vim.api.nvim_create_user_command("CapellaSetVersion", "lua vim.g.SetCapellaVersion(<f-args>)",
    { nargs = 1, force = true }
)
vim.api.nvim_create_user_command("HTML2FT", "%s/\\v(\\w+)\\(/\\=printf('ft.%s(', submatch(1))/g | nohl", { force = true })
vim.api.nvim_create_user_command("Qa", "qa", { force = true })
vim.api.nvim_create_user_command("Showautocmd", "redir! > /tmp/.autocmd | silent autocmd | redir END | e /tmp/.autocmd",
    { force = true })
vim.api.nvim_create_user_command("JarShowmap", "redir! > /tmp/.map | silent map | redir END | e /tmp/.map", { force = true })
vim.api.nvim_create_user_command("TSInspect", "Inspect!", { force = true })
vim.api.nvim_create_user_command("WorkingTimesCompute", "lua vim.g.WorkingTimesCompute()", { force = true })
vim.api.nvim_create_user_command("WorkingTimesSaveAndClose", "write | bdelete", { force = true })
