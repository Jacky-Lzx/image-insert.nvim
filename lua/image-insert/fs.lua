local config = require("image-insert.config")

local M = {}

M.sep = package.config:sub(1, 1)

---@param path string
---@return string
M.normalize_path = function(path)
  return vim.fn.simplify(path):gsub(M.sep .. "$", "") .. M.sep
end

---@param target string
---@param start? string
---@return string
M.relpath = function(target, start)
  start = start or vim.fn.getcwd()
  target = vim.fn.fnamemodify(target, ":p")
  start = vim.fn.fnamemodify(start, ":p")

  local function split_path(str)
    local res = {}
    for part in string.gmatch(str, "[^" .. M.sep .. "]+") do
      table.insert(res, part)
    end
    return res
  end

  local target_parts = split_path(target)
  local start_parts = split_path(start)

  local common_len = 0
  for i = 1, math.min(#start_parts, #target_parts) do
    if start_parts[i] == target_parts[i] then
      common_len = i
    else
      break
    end
  end

  local res = {}
  for _ = common_len + 1, #start_parts do
    table.insert(res, "..")
  end
  for i = common_len + 1, #target_parts do
    table.insert(res, target_parts[i])
  end
  return table.concat(res, M.sep)
end

---@param dir string
---@return boolean
M.mkdirp = function(dir)
  local path = vim.fn.resolve(dir)
  if vim.fn.isdirectory(path) == 1 then return true end

  local parent = vim.fn.fnamemodify(path, ":h")
  if not M.mkdirp(parent) then return false end

  return vim.loop.fs_mkdir(path, 493) -- 0755
end

---@return string | nil
M.get_file_path = function()
  local dir_path = config.get_opt("dir_path")
  if config.get_opt("relative_to_current_file") then
    local current_file_path = vim.fn.expand("%:.:h")
    if current_file_path ~= "." and current_file_path ~= "" then
      dir_path = current_file_path .. M.sep .. dir_path
    end
  end
  dir_path = M.normalize_path(dir_path)

  local file_name = os.date(config.get_opt("file_name"))
  local extension = config.get_opt("extension")

  local full_path
  if config.get_opt("prompt_for_file_name") then
    local input = vim.fn.input("File name: ", file_name)
    if input == "" then return nil end
    full_path = dir_path .. input
  else
    full_path = dir_path .. file_name
  end

  if vim.fn.fnamemodify(full_path, ":e") == "" then
    full_path = full_path .. "." .. extension
  end
  return full_path
end

return M
