-- Your nvim-dap config
return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
      {
        "igorlfs/nvim-dap-view",
        opts = {
          winbar = {
            show = true,
            -- You can add a "console" section to merge the terminal with the other views
            sections = { "watches", "exceptions", "breakpoints", "threads", "repl" },
            -- Must be one of the sections declared above
            default_section = "repl",
          },
          windows = {
            height = 12,
            terminal = {
              -- 'left'|'right'|'above'|'below': Terminal position in layout
              position = "left",
              -- List of debug adapters for which the terminal should be ALWAYS hidden
              hide = {},
              -- Hide the terminal when starting a new session
              start_hidden = false,
            },
          },
        },
      },
    },
  },
}
