local map = vim.keymap.set

-- Disable default Space key behavior to make it act cleanly as leader key
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Limpar marcação de pesquisa ao pressionar <Esc> no modo Normal
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clean search highlights" })

-- --- NATIVE TERMINAL TOGGLE ---
local term = require("utils.terminal")
-- Atalhos de compatibilidade (terminais diferentes enviam códigos diferentes para Ctrl+/)
map({ "n", "t" }, "<C-/>", term.toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-_>", term.toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-`>", term.toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-~>", term.toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-\\>", term.toggle_terminal, { desc = "Toggle Terminal (Fallback)" })

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

  -- Get listed buffers
  local buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())

  -- Find alternative buffer
  local target_buf = nil
  if #buffers > 1 then
    for i, buf in ipairs(buffers) do
      if buf == bufnr then
        if i > 1 then
          target_buf = buffers[i - 1]
        else
          target_buf = buffers[i + 1]
        end
        break
      end
    end
  end

  -- If no other buffer exists, create a new empty one
  if not target_buf then
    target_buf = vim.api.nvim_create_buf(true, false)
  end

  -- Swap buffer first to keep window layout
  local bufinfo = vim.fn.getbufinfo(bufnr)
  local windows = (bufinfo and bufinfo[1] and bufinfo[1].windows) or {}
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_buf(win, target_buf)
    end
  end
  bd(bufnr, {})
end

map("n", "<leader>bd", buf_delete, { desc = "Delete Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Delete Other Buffers" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle Pin Buffer" })
map("n", "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", { desc = "Close Buffers to Left" })
map("n", "<leader>bl", "<cmd>BufferLineCloseRight<cr>", { desc = "Close Buffers to Right" })
map("n", "<leader>b[", "<cmd>BufferLineMovePrev<cr>", { desc = "Move Buffer Left" })
map("n", "<leader>b]", "<cmd>BufferLineMoveNext<cr>", { desc = "Move Buffer Right" })

-- Criar NOVO terminal em um split abaixo
local function new_split_terminal()
  vim.cmd("botright split | terminal")
  vim.cmd("startinsert")
end
map({ "n", "t" }, "<C-S-`>", new_split_terminal, { desc = "New Split Terminal" })

-- Mover linhas (Alt + j/k)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down", silent = true })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up", silent = true })

-- Selecionar tudo
map({ "n", "v" }, "<C-a>", "ggVG", { desc = "Select all" })
-- Salvar arquivo (Ctrl + s)
map({ "n", "i", "x" }, "<C-s>", "<cmd>w<cr>", { desc = "Save File" })

-- Formatar buffer / seleção (sem salvar)
local fmt = require("utils.format")
map({ "n", "v" }, "<leader>cf", function() fmt.format_buffer({ async = true }) end,
  { desc = "Format Document / Selection" })

-- Copiar, colar e cortar
map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })

-- --- NAVEGAÇÃO GLOBAL (SPLITS E BUFFERS) ---
-- Mover entre janelas (Ctrl + Arrow keys) (funciona em modo normal, insert, visual e terminal)
map({ "n", "i", "v", "t" }, "<C-Left>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map({ "n", "i", "v", "t" }, "<C-Down>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map({ "n", "i", "v", "t" }, "<C-Up>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map({ "n", "i", "v", "t" }, "<C-Right>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- Alternar entre buffers (Shift + h/l)
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- --- Telescope (LazyVim Style Shortcuts) ---
local function find_files()
  require("telescope.builtin").find_files()
end

local function live_grep()
  require("telescope.builtin").live_grep()
end

local function fuzzy_find()
  require("telescope.builtin").current_buffer_fuzzy_find()
end

local function show_commands()
  require("telescope.builtin").commands()
end

map("n", "<leader><space>", find_files, { desc = "Find Files (root dir)" })
map("n", "<leader>ff", find_files, { desc = "Find Files (root dir)" })

map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })
map("n", "<leader>fr", function()
  require("telescope.builtin").oldfiles()
end, { desc = "Recent Files" })
map("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "Buffers" })

-- Helper function to get visual selection text safely
local function get_visual_selection()
  local old_reg = vim.fn.getreg("v")
  local old_regtype = vim.fn.getregtype("v")

  vim.cmd('noau normal! "vy')
  local text = vim.fn.getreg("v")

  vim.fn.setreg("v", old_reg, old_regtype)

  -- Clean up text (remove newlines and carriage returns)
  text = string.gsub(text, "\n", "")
  text = string.gsub(text, "\r", "")
  return text
end

map("n", "<leader>sg", live_grep, { desc = "Grep (root dir)" })
map("n", "<leader>/", live_grep, { desc = "Grep (root dir)" })

-- Search in current file (Normal mode)
map("n", "<leader>ss", fuzzy_find, { desc = "Search in Current File" })

-- Search visual selection in project (Grep)
map("v", "<leader>sg", function()
  local text = get_visual_selection()
  require("telescope.builtin").grep_string({ search = text })
end, { desc = "Search Selection in Project" })

-- Search visual selection in current file
local function fuzzy_find_selection()
  local text = get_visual_selection()
  require("telescope.builtin").current_buffer_fuzzy_find({ default_text = text })
end
map("v", "<leader>ss", fuzzy_find_selection, { desc = "Search Selection in File" })

map("n", "<leader>sh", function()
  require("telescope.builtin").help_tags()
end, { desc = "Help Tags" })
map("n", "<leader>sk", function()
  require("telescope.builtin").keymaps()
end, { desc = "Key Maps" })
map("n", "<leader>sC", show_commands, { desc = "Commands Palette" })

map("n", "<leader>sd", function()
  require("telescope.builtin").diagnostics()
end, { desc = "Workspace Diagnostics" })

-- --- FOLDING ---
map("n", "<C-k>z", "za", { desc = "Toggle Fold" })

-- --- File Explorer (Oil.nvim) ---
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Open parent directory with Oil" })

-- --- Search & Replace (Grug-far) ---
map("n", "<leader>sr", function()
  local ok, grug = pcall(require, "grug-far")
  if ok then
    grug.open({ transient = true })
  else
    vim.notify("Plugin grug-far.nvim não encontrado", vim.log.levels.ERROR)
  end
end, { desc = "Search and Replace (Grug-far)" })

map("v", "<leader>sr", function()
  local ok, grug = pcall(require, "grug-far")
  if ok then
    grug.with_visual_selection({ transient = true })
  else
    vim.notify("Plugin grug-far.nvim não encontrado", vim.log.levels.ERROR)
  end
end, { desc = "Search and Replace Selection (Grug-far)" })

-- --- Diagnostics Mappings ---
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "pd", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "nd", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })


