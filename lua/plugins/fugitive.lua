local map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Fugitive Git Keymaps (Lightweight and Native Git Integration)
map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git Status" })
map("n", "<leader>gd", "<cmd>Gdiffsplit<CR>", { desc = "Git Diff Split" })
map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git Commit" })
map("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git Push" })
map("n", "<leader>gl", "<cmd>Git log -n 100<CR>", { desc = "Git Log (Last 100)" })
map("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git Blame" })
map("n", "<leader>ge", "<cmd>Gedit<CR>", { desc = "Git Edit (Revert buffer changes)" })

-- Histórico do Arquivo Atual (Abre no Telescope / Quickfix)
map("n", "<leader>gh", function()
  vim.cmd("0Gclog")
  vim.defer_fn(function()
    local ok_tele, telescope = pcall(require, "telescope.builtin")
    if ok_tele then
      telescope.quickfix({ prompt_title = "Histórico do Arquivo" })
    else
      vim.cmd("copen")
    end
  end, 150)
end, { desc = "Git File History" })

-- Histórico de Linhas Selecionadas (Git log -L)
map("v", "<leader>gl", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  -- Escapes to normal mode first to clear the visual block visual state
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "x", true)
  vim.cmd(string.format("Git log -L %d,%d:%%", start_line, end_line))
end, { desc = "Git Log for Selected Lines" })
