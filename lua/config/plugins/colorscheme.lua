local pack = require("config.pack")

pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

local has_catppuccin, catppuccin = pcall(require, "catppuccin")
local transparent_background = true

local function setup_catppuccin()
  catppuccin.setup({
    flavour = "mocha",
    transparent_background = transparent_background,

    integrations = {
      telescope = true,
      treesitter = true,
      native_lsp = {
        enabled = true,
      },
    },
  })
end

if has_catppuccin then
  setup_catppuccin()

  vim.keymap.set("n", "<leader>tt", function()
    transparent_background = not transparent_background
    setup_catppuccin()
    vim.cmd.colorscheme("catppuccin")
    vim.notify(("Transparent background: %s"):format(transparent_background and "enabled" or "disabled"))
  end, { desc = "[T]oggle [T]ransparent background" })
end

if not pcall(vim.cmd.colorscheme, "catppuccin") then
  pcall(vim.cmd.colorscheme, "habamax")
end
