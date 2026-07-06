-- 8. LSP config (Mason & Mason-lspconfig & nvim-lspconfig)
local ok_mason, mason = pcall(require, "mason")
local ok_mason_lsp, mason_lsp = pcall(require, "mason-lspconfig")
local ok_lspconfig, lspconfig = pcall(require, "lspconfig")

if ok_mason then
  mason.setup()
end

if ok_mason_lsp and ok_lspconfig then
  -- Configure global defaults (capabilities, etc.)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp_lsp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end
  local ok_lsp_file_ops, lsp_file_ops = pcall(require, "lsp-file-operations")
  if ok_lsp_file_ops then
    lsp_file_ops.setup()
    capabilities = vim.tbl_deep_extend("force", capabilities, lsp_file_ops.default_capabilities())
  end

  -- Apply capabilities globally for all servers natively (including completion capabilities)
  if vim.lsp.config then
    vim.lsp.config("*", { capabilities = capabilities })
  end

  -- Customize specific servers natively
  if vim.lsp.config then
    -- lua_ls configuration (essential to avoid undefined global 'vim' warnings in neovim config files)
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    })
  end

  -- Setup mason-lspconfig (mason-lspconfig v2.0.0+ automatically manages and enables all installed servers natively)
  mason_lsp.setup({
    ensure_installed = { "lua_ls" },
  })
end
