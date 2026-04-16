local M = {}

---@param cmd string
---@param silent? boolean
---@return string | nil output
---@return number exit_code
M.execute = function(cmd, silent)
  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if not silent and exit_code ~= 0 then
    M.error("Command failed: " .. cmd .. "\nOutput: " .. output)
  end

  return output, exit_code
end

---@param msg string
M.info = function(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = "image-insert.nvim" })
end

---@param msg string
M.warn = function(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "image-insert.nvim" })
end

---@param msg string
M.error = function(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "image-insert.nvim" })
end

---@param feature string
---@return boolean
M.has = function(feature)
  return vim.fn.has(feature) > 0
end

---@param executable string
---@return boolean
M.executable = function(executable)
  return vim.fn.executable(executable) > 0
end

return M
