local pack = require("config.pack")

pack.add({
  "https://github.com/3rd/image.nvim",
  "https://github.com/benlubas/molten-nvim",
})

local notebook_venv = vim.fn.stdpath("config") .. "/.venv-nvim/bin"
local kaggle_output_dirname = vim.g.kaggle_output_dirname or "kaggle-output"

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

local function current_file_dir()
  local path = current_file_path()
  if not path then
    return nil
  end

  return vim.fs.dirname(path)
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

local function notify(message, level, opts)
  vim.schedule(function()
    vim.notify(message, level, opts)
  end)
end

local function run_command(cmd, title, opts)
  opts = opts or {}

  vim.system(cmd, {
    text = true,
    cwd = opts.cwd,
  }, function(result)
    notify_result(title, result)
    if result.code == 0 and opts.on_success then
      opts.on_success(result)
    end
  end)
end

local function notebook_executable_or_error(name)
  local executable = notebook_executable(name)
  if executable then
    return executable
  end

  vim.notify(("Không tìm thấy lệnh %s. Hãy cài nó trước."):format(name), vim.log.levels.ERROR)
  return nil
end

local function metadata_path_from_dir(dir)
  if not dir then
    return nil
  end

  local found = vim.fs.find("kernel-metadata.json", {
    path = dir,
    upward = true,
    stop = vim.fn.expand("~"),
    type = "file",
  })[1]

  return found
end

local function metadata_context()
  local dir = current_file_dir()
  if not dir then
    return nil
  end

  local metadata_path = metadata_path_from_dir(dir)
  if metadata_path then
    return {
      dir = vim.fs.dirname(metadata_path),
      metadata_path = metadata_path,
    }
  end

  return {
    dir = dir,
    metadata_path = nil,
  }
end

local function read_json_file(path)
  if not path then
    return nil
  end

  local lines = vim.fn.readfile(path)
  if vim.v.shell_error ~= 0 then
    return nil
  end

  local ok, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok then
    notify(("Không đọc được JSON từ %s"):format(path), vim.log.levels.ERROR)
    return nil
  end

  return data
end

local function kernel_ref_from_context(context)
  if type(vim.g.kaggle_kernel_ref) == "string" and vim.g.kaggle_kernel_ref ~= "" then
    return vim.g.kaggle_kernel_ref
  end

  local metadata = read_json_file(context.metadata_path)
  if type(metadata) == "table" and type(metadata.id) == "string" and metadata.id ~= "" then
    return metadata.id
  end

  return nil
end

local function prompt_kernel_ref(default_ref, callback)
  vim.schedule(function()
    vim.ui.input({
      prompt = "Kaggle kernel ref (owner/slug): ",
      default = default_ref or "",
    }, function(input)
      if not input or vim.trim(input) == "" then
        vim.notify("Thiếu Kaggle kernel ref.", vim.log.levels.WARN)
        return
      end

      callback(vim.trim(input))
    end)
  end)
end

local function resolve_kernel_ref(arg, callback)
  if arg and vim.trim(arg) ~= "" then
    callback(vim.trim(arg))
    return
  end

  local context = metadata_context()
  if not context then
    return
  end

  local inferred = kernel_ref_from_context(context)
  if inferred then
    callback(inferred)
    return
  end

  prompt_kernel_ref(nil, callback)
end

local function kaggle_output_dir(context)
  return vim.fs.joinpath(context.dir, kaggle_output_dirname)
end

local function run_kaggle(args, title, opts)
  local kaggle = notebook_executable_or_error("kaggle")
  if not kaggle then
    return
  end

  local cmd = vim.list_extend({ kaggle }, args)
  run_command(cmd, title, opts)
end

local function kaggle_kernel_init()
  local context = metadata_context()
  if not context then
    return
  end

  if context.metadata_path then
    vim.notify(
      ("Đã có kernel-metadata.json tại %s"):format(context.metadata_path),
      vim.log.levels.INFO,
      { title = "Kaggle Init" }
    )
    return
  end

  run_kaggle({ "kernels", "init", "-p", context.dir }, "Kaggle Init", { cwd = context.dir })
end

local function kaggle_kernel_push()
  local context = metadata_context()
  if not context then
    return
  end

  if not context.metadata_path then
    vim.notify(
      "Chưa có kernel-metadata.json. Hãy chạy :KaggleKernelInit trước.",
      vim.log.levels.ERROR,
      { title = "Kaggle Push" }
    )
    return
  end

  run_kaggle({ "kernels", "push", "-p", context.dir }, "Kaggle Push", { cwd = context.dir })
end

local function kaggle_kernel_pull(arg)
  local context = metadata_context()
  if not context then
    return
  end

  resolve_kernel_ref(arg, function(ref)
    run_kaggle({ "kernels", "pull", "-p", context.dir, "-m", ref }, "Kaggle Pull", { cwd = context.dir })
  end)
end

local function kaggle_kernel_status(arg)
  resolve_kernel_ref(arg, function(ref)
    run_kaggle({ "kernels", "status", ref }, "Kaggle Status")
  end)
end

local function kaggle_kernel_files(arg)
  resolve_kernel_ref(arg, function(ref)
    run_kaggle({ "kernels", "files", ref }, "Kaggle Files")
  end)
end

