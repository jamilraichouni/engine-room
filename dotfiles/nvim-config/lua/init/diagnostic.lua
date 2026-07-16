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
vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    config = vim.tbl_deep_extend("force", config or {}, { border = "rounded" })
    return vim.lsp.handlers.hover(err, result, ctx, config)
end

vim.lsp.handlers["textDocument/signatureHelp"] =
    function(err, result, ctx, config)
        config = vim.tbl_deep_extend(
            "force",
            config or {},
            { border = "rounded" }
        )
        return vim.lsp.handlers.signature_help(err, result, ctx, config)
    end
