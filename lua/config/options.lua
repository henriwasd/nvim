-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_prettier_needs_config = false

-- Check if 'pwsh' is executable and set the shell accordingly
if vim.fn.executable("pwsh") == 1 then
  vim.o.shell = "pwsh"
else
  if vim.fn.executable("powershell") == 1 then
    vim.o.shell = "powershell"
  end
end

if vim.fn.executable("zsh") == 1 then
  local clip = "/mnt/c/Windows/System32/clip.exe" -- Change this path if needed

  if vim.fn.executable(clip) then
    local opts = {
      callback = function()
        if vim.v.event.operator ~= "y" then
          return
        end
        vim.fn.system(clip, vim.fn.getreg("0"))
      end,
    }

    opts.group = vim.api.nvim_create_augroup("WSLYank", {})
    vim.api.nvim_create_autocmd("TextYankPost", { group = opts.group, callback = opts.callback })
  end
end

-- Setting shell command flags
vim.o.shellcmdflag =
  "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"

-- Setting shell redirection
vim.o.shellredir = '2>&1 | %{ "$_" } | Out-File %s; exit $LastExitCode'

-- Setting shell pipe
vim.o.shellpipe = '2>&1 | %{ "$_" } | Tee-Object %s; exit $LastExitCode'

-- Setting shell qu
vim.lsp.inlay_hint.is_enabled = false
