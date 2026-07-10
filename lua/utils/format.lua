local M = {}


function M.organize_imports(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  local clients = get_clients({ bufnr = bufnr })
  
  -- Pre-flight check: do we have any initialized client supporting organizeImports?
  local has_support = false
  for _, client in ipairs(clients) do
    if client.initialized and client.supports_method("textDocument/codeAction") then
      local provider = client.server_capabilities.codeActionProvider
      if provider then
        if type(provider) == "table" and provider.codeActionKinds then
          for _, kind in ipairs(provider.codeActionKinds) do
            if kind:find("^source%.organizeImports") then
              has_support = true
              break
            end
          end
        else
          has_support = true
        end
      end
    end
    if has_support then break end
  end

  if not has_support then
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
      only = { "source.organizeImports" },
      diagnostics = {}
    }
  }

  local timeout_ms = 2000
  local results, err = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, timeout_ms)
  if err then
    vim.notify("Organize imports error: " .. tostring(err), vim.log.levels.ERROR, { title = "Format" })
    return
  end
  if not results or vim.tbl_isempty(results) then
    return
  end

  local actions_applied = 0
  for client_id, response in pairs(results) do
    if response and type(response.result) == "table" then
      local client = vim.lsp.get_client_by_id(client_id)
      if client then
        for _, r in ipairs(response.result) do
          local matches_kind = false
          if r.kind then
            matches_kind = r.kind:find("^source%.organizeImports") ~= nil
          else
            matches_kind = true
          end

          if matches_kind then
            if not r.edit and not r.command then
              -- Resolve code action specifically on the client that returned it
              local resolve_result = client.request_sync("codeAction/resolve", r, timeout_ms, bufnr)
              if resolve_result and resolve_result.result then
                r = resolve_result.result
              end
            end

            if r.edit then
              vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
              actions_applied = actions_applied + 1
            elseif r.command then
              local command_to_execute = type(r.command) == "table" and r.command or r
              vim.lsp.buf.execute_command(command_to_execute)
              actions_applied = actions_applied + 1
            end
          end
        end
      end
    end
  end

  if actions_applied > 0 then
    vim.notify("Organized imports successfully!", vim.log.levels.INFO, { title = "Format" })
  end
end



function M.format_buffer(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or 0
  local async = opts.async ~= false
  
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.format({ bufnr = bufnr, lsp_fallback = true, async = async })
  else
    vim.lsp.buf.format({ bufnr = bufnr, async = async })
  end
end


function M.format_and_save_all(opts)
  opts = opts or {}
  local current_buf = vim.api.nvim_get_current_buf()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modifiable and vim.bo[bufnr].modified then
      if bufnr == current_buf then
        pcall(M.organize_imports, bufnr)
      end
      pcall(M.format_buffer, { bufnr = bufnr, async = false })
    end
  end

  local bang = opts.bang and "!" or ""
  vim.cmd("wall" .. bang)
end


return M
