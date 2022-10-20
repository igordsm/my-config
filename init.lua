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

local Popup = require("nui.popup")
local tags = require "igortags"
local Tasks = require "igortasks"

--- Tab configurations
local set = vim.opt
set.tabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.smartindent = true

set.guicursor = "i:block"
set.cursorline = true

function show_popup(text)
    local p = Popup {
        enter = true,
        focusable = true,
        border = {
        style = "rounded",
        },
        position = "50%",
        size = {
        width = "80%",
        height = "60%",
        },
    }
    p:mount()
    vim.api.nvim_buf_set_lines(p.bufnr, 0, 1, false, text)
end

local Org = require "igororg"
Org.parse_all_tasks()

function print_tasks() 
    --local l = Org.get_all_tasks()
    --local l = Org.get_tasks_from_project("Técnicas de Programação")
    --show_popup(l)

    Org.ui_choose_project(function (item) 
        print(item.text .. " chosen")
        local l = Org.get_tasks_from_project(item.text)
        show_popup(l)
    end)
end

vim.keymap.set("n", "tt", print_tasks)