-- --- WINDOW MANAGEMENT (<leader>w) ---
map("n", "<leader>ww", "<cmd>wincmd w<cr>", { desc = "Switch to Other Window" })
map("n", "<leader>wd", "<cmd>wincmd c<cr>", { desc = "Close Window" })
map("n", "<leader>wo", "<cmd>wincmd o<cr>", { desc = "Maximize / Only Window" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split Horizontally" })
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split Vertically" })
map("n", "<leader>w=", "<cmd>wincmd =<cr>", { desc = "Equalize Window Sizes" })
map("n", "<leader>wt", "<cmd>wincmd T<cr>", { desc = "Move Window to New Tab" })

-- Resize window
map("n", "<leader>w+", "<cmd>resize +5<cr>", { desc = "Increase Height" })
map("n", "<leader>w_", "<cmd>resize -5<cr>", { desc = "Decrease Height" })
map("n", "<leader>w>", "<cmd>vertical resize +5<cr>", { desc = "Increase Width" })
map("n", "<leader>w<", "<cmd>vertical resize -5<cr>", { desc = "Decrease Width" })

-- Resize window with Alt + Arrow keys (works in normal, insert, visual, terminal modes)
map({ "n", "i", "v", "t" }, "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase Height" })
map({ "n", "i", "v", "t" }, "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Height" })
map({ "n", "i", "v", "t" }, "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Width" })
map({ "n", "i", "v", "t" }, "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Width" })

-- Move window position
map("n", "<leader>wH", "<cmd>wincmd H<cr>", { desc = "Move Window to Left" })
map("n", "<leader>wJ", "<cmd>wincmd J<cr>", { desc = "Move Window to Bottom" })
map("n", "<leader>wK", "<cmd>wincmd K<cr>", { desc = "Move Window to Top" })
map("n", "<leader>wL", "<cmd>wincmd L<cr>", { desc = "Move Window to Right" })

-- --- FORMAT ALL AND WRITE ALL (:wa) ---
-- Formatar todos os buffers modificados ao digitar :wa ou :wall
vim.api.nvim_create_user_command("Wa", function(opts)
  require("utils.format").format_and_save_all({ bang = opts.bang })
end, { bang = true, desc = "Format and organize imports of all modified buffers and write all" })

-- Redirecionar :wa, :wa!, :wall e :wall! ao pressionar Enter na linha de comando
vim.keymap.set("c", "<CR>", function()
  if vim.fn.getcmdtype() == ":" then
    local cmd = vim.fn.getcmdline()
    if cmd == "wa" or cmd == "wall" then
      return "<C-u>Wa<CR>"
    elseif cmd == "wa!" or cmd == "wall!" then
      return "<C-u>Wa!<CR>"
    end
  end
  return "<CR>"
end, { expr = true, replace_keycodes = true })

-- --- AI / SUPERMAVEN CONTROLS ---
map("n", "<leader>as", "<cmd>SupermavenStart<cr>", { desc = "Start Supermaven AI" })
map("n", "<leader>ap", "<cmd>SupermavenStop<cr>", { desc = "Stop Supermaven AI" })
map("n", "<leader>at", "<cmd>SupermavenToggle<cr>", { desc = "Toggle Supermaven AI" })

