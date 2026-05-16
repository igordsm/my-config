vim.pack.add({
  'https://github.com/navarasu/onedark.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/github/copilot.vim',
  'https://github.com/neovim/nvim-lspconfig',
})

require('onedark').load()
local wk = require('which-key')
wk.setup({
	preset = 'helix'
})

if os.getenv("TERMUX") ~= nil then
 vim.o.background = "light"
end

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<Up>", "gk")
vim.keymap.set("n", "<Down>", "gj")


--- LSP stuff
vim.lsp.enable("clangd")

-- Enable LSP-based completion with autotrigger

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev) 
      local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
	vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = true})


    end
    })

