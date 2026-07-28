#!/usr/bin/env bash
# ==============================================================================
# OmniRoute CLI — Instalação e Inicialização
# ==============================================================================
# Suporta:
#   - Fedora e derivados (RHEL, CentOS, Rocky, AlmaLinux, Nobara, Bluefin)
#   - Debian, Ubuntu e derivados (Mint, Pop!_OS, Kali, Deepin)
#   - Instalação global (/usr/local/bin) em qualquer distro
#   - Criação de pacotes .deb e .rpm
#   - Instalação no espaço do usuário (~/.local/bin)
#   - Sistemas imutáveis (Silverblue, Kinoite, COSMIC)
# ==============================================================================

set -e

# ── Cores ANSI ─────────────────────────────────────────────────────────────────
VERDE="\033[1;32m"
AZUL="\033[1;34m"
AMARELO="\033[1;33m"
VERMELHO="\033[1;31m"
CIANO="\033[1;36m"
RESET="\033[0m"

# ── Utilitários de saída ──────────────────────────────────────────────────────
info()    { echo -e "${AZUL}[INFO]${RESET}   $*"; }
sucesso() { echo -e "${VERDE}[OK]${RESET}     $*"; }
aviso()   { echo -e "${AMARELO}[AVISO]${RESET}  $*"; }
erro()    { echo -e "${VERMELHO}[ERRO]${RESET}  $*" >&2; }
destaque(){ echo -e "${CIANO}[...]${RESET}   $*"; }

# ── Diretórios base (sem hardcoding de usuário) ───────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="${HOME}"
LOCAL_BIN="${USER_HOME}/.local/bin"
LOCAL_SHARE="${USER_HOME}/.local/share/omniroute-cli"
SYSTEM_BIN="/usr/local/bin"
SYSTEM_SHARE="/usr/local/share/omniroute-cli"

# ── Detecta distribuição Linux ────────────────────────────────────────────────
detectar_distro() {
    local id=""
    local id_like=""

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        id="${ID,,}"
        id_like="${ID_LIKE,,}"
    fi

    # Família Fedora / RHEL
    if [ "$id" = "fedora" ] || [ "$id" = "rhel" ] || [ "$id" = "centos" ] || \
       [ "$id_like" = "fedora" ] || [ "$id_like" = "rhel" ] || [ "$id_like" = "centos" ] || \
       [[ "$id" =~ ^(rocky|almalinux|nobara|bluefin|aurora|ultramarine)$ ]]; then
        echo "fedora"
        return 0
    fi

    # Família Debian/Ubuntu
    if [ "$id" = "debian" ] || [ "$id" = "ubuntu" ] || \
       [ "$id_like" = "debian" ] || [ "$id_like" = "ubuntu" ]; then
        echo "debian"
        return 0
    fi

    # Arch Linux
    if [ "$id" = "arch" ] || [ "$id_like" = "arch" ]; then
        echo "arch"
        return 0
    fi

    # openSUSE
    if [ "$id" = "opensuse" ] || [ "$id_like" = "suse" ]; then
        echo "suse"
        return 0
    fi

    echo "desconhecida"
}

# ── Detecta sistema imutável (Atomic/ostree) ──────────────────────────────────
sistema_imutavel() {
    # Fedora Atomic (Silverblue, Kinoite, COSMIC, etc.)
    if [ -f /etc/ostree-aware ] || command -v rpm-ostree &>/dev/null; then
        return 0
    fi
    return 1
}

# ── Verifica dependências ─────────────────────────────────────────────────────
verificar_dependencias() {
    local distro="$1"
    local faltando=0

    info "Verificando dependências..."

    # Bun
    if ! command -v bun &>/dev/null; then
        aviso "Bun não encontrado."
        case "$distro" in
            fedora)
                echo "  Instale com: curl -fsSL https://bun.sh/install | bash"
                echo "  Ou via npm:  npm install -g bun"
                ;;
            debian)
                echo "  Opção 1 (recomendado): curl -fsSL https://bun.sh/install | bash"
                echo "  Opção 2 (apt):"
                echo "    sudo apt update && sudo apt install -y curl unzip"
                echo "    curl -fsSL https://bun.sh/install | bash"
                echo "  Opção 3 (npm): sudo apt install -y nodejs npm && npm install -g bun"
                ;;
            *)
                echo "  Instale com: curl -fsSL https://bun.sh/install | bash"
                ;;
        esac
        faltando=1
    fi

    # npm (geralmente vem com Bun)
    if ! command -v npm &>/dev/null && ! command -v bun &>/dev/null; then
        aviso "npm não encontrado (opcional se Bun estiver instalado)."
        faltando=1
    fi

    if [ "$faltando" -eq 1 ]; then
        echo ""
        aviso "Dependências opcionais faltando. O script continuará, mas"
        aviso "algumas funcionalidades podem não estar disponíveis."
    else
        sucesso "Todas as dependências encontradas."
    fi
}

