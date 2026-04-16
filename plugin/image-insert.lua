if vim.fn.has("nvim-0.7.0") == 0 then
  vim.api.nvim_err_writeln("image-insert.nvim requires Neovim 0.7.0 or newer.")
  return
end

local image_insert = require("image-insert")

-- setup with default config if not already setup
image_insert.setup({})

vim.api.nvim_create_user_command("ImageInsert", function()
  image_insert.insert_image()
end, { desc = "Insert image from clipboard" })
