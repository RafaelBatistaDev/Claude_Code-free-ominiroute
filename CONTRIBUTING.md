# 🤝 Guia de Contribuição

Obrigado pelo interesse em contribuir com o **OmniRoute CLI**!

## Como contribuir

1. **Fork** o repositório
2. Crie uma branch descritiva: `git checkout -b feat/minha-feature`
3. Faça suas alterações
4. Execute os scripts de validação:
   ```bash
   bash -n omniroute.sh          # Valida sintaxe do shell script
   ```
5. Commit com mensagem clara:
   ```
   feat: Adiciona suporte a nova distribuição
   fix: Corrige erro de PATH no Windows
   docs: Atualiza README com instruções
   ```
6. Push: `git push origin feat/minha-feature`
7. Abra um **Pull Request**

## Padrões de código

- Shell script: `bash -n` deve passar sem erros
- PowerShell: mantenha compatibilidade com Windows 10/11
- Markdown: tabelas com separadores alinhados
- Nunca inclua chaves de API ou tokens nos arquivos
- Use `sua-chave-aqui` como placeholder em exemplos

## Reportando bugs

Abra uma [issue](https://github.com/recifecrypto/omniroute-cli/issues) com:
- Sistema operacional e versão
- O comando executado
- A saída completa do terminal
- O que você esperava que acontecesse

## Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a **MIT License**.
