vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ", -- 
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "⚑ ", -- 
            [vim.diagnostic.severity.INFO] = " ",
        }
    },
    underline = true,
    update_in_insert = true,
    float = {
        focusable = true,
        focus = true,
        severity_sort = true,
        source = "always",
        border = "rounded"
    },
    severity_sort = true,
    source = true,
    virtual_text = false
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = "rounded",
    }
)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = "rounded",
    }
)

