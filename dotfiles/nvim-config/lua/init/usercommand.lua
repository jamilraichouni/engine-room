vim.api.nvim_create_user_command("CapellaSetVersion", "lua vim.g.SetCapellaVersion(<f-args>)",
    { nargs = 1, force = true }
)
vim.api.nvim_create_user_command("DevTab", "tabnew | tabm 0 | TabooRename dev", { force = true })
vim.api.nvim_create_user_command("DockerImagesTab",
    "tabnew | tcd ~/dev/dbgitlab/docker-images | TabooRename docker-images", { force = true })
vim.api.nvim_create_user_command("GitopsTab", "tabnew | tcd ~/dev/dbgitlab/gitops | TabooRename gitops", { force = true })
vim.api.nvim_create_user_command("HTML2FT", "%s/\\v(\\w+)\\(/\\=printf('ft.%s(', submatch(1))/g | nohl", { force = true })
vim.api.nvim_create_user_command("OpenCode",
    "tabnew | tcd ~/engine-room/dotfiles/opencode | edit . | TabooRename opencode (config)",
    { force = true }
)
vim.api.nvim_create_user_command("AgentsOpenCode",
    "edit ~/engine-room/dotfiles/opencode/agents/",
    { force = true }
)
vim.api.nvim_create_user_command("OpenCodeAgents",
    "edit ~/engine-room/dotfiles/opencode/agents/",
    { force = true }
)
vim.api.nvim_create_user_command("CommandsOpenCode",
    "edit ~/engine-room/dotfiles/opencode/commands/",
    { force = true }
)
vim.api.nvim_create_user_command("OpenCodeCommands",
    "edit ~/engine-room/dotfiles/opencode/commands/",
    { force = true }
)
vim.api.nvim_create_user_command("OpenCodeJson",
    "edit ~/engine-room/dotfiles/opencode/opencode.json",
    { force = true }
)
vim.api.nvim_create_user_command("SkillsOpenCode",
    "edit ~/engine-room/dotfiles/opencode/skills/",
    { force = true }
)
vim.api.nvim_create_user_command("OpenCodeSkills",
    "edit ~/engine-room/dotfiles/opencode/skills/",
    { force = true }
)
vim.api.nvim_create_user_command("ToolsOpenCode",
    "edit ~/engine-room/dotfiles/opencode/tools/",
    { force = true }
)
vim.api.nvim_create_user_command("OpenCodeTools",
    "edit ~/engine-room/dotfiles/opencode/tools/",
    { force = true }
)
vim.api.nvim_create_user_command("Qa", "qa", { force = true })
vim.api.nvim_create_user_command("Showautocmd", "redir! > /tmp/.autocmd | silent autocmd | redir END | e /tmp/.autocmd",
    { force = true }
)
vim.api.nvim_create_user_command("JoKeymapsAll", "redir! > /tmp/.map | silent map | redir END | e /tmp/.map",
    { force = true }
)
vim.api.nvim_create_user_command("JoDoc",
    "edit ~/engine-room/dotfiles/nvim-config/docs/JARDOC.md",
    { force = true }
)
vim.api.nvim_create_user_command("JoCheatSheet",
    "echo system('cat ~/engine-room/dotfiles/nvim-config/docs/CHEATSHEET.md')",
    { force = true }
)
vim.api.nvim_create_user_command("JoCheatSheetEdit", "edit ~/engine-room/dotfiles/nvim-config/docs/CHEATSHEET.md",
    { force = true }
)
vim.api.nvim_create_user_command("TSInspect", "Inspect!", { force = true })
vim.api.nvim_create_user_command("WorkingTimesCompute", "lua vim.g.WorkingTimesCompute()", { force = true })
vim.api.nvim_create_user_command("WorkingTimesSaveAndClose", "write | bdelete", { force = true })

