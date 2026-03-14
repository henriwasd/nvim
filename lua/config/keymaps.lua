-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Atalho para alternar o terminal (ToggleTerm style)
-- No Windows/Neovim, Ctrl + / geralmente é enviado como <C-_>
vim.keymap.set({ "n", "t" }, "<C-/>", function() LazyVim.terminal() end, { desc = "Terminal (root dir)" })
vim.keymap.set({ "n", "t" }, "<C-_>", function() LazyVim.terminal() end, { desc = "Terminal (root dir)" })
