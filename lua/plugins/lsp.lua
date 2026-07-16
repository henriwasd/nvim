return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Desativa o vtsls completamente (que está travando no Windows)
        vtsls = { enabled = false },
        -- Ativa o tsserver / ts_ls tradicional (muito mais estável e maduro)
        tsserver = { enabled = true },
        ts_ls = { enabled = true },
      },
    },
  },
}
