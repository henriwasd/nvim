
vim.g.mapleader = " "
vim.g.maplocalleader = " "


require("pack_manager").setup()


require("core.options")
require("core.keymaps")
require("core.autocmds")


require("plugins")
