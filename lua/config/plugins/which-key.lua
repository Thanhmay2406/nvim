local pack = require("config.pack")

pack.add({
  "https://github.com/folke/which-key.nvim",
})

local has_which_key, which_key = pcall(require, "which-key")
if has_which_key then
  which_key.setup({
    plugins = {
      presets = {
        z = false,
      },
    },
    spec = {
      { "<leader>j", group = "[J]upyter", icon = { icon = "󰠮", color = "yellow" } },
      { "<leader>s", group = "[S]earch", icon = { icon = "", color = "green" } },
    },
  })
end
