return {
    -- https://github.com/VonHeikemen/lsp-zero.nvim {{{
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v4.x",
        lazy = true,
        config = false,
    },
    -- }}}
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
    -- https://github.com/zbirenbaum/copilot.lua {{{
    {
        "zbirenbaum/copilot.lua",
        -- cond = function() return vim.env.NVIM == nil and vim.fn.executable("node") == 1 end,
        cmd = { "Copilot" },
        event = "InsertEnter",
        opts = {
            filetypes = {
                -- gitcommit = true,
                -- markdown = true,
                -- python = true,
                -- yaml = true,
                ["*"] = true
            },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                hide_during_completion = true,
                debounce = 75,
                keymap = {
                    accept = "<c-a>",
                    accept_word = "<c-w>",
                    accept_line = "<c-l>",
                    next = "<c-j>",
                    prev = "<c-k>",
                    -- dismiss = "<C-]>",
                },
            },
        },
        -- config = function()
        --     require("copilot").setup(opts)
        -- end,
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

            cmp.setup({
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
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                }),
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
            })
            require("config.nvim-cmp")
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
            { "williamboman/mason-lspconfig.nvim" },
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
            local lsp_zero = require("lsp-zero")

            -- lsp_attach is where you enable features that only work
            -- if there is a language server active in the file
            local lsp_attach = function(_, bufnr)
                local opts = { buffer = bufnr }
                vim.keymap.set("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
                vim.keymap.set("v", "<leader>la", "<cmd>lua vim.lsp.buf.range_code_action()<cr>", opts)
                vim.keymap.set("n", "<leader>lc", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
                vim.keymap.set("n", "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<cr>z<cr>", opts)
                -- vim.keymap.set("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format({timeout_ms = 5000})<cr><cmd>Prettier<cr>", opts)
                vim.keymap.set("n", "<leader>lf", "<cmd>lua vim.g.FormatCode()<cr>", opts)
                vim.keymap.set("n", "<leader>lF", "<cmd>lua vim.lsp.buf.format({timeout_ms = 10000})<cr>", opts)
                vim.keymap.set("n", "<leader>lh", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
                vim.keymap.set("n", "<leader>li", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
                vim.keymap.set("n", "<leader>lj",
                    "<cmd>lua vim.diagnostic.goto_next{wrap=false,popup_opts={border='single'}}<cr>", opts)
                vim.keymap.set("n", "<leader>lk",
                    "<cmd>lua vim.diagnostic.goto_prev{wrap=false,popup_opts={border='single'}}<cr>", opts)
                vim.keymap.set("n", "<leader>ln", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
                vim.keymap.set("n", "<leader>lsd",
                    "<cmd>lua vim.lsp.buf.document_symbol()<cr><cmd>copen<cr><cmd>wincmd J<cr>",
                    opts)
                vim.keymap.set("n", "<leader>lsw", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", opts)
                vim.keymap.set("n", "<leader>ltd", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
                vim.keymap.set("n", "<leader>ltb", "<cmd>lua vim.lsp.buf.typehierarchy('subtypes')<cr>", opts)
                vim.keymap.set("n", "<leader>ltp", "<cmd>lua vim.lsp.buf.typehierarchy('supertypes')<cr>", opts)
                vim.keymap.set("n", "<leader>lS", "<cmd>lua require('jdtls').super_implementation()<cr>", opts)
                vim.keymap.set("n", "<leader>lp",
                    "<cmd>lua vim.diagnostic.open_float(nil, {scope = 'line', focus = true, focusable = true, focus_id = '1'})<cr>",
                    opts)
                vim.keymap.set("n", "<leader>lP",
                    "<cmd>lua vim.diagnostic.open_float(nil, {scope = 'buffer', focus = true, focusable = true})<cr>",
                    opts)
                vim.keymap.set("n", "<leader>lr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
                vim.keymap.set("n", "<leader>dd",
                    "<cmd>lua vim.diagnostic.setqflist({open = true})<cr><cr><cmd>foldopen!<cr>", opts)
                vim.keymap.set("n", "<leader>gg",
                    "<cmd>lua vim.diagnostic.setqflist({buffer = false})<cr><cr><cmd>foldopen!<cr>", opts)
            end

            lsp_zero.extend_lspconfig({
                sign_text = true,
                lsp_attach = lsp_attach,
                capabilities = require("cmp_nvim_lsp").default_capabilities()
            })

            require("mason-lspconfig").setup({
                automatic_installation = false,
                ensure_installed = {
                    "angularls",
                    "bashls",
                    "cssls",
                    "diagnosticls",
                    "docker_compose_language_service",
                    "dockerls",
                    "efm",
                    "html",
                    "htmx",
                    "jdtls",
                    "jinja_lsp",
                    "jsonls",
                    "lua_ls",
                    "ruff",
                    "sqlls",
                    "tailwindcss",
                    "taplo",
                    "ts_ls",
                    "yamlls",
                },
                handlers = {
                    -- this first function is the "default handler"
                    -- it applies to every language server without a "custom handler"
                    function(server_name)
                        -- we setup jdtls in ftplugin/java.lua.
                        -- hence, setup only when server_name is not "jdtls"
                        if server_name == "jdtls" then
                            return
                        end
                        require("lspconfig")[server_name].setup({})
                    end,
                }
            })
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
            local lspconfig = require "lspconfig"
            lspconfig.angularls.setup({})

            -- https://github.com/bash-lsp/bash-language-server
            lspconfig.bashls.setup({
                filetypes = { "sh", "zsh" }
            })

            -- https://github.com/iamcco/diagnostic-languageserver
            lspconfig.diagnosticls.setup({
                -- command = { "diagnostic-languageserver", "--stdio", "--log-level", "3" },
                filetypes = {
                    -- "html",
                    -- "jinja.html",
                    "markdown",
                },
                init_options = {
                    linters = {
                        markdownlint = {
                            -- https://github.com/igorshubovych/markdownlint-cli
                            command = "markdownlint",
                            sourceName = "markdownlint",
                            args = { "--stdin", "--disable MD013 MD034", "-" },
                            isStdout = false,
                            isStderr = true,
                            -- parseJson = {
                            --     -- to see some example:
                            --     -- cat /path/to/file | flake8 --format=json -
                            --     errorsRoot = "",
                            --     sourceName = "markdownlint",
                            --     line = "kineNumber",
                            --     column = "errorRange[0]",
                            --     security = "ruleNames[0]",
                            --     message = "[flake8] ${text} [${code}]",
                            -- },
                            formatLines = 1,
                            formatPattern = {
                                "^stdin:(\\d+):?(\\d+)? (\\w+)/([\\w\\-\\/]+) (.+)$",
                                {
                                    line = 1,
                                    column = 2,
                                    message = { "[", 3, "] ", 5 },
                                    security = 3
                                }
                            },
                        },
                    },
                    -- formatters = {
                    --     djlint = {
                    --         command = "strace",
                    --         args = { "-o", "/tmp/strace", "-e trace=djlint --profile=jinja --reformat %file" },
                    --         isStdout = true,
                    --         isStderr = false,
                    --         rootPatterns = { "pyproject.toml" },
                    --         ignore = { ".git" },
                    --         ignoreExitCode = false
                    --     },
                    -- },
                    filetypes = {
                        -- filetype to linter(s) mapping:
                        markdown = { "markdownlint" }
                    },
                    -- formatFiletypes = {
                    --     -- filetype to formatter(s) mapping:
                    --     ["html"] = { "djlint" },
                    --     ["jinja.html"] = { "djlint" }
                    -- }
                }
            })

            -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
            lspconfig.dockerls.setup({})

            -- https://github.com/mattn/efm-langserver
            lspconfig.efm.setup {
                init_options = { documentFormatting = true },
                settings = {
                    rootMarkers = { ".git/" },
                    languages = {
                        css = {
                            {
                                formatCommand = "prettier --parser css --tab-width 4 --print-width 79",
                                formatStdin = true
                            }
                        },
                        javascript = {
                            {
                                formatCommand = "prettier --parser babel --tab-width 4 --print-width 79",
                                formatStdin = true
                            }
                        },
                        json = {
                            {
                                formatCommand = "prettier --parser json --tab-width 4 --print-width 79",
                                formatStdin = true
                            }
                        },
                        -- html = {
                        --     {
                        --         formatCommand =
                        --         'prettier --parser html --tab-width 4 --print-width 79 --single-attribute-per-line --plugin "$NPM_DIR/lib/node_modules/prettier-plugin-tailwindcss/dist/index.mjs"',
                        --         formatStdin = true
                        --     }
                        -- },
                        ["jinja.html"] = {
                            {
                                formatCommand =
                                'prettier --parser jinja-template --tab-width 4 --print-width 79 --single-attribute-per-line --plugin "$NPM_DIR/lib/node_modules/prettier-plugin-tailwindcss/dist/index.mjs" --plugin "$NPM_DIR/lib/node_modules/prettier-plugin-jinja-template/lib/index.js"',
                                formatStdin = true
                            },
                        },
                        -- sh = {
                        --     {
                        --         formatCommand =
                        --         'prettier --parser sh --tab-width 2 --print-width 79 --plugin "$NPM_DIR/lib/node_modules/prettier-plugin-sh/lib/index.js"',
                        --         formatStdin = true
                        --     }
                        -- },
                        xml = {
                            {
                                formatCommand =
                                'prettier --parser xml --tab-width 4 --print-width 79 --plugin "$NPM_DIR/lib/node_modules/@prettier/plugin-xml/src/plugin.js"',
                                formatStdin = true
                            }
                        },
                        -- zsh = {
                        --     {
                        --         formatCommand =
                        --         'prettier --parser sh --tab-width 2 --print-width 79 --plugin "$NPM_DIR/lib/node_modules/prettier-plugin-sh/lib/index.js"',
                        --         formatStdin = true
                        --     }
                        -- },
                    }
                }
            }

            -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/html.lua
            lspconfig.html.setup({
                cmd = { "vscode-html-language-server", "--stdio" },
                filetypes = {
                    -- "html",
                    "xhtml"
                },
                init_options = {
                    configurationSection = {
                        "css",
                        "html",
                        "javascript"
                    },
                    embeddedLanguages = { css = true, javascript = true },
                    settings = {
                        css = {
                            validate = true,
                        },
                        html = {
                            format = {
                                tabSize = 4,
                                insertSpaces = true,
                                enable = false,
                                preserveNewLines = true,
                                indentInnerHtml = true,
                                indentScripts = "keep",
                                wrapAttributes = "preserve-aligned",
                                wrapLineLength = 80,
                            },
                            autoClosingTags = true,
                            tagClosing = true,
                        },
                        javascript = {
                            validate = true,
                        },
                    },
                },
            })

            lspconfig.jinja_lsp.setup({})

            -- https://github.com/LuaLS/lua-language-server
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
            lspconfig.lua_ls.setup({
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
            })
            lspconfig.pylsp.setup {
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
            require('lspconfig').ruff.setup({
                init_options = {
                    settings = {
                        lineLength = 79,
                        showSyntaxErrors = true
                    }
                }
            })

            -- https://taplo.tamasfe.dev/cli/usage/language-server.html
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#taplo
            lspconfig.taplo.setup({})

            -- https://github.com/redhat-developer/yaml-language-server
            local home = os.getenv("HOME")
            lspconfig.yamlls.setup({
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
                            [home .. "/dev/dbgitlab/mddocgen/builddesc_schema.json"] = "/builddesc*.yml",
                            ["/mnt/volume/data/dotfiles/openapi_schema.yaml"] = "**/openapi/*.yaml"
                        },
                    },
                    schemaDownload = { enable = true },
                    -- trace = { server = "verbose" },
                }
            })
            vim.lsp.set_log_level("warn") -- error, warn, info, or debug
        end
    }
    -- }}}
}
