-- 100% Native Pure Lua Statusline (Zero Plugins)
local M = {}

local modes = {
  ["n"]  = { "NORMAL", "StatusNormal" },
  ["no"] = { "N·OP",   "StatusNormal" },
  ["v"]  = { "VISUAL", "StatusVisual" },
  ["V"]  = { "V·LINE", "StatusVisual" },
  ["\22"]= { "V·BLOCK","StatusVisual" },
  ["s"]  = { "SELECT", "StatusVisual" },
  ["S"]  = { "S·LINE", "StatusVisual" },
  ["i"]  = { "INSERT", "StatusInsert" },
  ["ic"] = { "INSERT", "StatusInsert" },
  ["R"]  = { "REPLACE","StatusReplace" },
  ["Rv"] = { "V·REPLACE", "StatusReplace" },
  ["c"]  = { "COMMAND","StatusCommand" },
  ["cv"] = { "VIM EX","StatusCommand" },
  ["ce"] = { "EX",    "StatusCommand" },
  ["r"]  = { "PROMPT", "StatusCommand" },
  ["rm"] = { "MORE",   "StatusCommand" },
  ["r?"] = { "CONFIRM","StatusCommand" },
  ["!"]  = { "SHELL",  "StatusCommand" },
  ["t"]  = { "TERM",   "StatusTerminal" },
}

local function get_git_branch()
  local branch = vim.b.git_branch
  if branch ~= nil then return branch end

  local git_dir = vim.fs.find(".git", { upward = true, path = vim.fn.expand("%:p:h") })[1]
  if not git_dir then
    vim.b.git_branch = ""
    return ""
  end

  local head_file = io.open(git_dir .. "/HEAD", "r")
  if head_file then
    local content = head_file:read("*l") or ""
    head_file:close()
    local b = content:match("ref: refs/heads/(.+)")
    if b then
      vim.b.git_branch = "  " .. b .. " "
      return vim.b.git_branch
    end
  end
  vim.b.git_branch = ""
  return ""
end

local function get_diagnostics()
  local count_e = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local count_w = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local diag = ""
  if count_e > 0 then
    diag = diag .. " %#DiagnosticError#E:" .. count_e .. "%*"
  end
  if count_w > 0 then
    diag = diag .. " %#DiagnosticWarn#W:" .. count_w .. "%*"
  end
  return diag
end

function M.render()
  local mode_info = modes[vim.fn.mode()] or { "UNKNOWN", "StatusNormal" }
  local mode_str = string.format("%%#%s# %s %%*", mode_info[2], mode_info[1])
  local branch = get_git_branch()
  local diag = get_diagnostics()

  return table.concat({
    mode_str,
    branch ~= "" and ("%#StatusSub# " .. branch .. "%*") or "",
    " %f %m%r",
    "%=",
    diag,
    " %#StatusSub# %Y │ %l:%c │ %p%% %*",
  })
end

function M.setup()
  -- Statusline colors harmonious with retrobox / gruvbox
  vim.api.nvim_set_hl(0, "StatusNormal",   { fg = "#282828", bg = "#83a598", bold = true })
  vim.api.nvim_set_hl(0, "StatusInsert",   { fg = "#282828", bg = "#b8bb26", bold = true })
  vim.api.nvim_set_hl(0, "StatusVisual",   { fg = "#282828", bg = "#fabd2f", bold = true })
  vim.api.nvim_set_hl(0, "StatusReplace",  { fg = "#282828", bg = "#fb4934", bold = true })
  vim.api.nvim_set_hl(0, "StatusCommand",  { fg = "#282828", bg = "#fe8019", bold = true })
  vim.api.nvim_set_hl(0, "StatusTerminal", { fg = "#282828", bg = "#d3869b", bold = true })
  vim.api.nvim_set_hl(0, "StatusSub",      { fg = "#ebdbb2", bg = "#3c3836" })

  vim.o.laststatus = 3 -- Global statusline
  vim.o.statusline = "%!v:lua.require'config.statusline'.render()"
end

return M
