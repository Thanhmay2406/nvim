local pack = require("config.pack")

pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

local treesitter_languages = {
  "lua",
  "vim",
  "vimdoc",
  "c",
  "cpp",
  "python",
  "javascript",
  "typescript",
  "html",
  "css",
  "json",
  "markdown",
  "markdown_inline",
  "yaml",
  "latex",
}

local has_treesitter, treesitter = pcall(require, "nvim-treesitter")
if has_treesitter then
  treesitter.setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
  })

  vim.api.nvim_create_user_command("TSInstallConfigured", function()
    treesitter.install(treesitter_languages)
  end, { desc = "Install configured Treesitter parsers" })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = treesitter_languages,
    callback = function()
      pcall(vim.treesitter.start)
    end,
  })
end
