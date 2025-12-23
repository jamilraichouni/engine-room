-- https://github.com/andythigpen/nvim-coverage
return {
    {
        "andythigpen/nvim-coverage",
        version = "*",
        cmd = { "CoverageLoad", "CoverageSummary", "CoverageToggle" },
        config = function()
            require("coverage").setup({
                auto_reload = true,
                commands = true,
                highlights = {
                    covered = { fg = "#00ff00" }, -- supports style, fg, bg, sp (see :h highlight-gui)
                    uncovered = { fg = "#F07178" },
                },
                signs = {
                    covered = { hl = "CoverageCovered", text = "▎" },
                    uncovered = { hl = "CoverageUncovered", text = "▎" },
                },
                -- summary = {
                --     -- customize the summary pop-up
                --     min_coverage = 80.0, -- minimum coverage threshold (used for highlighting)
                -- },
                -- lang = {
                --     python = {
                --     }
                -- },
            })
        end,
        dependencies = {
            -- https://github.com/nvim-lua/plenary.nvim
            "nvim-lua/plenary.nvim"
        },
        ft = { "python" },
        keys = {
            { "<leader>cl", "<cmd>CoverageLoad<cr>",    silent = true },
            { "<leader>cs", "<cmd>CoverageSummary<cr>", silent = true },
            { "<leader>ct", "<cmd>CoverageToggle<cr>",  silent = true },
        },
    },
}

