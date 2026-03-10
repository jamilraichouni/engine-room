#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright DB InfraGO AG
# SPDX-License-Identifier: LicenseRef-DBPROPRIETARY
"""See ``python polariondoc2yaml.py --help``."""

import collections
import html
import html.parser
import io
import logging
import re
import sys
import typing as t

import click
import polarion_rest_api_client as polarion_api
import yaml
from polarion_rest_api_client.open_api_client import types as oa_types

logger = logging.getLogger(__name__)
POLARION_BASE_URL = "https://awspoldsdpu.polarion.comp.db.de/polarion"
REST_API_ENDPOINT = "/rest/v1"
CLI_HELP = (
    "Query requirements from a Polarion document via the REST API.\n\n"
    "This CLI uses the polarion-rest-api-client high-level client to "
    "fetch all work items that belong to a specific document, identified "
    "by project ID, space ID and document ID. It serializes id, "
    "outlineNumber, title, type, status, space, document, description, "
    "description_plain, rationale and linkedWorkItems, and writes YAML to "
    "stdout. The description_plain field is computed from description with "
    "HTML tags and entities removed. Inline work item links are resolved "
    "to double-quoted referenced work item titles, with the raw item ID as "
    "fallback. Inline document links are resolved to double-quoted "
    "referenced document titles, with the raw document name as fallback."
)
CLI_EPILOG = (
    "Prerequisites:\n"
    "  Install polarion-rest-api-client separately; it is not part of this "
    "project's dependencies.\n\n"
    "Examples:\n"
    '  export POLARION_PAT="your-personal-access-token"\n\n'
    "  python tools/polariondoc2yaml.py \\\n"
    "      --project-id AR_DKS \\\n"
    "      --space-id Interfaces \\\n"
    "      --document-id ARDKS_SYS_021\n\n"
    "  python tools/polariondoc2yaml.py \\\n"
    "      --project-id AR_DKS \\\n"
    "      --space-id Interfaces \\\n"
    "      --document-id ARDKS_SYS_021 \\\n"
    '      --filter "priority:90.0"\n\n'
    "  python tools/polariondoc2yaml.py \\\n"
    "      --project-id OTHER_PROJECT \\\n"
    "      --space-id MySpace \\\n"
    "      --document-id MY_DOC_001"
)


def create_client(
    api_endpoint: str,
    token: str,
    page_size: int,
) -> polarion_api.PolarionClient:
    """Create and return a Polarion API client.

    Args:
        api_endpoint: Polarion REST API endpoint URL.
        token: Personal access token for authentication.
        page_size: Number of items per page when paginating.

    Returns:
        Configured Polarion client instance.
    """
    return polarion_api.PolarionClient(
        polarion_api_endpoint=api_endpoint,
        polarion_access_token=token,
        page_size=page_size,
    )


def fetch_document(
    project_client: polarion_api.ProjectClient,
    space_id: str,
    document_id: str,
) -> polarion_api.Document | None:
    """Fetch a single document from Polarion.

    Args:
        project_client: Project-specific Polarion client.
        space_id: Document space (module_folder) ID.
        document_id: Document (module_name) ID.

    Returns:
        Document instance or ``None`` if not found.
    """
    return project_client.documents.get(space_id, document_id)


def _build_query(
    space_id: str,
    document_id: str,
    filter_query: str,
) -> str:
    """Build a Polarion Lucene query string.

    Starts with a document scope clause and appends an optional
    free-form Lucene query.

    Args:
        space_id: Document space (module_folder) ID.
        document_id: Document (module_name) ID.
        filter_query: Additional free-form Lucene filter.

    Returns:
        Combined Lucene query string.
    """
    clauses = [f"document.id:{space_id}/{document_id}"]
    if filter_query:
        clauses.append(f"({filter_query})")
    return " AND ".join(clauses)


