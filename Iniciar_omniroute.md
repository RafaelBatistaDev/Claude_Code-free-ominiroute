# Guia de Inicialização — OmniRoute CLI

## 📋 Pré-requisitos

- **Bun** instalado no sistema
- **npm** (gerenciado pelo Bun)
- Acesso à internet para instalar pacotes

---

## 🔧 Instalação Global (recomendado)

```bash
# Torne o script executável
chmod +x omniroute.sh

# Instale globalmente (modo usuário local — ~/.local/bin/)
./omniroute.sh --install

# Ou instale globalmente no sistema (requer sudo — /usr/local/bin/)
sudo ./omniroute.sh --install-system
```

---

## ⚙️ Configuração das Chaves de API

Após instalar, você precisa configurar suas chaves de API no arquivo de configuração.

### Claude Configuration

Edite o arquivo `~/.claude.json` e adicione suas chaves:

```bash
nano ~/.claude.json
```

Substitua pelos valores das suas chaves:

```json
{
  "primaryApiKey": "sua-chave-aqui",
  "openRouterApiKey": "sua-chave-aqui"
}
```

### Configurar via sed (substitua pela sua chave)

```bash
sed -i 's|"openRouterApiKey": "[^"]*"|"openRouterApiKey": "sua-chave-aqui"|g' ~/.claude.json
sed -i 's|"primaryApiKey": "[^"]*"|"primaryApiKey": "sua-chave-aqui"|g' ~/.claude.json
```

### Secrets Environment

Configure o arquivo `~/.config/secrets.env`:

```bash
nano ~/.config/secrets.env
```

Exemplo de conteúdo:

```env
export GOOGLE_API_KEY="sua-chave-aqui"
export GEMINI_API_KEY="sua-chave-aqui"
export GEMINI_BASE_URL="http://localhost:20128"
export ANTHROPIC_BASE_URL="http://localhost:20128"
export ANTHROPIC_API_KEY="sua-chave-aqui"
export OPENAI_BASE_URL="sua-chave-aqui"
export OPENAI_API_BASE="sua-chave-aqui"
export OPENAI_API_KEY="sua-chave-aqui"
export XAI_API_KEY="sua-chave-aqui"
export GITHUB_TOKEN="seu-token-aqui"
```

### Atualizar via Bun (automático)

Você também pode usar este script Bun para configurar automaticamente:

```bash
bun -e '
import os from "node:os";
import path from "node:path";
import fs from "node:fs";

// Configurar ~/.claude.json
const configPath = path.join(os.homedir(), ".claude.json");
const claudeConfig = JSON.parse(fs.readFileSync(configPath, "utf-8"));

claudeConfig.primaryApiKey = "sua-chave-aqui";
claudeConfig.openRouterApiKey = "sua-chave-aqui";

fs.writeFileSync(configPath, JSON.stringify(claudeConfig, null, 2));
console.log("Configuração do Claude atualizada!");

// Configurar ~/.config/secrets.env
const secretsPath = path.join(os.homedir(), ".config", "secrets.env");
let secretsContent = fs.readFileSync(secretsPath, "utf-8");

const replacements = {
  GOOGLE_API_KEY: "sua-chave-aqui",
  GEMINI_API_KEY: "sua-chave-aqui",
  GEMINI_BASE_URL: "http://localhost:20128",
  ANTHROPIC_BASE_URL: "http://localhost:20128",
  ANTHROPIC_API_KEY: "sua-chave-aqui",
  CLAUDE_CODE_MODEL: "fedora",
  OPENAI_BASE_URL: "sua-chave-aqui",
  OPENAI_API_BASE: "sua-chave-aqui",
  OPENAI_API_KEY: "sua-chave-aqui",
  XAI_API_KEY: "sua-chave-aqui",
  GITHUB_TOKEN: "sua-chave-aqui",
};

for (const [key, value] of Object.entries(replacements)) {
  const regex = new RegExp(`^export ${key}=.*$`, "m");
  secretsContent = secretsContent.replace(regex, `export ${key}="${value}"`);
}

fs.writeFileSync(secretsPath, secretsContent);
console.log("secrets.env atualizado!");
'
```

---

## 🚀 Uso

```bash
# Executar CLI
omniroute --version
omniroute --help
omniroute -p 20128
omniroute -p 20128 --no-browser
```

### Opções disponíveis

| Opção | Descrição |
| ----- | --------- |
| `-p, --port <port>` | Porta do servidor (padrão: 20128) |
| `-H, --host <host>` | Host para bind (padrão: 0.0.0.0) |
| `-n, --no-browser` | Não abre o navegador automaticamente |
| `-l, --log` | Exibe logs do servidor |
| `-t, --tray` | Executa em modo de bandeja (background) |
| `-h, --help` | Mostra ajuda |
| `-v, --version` | Mostra versão |

---

## 🗑️ Desinstalação

```bash
# Remover instalação do usuário
./omniroute.sh --uninstall

# Remover instalação do sistema
sudo ./omniroute.sh --uninstall-system
```

---

## 📝 Notas

- Para usuários de **Fedora e derivados**, use `--install-system` para instalação global
- O modo `--install` padrão instala em `~/.local/bin/` (espaço do usuário)
- Certifique-se de configurar suas chaves de API antes de usar
- Todas as chaves neste documento são placeholders — substitua pelas suas
