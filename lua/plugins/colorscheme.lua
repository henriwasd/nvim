
local ok_gruvbox, gruvbox = pcall(require, "gruvbox")
if ok_gruvbox then
  gruvbox.setup({
    transparent_mode = true,
  })
  vim.cmd("colorscheme gruvbox")
end
