-- Native LSP Setup (Neovim 0.11 / 0.12+ Native Architecture)
local M = {}

function M.setup()
  -- Configuracao visual nativa de diagnosticos
  vim.diagnostic.config({
    virtual_text = {
      prefix = "●",
      spacing = 2,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "always",
    },
  })

  -- Definicao de icones nos sinais da coluna lateral
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  -- Autocomando executado ao conectar qualquer servidor LSP
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local bufnr = args.buf

      -- Habilita Autocomplete Nativo do Neovim (vim.lsp.completion)
      if client and client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      end
    end,
  })

  -- Comando utilitario para abrir os logs do LSP diretamente
  vim.api.nvim_create_user_command("LspLog", function()
    local path = vim.lsp.log.get_filename and vim.lsp.log.get_filename() or vim.lsp.get_log_path()
    vim.cmd.edit(path)
  end, { desc = "Open LSP log file" })

  -- Helper para resolver o executavel do TypeScript Language Server no Windows e Unix
  local function resolve_ts_cmd(root_dir)
    local base = "typescript-language-server"
    if root_dir then
      local local_cmd = vim.fs.joinpath(root_dir, "node_modules", ".bin", base)
      if vim.fn.has("win32") == 1 then
        local_cmd = local_cmd .. ".cmd"
      end
      if vim.fn.executable(local_cmd) == 1 then
        return local_cmd
      end
    end
    if vim.fn.has("win32") == 1 then
      if vim.fn.executable(base .. ".cmd") == 1 then
        return base .. ".cmd"
      elseif vim.fn.executable(base .. ".exe") == 1 then
        return base .. ".exe"
      end
    end
    if vim.fn.executable(base) == 1 then
      return base
    end
    return nil
  end

  -- TypeScript / JavaScript (ts_ls)
  vim.lsp.config("ts_ls", {
    cmd = function(dispatchers, config)
      local resolved = resolve_ts_cmd((config or {}).root_dir)
      if not resolved then
        return nil
      end
      return vim.lsp.rpc.start({ resolved, "--stdio" }, dispatchers)
    end,
  })
  vim.lsp.enable("ts_ls")

  -- Lua Language Server (lua_ls) com globals do Neovim
  if vim.fn.executable("lua-language-server") == 1 or vim.fn.executable("lua-language-server.cmd") == 1 then
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME,
            },
          },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.enable("lua_ls")
  end
end

return M
