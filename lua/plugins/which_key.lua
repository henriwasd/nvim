local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
  wk.setup({
    preset = "classic",
  })
  wk.add({
    { "<leader>a", group = "AI / Supermaven" },
    { "<leader>b", group = "Buffer" },
    { "<leader>c", group = "Code / LSP" },
    { "<leader>d", group = "Debug" },
    { "<leader>f", group = "File" },
    { "<leader>g", group = "Git" },
    { "<leader>h", group = "Git Hunk" },
    { "<leader>s", group = "Search" },
    { "<leader>t", group = "Toggle" },
    { "<leader>w", group = "Window" },
  })
end
