return {
    {
        -- https://github.com/nvim-treesitter/nvim-treesitter
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            require "nvim-treesitter".setup {
                auto_install = true,
                highlight = {
                    enable = true,
                    disable = function(lang, buf)
                        if lang == "csv" or -- because of https://github.com/mechatroner/rainbow_csv
                            lang == "jinja" or lang == "json" or lang == "json5" then
                            return true
                        end
                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                },
                indent = { enable = true },
            }
            require "nvim-treesitter".install {
                "angular",
                "bash",
                "cmake",
                "comment",
                "cpp",
                "css",
                "csv",
                "diff",
                "dockerfile",
                "git_rebase",
                "gitcommit",
                "helm",
                "html",
                "htmldjango",
                "java",
                "javascript",
                "json",
                "json5",
                "lua",
                "make",
                "markdown",
                "markdown_inline",
                "matlab",
                "mermaid",
                "ninja",
                "pem",
                "perl",
                "php",
                "php_only",
                "phpdoc",
                "powershell",
                "printf",
                "properties",
                "proto",
                "pymanifest",
                "python",
                "rst",
                "scala",
                "scss",
                "toml",
                "typescript",
                "vim",
                "vimdoc",
                "xml",
                "yaml",
                "zsh",
            }
        end
    },
}

