Segue o script em Bash para instalar o **Multipass**, iniciar uma máquina virtual Ubuntu 20.04 com 2 GB de memória e 10 GB de armazenamento, e garantir que ela esteja pronta ao final do processo:



Caso necessário para resolver o problema de permissões do Docker ao instalar o software. A solução foi incorporada diretamente no script, garantindo que o usuário seja adicionado ao grupo `docker` após a instalação.

### Script Ajustado

```
#!/bin/bash

# Verificar se o Multipass está instalado
if ! command -v multipass &> /dev/null
then
    echo "Multipass não encontrado. Instalando..."
    sudo snap install multipass
    echo "Multipass instalado com sucesso."
else
    echo "Multipass já está instalado."
fi

# Definir variáveis
VM_NAME="docker-dc"
MEMORY="2G"
DISK="10G"
CLOUD_INIT_FILE="cloud-init.yaml"

# Perguntar ao usuário
echo "O que deseja fazer?"
echo "1) Criar a máquina virtual $VM_NAME"
echo "2) Deletar a máquina virtual $VM_NAME"
echo "3) Cancelar"
read -p "Escolha uma opção (1/2/3): " USER_CHOICE

case $USER_CHOICE in
    1)
        # Criar a máquina virtual
        echo "Criando arquivo $CLOUD_INIT_FILE..."
        cat <<EOL > $CLOUD_INIT_FILE
#cloud-config
runcmd:
  - sudo apt update
  - sudo apt install -y docker.io curl
  - curl -L "https://github.com/docker/compose/releases/download/\$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
  - sudo chmod +x /usr/local/bin/docker-compose
  - sudo systemctl enable --now docker
  - sudo newgrp docker
  - sudo usermod -aG docker ubuntu
  - sudo systemctl restart docker
  - sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
  - sudo systemctl restart sshd
  - sudo reboot
  - echo "Usuário ubuntu adicionado ao grupo docker. Reinicie a sessão para aplicar as alterações."
EOL
        echo "Arquivo $CLOUD_INIT_FILE criado com sucesso."
        
        echo "Tentando criar a máquina virtual $VM_NAME..."
        if multipass launch --name "$VM_NAME" --memory "$MEMORY" --disk "$DISK" --cloud-init "$CLOUD_INIT_FILE"
        then
            echo "Máquina virtual $VM_NAME criada com sucesso!"
            echo "Após criar a máquina, reinicie a sessão para acessar o Docker sem sudo."
        else
            echo "Erro ao criar a máquina virtual $VM_NAME."
            exit 1
        fi
        ;;
    2)
        # Deletar a máquina virtual
        if multipass list | grep -q "$VM_NAME"
        then
            echo "Deletando a máquina virtual $VM_NAME..."
            multipass delete "$VM_NAME"
            multipass purge
            echo "Máquina virtual $VM_NAME deletada com sucesso!"
        else
            echo "A máquina virtual $VM_NAME não existe."
        fi
        ;;
    3)
        echo "Operação cancelada pelo usuário."
        exit 0
        ;;
    *)
        echo "Opção inválida. Saindo."
        exit 1
        ;;
esac

```

### Alterações Feitas
1. **Adicionar o Usuário ao Grupo Docker**:
   - Incluído o comando `sudo usermod -aG docker ubuntu` no arquivo `cloud-init.yaml`.
   - Isso adiciona o usuário padrão `ubuntu` ao grupo `docker` para evitar problemas de permissão.

2. **Mensagem de Reinício de Sessão**:
   - Adicionada uma mensagem para lembrar o usuário de reiniciar a sessão após a criação da máquina.

3. **Revisão de Erros**:
   - Ajustado para garantir que mensagens claras sejam exibidas em caso de falhas.

### Após Executar o Script
- **Reinicie a Sessão na Máquina Virtual**:
  Faça login novamente para garantir que as permissões do grupo `docker` sejam aplicadas corretamente. Isso pode ser feito com:
  ```bash
  multipass shell docker-dc
  exit
  multipass shell docker-dc
  ```

Testar o Docker com:
```bash
sudo docker run hello-world
```

### Como usar o script

1. Salve o script em um arquivo chamado `install_multipass.sh`.
2. Dê permissão de execução ao script:
   ```bash
   chmod +x install_multipass.sh
   ```
3. Execute o script sem privilégio de superusuário:
   ```bash
   ./install_multipass.sh
   ```
4. Após a execução, você poderá acessar a máquina virtual com o comando:
   ```bash
   multipass shell docker-dc
   ``` 

Esse script cuidará de todo o processo, desde a instalação do Multipass até a criação e inicialização da máquina virtual.
