-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- keymaps.lua
local map = vim.keymap.set

map("x", "I", ":s/\\(\\s*\\)/\\0/ | nohl" .. ("<left>"):rep(8))

map("x", "A", ":s/$// | nohl" .. ("<left>"):rep(8))

--- F12 para rodar o comando FlutterRun
map("n", "<F12>", ":lua require('flutter-tools.commands')<CR>")
--- F5 para rodar o comando FlutterRun
map("n", "<F5>", ":lua require('flutter-tools.commands').run()<CR>")
--- Shift + F5 para rodar o comando FlutterQuit
map("n", "<S-F5>", ":lua require('flutter-tools.commands').quit()<CR>")

--- d Para next line in debug mode
map("n", "<Leader>dd", ":lua require'dap'.step_over()<CR>")
