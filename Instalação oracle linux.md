# Preparar Oracle Linux para um laboratório Oracle

[← Índice](README.md)

**Escopo:** Preparação do SO; versão e kernel sujeitos à certificação do banco.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Os exemplos originais usavam Oracle Linux 7 x86-64. Escolha a versão do SO e o kernel **certificados para a release e o patch do produto**; não aplique este roteiro automaticamente a outra combinação. Requisitos e certificação devem ser conferidos antes de criar a VM.

## 1. Instalar o SO

1. Baixe a ISO oficial e confira seu checksum com o publicado pelo fornecedor.
2. Crie a VM com CPU, RAM e disco suficientes para banco, backups e espaço temporário.
3. Configure fuso horário, teclado e sincronização de tempo.
4. Use instalação mínima para modo silencioso, ou os componentes gráficos exigidos pelo instalador. Não instale todos os grupos de pacotes indiscriminadamente.
5. Escolha o disco de instalação após confirmar sua identidade. Defina `/boot` e, quando necessário, a partição EFI conforme o firmware. Use LVM para os volumes de dados.
6. Dimensione `/`, `/var`, `/tmp`, `/u01` e swap pelos requisitos da versão e pela carga. Os tamanhos do material antigo eram exemplos, não mínimos universais. Separe o destino de backup do volume de dados quando possível.
7. Crie um usuário administrativo com `sudo` e senhas próprias. Mantenha kdump conforme a política de diagnóstico do ambiente.

## 2. Configurar nome e rede

Use um nome de host estável, independente do SID do banco. Em uma rede local, configure IP/gateway/DNS conforme o administrador; no OCI, mantenha DHCP e os parâmetros da imagem.

```bash
hostnamectl
ip -brief address
ip route
getent hosts dbhost.example.test
timedatectl
```

Substitua `dbhost.example.test` pelo nome real. Se usar `/etc/hosts`, associe IP real, FQDN e nome curto, por exemplo `192.0.2.10 dbhost.example.test dbhost`. Não use IP de exemplo na sua rede.

## 3. Atualizar e configurar proteção

Como root, em OL7:

```bash
yum repolist
yum update
```

Revise a transação. Reinicie na janela prevista quando o kernel/pacotes exigirem. Em versões com `dnf`, use o gerenciador correspondente. Preserve SELinux e firewall; qualquer exceção deve ser específica e justificada pelos requisitos do produto.

```bash
cat /etc/oracle-release
uname -r
getenforce
systemctl status firewalld
```

Configure [firewall](<Firewall no linux.md>) e instale o **Preinstallation RPM da versão do banco**, conforme o respectivo guia. Se o pacote falhar, corrija repositórios e dependências; não continue presumindo que os pré-requisitos foram aplicados.

## 4. Componentes opcionais e validação

Instale ferramentas de diagnóstico disponíveis nos repositórios confiáveis apenas quando necessárias. `procps-ng`, por exemplo, fornece `ps`, `top` e `free`; `htop` é outro pacote. EPEL e bibliotecas ASM não são pré-requisitos universais de Oracle Database.

Confira espaço (`df -hT`), memória (`free -h`), resolução de nomes e hora. Faça backup/snapshot do laboratório antes da instalação; snapshot de VM não substitui backup recuperável do banco.

## Referências oficiais

- [Oracle Linux](https://docs.oracle.com/en/operating-systems/oracle-linux/)
- [Pré-instalação 12.1](https://docs.oracle.com/database/121/LADBI/pre_install.htm)
- [Preinstallation RPM 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/installing-oracle-linux-with-public-yum-repository-support.html)
