return {
  {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    lazy = true,
    config = function()
      require("flutter-tools").setup({
        decorations = {
          statusline = {
            app_version = false,
            device = false,
          },
        },
        debugger = {
          enabled = true,
        },
        dev_log = {
          enabled = false,
        },
        lsp = {
          settings = {
            lineLength = 160,
            renameFilesWithClasses = "always",
            documentation = "full",
            widget_guides = true,
          },
        },
      })
    end,
  },
}
