local pack = require("config.pack")

pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

local has_catppuccin, catppuccin = pcall(require, "catppuccin")
local transparent_background = false
local forced_background = vim.g.theme_background
local sync_with_kitty = vim.g.theme_sync_with_kitty ~= false

local function normalize_hex(hex)
  if not hex then
    return nil
  end

  hex = hex:lower()
  if hex:match("^#%x%x%x%x%x%x$") then
    return hex
  end

  return nil
end

local function hex_to_rgb(hex)
  hex = normalize_hex(hex)
  if not hex then
    return nil
  end

  local r, g, b = hex:match("^#(%x%x)(%x%x)(%x%x)$")
  return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
end

local function blend(foreground, background, alpha)
  local fr, fg, fb = hex_to_rgb(foreground)
  local br, bg, bb = hex_to_rgb(background)
  if not fr or not br then
    return foreground or background
  end

  local function channel(fg_channel, bg_channel)
    return math.floor((alpha * fg_channel) + ((1 - alpha) * bg_channel) + 0.5)
  end

  return string.format("#%02x%02x%02x", channel(fr, br), channel(fg, bg), channel(fb, bb))
end

local function hex_to_background(hex)
  local r, g, b = hex_to_rgb(hex)
  if not r then
    return nil
  end

  local luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  return luminance >= 0.6 and "light" or "dark"
end

