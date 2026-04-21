return {
  "mrf/gemini-code-assist.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("gemini").setup()
  end,
}
