return {
  "CRAG666/code_runner.nvim",
  keys = {
    {
      "<leader>r", -- 1. Đây là phím tắt: Bấm Leader + r để chạy
      ":RunCode<CR>", -- 2. Đây là lệnh: Gọi RunCode
      desc = "Run Code",
    },
  },
  opts = {
    mode = "float",
    float = {
      close_key = "<ESC>",
      border = "rounded",
      height = 0.8,
      width = 0.8,
      x = 0.5,
      y = 0.5,
    },
    filetype = {
      cpp = {
        "cd $dir &&",
        -- Lệnh biên dịch: g++ -o <tên file> <tên file cpp>
        "g++ -o $fileNameWithoutExt $fileName &&",
        -- Chạy file
        "./$fileNameWithoutExt",
      },
    },
  },
}
