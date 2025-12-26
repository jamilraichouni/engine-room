"""A Neovim plugin to format the current buffer."""

import os
import pathlib
import subprocess

import vim  # type: ignore[unresolved-import]


def end_buffer_with_newline() -> None:
    """Ensure the current buffer ends with a newline."""
    if vim.current.buffer[-1] != "":
        vim.current.buffer.append("")


def prettier(
    parser: str,
    plugins: tuple[pathlib.Path, ...] = (),
    options: dict[str, str] | None = None,
) -> list[str]:
    """Format current buffer with `prettier`."""
    if options is None:
        options = {}
    content_lst = vim.current.buffer[:]
    content_str = "\n".join(content_lst)
    cmd = [f"{os.getenv('NVM_BIN')}/prettier", "--parser", parser]
    cfg = pathlib.Path(vim.eval("getcwd()")) / ".prettierrc.toml"
    if cfg.exists():
        cmd.extend(["--config", str(cfg)])
    else:
        cmd.append("--print-width=79")
        cmd.append("--tab-width=2")
    if options:
        for k, v in options.items():
            cmd.append(k) if v is None else cmd.append(f"{k}={v}")
    for plugin in plugins:
        cmd.extend(["--plugin", str(plugin)])
    proc_result = subprocess.run(
        cmd,
        input=content_str,
        text=True,
        capture_output=True,
        check=False,
    )
    if proc_result.returncode == 0:
        content_lst = proc_result.stdout.splitlines()
    else:
        msg = f"{' '.join(cmd)}\n{proc_result.stderr}"
        raise RuntimeError(msg)
    return content_lst


filetype = vim.eval("&filetype")
match filetype:
    case "bash" | "sh" | "zsh":
        plugins = tuple(
            pathlib.Path(os.environ["NVM_BIN"]).glob(
                "../lib/**/prettier-plugin-sh/lib/index.js"
            )
        )
        vim.current.buffer[:] = prettier(
            parser="sh",
            plugins=plugins,
            options={
                "--indent": "2",
            },
        )
        end_buffer_with_newline()
    case "css" | "json":
        vim.current.buffer[:] = prettier(filetype)
        end_buffer_with_newline()
    case "html":
        plugins = tuple(
            pathlib.Path(os.environ["NVM_BIN"]).glob(
                "../lib/**/prettier-plugin-tailwindcss/dist/index.mjs"
            )
        )
        vim.current.buffer[:] = prettier(
            parser=filetype,
            plugins=plugins,
            options={
                "--single-attribute-per-line": "true",
            },
        )
        end_buffer_with_newline()
    case "javascript":
        vim.current.buffer[:] = prettier(parser="babel")
        end_buffer_with_newline()
    case (
        "j2" | "jinja" | "jinja2" | "jinja.html" | "htmldjango" | "django-html"
    ):
        plugins = (
            next(
                iter(
                    pathlib.Path(os.environ["NVM_BIN"]).glob(
                        "../lib/**/prettier-plugin-jinja-template/lib/index.js"
                    )
                )
            ),
            next(
                iter(
                    pathlib.Path(os.environ["NVM_BIN"]).glob(
                        "../lib/**/prettier-plugin-tailwindcss/dist/index.mjs"
                    )
                )
            ),
        )
        vim.current.buffer[:] = prettier(
            parser="jinja-template",
            plugins=plugins,
            options={
                "--single-attribute-per-line": "true",
            },
        )
        end_buffer_with_newline()
    case "markdown":
        vim.current.buffer[:] = prettier(
            parser=filetype,
            options={
                "--prose-wrap": "always",
            },
        )
    case "toml":
        plugins = tuple(
            pathlib.Path(os.environ["NVM_BIN"]).glob(
                "../lib/**/prettier-plugin-toml/lib/index.js"
            )
        )
        vim.current.buffer[:] = prettier(
            parser=filetype,
            plugins=plugins,
            options={
                "--array-auto-expand": "true",
                "--array-auto-collapse": "false",
            },
        )
        end_buffer_with_newline()
    case "xml":
        plugins = tuple(
            pathlib.Path(os.environ["NVM_BIN"]).glob(
                "../lib/**/plugin-xml/src/plugin.js"
            )
        )
        vim.current.buffer[:] = prettier(
            parser=filetype,
            plugins=plugins,
            options={
                "--array-auto-expand": "true",
                "--array-auto-collapse": "false",
            },
        )
        end_buffer_with_newline()
    case _:
        vim.exec_lua("vim.lsp.buf.format({timeout_ms = 10000})")
        end_buffer_with_newline()

