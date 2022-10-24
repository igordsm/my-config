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

--- LSP configurations
require "lsp"


--- Organization Features

local Org = require "igororg"
Org.parse_all_tasks()

function print_tasks() 
    Org.ui_choose(Org.all_projects, function (item) 
        print(item.text .. " chosen")
        local l = Org.get_tasks_from_project(item.text)

        Org.ui_choose(l, function (item)
            vim.api.nvim_exec("tabnew " .. item.value.origin, false)
            vim.api.nvim_exec("" .. item.value.linenum, false)
            print(item.value.descr .. " " .. item.value.origin)
        end)

    end)
end

vim.keymap.set("n", "tt", print_tasks)
