# 🚀 Neovim Native Config

A minimal and highly efficient Neovim configuration utilizing native package management (`pack/plugins/start/`) instead of third-party plugin managers like LazyVim or lazy.nvim. 

Plugins are cloned and managed natively by Neovim's runtime path.

---

## 📂 Project Structure

```text
~/.config/nvim/
├── init.lua                # Main entry point (loads leader, options, keymaps, etc.)
├── LICENSE                 # License file
├── README.md               # This README
├── stylua.toml             # StyLua formatter configuration
└── lua/
    ├── autocmds.lua        # Autocommands definition
    ├── keymaps.lua         # Keyboard shortcuts and map configs
    ├── options.lua         # Neovim options and settings (numbers, wrap, tabstop...)
    ├── pack_manager.lua    # Native package manager code (cloning, updates, cleans)
    └── plugin_configs.lua  # Configurations for LSP, autocomplete, treesitter, etc.
```

---

## 📦 Package Management

Plugin management is handled by `lua/pack_manager.lua`, which bootstraps Neovim automatically on first run by cloning missing plugins to the native plugins path.

### Features
- **Auto-Bootstrapping**: Clones missing plugins dynamically when Neovim starts up.
- **Custom User Commands**:
  - `:PackUpdate`: Performs a `git pull` on all installed plugins.
  - `:PackClean`: Safely deletes directory paths of plugins no longer specified in `pack_manager.lua`.

---

## 🛠️ Requirements

- Neovim **0.9.0+**
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (recommended for devicons)
- Ripgrep & FD (for Telescope fuzzy searching)

---

## 🚀 Getting Started

1. Back up your existing configuration:
   ```bash
   # Unix/Linux/macOS
   mv ~/.config/nvim ~/.config/nvim.backup
   
   # Windows (PowerShell)
   Rename-Item -Path $env:LOCALAPPDATA\nvim -NewName nvim.backup
   ```

2. Clone this repository:
   ```bash
   # Unix/Linux/macOS
   git clone https://github.com/henriwasd/nvim.git ~/.config/nvim

   # Windows (PowerShell)
   git clone https://github.com/henriwasd/nvim.git $env:LOCALAPPDATA\nvim
   ```

3. Launch Neovim! The configuration will automatically clone all required packages and set up your workspace:
   ```bash
   nvim
   ```
