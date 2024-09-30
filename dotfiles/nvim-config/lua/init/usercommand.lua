vim.api.nvim_create_user_command("Qa", "qa", { force = true })
vim.api.nvim_create_user_command("Showautocmd", "redir! > /tmp/.autocmd | silent autocmd | redir END | e /tmp/.autocmd",
    { force = true })
vim.api.nvim_create_user_command("Showmap", "redir! > /tmp/.map | silent map | redir END | e /tmp/.map", { force = true })
vim.api.nvim_create_user_command("WorkingTimesCompute", "lua vim.g.WorkingTimesCompute()", { force = true })
vim.api.nvim_create_user_command("WorkingTimesSaveAndClose", "write | bdelete", { force = true })
