## DEB AWS - Script de configuração automática pra debian na AWS

**Introdução:**

Este script automatiza a configuração de um servidor Debian, incluindo:

* Atualização do sistema
* Instalação de aplicativos básicos
* Configuração de proxy para GitHub IPv6
* Mudança de fuso horário para São Paulo
* Instalação e configuração do NFS (servidor e cliente)
* Instalação e configuração do Docker
* Instalação e configuração do Docker Swarm (opcional)
* Instalação do Portainer (opcional)

**Documentação Detalhada:**

**1. Variáveis:**

| Nome da Variável | Descrição | Padrão | Opções |
|---|---|---|---|
| `DEFAULT_ROOT_PASSWORD` | Senha padrão do root | `_SUA_SENHA_AQUI_` | Qualquer senha |
| `DEFAULT_INSTALL_APPS` | Indica se os aplicativos básicos serão instalados | `sim` | `sim` ou `nao` |
| `DEFAULT_ADD_PROXY` | Indica se o proxy para GitHub IPv6 será configurado | `sim` | `sim` ou `nao` |
| `DEFAULT_CHANGE_TZ` | Indica se o fuso horário será mudado para São Paulo | `sim` | `sim` ou `nao` |
| `DEFAULT_INSTALL_NFS` | Indica se o NFS será instalado (servidor, cliente, ambos ou nenhum) | `none` | `server`, `client`, `both` ou `none` |
| `DEFAULT_NETWORK_IP` | IP da rede para configuração do NFS | "" | Endereço IP válido |
| `DEFAULT_SERVER_IP` | IP do servidor para configuração do NFS | "" | Endereço IP válido |
| `DEFAULT_INSTALL_DOCKER` | Indica se o Docker será instalado | `nao` | `sim` ou `nao` |
| `DEFAULT_NFS_SERVER_PATH` | Caminho do servidor NFS | `/mnt/shared` | Caminho do diretório no servidor |
| `DEFAULT_NFS_CLIENT_PATH` | Caminho do cliente NFS | `/mnt/nfs` | Caminho do diretório no cliente |
| `DEFAULT_INSTALL_PORTAINER` | Indica se o Portainer será instalado (nenhum, community ou enterprise) | `none` | `none`, `community` ou `enterprise` |
| `DEFAULT_CHANGE_ROOT_PASSWORD` | Indica se a senha do root será alterada | `sim` | `sim` ou `nao` |
| `DEFAULT_SWARM_ROLE` | Função do nó no Swarm (manager ou worker) | `none` | `manager` ou `worker` |
| `DEFAULT_MANAGER_TOKEN` | Token do manager do Docker Swarm | "" | Token do manager |
| `DEFAULT_WORKER_TOKEN` | Token do worker do Docker Swarm | "" | Token do worker |

**2. Execução:**

* O script pode ser executado de forma interativa ou silenciosa.
* Na execução interativa, o usuário será questionado sobre cada opção.
* Na execução silenciosa, as opções serão predefinidas com os valores padrão.

**3. Tarefas:**

* **Atualização do sistema:**
    * Atualiza os pacotes do sistema.

* **Instalação de aplicativos:**
    * Instala os seguintes aplicativos:
        * unattended-upgrades
        * git
        * curl
        * wget
        * nano
        * htop

* **Configuração de proxy:**
    * Adiciona um proxy para GitHub IPv6 no arquivo `/etc/hosts`.

* **Mudança de fuso horário:**
    * Define o fuso horário para "America/Sao_Paulo".

* **Instalação do NFS:**
    * Instala o servidor e/ou cliente NFS.
    * Configura o servidor NFS com o caminho especificado.
    * Configura o cliente NFS para montar o compartilhamento do servidor.

* **Instalação do Docker:**
    * Instala o Docker.

* **Instalação do Docker Swarm:**
    * Instala o Docker Swarm.
    * Configura o nó como manager ou worker.

* **Instalação do Portainer:**
    * Instala o Portainer Community ou Enterprise.

* **Informação da senha do root:**
    * Se a senha do root for alterada, o script informa a nova senha ao usuário.

**4. Observações:**

* É importante testar o script em um ambiente de teste antes de usá-lo em um ambiente de produção.
* O script pode ser personalizado de acordo com as suas necessidades.

## Suporte

* Para dúvidas ou problemas com o script, entre em contato com o autor através do GitHub: [https://github.com/koga436/debaws]

**Informações Adicionais:**

## Instalação e Execução do Script debaws

**Pré-requisitos:**

* Acesso SSH ao servidor Debian
* Permissões de root

**Passo 1: Conectar-se como root**

Para executar o script debaws, você precisa estar conectado ao seu servidor como root. Você pode fazer isso de duas maneiras:

* **Usando o comando `sudo su`:**

```
$ sudo su
```

* **Efetuando login diretamente como root:**

```
$ su root
```

**Passo 2: Baixar o Script**

Baixe o script debaws do GitHub usando o comando `curl`:

```
$ curl -sL https://raw.githubusercontent.com/koga436/debaws/main/script.sh -o script.sh
```

**Passo 3: Conceder Permissões de Execução**

O script precisa ter permissões de execução para ser executado. Para isso, use o comando `chmod`:

```
$ chmod +x script.sh
```

**Passo 4: Executar o Script**

Finalmente, execute o script usando o comando `./`:

```
$ ./script.sh
```

**Explicação dos Comandos:**

* **`curl -sL https://raw.githubusercontent.com/koga436/debaws/main/script.sh -o script.sh`:** Este comando baixa o script debaws do GitHub e o salva no seu servidor com o nome `script.sh`.
* **`chmod +x script.sh`:** Este comando concede permissões de execução ao script `script.sh`.
* **`./script.sh`:** Este comando executa o script `script.sh`.

**Observações:**

* É importante executar o script como root para que ele tenha acesso aos recursos do sistema.
* Ao executar o script pela primeira vez, você será questionado sobre as opções de configuração.
* As opções de configuração padrão são adequadas para a maioria dos casos.
* Você pode alterar as opções de configuração de acordo com suas necessidades.
