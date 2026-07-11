#!/bin/bash
# Setup script for LazyVim Custom Configuration on Linux
# Runs via: curl -fsSL https://raw.githubusercontent.com/henriwasd/nvim/master/setup.sh | bash

set -e

echo "============================================="
echo "   LazyVim Complete Setup & Dependencies     "
echo "                (Linux)                      "
echo "============================================="

NVIM_DIR="$HOME/.config/nvim"

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

# 2. Update and Install Base Dependencies
echo -e "\n[1/6] Instalando dependencias base..."
if [ "$PM" = "apt" ]; then
    sudo apt-get update
    sudo apt-get install -y git curl unzip tar ripgrep fd-find nodejs npm build-essential
    # On Debian/Ubuntu, the 'fd' command is renamed to 'fdfind'. We create a symlink to 'fd'.
    if ! command -v fd &> /dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf $(which fdfind) "$HOME/.local/bin/fd"
        # Export PATH dynamically if ~/.local/bin is not in it
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            export PATH="$HOME/.local/bin:$PATH"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null || true
        fi
    fi
elif [ "$PM" = "pacman" ]; then
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm git curl unzip tar ripgrep fd nodejs npm gcc make
elif [ "$PM" = "dnf" ]; then
    sudo dnf update -y
    sudo dnf install -y git curl unzip tar ripgrep fd-find nodejs npm gcc-c++ make
else
    echo "Gerenciador de pacotes nao suportado automaticamente."
    echo "Certifique-se de instalar manualmente: git curl unzip tar ripgrep fd nodejs npm gcc/g++"
fi

# 3. Clone or Pull Configuration
if [ -d "$NVIM_DIR" ]; then
    if [ -d "$NVIM_DIR/.git" ]; then
        echo -e "\n[2/6] Configuracao existente detectada. Atualizando..."
        cd "$NVIM_DIR"
        git pull || echo "Falha ao rodar git pull. Verifique alteracoes locais."
    else
        echo -e "\n[2/6] Pasta $NVIM_DIR ja existe, mas nao e um repositorio git. Pulando clonagem."
    fi
else
    echo -e "\n[2/6] Clonando configuracao..."
    git clone https://github.com/henriwasd/nvim.git "$NVIM_DIR"
fi

# 4. Check and Install Neovim (if not installed)
echo -e "\n[3/6] Verificando Neovim..."
if ! command -v nvim &> /dev/null; then
    echo "Neovim nao encontrado. Instalando..."
    if [ "$PM" = "apt" ]; then
        echo "Baixando Neovim AppImage (estavel)..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
        chmod +x nvim-linux-x86_64.appimage
        sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
    elif [ "$PM" = "pacman" ]; then
        sudo pacman -S --noconfirm neovim
    elif [ "$PM" = "dnf" ]; then
        sudo dnf install -y neovim
    else
        echo "Por favor, instale o Neovim manualmente."
    fi
else
    echo "Neovim ja esta instalado."
fi

# 5. Check and Install LazyGit
echo -e "\n[4/6] Verificando LazyGit..."
if ! command -v lazygit &> /dev/null; then
    echo "Instalando LazyGit..."
    if [ "$PM" = "pacman" ]; then
        sudo pacman -S --noconfirm lazygit
    elif [ "$PM" = "dnf" ]; then
        sudo dnf copr enable atim/lazygit -y
        sudo dnf install -y lazygit
    else
        # Default fallback: download binary from GitHub
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    fi
else
    echo "LazyGit ja esta instalado."
fi

# 6. Ensure node and npm are in path
echo -e "\n[5/6] Verificando Node.js e npm..."
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    echo "Node.js e npm prontos."
else
    echo "Aviso: Node.js ou npm nao foram encontrados ou nao estao no PATH."
fi

# 7. Compilador C check
echo -e "\n[6/6] Verificando compilador C para o Treesitter..."
if command -v gcc &> /dev/null || command -v clang &> /dev/null; then
    echo "Compilador C pronto."
else
    echo "Aviso: Nenhum compilador C encontrado. Instale o gcc ou clang."
fi

echo -e "\n============================================="
echo "           Configuracao Concluida!           "
echo "============================================="
echo "Execute o comando: nvim"
echo "============================================="
