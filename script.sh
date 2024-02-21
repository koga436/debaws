#!/bin/bash

# Variáveis padrão
DEFAULT_ROOT_PASSWORD="SUA_SENHA_AQUI"
DEFAULT_INSTALL_APPS="yes"
DEFAULT_ADD_PROXY="yes"
DEFAULT_CHANGE_TZ="yes"
DEFAULT_INSTALL_NFS="none"
DEFAULT_NETWORK_IP=""
DEFAULT_SERVER_IP=""
DEFAULT_INSTALL_DOCKER="yes"
DEFAULT_NFS_SERVER_PATH="/mnt/shared"
DEFAULT_NFS_CLIENT_PATH="/mnt/nfs"
DEFAULT_INSTALL_PORTAINER="none"  # Adicionado
DEFAULT_CHANGE_ROOT_PASSWORD="yes"  # Adicionado
DEFAULT_SWARM_ROLE="none"  # Adicionado
DEFAULT_MANAGER_TOKEN=""  # Adicionado
DEFAULT_WORKER_TOKEN=""  # Adicionado

# Pergunta ao usuário se o script deve ser executado silenciosamente
read -p "Executar silenciosamente? (s/n) " SILENT
if [[ "$SILENT" =~ ^[Ss]$ ]]
then
    ROOT_PASSWORD=$DEFAULT_ROOT_PASSWORD
    INSTALL_APPS=$DEFAULT_INSTALL_APPS
    ADD_PROXY=$DEFAULT_ADD_PROXY
    CHANGE_TZ=$DEFAULT_CHANGE_TZ
    INSTALL_NFS=$DEFAULT_INSTALL_NFS
    NETWORK_IP=$DEFAULT_NETWORK_IP
    SERVER_IP=$DEFAULT_SERVER_IP
    INSTALL_DOCKER=$DEFAULT_INSTALL_DOCKER
    NFS_SERVER_PATH=$DEFAULT_NFS_SERVER_PATH
    NFS_CLIENT_PATH=$DEFAULT_NFS_CLIENT_PATH
    INSTALL_PORTAINER=$DEFAULT_INSTALL_PORTAINER  # Adicionado
    CHANGE_ROOT_PASSWORD=$DEFAULT_CHANGE_ROOT_PASSWORD  # Adicionado
    INSTALL_SWARM=$DEFAULT_INSTALL_SWARM  # Adicionado
    SWARM_ROLE=$DEFAULT_SWARM_ROLE  # Adicionado
    MANAGER_TOKEN=$DEFAULT_MANAGER_TOKEN  # Adicionado
    WORKER_TOKEN=$DEFAULT_WORKER_TOKEN  # Adicionado
