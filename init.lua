-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Setup package manager (clones missing plugins using vim.pack)
require("pack_manager").setup()

-- Load options
require("options")

-- Load keymaps
require("keymaps")

-- Load autocommands
require("autocmds")

-- Load plugin configurations
require("plugin_configs")
