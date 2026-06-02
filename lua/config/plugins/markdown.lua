local pack = require("config.pack")

pack.add({
  "https://github.com/folke/snacks.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
})

if not vim.env.PUPPETEER_EXECUTABLE_PATH then
  for _, browser in ipairs({ "google-chrome-stable", "google-chrome", "chromium", "chromium-browser" }) do
    local path = vim.fn.exepath(browser)
    if path ~= "" then
      vim.env.PUPPETEER_EXECUTABLE_PATH = path
      break
    end
  end
end

pcall(function()
  require("snacks").setup({
    image = {},
  })
end)

pcall(function()
  require("render-markdown").setup({
    latex = {
      enabled = false,
    },
  })
end)
