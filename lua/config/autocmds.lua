-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
vim.opt.autoread = true

local autoreload_group = vim.api.nvim_create_augroup("AutoreloadExternalChanges", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoreload_group,
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = autoreload_group,
  callback = function()
    vim.notify("Detected external changes, reloading.", vim.log.levels.INFO, { title = "File Changed" })
  end,
})