else
    if [[ "$CHANGE_ROOT_PASSWORD" =~ ^[Ss]$ ]]  # Adicionado
    then
        read -p "Senha do root (padrão: $DEFAULT_ROOT_PASSWORD): " ROOT_PASSWORD
        ROOT_PASSWORD=${ROOT_PASSWORD:-$DEFAULT_ROOT_PASSWORD}
    fi

    if [[ "$INSTALL_DOCKER" =~ ^[Ss]$ ]]  # Adicionado
    then
        read -p "Instalar Docker Swarm? (s/n, padrão: $DEFAULT_INSTALL_SWARM) " INSTALL_SWARM  # Adicionado
        INSTALL_SWARM=${INSTALL_SWARM:-$DEFAULT_INSTALL_SWARM}  # Adicionado
    fi

    # Pergunta ao usuário se o Docker deve ser instalado
    if [[ "$INSTALL_DOCKER" =~ ^[Ss]$ ]]
    then
        # Se o Docker for instalado, pergunta ao usuário se o Docker Swarm deve ser instalado
        read -p "Instalar Docker Swarm? (s/n, padrão: $DEFAULT_INSTALL_SWARM) " INSTALL_SWARM
        INSTALL_SWARM=${INSTALL_SWARM:-$DEFAULT_INSTALL_SWARM}
    
        # Se o Docker Swarm for instalado, pergunta ao usuário qual função o nó deve ter no Swarm (manager ou worker)
        if [[ "$INSTALL_SWARM" =~ ^[Ss]$ ]]
        then
            read -p "Função no Swarm (manager/worker, padrão: $DEFAULT_SWARM_ROLE): " SWARM_ROLE
            SWARM_ROLE=${SWARM_ROLE:-$DEFAULT_SWARM_ROLE}
    
            # Se a função for "manager", pergunta ao usuário o token do manager e configura o Docker Swarm como manager
            if [[ "$SWARM_ROLE" == "manager" ]]
            then
                read -p "Token do manager (padrão: $DEFAULT_MANAGER_TOKEN): " MANAGER_TOKEN
                MANAGER_TOKEN=${MANAGER_TOKEN:-$DEFAULT_MANAGER_TOKEN}
                echo "Configurando Docker Swarm como manager..."
                sudo docker swarm init --advertise-addr $(hostname -i) --token $MANAGER_TOKEN
                echo "Docker Swarm configurado como manager!"
            # Se a função for "worker", pergunta ao usuário o token do worker e configura o Docker Swarm como worker
            elif [[ "$SWARM_ROLE" == "worker" ]]
            then
                read -p "Token do worker (padrão: $DEFAULT_WORKER_TOKEN): " WORKER_TOKEN
                WORKER_TOKEN=${WORKER_TOKEN:-$DEFAULT_WORKER_TOKEN}
                echo "Configurando Docker Swarm como worker..."
                sudo docker swarm join --token $WORKER_TOKEN
                echo "Docker Swarm configurado como worker!"
            fi
        fi
    fi

    
    read -p "Instalar aplicativos (unattended-upgrades git curl wget nano htop)? (s/n, padrão: $DEFAULT_INSTALL_APPS) " INSTALL_APPS
    INSTALL_APPS=${INSTALL_APPS:-$DEFAULT_INSTALL_APPS}

    read -p "Adicionar proxy para GitHub IPv6? (s/n, padrão: $DEFAULT_ADD_PROXY) " ADD_PROXY
    ADD_PROXY=${ADD_PROXY:-$DEFAULT_ADD_PROXY}

    read -p "Mudar TZ para São Paulo? (s/n, padrão: $DEFAULT_CHANGE_TZ) " CHANGE_TZ
    CHANGE_TZ=${CHANGE_TZ:-$DEFAULT_CHANGE_TZ}

    read -p "Instalar NFS? (server/client/both/none, padrão: $DEFAULT_INSTALL_NFS) " INSTALL_NFS
    INSTALL_NFS=${INSTALL_NFS:-$DEFAULT_INSTALL_NFS}

    if [[ "$INSTALL_NFS" =~ ^(server|both)$ ]]
    then
        read -p "IP da rede (padrão: $DEFAULT_NETWORK_IP): " NETWORK_IP
        NETWORK_IP=${NETWORK_IP:-$DEFAULT_NETWORK_IP}

        read -p "Caminho do servidor NFS (padrão: $DEFAULT_NFS_SERVER_PATH): " NFS_SERVER_PATH
        NFS_SERVER_PATH=${NFS_SERVER_PATH:-$DEFAULT_NFS_SERVER_PATH}
    fi

    if [[ "$INSTALL_NFS" =~ ^(client|both)$ ]]
    then
        read -p "IP do servidor (padrão: $DEFAULT_SERVER_IP): " SERVER_IP
        SERVER_IP=${SERVER_IP:-$DEFAULT_SERVER_IP}

        read -p "Caminho do cliente NFS (padrão: $DEFAULT_NFS_CLIENT_PATH): " NFS_CLIENT_PATH
        NFS_CLIENT_PATH=${NFS_CLIENT_PATH:-$DEFAULT_NFS_CLIENT_PATH}
    fi

    read -p "Instalar Docker? (s/n, padrão: $DEFAULT_INSTALL_DOCKER) " INSTALL_DOCKER
    INSTALL_DOCKER=${INSTALL_DOCKER:-$DEFAULT_INSTALL_DOCKER}

    if [[ "$INSTALL_DOCKER" =~ ^[Ss]$ ]]  # Adicionado
    then
        read -p "Instalar Portainer? (none/community/enterprise, padrão: $DEFAULT_INSTALL_PORTAINER) " INSTALL_PORTAINER  # Adicionado
        INSTALL_PORTAINER=${INSTALL_PORTAINER:-$DEFAULT_INSTALL_PORTAINER}  # Adicionado
    fi
