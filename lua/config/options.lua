vim.g.lazyvim_prettier_needs_config = false

if vim.fn.executable("pwsh") == 1 then
  vim.o.shell = "pwsh"
else
  if vim.fn.executable("powershell") == 1 then
    vim.o.shell = "powershell"
  end
end

if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end
