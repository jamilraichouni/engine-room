vim.g.startChat = function()
    vim.cmd.setlocal("filetype=aichat")
    vim.cmd.startinsert()
end
return {
    -- https://github.com/madox2/vim-ai (ChatGPT in Neovim) {{{
    {
        "madox2/vim-ai",
        cmd = { "AI", "AIChat", "AIEdit", "AINewChat", "AIRedo", "AIUtilRolesOpen", "AIUtilDebugOff", "AIUtilDebugOn" },
        ft = "aichat",
        keys = {
            { "<leader>bc", "<cmd>normal zt<cr><cmd>AIChat<cr>" },
            { "<leader>br", "<cmd>AIRedo<cr>" },
            { "<leader>Bt", "<cmd>AIC /t<cr>" },
            { "<leader>Bb", "<cmd>AIC /b<cr>" },
            { "<leader>Bh", "<cmd>AIC /h<cr>" },
            { "<leader>Bj", "<cmd>AIC /j<cr>" },
            { "<leader>Bk", "<cmd>AIC /k<cr>" },
            { "<leader>Bl", "<cmd>AIC /l<cr>" },
        },
        config = function()
            vim.g.vim_ai_debug = 0
            vim.g.vim_ai_debug_log_file = "/tmp/vim_ai_debug.log"
            vim.g.vim_ai_roles_config_file = os.getenv("HOME") .. "/.config/nvim/vim-ai-roles.ini"
            -- vim.g.vim_ai_token_file_path = "/mnt/volume/openai.token"

            -- "https://api.deepseek.com/v1", "https://api.openai.com/v1/chat/completions"
            -- local endpoint_url = "https://api.deepseek.com/v1"
            local endpoint_url = "https://api.openai.com/v1/chat/completions"

            -- "gpt-4o", "deepseek-chat"
            -- local model = "deepseek-chat"
            local model = "gpt-4o"

            local initial_chat_prompt = [[
>>> system

You are going to play a role of an IT expert (ITE) that works on a Fedora 40
system in a Docker container. The ITE codes on the backend mainly with Python
3.12 and Java 17. Maven is used for Java builds. Python backend servers will be
implemented using FastAPI. When a REST API is being built it must strictly
follow the latest OpenAPI standard. ]]

            local chat_engine_cfg = {
                engine = "chat",
                options = {
                    endpoint_url = endpoint_url,
                    model = model,
                    max_tokens = 0,
                    temperature = 0,
                    request_timeout = 20,
                    selection_boundary = '"""',
                    initial_prompt = initial_chat_prompt,
                },
                ui = {
                    paste_mode = 0,
                },
            }

            local complete_initial_prompt = [[
>>> system

You are going to play a role of a completion engine with following parameters:
Task: Provide compact code/text completion, generation, transformation or explanation.
Topic: General programming and text editing (Python, Shell, Lua, Neovim plugin development, GitHub actions, etc.)
Style: Plain result without any commentary, unless commentary is necessary or given in the prompt.
Audience: Users of text editor and programmers that need to transform/generate text
]]
            local edit_initial_prompt = [[
>>> system

You are going to play a role of a completion engine that replaces (edits) given software code or text with following parameters:
Task: Provide compact code/ text replacements or improvements.
Topic: General programming and text editing (Python, Shell, Lua, Neovim plugin development, GitHub actions, etc.)
Style: Plain result without any commentary, unless commentary is necessary or given in the prompt. Do never surround resulting code with '```python' and '```' or similar markers. Keep the indentation of the prompt (number of blanks at the start will be kept).
Audience: Users of text editor and programmers that need to transform/generate text
]]

            local complete_engine_cfg_chatgpt = {
                engine = "chat",
                options = {
                    endpoint_url = endpoint_url,
                    model = model,
                    max_tokens = 0,
                    temperature = 0,
                    request_timeout = 20,
                    selection_boundary = "",
                    initial_prompt = complete_initial_prompt,
                },
            }
            local edit_engine_cfg_chatgpt = {
                engine = "chat",
                options = {
                    endpoint_url = endpoint_url,
                    model = model,
                    max_tokens = 0,
                    temperature = 0,
                    request_timeout = 20,
                    selection_boundary = "",
                    initial_prompt = edit_initial_prompt,
                },
            }

            -- vim.g.vim_ai_chat = chat_engine_cfg
            -- vim.g.vim_ai_complete = complete_engine_cfg_chatgpt
            -- vim.g.vim_ai_edit = edit_engine_cfg_chatgpt

            vim.cmd("highlight link aichatRole Title")
            -- hightlight steps in gpt answers:
            vim.api.nvim_create_autocmd({ "FileType" }, {
                group = vim.g.augroup_jar,
                pattern = { "aichat" },
                command = "call matchadd('aichat_step', '^##.*')",
            })
            vim.cmd.highlight("aichat_step", "guifg=#569cd6 guibg=#1e1e1e")

            vim.api.nvim_create_autocmd({ "FileType" }, {
                group = vim.g.augroup_jar,
                pattern = { "aichat" },
                command = "call matchadd('Special', '^>>> user\\|^>>> include\\|^>>> exec')",
            })
            -- vim.cmd.highlight("aichat_user", "guifg=#ff0008 guibg=#1e1e1e")

            vim.api.nvim_create_autocmd({ "FileType" }, {
                group = vim.g.augroup_jar,
                pattern = { "aichat" },
                command = "call matchadd('Constant', '^<<< assistant')",
            })
            -- vim.cmd.highlight("aichat_assistant", "guifg=#00f900 guibg=#1e1e1e")

            function ChatGPTEclipsePluginExpertFn()
                local prompt = "I have a question about Eclipse plugin development."
                local config = {
                    engine = "chat",
                    options = {
                        model = "gpt-4o",
                        initial_prompt =
                        ">>> system\n\nYou are going to play a role of an expert in Eclipse plugin development.",
                        max_tokens = 0,
                        temperature = 0,
                        request_timeout = 20,
                        selection_boundary = '"""',
                    },
                }
                vim.fn['vim_ai#AIChatRun']("%", { config = config, prompt = prompt })
            end

            vim.api.nvim_create_user_command("ChatGPTEclipsePluginExpertFn", ChatGPTEclipsePluginExpertFn, {})
        end,
    },
    -- }}}
    -- https://github.com/github/copilot.vim {{{
    -- {
    --     "github/copilot.vim",
    --     cmd = "Copilot",
    --     event = "VeryLazy",
    --     config = function()
    --         vim.cmd [[
    --     let g:copilot_filetypes = {
    --     \ '*': v:true,
    --     \ 'oil': v:false,
    --     \ }
    --     let g:copilot_no_tab_map = v:true
    --
    --     imap <silent><script><expr> <C-K> copilot#Previous()
    --     imap <silent><script><expr> <C-J> copilot#Next()
    --     imap <silent><script><expr> <C-L> copilot#Accept("\<CR>")
    --     imap <silent><C-W> <Plug>(copilot-accept-word)
    --   ]]
    --     end,
    -- },
    -- }}}
}