def _inject_additional_attributes(
    original_method: t.Callable[..., polarion_api.WorkItem],
    raw_work_item: t.Any,
    work_item_cls: type[polarion_api.WorkItem],
) -> polarion_api.WorkItem:
    """Generate a WorkItem and recover dropped attributes.

    The high-level client drops additional attributes during
    conversion because the OpenAPI model pops them from the
    attribute dictionary before ``additional_properties`` is
    assigned. This wrapper calls the original conversion and
    injects selected values back into ``additional_attributes``.

    Args:
        original_method: Bound reference to the original
            ``_generate_work_item`` method.
        raw_work_item: Raw OpenAPI work item response object.
        work_item_cls: WorkItem class to instantiate.

    Returns:
        WorkItem with recovered values in
        ``additional_attributes``.
    """
    wi = original_method(raw_work_item, work_item_cls)
    outline = getattr(
        raw_work_item.attributes,
        "outline_number",
        oa_types.UNSET,
    )
    if not isinstance(outline, oa_types.Unset):
        wi.additional_attributes["outlineNumber"] = outline
    rationale = getattr(
        raw_work_item.attributes,
        "rationale",
        oa_types.UNSET,
    )
    if not isinstance(rationale, oa_types.Unset):
        wi.additional_attributes["rationale"] = rationale
    return wi


def fetch_work_items(
    project_client: polarion_api.ProjectClient,
    space_id: str,
    document_id: str,
    filter_query: str,
) -> list[polarion_api.WorkItem]:
    """Fetch all work items from a document.

    Combines the document scope query with an optional free-form
    Lucene filter. Paginates through all results automatically.
    Includes outlineNumber, rationale and linked work items.

    Args:
        project_client: Project-specific Polarion client.
        space_id: Document space (module_folder) ID.
        document_id: Document (module_name) ID.
        filter_query: Additional Lucene filter to restrict work items.

    Returns:
        List of work item objects.
    """
    doc_query = _build_query(space_id, document_id, filter_query)
    logger.debug("Query work items with: %s", doc_query)
    fields = {
        "workitems": (
            "id,title,description,status,type,outlineNumber,rationale"
        ),
        "linkedworkitems": "id,role,suspect",
    }
    work_items = t.cast(t.Any, project_client.work_items)
    original = work_items._generate_work_item
    work_items._generate_work_item = lambda raw, cls: (
        _inject_additional_attributes(original, raw, cls)
    )
    try:
        items = work_items.get_all(
            query=doc_query,
            fields=fields,
        )
    finally:
        work_items._generate_work_item = original
    return items


_BLOCK_TAGS = frozenset(
    {
        "address",
        "article",
        "aside",
        "blockquote",
        "br",
        "dd",
        "details",
        "dialog",
        "div",
        "dl",
        "dt",
        "fieldset",
        "figcaption",
        "figure",
        "footer",
        "form",
        "h1",
        "h2",
        "h3",
        "h4",
        "h5",
        "h6",
        "header",
        "hgroup",
        "hr",
        "li",
        "main",
        "nav",
        "ol",
        "p",
        "pre",
        "section",
        "summary",
        "table",
        "tbody",
        "td",
        "tfoot",
        "th",
        "thead",
        "tr",
        "ul",
    }
)
_RTE_LINK_RE = re.compile(r'data-item-id="([^"]+)"', re.IGNORECASE)
_RTE_SCOPE_RE = re.compile(r'data-scope="([^"]+)"', re.IGNORECASE)
_RTE_DOC_NAME_RE = re.compile(r'data-item-name="([^"]+)"', re.IGNORECASE)
_RTE_DOC_SPACE_RE = re.compile(r'data-space-name="([^"]+)"', re.IGNORECASE)
_RTE_TYPE_RE = re.compile(r'data-type="([^"]+)"', re.IGNORECASE)


