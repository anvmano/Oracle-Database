# Criar uma instância Compute no OCI

[← Índice](README.md)

**Escopo:** Instância Compute; não é um DB System gerenciado.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Prepare a [VCN](<Criar VCN no OCI.md>) e a [chave SSH](<Criar Chave SSH.md>). Confirme permissões, cotas e custos da região. Para Oracle Database em Linux, escolha arquitetura e imagem compatíveis com a versão do banco; uma shape ARM não executa a mídia Linux x86-64.

## 1. Escolher o compartimento

Em **Identity & Security → Compartments**, crie ou selecione um compartimento. Compartimentos organizam recursos e políticas IAM; não substituem isolamento de rede. Anote o OCID do **compartimento**, não o da instância.

## 2. Criar a VM

1. Acesse **Compute → Instances → Create instance**, na região correta.
2. Defina nome, compartimento e domínio de disponibilidade.
3. Escolha imagem Oracle Linux e shape certificadas para a instalação pretendida. Dimensione RAM, CPUs, boot volume e volumes de dados pelos requisitos do banco.
4. Selecione a VCN e a sub-rede já preparadas. Associe o NSG apropriado.
5. Atribua IP público somente se o acesso planejado for pela internet. Em rede privada, use VPN ou Bastion.
6. Cole a chave **pública** em formato OpenSSH. Se o Console gerar o par, salve a privada antes de concluir.
7. Revise volumes, metadados, opções de inicialização e valores estimados. Crie a instância.

## 3. Validar

Espere o estado **Running** e verifique diagnósticos de inicialização. Registre OCID da instância, IP e usuário informado pelo Console; imagens Oracle Linux normalmente usam `opc`, enquanto imagens personalizadas podem usar outro usuário.

Siga [Acessar instância](<Acessar instancia no OCI.md>). Se o SSH falhar, revise a cadeia completa: endereço, rota, NSG/security list, firewall e chave.

## Referências oficiais

- [Criar instância](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/launchinginstance.htm)
- [Conectar à instância](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/accessinginstance.htm)
