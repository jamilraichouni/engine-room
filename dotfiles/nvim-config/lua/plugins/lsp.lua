return {
    -- https://github.com/williamboman/mason.nvim {{{
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup({
                log_level = vim.log.levels.INFO
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
                "hrsh7th/cmp-nvim-lsp",                    -- source
                dependencies = { "neovim/nvim-lspconfig" } -- provider
            },
            {
                -- https://github.com/hrsh7th/cmp-nvim-lsp-signature-help
                "hrsh7th/cmp-nvim-lsp-signature-help",     -- source
                dependencies = { "neovim/nvim-lspconfig" } -- provider
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
    -- https://github.com/neovim/nvim-lspconfig {{{
    {
        "neovim/nvim-lspconfig",
        cmd = { "LspInfo", "LspInstall", "LspStart" },
        event = { "BufReadPre", "BufReadPost", "BufNewFile" },
        dependencies = {
            { "hrsh7th/cmp-nvim-lsp" },
            { "williamboman/mason.nvim" },
            -- https://github.com/williamboman/mason-lspconfig.nvim
            {
                "williamboman/mason-lspconfig.nvim",
                cmd = { "Mason" },
                opts = {
                    ensure_installed = {
                        "angularls",
                        "bashls",
                        "cssls",
                        "diagnosticls",
                        "docker_compose_language_service",
                        "dockerls",
                        "efm",
                        "html",
                        "jdtls",
                        "jinja_lsp",
                        "jsonls",
                        "lua_ls",
                        "ruff",
                        "sqlls",
                        "taplo",
                        "tailwindcss",
                        "ts_ls",
                        "ty",
                        "yamlls",
                    },
                }
            },
            {
                -- https://github.com/mfussenegger/nvim-jdtls
                "mfussenegger/nvim-jdtls",
                -- https://github.com/mfussenegger/nvim-dap
                dependencies = "mfussenegger/nvim-dap",
                ft = "java",
                keys = {
                    { "<leader>jb", "<cmd>lua require('jdtls').build_projects({select_mode='all', full_build=false})<cr>", silent = true },
                    { "<leader>jc", "<cmd>lua vim.g.CompileJavaProject()<cr>",                                             silent = true },
                    { "<leader>jC", "<cmd>lua vim.g.CompilePackageAndDeployCapellaAddon()<cr>",                            silent = true },
                    { "<leader>jh", "<cmd>JdtUpdateHotcode<cr>",                                                           silent = true },
                    { "<leader>jo", "<cmd>lua require('jdtls').organize_imports()<cr>",                                    silent = true },
                    { "<leader>jp", "<cmd>lua vim.g.JavaBuildClassPath()<cr>",                                             silent = true },
                },
            },
        },
        config = function()
            vim.diagnostic.config({
                signs = true,
                underline = true,
                update_in_insert = true,
                float = {
                    focusable = true,
                    focus = true,
                    severity_sort = true,
                    source = "always"
                },
                severity_sort = true,
                source = true,
                virtual_text = false
                -- virtual_text = {
                --     source = "always", -- Or "if_many"
                -- },
            })
            local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl })
            end

            vim.lsp.config.bashls = {
                filetypes = { "sh", "zsh" },
            }

            vim.lsp.config.cssls = {
                init_options = {
                    -- we format using prettier
                    provideFormatter = false,
                },
                settings = {
                    css = {
                        lint = {
                            unknownAtRules = "ignore",
                        },
                        validate = true,
                    },
                }
            }

            vim.lsp.config.diagnosticls = {
                cmd = { "diagnostic-languageserver", "--stdio" },
                root_markers = { '.git' },
                filetypes = {
                    "markdown",
                },
                init_options = {
                    linters = {
                        markdownlint = {
                            command = 'markdownlint',
                            rootPatterns = { '.git' },
                            isStderr = true,
                            debounce = 100,
                            args = { '--stdin' },
                            offsetLine = 0,
                            offsetColumn = 0,
                            sourceName = 'markdownlint',
                            securities = {
                                undefined = 'hint'
                            },
                            formatLines = 1,
                            formatPattern = {
                                '^.*:(\\d+)\\s+(.*)$',
                                {
                                    line = 1,
                                    column = -1,
                                    message = 2,
                                }
                            }
                        }
                    },
                    filetypes = {
                        markdown = { "markdownlint" }
                    },
                }
            }

            local prettier_jinja_cfg = {
                {
                    formatCommand =
                    'prettier --parser jinja-template --tab-width 4 --print-width 79 --single-attribute-per-line --plugin "$NVM_BIN/../lib/node_modules/prettier-plugin-tailwindcss/dist/index.mjs" --plugin "$NVM_BIN/../lib/node_modules/prettier-plugin-jinja-template/lib/index.js"',
                    formatStdin = true
                },
            }
            vim.lsp.config.efm = {
                init_options = { documentFormatting = true },
                settings = {
                    rootMarkers = { ".git/" },
                    languages = {
                        css = {
                            {
                                formatCommand = "prettier --parser css",
                                formatStdin = true
                            }
                        },
                        javascript = {
                            {
                                formatCommand = "prettier --parser babel --tab-width 2",
                                formatStdin = true
                            }
                        },
                        json = {
                            {
                                formatCommand = "prettier --parser json --tab-width 2 --print-width 79",
                                formatStdin = true
                            }
                        },
                        html = {
                            {
                                formatCommand =
                                'prettier --parser html --tab-width 4 --print-width 79 --single-attribute-per-line --plugin "$NVM_BIN/../lib/node_modules/prettier-plugin-tailwindcss/dist/index.mjs"',
                                formatStdin = true
                            }
                        },
                        ["jinja.html"] = prettier_jinja_cfg,
                        j2 = prettier_jinja_cfg,
                        jinja = prettier_jinja_cfg,
                        -- sh = {
                        --     {
                        --         formatCommand =
                        --         'prettier --parser sh --tab-width 2 --print-width 79 --plugin "$NVM_BIN/../lib/node_modules/prettier-plugin-sh/lib/index.js"',
                        --         formatStdin = true
                        --     }
                        -- },
                        -- markdown parser depends on npm pkg `remark-parse`
                        -- https://github.com/remarkjs/remark/tree/main/packages/remark-parse
                        markdown = {
                            {
                                formatCommand =
                                "prettier --parser markdown --tab-width 2 --print-width 79 --prose-wrap always",
                                formatStdin = true
                            }
                        },
                        xml = {
                            {
                                formatCommand =
                                'prettier --parser xml --tab-width 4 --print-width 79 --plugin "$NVM_BIN/../lib/node_modules/@prettier/plugin-xml/src/plugin.js"',
                                formatStdin = true
                            }
                        },
                        -- zsh = {
                        --     {
                        --         formatCommand =
                        --         'prettier --parser sh --tab-width 2 --print-width 79 --plugin "$NVM_BIN/../lib/node_modules/prettier-plugin-sh/lib/index.js"',
                        --         formatStdin = true
                        --     }
                        -- },
                    }
                }
            }
            vim.filetype.add {
                extension = {
                    ["jinja.html"] = "jinja",
                    j2 = "jinja",
                    jinja = "jinja",
                    jinja2 = "jinja",
                },
            }

            vim.lsp.config.jsonls = {
                init_options = {
                    provideFormatter = false,
                },
            }

            vim.lsp.config.lua_ls = {
                filetypes = { "lua" },
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = {
                                "use", -- packer
                                "vim"  -- nvim lua development
                            },
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                            enable = false,
                        },
                        -- Add format settings to control indentation
                        format = {
                            enable = true,
                            defaultConfig = {
                                indent_style = "space", -- or "tab"
                                indent_size = "4",      -- or any other number of spaces
                            },
                        },
                    },
                },
            }
            vim.lsp.config.pylsp = {
                cmd = { "pylsp" },
                flags = {
                    debounce_text_changes = 500,
                },
                settings = {
                    pylsp = {
                        plugins = {
                            autopep8 = { enabled = false },
                            flake8 = { enabled = false },
                            jedi_completion = { enabled = true, fuzzy = true },
                            mccabe = { enabled = false },
                            -- https://pycodestyle.pycqa.org/en/latest/intro.html#error-codes
                            pycodestyle = {
                                enabled = false,
                                convention = "numpy",
                                -- select blank line error code category (E301-E306):
                                select = { "E3" }
                            },
                            pydocstyle = {
                                enabled = false,
                                convention = "numpy"
                            },
                            pyflakes = { enabled = false },
                            pylint = {
                                enabled = false,
                                executable = "pylint",
                                args = { "--load-plugins=pylint.extensions.mccabe", "--max-complexity=14" },
                            },                                                           -- https://github.com/PyCQA/pylint
                            -- pyls_black = { enabled = true, executable = "black" },
                            black = { enabled = false, line_length = 79, timeout = 10 }, -- https://github.com/python-lsp/python-lsp-black
                            isort = { enabled = false },
                            mypy = { enabled = true },                                   -- https://github.com/python/mypy, https://github.com/python-lsp/pylsp-mypy
                            yapf = { enabled = false },
                        },
                    },
                },
            }
            vim.lsp.config.ruff = {
                init_options = {
                    settings = {
                        lineLength = 79,
                        showSyntaxErrors = true
                    }
                }
            }
            vim.lsp.config.tailwindcss = {
                filetypes = {
                    "css",
                    "django-html",
                    "gohtml",
                    "gohtmltmpl",
                    "html",
                    "htmlangular",
                    "htmldjango",
                    "javascript",
                    "javascriptreact",
                    "jinja",
                    "less",
                    "php",
                    "postcss",
                    "sass",
                    "scss",
                    "svelte",
                    "templ",
                    "typescript",
                    "typescriptreact",
                    "vue",
                }
            }

            vim.lsp.config.ty = {
                init_options = {
                    -- https://github.com/astral-sh/ty/blob/main/docs/reference/editor-settings.md
                    settings = {
                        python = {
                            ty = {
                                disableLanguageServices = true
                            }
                        }
                    }
                }
            }
            vim.lsp.config.yamlls = {
                settings = {
                    completion = {
                        enable = true,
                    },
                    format = {
                        enable = true,
                    },
                    hover = {
                        enable = true,
                    },
                    schemaStore = {
                        enable = true,
                    },
                    validate = {
                        enable = true,
                    },
                    yaml = {
                        schemas = {
                            [os.getenv("HOME") .. "/dev/dbgitlab/mddocgen/builddesc_schema.json"] = "/builddesc*.yml",
                            ["/mnt/volume/data/dotfiles/openapi_schema.yaml"] = "**/openapi/*.yaml"
                        },
                    },
                    schemaDownload = { enable = true },
                    -- trace = { server = "verbose" },
                }
            }

            vim.lsp.enable({
                "angularls",
                -- https://github.com/bash-lsp/bash-language-server
                "bashls",
                -- https://code.visualstudio.com/docs/languages/css
                "cssls",
                -- https://github.com/iamcco/diagnostic-languageserver
                "diagnosticls",
                -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
                "dockerls",
                -- https://github.com/mattn/efm-langserver
                "efm",
                "gh_actions_ls",
                "jinja_lsp",
                "jsonls",
                -- https://github.com/LuaLS/lua-language-server
                -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
                "lua_ls",
                "pylsp",
                "ruff",
                "tailwindcss",
                -- https://taplo.tamasfe.dev/cli/usage/language-server.html
                -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#taplo
                "taplo",
                "ty",
                -- https://github.com/redhat-developer/yaml-language-server
                "yamlls",
            })
            vim.lsp.set_log_level("warn") -- error, warn, info, or debug
        end
    }
    -- }}}
}
