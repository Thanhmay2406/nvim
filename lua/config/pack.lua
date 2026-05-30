local M = {}

function M.add(specs)
  local ok, err = pcall(vim.pack.add, specs, { confirm = false, load = true })
  if not ok then
    vim.notify(("Failed to install/load plugin(s): %s"):format(err), vim.log.levels.ERROR)
  end

  return ok
end

return M
