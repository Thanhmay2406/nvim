---@diagnostic disable: missing-fields

-- INFO: introduction
-- this is a minimal neovim configuration written in lua. this is not meant to
-- be a distribution, but rather a template for you to build upon and/or a
-- reference for how to configure neovim using lua in the latest version.
--
-- TUTOR:
-- if you're completely new to neovim and/or vim, consider going through
-- `:Tutor` inside neovim to get a basic idea of how it works.
--     if you don't know what this means, type the following:
--       - <escape key>
--       - :
--       - Tutor
--       - <enter key>
--
-- LUA:
-- some level of familiarity with lua/programming languages are also expected.
-- if you're new to lua, consider going through the official reference:
--    https://www.lua.org/manual
-- or a more friendly tutorial like:
--    https://learnxinyminutes.com/docs/lua/
-- you can also check out `:h lua-guide` inside neovim for a neovim-specific
-- lua guide.
--
-- DEPENDENCIES:
-- this configuration assumes you have the following tools installed on your
-- system:
--    `git` - for vim builtin package manager. (see `:h vim.pack`)
--    `ripgrep` - for fuzzy finding
--    clipboard tool: xclip/xsel/win32yank - for clipboard sharing between OS and neovim (see `h: clipboard-tool`)
--    a nerdfont (ensure the terminal running neovim is using it)
-- run `:checkhealth` inside neovim to see if your system is missing anything.
--
-- MINIMAL:
-- to say that something is 'minimal' you have to define what variable you're
-- minimizing. this configuration minimizes for lines of code and concepts.
-- to some, this configuration may have too many plugins. for example, using
-- mason.nvim to manage lsp servers will be an unnecessary dependency if the
-- user is already familiar with lsps and is comfortable managing them through
-- their OS package manager. but to someone that isn't familiar with lsp servers
-- this approach wouldn't cover everything needed to have the 'minimum' necessary
-- for lsp + completion + fuzzy finding. to some, fuzzy finding is also a bloated
-- dependency.
-- this configuration is only a starting point/reference. it is expected that
-- the user will change the configuration to suit their needs.


-- INFO: options
-- these change the default neovim behaviours using the 'vim.opt' API.
-- see `:h vim.opt` for more details.
-- run `:h '{option_name}'` to see what they do and what values they can take.
-- for example, `:h 'number'` for `vim.opt.number`.

-- set <space> as the leader key
-- must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function add_plugins(specs)
  local ok, err = pcall(vim.pack.add, specs, { confirm = false, load = true })
  if not ok then
    vim.notify(("Failed to install/load plugin(s): %s"):format(err), vim.log.levels.ERROR)
  end
  return ok
end

-- enable true color support
vim.opt.termguicolors = true

-- make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- enable mouse mode, can be useful for resizing splits
vim.opt.mouse = "a"

-- sync clipboard between OS and neovim.
--  remove this option if you want your OS clipboard to remain independent.
--  see `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"

-- save undo history
vim.opt.undofile = true

-- keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- sets how neovim will display certain whitespace characters in the editor.
--  see `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", }

-- enable live preview of substitutions
vim.opt.inccommand = "split"

-- show which line your cursor is on
vim.opt.cursorline = true

-- set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

-- enable break indent
vim.opt.breakindent = true

-- enable line wrapping
vim.opt.wrap = true

-- formatting
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.textwidth = 80

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  virtual_text = true, -- show inline diagnostics
})

-- clear search highlights with <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- INFO: colorscheme
add_plugins({ { src = "https://github.com/catppuccin/nvim", name = "catppuccin" }, })

if not pcall(vim.cmd.colorscheme, "catppuccin") then
  pcall(vim.cmd.colorscheme, "habamax")
end

-- INFO: plugins
-- we install plugins with neovim's builtin package manager: vim.pack
-- and then enable/configure them by calling their setup functions.
--
-- (see `:h vim.pack` for more details on how it works)
-- you can press `gx` on any of the plugin urls below to open them in your
-- browser and check out their documentation and functionality.
-- alternatively, you can run `:h {plugin-name}` to read their documentation.
--
-- plugins are then loaded and configured with a call to `setup` functions
-- provided by each plugin. this is not a rule of neovim but rather a convention
-- followed by the community.
-- these setup calls take a table as an agument and their expected contents can
-- vary wildly. refer to each plugin's documentation for details.

-- INFO: formatting and syntax highlighting
add_plugins({ "https://github.com/nvim-treesitter/nvim-treesitter" })

