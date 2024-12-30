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
USER_DIR="/home/ubuntu"  # Mudança para um diretório onde o usuário tem permissão de escrita

# Caminho da chave pública SSH local
SSH_KEY="$HOME/.ssh/id_rsa.pub"

# Verifica se a chave pública existe
if [ ! -f "$SSH_KEY" ]; then
    echo "Chave pública SSH não encontrada em $SSH_KEY. Por favor, gere uma chave SSH primeiro."
    exit 1
fi

# Perguntar ao usuário
echo "O que deseja fazer?"
echo "1) Criar a máquina virtual $VM_NAME"
echo "2) Deletar a máquina virtual $VM_NAME"
echo "3) Cancelar"
read -p "Escolha uma opção (1/2/3): " USER_CHOICE

case $USER_CHOICE in
    1) # Criar a máquina virtual
        # Obter o diretório onde o script está sendo executado
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

        # Definir o nome do arquivo de boas-vindas
        BOAS_VINDAS_FILE="$SCRIPT_DIR/boas_vindas.sh"

        # Criar o arquivo de boas-vindas
        cat <<EOL > "$BOAS_VINDAS_FILE"
#!/bin/bash
echo "==========================================="
echo "        Bem-vindo à máquina docker-dc       "
echo "==========================================="
echo "Use 'docker --version' para verificar o Docker."
echo "Tenha um ótimo trabalho!"
EOL

        # Tornar o arquivo executável
        chmod +x "$BOAS_VINDAS_FILE"

        # Criar o arquivo de configuração cloud-init
        echo "Criando arquivo $CLOUD_INIT_FILE..."
        cat <<EOL > $CLOUD_INIT_FILE
#cloud-config
runcmd:
  - chmod +x /home/ubuntu/boas_vindas.sh
  - /home/ubuntu/boas_vindas.sh
  - sudo apt update
  - sudo apt install -y docker.io curl
  - curl -L "https://github.com/docker/compose/releases/download/\$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
  - sudo chmod +x /usr/local/bin/docker-compose
  - sudo systemctl enable --now docker
  - sudo newgrp docker
  - sudo usermod -aG docker ubuntu
  - sudo systemctl restart docker
  # Alteração para criação de diretórios no diretório do usuário
  - mkdir -p $USER_DIR/scripts
  - touch $USER_DIR/scripts/install_multipass.sh
  - mkdir -p $USER_DIR/procedures/procedure1
  - touch $USER_DIR/procedures/procedure1/readme.md
  - touch $USER_DIR/procedures/procedure1/script1.sh
  - mkdir -p $USER_DIR/procedures/procedure2
  - touch $USER_DIR/procedures/procedure2/readme.md
  - touch $USER_DIR/procedures/procedure2/script2.sh
  - touch $USER_DIR/README.md
  - echo "Estrutura de diretórios criada com sucesso!"
  # Alteração para uso ssh
  - sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
  # Adicionando chave SSH pública
  - mkdir -p /home/ubuntu/.ssh
  - echo "$(cat $SSH_KEY)" >> /home/ubuntu/.ssh/authorized_keys
  - sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh
  - sudo chmod 700 /home/ubuntu/.ssh
  - sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
  - ls -R $USER_DIR  # Exibe a estrutura criada no diretório de usuário
  
write_files:
  - path: /etc/profile.d/boas_vindas.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      echo "==========================================="
      echo "      DDDDD              CCCCC      "
      echo " ▂▃▄▅▆▇█▓▒░  docker dc   ░▒▓█▇▆▅▄▃▂ "
      echo "    Feliz 2025!"☆.。.:・°☆.。.:・°    "
      echo "==========================================="
      echo "Use 'docker --version' para verificar o Docker."
      echo "Tenha um ótimo trabalho!"  
      echo "==========================================="
      echo "        Bem-vindo à máquina docker-dc      "

      echo "==========================================="
      echo "Use 'docker --version' para verificar o Docker."
      echo "Tenha um ótimo trabalho!"  

EOL

        echo "Arquivo $CLOUD_INIT_FILE criado com sucesso."
        
        echo "Tentando criar a máquina virtual $VM_NAME..."
        if multipass launch --name "$VM_NAME" --memory "$MEMORY" --disk "$DISK" --cloud-init "$CLOUD_INIT_FILE"
        then
            echo "Máquina virtual $VM_NAME criada com sucesso!"
            echo "Após criar a máquina, reinicie a sessão para acessar o Docker sem sudo."
            
            # Perguntar se o usuário deseja acessar a máquina agora
            read -p "Deseja acessar a máquina $VM_NAME agora? (s/n): " ACCESS_CHOICE
            if [[ "$ACCESS_CHOICE" == "s" || "$ACCESS_CHOICE" == "S" ]]; then
                # Obter o IP da máquina
                IP_ADDRESS=$(multipass list | grep "$VM_NAME" | awk '{print $3}')
                
                if [ -z "$IP_ADDRESS" ]; then
                    echo "Erro: IP não encontrado para o contêiner $VM_NAME."
                    exit 1
                fi

                # Conectar via SSH
                echo "O IP do contêiner $VM_NAME é: $IP_ADDRESS"
                ssh ubuntu@$IP_ADDRESS
            else
                echo "Você escolheu não acessar a máquina agora. Você pode acessá-la mais tarde usando SSH."
            fi
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
            multipass stop "$VM_NAME"
            multipass delete "$VM_NAME"
            multipass purge
            sudo rm -r cloud-init.yaml
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

[![Clone o repositório](https://img.shields.io/badge/Clone%20o%20reposit%C3%B3rio-%E2%9D%A4%20GitHub-blue)](https://github.com/BusinessFileGuardian/Multipass-Automation)


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
