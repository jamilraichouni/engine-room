vim.g.xml_fold_text = function()
    local line = vim.fn.getline(vim.v.foldstart)
    local num_lines = vim.v.foldend - vim.v.foldstart + 1
    local tag = line:match("<(%w+)")
    local indent = string.rep(" ", vim.fn.indent(vim.v.foldstart))
    return string.format("%s<%s> (%d lines)", indent, tag, num_lines, tag)
end
vim.opt_local.foldtext = "g:xml_fold_text()"