local function read_file_lines(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end

  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  return lines
end

local function detect_kitty_background_from_file(path, visited)
  visited = visited or {}
  path = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  if path == "" or visited[path] then
    return nil
  end
  visited[path] = true

  local lines = read_file_lines(path)
  if not lines then
    return nil
  end

  local detected_background
  local base_dir = vim.fn.fnamemodify(path, ":h")

  for _, line in ipairs(lines) do
    local clean = vim.trim(line)
    if clean:match("^#") then
      clean = ""
    end

    if clean ~= "" then
      local include_target = clean:match("^include%s+(.+)$")
      if include_target then
        local include_path = vim.fn.fnamemodify(base_dir .. "/" .. vim.trim(include_target), ":p")
        local include_background = detect_kitty_background_from_file(include_path, visited)
        if include_background then
          detected_background = include_background
        end
      end

      local background_hex = clean:match("^background%s+(#%x%x%x%x%x%x)$")
      if background_hex then
        local background = hex_to_background(background_hex)
        if background then
          detected_background = background
        end
      end
    end
  end

  return detected_background
end

local function parse_kitty_palette_from_file(path, visited)
  visited = visited or {}
  path = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  if path == "" or visited[path] then
    return nil
  end
  visited[path] = true

  local lines = read_file_lines(path)
  if not lines then
    return nil
  end

  local palette = {}
  local base_dir = vim.fn.fnamemodify(path, ":h")

  for _, line in ipairs(lines) do
    local clean = vim.trim(line)
    if not clean:match("^#") and clean ~= "" then
      local include_target = clean:match("^include%s+(.+)$")
      if include_target then
        local include_path = vim.fn.fnamemodify(base_dir .. "/" .. vim.trim(include_target), ":p")
        local include_palette = parse_kitty_palette_from_file(include_path, visited)
        if include_palette then
          palette = vim.tbl_extend("force", palette, include_palette)
        end
      else
        local key, value = clean:match("^(%S+)%s+(#%x%x%x%x%x%x)")
        value = normalize_hex(value)
        if key and value then
          palette[key] = value
        end
      end
    end
  end

  return next(palette) and palette or nil
end

local function is_kitty()
  return vim.env.KITTY_WINDOW_ID or vim.env.TERM == "xterm-kitty"
end

local function detect_kitty_palette()
  if not is_kitty() then
    return nil
  end

  return parse_kitty_palette_from_file("~/.config/kitty/kitty.conf")
end

local function detect_kitty_background()
  local palette = detect_kitty_palette()
  if palette and palette.background then
    return hex_to_background(palette.background)
  end

  if not is_kitty() then
    return nil
  end

  return detect_kitty_background_from_file("~/.config/kitty/kitty.conf")
end

local function detect_terminal_background()
  if forced_background == "light" or forced_background == "dark" then
    return forced_background
  end

  local env_background = vim.env.NVIM_THEME_BACKGROUND
  if env_background == "light" or env_background == "dark" then
    return env_background
  end

  local kitty_background = detect_kitty_background()
  if kitty_background then
    return kitty_background
  end

  local colorfgbg = vim.env.COLORFGBG
  if not colorfgbg or colorfgbg == "" then
    return "dark"
  end

  local parts = vim.split(colorfgbg, ";", { plain = true, trimempty = true })
  local bg = tonumber(parts[#parts])
  if not bg then
    return "dark"
  end

  if bg >= 0 and bg <= 6 then
    return "dark"
  end

  if bg >= 7 and bg <= 15 then
    return "light"
  end

  return "dark"
end

local function apply_kitty_palette_overrides()
  if not sync_with_kitty then
    return
  end

  local palette = detect_kitty_palette()
  if not palette or not palette.foreground or not palette.background then
    return
  end

  local bg = transparent_background and "none" or palette.background
  local subtle_bg = blend(palette.foreground, palette.background, vim.o.background == "light" and 0.08 or 0.12)
  local active_bg = blend(palette.foreground, palette.background, vim.o.background == "light" and 0.14 or 0.18)
  local border = palette.color8 or blend(palette.foreground, palette.background, 0.35)
  local muted = palette.color8 or blend(palette.foreground, palette.background, 0.55)
  local selection = palette.selection_background or active_bg
  local selection_fg = palette.selection_foreground or palette.foreground

  local highlights = {
    Normal = { fg = palette.foreground, bg = bg },
    NormalNC = { fg = palette.foreground, bg = bg },
    SignColumn = { fg = palette.foreground, bg = bg },
    EndOfBuffer = { fg = muted, bg = bg },
    LineNr = { fg = muted, bg = bg },
    CursorLine = { bg = subtle_bg },
    CursorLineNr = { fg = palette.color3 or palette.foreground, bg = subtle_bg, bold = true },
    Visual = { fg = selection_fg, bg = selection },
    Search = { fg = palette.background, bg = palette.color3 or selection },
    IncSearch = { fg = palette.background, bg = palette.color1 or selection },
    CurSearch = { fg = palette.background, bg = palette.color1 or selection },
    Cursor = { fg = palette.cursor_text_color or palette.background, bg = palette.cursor or palette.foreground },
    TermCursor = { fg = palette.cursor_text_color or palette.background, bg = palette.cursor or palette.foreground },
    ColorColumn = { bg = subtle_bg },
    Pmenu = { fg = palette.foreground, bg = subtle_bg },
    PmenuSel = { fg = selection_fg, bg = selection },
    NormalFloat = { fg = palette.foreground, bg = subtle_bg },
    FloatBorder = { fg = border, bg = subtle_bg },
    WinSeparator = { fg = border, bg = bg },
    StatusLine = { fg = palette.foreground, bg = active_bg },
    StatusLineNC = { fg = muted, bg = subtle_bg },
    VertSplit = { fg = border, bg = bg },
    TabLine = { fg = muted, bg = subtle_bg },
    TabLineSel = { fg = palette.foreground, bg = active_bg },
    TabLineFill = { bg = bg },
    Folded = { fg = muted, bg = subtle_bg },
    FoldColumn = { fg = muted, bg = bg },
    Directory = { fg = palette.color4 or palette.foreground },
    Comment = { fg = muted, italic = true },
    Constant = { fg = palette.color5 or palette.foreground },
    String = { fg = palette.color2 or palette.foreground },
    Character = { fg = palette.color2 or palette.foreground },
    Number = { fg = palette.color5 or palette.foreground },
    Boolean = { fg = palette.color5 or palette.foreground },
    Identifier = { fg = palette.color4 or palette.foreground },
    Function = { fg = palette.color4 or palette.foreground },
    Statement = { fg = palette.color1 or palette.foreground },
    Keyword = { fg = palette.color1 or palette.foreground },
    PreProc = { fg = palette.color3 or palette.foreground },
    Type = { fg = palette.color2 or palette.foreground },
    Special = { fg = palette.color6 or palette.foreground },
    Underlined = { fg = palette.color4 or palette.foreground, underline = true },
    Error = { fg = palette.color1 or palette.foreground },
    Todo = { fg = palette.background, bg = palette.color3 or palette.foreground, bold = true },
    DiagnosticError = { fg = palette.color1 or palette.foreground },
    DiagnosticWarn = { fg = palette.color3 or palette.foreground },
    DiagnosticInfo = { fg = palette.color4 or palette.foreground },
    DiagnosticHint = { fg = palette.color6 or palette.foreground },
  }

  for group, spec in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

local function apply_terminal_background_overrides()
  if not transparent_background then
    return
  end

  local groups = {
    "Normal",
    "NormalNC",
    "SignColumn",
    "EndOfBuffer",
    "LineNr",
    "CursorLineNr",
    "FoldColumn",
    "NormalFloat",
    "FloatBorder",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

local function setup_catppuccin()
  local background = detect_terminal_background()
  vim.o.background = background

  catppuccin.setup({
    flavour = "auto",
    background = {
      light = "latte",
      dark = "mocha",
    },
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
  local function apply_colorscheme()
    setup_catppuccin()
    vim.cmd.colorscheme("catppuccin")
    apply_kitty_palette_overrides()
    apply_terminal_background_overrides()
  end

  apply_colorscheme()

  vim.keymap.set("n", "<leader>tt", function()
    transparent_background = not transparent_background
    vim.g.theme_transparent_background = transparent_background
    apply_colorscheme()
    vim.notify(("Transparent background: %s"):format(transparent_background and "enabled" or "disabled"))
  end, { desc = "[T]oggle [T]ransparent background" })

  vim.api.nvim_create_user_command("ThemeSyncTerminal", function()
    forced_background = nil
    vim.g.theme_background = nil
    sync_with_kitty = true
    vim.g.theme_sync_with_kitty = true
    apply_colorscheme()
    vim.notify(("Theme synced to terminal background: %s"):format(vim.o.background))
  end, { desc = "Sync Neovim theme with terminal background" })

  vim.api.nvim_create_user_command("ThemeLight", function()
    forced_background = "light"
    vim.g.theme_background = forced_background
    sync_with_kitty = false
    vim.g.theme_sync_with_kitty = false
    apply_colorscheme()
    vim.notify("Theme forced to light (latte)")
  end, { desc = "Force Catppuccin latte" })

  vim.api.nvim_create_user_command("ThemeDark", function()
    forced_background = "dark"
    vim.g.theme_background = forced_background
    sync_with_kitty = false
    vim.g.theme_sync_with_kitty = false
    apply_colorscheme()
    vim.notify("Theme forced to dark (mocha)")
  end, { desc = "Force Catppuccin mocha" })

  vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
    group = vim.api.nvim_create_augroup("ThemeSyncKitty", { clear = true }),
    callback = function()
      if sync_with_kitty and not forced_background then
        apply_colorscheme()
      end
    end,
    desc = "Resync Neovim colors from Kitty when returning to the editor",
  })

  vim.keymap.set("n", "<leader>ts", "<cmd>ThemeSyncTerminal<cr>", { desc = "[T]heme [S]ync with terminal" })
  vim.keymap.set("n", "<leader>tl", "<cmd>ThemeLight<cr>", { desc = "[T]heme [L]ight" })
  vim.keymap.set("n", "<leader>td", "<cmd>ThemeDark<cr>", { desc = "[T]heme [D]ark" })
else
  pcall(vim.cmd.colorscheme, "habamax")
end
