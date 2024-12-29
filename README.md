
## Sobre o Repositório
Este repositório contém scripts e automações para configurar e gerenciar máquinas virtuais usando o **Multipass** no Linux. Ele é projetado para desenvolvedores que desejam configurar rapidamente ambientes de desenvolvimento locais baseados em Ubuntu.

## Objetivo
Automatizar a criação de uma máquina virtual Ubuntu 20.04 com configurações pré-definidas (4 GB de RAM e 50 GB de armazenamento). Este repositório também fornece uma estrutura modular para outros procedimentos relacionados ao **Multipass**.

---

## Estrutura do Repositório

O repositório está organizado da seguinte forma:

```
├── scripts
│   └── install_multipass.sh
├── procedures
│   ├── procedure1
│   │   ├── readme.md
│   │   └── script1.sh
│   ├── procedure2
│   │   ├── readme.md
│   │   └── script2.sh
│   └── ...
├── README.md
```

### Descrição das Pastas

1. **`scripts/`**
   - Contém scripts para instalação e configuração inicial do **Multipass**.
   - Exemplo: `install_multipass.sh` que instala o **Multipass** e inicia uma máquina virtual com configurações específicas.

2. **`procedures/`**
   - Contém subdiretórios com automações e procedimentos adicionais relacionados ao **Multipass**.
   - Cada subdiretório possui um `readme.md` que explica como usar os scripts e arquivos dentro dele.

   Exemplos de procedimentos:
   - **`procedure1`**: Scripts para ajustes de rede.
   - **`procedure2`**: Configurações de snapshots.

---

## Como Usar o Repositório

### Requisitos
- Linux com suporte a `snapd`.
- Permissão de superusuário (root).

### Passo a Passo
1. Clone este repositório:
   ```bash
   git clone git@github.com:BusinessFileGuardian/Multipass-Automation.git
   cd  Multipass-Automation
   ```

2. Navegue até o diretório `scripts/` e execute o script de instalação:
   ```bash
   cd scripts
   sudo ./install_multipass.sh
   ```

3. Para explorar outros procedimentos, navegue até o diretório `procedures/` e leia os arquivos `readme.md` em cada subdiretório antes de aplicar os scripts.

---

## Estrutura Modular
Os diretórios são projetados para serem autossuficientes, permitindo a reutilização de scripts em diferentes contextos. Certifique-se de verificar as dependências e pré-requisitos listados nos arquivos `readme.md` de cada procedimento antes de executá-los.
- [Acesse as Pastas de Script](./script)
- [Acesse as Pastas de Procedimentos](./procedures)


---

## Contribuição
Contribuições são bem-vindas! Por favor, siga estas etapas:
1. Faça um fork do repositório.
2. Crie um branch para sua contribuição:
   ```bash
   git checkout -b minha-contribuicao
   ```
3. Envie um pull request com suas alterações.

---

## Licença
Este projeto está licenciado sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