# ── Instalação no espaço do usuário (~/.local/bin) ────────────────────────────
install_usuario() {
    echo ""
    destaque "═ Instalação no espaço do usuário ═"
    echo ""

    info "Diretório destino: ${LOCAL_BIN}/omniroute"

    mkdir -p "${LOCAL_BIN}"
    mkdir -p "${LOCAL_SHARE}"

    cp "${SCRIPT_DIR}/omniroute.sh" "${LOCAL_BIN}/omniroute"
    chmod +x "${LOCAL_BIN}/omniroute"

    sucesso "Script copiado para ${LOCAL_BIN}/omniroute"

    # Configurar npm global no espaço do usuário
    if command -v npm &>/dev/null; then
        info "Configurando npm para instalação local do usuário..."
        npm config set prefix "${USER_HOME}/.npm-global" 2>/dev/null || true
    fi

    # Instalar pacote omniroute via npm
    if command -v npm &>/dev/null; then
        info "Instalando pacote omniroute..."
        npm install -g omniroute 2>/dev/null || {
            aviso "Não foi possível instalar o pacote omniroute via npm."
            aviso "Tente: npm install -g omniroute"
        }
    fi

    echo ""
    sucesso "Instalação do usuário concluída!"

    # Verificar PATH
    if [[ ":$PATH:" != *":${LOCAL_BIN}:"* ]] && [[ ":$PATH:" != *":${USER_HOME}/.npm-global/bin:"* ]]; then
        aviso "Os diretórios binários podem não estar no seu PATH."
        echo ""
        echo "  Adicione ao seu ~/.bashrc ou ~/.zshrc:"
        echo "    export PATH=\"${LOCAL_BIN}:${USER_HOME}/.npm-global/bin:\$PATH\""
        echo ""
        echo "  Depois recarregue: source ~/.bashrc"
    fi

    echo ""
    echo "  Agora execute: omniroute --help"
}

# ── Instalação global no sistema (/usr/local/bin) ─────────────────────────────
install_sistema() {
    echo ""
    destaque "═ Instalação Global no Sistema ═"
    echo ""

    # Verificar se é Fedora ou derivado
    local distro
    distro="$(detectar_distro)"
    info "Distribuição detectada: ${distro}"

    if sistema_imutavel; then
        aviso "Sistema imutável detectado (ostree/Atomic)."
        aviso "Recomendamos usar '--install' (instalação do usuário) em sistemas imutáveis."
        aviso "A instalação em /usr/local/bin pode ser revertida em atualizações do sistema."
        echo ""
        echo -n "Deseja continuar mesmo assim? [s/N] "
        read -r confirmacao
        if [[ ! "$confirmacao" =~ ^[sSyY] ]]; then
            info "Instalação cancelada. Use './omniroute.sh --install' como alternativa."
            exit 0
        fi
    fi

    info "Diretório destino: ${SYSTEM_BIN}/omniroute"

    # Verificar permissões de escrita em /usr/local/bin
    if [ ! -w "${SYSTEM_BIN}" ]; then
        erro "Sem permissão de escrita em ${SYSTEM_BIN}."
        erro "Execute com sudo: sudo ./omniroute.sh --install-system"
        exit 1
    fi

    mkdir -p "${SYSTEM_BIN}"
    mkdir -p "${SYSTEM_SHARE}"

    cp "${SCRIPT_DIR}/omniroute.sh" "${SYSTEM_BIN}/omniroute"
    chmod +x "${SYSTEM_BIN}/omniroute"

    sucesso "Script copiado para ${SYSTEM_BIN}/omniroute"

    # Configurar npm global do sistema
    if command -v npm &>/dev/null; then
        # Apenas se tiver permissão — senão, usa o padrão do sistema
        if [ -w "$(npm config get prefix 2>/dev/null || echo /usr)" ]; then
            info "Instalando pacote omniroute via npm global..."
            npm install -g omniroute 2>/dev/null || {
                aviso "Não foi possível instalar omniroute via npm global."
            }
        else
            aviso "Sem permissão para npm global. O pacote omniroute pode precisar"
            aviso "ser instalado manualmente: sudo npm install -g omniroute"
        fi
    fi

    echo ""
    sucesso "Instalação global concluída!"
    echo ""
    echo "  O comando 'omniroute' está disponível globalmente para todos os usuários."
    echo ""
    echo "  Teste com: omniroute --help"
}

