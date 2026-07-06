-- 8.5 Auto-formatting (conform.nvim)
local ok_conform, conform = pcall(require, "conform")
if ok_conform then
  conform.setup({
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "biome-check", "biome", "prettierd", "prettier", stop_after_first = true },
      typescript = { "biome-check", "biome", "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "biome-check", "biome", "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "biome-check", "biome", "prettierd", "prettier", stop_after_first = true },
      json = { "biome-check", "biome", stop_after_first = true },
      jsonc = { "biome-check", "biome", stop_after_first = true },
      dart = { "dart_format" },
    },
    formatters = {
      ["biome-check"] = {
        condition = function(self, ctx)
          return vim.fs.root(ctx.filename, { "biome.json", "biome.jsonc" }) ~= nil
        end,
      },
      biome = {
        condition = function(self, ctx)
          return vim.fs.root(ctx.filename, { "biome.json", "biome.jsonc" }) ~= nil
        end,
      },
    },
    -- format_on_save = {
    --   timeout_ms = 2000,
    --   lsp_fallback = true,
    -- },
  })
end
