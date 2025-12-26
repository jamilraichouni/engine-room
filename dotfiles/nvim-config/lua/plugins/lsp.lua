return {
    -- https://github.com/williamboman/mason.nvim {{{
    {
        "williamboman/mason.nvim",
        lazy = true,
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonInstallAll",
            "MasonUpdate",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonLog",
        },
        config = function()
            require("mason").setup({
                log_level = vim.log.levels.WARN, -- TRACE, DEBUG, INFO, WARN, ERROR, OFF
            })
        end
    },
    -- }}}
    -- https://github.com/hrsh7th/nvim-cmp {{{
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            -- SOURCES/ PROVIDERS
            -- (sources are the bridge between provider and nvim-cmp):
            {
                -- https://github.com/hrsh7th/cmp-buffer
                "hrsh7th/cmp-buffer",
            },
            {
                -- https://github.com/hrsh7th/cmp-nvim-lsp
                "hrsh7th/cmp-nvim-lsp", -- source
            },
            {
                -- https://github.com/hrsh7th/cmp-nvim-lsp-signature-help
                "hrsh7th/cmp-nvim-lsp-signature-help", -- source
            },
            {
                -- https://github.com/hrsh7th/cmp-path
                "hrsh7th/cmp-path", -- source
            },
            {
                -- https://github.com/hrsh7th/cmp-vsnip
                "hrsh7th/cmp-vsnip", -- source
            },
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
                -- https://github.com/tamago324/cmp-zsh
                "tamago324/cmp-zsh", -- source
            }
        },
        config = function()
            local cmp = require("cmp")
            local cmp_kinds = {
                Class = "  ",
                Color = "  ",
                Constant = "  ",
                Constructor = "  ",
                Enum = "  ",
                EnumMember = "  ",
                Event = "  ",
                Field = "  ",
                File = "  ",
                Folder = "  ",
                Function = "  ",
                Interface = "  ",
                Keyword = "  ",
                Method = "  ",
                Module = "  ",
                Operator = "  ",
                Property = "  ",
                Reference = "  ",
                Snippet = "  ",
                Struct = "  ",
                Text = "  ",
                TypeParameter = "  ",
                Unit = "  ",
                Value = "  ",
                Variable = "  ",
            }
            local feedkey = function(key, mode)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
            end
            cmp.setup({
                formatting = {
                    -- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#how-to-add-visual-studio-code-codicons-to-the-menu
                    format = function(_, vim_item)
                        vim_item.kind = (cmp_kinds[vim_item.kind] or "") .. vim_item.kind
                        return vim_item
                    end,
                },
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end
                },
                -- snippet = {
                --     expand = function(args)
                --         vim.snippet.expand(args.body)
                --     end,
                -- },
                sources = {
                    {
                        name = "buffer",
                        option = {
                            keyword_pattern = [[\K\k*]],
                        },
                    },
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_document_symbol" },
                    { name = "nvim_lsp_signature_help" },
                    {
                        name = "path",
                        option = {
                            trailing_slash = true
                        }
                    },
                    { name = "vsnip" },
                    { name = "zsh" }

                },
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if vim.fn["vsnip#available"](1) == 1 then
                            feedkey("<Plug>(vsnip-expand-or-jump)", "")
                        else
                            fallback() -- The fallback function sends an already mapped key. In this case, it's probably `<Tab>`.
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if vim.fn["vsnip#jumpable"](-1) == 1 then
                            feedkey("<Plug>(vsnip-jump-prev)", "")
                        else
                            fallback() -- The fallback function sends an already mapped key. In this case, it's probably `<Tab>`.
                        end
                    end, { "i", "s" }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
            })
        end
    },
    -- }}}
}

