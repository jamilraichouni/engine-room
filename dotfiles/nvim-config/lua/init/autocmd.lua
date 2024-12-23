vim.g.augroup_jar = vim.api.nvim_create_augroup("augroup_jar", { clear = true })

-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1337#issuecomment-1397639999
vim.api.nvim_create_autocmd({ "BufEnter" }, { pattern = { "*" }, command = "normal zx", })

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
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "*.class" },
    callback = function(_)
        if vim.bo.filetype == "java" then
            return
        end
        vim.bo.filetype = "java"
        -- vim.cmd.edit()
    end
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "*.log" },
    callback = function(_)
        vim.cmd.highlight("LogDebug", "guifg=#767676")
        vim.cmd.highlight("LogInfo", "guifg=#5fc83b")
        vim.cmd.highlight("LogWarning", "guifg=#c6c43f")
        vim.cmd.highlight("LogError", "guifg=#bb281b")
        vim.cmd.highlight("LogCritical", "guifg=#bb281b")
        -- Below, the `20` matches the century of the datetime stamp in a log file.
        vim.fn.matchadd('LogDebug', '.*20.*DEBUG.*')
        vim.fn.matchadd('LogInfo', '.*20.*INFO.*')
        vim.fn.matchadd('LogWarning', '.*20.*WARNING.*')
        vim.fn.matchadd('LogError', '.*20.*ERROR.*')
        vim.fn.matchadd('LogCritical', '.*20.*CRITICAL.*')
    end
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "**/engine-room/images/*" },
    callback = function(_)
        vim.bo.filetype = "dockerfile"
    end
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "**/engine-room/config.yml" },
    callback = function(_)
        vim.cmd.setlocal("nofoldenable")
    end
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "**/snippets/*.json" },
    callback = function(_)
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
    callback = function(_)
        if vim.fn.match(vim.fn.expand("<afile>"), "lua/init/function.lua") then
            vim.wo.foldmethod = "expr"
            vim.wo.foldlevel = 0
        else
            vim.wo.foldmethod = "marker"
            vim.wo.foldlevel = 1
        end
    end
})
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
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = vim.g.augroup_jar,
    pattern = { "*.java" },
    callback = function(_)
        if vim.bo.filetype ~= "java" then
            return
        end
        local bufnr = vim.api.nvim_get_current_buf()
        local jdtls_lspclients = vim.lsp.get_clients(
            { name = "jdtls", bufnr = bufnr }
        )
        if #jdtls_lspclients == 0 then
            return
        end
        -- give the LSP server time to process the file
        vim.defer_fn(function()
            vim.cmd("silent! JdtUpdateHotcode")
        end, 500)
    end
})
