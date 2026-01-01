return {
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    priority = 1000,
    opts = {
      transparent = true, -- Giữ trong suốt
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      -- 1. Setup Tokyonight
      require("tokyonight").setup(opts)

      -- 2. Danh sách theme (đã bỏ accent)
      local themes = {
        "tokyonight",
        "catppuccin",
        "rose-pine",
      }
      local current_theme_index = 1

      -- Set theme mặc định
      vim.cmd.colorscheme(themes[current_theme_index])

      -- Key mapping chuyển theme
      vim.keymap.set("n", "<leader>nt", function()
        current_theme_index = current_theme_index + 1
        if current_theme_index > #themes then
          current_theme_index = 1
        end
        local theme = themes[current_theme_index]
        vim.cmd.colorscheme(theme)
        print("Changed nvim theme to: " .. theme)
      end, { noremap = true, silent = true })
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 800,
    opts = {
      transparent_background = true, -- Giữ trong suốt
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
      styles = {
        transparency = true, -- Giữ trong suốt
      },
    },
  },
}
