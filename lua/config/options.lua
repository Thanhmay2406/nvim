-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.tabstop = 4 -- Số lượng khoảng trắng cho 1 tab
vim.opt.shiftwidth = 4 -- Số lượng khoảng trắng khi thụt đầu dòng (indent)
vim.opt.expandtab = true -- Chuyển đổi tab thành khoảng trắng
vim.opt.softtabstop = 4 -- Số lượng khoảng trắng khi nhấn Tab hoặc Backspace

-- tắt hiệu ứng con trỏ chuột
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_size = 0
