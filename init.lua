require "paq" {
    "savq/paq-nvim";                  -- Let Paq manage itself
	"neovim/nvim-lspconfig";
    "nvim-lua/plenary.nvim";
    "BurntSushi/ripgrep";
    "sharkdp/fd";
    "nvim-treesitter/nvim-treesitter";
    "nvim-telescope/telescope.nvim";
}



--- Tab configurations
local set = vim.opt
set.tabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.smartindent = true

set.guicursor = "i:block"
set.cursorline = true
