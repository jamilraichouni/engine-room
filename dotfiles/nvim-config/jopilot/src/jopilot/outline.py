"""A Neovim plugin to post-process the location list showing Python symbols.

To execute this plugin, use the `:py3file
/path/to/python_symbol_list.py` command.
"""

import sys

import vim


def format_quickfix() -> list[str]:
    """Python implementation of quickfixtextfunc for custom display.

    This function is called by Vim for each visible portion of the quickfix
    list.
    """
    info = vim.eval("g:qf_format_info")
    winid = int(info["winid"])
    start_idx = int(info["start_idx"])
    end_idx = int(info["end_idx"])

    # Get the location list items
    items = vim.eval(f"getloclist({winid}, {{'items': 1}})['items']")

    formatted_lines = []
    for idx in range(start_idx - 1, end_idx):
        if idx < len(items):
            item = items[idx]
            text = item.get("text", "")
            formatted = text
            # fmt: off
            formatted = formatted.replace("[Array]",    "Array   :   ")
            formatted = formatted.replace("[Boolean]",  "Boolean :   ")
            formatted = formatted.replace("[Class]",    "Class   :   ")
            formatted = formatted.replace("[Constant]", "Constant:   ")
            formatted = formatted.replace("[Field]",    "Field   :   ")
            formatted = formatted.replace("[Function]", "Function:   ")
            formatted = formatted.replace("[Method]",   "Method  :   ")
            formatted = formatted.replace("[Module]",   "Module  :   ")
            formatted = formatted.replace("[Number]",   "Number  :   ")
            formatted = formatted.replace("[Object]",   "Object  :   ")
            formatted = formatted.replace("[Package]",  "Package :   ")
            formatted = formatted.replace("[String]",   "String  :   ")
            formatted = formatted.replace("[Variable]", "Variable:   ")
            # fmt: on
            formatted_lines.append(formatted)
    return formatted_lines


vim.command("""
function! SymbolFormatter(info) abort
    let g:qf_format_info = a:info
    return py3eval('format_quickfix()')
endfunction
""")
filetype = vim.eval("&filetype")
if filetype == "markdown":
    vim.exec_lua("require('vim.treesitter._headings').show_toc()")
elif filetype:
    vim.command("lua vim.lsp.buf.document_symbol()")
    vim.command("sleep 100m")
    vim.command("setlocal quickfixtextfunc=SymbolFormatter")
