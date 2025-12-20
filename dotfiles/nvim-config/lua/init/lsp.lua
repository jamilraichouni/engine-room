vim.lsp.config("bashls", {
    cmd = { "bash-language-server", "start" },
    settings = {
        bashIde = {
            globPattern = vim.env.GLOB_PATTERN or "*@(.bash|.command|.inc|.sh|.zsh)",
        },
    },
    root_markers = { ".git", "pyproject.toml" },
    filetypes = { "bash", "sh", "zsh" },
})
vim.lsp.config("cssls", {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    init_options = { provideFormatter = false },
    settings = {
        css = {
            lint = {
                unknownAtRules = "ignore",
            },
            validate = true
        },
        scss = { validate = true },
        less = { validate = true },
    },
    root_markers = { ".git", "pyproject.toml" },
})
vim.lsp.config("diagnosticls", {
    cmd = { "diagnostic-languageserver", "--stdio" },
    root_markers = { ".git", "pyproject.toml" },
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
                args = {
                    '--stdin',
                    '--disable',
                    'MD013', -- line length
                },
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
})
vim.lsp.config("jsonls", {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { '.git' },
    init_options = {
        provideFormatter = false,
    },
})
vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".git" },
    settings = {
        Lua = {
            codeLens = { enable = true },
            diagnostics = {
                globals = {
                    "use", -- packer
                    "vim"  -- nvim lua development
                },
            },
            hint = { enable = true, semicolon = "Disable" },
            telemetry = {
                enable = false,
            },
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
vim.lsp.config("pylsp", {
    cmd = { "pylsp" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", ".git" },
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
})
vim.lsp.config("ruff", {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", ".git", "ruff.toml", ".ruff.toml" },
    init_options = {
        settings = {
            configurationPreference = "filesystemFirst",
            logLevel = "warn",
        }
    }
})
vim.lsp.config("tailwindcss", {
    cmd = { "tailwindcss-language-server", "--stdio" },
    root_markers = { ".git", "pyproject.toml" },
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
    },
    capabilities = {
        workspace = {
            didChangeWatchedFiles = {
                dynamicRegistration = true,
            },
        },
    },
    settings = {
        tailwindCSS = {
            validate = true,
            lint = {
                cssConflict = "warning",
                invalidApply = "error",
                invalidScreen = "error",
                invalidVariant = "error",
                invalidConfigPath = "error",
                invalidTailwindDirective = "error",
                recommendedVariantOrder = "warning",
            },
            classAttributes = {
                "class",
                "className",
                "class:list",
                "classList",
                "ngClass",
            },
            includeLanguages = {
                eelixir = "html-eex",
                elixir = "phoenix-heex",
                eruby = "erb",
                heex = "phoenix-heex",
                htmlangular = "html",
                templ = "html",
            },
        },
    },
})
vim.lsp.config("ty", {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", ".git", "ty.toml" },
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
})
vim.lsp.config("yamlls", {
    cmd = { "yaml-language-server", "--stdio" },
    root_markers = { "pyproject.toml", ".git" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
    on_init = function(client)
        client.server_capabilities.documentFormattingProvider = true
    end,
    settings = {
        completion = { enable = true },
        hover = { enable = true },
        redhat = { telemetry = { enabled = false } },
        schemaDownload = { enable = true },
        schemaStore = { enable = true },
        validate = { enable = true },
        yaml = {
            format = { enable = true },
            schemas = {
                [os.getenv("HOME") .. "/dev/dbgitlab/mddocgen/builddesc_schema.json"] = "/builddesc*.yml",
                ["/mnt/volume/data/dotfiles/openapi_schema.yaml"] = "**/openapi/*.yaml"
            },
        },
    }
})
-- :h lspconfig-all
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
    -- https://github.com/astral-sh/ty
    -- "ty",
    -- https://github.com/redhat-developer/yaml-language-server
    "yamlls",
})
vim.lsp.set_log_level("warn") -- error, warn, info, or debug

