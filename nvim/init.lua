local vim = vim
local opt = vim.opt

vim.g.mapleader = ','

vim.pack.add({
  'https://github.com/navarasu/onedark.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/github/copilot.vim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/folke/zen-mode.nvim',


  -- LSP and autocomplete
  'https://github.com/neovim/nvim-lspconfig',
  { src='https://github.com/saghen/blink.cmp', version="v1.10.2"},
  "https://github.com/nvim-tree/nvim-web-devicons",
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/nvim-treesitter/nvim-treesitter',

})

require('zen-mode').setup{}

require('onedark').load()
local wk = require('which-key')
wk.setup({
	preset = 'helix'
})

if os.getenv("TERMUX") ~= nil then
 vim.o.background = "light"
end

require('fzf-lua').setup { 'default',
  files = {
    -- Use fd for faster file finding if installed
    find_command = "fd --type f --strip-cwd-prefix --exclude .git",
  },

}
require('nvim-tree').setup {
	view = {

	width = 50,
}
}

require('blink.cmp').setup({
  keymap = { preset = 'super-tab' },

  appearance = {
    nerd_font_variant = 'mono'
  },

  completion = {
    documentation = { auto_show = false }
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  fuzzy = {
    implementation = "prefer_rust_with_warning"
  }
})



vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
  command = "checktime",
})

opt.foldlevel = 2
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"


----- Key bindings

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<Up>", "gk")
vim.keymap.set("n", "<Down>", "gj")

vim.keymap.set("n", "<leader>f", function() require('fzf-lua').files({cwd_only=true, previewer=false}) end, { desc="Find files" })
vim.keymap.set("n", "<leader>b", "<cmd>FzfLua buffers<CR>")
vim.keymap.set("n", "<leader>p", "<cmd>FzfLua global<CR>")
vim.keymap.set("n", "<leader>t", require('nvim-tree.api').tree.toggle, { desc = "Toggle file tree"})
vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Toggle Zen Mode" })

--- LSP stuff
vim.lsp.enable({"clangd", "gopls"})

-- Enable LSP-based completion with autotrigger
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev) 
      local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
	vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = true})


    end
    })

