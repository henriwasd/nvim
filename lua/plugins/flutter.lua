return {
  {
    "akinsho/flutter-tools.nvim",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
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
        opts = {
          inlay_hints = {
            enabled = false,
          },
        },
      })
    end,
  },
}
