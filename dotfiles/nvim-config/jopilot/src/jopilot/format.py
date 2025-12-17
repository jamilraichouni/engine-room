"""A Neovim plugin to format the current buffer."""

import json

import vim


def format_json() -> list[str]:
    """Python implementation to format current JSON buffer."""
    try:
        raw = "\n".join(vim.current.buffer[:])
        parsed = json.loads(raw)
        formatted = json.dumps(parsed, indent=2)
        processed = formatted.splitlines()
    except Exception as exp:  # noqa: BLE001
        processed = ["An error occurred during JSON formatting: " + str(exp)]
    return processed


filetype = vim.eval("&filetype")
if filetype == "json":
    vim.current.buffer[:] = format_json()
else:
    vim.exec_lua("vim.lsp.buf.format({timeout_ms = 10000})")
