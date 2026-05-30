> my nvim configuration

## Structure

```text
init.lua
lua/config/
  globals.lua
  options.lua
  diagnostics.lua
  keymaps.lua
  pack.lua
  plugins/
    colorscheme.lua
    completion.lua
    lsp.lua
    telescope.lua
    treesitter.lua
    which-key.lua
```

`init.lua` only loads modules. Core editor behavior lives in `lua/config/`,
while plugin installation and setup lives in `lua/config/plugins/`.

## Requirements

- Neovim with `vim.pack`
- `git`
- `ripgrep`
- A clipboard tool such as `xclip`, `xsel`, or `win32yank`
- A Nerd Font in the terminal
