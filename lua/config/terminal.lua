-- 100% Native Floating Terminal (Zero Plugins)
local M = {}

local state = {
  buf = -1,
  win = -1,
}

function M.toggle(opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.fn.getcwd()

  -- If window is open and valid, hide it
  if vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_hide(state.win)
    return
  end

  -- Create buffer if needed
  if not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].bufhidden = "hide"
  end

  -- Calculate floating window dimensions
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " Terminal (" .. vim.fs.basename(cwd) .. ") ",
    title_pos = "center",
  })

  -- Start terminal shell if not already started
  if vim.bo[state.buf].buftype ~= "terminal" then
    vim.fn.jobstart(vim.o.shell, {
      term = true,
      cwd = cwd,
    })
  end

  vim.cmd.startinsert()
end

return M
