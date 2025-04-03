-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- keymaps.lua
local map = vim.keymap.set

map("x", "I", ":s/\\(\\s*\\)/\\0/ | nohl" .. ("<left>"):rep(8))

map("x", "A", ":s/$// | nohl" .. ("<left>"):rep(8))

--- F12 para rodar o comando FlutterRun
map("n", "<F12>", ":lua require('flutter-tools.commands')<CR>")

--- F9 para alternar breakpoint
map("n", "<F9>", ":lua require'dap'.toggle_breakpoint()<CR>")
--- F5 para continuar ou iniciar depuração
map("n", "<F5>", ":lua require'dap'.continue()<CR>")
--- Shift + F5 para parar depuração
map("n", "<S-F5>", ":lua require'dap'.terminate()<CR>")
--- F10 para avançar uma linha (step over)
map("n", "<F10>", ":lua require'dap'.step_over()<CR>")
--- F11 para entrar na função (step into)
map("n", "<F11>", ":lua require'dap'.step_into()<CR>")
--- Shift + F11 para sair da função (step out)
map("n", "<S-F11>", ":lua require'dap'.step_out()<CR>")
--- F12 para abrir o console de depuração
map("n", "<leader>dd", ":DapViewToggle<CR>")
