return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach", -- Carrega assim que um servidor LSP for anexado
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
