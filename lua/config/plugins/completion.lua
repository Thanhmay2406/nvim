local pack = require("config.pack")

pack.add({
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
})

local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
  local has_utils, blink_utils = pcall(require, "blink.cmp.lib.utils")
  if has_utils then
    blink_utils.get_char_at_cursor = function()
      local has_context, context = pcall(require, "blink.cmp.completion.trigger.context")
      if not has_context then
        return ""
      end

      local ok_line, line = pcall(context.get_line)
      if not ok_line or type(line) ~= "string" or line == "" then
        return ""
      end

      local ok_cursor, cursor = pcall(context.get_cursor)
      if not ok_cursor or type(cursor) ~= "table" or type(cursor[2]) ~= "number" then
        return ""
      end

      local cursor_col = cursor[2]
      local start_col = cursor_col
      while start_col > 1 do
        local char = string.byte(line:sub(start_col, start_col))
        if not char or char < 0x80 or char > 0xBF then
          break
        end
        start_col = start_col - 1
      end

      local end_col = cursor_col
      while end_col < #line do
        local char = string.byte(line:sub(end_col + 1, end_col + 1))
        if not char or char < 0x80 or char > 0xBF then
          break
        end
        end_col = end_col + 1
      end

      return line:sub(start_col, end_col)
    end
  end

  local function blink_enabled()
    local buf = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) then
      return false
    end

    local bo = vim.bo[buf]
    if bo.buftype ~= "" or not bo.modifiable or bo.readonly then
      return false
    end

    local ok, line = pcall(vim.api.nvim_get_current_line)
    return ok and type(line) == "string"
  end

  blink.setup({
    enabled = blink_enabled,

    completion = {
      documentation = {
        auto_show = true,
      },
    },

    signature = {
      enabled = false,
    },

    keymap = {
      ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
      ["<C-n>"] = { "select_next", "fallback_to_mappings" },

      ["<C-y>"] = { "select_and_accept", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },

      ["<Tab>"] = { "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },

      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },

      ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
    },

    fuzzy = {
      implementation = "lua",
    },
  })
end
