local M = {}

-- Organizar imports dinamicamente via LSP (eslint, vtsls, ts_ls, gopls, etc.)
function M.organize_imports(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  local clients = get_clients({ bufnr = bufnr })
  if #clients == 0 then
    return
  end

  local last_line = vim.api.nvim_buf_line_count(bufnr)
  local last_char = 0
  if last_line > 0 then
    local lines = vim.api.nvim_buf_get_lines(bufnr, last_line - 1, last_line, false)
    if #lines > 0 then
      last_char = string.len(lines[1])
    end
  end

  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = math.max(0, last_line - 1), character = last_char }
    },
    context = {
      only = { "source.organizeImports", "source.fixAll" },
      diagnostics = {}
    }
  }

  local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 500)
  if not results then
    return
  end

  for client_id, response in pairs(results) do
    if response and response.result then
      local client = vim.lsp.get_client_by_id(client_id)
      if client then
        for _, r in ipairs(response.result) do
          if not r.edit and not r.command then
            local resolve_result = vim.lsp.buf_request_sync(bufnr, "codeAction/resolve", r, 500)
            if resolve_result and resolve_result[client_id] and resolve_result[client_id].result then
              r = resolve_result[client_id].result
            end
          end

          if r.edit then
            vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
          elseif r.command then
            vim.lsp.buf.execute_command(r.command)
          end
        end
      end
    end
  end
end

-- Formatar buffer atual ou buffer específico (síncrono ou assíncrono)
function M.format_buffer(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or 0
  local async = opts.async ~= false -- default to true
  
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.format({ bufnr = bufnr, lsp_fallback = true, async = async })
  else
    vim.lsp.buf.format({ bufnr = bufnr, async = async })
  end
end

-- Executa formatação + organização de imports em todos os buffers modificados e depois salva
function M.format_and_save_all(opts)
  opts = opts or {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modifiable and vim.bo[bufnr].modified then
      -- 1. Organiza imports
      pcall(M.organize_imports, bufnr)
      -- 2. Formata de forma síncrona para garantir a gravação correta
      M.format_buffer({ bufnr = bufnr, async = false })
    end
  end

  local bang = opts.bang and "!" or ""
  vim.cmd("wall" .. bang)
end

return M
