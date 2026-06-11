local pack = require("config.pack")

pack.add({
  "https://github.com/3rd/image.nvim",
  "https://github.com/benlubas/molten-nvim",
})

local notebook_venv = vim.fn.stdpath("config") .. "/.venv-nvim/bin"

vim.g.molten_auto_open_output = false
vim.g.molten_auto_init_behavior = "init"
vim.g.molten_cover_empty_lines = true
vim.g.molten_cover_lines_starting_with = { "# %%" }
vim.g.molten_enter_output_behavior = "open_then_enter"
vim.g.molten_image_provider = "image.nvim"
vim.g.molten_output_crop_border = true
vim.g.molten_output_show_more = true
vim.g.molten_output_virt_lines = true
vim.g.molten_output_win_max_height = 20
vim.g.molten_output_win_max_width = 120
vim.g.molten_virt_text_output = true
vim.g.molten_wrap_output = true

pcall(function()
  require("image").setup({
    backend = "kitty",
    processor = "magick_cli",
    integrations = {
      markdown = {
        enabled = false,
      },
      neorg = {
        enabled = false,
      },
      html = {
        enabled = false,
      },
      css = {
        enabled = false,
      },
    },
    max_width = 100,
    max_height = 24,
    max_width_window_percentage = math.huge,
    max_height_window_percentage = math.huge,
    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
  })
end)

local function notify_result(title, result)
  local level = result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
  local lines = vim.split(vim.trim(result.stdout .. "\n" .. result.stderr), "\n", { trimempty = true })
  local message = #lines > 0 and table.concat(lines, "\n") or title
  vim.schedule(function()
    vim.notify(message, level, { title = title })
  end)
end

local function current_file_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Buffer chưa có file trên đĩa.", vim.log.levels.WARN)
    return nil
  end

  return path
end

local function notebook_executable(name)
  local local_path = notebook_venv .. "/" .. name
  if vim.fn.executable(local_path) == 1 then
    return local_path
  end

  if vim.fn.executable(name) == 1 then
    return name
  end

  return nil
end

local function run_jupytext(args, title)
  local jupytext = notebook_executable("jupytext")
  if not jupytext then
    vim.notify("Không tìm thấy lệnh jupytext. Hãy cài nó trước.", vim.log.levels.ERROR)
    return
  end

  local path = current_file_path()
  if not path then
    return
  end

  local cmd = vim.list_extend({ jupytext }, args)
  table.insert(cmd, path)

  vim.system(cmd, { text = true }, function(result)
    notify_result(title, result)
  end)
end

local function is_cell_marker(line)
  return line:match("^%s*# %%%%")
end

local function current_cell_range()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #lines == 0 then
    return nil, nil
  end

  local start_line = cursor_line
  while start_line > 1 and not is_cell_marker(lines[start_line]) do
    start_line = start_line - 1
  end
  if is_cell_marker(lines[start_line]) then
    start_line = math.min(start_line + 1, #lines)
  end

  local end_line = cursor_line
  while end_line < #lines and not is_cell_marker(lines[end_line + 1]) do
    end_line = end_line + 1
  end

  if start_line > end_line then
    vim.notify("Cell hiện tại không có dòng code nào để chạy.", vim.log.levels.WARN)
    return nil, nil
  end

  return start_line, end_line
end

local function evaluate_current_cell()
  local start_line, end_line = current_cell_range()
  if not start_line or not end_line then
    return
  end

  local keys = vim.api.nvim_replace_termcodes(
    ("%dGV%dG:<C-u>MoltenEvaluateVisual<CR>"):format(start_line, end_line),
    true,
    false,
    true
  )
  vim.api.nvim_feedkeys(keys, "n", false)
end

vim.api.nvim_create_user_command("JupytextPair", function()
  run_jupytext({ "--set-formats", "ipynb,py:percent" }, "Jupytext Pair")
end, { desc = "Pair the current notebook with ipynb and py:percent" })

vim.api.nvim_create_user_command("JupytextSync", function()
  run_jupytext({ "--sync" }, "Jupytext Sync")
end, { desc = "Sync the current paired notebook" })

vim.api.nvim_create_user_command("JupytextToIpynb", function()
  run_jupytext({ "--to", "ipynb" }, "Jupytext Export")
end, { desc = "Export the current text notebook to ipynb" })

vim.api.nvim_create_user_command("JupyterRunCell", evaluate_current_cell, {
  desc = "Run the current # %% cell with Molten",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }

    vim.keymap.set("n", "<leader>ji", "<cmd>MoltenInit<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upyter [I]nit kernel",
    }))
    vim.keymap.set("n", "<leader>jc", evaluate_current_cell, vim.tbl_extend("force", opts, {
      desc = "[J]upyter run current [C]ell",
    }))
    vim.keymap.set("n", "<leader>jl", "<cmd>MoltenEvaluateLine<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upyter run current [L]ine",
    }))
    vim.keymap.set("n", "<leader>jr", "<cmd>MoltenReevaluateCell<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upyter [R]e-run active Molten cell",
    }))
    vim.keymap.set("n", "<leader>jo", "<cmd>MoltenShowOutput<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upyter show [O]utput",
    }))
    vim.keymap.set("n", "<leader>je", "<cmd>noautocmd MoltenEnterOutput<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upyter [E]nter output window",
    }))
    vim.keymap.set("n", "<leader>jx", "<cmd>MoltenInterrupt<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upyter interrupt e[X]ecution",
    }))
    vim.keymap.set("n", "<leader>jd", "<cmd>MoltenDelete<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upyter [D]elete active Molten cell",
    }))
    vim.keymap.set("v", "<leader>jv", ":<C-u>MoltenEvaluateVisual<CR>gv", vim.tbl_extend("force", opts, {
      desc = "[J]upyter run [V]isual selection",
    }))
    vim.keymap.set("n", "<leader>jp", "<cmd>JupytextPair<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upytext [P]air with ipynb",
    }))
    vim.keymap.set("n", "<leader>js", "<cmd>JupytextSync<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upytext [S]ync pair",
    }))
    vim.keymap.set("n", "<leader>jb", "<cmd>JupytextToIpynb<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upytext export note[B]ook",
    }))
    vim.keymap.set("n", "]j", function()
      vim.fn.search("^%s*# %%", "W")
    end, vim.tbl_extend("force", opts, {
      desc = "Jump to next Jupyter cell marker",
    }))
    vim.keymap.set("n", "[j", function()
      vim.fn.search("^%s*# %%", "bW")
    end, vim.tbl_extend("force", opts, {
      desc = "Jump to previous Jupyter cell marker",
    }))
  end,
})
