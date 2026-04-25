return {
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    priority = 1000,
    config = function()
      -- ========================
      -- STATE
      -- ========================
      local themes = {
        "tokyonight",
        "catppuccin",
        "rose-pine",
      }
      local current_theme_index = 2
      local is_transparent = true

      -- ========================
      -- APPLY THEME FUNCTION
      -- ========================
      local function apply_theme(theme)
        -- Tokyonight
        require("tokyonight").setup({
          transparent = is_transparent,
          styles = {
            sidebars = is_transparent and "transparent" or "dark",
            floats = is_transparent and "transparent" or "dark",
          },
        })

        -- Catppuccin
        require("catppuccin").setup({
          transparent_background = is_transparent,
          integrations = {
            treesitter = true,
            native_lsp = { enabled = true },
          },
          highlight_overrides = {
            all = function()
              return {
                Normal = { bg = is_transparent and "NONE" or nil },
                NormalFloat = { bg = is_transparent and "NONE" or nil },
              }
            end,
          },
        })

        -- Rose Pine
        require("rose-pine").setup({
          styles = {
            transparency = is_transparent,
          },
        })

        -- Apply colorscheme
        vim.cmd.colorscheme(theme)
      end

      -- ========================
      -- INIT
      -- ========================
      apply_theme(themes[current_theme_index])

      -- ========================
      -- KEYMAP: SWITCH THEME
      -- ========================
      vim.keymap.set("n", "<leader>nt", function()
        current_theme_index = current_theme_index + 1
        if current_theme_index > #themes then
          current_theme_index = 1
        end

        local theme = themes[current_theme_index]
        apply_theme(theme)

        print("Theme: " .. theme)
      end, { noremap = true, silent = true })

      -- ========================
      -- KEYMAP: TOGGLE TRANSPARENCY
      -- ========================
      vim.keymap.set("n", "<leader>tt", function()
        is_transparent = not is_transparent

        local theme = themes[current_theme_index]
        apply_theme(theme)

        print("Transparency: " .. (is_transparent and "ON" or "OFF"))
      end, { noremap = true, silent = true })
    end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 800,
    lazy = false,
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 900,
  },
}
