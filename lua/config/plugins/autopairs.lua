local pack = require("config.pack")

pack.add({
  "https://github.com/windwp/nvim-autopairs",
})

local has_autopairs, autopairs = pcall(require, "nvim-autopairs")
if has_autopairs then
  autopairs.setup({})
end