-- equivalent to :TSUpdate
-- require("nvim-treesitter.install").update("all")
--
-- require("nvim-treesitter.configs").setup({
--   auto_install = true, -- autoinstall languages that are not installed yet
-- })

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

-- INFO: completion engine
add_plugins({
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
})

local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
  blink.setup({
    completion = {
      documentation = {
        auto_show = true,
      },
    },

    -- default blink keymaps
    keymap = {
      ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
      ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

      ['<C-y>'] = { 'select_and_accept', 'fallback' },
      ['<C-e>'] = { 'cancel', 'fallback' },
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },

      ['<Tab>'] = { 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

      ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },

    fuzzy = {
      implementation = "lua",
    },
  })
end

-- INFO: lsp server installation and configuration

-- lsp servers we want to use and their configuration
-- see `:h lspconfig-all` for available servers and their settings
local lsp_servers = {
  lua_ls = {
    -- https://luals.github.io/wiki/settings/ | `:h nvim_get_runtime_file`
    Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true) }, },
  },
  clangd = {},
  rust_analyzer = {},
  gopls = {},
}

add_plugins({
  "https://github.com/neovim/nvim-lspconfig", -- default configs for lsps

  -- NOTE: if you'd rather install the lsps through your OS package manager you
  -- can delete the next three mason-related lines and their setup calls below.
  -- see `:h lsp-quickstart` for more details.
  "https://github.com/mason-org/mason.nvim",                     -- package manager
  "https://github.com/mason-org/mason-lspconfig.nvim",           -- lspconfig bridge
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" -- auto installer
})

pcall(function() require("mason").setup() end)
pcall(function() require("mason-lspconfig").setup() end)
pcall(function()
  require("mason-tool-installer").setup({
    ensure_installed = vim.tbl_keys(lsp_servers),
  })
end)

local capabilities = vim.lsp.protocol.make_client_capabilities()
if has_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- configure each lsp server on the table
-- to check what clients are attached to the current buffer, use
-- `:checkhealth vim.lsp`. to view default lsp keybindings, use `:h lsp-defaults`.
for server, config in pairs(lsp_servers) do
  vim.lsp.config(server, {
    capabilities = capabilities,
    settings = config,

    -- only create the keymaps if the server attaches successfully
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "grd", vim.lsp.buf.definition,
        { buffer = bufnr, desc = "vim.lsp.buf.definition()", })

      vim.keymap.set("n", "grf", vim.lsp.buf.format,
        { buffer = bufnr, desc = "vim.lsp.buf.format()", })
    end,
  })

  vim.lsp.enable(server)
end

-- INFO: fuzzy finder
add_plugins({
  "https://github.com/nvim-lua/plenary.nvim",        -- library dependency
  "https://github.com/nvim-tree/nvim-web-devicons",  -- icons (nerd font)
  "https://github.com/nvim-telescope/telescope.nvim" -- the fuzzy finder
})

local has_telescope, telescope = pcall(require, "telescope")
if has_telescope then
  telescope.setup({})
end

local has_pickers, pickers = pcall(require, "telescope.builtin")

if has_pickers then
  vim.keymap.set("n", "<leader>sp", pickers.builtin, { desc = "[S]earch Builtin [P]ickers", })
  vim.keymap.set("n", "<leader>sb", pickers.buffers, { desc = "[S]earch [B]uffers", })
  vim.keymap.set("n", "<leader>sf", pickers.find_files, { desc = "[S]earch [F]iles", })
  vim.keymap.set("n", "<leader>sw", pickers.grep_string, { desc = "[S]earch Current [W]ord", })
  vim.keymap.set("n", "<leader>sg", pickers.live_grep, { desc = "[S]earch by [G]rep", })
  vim.keymap.set("n", "<leader>sr", pickers.resume, { desc = "[S]earch [R]esume", })

  vim.keymap.set("n", "<leader>sh", pickers.help_tags, { desc = "[S]earch [H]elp", })
  vim.keymap.set("n", "<leader>sm", pickers.man_pages, { desc = "[S]earch [M]anuals", })
end

-- INFO: keybinding helper
add_plugins({ "https://github.com/folke/which-key.nvim" })

local has_which_key, which_key = pcall(require, "which-key")
if has_which_key then
  which_key.setup({
    spec = {
      { "<leader>s", group = "[S]earch", icon = { icon = "", color = "green", }, },
    }
  })
end

-- uncomment to enable automatic plugin updates
-- vim.pack.update()
