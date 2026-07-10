
local ok_mason, mason = pcall(require, "mason")
local ok_mason_lsp, mason_lsp = pcall(require, "mason-lspconfig")
local ok_lspconfig, lspconfig = pcall(require, "lspconfig")

if ok_mason then
  mason.setup()
end

if ok_mason_lsp and ok_lspconfig then

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


  if vim.lsp.config then
    vim.lsp.config("*", {
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 50,
      }
    })
  end


  if vim.lsp.config then

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME,
            },
          },
          telemetry = {
            enable = false,
          },
        },
      },
    })
  end


  mason_lsp.setup({
    ensure_installed = { "lua_ls" },
  })
end
