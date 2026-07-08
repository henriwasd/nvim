
local opt = vim.opt

opt.number = true
opt.splitbelow = true
opt.splitright = true
opt.wrap = false
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.undofile = true
opt.scrolloff = 8
opt.sidescrolloff = 8


vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1




if vim.fn.has("win32") == 1 then
  if vim.fn.executable("pwsh") == 1 then
    opt.shell = "pwsh"
    opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    opt.shellquote = ""
    opt.shellxquote = ""
  elseif vim.fn.executable("powershell.exe") == 1 then
    opt.shell = "powershell.exe"
    opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    opt.shellquote = ""
    opt.shellxquote = ""
  end
end


opt.cmdheight = 0
opt.laststatus = 0


opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99


vim.keymap.set('n', '<C-c>', '"+y', { noremap = true })
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true })
if vim.g.neovide then
  vim.api.nvim_set_keymap('n', '<C-v>', '"+p', { noremap = true })
  vim.api.nvim_set_keymap('v', '<C-v>', '"+P', { noremap = true })
  vim.api.nvim_set_keymap('c', '<C-v>', '<C-R>+', { noremap = true })
  vim.api.nvim_set_keymap('i', '<C-v>', '<C-R>+', { noremap = true })
  vim.api.nvim_set_keymap('t', '<C-v>', '<C-\\><C-n>"+Pi', { noremap = true })
  vim.o.guifont = "JetBrainsMono Nerd Font:h12"
end
