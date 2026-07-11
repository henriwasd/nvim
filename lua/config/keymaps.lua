-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set

map({ "n", "v" }, "<C-a>", "ggVG", { desc = "Select all" })

map({ "n", "i", "x" }, "<C-s>", "<cmd>noautocmd w<cr>", { desc = "Save File (No Format)" })

map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map("v", "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })

map({ "n", "i", "v", "t" }, "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase Height" })
map({ "n", "i", "v", "t" }, "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Height" })
map({ "n", "i", "v", "t" }, "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Width" })
map({ "n", "i", "v", "t" }, "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Width" })