# ── Desinstalação do usuário ───────────────────────────────────────────────────
uninstall_usuario() {
    echo ""
    destaque "═ Removendo instalação do usuário ═"
    echo ""

    if [ -f "${LOCAL_BIN}/omniroute" ]; then
        rm -f "${LOCAL_BIN}/omniroute"
        sucesso "Removido: ${LOCAL_BIN}/omniroute"
    fi

    if [ -d "${LOCAL_SHARE}" ]; then
        rm -rf "${LOCAL_SHARE}"
        sucesso "Removido: ${LOCAL_SHARE}"
    fi

    # Remover pacote npm global do usuário
    if command -v npm &>/dev/null; then
        info "Removendo pacote omniroute do npm..."
        npm uninstall -g omniroute 2>/dev/null || true
    fi

    # Remover diretórios de runtime
    for d in "${USER_HOME}/.omniroute" "${USER_HOME}/.config/omniroute" "${USER_HOME}/.cache/omniroute"; do
        if [ -d "$d" ]; then
            rm -rf "$d"
            sucesso "Removido: $d"
        fi
    done

    sucesso "Desinstalação do usuário concluída!"
}

# ── Desinstalação do sistema ───────────────────────────────────────────────────
uninstall_sistema() {
    echo ""
    destaque "═ Removendo instalação global do sistema ═"
    echo ""

    if [ ! -w "${SYSTEM_BIN}" ] && [ -f "${SYSTEM_BIN}/omniroute" ]; then
        erro "Sem permissão de escrita em ${SYSTEM_BIN}."
        erro "Execute com sudo: sudo ./omniroute.sh --uninstall-system"
        exit 1
    fi

    if [ -f "${SYSTEM_BIN}/omniroute" ]; then
        rm -f "${SYSTEM_BIN}/omniroute"
        sucesso "Removido: ${SYSTEM_BIN}/omniroute"
    fi

    if [ -d "${SYSTEM_SHARE}" ]; then
        rm -rf "${SYSTEM_SHARE}"
        sucesso "Removido: ${SYSTEM_SHARE}"
    fi

    # Remover pacote npm global do sistema
    if command -v npm &>/dev/null; then
        info "Removendo pacote omniroute do npm global..."
        npm uninstall -g omniroute 2>/dev/null || true
    fi

    sucesso "Desinstalação global concluída!"
}

