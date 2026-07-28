<div align="center">
  <h1>🚀 OmniRoute CLI</h1>
  <p><strong>Interface de linha de comando para gerenciamento de rotas de API<br>com múltiplos provedores de IA</strong></p>

  <p>
    <img src="https://img.shields.io/badge/Linux-Fedora_%7C_Debian_%7C_Ubuntu-blue?logo=linux&logoColor=white" alt="Linux">
    <img src="https://img.shields.io/badge/Windows-11_%7C_10-blue?logo=windows&logoColor=white" alt="Windows">
    <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
    <img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Frecifecrypto%2Fomniroute-cli&query=%24.stargazers_count&label=stars&color=yellow" alt="Stars">
  </p>

  <p>
    <a href="#instalação">Instalação</a> •
    <a href="#uso">Uso</a> •
    <a href="INSTALL.md">Guia Completo</a> •
    <a href="CLI.MD">CLI</a> •
    <a href="#contribuição">Contribuição</a>
  </p>
</div>

---

## 📋 Requisitos

- **Bun** ou **npm** (gerenciador de pacotes JavaScript)

---

## 🐧 Linux

### Fedora e derivados (RHEL, CentOS, Rocky, AlmaLinux, Nobara)

```bash
chmod +x omniroute.sh
sudo ./omniroute.sh --install-system
omniroute --help
```

### Debian, Ubuntu e derivados (Mint, Pop!_OS, Kali, Deepin)

```bash
chmod +x omniroute.sh
sudo ./omniroute.sh --install-system
```

**Criar pacote .deb:**
```bash
sudo ./omniroute.sh --install-deb
sudo dpkg -i /tmp/omniroute-cli_1.0.0_all.deb
sudo apt install -f
```

### Instalação por Usuário (qualquer Linux — sem sudo)

```bash
chmod +x omniroute.sh
./omniroute.sh --install
```

---

## 🪟 Windows 11 / 10

### PowerShell (como Administrador)

```powershell
.\install-omniroute.ps1 -Global
```

### Instalação para o usuário atual

```powershell
.\install-omniroute.ps1
```

### Se encontrar erro de permissão

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

> O script instala automaticamente o Bun se necessário, configura o PATH e oferece desinstalação.

---

## ⚙️ Configuração

Edite `~/.claude.json` (Linux) ou `%USERPROFILE%\.claude.json` (Windows):

```json
{
  "primaryApiKey": "sua-chave-aqui",
  "openRouterApiKey": "sua-chave-aqui"
}
```

---

## 📚 Documentação

| Documento | Descrição |
| --------- | --------- |
| [INSTALL.md](INSTALL.md) | Guia completo — Linux (todas as distros) e Windows |
| [CLI.MD](CLI.MD) | Referência de comandos da CLI |
| [Iniciar_omniroute.md](Iniciar_omniroute.md) | Configuração de chaves de API |

---

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch: `git checkout -b minha-feature`
3. Commit suas mudanças: `git commit -m 'feat: Minha nova feature'`
4. Push: `git push origin minha-feature`
5. Abra um Pull Request

---

## 📄 Licença

Distribuído sob licença **MIT**. Veja [LICENSE](LICENSE) para mais informações.

---

<p align="center">
  <sub>Feito com ❤️ para a comunidade de código aberto</sub>
</p>
