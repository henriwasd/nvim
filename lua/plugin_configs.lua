-- =============================================================================
-- ESSENTIAL PLUGIN CONFIGURATIONS (Loaded synchronously at startup)
-- =============================================================================

-- 1. Colorscheme (Gruvbox)
local ok_gruvbox, gruvbox = pcall(require, "gruvbox")
if ok_gruvbox then
  gruvbox.setup({
    transparent_mode = true,
  })
  vim.cmd("colorscheme gruvbox")
end

-- 2. Statusline (Lualine)
local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
  -- Async git status tracking
  local git_status_cache = {
    branch = "",
    ahead = 0,
    behind = 0,
    staged = 0,
    unstaged = 0,
    untracked = 0,
    conflicted = 0,
  }

  local function parse_git_status(stdout)
    local branch = ""
    local ahead = 0
    local behind = 0
    local staged = 0
    local unstaged = 0
    local untracked = 0
    local conflicted = 0

    for line in string.gmatch(stdout, "[^\r\n]+") do
      if string.match(line, "^# branch.head") then
        branch = string.match(line, "^# branch.head%s+(.+)") or ""
      elseif string.match(line, "^# branch.ab") then
        local a, b = string.match(line, "^# branch.ab%s+%+(%d+)%s+%-(%d+)")
        ahead = tonumber(a) or 0
        behind = tonumber(b) or 0
      elseif string.match(line, "^%?") then
        untracked = untracked + 1
      elseif string.match(line, "^[12]") then
        local xy = string.match(line, "^[12]%s+(%S+)")
        if xy then
          local x = string.sub(xy, 1, 1)
          local y = string.sub(xy, 2, 2)
          if x ~= "." then
            staged = staged + 1
          end
          if y ~= "." then
            unstaged = unstaged + 1
          end
        end
      elseif string.match(line, "^u") then
        conflicted = conflicted + 1
      end
    end

    return {
      branch = branch,
      ahead = ahead,
      behind = behind,
      staged = staged,
      unstaged = unstaged,
      untracked = untracked,
      conflicted = conflicted,
    }
  end

  local function update_git_status()
    local buftype = vim.bo.buftype
    if buftype ~= "" then
      return
    end

    local git_root = vim.fs.root(0, ".git") or vim.fs.root(vim.fn.getcwd(), ".git")
    if not git_root then
      git_status_cache.branch = ""
      return
    end

    vim.system(
      { "git", "status", "--porcelain=v2", "--branch" },
      { text = true, cwd = git_root },
      function(obj)
        if obj.code == 0 and obj.stdout then
          local status = parse_git_status(obj.stdout)
          git_status_cache = status
        else
          git_status_cache.branch = ""
        end
        vim.schedule(function()
          vim.cmd("redrawstatus")
        end)
      end
    )
  end

  -- Start periodic polling and auto-commands for status updates
  local uv = vim.uv or vim.loop
  if uv then
    local git_timer = uv.new_timer()
    if git_timer then
      git_timer:start(0, 30000, vim.schedule_wrap(update_git_status))
    end
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
    callback = function()
      update_git_status()
    end,
  })

  -- Component to show git status information (ahead/behind, changes)
  local function get_git_status_str()
    if git_status_cache.branch == "" then
      return ""
    end

    local parts = {}

    -- Ahead / Behind (pull/push dependencies)
    if git_status_cache.ahead > 0 then
      table.insert(parts, "⇡" .. git_status_cache.ahead)
    end
    if git_status_cache.behind > 0 then
      table.insert(parts, "⇣" .. git_status_cache.behind)
    end

    -- Files changed (staged, unstaged, untracked, conflicted)
    local changes = {}
    if git_status_cache.staged > 0 then
      table.insert(changes, "●" .. git_status_cache.staged)
    end
    if git_status_cache.unstaged > 0 then
      table.insert(changes, "✚" .. git_status_cache.unstaged)
    end
    if git_status_cache.untracked > 0 then
      table.insert(changes, "…" .. git_status_cache.untracked)
    end
    if git_status_cache.conflicted > 0 then
      table.insert(changes, "!" .. git_status_cache.conflicted)
    end

    if #changes > 0 then
      table.insert(parts, "[" .. table.concat(changes, " ") .. "]")
    end

    return table.concat(parts, " ")
  end

  lualine.setup({
    options = {
      theme = "gruvbox",
      component_separators = "|",
      section_separators = "",
      globalstatus = true,
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        { "branch", icon = "" },
        {
          get_git_status_str,
          color = { fg = "#fe8019" }, -- Gruvbox orange for beautiful accent color
        },
      },
      lualine_c = {
        {
          "filename",
          path = 1, -- 0: Just filename, 1: Relative path, 2: Absolute path, 3: Absolute path with tilde
        },
      },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = { error = " ", warn = " ", info = " ", hint = " " },
        },
        "encoding",
        "fileformat",
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })
end

-- 3. Tabline (Bufferline)
local ok_bufferline, bufferline = pcall(require, "bufferline")
if ok_bufferline then
  bufferline.setup({
    options = {
      offsets = {
        {
          filetype = "neo-tree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  })
end
