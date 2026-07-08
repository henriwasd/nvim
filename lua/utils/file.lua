local M = {}

M.max_filesize = 1 * 1024 * 1024


function M.is_large_file(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    return false
  end
  local ok, stats = pcall((vim.uv or vim.loop).fs_stat, path)
  if ok and stats and stats.size > M.max_filesize then
    return true
  end
  return false
end

return M
