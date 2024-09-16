vim.g.json_fold_text = function()
    local line = vim.fn.getline(vim.v.foldstart)
    local num_lines = vim.v.foldend - vim.v.foldstart + 1
    local key = line:match("\"(.+)\"")
    if key == nil then
        key = line
        return string.format("%s (%d lines)", line, num_lines)
    end
    local indent = string.rep(" ", vim.fn.indent(vim.v.foldstart))
    return string.format("%s\"%s\" (%d lines)", indent, key, num_lines, key)
end
vim.cmd.setlocal("foldtext=g:json_fold_text()")
