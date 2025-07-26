vim.g.augroup_jar = vim.api.nvim_create_augroup("augroup_jar", { clear = true })

local function colorize_logs()
    vim.cmd.highlight("LogDebug", "guifg=#767676")
    vim.cmd.highlight("LogWarning", "guifg=#c6c43f")
    vim.cmd.highlight("LogError", "guifg=#bb281b")
    vim.cmd.highlight("LogCritical", "guifg=#bb281b")
    -- Below, the `20` matches the century of the datetime stamp in a log file.
    vim.fn.matchadd('LogDebug', '.*20.*DEBUG.*')
    vim.fn.matchadd('Special', '.*20.*INFO.*')
    vim.fn.matchadd('LogWarning', '.*20.*WARNING.*')
    vim.fn.matchadd('LogError', '.*20.*ERROR.*')
    vim.fn.matchadd('LogCritical', '.*20.*CRITICAL.*')
end

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
    pattern = { ".env" },
    callback = function(_)
        vim.b.copilot_enabled = false
    end
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
        colorize_logs()
    end
})
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = vim.g.augroup_jar,
    callback = function(_)
        colorize_logs()
    end
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "**/engine-room/images/*" },
    callback = function(_)
        vim.bo.filetype = "dockerfile"
    end
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "**/vim-ai-roles.ini" },
    command = "setlocal wrap"
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "**/snippets/*.json" },
    callback = function(_)
        vim.cmd("setlocal foldlevel=1")
    end
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "COMMIT_EDITMSG" },
    command = "AI /commit-message"
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = vim.g.augroup_jar,
    pattern = { "MANIFEST.MF" },
    command = "setlocal colorcolumn=72"
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
        if vim.bo.filetype == "lua" or vim.bo.filetype == "markdown" or vim.bo.filetype == "python" then
            local did_something = false

            if next(vim.lsp.get_clients { bufnr = 0, method = "textDocument/codeAction" }) ~= nil then
                local kind = "source.organizeImports"
                if vim.bo.filetype == "python" then
                    kind = "source.organizeImports.ruff"
                end

                local has_code_action = false
                vim.lsp.buf.code_action {
                    context = { only = { kind } },
                    filter = function(_)
                        if not has_code_action then
                            has_code_action = true
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
        end
    end
})
vim.api.nvim_create_autocmd({ "LspAttach" }, {
    group = vim.g.augroup_jar,
    callback = function(args)
        local opts = { buffer = args.buf }
        vim.keymap.set("n", "<leader>ltb", "<cmd>lua vim.lsp.buf.typehierarchy('subtypes')<cr>", opts)
        vim.keymap.set("n", "<leader>ltp", "<cmd>lua vim.lsp.buf.typehierarchy('supertypes')<cr>", opts)
        vim.keymap.set("n", "<leader>lS", "<cmd>lua require('jdtls').super_implementation()<cr>", opts)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method("textDocument/codeAction") then
            vim.keymap.set("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
            vim.keymap.set("v", "<leader>la", "<cmd>lua vim.lsp.buf.range_code_action()<cr>", opts)
        end
        if client:supports_method("textDocument/definition") then
            vim.keymap.set("n", "<leader>ld", "<cmd>lua vim.lsp.buf.definition({reuse_win=false})<cr>z<cr>", opts)
        end
        if client:supports_method("textDocument/declaration") then
            vim.keymap.set("n", "<leader>lc", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
        end
        if client:supports_method("textDocument/documentSymbol") then
            vim.keymap.set("n", "<leader>ly",
                "<cmd>lua vim.lsp.buf.document_symbol()<cr><cmd>copen<cr><cmd>wincmd J<cr>",
                opts)
        end
        if client:supports_method("textDocument/formatting") then
            vim.keymap.set("n", "<leader>lf", "<cmd>lua vim.g.FormatCode()<cr>", opts)
            vim.keymap.set("n", "<leader>lF", "<cmd>lua vim.lsp.buf.format({timeout_ms = 20000})<cr>", opts)
        end
        if client:supports_method("textDocument/hover") then
            vim.keymap.set("n", "<leader>lh", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
        end
        if client:supports_method("textDocument/implementation") then
            vim.keymap.set("n", "<leader>li", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
        end
        if client:supports_method("textDocument/publishDiagnostics") then
            vim.keymap.set("n", "<leader>lj",
                "<cmd>lua vim.diagnostic.goto_next{wrap=false,popup_opts={border='single'}}<cr>", opts)
            vim.keymap.set("n", "<leader>lk",
                "<cmd>lua vim.diagnostic.goto_prev{wrap=false,popup_opts={border='single'}}<cr>", opts)
            vim.keymap.set("n", "<leader>lp",
                "<cmd>lua vim.diagnostic.open_float(nil, {scope = 'line', focus = true, focusable = true, focus_id = '1'})<cr>",
                opts)
            vim.keymap.set("n", "<leader>lo", "<cmd>lopen<cr><cmd>wincmd k<cr>", opts)
            vim.keymap.set("n", "<leader>lc", "<cmd>lclose<cr>", opts)
            vim.keymap.set("n", "<leader>WS",
                "<cmd>lua vim.diagnostic.setqflist({buffer = false})<cr><cr><cmd>foldopen!<cr>", opts)
        end
        if client:supports_method("textDocument/references") then
            vim.keymap.set("n", "<leader>lr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
        end
        if client:supports_method("textDocument/rename") then
            vim.keymap.set("n", "<leader>ln", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
        end
        if client:supports_method("textDocument/typeDefinition") then
            vim.keymap.set("n", "<leader>ltd", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
        end
        if client:supports_method("workspace/symbol") then
            vim.keymap.set("n", "<leader>lY", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", opts)
        end
        vim.cmd.normal("zx")
    end
})
local sev_name = {
    E = 'E', -- Error
    W = 'W', -- Warning
    I = 'I', -- Information
    H = 'H', -- Hint
}

-- 2. the quick-fix formatting function ----------------------------
--    (must be global so that the location list can see it)
function _G.DiagnosticLoclistText(info)
    local items = vim.fn.getloclist(info.winid,
        { id = info.id, items = 0 }).items

    local out = {}
    for i = info.start_idx, info.end_idx do
        local it      = items[i]
        local udat    = it.user_data or {}
        out[#out + 1] = string.format(
            '%-7s │ %-10s │ %4d │ %s',
            sev_name[it.type] or '',
            udat.source or '',
            it.lnum,
            -- it.col,
            -- vim.fn.fnamemodify(vim.api.nvim_buf_get_name(it.bufnr), ':~:.'),
            it.text:gsub('[\n\r]', ' ')
        )
    end
    return out
end

-- 3. function that rebuilds the list -------------------------------
local function update_loclist(bufnr)
    local diags = vim.diagnostic.get(bufnr)
    if vim.tbl_isempty(diags) then
        vim.fn.setloclist(0, {}, "r", { title = "Diagnostics", items = {} }) -- clear the location list
        return
    end                                                                      -- nothing to show

    local items = {}
    for _, d in ipairs(diags) do
        items[#items + 1] = {
            bufnr     = bufnr,
            lnum      = d.lnum + 1,
            col       = d.col + 1,
            text      = d.message,
            type      = ("EWHI"):sub(d.severity, d.severity), -- single-letter code
            user_data = {                                     -- <-- extra information lives here
                severity = d.severity,
                source   = d.source or '',
            },
        }
    end

    -- Replace (r) the location list of the current window and attach
    -- the custom text function defined above.
    vim.fn.setloclist(0, {}, "r", {
        title            = "Diagnostics",
        items            = items,
        quickfixtextfunc = "v:lua.DiagnosticLoclistText",
    })

    -- Open the list only once – if it is already open getloclist()
    -- returns its window id instead of 0.
    -- if vim.fn.getloclist(0, { winid = 0 }).winid == 0 then
    --     vim.cmd.lopen()
    -- end
end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = vim.g.augroup_jar,
    callback = function(ev)
        -- ev.buf == buffer whose diagnostics changed
        update_loclist(ev.buf)
    end,
})
