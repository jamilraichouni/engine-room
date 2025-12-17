import os

import pynvim

vim = pynvim.attach("socket", path=os.environ["NVIM"])
vim.command(
    "pyfile /home/nerd/engine-room/dotfiles/nvim-config/jopilot/debug.py"
)
