local M = {}

---@class ImageInsertProcess
---@field cmd string
---@field extension string

---@class ImageInsertConfig
local default_config = {
  ---@type string
  dir_path = "img",
  ---@type string
  file_name = "%Y-%m-%d_%H-%M-%S",
  ---@type boolean
  relative_to_current_file = true,
  ---@type boolean
  prompt_for_file_name = true,
  ---@type string | function
  template = "![$CURSOR]($FILE_PATH)",
  ---@type "insert_after" | "insert_before" | "insert_line_after" | "insert_line_before"
  insert_strategy = "insert_after",
  ---@type ImageInsertProcess | ImageInsertProcess[]

  process = {
    cmd = "",
    extension = "png",
  },
}

---@type ImageInsertConfig
M.options = {}

---@param opts? table
M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", default_config, opts or {})
end

---@param key string
---@param opts? table The opts table should override the default options if provided
---@return any
M.get_opt = function(key, opts)
  if opts and opts[key] ~= nil then
    return opts[key]
  end
  return M.options[key]
end

return M