# ── Criar pacote .deb (Debian/Ubuntu) ──────────────────────────────────────────
install_deb_package() {
    echo ""
    destaque "═ Criando pacote .deb para Debian/Ubuntu ═"
    echo ""

    local distro
    distro="$(detectar_distro)"
    if [ "$distro" != "debian" ]; then
        aviso "Distribuição detectada: ${distro}"
        aviso "Pacotes .deb são nativos do Debian/Ubuntu."
        echo -n "Deseja continuar mesmo assim? [s/N] "
        read -r confirmacao
        if [[ ! "$confirmacao" =~ ^[sSyY] ]]; then
            info "Criação cancelada."
            exit 0
        fi
    fi

    # Verificar dependências para empacotamento
    if ! command -v dpkg-deb &>/dev/null; then
        erro "dpkg-deb não encontrado. Instale com:"
        erro "  sudo apt install -y dpkg-dev"
        exit 1
    fi

    local versao="1.0.0"
    local pacote_dir="/tmp/omniroute-cli_${versao}_all"
    local deb_file="/tmp/omniroute-cli_${versao}_all.deb"

    info "Criando estrutura do pacote..."
    rm -rf "$pacote_dir"
    mkdir -p "${pacote_dir}/DEBIAN"
    mkdir -p "${pacote_dir}/usr/local/bin"
    mkdir -p "${pacote_dir}/usr/local/share/omniroute-cli"
    mkdir -p "${pacote_dir}/usr/share/doc/omniroute-cli"

    # Copiar arquivos
    cp "${SCRIPT_DIR}/omniroute.sh" "${pacote_dir}/usr/local/bin/omniroute"
    chmod +x "${pacote_dir}/usr/local/bin/omniroute"

    # Copiar documentação se existir
    for doc in README.md CLI.MD INSTALL.md Iniciar_omniroute.md; do
        if [ -f "${SCRIPT_DIR}/${doc}" ]; then
            cp "${SCRIPT_DIR}/${doc}" "${pacote_dir}/usr/local/share/omniroute-cli/"
        fi
    done

    # Criar arquivo de copyright
    cat > "${pacote_dir}/usr/share/doc/omniroute-cli/copyright" << 'COPYRIGHT'
OmniRoute CLI
Copyright (C) 2024-2026 OmniRoute Team

Licensed under the MIT License.
See /usr/local/share/omniroute-cli/LICENSE for details.
COPYRIGHT

    # Criar changelog
    cat > "${pacote_dir}/usr/share/doc/omniroute-cli/changelog" << 'CHANGELOG'
omniroute-cli (1.0.0) stable; urgency=medium

  * Initial release
  * Support for Fedora, Debian, Ubuntu, and derivatives
  * Global and user-space installation modes

 -- OmniRoute Team <recifecrypto@gmail.com>  Mon, 28 Jul 2026 00:00:00 -0300
CHANGELOG
    gzip -9 "${pacote_dir}/usr/share/doc/omniroute-cli/changelog"

    # Criar arquivo de controle
    cat > "${pacote_dir}/DEBIAN/control" << 'CONTROL'
Package: omniroute-cli
Version: 1.0.0
Section: utils
Priority: optional
Architecture: all
Depends: nodejs (>= 18), npm
Recommends: curl, ca-certificates
Suggests: bun
Maintainer: OmniRoute Team <recifecrypto@gmail.com>
Description: OmniRoute CLI - API route manager for multiple AI providers
 OmniRoute CLI is a command-line interface for managing API routes
 with support for multiple AI providers including Anthropic, Google,
 OpenAI, and others.
 .
 It provides a unified interface for routing API requests
 and managing configurations for AI-powered applications.
Homepage: https://github.com/recifecrypto/omniroute-cli
CONTROL

    # Criar script pós-instalação
    cat > "${pacote_dir}/DEBIAN/postinst" << 'POSTINST'
#!/bin/sh
set -e

case "$1" in
    configure)
        # Instalar pacote npm global
        if command -v npm >/dev/null 2>&1; then
            echo "Instalando pacote omniroute via npm..."
            npm install -g omniroute >/dev/null 2>&1 || true
        fi
        ;;
esac

exit 0
POSTINST
    chmod +x "${pacote_dir}/DEBIAN/postinst"

    # Criar script pós-remoção
    cat > "${pacote_dir}/DEBIAN/postrm" << 'POSTRM'
#!/bin/sh
set -e

case "$1" in
    remove|purge)
        if command -v npm >/dev/null 2>&1; then
            npm uninstall -g omniroute >/dev/null 2>&1 || true
        fi
        ;;
esac

exit 0
POSTRM
    chmod +x "${pacote_dir}/DEBIAN/postrm"

    # Construir o pacote
    info "Construindo pacote .deb..."
    fakeroot dpkg-deb --build "$pacote_dir" "$deb_file" 2>/dev/null || \
        dpkg-deb --build "$pacote_dir" "$deb_file" 2>/dev/null || {
        erro "Falha ao criar pacote .deb."
        erro "Certifique-se de que dpkg-dev e fakeroot estão instalados:"
        erro "  sudo apt install -y dpkg-dev fakeroot"
        exit 1
    }

    sucesso "Pacote .deb criado: ${deb_file}"
    echo ""
    echo "  Para instalar:"
    echo "    sudo dpkg -i ${deb_file}"
    echo "    sudo apt install -f   # corrigir dependências se necessário"
    echo ""
    echo "  Para desinstalar:"
    echo "    sudo dpkg -r omniroute-cli"
}

