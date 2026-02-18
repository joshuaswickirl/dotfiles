-- init.lua — Neovim configuration (kickstart-inspired)

-- ── Leader key ─────────────────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Options ────────────────────────────────────────────────────────
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.breakindent = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- ── Keymaps ────────────────────────────────────────────────────────
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

-- ── Yank highlight ─────────────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- ── Compat shim (Telescope uses removed Treesitter API) ───────────
if not vim.treesitter.language.ft_to_lang then
  vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang
end

-- ── Bootstrap lazy.nvim ────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
  end
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugins ────────────────────────────────────────────────────────
require("lazy").setup({

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      require("telescope").setup({})
      pcall(require("telescope").load_extension, "fzf")
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Grep word" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume search" })
      vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = "Recent files" })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
      vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeToggle<CR>", { desc = "File explorer" })
    end,
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {},
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "bash", "lua", "python", "vim", "vimdoc", "markdown", "json", "yaml" },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "-" },
        changedelete = { text = "~" },
      },
    },
  },

  -- Mini.nvim collection
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.base16").setup({
        palette = {
          base00 = "#242424", -- background
          base01 = "#2e2e2e", -- lighter bg (status bars, line numbers)
          base02 = "#3a3a3a", -- selection
          base03 = "#524e45", -- comments
          base04 = "#a0a0a0", -- dark foreground (status bars)
          base05 = "#e8e8e8", -- foreground
          base06 = "#f7f6f3", -- light foreground
          base07 = "#fff8e7", -- lightest (cosmic latte)
          base08 = "#e83b35", -- red (variables, tags)
          base09 = "#ed935f", -- orange (constants, booleans)
          base0A = "#edc25f", -- yellow (classes, search)
          base0B = "#22bd5b", -- green (strings)
          base0C = "#35b2e8", -- cyan (regex, escape chars)
          base0D = "#356be8", -- blue (functions)
          base0E = "#7735e8", -- violet (keywords)
          base0F = "#e87735", -- orange (embedded tags)
        },
      })
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup()
      require("mini.statusline").setup()
    end,
  },
})
