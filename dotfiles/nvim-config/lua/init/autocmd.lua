vim.g.augroup_jar = vim.api.nvim_create_augroup("augroup_jar", { clear = true })
-- BufReadPost {{{
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "*" },
    callback = function(args)
        local file = args.file
        local file_size_kb = vim.fn.getfsize(file) / 1024
        if file_size_kb > 1000 then
            vim.cmd.setlocal("foldmethod=manual")
        end
    end,
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "*.class" },
    callback = function(args)
        if vim.bo.filetype == "java" then
            return
        end
        vim.bo.filetype = "java"
        -- vim.cmd.edit()
    end
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "**/snippets/*.json" },
    callback = function(args)
        vim.wo.foldmethod = "expr"
        vim.wo.foldlevel = 1
    end
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "COMMIT_EDITMSG" },
    command = "startinsert"
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "MANIFEST.MF" },
    command = "setlocal colorcolumn=72"
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "*/init/*.lua", "*/plugins/*.lua" },
    command = "setlocal foldmethod=marker"
})
-- }}}
-- Term... {{{
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = vim.g.augroup_jar,
    command = "setlocal colorcolumn=0 nomodified nonumber ruler norelativenumber"
})
vim.api.nvim_create_autocmd({ "TermClose" }, {
    group = vim.g.augroup_jar,
    callback = function()
        vim.o.ruler = true
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
    end,
})
-- }}}
