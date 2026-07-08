
vim.g.matchup_matchparen_deferred = 1
vim.g.matchup_matchparen_offscreen = { method = "popup" }

local file_utils = require("utils.file")
local ok_ts, ts = pcall(require, "nvim-treesitter.configs")
if ok_ts then
  ts.setup({
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "markdown",
      "markdown_inline",
      "javascript",
      "typescript",
      "dart",
      "html",
      "tsx",
    },
    highlight = {
      enable = true,
      disable = function(lang, buf)
        return file_utils.is_large_file(buf)
      end,
    },
    indent = {
      enable = true,
      disable = function(lang, buf)
        return file_utils.is_large_file(buf)
      end,
    },
    matchup = {
      enable = true,
      disable = function(lang, buf)
        return file_utils.is_large_file(buf)
      end,
    },
  })
end
