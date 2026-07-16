vim.cmd.colorscheme("habamax")
vim.g.terminal_ansi_colors = {
    '#000000',
    '#cd0000',
    '#00cd00',
    '#cdcd00',
    '#0000ee',
    '#cd00cd',
    '#00cdcd',
    '#e5e5e5',
    '#7f7f7f',
    '#ff0000',
    '#00ff00',
    '#ffff00',
    '#5c5cff',
    '#ff00ff',
    '#00ffff',
    '#ffffff'
}
for i = 0, #vim.g.terminal_ansi_colors - 1 do
    vim.g['terminal_color_' .. i] = vim.g.terminal_ansi_colors[i + 1]
end
vim.cmd("filetype plugin indent on")

require("init.global")

require("init.lazy")
require("init.autocmd")
require("init.function")
require("init.highlight")
require("init.keymap")
require("init.lsp")
require("init.option")
require("init.diagnostic")
require("init.usercommand")

vim.cmd.set("foldtext=g:fold_text()")

-- require('vim._core.ui2').enable({
--     enable = true, -- Whether to enable or disable the UI.
--     -- msg = {        -- Options related to the message module.
--     --     ---@type 'cmd'|'msg' Default message target, either in the
--     --     ---cmdline or in a separate ephemeral message window.
--     --     ---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
--     --     ---or table mapping |ui-messages| kinds and triggers to a target.
--     --     targets = 'cmd',
--     --     cmd = {             -- Options related to messages in the cmdline window.
--     --         height = 0.5    -- Maximum height while expanded for messages beyond 'cmdheight'.
--     --     },
--     --     dialog = {          -- Options related to dialog window.
--     --         height = 0.5,   -- Maximum height.
--     --     },
--     --     msg = {             -- Options related to msg window.
--     --         height = 0.5,   -- Maximum height.
--     --         timeout = 4000, -- Time a message is visible in the message window.
--     --     },
--     --     pager = {           -- Options related to message window.
--     --         height = 1,     -- Maximum height.
--     --     },
--     -- },
-- })
