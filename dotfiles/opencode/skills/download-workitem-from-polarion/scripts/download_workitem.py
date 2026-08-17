#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright DB InfraGO AG
# SPDX-License-Identifier: LicenseRef-DBPROPRIETARY
"""Export one Polarion work item in the coverage YAML schema."""

import argparse
import html
import json
import os
import shlex
import subprocess
import sys
import typing as t
import urllib.parse
from html.parser import HTMLParser
from pathlib import Path

import yaml

BASE_URL = "https://awspoldsdpu.polarion.comp.db.de/polarion/rest/v1"
CANDIDATE_SUFFIXES = (".feature", ".feature.txt", ".gherkin", ".cucumber")


class LiteralDumper(yaml.SafeDumper):
    """Write multiline strings as YAML literal scalars."""

    def analyze_scalar(self, scalar: str) -> yaml.emitter.ScalarAnalysis:
        """Permit literal style for multiline text containing tabs."""
        analysis = super().analyze_scalar(scalar)
        if "\n" in scalar:
            analysis.allow_block = True
        return analysis


def represent_string(dumper: yaml.SafeDumper, value: str) -> yaml.Node:
    """Represent multiline strings without escaping their line breaks."""
    return dumper.represent_scalar(
        "tag:yaml.org,2002:str", value, style="|" if "\n" in value else None
    )


LiteralDumper.add_representer(str, represent_string)


def normalize_line_breaks(value: t.Any) -> t.Any:
    """Convert all exported text line endings to LF recursively."""
    if isinstance(value, str):
        return value.replace("\r\n", "\n").replace("\r", "\n")
    if isinstance(value, list):
        return [normalize_line_breaks(entry) for entry in value]
    if isinstance(value, dict):
        return {
            key: normalize_line_breaks(entry) for key, entry in value.items()
        }
    return value


class UniqueKeyLoader(yaml.SafeLoader):
    """Reject YAML mappings with duplicate keys."""


def construct_mapping(
    loader: UniqueKeyLoader, node: yaml.MappingNode, deep: bool = False
) -> dict[t.Any, t.Any]:
    """Construct a mapping while rejecting duplicate keys."""
    mapping: dict[t.Any, t.Any] = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in mapping:
            raise yaml.constructor.ConstructorError(
                "while constructing a mapping",
                node.start_mark,
                f"found duplicate key {key!r}",
                key_node.start_mark,
            )
        mapping[key] = loader.construct_object(value_node, deep=deep)
    return mapping


UniqueKeyLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, construct_mapping
)


def valid_id(value: str, name: str) -> str:
    """Accept a non-empty Polarion identifier without path separators."""
    if not value or value in {".", ".."} or "/" in value or "\\" in value:
        raise argparse.ArgumentTypeError(
            f"{name} must be a single path segment"
        )
    return value


def request(url: str, accept: str = "application/json") -> t.Any:
    """Retrieve a Polarion resource using the configured bearer token."""
    command = [
        "curl",
        "--fail-with-body",
        "--silent",
        "--show-error",
        "--header",
        f"Accept: {accept}",
        "--header",
        "@-",
        url,
    ]
    print(shlex.join(command), file=sys.stderr)
    result = subprocess.run(
        command,
        check=True,
        capture_output=True,
        input=(
            f"Authorization: Bearer {os.environ['POLARION_PAT_PU']}\n"
        ).encode(),
    )
    return (
        json.loads(result.stdout)
        if accept == "application/json"
        else result.stdout
    )


def resource(project: str, work_item: str) -> dict[str, t.Any]:
    """Retrieve all fields for one work item."""
    path = "/projects/{}/workitems/{}?fields%5Bworkitems%5D=%40all".format(
        urllib.parse.quote(project, safe=""),
        urllib.parse.quote(work_item, safe=""),
    )
    return request(BASE_URL + path)["data"]


class TextParser(HTMLParser):
    """Extract visible description text and resolve inline work-item links."""

    def __init__(self, project: str) -> None:
        super().__init__()
        self.project = project
        self.parts: list[str] = []

    def handle_data(self, data: str) -> None:
        """Preserve visible text."""
        self.parts.append(data)

    def handle_starttag(
        self, tag: str, attrs: list[tuple[str, str | None]]
    ) -> None:
        """Replace Polarion RTE link spans with their linked titles."""
        attributes = dict(attrs)
        if tag == "br" or tag in {"div", "li", "p", "td", "th", "tr"}:
            self.parts.append(" ")
        classes = attributes.get("class") or ""
        if tag != "span" or "polarion-rte-link" not in classes:
            return
        linked_id = attributes.get("data-item-id")
        if not linked_id:
            return
        linked_project = attributes.get("data-scope") or self.project
        try:
            title = resource(linked_project, linked_id)["attributes"].get(
                "title"
            )
        except subprocess.CalledProcessError:
            title = None
        self.parts.append(f'"{title}"' if title else linked_id)


def plain_description(project: str, item: dict[str, t.Any]) -> str:
    """Derive HTML-free text from a rich work-item description."""
    description = item["attributes"].get("description", {})
    value = (
        description.get("value", "")
        if isinstance(description, dict)
        else description
    )
    parser = TextParser(project)
    parser.feed(value or "")
    parser.close()
    text = " ".join(html.unescape("".join(parser.parts)).split())
    if "<" in text or "polarion-rte-link" in text:
        raise ValueError("requirement text contains HTML markup")
    return text


