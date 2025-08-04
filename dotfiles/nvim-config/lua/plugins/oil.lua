return {
    {
        'stevearc/oil.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup({
                preview_win = {
                    win_options = {
                        foldenable = false,
                    },
                },
                -- Oil will automatically delete hidden buffers after this delay
                -- You can set the delay to false to disable cleanup entirely
                -- Note that the cleanup process only starts when none of the oil buffers are currently displayed
                cleanup_delay_ms = false, -- default is 2000, 300000 is 5 minutes
                constrain_cursor = "name",
                buf_options = {
                    buflisted = false,
                    bufhidden = "hide",
                },
                win_options = {
                    concealcursor = "nvic",
                    conceallevel = 3,
                    cursorcolumn = false,
                    foldcolumn = "0",
                    foldenable = false,
                    list = false,
                    signcolumn = "no",
                    spell = false,
                    wrap = false,
                },
                columns = {
                    { "size",  highlight = "Constant" },
                    { "ctime", format = "%Y-%m-%d %H:%M:%S" },
                    { "mtime", format = "%Y-%m-%d %H:%M:%S", highlight = "Comment" },
                },
                keymaps = {
                    ["g?"] = "actions.show_help",
                    ["<CR>"] = "actions.select",
                    ["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
                    ["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
                    ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
                    ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = "actions.close",
                    ["<C-l>"] = "actions.refresh",
                    ["-"] = "actions.parent",
                    ["_"] = "actions.open_cwd",
                    ["`"] = "actions.cd",
                    ["~"] = { "actions.cd", opts = { scope = "win" }, desc = ":tcd to the current oil directory" },
                    ["gs"] = "actions.change_sort",
                    ["gx"] = "actions.open_external",
                    ["g."] = "actions.toggle_hidden",
                    ["g\\"] = "actions.toggle_trash",
                },
                -- Set to false to disable all of the above keymaps
                use_default_keymaps = true,
                -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
                skip_confirm_for_simple_edits = true,
                view_options = {
                    show_hidden = false,
                    -- This function defines what is considered a "hidden" file
                    is_hidden_file = function(name, bufnr)
                        bufnr = bufnr
                        return vim.startswith(name, ".")
                    end,
                    -- This function defines what will never be shown, even when `show_hidden` is set
                    is_always_hidden = function(name, bufnr)
                        name = name
                        bufnr = bufnr
                        return false
                    end,
                    -- Sort file and directory names case insensitive
                    case_insensitive = false,
                    sort = {
                        -- sort order can be "asc" or "desc"
                        -- see :help oil-columns to see which columns are sortable
                        { "name", "asc" },
                    },
                },
                watch_for_changes = true,
            })
            vim.cmd [[
            nnoremap <silent><leader>Ob <cmd>Oil<cr>
            nnoremap <silent><leader>Ot <cmd>tabnew <bar> Oil<cr><cmd>TabooRename Oil<cr>
            nnoremap <silent><leader>Oh <cmd>vnew <bar> Oil<cr>
            nnoremap <silent><leader>Oj <cmd>belowright new <bar> Oil<cr>
            nnoremap <silent><leader>Ok <cmd>new <bar> Oil<cr>
            nnoremap <silent><leader>Ol <cmd>belowright vnew <bar> Oil<cr>
        ]]
        end,
    },
}
