return {
    -- https://github.com/zbirenbaum/copilot.lua {{{
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require('copilot').setup({
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    hide_during_completion = true,
                    debounce = 75,
                    trigger_on_accept = false,
                    keymap = {
                        accept = "<c-a>",
                        accept_word = "<c-w>",
                        accept_line = "<c-l>",
                        next = "<c-j>",
                        prev = "<c-k>",
                        -- dismiss = "<C-]>",
                    },
                },
                filetypes = {
                    -- gitcommit = true,
                    -- markdown = true,
                    -- python = true,
                    -- yaml = true,
                    sh = function()
                        if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
                            -- disable for .env files
                            return false
                        end
                        return true
                    end,
                    ["*"] = true
                },
                should_attach = function(_, _)
                    return true
                end,
                logger = {
                    file = "/tmp/copilot-lua.log",
                    file_log_level = vim.log.levels.OFF,
                    print_log_level = vim.log.levels.ERROR,
                    trace_lsp = "off", -- "off" | "messages" | "verbose"
                    trace_lsp_progress = false,
                    log_lsp_messages = false,
                },
            })
        end,
    },
    -- }}}
    -- https://github.com/AndreM222/copilot-lualine {{{
    { 'AndreM222/copilot-lualine' }
    -- }}}
}
