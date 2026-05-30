local pack = require("config.pack")

pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

local has_catppuccin, catppuccin = pcall(require, "catppuccin")

if has_catppuccin then
  catppuccin.setup({
    flavour = "mocha",
    transparent_background = true,

    integrations = {
      telescope = true,
      treesitter = true,
      native_lsp = {
        enabled = true,
      },
    },
  })
end

if not pcall(vim.cmd.colorscheme, "catppuccin") then
  pcall(vim.cmd.colorscheme, "habamax")
end
