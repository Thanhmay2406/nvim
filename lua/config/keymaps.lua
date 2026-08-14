-- Clear search highlights with <Esc>.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

local cpp_template = {
  "#include <bits/stdc++.h>",
  "",
  "using namespace std;",
  "",
  "int main() {",
  "  ios::sync_with_stdio(false);",
  "  cin.tie(nullptr);",
  "",
  "  return 0;",
  "}",
}

vim.api.nvim_create_user_command("CP", function()
  local buf = vim.api.nvim_get_current_buf()
  if not vim.bo[buf].modifiable then
    vim.notify("Current buffer is not modifiable", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local is_empty_buffer = #lines == 1 and lines[1] == ""
  if not is_empty_buffer then
    local choice = vim.fn.confirm("Replace current buffer with C++ template?", "&Yes\n&No", 2)
    if choice ~= 1 then
      return
    end
  end

  vim.bo[buf].filetype = "cpp"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, cpp_template)
  vim.api.nvim_win_set_cursor(0, { 10, 11 })
end, { desc = "Insert competitive programming C++ template" })