def collection(url: str) -> list[dict[str, t.Any]]:
    """Retrieve all pages of a Polarion collection."""
    entries: list[dict[str, t.Any]] = []
    while url:
        payload = request(url)
        entries.extend(payload.get("data", []))
        url = payload.get("links", {}).get("next")
    return entries


def cucumber_attachment(project: str, work_item: str) -> str | None:
    """Return a readable Cucumber attachment only if exactly one exists."""
    encoded_project = urllib.parse.quote(project, safe="")
    encoded_work_item = urllib.parse.quote(work_item, safe="")
    attachments = collection(
        f"{BASE_URL}/projects/{encoded_project}/workitems/"
        f"{encoded_work_item}/attachments"
    )
    candidates: list[bytes] = []
    for attachment in attachments:
        name = attachment["id"].rsplit("/", 1)[-1].lower()
        if not name.endswith(CANDIDATE_SUFFIXES):
            continue
        content_url = attachment.get("links", {}).get("content")
        if not content_url:
            continue
        try:
            content = request(content_url, "application/octet-stream")
        except subprocess.CalledProcessError:
            continue
        if content:
            candidates.append(content)
    if len(candidates) != 1:
        return None
    return candidates[0].decode("utf-8")


def linked_test_cases(project: str, work_item: str) -> list[dict[str, t.Any]]:
    """Retrieve verification links and retain only linked system test cases."""
    encoded_project = urllib.parse.quote(project, safe="")
    encoded_work_item = urllib.parse.quote(work_item, safe="")
    backlinks = collection(
        f"{BASE_URL}/projects/{encoded_project}/workitems/"
        f"{encoded_work_item}/backlinkedworkitems?"
        "fields%5Bworkitems%5D=%40all&page%5Bsize%5D=100&page%5Bnumber%5D=1"
    )
    tests: list[dict[str, t.Any]] = []
    for backlink in backlinks:
        parts = backlink["id"].split("/")
        if len(parts) != 5 or parts[2] != "verifies":
            continue
        linked_project, linked_id = parts[:2]
        linked = resource(linked_project, linked_id)
        attributes = linked["attributes"]
        if attributes.get("type") != "systemtestcase":
            continue
        test: dict[str, t.Any] = {
            "work item id": linked_id,
            "work item type": "systemtestcase",
            "project id": linked_project,
        }
        cucumber = cucumber_attachment(linked_project, linked_id)
        if cucumber is not None:
            test["cucumber test"] = cucumber
        test["description"] = plain_description(linked_project, linked)
        test["suspect"] = (
            backlink.get("attributes", {}).get("suspect") is True
        )
        tests.append(test)
    return tests


def output_path(output_directory: Path, project: str, work_item: str) -> Path:
    """Return the validated output path below the requested directory."""
    directory = output_directory.resolve()
    if not directory.is_dir():
        raise ValueError(f"output directory does not exist: {directory}")
    output = (directory / f"{project}_{work_item}.yaml").resolve()
    if output.parent != directory:
        raise ValueError("output path escapes output directory")
    return output


def parse_arguments() -> argparse.Namespace:
    """Parse exporter arguments."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "project_id", type=lambda value: valid_id(value, "project ID")
    )
    parser.add_argument(
        "workitem_id", type=lambda value: valid_id(value, "work-item ID")
    )
    parser.add_argument("output_directory", nargs="?", default=".", type=Path)
    parser.add_argument("--overwrite", action="store_true")
    return parser.parse_args()


def main() -> None:
    """Create and validate the requested single-work-item YAML export."""
    arguments = parse_arguments()
    if not os.environ.get("POLARION_PAT_PU"):
        sys.exit("POLARION_PAT_PU is unset")
    output = output_path(
        arguments.output_directory, arguments.project_id, arguments.workitem_id
    )
    if output.exists() and not arguments.overwrite:
        sys.exit(f"refusing to overwrite existing file: {output}")
    item = resource(arguments.project_id, arguments.workitem_id)
    if item["id"] != f"{arguments.project_id}/{arguments.workitem_id}":
        raise ValueError("Polarion returned a different work-item ID")
    document = [
        {
            "work item id": arguments.workitem_id,
            "requirement text": plain_description(arguments.project_id, item),
            "work item type": item["attributes"]["type"],
            "project id": arguments.project_id,
            "linked test cases": linked_test_cases(
                arguments.project_id, arguments.workitem_id
            ),
        }
    ]
    document = normalize_line_breaks(document)
    serialized = yaml.dump(
        document,
        Dumper=LiteralDumper,
        allow_unicode=True,
        sort_keys=False,
        width=79,
    )
    if "\r" in serialized:
        raise ValueError("serialized YAML contains a carriage return")
    if "\\n" in serialized or "\\r" in serialized:
        raise ValueError("serialized YAML contains escaped line breaks")
    output.write_text(serialized, encoding="utf-8")
    parsed = yaml.load(
        output.read_text(encoding="utf-8"), Loader=UniqueKeyLoader
    )
    if parsed != document or len(parsed) != 1:
        output.unlink()
        raise ValueError("written YAML does not match the export schema")


if __name__ == "__main__":
    main()