class _HTMLTextExtractor(html.parser.HTMLParser):
    """HTML parser that collects visible text content.

    Resolves ``polarion-rte-link`` spans by replacing them
    with the double-quoted referenced work item or document
    title from lookup dicts.

    Args:
        title_lookup: Mapping of ``(scope_or_empty, item_id)``
            to the work item title string.
        doc_title_lookup: Mapping of
            ``(space, document_name)`` to the document title
            string.
    """

    def __init__(
        self,
        title_lookup: dict[tuple[str, str], str] | None = None,
        doc_title_lookup: (dict[tuple[str, str], str] | None) = None,
    ) -> None:
        super().__init__()
        self._buf = io.StringIO()
        self._titles = title_lookup or {}
        self._doc_titles = doc_title_lookup or {}

    def handle_starttag(
        self,
        tag: str,
        attrs: list[tuple[str, str | None]],
    ) -> None:
        if tag in _BLOCK_TAGS:
            self._buf.write(" ")
            return
        if tag != "span":
            return
        attr_dict = dict(attrs)
        css_class = attr_dict.get("class") or ""
        if "polarion-rte-link" not in css_class:
            return
        data_type = (attr_dict.get("data-type") or "").lower()
        if data_type == "document":
            self._handle_doc_link(attr_dict)
        else:
            self._handle_wi_link(attr_dict)

    def _handle_wi_link(self, attr_dict: dict[str, str | None]) -> None:
        item_id = attr_dict.get("data-item-id") or ""
        scope = attr_dict.get("data-scope") or ""
        title = self._titles.get((scope, item_id))
        if title:
            self._buf.write(f'"{title}"')
        else:
            self._buf.write(item_id or "")

    def _handle_doc_link(self, attr_dict: dict[str, str | None]) -> None:
        doc_name = attr_dict.get("data-item-name") or ""
        space = attr_dict.get("data-space-name") or ""
        title = self._doc_titles.get((space, doc_name))
        if title:
            self._buf.write(f'"{title}"')
        else:
            self._buf.write(doc_name or "")

    def handle_endtag(self, tag: str) -> None:
        if tag in _BLOCK_TAGS:
            self._buf.write(" ")

    def handle_data(self, data: str) -> None:
        self._buf.write(data)

    def get_text(self) -> str:
        """Return accumulated plain text.

        Returns:
            Concatenated text with collapsed whitespace.
        """
        return " ".join(self._buf.getvalue().split())


def _collect_link_refs(
    descriptions: list[str],
) -> dict[str, set[str]]:
    """Collect all ``polarion-rte-link`` work item references.

    Scans the given HTML descriptions for
    ``polarion-rte-link`` spans with ``data-type="workItem"``
    and groups the referenced work item IDs by project scope.

    Args:
        descriptions: List of raw HTML description strings.

    Returns:
        Mapping of scope (empty string for same-project) to
        the set of referenced work item IDs.
    """
    refs: dict[str, set[str]] = collections.defaultdict(set)
    for desc in descriptions:
        for chunk in desc.split("polarion-rte-link"):
            item_match = _RTE_LINK_RE.search(chunk)
            if not item_match:
                continue
            item_id = item_match.group(1)
            scope_match = _RTE_SCOPE_RE.search(chunk)
            scope = scope_match.group(1) if scope_match else ""
            refs[scope].add(item_id)
    return dict(refs)


def _collect_doc_refs(
    descriptions: list[str],
) -> set[tuple[str, str]]:
    """Collect all ``polarion-rte-link`` document references.

    Scans the given HTML descriptions for
    ``polarion-rte-link`` spans with
    ``data-type="document"`` and collects the referenced
    document space and name pairs.

    Args:
        descriptions: List of raw HTML description strings.

    Returns:
        Set of ``(space_name, document_name)`` tuples.
    """
    refs: set[tuple[str, str]] = set()
    for desc in descriptions:
        for chunk in desc.split("polarion-rte-link"):
            type_match = _RTE_TYPE_RE.search(chunk)
            if not type_match:
                continue
            if type_match.group(1).lower() != "document":
                continue
            name_match = _RTE_DOC_NAME_RE.search(chunk)
            if not name_match:
                continue
            space_match = _RTE_DOC_SPACE_RE.search(chunk)
            space = space_match.group(1) if space_match else ""
            refs.add((space, name_match.group(1)))
    return refs


def _resolve_link_titles(
    client: polarion_api.PolarionClient,
    project_id: str,
    refs: dict[str, set[str]],
) -> dict[tuple[str, str], str]:
    """Fetch titles for all referenced work items.

    Groups references by project scope and queries each
    project once for all its referenced IDs.

    Args:
        client: Top-level Polarion client.
        project_id: Default project ID for unscoped refs.
        refs: Mapping of scope to work item ID sets as
            returned by ``_collect_link_refs``.

    Returns:
        Mapping of ``(scope, item_id)`` to the work item
        title string.
    """
    titles: dict[tuple[str, str], str] = {}
    for scope, item_ids in refs.items():
        target_project = scope or project_id
        id_list = " ".join(item_ids)
        lucene = f"id:({id_list})"
        logger.debug(
            "Resolve %d linked titles from project %s ...",
            len(item_ids),
            target_project,
        )
        try:
            proj = client.generate_project_client(target_project)
            items = proj.work_items.get_all(
                query=lucene,
                fields={"workitems": "id,title"},
            )
        except Exception:
            logger.exception(
                "Failed to resolve titles for project %s:",
                target_project,
            )
            continue
        for wi in items:
            if wi.id and wi.title:
                titles[(scope, wi.id)] = wi.title
    return titles


