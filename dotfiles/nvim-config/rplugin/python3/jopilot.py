"""The jopilot Neovim plugin.

# After every change:

:UpdateRemotePlugins
:source /home/nerd/.local/share/nvim/rplugin.vim

# Develop in IPython

Start IPython in Neovim and use `vim` to access the Neovim API.
This works because of the setup in
`~/engine-room/dotfiles/ipython/profile_default/startup/01-nvim.py`.

# Docs

## pynvim docs

https://pynvim.readthedocs.io/en/latest/index.html

## Help pages

index
lua-vimscript
vimscript-functions
api.txt             - funcs to call via `vim.request("func_name")`
vimfn.txt           - funcs to call via `vim.func_name()`
```
"""

import pathlib

import pynvim
from pynvim.api.nvim import Nvim

vim: Nvim


@pynvim.plugin
class Jopilot:
    def __init__(self, vim_: Nvim):
        global vim  # noqa: PLW0603
        vim = vim_

    @pynvim.command("JoUpdate", range="", nargs="*", sync=True)
    def update(self, _1, _2):  # args, range
        rplugin_path = pathlib.Path.home() / ".local/share/nvim/rplugin.vim"
        rplugin_path.unlink(missing_ok=True)
        vim.command("UpdateRemotePlugins")
        rplugin_path = pathlib.Path.home() / ".local/share/nvim/rplugin.vim"
        rplugin_path.unlink(missing_ok=True)
        vim.command("UpdateRemotePlugins")

    @pynvim.command("JoTest", range="", nargs="*", sync=True)
    def test(self, _1, _2):  # args, range
        vim.command("echo 'Test2'")

    # @pynvim.autocmd(
    #     "BufEnter", pattern="*.py", eval='expand("<afile>")', sync=True
    # )
    # def autocmd_handler(self, filename):
    #     vim.command(f"echo 'File entered: {filename}'")
    #     print("Hello")
    #
    # @pynvim.function("Func")
    # def function_handler(self, args):
    #     vim.command("echo 'Function called'")
