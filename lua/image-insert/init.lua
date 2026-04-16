local clipboard = require("image-insert.clipboard")
local fs = require("image-insert.fs")
local markup = require("image-insert.markup")
local util = require("image-insert.util")
local config = require("image-insert.config")

local M = {}

M.setup = function(opts)
  config.setup(opts)
end

M.insert_image = function()
  if not clipboard.get_clip_cmd() then
    util.error("Could not find a clipboard tool. Please install xclip, wl-paste, pbctl, or powershell.")
    return
  end

  if not clipboard.content_is_image() then
    util.warn("Clipboard does not contain an image.")
    return
  end

  local file_path = fs.get_file_path()
  if not file_path then
    util.info("Image insertion cancelled.")
    return
  end

  local dir_path = vim.fn.fnamemodify(file_path, ":h")
  if not fs.mkdirp(dir_path) then
    util.error("Could not create directory: " .. dir_path)
    return
  end

  if not clipboard.save_image(file_path) then
    util.error("Could not save image to: " .. file_path)
    return
  end

  if not markup.insert_markup(file_path) then
    util.error("Could not insert markup.")
    return
  end

  util.info("Image inserted: " .. file_path)
end

return M