def _resolve_doc_titles(
    client: polarion_api.PolarionClient,
    project_id: str,
    refs: set[tuple[str, str]],
) -> dict[tuple[str, str], str]:
    """Fetch titles for all referenced documents.

    Queries the Polarion API for each referenced document
    and returns a mapping from ``(space, document_name)``
    to the document title.

    Args:
        client: Top-level Polarion client.
        project_id: Project ID to query documents from.
        refs: Set of ``(space_name, document_name)`` tuples
            as returned by ``_collect_doc_refs``.

    Returns:
        Mapping of ``(space, document_name)`` to the
        document title string.
    """
    titles: dict[tuple[str, str], str] = {}
    for space, doc_name in refs:
        logger.debug(
            "Resolve document title for %s/%s ...",
            space,
            doc_name,
        )
        try:
            proj = client.generate_project_client(project_id)
            doc = proj.documents.get(
                space,
                doc_name,
                fields={"documents": "title"},
            )
        except Exception:
            logger.exception(
                "Failed to resolve document %s/%s:",
                space,
                doc_name,
            )
            continue
        if doc and doc.title:
            titles[(space, doc_name)] = doc.title
    return titles


def _strip_html(
    value: str,
    title_lookup: dict[tuple[str, str], str] | None = None,
    doc_title_lookup: dict[tuple[str, str], str] | None = None,
) -> str:
    """Remove HTML tags, decode entities and resolve links.

    ``polarion-rte-link`` spans referencing work items are
    replaced by the double-quoted title from *title_lookup*.
    Spans referencing documents are replaced by the
    double-quoted title from *doc_title_lookup*. When no
    title is found the raw ``data-item-id`` or
    ``data-item-name`` is used as unquoted fallback.

    Args:
        value: Raw HTML string.
        title_lookup: Mapping of ``(scope, item_id)`` to work
            item title.
        doc_title_lookup: Mapping of
            ``(space, document_name)`` to document title.

    Returns:
        Plain text with tags removed, entities decoded and
        whitespace collapsed.
    """
    if not value:
        return ""
    extractor = _HTMLTextExtractor(title_lookup, doc_title_lookup)
    extractor.feed(html.unescape(value))
    return extractor.get_text()


def _text_content_value(
    content: polarion_api.TextContent | str | None,
) -> str:
    """Extract the string value from a TextContent or string.

    Args:
        content: TextContent instance, plain string, or
            ``None``.

    Returns:
        Plain string value.
    """
    if content is None:
        return ""
    if isinstance(content, polarion_api.TextContent):
        return content.value or ""
    return str(content)


def serialize_link(
    link: polarion_api.WorkItemLink,
) -> dict[str, t.Any]:
    """Serialize a work item link to a JSON-compatible dictionary.

    Args:
        link: Polarion work item link object.

    Returns:
        Dictionary with role, secondary work item id, suspect
        flag and optional project and revision.
    """
    result: dict[str, t.Any] = {
        "role": link.role,
        "workItemId": link.secondary_work_item_id,
        "suspect": link.suspect,
    }
    if link.secondary_work_item_project:
        result["project"] = link.secondary_work_item_project
    if link.secondary_work_item_revision:
        result["revision"] = link.secondary_work_item_revision
    return result


def serialize_work_item(
    item: polarion_api.WorkItem,
    space_id: str,
    document_id: str,
    title_lookup: dict[tuple[str, str], str] | None = None,
    doc_title_lookup: (dict[tuple[str, str], str] | None) = None,
) -> dict[str, t.Any]:
    """Serialize a work item to a JSON-compatible dictionary.

    Args:
        item: Polarion work item object.
        space_id: Document space (module_folder) ID.
        document_id: Document (module_name) ID.
        title_lookup: Mapping of ``(scope, item_id)`` to work
            item title for resolving inline links.
        doc_title_lookup: Mapping of
            ``(space, document_name)`` to document title for
            resolving inline document links.

    Returns:
        Dictionary with id, outlineNumber, title, type, status,
        space, document, description, description_plain,
        rationale and linkedWorkItems fields.
    """
    additional = item.additional_attributes or {}
    rationale = additional.get("rationale")
    description = _text_content_value(item.description)
    return {
        "id": item.id or "",
        "outlineNumber": additional.get("outlineNumber", ""),
        "title": item.title or "",
        "type": item.type or "",
        "status": item.status or "",
        "space": space_id,
        "document": document_id,
        "description": description,
        "description_plain": _strip_html(
            description, title_lookup, doc_title_lookup
        ),
        "rationale": _text_content_value(rationale),
        "linkedWorkItems": [
            serialize_link(link) for link in (item.linked_work_items or [])
        ],
    }


