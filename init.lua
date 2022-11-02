require "paq" {
    "savq/paq-nvim";                  -- Let Paq manage itself
	"neovim/nvim-lspconfig";
    "nvim-lua/plenary.nvim";
    "BurntSushi/ripgrep";
    "sharkdp/fd";
    "nvim-treesitter/nvim-treesitter";
    "nvim-telescope/telescope.nvim";
    "MunifTanjim/nui.nvim";
}

--- Tab configurations
local set = vim.opt
set.tabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.smartindent = true

set.guicursor = "i:block"
set.cursorline = true

--- Custom keymaps
vim.api.nvim_set_keymap("t", "<esc>", '<C-\\><c-n>', { noremap = true })

--- LSP configurations
require "lsp"


--- Organization Features

local Org = require "igororg"
Org.parse_all_tasks()

function open_file_from_task(task) 
    vim.api.nvim_exec("tabnew " .. task.origin, false)
    vim.api.nvim_exec("" .. task.linenum, false)
end

function print_tasks() 
    Org.ui_choose(Org.all_projects, function (item) 
        print(item.text .. " chosen")
        local l = Org.get_tasks_from_project(item.text, function (tsk)
            return not tsk.done
        end)

        Org.ui_choose(l, function (item) open_file_from_task(item.value) end)

    end)
end

vim.keymap.set("n", "tt", print_tasks)


function show_follow_ups()
    local all_follow_ups = Org.get_tasks_by(function (tsk) 
        return tsk.taglist["follow-up"] ~= nil and not tsk.done
    end)
    Org.ui_choose(all_follow_ups, function (item) open_file_from_task(item.value) end)
end

vim.keymap.set("n", "tff", show_follow_ups)
