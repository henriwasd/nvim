return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = { enabled = false },
        tsserver = { enabled = false },
        ts_ls = {
          enabled = true,
          cmd = function(dispatchers, config)
            local cmd = "typescript-language-server"
            if (config or {}).root_dir then
              local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules/.bin", cmd)
              if vim.fn.has("win32") == 1 then
                local_cmd = local_cmd .. ".cmd"
              end
              if vim.fn.executable(local_cmd) == 1 then
                cmd = local_cmd
              end
            end
            if vim.fn.has("win32") == 1 and cmd == "typescript-language-server" then
              if vim.fn.executable("typescript-language-server.cmd") == 1 then
                cmd = "typescript-language-server.cmd"
              end
            end
            return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers)
          end,
        },
      },
    },
  },
}
