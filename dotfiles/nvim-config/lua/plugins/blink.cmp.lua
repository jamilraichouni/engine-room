return {
    -- https://github.com/saghen/blink.cmp
    -- https://cmp.saghen.dev/
    {
        "saghen/blink.cmp",
        event = "VeryLazy",
        dependencies = {
            {
                -- https://github.com/hrsh7th/vim-vsnip
                "hrsh7th/vim-vsnip", -- provider
                cmd = {
                    "VsnipOpen",
                    "VsnipOpenEdit",
                    "VsnipOpenSplit",
                    "VsnipOpenVsplit",
                    "VsnipYank",
                },
                config = function()
                    vim.g.vsnip_snippet_dir = "~/.config/nvim/snippets"
                    vim.g.vsnip_filetypes = {}
                    vim.g.vsnip_filetypes.python = { "python", "rst" }
                end,
            },
            {
                -- https://github.com/mikavilpas/blink-ripgrep.nvim
                "mikavilpas/blink-ripgrep.nvim",
                version = "*",
            },
            {
                -- https://github.com/fang2hou/blink-copilot
                "fang2hou/blink-copilot"
            },
        },
        version = "*",
        opts = {
            appearance = {
                nerd_font_variant = "normal"
            },
            cmdline = {
                enabled = false,
                keymap = {
                    preset = "inherit",
                    ["<Tab>"] = { "show", "fallback" },
                },
                completion = { menu = { auto_show = false } },
            },
            completion = {
                documentation = { auto_show = true, window = { border = 'single' } },
                ghost_text = {
                    enabled = true,
                    -- Show the ghost text when an item has been selected
                    show_with_selection = true,
                },
                list = {
                    selection = {
                        preselect = true,
                        auto_insert = false,
                    }
                },
                menu = { border = "single" },
            },
            fuzzy = {
                implementation = "prefer_rust",
                sorts = {
                    "score",
                    "sort_text",
                    "label",
                },
                prebuilt_binaries = {
                    download = true,
                    ignore_version_mismatch = true,
                }
            },
            keymap = {
                preset = "default",
                ["<Enter>"] = { "accept", "fallback" },
            },
            signature = {
                enabled = true,
                window = {
                    border = "single",
                    show_documentation = true,
                }
            },
            sources = {
                default = {
                    "buffer",
                    "copilot",
                    "lsp",
                    "path",
                    "ripgrep",
                    "snippets",
                },
                providers = {
                    copilot = {
                        name = "copilot",
                        module = "blink-copilot",
                        score_offset = 100,
                        async = true,
                    },
                    ripgrep = {
                        module = "blink-ripgrep",
                        name = "Ripgrep",
                        opts = {
                            project_root_marker = { ".git", "pyproject.toml" },
                            backend = {
                                use = "gitgrep-or-ripgrep",
                                ripgrep = {
                                    ignore_paths = { ".git", ".venv", "node_modules" },
                                }
                            }
                        },
                    },
                },
            },
        },
        opts_extend = { "sources.default" }
    }
}