def _outline_sort_key(
    item: dict[str, t.Any],
) -> tuple[int, ...]:
    """Return a numeric sort key for an outline number.

    Splits the outline string (e.g. ``4.2-9``) on ``.`` and
    ``-`` delimiters into integer segments so that ``4.2-1``
    sorts before ``4.2-9``. Items without an outline number
    are sorted last.

    Args:
        item: Serialized work item dictionary.

    Returns:
        Tuple of integers suitable for comparison.
    """
    outline = item.get("outlineNumber", "")
    if not outline:
        return (sys.maxsize,)
    parts: list[int] = []
    for segment in re.split(r"[.\-]", outline):
        try:
            parts.append(int(segment))
        except ValueError:
            parts.append(sys.maxsize)
    return tuple(parts)


def render_output(data: list[dict[str, t.Any]]) -> str:
    """Render serialized work items as YAML text.

    Args:
        data: List of serialized work item dictionaries.

    Returns:
        YAML representation of the given work items.
    """
    return yaml.dump(
        data,
        default_flow_style=False,
        allow_unicode=True,
        sort_keys=False,
    )


@click.command(help=CLI_HELP, epilog=CLI_EPILOG)
@click.option(
    "--project-id",
    "-p",
    required=True,
    help="Polarion project ID.",
)
@click.option(
    "--space-id",
    "-s",
    required=True,
    help="Document space or module_folder ID.",
)
@click.option(
    "--document-id",
    "-d",
    required=True,
    help="Document or module_name ID.",
)
@click.option(
    "--filter",
    "filter_query",
    default="",
    show_default=True,
    help="Additional Lucene filter to restrict work items.",
)
@click.option(
    "--personal-access-token",
    required=False,
    envvar="POLARION_PAT",
    help=(
        "Polarion personal access token. Uses POLARION_PAT when set. "
        "The base URL is fixed to "
        "https://awspoldsdpu.polarion.comp.db.de/polarion."
    ),
)
@click.option(
    "--page-size",
    default=100,
    show_default=True,
    type=int,
    help="Number of items per page.",
)
def main(
    project_id: str,
    space_id: str,
    document_id: str,
    filter_query: str,
    personal_access_token: str,
    page_size: int,
) -> None:
    """Query requirements from a Polarion document."""
    logging.basicConfig(
        level=logging.ERROR,
        format="%(levelname)s: %(message)s",
    )
    api_endpoint = POLARION_BASE_URL + REST_API_ENDPOINT
    client = create_client(
        api_endpoint,
        personal_access_token,
        page_size,
    )
    project_client = client.generate_project_client(project_id)
    if not project_client.exists():
        logger.error("Project %s does not exist.", project_id)
        sys.exit(1)
    logger.debug(
        "Fetch document %s/%s from project %s ...",
        space_id,
        document_id,
        project_id,
    )
    doc = fetch_document(project_client, space_id, document_id)
    if doc is None:
        logger.error("Document %s/%s not found.", space_id, document_id)
        sys.exit(1)
    logger.debug(
        "Fetch work items from document %s ...",
        doc.title or document_id,
    )
    items = fetch_work_items(
        project_client,
        space_id,
        document_id,
        filter_query,
    )
    descriptions = [_text_content_value(wi.description) for wi in items]
    refs = _collect_link_refs(descriptions)
    title_lookup = _resolve_link_titles(client, project_id, refs)
    doc_refs = _collect_doc_refs(descriptions)
    doc_title_lookup = _resolve_doc_titles(client, project_id, doc_refs)
    serialized = [
        serialize_work_item(
            wi,
            space_id,
            document_id,
            title_lookup,
            doc_title_lookup,
        )
        for wi in items
    ]
    serialized.sort(key=_outline_sort_key)
    sys.stdout.write(render_output(serialized))
    logger.debug(
        "Wrote %d work items to stdout",
        len(serialized),
    )


if __name__ == "__main__":
    main()
