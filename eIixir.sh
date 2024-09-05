#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${YELLOW}This creak was written by Dikci${NC}"

apt install ufw -y

ufw allow ssh
ufw allow https
ufw allow http
ufw allow 9151
ufw enable

sudo apt-get update -q

sudo apt-get install -qy ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -q

sudo apt-get install -qy docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo -e "${GREEN}The preparation for the installation of the node has been successfully completed${NC}"

echo "-----------------------------------------------------------------------------"
function env {
    if [ ! $validator_name ]; then
        read -p "Введите ваше имя валидатора(придумайте, без спецсимволов - только буквы и цифры): " validator_name
    fi

     if [ ! $address ]; then
        read -p "Введите ваш ip: " address
    fi

    if [ ! $wallet ]; then
        read -p "Введите адрес кошелька ММ(начинается с 0x): " wallet
    fi

    if [ ! $private_key ]; then
        read -p "Введите приватник от ММ: " private_key
        if [[ ! $private_key == 0x* ]]; then
            private_key="0x$private_key"
        fi
    fi
}

function install_docker {
    bash <(curl -s https://raw.githubusercontent.com/artemkovsh/Nodes/main/docker.sh)
}

function prepare_docker_image {
    mkdir -p $HOME/elixir/
    cd $HOME/elixir/

    cat > $HOME/elixir/Dockerfile <<EOF
    ENV=testnet-3
    STRATEGY_EXECUTOR_IP_ADDRESS=$address
    STRATEGY_EXECUTOR_BENEFICIARY=$wallet
    SIGNER_PRIVATE_KEY=$private_key
    STRATEGY_EXECUTOR_DISPLAY_NAME=$validator_name
EOF
}

function delete_old {
    docker rmi -f elixir-validator &>/dev/null
    docker rm -f ev &>/dev/null
    rm -rf $HOME/elixir/ &>/dev/null
}

function build_and_start {
    docker pull elixirprotocol/validator:v3
    docker run -it --env-file ./Dockerfile --name elixir-node --restart unless-stopped -p 17690:17690 elixirprotocol/validator:v3
}

function main {
    env
    install_docker
    delete_old
    prepare_docker_image
    build_and_start
}

main
