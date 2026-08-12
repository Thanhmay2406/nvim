local pack = require("config.pack")

local lsp_servers = {
  lua_ls = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file("lua", true),
      },
    },
  },
  pyright = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
  clangd = {},
  rust_analyzer = {},
  gopls = {},
  marksman = {},
}

local cpp_include_dirs = {
  vim.fn.expand("~/School/competitive_programming"),
  "/usr/local/include",
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
  local server_config = {
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
  }

  if server == "clangd" then
    local fallback_flags = { "-std=c++20" }
    for _, include_dir in ipairs(cpp_include_dirs) do
      if vim.fn.isdirectory(include_dir) == 1 then
        table.insert(fallback_flags, "-I" .. include_dir)
      end
    end

    server_config.cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--query-driver=/usr/bin/g++,/usr/bin/gcc,/usr/local/bin/g++,/usr/local/bin/gcc",
    }
    server_config.init_options = {
      fallbackFlags = fallback_flags,
    }
  end

  vim.lsp.config(server, server_config)

  vim.lsp.enable(server)
end
