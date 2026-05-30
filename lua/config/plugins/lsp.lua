local pack = require("config.pack")

local lsp_servers = {
  lua_ls = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file("lua", true),
      },
    },
  },
  clangd = {},
  rust_analyzer = {},
  gopls = {},
}

pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
})

pcall(function()
  require("mason").setup()
end)

pcall(function()
  require("mason-lspconfig").setup()
end)

pcall(function()
  require("mason-tool-installer").setup({
    ensure_installed = vim.tbl_keys(lsp_servers),
  })
end)

local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

for server, config in pairs(lsp_servers) do
  vim.lsp.config(server, {
    capabilities = capabilities,
    settings = config,

    on_attach = function(_, bufnr)
      vim.keymap.set("n", "grd", vim.lsp.buf.definition, {
        buffer = bufnr,
        desc = "vim.lsp.buf.definition()",
      })

      vim.keymap.set("n", "grf", vim.lsp.buf.format, {
        buffer = bufnr,
        desc = "vim.lsp.buf.format()",
      })
    end,
  })

  vim.lsp.enable(server)
end
