local M = {}

local pack_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start/"

M.plugins = {

  { repo = "ellisonleao/gruvbox.nvim",               name = "gruvbox.nvim" },


  { repo = "nvim-tree/nvim-web-devicons",            name = "nvim-web-devicons" },


  { repo = "nvim-lualine/lualine.nvim",              name = "lualine.nvim" },
  { repo = "akinsho/bufferline.nvim",                name = "bufferline.nvim" },


  { repo = "nvim-lua/plenary.nvim",                  name = "plenary.nvim" },
  { repo = "MunifTanjim/nui.nvim",                   name = "nui.nvim" },


  { repo = "stevearc/oil.nvim",                      name = "oil.nvim" },
  { repo = "refractalize/oil-git-status.nvim",       name = "oil-git-status.nvim" },
  { repo = "JezerM/oil-lsp-diagnostics.nvim",        name = "oil-lsp-diagnostics.nvim" },
  { repo = "MagicDuck/grug-far.nvim",                name = "grug-far.nvim" },
  { repo = "antosha417/nvim-lsp-file-operations",    name = "nvim-lsp-file-operations" },
  { repo = "smjonas/inc-rename.nvim",                name = "inc-rename.nvim" },


  { repo = "nvim-telescope/telescope.nvim",          name = "telescope.nvim" },


  { repo = "neovim/nvim-lspconfig",                  name = "nvim-lspconfig" },
  { repo = "williamboman/mason.nvim",                name = "mason.nvim" },
  { repo = "williamboman/mason-lspconfig.nvim",      name = "mason-lspconfig.nvim" },
  { repo = "stevearc/conform.nvim",                  name = "conform.nvim" },


  { repo = "hrsh7th/nvim-cmp",                       name = "nvim-cmp" },
  { repo = "hrsh7th/cmp-nvim-lsp",                   name = "cmp-nvim-lsp" },
  { repo = "hrsh7th/cmp-buffer",                     name = "cmp-buffer" },
  { repo = "hrsh7th/cmp-path",                       name = "cmp-path" },
  { repo = "hrsh7th/cmp-nvim-lsp-signature-help",    name = "cmp-nvim-lsp-signature-help" },
  { repo = "L3MON4D3/LuaSnip",                       name = "LuaSnip" },
  { repo = "saadparwaiz1/cmp_luasnip",               name = "cmp_luasnip" },


  { repo = "andymass/vim-matchup",                   name = "vim-matchup" },
  { repo = "windwp/nvim-ts-autotag",                 name = "nvim-ts-autotag" },
  { repo = "echasnovski/mini.pairs",                 name = "mini.pairs" },
  { repo = "echasnovski/mini.surround",              name = "mini.surround" },
  { repo = "mg979/vim-visual-multi",                 name = "vim-visual-multi" },
  { repo = "supermaven-inc/supermaven-nvim",         name = "supermaven-nvim" },
  { repo = "folke/which-key.nvim",                   name = "which-key.nvim" },
  { repo = "folke/ts-comments.nvim",                 name = "ts-comments.nvim" },


  { repo = "nvim-treesitter/nvim-treesitter",        name = "nvim-treesitter" },


  { repo = "mfussenegger/nvim-dap",                  name = "nvim-dap" },
  { repo = "rcarriga/nvim-dap-ui",                   name = "nvim-dap-ui" },
  { repo = "theHamsta/nvim-dap-virtual-text",        name = "nvim-dap-virtual-text" },
  { repo = "nvim-neotest/nvim-nio",                  name = "nvim-nio" },


  { repo = "akinsho/flutter-tools.nvim",             name = "flutter-tools.nvim" },
  { repo = "stevearc/dressing.nvim",                 name = "dressing.nvim" },


  { repo = "echasnovski/mini.hipatterns",            name = "mini.hipatterns" },
  { repo = "rachartier/tiny-inline-diagnostic.nvim", name = "tiny-inline-diagnostic.nvim" },
  { repo = "lewis6991/gitsigns.nvim",                name = "gitsigns.nvim" },
  { repo = "tpope/vim-fugitive",                      name = "vim-fugitive" }
}

function M.bootstrap()
  local missing = false
  local fs = vim.uv or vim.loop
  for _, p in ipairs(M.plugins) do
    local dir = pack_path .. p.name
    if not fs.fs_stat(dir) then
      missing = true
      print("Installing " .. p.name .. "...")
      vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/" .. p.repo .. ".git", dir })

      vim.opt.rtp:append(dir)
    end
  end
  if missing then
    vim.notify("All plugins installed! Please restart Neovim if some features do not work.", vim.log.levels.INFO)
  end
end

function M.update()
  print("Updating plugins...")
  for _, p in ipairs(M.plugins) do
    local dir = pack_path .. p.name
    if vim.fn.empty(vim.fn.glob(dir)) == 0 then
      print("Updating " .. p.name .. "...")
      local out = vim.fn.system({ "git", "-C", dir, "pull" })
      print(out)
    end
  end
  print("Plugins update finished!")
end

function M.clean()
  local installed = vim.fn.glob(pack_path .. "*", true, true)
  local declared = {}
  for _, p in ipairs(M.plugins) do
    declared[p.name] = true
  end
  for _, path in ipairs(installed) do
    local name = vim.fs.basename(path)
    if not declared[name] then
      print("Removing unused plugin: " .. name)
      vim.fn.delete(path, "rf")
    end
  end
  print("Clean finished!")
end

function M.setup()
  M.bootstrap()


  vim.api.nvim_create_user_command("PackUpdate", function()
    M.update()
  end, {})
  vim.api.nvim_create_user_command("PackClean", function()
    M.clean()
  end, {})
end

return M
