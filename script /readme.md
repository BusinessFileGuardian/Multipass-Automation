Segue o script em Bash para instalar o **Multipass**, iniciar uma máquina virtual docker-dc com 2 GB de memória e 10 GB de armazenamento, e garantir que ela esteja pronta ao final do processo:

### Como usar o script

1. Salve o script em um arquivo chamado `install_multipass.sh`.
2. Dê permissão de execução ao script:
   ```bash
   chmod +x install_multipass.sh
   ```
3. Execute o script:
   ```bash
   ./install_multipass.sh
   ```
4. Após a execução, você poderá acessar a máquina virtual com o comando:
   ```bash
   multipass shell docker-dc
   ``` 
### Testar o Docker com:
   ```bash
   sudo docker run hello-world
   ``` 
Esse script cuidará de todo o processo, desde a instalação do Multipass até a criação e inicialização da máquina virtual.