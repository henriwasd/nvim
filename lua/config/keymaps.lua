-- Native Keymaps
local map = vim.keymap.set

-- Desativa a acao padrao da barra de espaco no modo Normal e Visual para funcionar puramente como Leader
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Selecionar tudo
map({ "n", "v" }, "<C-a>", "ggVG", { desc = "Select all" })

-- Salvar rapido (sem formatar)
map({ "n", "i", "x" }, "<C-s>", "<cmd>noautocmd w<cr>", { desc = "Save File (No Format)" })

-- Area de transferencia do sistema (Clipboard)
map("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
map("v", "<C-v>", '"+p', { desc = "Paste from clipboard" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })

-- Redimensionar janelas com Alt + Setas
map({ "n", "i", "v", "t" }, "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase Height" })
map({ "n", "i", "v", "t" }, "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Height" })
map({ "n", "i", "v", "t" }, "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Width" })
map({ "n", "i", "v", "t" }, "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Width" })

-- Navegacao entre janelas com Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- Navegacao de buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

-- Terminal Flutuante Nativo (Zero Plugins)
local terminal = require("config.terminal")
map({ "n", "t" }, "<C-/>", function() terminal.toggle({ cwd = vim.fn.getcwd() }) end, { desc = "Toggle Terminal (CWD)" })
map({ "n", "t" }, "<c-_>", function() terminal.toggle({ cwd = vim.fn.getcwd() }) end, { desc = "Toggle Terminal (CWD)" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Explorador de arquivos (Oil.nvim)
map("n", "<leader>e", function()
  local ok, oil = pcall(require, "oil")
  if ok then oil.open() else vim.cmd("Ex") end
end, { desc = "Explorer (Oil)" })

-- Menu de Busca e Navegacao (<leader>f)
local pick = function(fn_name)
  return function()
    local ok, p = pcall(require, "mini.pick")
    if ok and p.builtin[fn_name] then
      p.builtin[fn_name]()
    end
  end
end

map("n", "<leader>ff", pick("files"), { desc = "Find Files" })
map("n", "<leader>fg", pick("grep_live"), { desc = "Live Grep" })
map("n", "<leader>fb", pick("buffers"), { desc = "Buffers" })
map("n", "<leader>ft", function() terminal.toggle({ cwd = vim.fn.getcwd() }) end, { desc = "Terminal (cwd)" })
map("n", "<leader>fh", pick("help"), { desc = "Help Tags" })

-- Menu de Codigo & LSP (<leader>c)
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format Document" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP Info" })

-- Navegacao LSP & Diagnosticos
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- Limpar destaque de busca ao pressionar Esc no modo Normal
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>", { desc = "Clear Search Highlights" })

-- Manter selecao ao indentar no modo visual
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Mover linhas selecionadas para cima ou baixo
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move Selection Down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move Selection Up" })

-- Comportamento ergonomico do Menu de Autocomplete Nativo
map("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif vim.snippet and vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
    return ""
  else
    return "<Tab>"
  end
end, { expr = true, silent = true, desc = "Next Completion Item or Snippet Jump" })

map("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  elseif vim.snippet and vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
    return ""
  else
    return "<S-Tab>"
  end
end, { expr = true, silent = true, desc = "Previous Completion Item or Snippet Jump" })

map("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-y>"
  else
    return "<CR>"
  end
end, { expr = true, silent = true, desc = "Accept Completion or Newline" })
