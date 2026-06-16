local pack = require("config.pack")

pack.add({
  -- { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  { src = "https://github.com/ellisonleao/gruvbox.nvim", name = "gruvbox.nvim" },
})

-- local has_catppuccin, catppuccin = pcall(require, "catppuccin")
-- local function setup_catppuccin()
--   catppuccin.setup({
--     flavour = "mocha",
--     transparent_background = true,
--     integrations = {
--       telescope = true,
--       treesitter = true,
--       native_lsp = {
--         enabled = true,
--       },
--     },
--   })
-- end

local has_gruvbox, gruvbox = pcall(require, "gruvbox")
local transparent_background = false

local function setup_gruvbox()
  vim.o.background = "light"
  gruvbox.setup({
    contrast = "soft",
    transparent_mode = transparent_background,
  })
end

if has_gruvbox then
  setup_gruvbox()

  vim.keymap.set("n", "<leader>tt", function()
    transparent_background = not transparent_background
    setup_gruvbox()
    vim.cmd.colorscheme("gruvbox")
    vim.notify(("Transparent background: %s"):format(transparent_background and "enabled" or "disabled"))
  end, { desc = "[T]oggle [T]ransparent background" })
end

if not pcall(vim.cmd.colorscheme, "gruvbox") then
  pcall(vim.cmd.colorscheme, "habamax")
end
