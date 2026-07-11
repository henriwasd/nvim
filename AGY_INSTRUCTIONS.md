# 🤖 Instruções para Agentes de IA (Antigravity / agy)

Este repositório contém a configuração do Neovim (baseada em LazyVim) do usuário, otimizada tanto para um notebook de baixo desempenho quanto para sincronização limpa entre múltiplos computadores com diferentes focos de desenvolvimento.

---

## ⚙️ Regras de Arquitetura & Git (IMPORTANTE)

1. **Arquivos Ignorados Localmente**:
   - `lazyvim.json`, `lazy-lock.json` e `.luarc.json` estão propositalmente no `.gitignore`.
   - **NÃO adicione ou force o commit desses arquivos.** Cada PC possui seus próprios extras instalados (ex: diferentes linguagens de programação, AI autocompletes locais) e versões de pacotes.
2. **Filosofia de Otimização (Notebook Fraco)**:
   - A configuração na branch `master` deve permanecer o mais fluida possível.
   - **Sem Formatação Automática**: O recurso de auto-format está desligado globalmente via `vim.g.autoformat = false` em `lua/config/options.lua`. Não mude essa opção sem permissão explícita do usuário.
   - **Sem Plugins Visuais Pesados**: Plugins que consomem muita GPU/CPU de renderização de terminal (como `noice.nvim` e `mini.animate`) estão desativados em `lua/plugins/disabled.lua`. Mantenha-os desativados para evitar lag de escrita (input lag).
   - **Explorador de Arquivos**: O `neo-tree.nvim` está desativado. Usamos o **`oil.nvim`** (`lua/plugins/oil.lua`), que é extremamente leve e rápido.
3. **Backup**:
   - A configuração antiga pura do Neovim (sem o framework LazyVim) está guardada de forma segura na branch `backup-pure-nvim`.

---

## 🛠️ Modificando as Configurações

* Se o usuário pedir para adicionar um novo plugin ou atalho:
  - Adicione o plugin na pasta `lua/plugins/` criando um novo arquivo específico (ex: `lua/plugins/novo_plugin.lua`).
  - Configure de forma que use **Lazy Loading** (eventos como `VeryLazy`, `LspAttach`, `BufReadPost`, etc.) sempre que possível para não degradar o tempo de inicialização do notebook.
  - Se for um plugin específico para apenas uma das máquinas, confirme com o usuário se a importação deve ser condicional ou manual através do `:LazyExtras` local (sem commitar).
