return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_hidden = false,
        hide_by_name = {
          "node_modules",
          ".git",
          "*.DS_Store",
          "thumbs.db",
        },
      },
    },
  },
}
