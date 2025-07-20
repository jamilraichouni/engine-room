vim.cmd.colorscheme("habamax")
vim.cmd("filetype plugin indent on")

require("init.autocmd")
require("init.function")
require("init.global")
require("init.highlight")
require("init.keymap")
require("init.lazy")
require("init.option")
require("init.usercommand")

vim.cmd.set("foldtext=g:fold_text()")
require("mason-registry").update()

if vim.loop.os_gethostname():find("dbmac") then
    local capella_version = "6.0.0"
    if vim.fn.isdirectory("/opt/capella_" .. capella_version) == 1 then
        vim.g.SetCapellaVersion(capella_version)
    end
end
