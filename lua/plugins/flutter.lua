return {
  {
    "akinsho/flutter-tools.nvim",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
      -- "migbyte-0/archflow-nvim",
      -- config = function()
      --   require("archflow").setup()
      -- end,
    },
    config = function()
      require("flutter-tools").setup({
        debugger = {
          enabled = true,
        },
        dev_log = {
          enabled = false,
        },
        lsp = {
          settings = {
            lineLength = 160,
          },
        },
      })
      require("lspconfig").dartls.setup({
        cmd = { "dart", "language-server", "--protocol=lsp" },
        opts = {
          inlay_hints = {
            enabled = false,
          },
        },
      })
    end,
  },
}
