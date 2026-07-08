-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- Selecionar tudo (Ctrl + a)
map({ "n", "v" }, "<C-a>", "ggVG", { desc = "Select all" })

-- Salvar arquivo (Ctrl + s)
map({ "n", "i", "x" }, "<C-s>", "<cmd>w<cr>", { desc = "Save File" })

-- Copiar e colar usando a área de transferência do sistema (Ctrl + c / Ctrl + v)
map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })
