vim.g.fold_text = function()
    local line = vim.fn.getline(vim.v.foldstart)
    local num_lines = vim.v.foldend - vim.v.foldstart + 1
    return string.format("%s    %d lines", line, num_lines)
end

local function get_last_modified_date(filepath)
    local stat = vim.loop.fs_stat(filepath)
    if stat then
        return os.date('%Y-%m-%d %H:%M:%S', stat.mtime.sec)
    else
        return nil, "File not found"
    end
end

vim.g.JavaBuildClassPath = function()
    local obj = nil
    local current_buffer_path = vim.api.nvim_buf_get_name(0)
    obj = vim.system({ "python", "-m", "eclipse_plugin_builders", "build-classpath", current_buffer_path, vim.g.capella_home },
            { cwd = os.getenv("HOME") .. "/dev/github/eclipse-plugin-builders", env = { PYENV_VERSION = "eclipse-plugin-builders" } })
        :wait()
    if obj.code == 0 then
        print(obj.stdout)
    else
        print("Error: " .. obj.stderr)
    end
end

vim.g.PackageAndDeployEclipsePlugin = function()
    local obj = nil
    obj = vim.system({ "python3", "-m", "eclipse_plugin_builders", "package" }):wait()
    print(obj.stdout)
    if obj.code == 0 then
        obj = vim.system({ "python3", "-m", "eclipse_plugin_builders", "deploy", vim.g.capella_home }):wait()
        print(obj.stdout)
        local deployed_file_path = obj.stdout:match("`(.-)`")
        local last_modified, err = get_last_modified_date(deployed_file_path)
        if last_modified then
            print("Last modified date: " .. last_modified)
        else
            print("Error: " .. err)
        end
    end
end

vim.g.CompilePackageAndDeployEclipsePlugin = function()
    -- require("jdtls").compile("full")
    local bufnr = vim.api.nvim_get_current_buf()
    local client = vim.lsp.get_clients({ name = "jdtls", bufnr = bufnr })[1]
    local resp = client.request_sync("java/buildWorkspace", true, 5000, bufnr)
    if resp.result > 1 then
        require("jdtls").compile("full")
        return
    end
    vim.fn.setqflist({}, "r", { title = "", items = {} })
    vim.cmd("cclose")
    print("Compile done")
    vim.g.PackageAndDeployEclipsePlugin()
end

vim.g.WorkingTimesCompute = function()
    local obj = nil
    vim.api.nvim_command("write")
    obj = vim.system({ "python", "-m", "working_times" },
        { cwd = os.getenv("HOME") .. "/dev/github/working-times", env = { PYENV_VERSION = "working-times" } }):wait()
    if obj.code == 0 then
        vim.api.nvim_command("edit")
    else
        print("Error: " .. obj.stderr)
    end
end
