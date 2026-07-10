local map = vim.keymap.set


map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })


map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clean search highlights" })


local term = require("utils.terminal")

map({ "n", "t" }, "<C-/>", term.toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-_>", term.toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-`>", term.toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-~>", term.toggle_terminal, { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-\\>", term.toggle_terminal, { desc = "Toggle Terminal (Fallback)" })


map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })


local function buf_delete()
  local bufnr = vim.api.nvim_get_current_buf()
  local bd = vim.api.nvim_buf_delete

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


  local buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())


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


  if not target_buf then
    target_buf = vim.api.nvim_create_buf(true, false)
  end


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


local function new_split_terminal()
  vim.cmd("botright split | terminal")
  vim.cmd("startinsert")
end
map({ "n", "t" }, "<C-S-`>", new_split_terminal, { desc = "New Split Terminal" })


map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down", silent = true })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up", silent = true })


map({ "n", "v" }, "<C-a>", "ggVG", { desc = "Select all" })

map({ "n", "i", "x" }, "<C-s>", "<cmd>w<cr>", { desc = "Save File" })


local fmt = require("utils.format")
map({ "n", "v" }, "<leader>cf", function() fmt.format_buffer({ async = true }) end,
  { desc = "Format Document / Selection" })


map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })



map({ "n", "i", "v", "t" }, "<C-Left>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map({ "n", "i", "v", "t" }, "<C-Down>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map({ "n", "i", "v", "t" }, "<C-Up>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map({ "n", "i", "v", "t" }, "<C-Right>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })


map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })


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


local function get_visual_selection()
  local old_reg = vim.fn.getreg("v")
  local old_regtype = vim.fn.getregtype("v")

  vim.cmd('noau normal! "vy')
  local text = vim.fn.getreg("v")

  vim.fn.setreg("v", old_reg, old_regtype)


  text = string.gsub(text, "\n", "")
  text = string.gsub(text, "\r", "")
  return text
end

map("n", "<leader>sg", live_grep, { desc = "Grep (root dir)" })
map("n", "<leader>/", live_grep, { desc = "Grep (root dir)" })


map("n", "<leader>ss", fuzzy_find, { desc = "Search in Current File" })


map("v", "<leader>sg", function()
  local text = get_visual_selection()
  require("telescope.builtin").grep_string({ search = text })
end, { desc = "Search Selection in Project" })


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


map("n", "<C-k>z", "<cmd>silent! normal! za<CR>", { desc = "Toggle Fold (Silent)" })
map("n", "za", "<cmd>silent! normal! za<CR>", { desc = "Toggle Fold (Silent)" })
map("n", "zo", "<cmd>silent! normal! zo<CR>", { desc = "Open Fold (Silent)" })
map("n", "zc", "<cmd>silent! normal! zc<CR>", { desc = "Close Fold (Silent)" })
map("n", "zR", "<cmd>silent! normal! zR<CR>", { desc = "Open All Folds (Silent)" })
map("n", "zM", "<cmd>silent! normal! zM<CR>", { desc = "Close All Folds (Silent)" })



map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Open parent directory with Oil" })


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


map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "pd", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "nd", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })



map("n", "<leader>ww", "<cmd>wincmd w<cr>", { desc = "Switch to Other Window" })
map("n", "<leader>wd", "<cmd>wincmd c<cr>", { desc = "Close Window" })
map("n", "<leader>wo", "<cmd>wincmd o<cr>", { desc = "Maximize / Only Window" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split Horizontally" })
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split Vertically" })
map("n", "<leader>w=", "<cmd>wincmd =<cr>", { desc = "Equalize Window Sizes" })
map("n", "<leader>wt", "<cmd>wincmd T<cr>", { desc = "Move Window to New Tab" })


map("n", "<leader>w+", "<cmd>resize +5<cr>", { desc = "Increase Height" })
map("n", "<leader>w_", "<cmd>resize -5<cr>", { desc = "Decrease Height" })
map("n", "<leader>w>", "<cmd>vertical resize +5<cr>", { desc = "Increase Width" })
map("n", "<leader>w<", "<cmd>vertical resize -5<cr>", { desc = "Decrease Width" })


map({ "n", "i", "v", "t" }, "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase Height" })
map({ "n", "i", "v", "t" }, "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Height" })
map({ "n", "i", "v", "t" }, "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Width" })
map({ "n", "i", "v", "t" }, "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Width" })


map("n", "<leader>wH", "<cmd>wincmd H<cr>", { desc = "Move Window to Left" })
map("n", "<leader>wJ", "<cmd>wincmd J<cr>", { desc = "Move Window to Bottom" })
map("n", "<leader>wK", "<cmd>wincmd K<cr>", { desc = "Move Window to Top" })
map("n", "<leader>wL", "<cmd>wincmd L<cr>", { desc = "Move Window to Right" })





map("n", "<leader>as", "<cmd>SupermavenStart<cr>", { desc = "Start Supermaven AI" })
map("n", "<leader>ap", "<cmd>SupermavenStop<cr>", { desc = "Stop Supermaven AI" })
map("n", "<leader>at", "<cmd>SupermavenToggle<cr>", { desc = "Toggle Supermaven AI" })

