local clipboard = require("image-insert.clipboard")
local fs = require("image-insert.fs")
local markup = require("image-insert.markup")
local util = require("image-insert.util")
local config = require("image-insert.config")

local M = {}

M.setup = function(opts)
  config.setup(opts)
end

local get_resolved_process = function(opts, callback)
  local process = config.get_opt("process", opts)

  if type(process) ~= "table" then
    callback(nil)
    return
  end

  -- If it's a list of processes
  if #process > 0 then
    if #process == 1 then
      callback(process[1])
      return
    end

    vim.ui.select(process, {
      prompt = "Select process command:",
      format_item = function(item)
        return string.format("%s (%s)", item.cmd == "" and "Direct save" or item.cmd, item.extension)
      end,
    }, function(choice)
      callback(choice)
    end)
    return
  end

  -- If it's a single process table
  if process.extension then
    callback(process)
    return
  end

  callback(nil)
end

---@param opts? table
M.insert_image = function(opts)
  if not clipboard.get_clip_cmd() then
    util.error("Could not find a supported clipboard tool.")
    return
  end

  if not clipboard.content_is_image() then
    util.warn("Clipboard does not contain an image.")
    return
  end

  get_resolved_process(opts, function(resolved_process)
    if not resolved_process then
      util.info("Image insertion cancelled.")
      return
    end

    -- Update the opts table with resolved values
    opts = opts or {}
    opts.process = resolved_process

    local file_path = fs.get_file_path(opts)
    if not file_path then
      util.info("Image insertion cancelled.")
      return
    end

    local dir_path = vim.fn.fnamemodify(file_path, ":h")
    if not fs.mkdirp(dir_path) then
      util.error("Could not create directory: " .. dir_path)
      return
    end

    if not clipboard.save_image(file_path, opts) then
      util.error("Could not save image to: " .. file_path)
      return
    end

    if not markup.insert_markup(file_path, opts) then
      util.error("Could not insert markup.")
      return
    end

    util.info("Image inserted: " .. file_path)
  end)
end

return M
