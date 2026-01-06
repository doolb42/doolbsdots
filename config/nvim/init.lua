-- =============== BASIC OPTIONS ===============

vim.opt.ttimeoutlen = 0
vim.opt.timeoutlen = 500
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- =============== BOOTSTRAP LAZY.NVIM ===============
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============== PLUGINS ===============
require("lazy").setup({
  { "sainnhe/everforest" },
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-lualine/lualine.nvim" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- LSP + Autocomplete
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },

  -- Git
  { "tpope/vim-fugitive" },
  { "airblade/vim-gitgutter" },

  -- Godot
  { "habamax/vim-godot" },

  -- Vim Essentials
  { "tpope/vim-surround" },
  { "tpope/vim-commentary" },

  --LaTeX
  { "lervag/vimtex" },
  { "kdheepak/cmp-latex-symbols" },
})

-- =============== UI SETUP ===============
vim.cmd("colorscheme everforest")
require("nvim-tree").setup()
require("lualine").setup()

-- =============== TREESITTER ===============
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "lua", "python", "vim", "bash", "json" },
  highlight = { enable = true },
})

-- =============== AUTOCOMPLETE (nvim-cmp) ===============
local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert(),
  sources = { { name = "nvim_lsp" },
              { name = "latex_symbols" },
            }
})

-- =============== LSP (FIXED NATIVE API) ===============
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function start_lsp(server)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = server.filetypes,
    callback = function()
      vim.lsp.start({
        name = server.name,
        cmd = server.cmd,
        root_dir = vim.fs.root(0, server.root_files),
        capabilities = capabilities,
        settings = server.settings
      })
    end,
  })
end

-- Servers
start_lsp({
  name = "clangd",
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_files = { "compile_commands.json", ".git" },
})

start_lsp({
  name = "pyright",
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_files = { "pyproject.toml", "setup.py", ".git" },
})

start_lsp({
  name = "lua_ls",
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_files = { ".luarc.json", ".git" },
  settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})

-- LSP Keybinds only when active
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buf })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = buf })
    vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { buffer = buf })
    vim.keymap.set("n", "<F3>", vim.lsp.buf.code_action, { buffer = buf })
    vim.keymap.set("n", "<F4>", function() vim.lsp.buf.format { async = true } end, { buffer = buf })
  end,
})

-- =============== KEYBINDS ===============
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")

-- Open NvimTree on startup if no file is opened
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    -- buffer is a real file → do nothing
    if vim.fn.isdirectory(data.file) == 0 and data.file ~= "" then
      return
    end
    -- open tree
    require("nvim-tree.api").tree.open()
  end
})

-- Force Ctrl+n to toggle NvimTree even if plugins interfere
vim.keymap.set("n", "<C-n>", function()
  require("nvim-tree.api").tree.toggle()
end, {})

