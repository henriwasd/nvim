-- Native Autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Sincronizacao automatica com alteracoes externas no disco
local autoreload_group = augroup("AutoreloadExternalChanges", { clear = true })

autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoreload_group,
  callback = function()
    if vim.fn.getcmdwintype() == "" and vim.fn.mode() == "n" then
      vim.cmd("checktime")
    end
  end,
})

autocmd("FileChangedShellPost", {
  group = autoreload_group,
  callback = function()
    vim.notify("Alterações externas detectadas, arquivo recarregado.", vim.log.levels.INFO, { title = "File Changed" })
  end,
})

-- Highlight ao copiar texto (Yank)
local yank_group = augroup("HighlightYank", { clear = true })
autocmd("TextYankPost", {
  group = yank_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Retornar a ultima posicao do cursor ao reabrir um arquivo
local cursor_group = augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = cursor_group,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Fechar buffers utilitarios com 'q'
local close_with_q = augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
  group = close_with_q,
  pattern = { "help", "lspinfo", "man", "qf", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
