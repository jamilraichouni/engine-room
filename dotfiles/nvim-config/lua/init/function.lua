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

vim.g.CompilePackageAndDeployCapellaAddon = function()
    -- compile
    local result_code = vim.g.CompileJavaProject()
    if result_code ~= 0 then
        return result_code
    end
    -- package
    local cmd = {
        "capella-addons",
        "package",
        vim.g.JAVA_HOME,
        vim.g.capella_home
    }
    print("Executing `" .. table.concat(cmd, " ") .. "`")
    local proc = vim.system(cmd):wait()
    print(proc.stdout)
    -- deploy
    if proc.code == 0 then
        cmd = {
            "capella-addons",
            "deploy",
            vim.g.capella_home
        }
        print("Executing `" .. table.concat(cmd, " ") .. "`")
        proc = vim.system(cmd):wait()
        print(proc.stdout)
        local deployed_file_path = proc.stdout:match("`(.-)`")
        local last_modified, err = get_last_modified_date(deployed_file_path)
        if last_modified then
            print("Last modified date: " .. last_modified)
        else
            print("Error: " .. err)
        end
    end
end

vim.g.CompileJavaProject = function()
    require("jdtls").compile("full")
    local bufnr = vim.api.nvim_get_current_buf()
    local jdtls_lspclients = vim.lsp.get_clients({ name = "jdtls", bufnr = bufnr })
    if #jdtls_lspclients == 0 then
        vim.notify("No JDT LSP client found!", vim.log.levels.ERROR)
        return 1
    end
    local client = jdtls_lspclients[1]
    local resp = client.request_sync("java/buildWorkspace", true, 5000, bufnr)
    if resp.result > 1 then
        -- we rerun the failed compilation to get the diagnostics
        require("jdtls").compile("full")
        return 1
    end
    vim.fn.setqflist({}, "r", { title = "", items = {} })
    vim.cmd("cclose")
    print("Compile done")
    return 0
end

vim.g.FormatCode = function()
    local bufnr = vim.api.nvim_get_current_buf()
    -- vim.lsp.buf.format({timeout_ms = 5000})
    vim.lsp.buf.format({ async = false })
    if next(vim.lsp.get_clients { bufnr = bufnr, method = "textDocument/codeAction" }) ~= nil then
        local kind = "source.organizeImports"
        if vim.bo.filetype == "python" then
            kind = "source.organizeImports.ruff"
        end

        local has_ca = false
        vim.lsp.buf.code_action {
            context = { only = { kind } },
            filter = function(x)
                if not has_ca then
                    has_ca = true
                    return true
                end
                return false
            end,
            apply = true,
        }
    end
end

vim.g.JavaBuildClassPath = function()
    local current_buffer_path = vim.api.nvim_buf_get_name(0)
    local cmd = {
        "capella-addons",
        "build-classpath",
        "--java-execution-environment=" ..
        vim.g.JavaGetDefaultRuntime().name,
        current_buffer_path,
        vim.g.capella_home
    }
    print("Executing `" .. table.concat(cmd, " ") .. "`")
    local proc = vim.system(cmd):wait()
    if proc.code == 0 then
        print(proc.stdout)
    else
        print("Error: " .. proc.stderr)
    end
end

vim.g.JavaGetDefaultRuntime = function()
    -- read the default runtime from the LSP client settings as it has been set
    -- in ~/.config/nvim/ftplugin/java.lua
    local bufnr = vim.api.nvim_get_current_buf()
    local client = vim.lsp.get_clients({ name = "jdtls", bufnr = bufnr })[1]
    if not client then
        vim.notify(
            "No LSP client `jdtls` found.",
            vim.log.levels.WARN
        )
    end
    local runtimes = (client.config.settings.java.configuration or {}).runtimes or {}
    if #runtimes == 0 then
        vim.notify(
            "No runtimes found in `config.settings.java.configuration.runtimes`."
            .. " You need to add runtime paths to change the runtime",
            vim.log.levels.WARN
        )
        return
    end
    local runtime
    for _, r in pairs(runtimes) do
        if r.default or #runtimes == 1 then
            runtime = r
        end
    end
    if not runtime then
        vim.notify(
            "No default runtime found in `config.settings.java.configuration.runtimes`",
            vim.log.levels.WARN
        )
        return
    end
    return runtime
end

vim.g.SetCapellaVersion = function(version)
    if type(version) ~= "string" or not version:match("%d+%.%d+%.%d+") then
        vim.notify("Invalid version: " .. version, vim.log.levels.ERROR)
        return
    end
    vim.g.capella_version = version
    vim.g.capella_home = "/opt/capella_" .. vim.g.capella_version
    -- check if the directory `vim.g.capella_home` exists
    if vim.loop.fs_stat(vim.g.capella_home) == nil then
        vim.notify("Capella home directory not found: " .. vim.g.capella_home, vim.log.levels.ERROR)
        return
    end
    vim.g.JAVA_HOME = nil
    if vim.g.capella_version == "6.0.0" or vim.g.capella_version == "6.1.0" then
        vim.g.JAVA_HOME = "/usr/lib/jvm/jdk-17.0.6+10"
    elseif vim.g.capella_version == "7.0.0" then
        vim.g.JAVA_HOME = "/usr/lib/jvm/jdk-17.0.11+9"
    end
    vim.notify("Capella version set to " .. version)
end

vim.g.WorkingTimesCompute = function()
    -- save the modified working time buffer
    vim.api.nvim_command("write")
    local proc = vim.system(
        { "uv", "run", "python", "-m", "working_times" },
        {
            cwd = os.getenv("HOME") .. "/dev/github/working-times",
            -- env = { PYENV_VERSION = "working-times" }
        }
    ):wait()
    if proc.code == 0 then
        vim.api.nvim_command("edit")
    else
        print("Error: " .. proc.stdout)
    end
end
