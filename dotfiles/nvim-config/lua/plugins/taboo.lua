return {
    {
        -- https://github.com/gcmt/taboo.vim
        "gcmt/taboo.vim",
        lazy = false,
        config = function()
            vim.cmd [[
                set sessionoptions+=tabpages,globals
                let g:taboo_tab_format = "| %N: %f%m"
                let g:taboo_renamed_tab_format = "| %N: %l"
            ]]
        end
    },
}
