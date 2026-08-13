#!/bin/bash
# Uninstall script for LazyVim Setup & Dependencies on Linux
# Runs via: curl -fsSL https://raw.githubusercontent.com/henriwasd/nvim/master/uninstall.sh | bash

set -e

echo "============================================="
echo "   LazyVim Uninstall & Cleanup (Linux)       "
echo "============================================="

NVIM_SHARE="$HOME/.local/share/nvim"
NVIM_STATE="$HOME/.local/state/nvim"
NVIM_CACHE="$HOME/.cache/nvim"

# 1. Detect Package Manager
if [ -f /etc/debian_version ]; then
    PM="apt"
elif [ -f /etc/arch-release ]; then
    PM="pacman"
elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
    PM="dnf"
else
    PM="unknown"
fi

echo -e "\n[1/2] Desinstalando ferramentas instaladas pelo setup..."

if [ "$PM" = "apt" ]; then
    sudo apt-get remove -y ripgrep fd-find nodejs npm build-essential || true
    sudo apt-get autoremove -y || true
elif [ "$PM" = "pacman" ]; then
    sudo pacman -Rns --noconfirm ripgrep fd nodejs npm gcc make neovim lazygit || true
elif [ "$PM" = "dnf" ]; then
    sudo dnf remove -y ripgrep fd-find nodejs npm gcc-c++ make neovim lazygit || true
fi

# Remove AppImage or manually installed binaries if present
if [ -f /usr/local/bin/nvim ]; then
    sudo rm -f /usr/local/bin/nvim
fi
if [ -f /usr/local/bin/lazygit ]; then
    sudo rm -f /usr/local/bin/lazygit
fi
if [ -f "$HOME/.local/bin/fd" ]; then
    rm -f "$HOME/.local/bin/fd"
fi

echo -e "\n[2/2] Removendo pastas de dados, estado e cache do Neovim..."
rm -rf "$NVIM_SHARE" "$NVIM_STATE" "$NVIM_CACHE"

echo -e "\n============================================="
echo "        Desinstalacao Concluida!             "
echo "============================================="
