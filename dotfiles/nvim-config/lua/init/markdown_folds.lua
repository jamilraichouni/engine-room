local M = {}

function M.foldexpr()
    local line = vim.fn.getline(vim.v.lnum)
    local hashes = line:match("^%s*(#+)%s+")
    if not hashes then
        return "="
    end
    return ">" .. #hashes
end

return M
