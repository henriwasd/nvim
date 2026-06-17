local map = vim.keymap.set

-- Disable default Space key behavior to make it act cleanly as leader key
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Limpar marcação de pesquisa ao pressionar <Esc> no modo Normal
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clean search highlights" })

-- --- NATIVE TERMINAL TOGGLE ---
local terminals = {} -- Map of ID (number) to { buf = bufnr, win = winid }
local last_active_term_id = 1

local function toggle_terminal()
  local count = vim.v.count
  local term_id = count > 0 and count or last_active_term_id
  last_active_term_id = term_id

  -- Clean up invalid window references in other terminals
  for id, term in pairs(terminals) do
    if id ~= term_id then
      if term.win and not vim.api.nvim_win_is_valid(term.win) then
        term.win = nil
      end
    end
  end

  local term = terminals[term_id]
  if not term then
    term = { buf = nil, win = nil }
    terminals[term_id] = term
  end

  -- Validate current terminal's window and buffer
  if term.win and not vim.api.nvim_win_is_valid(term.win) then
    term.win = nil
  end
  if term.buf and not vim.api.nvim_buf_is_valid(term.buf) then
    term.buf = nil
  end

  -- Check if this specific terminal is currently open (visible)
  if term.win then
    -- It is visible, so hide it
    vim.api.nvim_win_hide(term.win)
    term.win = nil
  else
    -- It is not visible.
    -- First, hide any other visible terminals to keep a single terminal window
    for id, other_term in pairs(terminals) do
      if id ~= term_id and other_term.win and vim.api.nvim_win_is_valid(other_term.win) then
        vim.api.nvim_win_hide(other_term.win)
        other_term.win = nil
      end
    end

    -- Create or validate buffer
    if not term.buf then
      term.buf = vim.api.nvim_create_buf(false, true)
    end

    -- Create the window
    vim.cmd("botright 12split")
    term.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(term.win, term.buf)

    -- Initialize terminal if needed
    if vim.bo[term.buf].buftype ~= "terminal" then
      vim.fn.termopen(vim.o.shell)
      pcall(vim.api.nvim_buf_set_name, term.buf, "Terminal " .. term_id)
    end

    vim.cmd("startinsert")
  end
end

-- Keymaps for terminal toggle
map({ "n", "t" }, "<C-/>", toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-_>", toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-~>", toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-`>", toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-@>", toggle_terminal, { desc = "Toggle Terminal (Fallback)" })
map({ "n", "t" }, "<C-\\>", toggle_terminal, { desc = "Toggle Terminal (Fallback)" })

-- Terminal mode escapes
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- --- NATIVE BUFFER DELETE (keep window layout) ---
local function buf_delete()
  local bufnr = vim.api.nvim_get_current_buf()
  local bd = vim.api.nvim_buf_delete
  -- Check if buffer is modified
  if vim.bo[bufnr].modified then
    local choice = vim.fn.confirm(string.format("Save changes to %q?", vim.fn.bufname(bufnr)), "&Yes\n&No\n&Cancel")
    if choice == 1 then
      vim.cmd("write")
    elseif choice == 2 then
      bd(bufnr, { force = true })
      return
    else
      return
    end
  end

  -- Swap buffer first to keep window layout
  local windows = vim.fn.getbufinfo(bufnr)[1].windows
  for _, win in ipairs(windows) do
    vim.api.nvim_win_call(win, function()
      vim.cmd("bnext")
      if vim.api.nvim_get_current_buf() == bufnr then
        vim.cmd("enew")
      end
    end)
  end
  bd(bufnr, {})
end

map("n", "<leader>bd", buf_delete, { desc = "Delete Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Criar NOVO terminal em um split abaixo
map({ "n", "t" }, "<C-S-`>", function()
  vim.cmd("botright split | terminal")
  vim.cmd("startinsert")
end, { desc = "New Split Terminal" })
map({ "n", "t" }, "<C-S-~>", function()
  vim.cmd("botright split | terminal")
  vim.cmd("startinsert")
end, { desc = "New Split Terminal" })

-- Mover linhas (Alt + j/k)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down", silent = true })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up", silent = true })

-- Selecionar tudo
map({ "n", "v" }, "<C-a>", "ggVG", { desc = "Select all" })
-- Copiar, colar e cortar
map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })

-- --- NAVEGAÇÃO GLOBAL (SPLITS E BUFFERS) ---
-- Mover entre janelas (Ctrl + hjkl)
map({ "n", "v", "t" }, "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map({ "n", "v", "t" }, "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map({ "n", "v", "t" }, "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map({ "n", "v", "t" }, "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- Alternar entre buffers (Shift + h/l)
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Atalhos de compatibilidade (Ctrl-Shift-Alt Setas)
map({ "n", "v", "t" }, "<C-S-M-Left>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map({ "n", "v", "t" }, "<C-S-M-Right>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map({ "n", "v", "t" }, "<C-S-M-Up>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map({ "n", "v", "t" }, "<C-S-M-Down>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })

-- --- Telescope (LazyVim Style Shortcuts) ---
map("n", "<leader><space>", function()
  require("telescope.builtin").find_files()
end, { desc = "Find Files (root dir)" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })
map("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find Files (root dir)" })
map("n", "<leader>fr", function()
  require("telescope.builtin").oldfiles()
end, { desc = "Recent Files" })
map("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "Buffers" })
map("n", "<leader>sg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Grep (root dir)" })
map("n", "<leader>/", function()
  require("telescope.builtin").live_grep()
end, { desc = "Grep (root dir)" })
map("n", "<leader>sh", function()
  require("telescope.builtin").help_tags()
end, { desc = "Help Tags" })
map("n", "<leader>sk", function()
  require("telescope.builtin").keymaps()
end, { desc = "Key Maps" })
map("n", "<leader>sC", function()
  require("telescope.builtin").commands()
end, { desc = "Commands Palette" })
map("n", "<leader>sd", function()
  require("telescope.builtin").diagnostics()
end, { desc = "Workspace Diagnostics" })
map({ "n", "v" }, "<C-p>", function()
  require("telescope.builtin").find_files()
end, { desc = "Find Files" })
map({ "n", "v" }, "<C-e>", function()
  require("telescope.builtin").find_files()
end, { desc = "Find Files" })
map({ "n", "v" }, "<C-S-p>", function()
  require("telescope.builtin").commands()
end, { desc = "Command Palette" })
map({ "n", "v" }, "<F1>", function()
  require("telescope.builtin").commands()
end, { desc = "Command Palette" })

-- --- FOLDING ---
map("n", "<C-k>z", "za", { desc = "Toggle Fold" })

-- --- JUMPLIST NAVEGATION ---
map("n", "<leader>o", "<C-o>", { desc = "Jump backward" })
map("n", "<leader>i", "<C-i>", { desc = "Jump forward" })

-- --- File Tree Toggle (Neo-Tree) ---
map("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>", { desc = "Toggle Explorer" })

-- --- Diagnostics Mappings ---
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>xx", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
