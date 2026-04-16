local M = {}

---@class ImageInsertConfig
local default_config = {
  dir_path = "img",
  file_name = "%Y-%m-%d_%H-%M-%S",
  extension = "png",
  relative_to_current_file = true,
  prompt_for_file_name = true,
  template = "![$FILE_NAME]($FILE_PATH)",
  process_cmd = "",
}

---@type ImageInsertConfig
M.options = {}

---@param opts? table
M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", default_config, opts or {})
end

---@param key string
---@param opts? table
---@return any
M.get_opt = function(key, opts)
  if opts and opts[key] ~= nil then
    return opts[key]
  end
  return M.options[key]
end

return M
