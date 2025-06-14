local function get_venv(variable)
    local venv = os.getenv(variable)
    if venv ~= nil and string.find(venv, "/") then
        local orig_venv = venv
        for w in orig_venv:gmatch("([^/]+)") do
            venv = w
        end
        venv = string.format("%s", venv)
    end
    return venv
end
return {
    {
        -- https://github.com/nvim-lualine/lualine.nvim
        "nvim-lualine/lualine.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            local colors = {
                black     = '#000000',
                blue      = '#000EB0',
                cyan      = '#00C8FF',
                comment   = '#5d656f',
                darkgreen = '#1a3a1a',
                purple    = '#531B93',
                red       = '#b00001',
                white     = '#d4d4d4',
            }
            local theme = {
                normal = {
                    a = { bg = colors.blue, fg = colors.white, gui = 'bold,italic' },
                    b = { bg = colors.cyan, fg = colors.black },
                    c = { bg = colors.cyan, fg = colors.black },
                    x = { bg = colors.cyan, fg = colors.black },
                    y = { bg = colors.cyan, fg = colors.black },
                    z = { bg = colors.blue, fg = colors.white },
                },
                insert = {
                    a = { bg = colors.red, fg = colors.white, gui = 'bold,italic' },
                    b = { bg = colors.cyan, fg = colors.black },
                    c = { bg = colors.cyan, fg = colors.black },
                    x = { bg = colors.cyan, fg = colors.black },
                    y = { bg = colors.cyan, fg = colors.black },
                    z = { bg = colors.red, fg = colors.white },
                },
                terminal = {
                    a = { bg = colors.cyan, fg = colors.black, gui = 'bold,italic' },
                    b = { bg = colors.darkgreen, fg = colors.white },
                    c = { bg = colors.darkgreen, fg = colors.white },
                    x = { bg = colors.darkgreen, fg = colors.white },
                    y = { bg = colors.darkgreen, fg = colors.white },
                    z = { bg = colors.cyan, fg = colors.black },
                },
                visual = {
                    a = { bg = colors.purple, fg = colors.white, gui = 'bold,italic' },
                    b = { bg = colors.cyan, fg = colors.black },
                    c = { bg = colors.cyan, fg = colors.black },
                    x = { bg = colors.cyan, fg = colors.black },
                    y = { bg = colors.cyan, fg = colors.black },
                    z = { bg = colors.purple, fg = colors.white },
                },
                replace = {
                    a = { bg = colors.red, fg = colors.white, gui = 'bold,italic' },
                    b = { bg = colors.cyan, fg = colors.black },
                    c = { bg = colors.cyan, fg = colors.black },
                    x = { bg = colors.cyan, fg = colors.black },
                    y = { bg = colors.cyan, fg = colors.black },
                    z = { bg = colors.red, fg = colors.white },
                },
                command = {
                    a = { bg = colors.black, fg = colors.white, gui = 'bold,italic' },
                    b = { bg = colors.cyan, fg = colors.black },
                    c = { bg = colors.cyan, fg = colors.black },
                    x = { bg = colors.cyan, fg = colors.black },
                    y = { bg = colors.cyan, fg = colors.black },
                    z = { bg = colors.black, fg = colors.white },
                },
                inactive = {
                    a = { bg = colors.black, fg = colors.comment },
                    b = { bg = colors.black, fg = colors.comment },
                    c = { bg = colors.black, fg = colors.comment },
                    x = { bg = colors.black, fg = colors.comment },
                    y = { bg = colors.black, fg = colors.comment },
                    z = { bg = colors.black, fg = colors.comment },
                }
            }
            require("lualine").setup {
                options = {
                    icons_enabled = true,
                    theme = theme,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    ignore_focus = {},
                    always_divide_middle = true,
                    globalstatus = false,
                    refresh = {
                        statusline = 200,
                        tabline = 1000,
                        winbar = 1000,
                    }
                },
                sections = {
                    lualine_a = {
                        "mode",
                        {
                            "diagnostics",

                            -- Table of diagnostic sources, available sources are:
                            --   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
                            -- or a function that returns a table as such:
                            --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
                            sources = { "nvim_lsp" },

                            -- Displays diagnostics for the defined severity types
                            sections = { "error", "warn", "info", "hint" },

                            diagnostics_color = {
                                -- Same values as the general color option can be used here.
                                error = {
                                    guifg = "DiagnosticError", -- Changes diagnostics' error color.
                                },
                                warn  = {
                                    guifg = "DiagnosticWarn", -- Changes diagnostics' warn color.
                                },
                                info  = {
                                    guifg = "DiagnosticInfo", -- Changes diagnostics' info color.
                                },
                                hint  = {
                                    guifg = "DiagnosticHint", -- Changes diagnostics' hint color.
                                },
                            },
                            symbols = { error = " ", warn = " ", hint = " ", info = " " },
                            colored = true,          -- Displays diagnostics status in color if set to true.
                            update_in_insert = true, -- Update diagnostics in insert mode.
                            always_visible = false,  -- Show diagnostics even if there are none.
                        },
                    },
                    lualine_b = {
                        {
                            "filename",
                            file_status = true,     -- Displays file status (readonly status, modified status)
                            newfile_status = false, -- Display new file status (new file means no write after created)
                            path = 3,               -- 0: Just the filename
                            -- 1: Relative path
                            -- 2: Absolute path
                            -- 3: Absolute path, with tilde as the home directory
                            -- 4: Filename and parent dir, with tilde as the home directory

                            shorting_target = 40, -- Shortens path to leave 40 spaces in the window
                            -- for other components. (terrible name, any suggestions?)
                            symbols = {
                                modified = "", -- Text to show when the file is modified.
                                readonly = "", -- Text to show when the file is non-modifiable or readonly.
                                unnamed = "[No Name]", -- Text to show for unnamed buffers.
                                newfile = "[New]", -- Text to show for newly created file before first write
                            }
                        }
                    },
                    lualine_c = {
                        { "branch", icon = "", color = { fg = "#6f6f6f", gui = "bold" } },
                    },
                    lualine_x = { "copilot", "encoding", "fileformat", "filetype", "lsp_status" },
                    lualine_y = { "progress", {
                        function()
                            local venv = get_venv("CONDA_DEFAULT_ENV") or get_venv("VIRTUAL_ENV") or "-"
                            return " " .. venv
                        end,
                        -- cond = function() return vim.bo.filetype == "python" end,
                    } },
                    lualine_z = { "location",
                        {
                            "searchcount",
                            maxcount = 999,
                            timeout = 500,
                        }
                    }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        {
                            "filename",
                            file_status = true,     -- Displays file status (readonly status, modified status)
                            newfile_status = false, -- Display new file status (new file means no write after created)
                            path = 3,               -- 0: Just the filename
                            -- 1: Relative path
                            -- 2: Absolute path
                            -- 3: Absolute path, with tilde as the home directory
                            -- 4: Filename and parent dir, with tilde as the home directory

                            shorting_target = 40, -- Shortens path to leave 40 spaces in the window
                            -- for other components. (terrible name, any suggestions?)
                            symbols = {
                                modified = "", -- Text to show when the file is modified.
                                readonly = "", -- Text to show when the file is non-modifiable or readonly.
                                unnamed = "[No Name]", -- Text to show for unnamed buffers.
                                newfile = "[New]", -- Text to show for newly created file before first write
                            }
                        }
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {
                        {
                            "searchcount",
                            maxcount = 999,
                            timeout = 300,
                        }
                    }
                },
                tabline = {},
                winbar = {},
                inactive_winbar = {},
                extensions = { "fugitive", "lazy", "man", "mason", "oil", "quickfix" },
            }
        end,
    },
}
