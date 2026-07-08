local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
  wk.setup({
    preset = "classic",
  })
  wk.add({
    { "<leader>w", group = "Window" },
    { "<leader>b", group = "Buffer" },
    { "<leader>a", group = "AI / Supermaven" },
  })
end
