return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = { enabled = false },
        tsserver = { enabled = true },
        ts_ls = { enabled = true },
      },
    },
  },
}
