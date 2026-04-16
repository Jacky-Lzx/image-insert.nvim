local function root(path)
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (path or "")
end

vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.opt.runtimepath:append(root())

-- Load dependencies if needed
-- local plenary_path = root(".tests/plenary.nvim")
-- if vim.fn.isdirectory(plenary_path) == 0 then
--   vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/nvim-lua/plenary.nvim", plenary_path })
-- end
-- vim.opt.runtimepath:append(plenary_path)
