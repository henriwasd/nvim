-- Git interface (Neogit)
local ok_neogit, neogit = pcall(require, "neogit")
if not ok_neogit then
  return
end

neogit.setup({
  disable_commit_confirmation = true,
  graph_style = "unicode",
  -- Open Neogit in a new tab to feel like a full-screen application (similar to Lazygit)
  kind = "tab",
  commit_editor = {
    kind = "tab",
  },
  popup = {
    kind = "split",
  },
  integrations = {
    diffview = false,
    telescope = true,
  },
})
