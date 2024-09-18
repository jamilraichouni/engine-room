vim.g.python_fold_text = function()
    local line = vim.fn.getline(vim.v.foldstart)
    local num_lines = vim.v.foldend - vim.v.foldstart + 1
    return string.format("%s    %d lines", line, num_lines)
end
vim.o.foldtext = "g:python_fold_text()"
vim.opt_local.colorcolumn = { "72", "79" }
vim.wo.foldlevel = 0
