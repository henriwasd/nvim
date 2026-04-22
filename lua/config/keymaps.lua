-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Atalho para alternar o terminal (ToggleTerm style)
-- No Windows/Neovim, Ctrl + / geralmente é enviado como <C-_>
vim.keymap.set({ "n", "t" }, "<C-/>", function() LazyVim.terminal() end, { desc = "Terminal (root dir)" })
vim.keymap.set({ "n", "t" }, "<C-_>", function() LazyVim.terminal() end, { desc = "Terminal (root dir)" })

-- ==========================================
-- VSCode Keybindings & Custom user shortcuts
-- ==========================================
local map = vim.keymap.set

-- --- Padrões VSCode ---
-- Salvar
map({ "i", "n", "v", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
-- Selecionar tudo
map({ "n", "v" }, "<C-a>", "ggVG", { desc = "Select all" })
-- Copiar, colar e cortar (apenas para modo de inserção/visual se necessário, NVim já usa y/p/d)
map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", '<C-r>+', { desc = "Paste from clipboard" })

-- Desfazer / Refazer
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo" })
map("n", "<C-y>", "<C-r>", { desc = "Redo" })

-- --- NAVEGAÇÃO DE ABAS (ALT + NÚMERO) ---
for i = 1, 9 do
  map("n", "<A-" .. i .. ">", function()
    if package.loaded["bufferline"] then
      require("bufferline").go_to(i, true)
    end
  end, { desc = "Go to buffer " .. i })
end
map("n", "<A-0>", function()
  if package.loaded["bufferline"] then
    vim.cmd("BufferLineGoToBuffer -1")
  end
end, { desc = "Go to last buffer" })

-- --- TERMINAL / EDITOR CLOSE ---
map({ "n", "t" }, "<C-w>", function() Snacks.bufdelete() end, { desc = "Close Buffer" })

-- Alternar terminal padrão
-- No padrão internacional (dead keys), os terminais do Windows enviam sinais diferentes
map({ "n", "t" }, "<C-~>", function() LazyVim.terminal(nil, { id = vim.v.count1 }) end, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-`>", function() LazyVim.terminal(nil, { id = vim.v.count1 }) end, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-@>", function() LazyVim.terminal(nil, { id = vim.v.count1 }) end, { desc = "Toggle Terminal (WinTerminal Fallback)" })
map({ "n", "t" }, "<C-\\>", function() LazyVim.terminal(nil, { id = vim.v.count1 }) end, { desc = "Toggle Terminal (Universal Fallback)" })

-- Criar NOVO terminal em um split abaixo
map({ "n", "t" }, "<C-S-`>", function()
  vim.cmd("botright split | terminal")
  vim.cmd("startinsert")
end, { desc = "New Split Terminal" })
map({ "n", "t" }, "<C-S-~>", function()
  vim.cmd("botright split | terminal")
  vim.cmd("startinsert")
end, { desc = "New Split Terminal" })


-- --- NAVEGAÇÃO GLOBAL (SPLITS) ---
map({ "n", "v", "t" }, "<C-S-M-Left>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map({ "n", "v", "t" }, "<C-S-M-Right>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map({ "n", "v", "t" }, "<C-S-M-Up>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map({ "n", "v", "t" }, "<C-S-M-Down>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })

-- --- Quick Open / Command Palette ---
map({ "n", "v" }, "<C-p>", function() LazyVim.pick("files")() end, { desc = "Find Files" })
map({ "n", "v" }, "<C-e>", function() LazyVim.pick("files")() end, { desc = "Find Files" })
map({ "n", "v" }, "<C-S-p>", function() LazyVim.pick("commands")() end, { desc = "Command Palette" })
map({ "n", "v" }, "<F1>", function() LazyVim.pick("commands")() end, { desc = "Command Palette" })

-- --- ZEN MODE / FOLDING ---
map("n", "<C-k>z", "za", { desc = "Toggle Fold" })

-- --- JUMPLIST NAVEGATION ---
map("n", "<leader>o", "<C-o>", { desc = "Jump backward" })
map("n", "<leader>i", "<C-i>", { desc = "Jump forward" })
