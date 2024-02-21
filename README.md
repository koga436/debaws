# Script de Configuração do Servidor Debian

Este script bash automatiza a configuração de um novo servidor Debian. Ele foi projetado para ser executado tanto silenciosamente quanto com entrada do usuário.

## Características

- Atualiza o sistema operacional.
- Instala aplicativos essenciais (unattended-upgrades, git, curl, wget, nano, htop).
- Configura o login e a senha do root.
- Configura o unattended-upgrades.
- Adiciona um proxy para GitHub IPv6.
- Muda a TZ para São Paulo.
- Instala o Docker.
- Instala e configura o NFS tanto no servidor quanto no cliente.

## Uso

Primeiro, você precisa baixar o script. Você pode fazer isso usando o comando `curl`:

\`\`\`bash
curl -O https://raw.githubusercontent.com/koga436/debaws/main/script.sh
\`\`\`

Em seguida, você precisa tornar o script executável. Você pode fazer isso com o comando `chmod`:

\`\`\`bash
chmod +x script.sh
\`\`\`

Agora você pode executar o script. Durante a execução, o script fará várias perguntas para personalizar a configuração. Se você quiser executar o script silenciosamente com todas as opções padrão, use o seguinte comando:

\`\`\`bash
./script.sh -s
\`\`\`

Se você quiser executar o script com entrada do usuário, use o seguinte comando:

\`\`\`bash
./script.sh
\`\`\`

## Opções Padrão

As opções padrão do script são as seguintes:

- Senha do root: "_SUA_SENHA_AQUI_"
- Instalar aplicativos: sim
- Adicionar proxy para GitHub IPv6: sim
- Mudar TZ para São Paulo: sim
- Instalar NFS: não
- IP da rede: vazio
- IP do servidor: vazio
- Instalar Docker: sim

## Notas de Segurança

Este script configura várias opções de segurança importantes, incluindo a senha do root e as configurações do unattended-upgrades. No entanto, é importante revisar todas as configurações de segurança e fazer quaisquer ajustes necessários para o seu ambiente específico.

## Contribuições

Contribuições para este script são bem-vindas. Se você encontrar um problema ou tiver uma sugestão de melhoria, sinta-se à vontade para abrir uma issue ou enviar um pull request.
