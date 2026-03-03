return {
  {
    "NeogitOrg/neogit",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- highly recommended for diffs
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = function()
      require("neogit").setup({
        -- Neogit options go here
        integrations = {
          diffview = true,
          telescope = true,
        },
      })
    end,
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit (Git GUI)" },
      -- Adicionalmente para Diffs puros:
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Current File History" },
    },
  },
}
