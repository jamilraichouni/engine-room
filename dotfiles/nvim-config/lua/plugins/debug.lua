return {
    {
        -- https://github.com/mfussenegger/nvim-dap
        "mfussenegger/nvim-dap",
        enabled = false,
        ft = { "java" },
        config = function()
            local dap = require("dap")
            dap.defaults.fallback.switchbuf = "usetab"
            dap.defaults.fallback.terminal_win_cmd = "belowright 15new | wincmd J"
            vim.fn.sign_define("DapBreakpoint",
                { text = "", texthl = "DapBreakpointText", linehl = "DapBreakpointLine", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "" })
            -- vim.fn.sign_define("DapStopped",
            --     { text = "", texthl = "DapStoppedText", linehl = "DapStoppedLine", numhl = "" })
            vim.cmd("highlight! DapBreakpointText guifg=#ff0000")

            -- dap mostly opening new windows
            vim.keymap.set("n", "<leader>Db", "<cmd>lua require('dap').list_breakpoints()<cr><cmd>copen<cr>")
            vim.keymap.set("n", "<leader>Df",
                "<cmd>lua require('dap.ui.widgets').sidebar(require('dap.ui.widgets').frames).open()<cr>")
            vim.keymap.set("n", "<leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<cr>")
            vim.keymap.set("n", "<leader>Dr", "<cmd>lua require('dap').repl.open()<cr>")
            vim.keymap.set("n", "<leader>Ds",
                "<cmd>lua require('dap.ui.widgets').sidebar(require('dap.ui.widgets').scopes).open()<cr>")

            vim.keymap.set("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>")
            vim.keymap.set("n", "<leader>dr", "<cmd>lua require('dap').restart()<cr>")

            -- continue functions also as (re-)start
            vim.keymap.set("n", "<leader>dc", "<cmd>lua require('dap').continue()<cr>")
            vim.keymap.set("n", "<leader>dC", "<cmd>lua require('dap').run_last()<cr>")
            vim.keymap.set("n", "<leader>d<esc>", "<cmd>lua require('dap').terminate()<cr>")
            vim.keymap.set("n", "<leader>do", "<cmd>lua require('dap').step_out()<cr>")
            vim.keymap.set("n", "<leader>dn", "<cmd>lua require('dap').step_over()<cr>")
            vim.keymap.set("n", "<leader>ds", "<cmd>lua require('dap').step_into()<cr>")
            vim.keymap.set("n", "<leader>dx", "<cmd>lua require('dap').clear_breakpoints()<cr>")
        end
    },
    -- {
    --     -- https://github.com/rcarriga/nvim-dap-ui
    --     "rcarriga/nvim-dap-ui",
    --     dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    --     config = function()
    --         local dap, dapui = require("dap"), require("dapui")
    --         dapui.setup()
    --         dap.listeners.before.attach.dapui_config = function()
    --             dapui.open()
    --         end
    --         dap.listeners.before.launch.dapui_config = function()
    --             dapui.open()
    --         end
    --         dap.listeners.before.event_terminated.dapui_config = function()
    --             dapui.close()
    --         end
    --         dap.listeners.before.event_exited.dapui_config = function()
    --             dapui.close()
    --         end
    --     end
    -- },
    {
        -- https://github.com/theHamsta/nvim-dap-virtual-text
        "theHamsta/nvim-dap-virtual-text",
        enabled = false,
        config = function()
            require("nvim-dap-virtual-text").setup({ virt_text_pos = "eol" })
        end,
    }
}
