local ok_inline_diag, inline_diag = pcall(require, "tiny-inline-diagnostic")
if ok_inline_diag then
  vim.diagnostic.config({
    virtual_text = false,
    update_in_insert = false,
    severity_sort = true,
  })

  inline_diag.setup({
    preset = "cheap",
    options = {
      throttle = 150,
      softwrap = 15,
      multiple_diag_under_cursor = true,
    },
  })
end