# ── Menu de ajuda ──────────────────────────────────────────────────────────────
mostrar_ajuda() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                OmniRoute CLI — Instalação                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Uso: $0 [opções]  ou  omniroute [opções da CLI]"
    echo ""
    echo "Opções de instalação:"
    echo "  --install              Instala no espaço do usuário (~/.local/bin/)"
    echo "  --install-system       Instala globalmente no sistema (/usr/local/bin/)"
    echo "  --install-deb          Cria um pacote .deb (Debian/Ubuntu)"
    echo "  --uninstall            Remove instalação do usuário"
    echo "  --uninstall-system     Remove instalação global do sistema"
    echo ""
    echo "Opções de informação:"
    echo "  -h, --help             Mostra esta ajuda"
    echo "  -v, --version          Mostra versão"
    echo ""
    echo "Opções da CLI (omniroute):"
    echo "  -p, --port <porta>     Porta do servidor (padrão: 20128)"
    echo "  -H, --host <host>      Host para bind (padrão: 0.0.0.0)"
    echo "  -n, --no-browser       Não abre o navegador automaticamente"
    echo "  -l, --log              Exibe logs do servidor"
    echo "  -t, --tray             Executa em modo de bandeja (background)"
    echo ""
    echo "Exemplos:"
    echo "  $0 --install                   # Instalação local (qualquer Linux)"
    echo "  sudo $0 --install-system       # Instalação global (qualquer Linux)"
    echo "  sudo $0 --install-deb          # Cria pacote .deb (Debian/Ubuntu)"
    echo "  omniroute -p 20128             # Executa CLI"
    echo ""
}

# ── Resolução do binário npm ───────────────────────────────────────────────────
resolve_npm_omniroute() {
    # Procurar em locais conhecidos
    local locais=(
        "${USER_HOME}/.npm-global/bin/omniroute"
        "${USER_HOME}/.local/share/npm/bin/omniroute"
        "$(npm root -g 2>/dev/null | xargs dirname 2>/dev/null)/bin/omniroute"
    )

    # Adicionar local do sistema se tiver permissão
    if [ -d "/usr/local/share/npm/bin" ]; then
        locais+=("/usr/local/share/npm/bin/omniroute")
    fi

    for caminho in "${locais[@]}"; do
        if [ -f "$caminho" ]; then
            echo "$caminho"
            return 0
        fi
    done

    # Busca genérica no PATH
    local encontrado
    encontrado="$(command -v omniroute 2>/dev/null || true)"
    if [ -n "$encontrado" ] && [ "$encontrado" != "${LOCAL_BIN}/omniroute" ] && \
       [ "$encontrado" != "${SYSTEM_BIN}/omniroute" ]; then
        echo "$encontrado"
        return 0
    fi

    return 1
}

# ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ──
# PROCESSAMENTO DE ARGUMENTOS
# ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ──

case "${1:-}" in
    --install)
        verificar_dependencias "$(detectar_distro)"
        install_usuario
        exit 0
        ;;
    --install-system)
        verificar_dependencias "$(detectar_distro)"
        install_sistema
        exit 0
        ;;
    --install-deb)
        verificar_dependencias "debian"
        install_deb_package
        exit 0
        ;;
    --uninstall)
        uninstall_usuario
        exit 0
        ;;
    --uninstall-system)
        uninstall_sistema
        exit 0
        ;;
    -h|--help)
        mostrar_ajuda
        exit 0
        ;;
    -v|--version)
        # Tenta obter versão do pacote npm
        if command -v npm &>/dev/null; then
            npm list -g omniroute --depth=0 2>/dev/null | grep omniroute || \
                echo "OmniRoute CLI — versão desconhecida (consulte npm list -g omniroute)"
        else
            echo "OmniRoute CLI"
        fi
        exit 0
        ;;
    "")
        # Sem argumentos — mostra ajuda
        mostrar_ajuda
        exit 0
        ;;
esac

# ── Delegação para o binário real do omniroute ────────────────────────────────
# Se chegou aqui, os argumentos não são flags de instalação/ajuda,
# então tenta delegar para o binário real do npm/omniroute.

# Verificar se está sendo executado de dentro do diretório de instalação
if [ "$SCRIPT_DIR" = "${LOCAL_BIN}" ] || [ "$SCRIPT_DIR" = "${SYSTEM_BIN}" ]; then
    NPM_BIN="$(resolve_npm_omniroute || true)"
    if [ -n "$NPM_BIN" ]; then
        exec "$NPM_BIN" "$@"
    else
        erro "Binário omniroute não encontrado no sistema."
        erro "Execute a instalação primeiro:"
        erro "  $0 --install         (instalação do usuário)"
        erro "  sudo $0 --install-system  (instalação global)"
        exit 1
    fi
fi

# Execução local com argumentos — tenta delegar para o binário global
NPM_BIN="$(resolve_npm_omniroute || true)"
if [ -n "$NPM_BIN" ]; then
    exec "$NPM_BIN" "$@"
else
    erro "Binário omniroute não encontrado. Instale primeiro:"
    erro "  $0 --install"
    exit 1
fi
