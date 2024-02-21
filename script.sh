# Variáveis padrão
DEFAULT_ROOT_PASSWORD="_SUA_SENHA_AQUI_"
DEFAULT_INSTALL_APPS="yes"
DEFAULT_ADD_PROXY="yes"
DEFAULT_CHANGE_TZ="yes"
DEFAULT_INSTALL_NFS="no"
DEFAULT_NETWORK_IP=""
DEFAULT_SERVER_IP=""
DEFAULT_INSTALL_DOCKER="yes"

# Pergunta ao usuário se o script deve ser executado silenciosamente
read -p "Executar silenciosamente? (s/n) - Para executar silenciosamente altere os valores DEFAULT no script!" SILENT
if [[ "$SILENT" =~ ^[Ss]$ ]]
then
    ROOT_PASSWORD=$DEFAULT_ROOT_PASSWORD
    INSTALL_APPS=$DEFAULT_INSTALL_APPS
    ADD_PROXY=$DEFAULT_ADD_PROXY
    CHANGE_TZ=$DEFAULT_CHANGE_TZ
    INSTALL_NFS=$DEFAULT_INSTALL_NFS
    NETWORK_IP=$DEFAULT_NETWORK_IP
    SERVER_IP=$DEFAULT_SERVER_IP
    INSTALL_DOCKER=$DEFAULT_INSTALL_DOCKER  # Adicionado
else
    read -p "Senha do root (padrão: $DEFAULT_ROOT_PASSWORD): " ROOT_PASSWORD
    ROOT_PASSWORD=${ROOT_PASSWORD:-$DEFAULT_ROOT_PASSWORD}

    read -p "Instalar aplicativos (unattended-upgrades git curl wget nano htop)? (s/n, padrão: $DEFAULT_INSTALL_APPS) " INSTALL_APPS
    INSTALL_APPS=${INSTALL_APPS:-$DEFAULT_INSTALL_APPS}

    read -p "Adicionar proxy para GitHub IPv6? (s/n, padrão: $DEFAULT_ADD_PROXY) " ADD_PROXY
    ADD_PROXY=${ADD_PROXY:-$DEFAULT_ADD_PROXY}

    read -p "Mudar TZ para São Paulo? (s/n, padrão: $DEFAULT_CHANGE_TZ) " CHANGE_TZ
    CHANGE_TZ=${CHANGE_TZ:-$DEFAULT_CHANGE_TZ}

    read -p "Instalar NFS? (s/n, padrão: $DEFAULT_INSTALL_NFS) " INSTALL_NFS
    INSTALL_NFS=${INSTALL_NFS:-$DEFAULT_INSTALL_NFS}

    read -p "Instalar Docker? (s/n, padrão: $DEFAULT_INSTALL_DOCKER) " INSTALL_DOCKER  # Adicionado
    INSTALL_DOCKER=${INSTALL_DOCKER:-$DEFAULT_INSTALL_DOCKER}  # Adicionado
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

# Instala o Docker, se necessário  # Adicionado
if [[ "$INSTALL_DOCKER" =~ ^[Ss]$ ]]  # Adicionado
then  # Adicionado
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
fi  # Adicionado

# Instala e configura o NFS, se necessário
if [[ "$INSTALL_NFS" =~ ^[Ss]$ ]]
then
    # Instala o NFS Server e o NFS Client
    sudo apt install -y nfs-kernel-server nfs-common

    # Configura o servidor NFS
    sudo mkdir -p /mnt/shared
    echo "/mnt/shared $NETWORK_IP(rw,sync,no_subtree_check,all_squash)" | sudo tee -a /etc/exports
    sudo exportfs -a
    sudo systemctl restart nfs-kernel-server
    sudo chown nobody:nogroup /mnt/shared
    sudo chmod 777 /mnt/shared

    # Configura o cliente NFS
    sudo mkdir -p /mnt/nfs
    echo "$SERVER_IP:/mnt/shared /mnt/nfs nfs rw,defaults 0 0" | sudo tee -a /etc/fstab
    sudo mount -a
fi

# Informa ao usuário a senha do root
echo "Sua senha de root é $ROOT_PASSWORD"
