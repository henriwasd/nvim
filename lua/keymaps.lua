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
-- Salvar arquivo (Ctrl + s)
map({ "n", "i", "x" }, "<C-s>", "<cmd>w<cr>", { desc = "Save File" })

-- Formatar buffer / seleção (sem salvar)
local function format_buffer()
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.format({ bufnr = 0, lsp_fallback = true })
  else
    vim.lsp.buf.format({ async = true })
  end
end
map({ "n", "v" }, "<leader>cf", format_buffer, { desc = "Format Document / Selection" })
map({ "n", "v" }, "<A-f>", format_buffer, { desc = "Format Document / Selection" })
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

-- Mover entre janelas (Ctrl + Alt + Setas / Ctrl + Shift + Alt + Setas)
map({ "n", "v", "t" }, "<C-M-Left>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map({ "n", "v", "t" }, "<C-M-Right>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map({ "n", "v", "t" }, "<C-M-Up>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map({ "n", "v", "t" }, "<C-M-Down>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })

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

map("n", "<leader>sg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Grep (root dir)" })
map("n", "<leader>/", function()
  require("telescope.builtin").live_grep()
end, { desc = "Grep (root dir)" })

-- Search in current file (Normal mode)
map("n", "<leader>ss", function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Search in Current File" })
map("n", "<leader>sf", function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Search in Current File" })

-- Search visual selection in project (Grep)
map("v", "<leader>sg", function()
  local text = get_visual_selection()
  require("telescope.builtin").grep_string({ search = text })
end, { desc = "Search Selection in Project" })

-- Search visual selection in current file
map("v", "<leader>ss", function()
  local text = get_visual_selection()
  require("telescope.builtin").current_buffer_fuzzy_find({ default_text = text })
end, { desc = "Search Selection in File" })
map("v", "<leader>sf", function()
  local text = get_visual_selection()
  require("telescope.builtin").current_buffer_fuzzy_find({ default_text = text })
end, { desc = "Search Selection in File" })

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

-- --- File Explorer (Oil.nvim) ---
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Open parent directory with Oil" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory with Oil" })

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

-- --- GIT INTEGRATIONS KEYMAPS ---
-- Neogit (Full Git Client)
map("n", "<leader>gs", "<cmd>Neogit<cr>", { desc = "Git Status (Neogit)" })
map("n", "<leader>gc", "<cmd>Neogit commit<cr>", { desc = "Git Commit" })
map("n", "<leader>gp", "<cmd>Neogit pull<cr>", { desc = "Git Pull" })
map("n", "<leader>gP", "<cmd>Neogit push<cr>", { desc = "Git Push" })

-- Diffview (Visual Diffs & History)
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git Diff (Diffview)" })
map("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close Git Diff" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git File History" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Git Project History" })

-- Telescope Git Picker
map("n", "<leader>gb", function()
  require("telescope.builtin").git_branches()
end, { desc = "Git Branches" })
map("n", "<leader>gl", function()
  require("telescope.builtin").git_commits()
end, { desc = "Git Commits Log" })

-- Gitsigns (Inline Git indicators & hunk actions)
map("n", "]h", function()
  if vim.wo.diff then return "]h" end
  vim.schedule(function()
    require("gitsigns").next_hunk()
  end)
  return "<Ignore>"
end, { expr = true, desc = "Next Git Hunk" })

map("n", "[h", function()
  if vim.wo.diff then return "[h" end
  vim.schedule(function()
    require("gitsigns").prev_hunk()
  end)
  return "<Ignore>"
end, { expr = true, desc = "Previous Git Hunk" })

map("n", "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", { desc = "Stage Git Hunk" })
map("n", "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset Git Hunk" })
map("v", "<leader>ghs", function()
  require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Stage Git Hunk (Visual)" })
map("v", "<leader>ghr", function()
  require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Reset Git Hunk (Visual)" })
map("n", "<leader>ghp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview Git Hunk" })
map("n", "<leader>gbl", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Toggle Line Blame" })

-- --- WINDOW MANAGEMENT (<leader>w) ---
map("n", "<leader>ww", "<cmd>wincmd w<cr>", { desc = "Switch to Other Window" })
map("n", "<leader>wd", "<cmd>wincmd c<cr>", { desc = "Close Window" })
map("n", "<leader>wo", "<cmd>wincmd o<cr>", { desc = "Maximize / Only Window" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split Horizontally" })
map("n", "<leader>w-", "<cmd>split<cr>", { desc = "Split Horizontally" })
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split Vertically" })
map("n", "<leader>w|", "<cmd>vsplit<cr>", { desc = "Split Vertically" })
map("n", "<leader>w=", "<cmd>wincmd =<cr>", { desc = "Equalize Window Sizes" })
map("n", "<leader>wt", "<cmd>wincmd T<cr>", { desc = "Move Window to New Tab" })

-- Resize window
map("n", "<leader>w+", "<cmd>resize +5<cr>", { desc = "Increase Height" })
map("n", "<leader>w_", "<cmd>resize -5<cr>", { desc = "Decrease Height" })
map("n", "<leader>w>", "<cmd>vertical resize +5<cr>", { desc = "Increase Width" })
map("n", "<leader>w<", "<cmd>vertical resize -5<cr>", { desc = "Decrease Width" })

-- Resize window with Alt + Shift + Setas / HJKL
map("n", "<A-S-Up>", "<cmd>resize +2<cr>", { desc = "Increase Height" })
map("n", "<A-S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Height" })
map("n", "<A-S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Width" })
map("n", "<A-S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Width" })

map("n", "<A-K>", "<cmd>resize +2<cr>", { desc = "Increase Height" })
map("n", "<A-J>", "<cmd>resize -2<cr>", { desc = "Decrease Height" })
map("n", "<A-H>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Width" })
map("n", "<A-L>", "<cmd>vertical resize +2<cr>", { desc = "Increase Width" })

-- Move window position
map("n", "<leader>wH", "<cmd>wincmd H<cr>", { desc = "Move Window to Left" })
map("n", "<leader>wJ", "<cmd>wincmd J<cr>", { desc = "Move Window to Bottom" })
map("n", "<leader>wK", "<cmd>wincmd K<cr>", { desc = "Move Window to Top" })
map("n", "<leader>wL", "<cmd>wincmd L<cr>", { desc = "Move Window to Right" })
