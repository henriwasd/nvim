-- Your nvim-dap config
return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
      { "igorlfs/nvim-dap-view", opts = {} },
    },
  },
}
