-- Set <space> as the leader key.
-- Must happen before plugins are loaded.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local python_host = vim.fn.stdpath("config") .. "/.venv-nvim/bin/python"
if vim.fn.executable(python_host) == 1 then
  vim.g.python3_host_prog = python_host
end
