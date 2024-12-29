#!/bin/bash

# Função para exibir mensagens de erro e sair
function error_exit {
  echo "Erro: $1" >&2
  exit 1
}

# Verificar se o usuário é root
if [ "$EUID" -ne 0 ]; then
  error_exit "Este script precisa ser executado como root ou usando sudo."
fi

# Atualizar os pacotes
echo "Atualizando pacotes..."
apt update || error_exit "Não foi possível atualizar os pacotes."
apt upgrade -y || error_exit "Não foi possível atualizar os pacotes."

# Instalar o Multipass
echo "Instalando o Multipass..."
apt install -y snapd || error_exit "Não foi possível instalar o snapd."
snap install multipass || error_exit "Não foi possível instalar o Multipass."

# Verificar a instalação do Multipass
if ! command -v multipass &> /dev/null; then
  error_exit "O Multipass não foi instalado corretamente."
fi

# Criar a máquina Ubuntu 20.04 com 4 GB de RAM e 50 GB de armazenamento
VM_NAME="ubuntu-20-04-vm"
MEMORY="4G"
DISK="50G"
IMAGE="20.04"

echo "Iniciando a criação da máquina virtual..."
multipass launch --name "$VM_NAME" --mem "$MEMORY" --disk "$DISK" "$IMAGE" || error_exit "Não foi possível criar a máquina virtual."

# Verificar o status da máquina virtual
if ! multipass info "$VM_NAME" | grep -q "RUNNING"; then
  error_exit "A máquina virtual não está em execução."
fi

echo "Máquina virtual criada e em execução com sucesso!"

# Exibir informações da máquina
multipass info "$VM_NAME"

# Acessar a máquina virtual
echo "Para acessar a máquina virtual, use o comando:"
echo "multipass shell $VM_NAME"
