vim.g.augroup_jar = vim.api.nvim_create_augroup("augroup_jar", { clear = true })

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
        vim.cmd("setlocal foldmethod=expr")
        vim.cmd("setlocal foldlevel=1")
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
            vim.cmd("setlocal foldmethod=expr")
            vim.cmd("setlocal foldlevel=0")
        else
            vim.cmd("setlocal foldmethod=marker")
            vim.cmd("setlocal foldlevel=1")
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
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = vim.g.augroup_jar,
    desc = "LSP format on save",
    nested = true,
    callback = function()
        local did_something = false

        if next(vim.lsp.get_clients { bufnr = 0, method = "textDocument/codeAction" }) ~= nil then
            local kind = "source.organizeImports"
            if vim.bo.filetype == "python" then
                kind = "source.organizeImports.ruff"
            end

            local has_ca = false
            vim.lsp.buf.code_action {
                context = { only = { kind } },
                filter = function(x)
                    if not has_ca then
                        has_ca = true
                        return true
                    end
                    return false
                end,
                apply = true,
            }
            did_something = true
        end

        if next(vim.lsp.get_clients { bufnr = 0, method = "textDocument/formatting" }) ~= nil then
            vim.lsp.buf.format { async = false }
            did_something = true
        end

        if not did_something then
            vim.api.nvim_echo({ { "Format-on-save failed, no matching language servers.", "Error" } }, true, {})
        end
    end,
})