fi

# Atualiza o sistema
sudo apt update -y && sudo apt upgrade -y

# Instala os aplicativos, se necessário
if [[ "$INSTALL_APPS" =~ ^[Ss]$ ]]
then
    sudo apt install -y unattended-upgrades git curl wget nano htop
fi

# Configura o login e a senha do root, se necessário
if [[ "$CHANGE_ROOT_PASSWORD" =~ ^[Ss]$ ]]  # Adicionado
then
    sudo touch ~/.hushlogin
    echo -e "PermitRootLogin yes\nPasswordAuthentication yes" | sudo tee /etc/ssh/sshd_config.d/aws.conf
    echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | sudo passwd root
fi

CONFIG_FILE="/etc/apt/apt.conf.d/50unattended-upgrades"

# 1. Cria o backup se não existir
if [ ! -f ${CONFIG_FILE}.bak ]; then
  sudo cp ${CONFIG_FILE} ${CONFIG_FILE}.bak
fi

# 2. Deleta o arquivo original (apenas se o backup foi criado)
if [ -f ${CONFIG_FILE}.bak ]; then
  sudo rm ${CONFIG_FILE}
fi

# 3. Cria um novo arquivo com o conteúdo desejado
sudo bash -c "cat > ${CONFIG_FILE}" << EOL
    Unattended-Upgrade::Origins-Pattern {
    "origin=Debian,codename=\${distro_codename}-updates";
    "origin=Debian,codename=\${distro_codename}-proposed-updates";
    "origin=Debian,codename=\${distro_codename},label=Debian";
    "origin=Debian,codename=\${distro_codename},label=Debian-Security";
    "origin=Debian,codename=\${distro_codename}-security,label=Debian-Security";
    };

    Unattended-Upgrade::AutoFixInterruptedDpkg "true";
    Unattended-Upgrade::MinimalSteps "true";
    Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
    Unattended-Upgrade::Remove-Unused-Dependencies "true";
    Unattended-Upgrade::Automatic-Reboot "true";
    Unattended-Upgrade::Automatic-Reboot-WithUsers "true";
    Unattended-Upgrade::SyslogEnable "true";
    Unattended-Upgrade::Allow-APT-Mark-Fallback "true";
    EOL

# Adiciona o proxy para GitHub IPv6, se necessário
if [[ "$ADD_PROXY" =~ ^[Ss]$ ]]
then
    echo -e "2a01:7c8:7c8::1337 github.com\n2a01:7c8:7c8::1337 api.github.com\n2a01:7c8:7c8::1337 codeload.github.com\n2a01:7c8:7c8::1337 objects.githubusercontent.com\n2a01:7c8:7c8::1337 raw.githubusercontent.com" | sudo tee -a /etc/hosts
fi

# Muda a TZ para São Paulo, se necessário
if [[ "$CHANGE_TZ" =~ ^[Ss]$ ]]
then
    sudo timedatectl set-timezone America/Sao_Paulo
fi

# Instala o Docker, se necessário
if [[ "$INSTALL_DOCKER" =~ ^[Ss]$ ]]
then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
fi

