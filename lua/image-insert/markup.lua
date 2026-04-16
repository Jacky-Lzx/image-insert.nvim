local config = require("image-insert.config")
local fs = require("image-insert.fs")

local M = {}

---@param file_path string
---@param opts? table
---@return boolean
M.insert_markup = function(file_path, opts)
  local file_name = vim.fn.fnamemodify(file_path, ":t")
  local file_name_no_ext = vim.fn.fnamemodify(file_path, ":t:r")
  local current_dir = vim.fn.expand("%:p:h")
  local relative_path = fs.relpath(file_path, current_dir)

  local label = file_name_no_ext:lower():gsub("%s+", "-")

  local template = config.get_opt("template", opts)
  if not template then
    return false
  end

  local context = {
    file_name = file_name,
    file_name_no_ext = file_name_no_ext,
    file_path = relative_path,
    label = label,
    cursor = "$CURSOR",
  }

  local markup
  if type(template) == "function" then
    markup = template(context)
  else
    markup = template
      :gsub("$FILE_NAME_NO_EXT", context.file_name_no_ext)
      :gsub("$FILE_NAME", context.file_name)
      :gsub("$FILE_PATH", context.file_path)
      :gsub("$LABEL", context.label)
  end

  local cursor_pos = markup:find("$CURSOR", 1, true)
  if cursor_pos then
    markup = markup:gsub("$CURSOR", "")
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local is_empty_line = line == ""

  -- Use after = true to append after the current cursor position
  vim.api.nvim_put({ markup }, "c", true, true)

  if cursor_pos then
    local new_col
    if is_empty_line then
      new_col = cursor_pos - 1
    else
      new_col = col + cursor_pos
    end

    vim.api.nvim_win_set_cursor(0, { row, new_col })
    vim.cmd("startinsert")
  end

  return true
end

return M
