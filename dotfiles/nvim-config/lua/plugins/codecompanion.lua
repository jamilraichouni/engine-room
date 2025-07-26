return {
    -- https://github.com/olimorris/codecompanion.nvim
    {
        "olimorris/codecompanion.nvim",
        enabled = false,
        cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
        dependencies = {
            { "nvim-lua/plenary.nvim", branch = "master" },
            "nvim-treesitter/nvim-treesitter",
        },
        config = function(_, opts)
            require("codecompanion").setup(
                {
                    adapters = {
                        anthropic = function()
                            return require("codecompanion.adapters").extend("anthropic", {
                                env = {
                                    api_key = ""
                                },
                            })
                        end,
                    },
                    strategies = {
                        chat = {
                            adapter = "anthropic",
                        },
                        inline = {
                            adapter = "anthropic",
                        },
                        cmd = {
                            adapter = "anthropic",
                        }
                    },
                }
            )
        end,
    },
}
