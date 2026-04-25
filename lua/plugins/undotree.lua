return {
  {
    "mbbill/undotree",
    keys = {
      { "<leader>uT", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree" },
    },
    init = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SplitWidth = 35
      vim.g.undotree_DiffpanelHeight = 12
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
}
