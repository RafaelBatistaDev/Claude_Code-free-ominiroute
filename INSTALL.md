# 📖 Guia de Instalação — OmniRoute CLI

Este guia cobre a instalação do **OmniRoute CLI** em **Linux** (Fedora, Debian, Ubuntu e derivados) e **Windows 11**.

---

## Índice

- [Linux](#linux)
  - [Pré-requisitos (Linux)](#pré-requisitos-linux)
  - [Instalação Global via Script (recomendado)](#instalação-global-via-script-recomendado)
  - [Instalação no Espaço do Usuário](#instalação-no-espaço-do-usuário)
  - [Empacotamento .deb (Debian/Ubuntu)](#empacotamento-deb-debianubuntu)
  - [Empacotamento RPM (Fedora/RHEL)](#empacotamento-rpm-fedorarhel)
  - [Sistemas Imutáveis](#sistemas-imutáveis-silverblue--kinoite--cosmic)
- [Windows 11](#windows-11)
  - [Pré-requisitos (Windows)](#pré-requisitos-windows)
  - [Instalação via PowerShell](#instalação-via-powershell)
  - [Instalação Manual](#instalação-manual)
  - [Desinstalação (Windows)](#desinstalação-windows)
- [Pós-instalação](#pós-instalação)
- [Solução de Problemas](#solução-de-problemas)
- [Desinstalação (Linux)](#desinstalação-linux)

---

# Linux

## Pré-requisitos (Linux)

### Opção 1: Bun (recomendado)

```bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
```

### Opção 2: Node.js/npm

**Fedora/RHEL:**
```bash
sudo dnf install -y nodejs npm
```

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install -y nodejs npm
```

---

## Instalação Global via Script (recomendado)

Funciona em **qualquer distribuição Linux**. Instala em `/usr/local/bin/`.

```bash
cd /caminho/para/OmniRoute-Cli
chmod +x omniroute.sh
sudo ./omniroute.sh --install-system
```

### O que o script faz:

1. Detecta automaticamente a distribuição (Fedora, Debian, Ubuntu, etc.)
2. Verifica dependências (Bun/npm)
3. Copia o script para `/usr/local/bin/omniroute`
4. Tenta instalar o pacote `omniroute` via npm global
5. Configura diretórios de dados em `/usr/local/share/omniroute-cli/`

---

## Instalação no Espaço do Usuário

Alternativa **sem sudo** para qualquer distribuição. Instala em `~/.local/bin/`.

```bash
cd /caminho/para/OmniRoute-Cli
chmod +x omniroute.sh
./omniroute.sh --install
```

Após a instalação, configure o PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Empacotamento .deb (Debian/Ubuntu)

### Método rápido via script

```bash
chmod +x omniroute.sh
sudo ./omniroute.sh --install-deb
sudo dpkg -i /tmp/omniroute-cli_1.0.0_all.deb
sudo apt install -f   # corrigir dependências se necessário
```

### Método manual

```bash
# Instalar ferramentas de empacotamento
sudo apt install -y dpkg-dev fakeroot

# Criar estrutura
mkdir -p /tmp/omniroute-deb/DEBIAN
mkdir -p /tmp/omniroute-deb/usr/local/bin

# Copiar arquivos
cp omniroute.sh /tmp/omniroute-deb/usr/local/bin/omniroute
chmod +x /tmp/omniroute-deb/usr/local/bin/omniroute

# Criar arquivo de controle
cat > /tmp/omniroute-deb/DEBIAN/control << 'CONTROL'
Package: omniroute-cli
Version: 1.0.0
Section: utils
Priority: optional
Architecture: all
Depends: nodejs (>= 18), npm
Maintainer: OmniRoute Team <recifecrypto@gmail.com>
Description: OmniRoute CLI - API route manager
CONTROL

# Construir o pacote
fakeroot dpkg-deb --build /tmp/omniroute-deb /tmp/omniroute-cli_1.0.0_all.deb

# Instalar
sudo dpkg -i /tmp/omniroute-cli_1.0.0_all.deb
sudo apt install -f
```

### Desinstalar pacote .deb

```bash
sudo dpkg -r omniroute-cli
```

---

## Empacotamento RPM (Fedora/RHEL)

### Método rápido via script

```bash
sudo ./omniroute.sh --install-system
```

### Método manual com rpmbuild

```bash
# Instalar ferramentas
sudo dnf install -y rpm-build rpmdevtools
rpmdev-setuptree

# Preparar sources
mkdir -p ~/rpmbuild/SOURCES/omniroute-cli-1.0.0
cp omniroute.sh ~/rpmbuild/SOURCES/omniroute-cli-1.0.0/
cp *.md ~/rpmbuild/SOURCES/omniroute-cli-1.0.0/
cd ~/rpmbuild/SOURCES
tar czf omniroute-cli-1.0.0.tar.gz omniroute-cli-1.0.0/

# Arquivo .spec
cat > ~/rpmbuild/SPECS/omniroute-cli.spec << 'EOF'
Name:       omniroute-cli
Version:    1.0.0
Release:    1%{?dist}
Summary:    OmniRoute CLI - API route manager
License:    MIT
URL:        https://github.com/recifecrypto/omniroute-cli
Source0:    %{name}-%{version}.tar.gz
Requires:   nodejs, npm

%description
OmniRoute CLI is a command-line interface for managing API routes
with multiple AI providers.

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/omniroute-cli
install -m 755 %{_builddir}/%{name}-%{version}/omniroute.sh %{buildroot}%{_bindir}/omniroute
cp -r %{_builddir}/%{name}-%{version}/*.md %{buildroot}%{_datadir}/omniroute-cli/

%files
%{_bindir}/omniroute
%{_datadir}/omniroute-cli/

%post
if command -v npm &>/dev/null; then
    npm install -g omniroute 2>/dev/null || true
fi

%preun
if [ "$1" = "0" ]; then
    if command -v npm &>/dev/null; then
        npm uninstall -g omniroute 2>/dev/null || true
    fi
fi
EOF

# Construir RPM
rpmbuild -ba ~/rpmbuild/SPECS/omniroute-cli.spec

# Instalar
sudo dnf install ~/rpmbuild/RPMS/noarch/omniroute-cli-*.rpm
```

---

## Sistemas Imutáveis (Silverblue / Kinoite / COSMIC)

Em sistemas **Fedora Atomic**, o diretório `/usr/local/bin/` é gravável, mas pode ser revertido em atualizações ostree.

**Recomendado:** instalação do usuário

```bash
./omniroute.sh --install
```

**Alternativa avançada** (camada rpm-ostree):

```bash
# Criar RPM e depois:
sudo rpm-ostree install ~/rpmbuild/RPMS/noarch/omniroute-cli-*.rpm
sudo systemctl reboot
```

---

# Windows 11

## Pré-requisitos (Windows)

### Opção 1: Node.js (recomendado para Windows)

1. Acesse [nodejs.org](https://nodejs.org)
2. Baixe o instalador **LTS** (.msi)
3. Execute o instalador (mantenha as opções padrão)
4. Após instalar, reinicie o terminal

### Opção 2: Bun (mais rápido)

No PowerShell como **Administrador**:

```powershell
powershell -c "irm bun.sh/install.ps1 | iex"
```

---

## Instalação via PowerShell

### 1. Configure a política de execução (uma vez)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2. Execute o script de instalação

**Instalação global (recomendado)** — requer Admin:

```powershell
# PowerShell como Administrador
.\install-omniroute.ps1 -Global
```

**Instalação para o usuário atual:**

```powershell
.\install-omniroute.ps1
```

### Opções do script

| Parâmetro | Descrição |
| --------- | --------- |
| `-Global` | Instala globalmente (requer Admin) |
| `-Check`  | Apenas verifica dependências |
| `-Silent` | Modo silencioso (sem prompts) |
| `-Uninstall` | Remove a instalação |
| `-Help` | Mostra ajuda |

### Exemplos

```powershell
# Verificar dependências
.\install-omniroute.ps1 -Check

# Instalar globalmente (será reiniciado como Admin automaticamente)
.\install-omniroute.ps1 -Global

# Desinstalar
.\install-omniroute.ps1 -Uninstall
```

### Solução de problemas no Windows

**Erro de política de execução:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Bypass da política (sem alterar configuração):**
```powershell
powershell -ExecutionPolicy Bypass -File install-omniroute.ps1 -Global
```

**`omniroute` não é reconhecido:**
1. Abra um **novo** PowerShell (as alterações de PATH precisam de novo terminal)
2. Ou reinicie o computador

---

## Instalação Manual (Windows)

Se preferir instalar manualmente sem o script:

```powershell
# 1. Instalar Node.js (https://nodejs.org) ou Bun

# 2. Instalar omniroute globalmente
npm install -g omniroute

# 3. Verificar
omniroute --version
```

---

## Desinstalação (Windows)

### Via script PowerShell

```powershell
.\install-omniroute.ps1 -Uninstall
```

### Manual

```powershell
npm uninstall -g omniroute
```

Remova também os diretórios de configuração:

```powershell
Remove-Item -Path "$env:APPDATA\omniroute" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\omniroute" -Recurse -Force -ErrorAction SilentlyContinue
```

---

# Pós-instalação

## Verificar se o comando está disponível

```bash
omniroute --version
```

## Configurar chaves de API

Edite `~/.claude.json` (Linux) ou `%USERPROFILE%\.claude.json` (Windows):

```json
{
  "primaryApiKey": "sua-chave-aqui",
  "openRouterApiKey": "sua-chave-aqui"
}
```

Configurar secrets.env (Linux):

```bash
nano ~/.config/secrets.env
```

```env
export ANTHROPIC_API_KEY="sua-chave-aqui"
export GEMINI_API_KEY="sua-chave-aqui"
export OPENAI_API_KEY="sua-chave-aqui"
```

---

# Solução de Problemas

## `omniroute: comando não encontrado`

**Linux — instalação global:**
```bash
ls -la /usr/local/bin/omniroute
```

**Linux — instalação do usuário:**
```bash
echo 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Windows:**
1. Abra um novo PowerShell
2. Ou reinicie o computador

## `npm install -g omniroute` falha

Instale o Bun como alternativa:

**Linux:**
```bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
```

**Windows (PowerShell Admin):**
```powershell
powershell -c "irm bun.sh/install.ps1 | iex"
```

## `Permissão negada` ao instalar (Linux)

Use `sudo` para instalação global:

```bash
sudo ./omniroute.sh --install-system
```

---

# Desinstalação (Linux)

### Instalação do usuário

```bash
./omniroute.sh --uninstall
```

### Instalação global

```bash
sudo ./omniroute.sh --uninstall-system
```

### Pacote .deb

```bash
sudo dpkg -r omniroute-cli
```

### Pacote RPM

```bash
sudo dnf remove omniroute-cli
```
