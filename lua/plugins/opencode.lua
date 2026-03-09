return {
  "jaswdr/opencode-completion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    -- Tenta iniciar o servidor do OpenCode em background de forma silenciosa e atrelada ao Neovim.
    -- O servidor morrerá junto com o Neovim que o abriu.
    -- Se a porta já estiver ocupada (por exemplo, se você já tiver outro Neovim aberto), ele só vai falhar silenciosamente.
    vim.fn.jobstart({ "opencode", "serve", "--port=4096" }, {
      clear_env = false,
      -- Ocultar saída para não encher o log do seu Neovim
      on_stdout = function(_, _) end,
      on_stderr = function(_, _) end,
    })

    require("opencode-completion").setup()
  end,
  keys = {
    -- Mapeamento padrão do plugin para acionar o autocomplete (Ctrl + L)
    { "<C-l>", ":OpenCodeComplete<CR>", mode = { "n", "i" }, desc = "OpenCode: Autocomplete" },
  },
}
