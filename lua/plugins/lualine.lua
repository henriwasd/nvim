
local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then

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


  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
    callback = function()
      update_git_status()
    end,
  })


  local function get_git_status_str()
    if git_status_cache.branch == "" then
      return ""
    end

    local parts = {}


    if git_status_cache.ahead > 0 then
      table.insert(parts, "⇡" .. git_status_cache.ahead)
    end
    if git_status_cache.behind > 0 then
      table.insert(parts, "⇣" .. git_status_cache.behind)
    end


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
          color = { fg = "#fe8019" },
        },
      },
      lualine_c = {
        {
          "filename",
          path = 1,
        },
      },
      lualine_x = {
        {
          "diagnostics",
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
