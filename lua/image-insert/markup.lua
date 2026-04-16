local config = require("image-insert.config")
local fs = require("image-insert.fs")

local M = {}

---@param file_path string
---@return boolean
M.insert_markup = function(file_path)
  local file_name = vim.fn.fnamemodify(file_path, ":t:r")
  local current_dir = vim.fn.expand("%:p:h")
  local relative_path = fs.relpath(file_path, current_dir)

  local template = config.get_opt("template")
  if not template then
    return false
  end

  local markup = template:gsub("$FILE_NAME", file_name):gsub("$FILE_PATH", relative_path)
  vim.api.nvim_put({ markup }, "c", true, true)
  return true
end

return M
