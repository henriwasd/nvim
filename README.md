# ⚡ Neovim Native High-Performance Config (v0.12+)

Uma configuração do **Neovim (v0.12+)** ultra-otimizada, limpa e moderna, construída utilizando o **máximo de recursos nativos do próprio Neovim** para atingir performance extrema e inicialização instantânea, sem o overhead de frameworks pesados.

---

## 📂 Estrutura do Projeto

```text
~/.config/nvim/ (ou %LOCALAPPDATA%\nvim\)
├── init.lua                 # Ponto de entrada limpo e modular
├── LICENSE                  # Licença
├── README.md                # Esta documentação
├── AGY_INSTRUCTIONS.md      # Instruções de arquitetura para agentes
├── AGY_CONTEXT.md           # Registro completo das decisões e histórico
├── stylua.toml              # Regras de formatação do código Lua
└── lua/
    ├── plugins.lua          # Gerenciamento de plugins nativo via vim.pack (Neovim 0.12)
    ├── config/
    │   ├── options.lua      # Opções nativas e tema retrobox com transparência
    │   ├── keymaps.lua      # Atalhos ergonômicos e atalhos de autocomplete
    │   ├── autocmds.lua     # Sincronização externa de arquivos, highlight yank, etc.
    │   ├── statusline.lua   # Statusline 100% nativa em Lua puro (zero plugins)
    │   └── terminal.lua     # Terminal flutuante 100% nativo em Lua puro
    └── lsp/
        └── init.lua         # LSP nativo (vim.lsp.config), autocomplete nativo e diagnósticos
```

---

## ✨ Principais Recursos & Filosofia Nativa

### 📦 1. Gerenciamento de Pacotes Nativo (`vim.pack`)
*   Zero dependência de gerenciadores externos pesados como `lazy.nvim`.
*   Utiliza a API nativa **`vim.pack`** introduzida no Neovim core:
    *   `:PackUpdate` — atualiza todos os plugins diretamente.
    *   `:PackStatus` — visualiza o status e detalhes dos pacotes instalados.

### ⚡ 2. Autocomplete & Snippets 100% Nativos
*   Alimentado pela engine nativa do Neovim **`vim.lsp.completion`**:
    *   Zero plugins de autocomplete rodando em segundo plano.
    *   Menu de sugestões popup e documentação integrados nativamente.
    *   Suporte a expansão de snippets nativo (`vim.snippet`).
    *   Navegação intuitiva: `<Tab>` e `<S-Tab>` percorrem sugestões ou pulam entre placeholders de snippets, e `<CR>` (Enter) aceita a sugestão.

### 🎨 3. Tema Nativo 'Retrobox' com Transparência
*   Utiliza o **`retrobox`** oficial embutido no binário do Neovim (a recriação oficial do clássico Gruvbox).
*   Zero plugins de tema e zero I/O de disco para carregar o visual.
*   Fundo e painéis transparentes configurados nativamente via API de highlights.

### 📊 4. Statusline Nativa em Lua Puro
*   Renderização em menos de **0.05ms** sem bibliotecas externas.
*   Exibe modo do editor, branch Git atual, nome do arquivo com status de modificação, contadores de diagnóstico LSP (Erros e Avisos), tipo de arquivo e posição do cursor.

### 🖥️ 5. Terminal Flutuante Nativo
*   Janela flutuante centralizada e elegante acionada por atalho (`<C-/>` ou `<leader>ft`).
*   Abre sempre no diretório atual de trabalho (`getcwd()`), perfeito para monorepos e projetos múltiplos.
*   Pressione `<Esc><Esc>` para entrar no modo Normal do terminal.

### 📁 6. Explorador de Arquivos com Oil (`oil.nvim`)
*   Edição de diretórios como se fossem buffers de texto padrão do Neovim.
*   Use `<leader>e` para abrir o diretório do arquivo atual.

### 🔍 7. Busca Rápida com Mini.Pick
*   Fuzzy finder ultra-leve em janela flutuante (`mini.pick`).
*   Integração direta com `ripgrep` (`rg`) e `fd` para velocidade instantânea de busca.

### 🧙‍♂️ 8. Edição Avançada
*   **Surround**: `mini.surround` com prefixo `gz` (`gza` adiciona, `gzd` deleta, `gzr` substitui delimitadores).
*   **Múltiplos Cursores**: `vim-visual-multi` (`Ctrl+N` para selecionar ocorrências).
*   **Which-Key**: Menu visual popup rápido e categorizado ao teclar `<Space>`.

---

## ⌨️ Tabela de Atalhos Principais

| Atalho | Modo | Ação |
| :--- | :---: | :--- |
| `Ctrl + A` | Normal / Visual | Seleciona todo o conteúdo do arquivo |
| `Ctrl + S` | Normal / Insert / Visual | **Salva o arquivo** sem formatação automática |
| `Ctrl + C` | Visual | Copia para a área de transferência do sistema |
| `Ctrl + V` | Insert / Visual | Cola da área de transferência do sistema |
| `Alt + ⬆️/⬇️/⬅️/➡️` | Todos | **Redimensiona painéis de janelas** |
| `Ctrl + h/j/k/l` | Normal | Navega entre divisões de janelas |
| `Shift + h` / `Shift + l` | Normal | Alterna entre buffers abertos |
| `<leader>e` | Normal | Abre o explorador de arquivos (**Oil**) |
| `<leader>ff` | Normal | **Busca arquivos** por nome (MiniPick) |
| `<leader>fg` | Normal | **Busca texto em todo o projeto** (Live Grep) |
| `<leader>fb` | Normal | Lista e alterna entre **buffers** |
| `<leader>ft` ou `<C-/>` | Normal / Terminal | Abre/Alterna o **Terminal Flutuante no CWD** |
| `<leader>fh` | Normal | Busca nas páginas de ajuda (**Help Tags**) |
| `<leader>bd` | Normal | Fecha o buffer atual (**Delete Buffer**) |
| `<leader>ca` | Normal / Visual | Ações de código (**Code Action**) |
| `<leader>cf` | Normal | Formata o buffer atual via LSP |
| `<leader>cr` | Normal | Renomeia símbolo (**LSP Rename**) |
| `<leader>cd` | Normal | Abre janela flutuante de diagnóstico na linha |
| `<leader>cl` | Normal | Informações de saúde do LSP |
| `gd` / `gD` | Normal | Ir para a Definição / Declaração |
| `K` | Normal | Exibe documentação flutuante (Hover) |
| `[d` / `]d` | Normal | Pula para o diagnóstico anterior / próximo |
| `Tab` / `Shift+Tab` | Insert | Próxima / Anterior sugestão no Autocomplete |
| `Enter` | Insert | Aceita sugestão do Autocomplete |
| `gza` / `gzd` / `gzr` | Normal / Visual | Adiciona / Deleta / Substitui delimitadores (surround) |
