vim.diagnostic.config({
    signs = true,
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
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl })
end
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