local function kaggle_kernel_output(arg)
  local context = metadata_context()
  if not context then
    return
  end

  vim.fn.mkdir(kaggle_output_dir(context), "p")
  resolve_kernel_ref(arg, function(ref)
    run_kaggle(
      { "kernels", "output", ref, "-p", kaggle_output_dir(context), "-o" },
      "Kaggle Output",
      { cwd = context.dir }
    )
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

local function normalize_jupyter_server_url(url)
  if type(url) ~= "string" then
    return nil
  end

  local trimmed = vim.trim(url)
  if trimmed == "" then
    return nil
  end

  return trimmed
end

local function saved_jupyter_server_url()
  local candidates = {
    vim.g.jupyter_server_url,
    vim.env.JUPYTER_SERVER_URL,
    vim.env.MOLTEN_JUPYTER_SERVER_URL,
  }

  for _, candidate in ipairs(candidates) do
    local normalized = normalize_jupyter_server_url(candidate)
    if normalized then
      return normalized
    end
  end

  return nil
end

local function set_jupyter_server_url(url)
  local normalized = normalize_jupyter_server_url(url)
  if not normalized then
    vim.notify("Thiếu Jupyter server URL.", vim.log.levels.WARN, { title = "Jupyter Server" })
    return nil
  end

  vim.g.jupyter_server_url = normalized
  vim.notify(("Đã lưu Jupyter server URL: %s"):format(normalized), vim.log.levels.INFO, {
    title = "Jupyter Server",
  })
  return normalized
end

local function prompt_jupyter_server_url(default_url, callback)
  vim.schedule(function()
    vim.ui.input({
      prompt = "Jupyter server URL: ",
      default = default_url or "",
    }, function(input)
      local normalized = normalize_jupyter_server_url(input)
      if not normalized then
        vim.notify("Thiếu Jupyter server URL.", vim.log.levels.WARN, { title = "Jupyter Server" })
        return
      end

      callback(normalized)
    end)
  end)
end

local function resolve_jupyter_server_url(arg, callback)
  local normalized = normalize_jupyter_server_url(arg)
  if normalized then
    callback(normalized)
    return
  end

  local saved = saved_jupyter_server_url()
  if saved then
    callback(saved)
    return
  end

  prompt_jupyter_server_url(nil, callback)
end

local function molten_init_jupyter_server(arg, opts)
  opts = opts or {}

  resolve_jupyter_server_url(arg, function(url)
    if opts.persist ~= false then
      set_jupyter_server_url(url)
    end

    vim.cmd({
      cmd = "MoltenInit",
      args = { url },
    })
  end)
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

vim.api.nvim_create_user_command("JupyterServerSet", function(opts)
  if opts.args ~= "" then
    set_jupyter_server_url(opts.args)
    return
  end

  prompt_jupyter_server_url(saved_jupyter_server_url(), function(url)
    set_jupyter_server_url(url)
  end)
end, {
  desc = "Save the Jupyter server URL for this Neovim session",
  nargs = "?",
})

vim.api.nvim_create_user_command("JupyterServerConnect", function(opts)
  molten_init_jupyter_server(opts.args)
end, {
  desc = "Connect Molten to a Jupyter Server URL",
  nargs = "?",
  complete = "file",
})

vim.api.nvim_create_user_command("KaggleKernelInit", kaggle_kernel_init, {
  desc = "Create kernel-metadata.json in the current notebook directory",
})

vim.api.nvim_create_user_command("KaggleKernelPush", kaggle_kernel_push, {
  desc = "Push the current notebook directory to Kaggle and trigger a run",
})

vim.api.nvim_create_user_command("KaggleKernelPull", function(opts)
  kaggle_kernel_pull(opts.args)
end, {
  desc = "Pull a Kaggle notebook and metadata into the current notebook directory",
  nargs = "?",
})

vim.api.nvim_create_user_command("KaggleKernelStatus", function(opts)
  kaggle_kernel_status(opts.args)
end, {
  desc = "Show the latest status for a Kaggle kernel",
  nargs = "?",
})

vim.api.nvim_create_user_command("KaggleKernelFiles", function(opts)
  kaggle_kernel_files(opts.args)
end, {
  desc = "List output files from the latest Kaggle kernel run",
  nargs = "?",
})

vim.api.nvim_create_user_command("KaggleKernelOutput", function(opts)
  kaggle_kernel_output(opts.args)
end, {
  desc = "Download output files from the latest Kaggle kernel run",
  nargs = "?",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }

    vim.keymap.set("n", "<leader>ji", "<cmd>MoltenInit<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upyter [I]nit kernel",
    }))
    vim.keymap.set("n", "<leader>ju", "<cmd>JupyterServerConnect<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upyter attach via server [U]RL",
    }))
    vim.keymap.set("n", "<leader>jU", "<cmd>JupyterServerSet<CR>", vim.tbl_extend("force", opts, {
      desc = "[J]upyter set server [U]RL",
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
    vim.keymap.set("n", "<leader>ki", "<cmd>KaggleKernelInit<CR>", vim.tbl_extend("force", opts, {
      desc = "[K]aggle metadata [I]nit",
    }))
    vim.keymap.set("n", "<leader>kp", "<cmd>KaggleKernelPush<CR>", vim.tbl_extend("force", opts, {
      desc = "[K]aggle [P]ush and run",
    }))
    vim.keymap.set("n", "<leader>kl", "<cmd>KaggleKernelPull<CR>", vim.tbl_extend("force", opts, {
      desc = "[K]aggle pu[L]l notebook",
    }))
    vim.keymap.set("n", "<leader>ks", "<cmd>KaggleKernelStatus<CR>", vim.tbl_extend("force", opts, {
      desc = "[K]aggle [S]tatus",
    }))
    vim.keymap.set("n", "<leader>kf", "<cmd>KaggleKernelFiles<CR>", vim.tbl_extend("force", opts, {
      desc = "[K]aggle list output [F]iles",
    }))
    vim.keymap.set("n", "<leader>ko", "<cmd>KaggleKernelOutput<CR>", vim.tbl_extend("force", opts, {
      desc = "[K]aggle download [O]utput",
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
