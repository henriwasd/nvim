-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Setup package manager (clones missing plugins using vim.pack)
require("pack_manager").setup()

-- Load core configurations
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Load plugin configurations
require("plugins")
