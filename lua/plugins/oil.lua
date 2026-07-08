local ok_oil, oil = pcall(require, "oil")
if ok_oil then
  oil.setup({
    default_file_explorer = true,
    columns = {
      "icon",
    },
    win_options = {
      signcolumn = "yes:2",
    },
  })

  local ok_oil_git, oil_git = pcall(require, "oil-git-status")
  if ok_oil_git then
    oil_git.setup()
  end

  local ok_oil_lsp, oil_lsp = pcall(require, "oil-lsp-diagnostics")
  if ok_oil_lsp then
    oil_lsp.setup()
  end
end
