local M = {}

local terminals = {} -- Map of ID (number) to { buf = bufnr, win = winid }
local last_active_term_id = 1

function M.toggle_terminal()
  local count = vim.v.count
  local term_id = count > 0 and count or last_active_term_id
  last_active_term_id = term_id

  -- Clean up invalid window references in other terminals
  for id, term in pairs(terminals) do
    if id ~= term_id then
      if term.win and not vim.api.nvim_win_is_valid(term.win) then
        term.win = nil
      end
    end
  end

  local term = terminals[term_id]
  if not term then
    term = { buf = nil, win = nil }
    terminals[term_id] = term
  end

  -- Validate current terminal's window and buffer
  if term.win and not vim.api.nvim_win_is_valid(term.win) then
    term.win = nil
  end
  if term.buf and not vim.api.nvim_buf_is_valid(term.buf) then
    term.buf = nil
  end

  -- Check if this specific terminal is currently open (visible)
  if term.win then
    -- It is visible, so hide it
    vim.api.nvim_win_hide(term.win)
    term.win = nil
  else
    -- It is not visible.
    -- First, hide any other visible terminals to keep a single terminal window
    for id, other_term in pairs(terminals) do
      if id ~= term_id and other_term.win and vim.api.nvim_win_is_valid(other_term.win) then
        vim.api.nvim_win_hide(other_term.win)
        other_term.win = nil
      end
    end

    -- Create or validate buffer
    if not term.buf then
      term.buf = vim.api.nvim_create_buf(false, true)
    end

    -- Create the window
    vim.cmd("botright 12split")
    term.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(term.win, term.buf)

    -- Initialize terminal if needed
    if vim.bo[term.buf].buftype ~= "terminal" then
      vim.fn.termopen(vim.o.shell)
      pcall(vim.api.nvim_buf_set_name, term.buf, "Terminal " .. term_id)
    end

    vim.cmd("startinsert")
  end
end

return M
