return {
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    cmd = "Oil",
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "Open parent directory with Oil" },
    },
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
      },
      win_options = {
        signcolumn = "yes:2",
      },
      keymaps = {
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<Esc>"] = "actions.close",
      },
    },
  },
  {
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    event = "VeryLazy",
    config = true,
  },
  {
    "JezerM/oil-lsp-diagnostics.nvim",
    dependencies = { "stevearc/oil.nvim" },
    event = "VeryLazy",
    config = true,
  },
}
