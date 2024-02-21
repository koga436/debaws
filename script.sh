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
else
    read -p "Senha do root (padrão: $DEFAULT_ROOT_PASSWORD): " ROOT_PASSWORD
    ROOT_PASSWORD=${ROOT_PASSWORD:-$DEFAULT_ROOT_PASSWORD}

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

    read -p "Instalar Portainer? (none/community/enterprise, padrão: $DEFAULT_INSTALL_PORTAINER) " INSTALL_PORTAINER  # Adicionado
    INSTALL_PORTAINER=${INSTALL_PORTAINER:-$DEFAULT_INSTALL_PORTAINER}  # Adicionado
fi

# Atualiza o sistema
sudo apt update -y && sudo apt upgrade -y

# Instala os aplicativos, se necessário
if [[ "$INSTALL_APPS" =~ ^[Ss]$ ]]
then
    sudo apt install -y unattended-upgrades git curl wget nano htop
fi

# Configura o login e a senha do root
sudo touch ~/.hushlogin
echo -e "PermitRootLogin yes\nPasswordAuthentication yes" | sudo tee /etc/ssh/sshd_config.d/aws.conf
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | sudo passwd root

# Configura o unattended-upgrades
CONFIG_FILE="/etc/apt/apt.conf.d/50unattended-upgrades"
if [ ! -f ${CONFIG_FILE}.bak ]; then
    sudo cp ${CONFIG_FILE} ${CONFIG_FILE}.bak
fi
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
Unattended-Upgrade::SyslogEnable "false";
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
else
    echo "Docker não está instalado. Por favor, instale o Docker antes de tentar instalar o Portainer."
    exit 1
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
if [[ "$INSTALL_PORTAINER" =~ ^(community|enterprise)$ ]]
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
    fi
fi

# Informa ao usuário a senha do root
echo "Sua senha de root é $ROOT_PASSWORD"
