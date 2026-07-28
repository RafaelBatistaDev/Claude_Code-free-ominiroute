# OmniRoute CLI — Guia de Uso

## 📋 Visão Geral

OmniRoute CLI é uma interface de linha de comando para gerenciar rotas de API com suporte a múltiplos provedores de IA.

## 🚀 Instalação Rápida

### Instalação do Usuário (~/.local/bin)

```bash
chmod +x omniroute.sh
./omniroute.sh --install
```

### Instalação Global no Sistema (/usr/local/bin) — Fedora

```bash
chmod +x omniroute.sh
sudo ./omniroute.sh --install-system
```

## 🔧 Comandos da CLI

| Comando | Descrição |
| ------- | --------- |
| `-p, --port <porta>` | Porta do servidor (padrão: 20128) |
| `-H, --host <host>` | Host para bind (padrão: 0.0.0.0) |
| `-n, --no-browser` | Não abre o navegador automaticamente |
| `-l, --log` | Exibe logs do servidor |
| `-t, --tray` | Executa em modo de bandeja (background) |
| `-h, --help` | Mostra ajuda |
| `-v, --version` | Mostra versão |

## 📦 Gerenciamento

### Verificar instalação

```bash
omniroute --version
```

### Atualizar

```bash
# Reinstalar com a versão mais recente
npm install -g omniroute
```

### Desinstalar

```bash
# Instalação do usuário
./omniroute.sh --uninstall

# Instalação global
sudo ./omniroute.sh --uninstall-system
```

## 🔑 Configuração de API

Edite `~/.claude.json`:

```json
{
  "primaryApiKey": "sua-chave-aqui",
  "openRouterApiKey": "sua-chave-aqui"
}
```

Edite `~/.config/secrets.env`:

```env
export ANTHROPIC_API_KEY="sua-chave-aqui"
export GEMINI_API_KEY="sua-chave-aqui"
export OPENAI_API_KEY="sua-chave-aqui"
```

## 🐧 Distribuições Suportadas

- **Fedora** (39, 40, 41+)
- **Fedora Atomic**: Silverblue, Kinoite, COSMIC
- **Derivados**: Nobara, Bluefin, Aurora, Ultramarine
- **RHEL/CentOS/Rocky/AlmaLinux** (via `--install-system` ou `--install`)
