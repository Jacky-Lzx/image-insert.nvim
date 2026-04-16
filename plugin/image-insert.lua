if vim.fn.has("nvim-0.7.0") == 0 then
  vim.notify("image-insert.nvim requires Neovim 0.7.0 or newer.", vim.log.levels.ERROR)
  return
end

local image_insert = require("image-insert")

vim.api.nvim_create_user_command("ImageInsert", function(args)
  local file_path = args.args ~= "" and args.args or nil
  image_insert.insert_image({}, file_path)
end, {
  desc = "Insert image from clipboard or existing file",
  nargs = "?",
  complete = "file",
})
