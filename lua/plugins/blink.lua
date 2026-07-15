return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
        },
        list = {
          max_items = 100,
        },
      },
      sources = {
        providers = {
          lsp = {
            async = true,
            timeout_ms = 1000,
          },
        },
      },
    },
  },
}
