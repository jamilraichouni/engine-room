vim.api.nvim_exec([[
    function! MarkdownPreviewDummyFunction(url)
    endfunction
]], false)
return {
    {
        -- https://github.com/iamcco/markdown-preview.nvim
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        config = function()
            vim.g.mkdp_auto_start = 1
            vim.g.mkdp_open_ip = "127.0.0.1"
            vim.g.mkdp_port = "5098"
            vim.g.mkdp_open_to_the_world = 1
            vim.g.mkdp_echo_preview_url = 1
            -- Next to avoid that the browser in the devcontainer will be started
            vim.g.mkdp_browserfunc = "MarkdownPreviewDummyFunction"
        end
    },
}
