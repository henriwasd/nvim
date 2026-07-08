
require("plugins.colorscheme")
require("plugins.lualine")
require("plugins.bufferline")


vim.schedule(function()
  require("plugins.telescope")
  require("plugins.treesitter")
  require("plugins.cmp")
  require("plugins.lsp")
  require("plugins.conform")
  require("plugins.others")
end)
