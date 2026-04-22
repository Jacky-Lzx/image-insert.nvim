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

  local template_opt = config.get_opt("template", opts)
  if not template_opt then
    return false
  end

  local template
  if type(template_opt) == "table" then
    local filetype = vim.bo.filetype
    template = template_opt[filetype] or template_opt["markdown"] or template_opt["default"]
  else
    template = template_opt
  end

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

  -- Strip exactly one trailing newline if it exists
  if markup:sub(-1) == "\n" then
    markup = markup:sub(1, -2)
  end

  local lines = vim.split(markup, "\n")

  -- Handle base indentation: use the indentation of the first line as base and strip it from all lines
  if #lines > 0 then
    -- If the first line is empty (common in [[ multi-line strings), use the second line for base indent
    local first_content_line = 1
    if #lines > 1 and lines[1] == "" then
      first_content_line = 2
    end

    local base_indent = lines[first_content_line]:match("^(%s*)")
    if #base_indent > 0 then
      for i, line in ipairs(lines) do
        if line:sub(1, #base_indent) == base_indent then
          lines[i] = line:sub(#base_indent + 1)
        elseif line:match("^%s*$") then
          lines[i] = ""
        end
      end
    end

    -- Remove the first line if it's empty (result of [[ starting on a new line)
    if lines[1] == "" and #lines > 1 then
      table.remove(lines, 1)
    end

    -- Remove the last line if it consists of all white spaces (common in [[ multi-line strings)
    if #lines > 0 and lines[#lines]:match("^%s*$") then
      table.remove(lines)
    end
  end

  local cursor_line, cursor_col
  for i, line in ipairs(lines) do
    local pos = line:find("$CURSOR", 1, true)
    if pos then
      cursor_line = i
      cursor_col = pos
      lines[i] = line:gsub("$CURSOR", "")
      break
    end
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local is_empty_line = line == ""
  local strategy = config.get_opt("insert_strategy", opts)

  local put_after = strategy == "insert_after" or strategy == "insert_line_after"
  local is_line = strategy == "insert_line_after" or strategy == "insert_line_before"

  if is_line then
    -- Use append(o) or insert(O) behavior
    local target_row = put_after and row or row - 1
    vim.api.nvim_buf_set_lines(0, target_row, target_row, false, lines)
    if cursor_line then
      vim.api.nvim_win_set_cursor(0, { target_row + cursor_line, cursor_col - 1 })
      vim.cmd("startinsert")
    end
  else
    -- Standard nvim_put for in-line insertion
    vim.api.nvim_put(lines, "c", put_after, true)

    if cursor_line then
      local new_row = row + cursor_line - 1
      local new_col
      if cursor_line == 1 then
        if put_after then
          if is_empty_line then
            new_col = cursor_col - 1
          else
            new_col = col + cursor_col
          end
        else
          new_col = col + cursor_col - 1
        end
      else
        new_col = cursor_col - 1
      end

      vim.api.nvim_win_set_cursor(0, { new_row, new_col })
      vim.cmd("startinsert")
    end
  end

  return true
end

return M
