local vim = vim
local opt = vim.opt

vim.g.mapleader = ','

vim.pack.add({
  'https://github.com/navarasu/onedark.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/folke/zen-mode.nvim',


  -- LSP and autocomplete
  'https://github.com/neovim/nvim-lspconfig',
  { src='https://github.com/saghen/blink.cmp', version="v1.10.2"},
  "https://github.com/nvim-tree/nvim-web-devicons",
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/nvim-treesitter/nvim-treesitter',


  'https://github.com/ray-x/go.nvim',
  'https://github.com/hedyhli/outline.nvim',

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

require('outline').setup{}

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


require('go').setup{}


opt.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
  command = "checktime",
})
opt.number = true

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
vim.keymap.set("n", "<leader>tf", "<cmd>NvimTreeFindFile<CR>", { desc = "Find file tree"})
vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Toggle Zen Mode" })

vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>")

--- LSP stuff
vim.lsp.enable({"clangd", "gopls"})

-- Enable LSP-based completion with autotrigger
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev) 
      local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
	vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = true})


    end
    })

-- Enable session saving
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback= function (ev) 
		vim.cmd("mksession!")
	end
})

-- UBER specific stuff --
--

vim.env.PATH = vim.env.VIM_PATH or vim.env.PATH

vim.lsp.config('ulsp', {
    cmd = { "socat", "-", "tcp:localhost:27883,ignoreeof" },
    flags = {
      debounce_text_changes = 1000,
    },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    filetypes = { "go", "java" },
    root_dir = require('lspconfig.util').root_pattern("go.mod", ".git"),
    single_file_support = false,
    docs = {
      description = [[
  uLSP brought to you by the IDE team!
  By utilizing uLSP in Neovim, you acknowledge that this integration is provided 'as-is' with no warranty, express or implied.
  We make no guarantees regarding its functionality, performance, or suitability for any purpose, and absolutely no support will be provided.
  Use at your own risk, and may the code gods have mercy on your soul
]],
    },
  })




vim.lsp.enable({"clangd", "gopls", 'ulsp'})
