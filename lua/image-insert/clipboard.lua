local util = require("image-insert.util")
local config = require("image-insert.config")

local M = {}

---@return string | nil
M.get_clip_cmd = function()
  if (util.has("win32") or util.has("wsl")) and util.executable("powershell.exe") then
    return "powershell.exe"
  elseif util.has("mac") then
    if util.executable("pbctl") then
      return "pbctl"
    elseif util.executable("pngpaste") then
      return "pngpaste"
    end
  elseif os.getenv("WAYLAND_DISPLAY") and util.executable("wl-paste") then
    return "wl-paste"
  elseif os.getenv("DISPLAY") and util.executable("xclip") then
    return "xclip"
  end
  return nil
end

---@return boolean
M.content_is_image = function()
  local cmd = M.get_clip_cmd()
  if not cmd then
    return false
  end

  if cmd == "xclip" then
    local output = util.execute("xclip -selection clipboard -t TARGETS -o", true)
    return output ~= nil and output:find("image/png") ~= nil
  elseif cmd == "wl-paste" then
    local output = util.execute("wl-paste --list-types", true)
    return output ~= nil and output:find("image/png") ~= nil
  elseif cmd == "pbctl" then
    local output = util.execute("pbctl types", true)
    return output ~= nil and output:find("image/") ~= nil
  elseif cmd == "pngpaste" then
    local _, exit_code = util.execute("pngpaste -", true)
    return exit_code == 0
  elseif cmd == "powershell.exe" then
    local output =
      util.execute("Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::GetImage()", true)
    return output ~= nil and output:find("Width") ~= nil
  end
  return false
end

---@param file_path string
---@return boolean
M.save_image = function(file_path)
  local cmd = M.get_clip_cmd()
  if not cmd then
    return false
  end

  local process_cmd = config.get_opt("process_cmd")
  if process_cmd ~= "" then
    process_cmd = "| " .. process_cmd .. " "
  end
  process_cmd = process_cmd:gsub("%%", "%%%%")

  local command = nil
  if cmd == "xclip" then
    command = string.format('xclip -selection clipboard -o -t image/png %s> "%s"', process_cmd, file_path)
  elseif cmd == "wl-paste" then
    command = string.format('wl-paste --type image/png %s> "%s"', process_cmd, file_path)
  elseif cmd == "pbctl" then
    command = string.format('pbctl paste %s> "%s"', process_cmd, file_path)
  elseif cmd == "pngpaste" then
    command = string.format('pngpaste - %s> "%s"', process_cmd, file_path)
  elseif cmd == "powershell.exe" then
    command = string.format(
      "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::GetImage().Save('%s')",
      file_path
    )
  end

  if command then
    local _, exit_code = util.execute(command)
    return exit_code == 0
  end
  return false
end

return M
