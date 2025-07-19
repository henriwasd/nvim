local map = vim.keymap.set

map("x", "I", ":s/\\(\\s*\\)/\\0/ | nohl" .. ("<left>"):rep(8))

map("x", "A", ":s/$// | nohl" .. ("<left>"):rep(8))

map("n", "<F12>", ":lua require('flutter-tools.commands')<CR>")

map("n", "<F9>", ":lua require'dap'.toggle_breakpoint()<CR>")
map("n", "<F5>", ":lua require'dap'.continue()<CR>")
map("n", "<S-F5>", ":lua require'dap'.terminate()<CR>")
map("n", "<F10>", ":lua require'dap'.step_over()<CR>")
map("n", "<F11>", ":lua require'dap'.step_into()<CR>")
map("n", "<S-F11>", ":lua require'dap'.step_out()<CR>")
