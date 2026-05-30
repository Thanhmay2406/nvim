-- Enable true color support.
vim.opt.termguicolors = true

-- Make line numbers default.
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, useful for resizing splits.
vim.opt.mouse = "a"

-- Sync clipboard between OS and Neovim.
vim.opt.clipboard = "unnamedplus"

-- Save undo history.
vim.opt.undofile = true

-- Keep signcolumn on by default.
vim.opt.signcolumn = "yes"

-- Display whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Enable live preview of substitutions.
vim.opt.inccommand = "split"

-- Show which line your cursor is on.
vim.opt.cursorline = true

-- Set highlight on search, cleared by <Esc> in normal mode.
vim.opt.hlsearch = true

-- Indentation and wrapping.
vim.opt.breakindent = true
vim.opt.wrap = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.textwidth = 80