# Instala o Docker Swarm, se necessário
if [[ "$INSTALL_DOCKER" =~ ^[Ss]$ ]] && [[ "$INSTALL_SWARM" =~ ^[Ss]$ ]]
then
  echo "Instalando Docker Swarm..."

  if [[ "$DEFAULT_SWARM_ROLE" == "none" ]]; then
    # Executa o `sudo docker swarm init` apenas se a opção for "none"
    sudo docker swarm init
    echo "Docker Swarm instalado com sucesso!"
  else
    # Configuração para manager ou worker
    read -p "Função no Swarm (manager/worker, padrão: $DEFAULT_SWARM_ROLE): " SWARM_ROLE
    SWARM_ROLE=${SWARM_ROLE:-$DEFAULT_SWARM_ROLE}

    if [[ "$SWARM_ROLE" == "manager" ]]; then
      # Configuração para manager
      read -p "Token do manager (padrão: $DEFAULT_MANAGER_TOKEN): " MANAGER_TOKEN
      MANAGER_TOKEN=${MANAGER_TOKEN:-$DEFAULT_MANAGER_TOKEN}
      echo "Configurando Docker Swarm como manager..."
      sudo docker swarm join --token $MANAGER_TOKEN
      echo "Docker Swarm configurado como manager!"
    elif [[ "$SWARM_ROLE" == "worker" ]]; then
      # Configuração para worker
      read -p "Token do worker (padrão: $DEFAULT_WORKER_TOKEN): " WORKER_TOKEN
      WORKER_TOKEN=${WORKER_TOKEN:-$DEFAULT_WORKER_TOKEN}
      echo "Configurando Docker Swarm como worker..."
      sudo docker swarm join --token $WORKER_TOKEN
      echo "Docker Swarm configurado como worker!"
    fi
  fi
fi

# Instala e configura o NFS, se necessário
if [[ "$INSTALL_NFS" =~ ^(server|both)$ ]]
then
    # Instala o NFS Server
    sudo apt install -y nfs-kernel-server

    # Configura o servidor NFS
    sudo mkdir -p $NFS_SERVER_PATH
    echo "$NFS_SERVER_PATH $NETWORK_IP(rw,sync,no_subtree_check,all_squash)" | sudo tee -a /etc/exports
    sudo exportfs -a
    sudo systemctl restart nfs-kernel-server
    sudo chown nobody:nogroup $NFS_SERVER_PATH
    sudo chmod 777 $NFS_SERVER_PATH
fi

if [[ "$INSTALL_NFS" =~ ^(client|both)$ ]]
then
    # Instala o NFS Client
    sudo apt install -y nfs-common

    # Configura o cliente NFS
    sudo mkdir -p $NFS_CLIENT_PATH
    echo "$SERVER_IP:$NFS_SERVER_PATH $NFS_CLIENT_PATH nfs rw,defaults 0 0" | sudo tee -a /etc/fstab
    sudo mount -a
fi

# Instala o Portainer, se necessário
if [[ "$INSTALL_DOCKER" =~ ^[Ss]$ ]] && [[ "$INSTALL_PORTAINER" =~ ^(community|enterprise)$ ]]  # Modificado
then
    # Instala o Portainer
    if [[ "$INSTALL_PORTAINER" == "community" ]]
    then
        echo "Instalando Portainer Community..."
        sudo docker volume create portainer_data
        sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
        echo "Portainer Community instalado com sucesso!"
    elif [[ "$INSTALL_PORTAINER" == "enterprise" ]]
    then
        echo "Instalando Portainer Enterprise..."
        sudo docker volume create portainer_data
        sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest
        echo "Portainer Enterprise instalado com sucesso!"

# Informa ao usuário a senha do root, se necessário
if [[ "$CHANGE_ROOT_PASSWORD" =~ ^[Ss]$ ]]  # Adicionado
then
    echo "Sua senha de root é $ROOT_PASSWORD"
fi

