---@diagnostic disable: missing-fields

require("config.globals")
require("config.options")
require("config.diagnostics")
require("config.keymaps")

require("config.plugins.colorscheme")
require("config.plugins.treesitter")
require("config.plugins.markdown")
require("config.plugins.notebook")
require("config.plugins.autopairs")
require("config.plugins.completion")
require("config.plugins.lsp")
require("config.plugins.telescope")
require("config.plugins.which-key")

-- Uncomment to enable automatic plugin updates.
-- vim.pack.update()
