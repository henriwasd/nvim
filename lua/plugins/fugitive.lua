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
