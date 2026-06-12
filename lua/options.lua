-- Sensible defaults
local opt = vim.opt

opt.number = true -- Show line numbers
opt.relativenumber = true -- Relative line numbers
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.wrap = false -- Disable line wrap
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Shift 2 spaces
opt.tabstop = 2 -- Tab 2 spaces
opt.smartindent = true -- Smart indenting
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Smart case search
opt.mouse = "a" -- Enable mouse support
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.signcolumn = "yes" -- Always show the sign column
opt.updatetime = 250 -- Faster completion and diagnostic updates
opt.timeoutlen = 300 -- Time to wait for a mapped sequence to complete
opt.undofile = true -- Save undo history
opt.autoread = true -- Automatically reload files modified externally
opt.scrolloff = 8 -- Minimum lines to keep above/below cursor
opt.sidescrolloff = 8 -- Minimum columns to keep left/right

-- Keep netrw disabled since we use neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ==========================================
-- Configuração do PowerShell 7 (pwsh)
-- ==========================================
if vim.fn.executable("pwsh") == 1 then
  opt.shell = "pwsh"
  opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  opt.shellquote = ""
  opt.shellxquote = ""
end

-- Fix para gap visual no Windows Terminal
opt.cmdheight = 0
opt.laststatus = 0

-- Folding configuration using Treesitter
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
