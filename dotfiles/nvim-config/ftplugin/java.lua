-- https://github.com/mfussenegger/nvim-dap/wiki/Java
local dap = require('dap')
local HOME = os.getenv("HOME")
if not vim.g.JAVA_HOME then
    vim.notify("vim.g.JAVA_HOME is not set", vim.log.levels.INFO)
    return
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspaces_dir = '/opt/bind/workspaces/'
local workspace_dir = workspaces_dir .. "eclipse-jdt_" .. project_name
local equinox_launcher = {
    ["6.0.0"] = "org.eclipse.equinox.launcher_1.6.200.v20210416-2027.jar",
    ["6.1.0"] = "org.eclipse.equinox.launcher_1.6.200.v20210416-2027.jar",
}

dap.configurations.java = {
    {
        name = "Eclipse Plugin",
        request = "launch",
        type = "java",
        javaExec = vim.g.JAVA_HOME .. "/bin/java",
        args =
            "-product org.polarsys.capella.rcp.product" ..
            " -showsplash" ..
            " -launcher " .. vim.g.capella_home .. "/capella" ..
            " -name Capella" ..
            " -data " .. workspaces_dir .. "RUNTIME" ..
            " --add-modules=ALL-SYSTEM" ..
            " -os linux" ..
            " -ws gtk" ..
            " -arch " .. vim.fn.system("uname -m") ..
            " -nl en_US" ..
            " -clean" ..
            " -consoleLog" ..
            " -debug" ..
            " -vm " .. vim.g.JAVA_HOME .. "/bin/java",
        -- "-product org.polarsys.capella.rcp.product -launcher /opt/capella/capella -name Eclipse -data /mnt/volume/data/workspaces/RUNTIME --add-modules=ALL-SYSTEM -os linux -ws gtk -arch aarch64 -nl en_US -clean -consoleLog -debug -console",
        vmArgs =
            "-XX:+ShowCodeDetailsInExceptionMessages" ..
            " -Dorg.eclipse.swt.graphics.Resource.reportNonDisposed=true" ..
            " -Declipse.pde.launch=true" ..
            " -Dfile.encoding=UTF-8",
        classPaths = {
            vim.g.capella_home .. "/plugins/" .. equinox_launcher[vim.g.capella_version]
        },
        mainClass = "org.eclipse.equinox.launcher.Main",
        env = {
            -- MODEL_INBOX_DIRECTORIES = "/mnt/volume/data/dev/github/capella-addons/data/models/empty_capella_project:/mnt/volume/data/dev/github/capella-addons/data/models/test:/mnt/volume/data/dev/github/capella-rest-api/data/models/automated-train",
            -- SELECTED_ELEMENTS_SERVICE_TARGET_URL = "http://localhost:8080",
        }
    },
    -- {
    --     name = "TestBrowser",
    --     request = "launch",
    --     type = "java",
    --     javaExec = "java",
    --     args = "-consoleLog -debug TestBrowser",
    --     classPaths = {
    --         "target/classes",
    --         "lib/org.eclipse.swt.gtk.linux.aarch64.source_3.123.0.v20230220-1431.jar",
    --         "lib/org.eclipse.swt.gtk.linux.aarch64_3.123.0.v20230220-1431.jar",
    --         "lib/org.eclipse.swt_3.123.0.v20230220-1431.jar"
    --     },
    --     env = {
    --         XDG_RUNTIME_DIR = "/tmp/xdg_runtime_dir",
    --     }
    -- },
}


local jdtls = require('jdtls')
jdtls.setup_dap({hotcodereplace = true,})
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
local config = {
    cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-jar',
        HOME .. "/.local/share/nvim/mason/share/jdtls/plugins/org.eclipse.equinox.launcher.jar",
        "-configuration",
        HOME .. "/.local/share/nvim/mason/packages/jdtls/config_linux_arm",
        '-data', workspace_dir,
    },
    root_dir = vim.fs.dirname(vim.fs.find({ 'plugin.xml', 'pom.xml', '.project' }, { upward = true })[1]),
    settings = {
        java = {
            configuration = {
                -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                -- And search for `interface RuntimeOption`
                -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
                runtimes = {
                    {
                        name = "JavaSE-17",
                        path = vim.g.JAVA_HOME .. "/",
                    }
                }
            },
            -- updateBuildConfiguration = "automatic",
            signatureHelp = { enabled = true },
        }
    },
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    handlers = {
        ['textDocument/documentSymbol'] = function(_, result, ctx, _)
            -- local items = {}
            local symbols = {}
            for _, symbol in ipairs(result) do
                table.insert(symbols, symbol)
            end
            local items = vim.lsp.util.symbols_to_items(symbols)
            for _, item in ipairs(items) do
                item.bufnr = ctx.bufnr
            end

            -- Update quickfix list with the items
            -- see `:h setqflist`
            vim.fn.setqflist({}, 'r', {
                bufnr = ctx.bufnr,
                title = 'Document Symbols',
                items = items,
                quickfixtextfunc = function(info)
                    local custom_items = vim.fn.getqflist({ id = info.id, items = 1 }).items
                    local l = {}
                    local txt = ''
                    for idx = info.start_idx, info.end_idx do
                        -- table.insert(l, vim.fn.fnamemodify(vim.fn.bufname(custom_items[idx].bufnr), ':p:.'))
                        -- see `:h quickfix-window-function`
                        txt = custom_items[idx].text
                        -- see https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
                        txt = txt:gsub('%[Class%]', ' ')
                        txt = txt:gsub('%[Constant%]', '  ')
                        txt = txt:gsub('%[Constructor%]', ' ')
                        txt = txt:gsub('%[Enum%]', '  ')
                        txt = txt:gsub('%[EnumMember%]', '  ')
                        txt = txt:gsub('%[Event%]', ' ')
                        txt = txt:gsub('%[Field%]', ' ')
                        txt = txt:gsub('%[File%]', ' ')
                        txt = txt:gsub('%[Function%]', ' ')
                        txt = txt:gsub('%[Interface%]', ' ')
                        txt = txt:gsub('%[Key%]', ' ')
                        txt = txt:gsub('%[Method%]', ' ')
                        txt = txt:gsub('%[Module%]', ' ')
                        txt = txt:gsub('%[Namespace%]', ' ')
                        txt = txt:gsub('%[Number%]', ' ')
                        txt = txt:gsub('%[Object%]', ' ')
                        txt = txt:gsub('%[Operator%]', ' ')
                        txt = txt:gsub('%[Package%]', ' ')
                        txt = txt:gsub('%[Property%]', ' ')
                        txt = txt:gsub('%[String%]', ' ')
                        txt = txt:gsub('%[Struct%]', ' ')
                        txt = txt:gsub('%[TypeParameter%]', ' ')
                        txt = txt:gsub('%[Variable%]', ' ')
                        table.insert(l, txt)
                    end
                    return l
                end
            })
        end,
    },
    init_options = {
        bundles = {
            vim.fn.glob(
                "~/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
                1)
        },
    }
}
jdtls.start_or_attach(config)

vim.g.java_fold_text = function()
    local line = vim.fn.getline(vim.v.foldstart)
    local num_lines = vim.v.foldend - vim.v.foldstart + 1
    return string.format("%s    %d lines", line, num_lines)
end

vim.wo.foldtext = "g:java_fold_text()"
vim.wo.foldlevel = 1
