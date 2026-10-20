# Preparar e instalar Enterprise Manager Cloud Control 13.3

[← Índice](README.md)

**Escopo:** Cloud Control 13.3; certificação e template específicos ainda dependem da mídia/ambiente.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Roteiro histórico de **EM Cloud Control 13.3**, distinto de EM Express. Confirme no guia/matriz de certificação dessa versão o SO, banco do repositório, patches, CPU, memória, espaço, nomes de host e portas. Não use um template de EM 12c apenas porque ele também menciona Database 12.1.0.2.

## 1. Preparar o SO e o repositório

1. Prepare o [Oracle Linux](<Instalação oracle linux.md>), resolução de nomes estável, sincronização de hora e firewall específico para OMS, agentes e banco.
2. Instale os pacotes exigidos pelo guia **EM 13.3 para seu SO** e pelo banco. O Preinstallation RPM do banco não cobre sozinho todos os requisitos de EM.
3. Instale o Oracle Database certificado e seu patch exigido. Verifique que os pré-requisitos passam; não presuma que qualquer 12c/19c é aceito.
4. Baixe o template de repositório **correspondente a EM 13.3, versão do banco, plataforma e tamanho de implantação**. Extraia-o em `$ORACLE_HOME/assistants/dbca/templates` como proprietário do banco.
5. Execute DBCA e escolha o template adequado. Se optar por CDB/PDB, confira o procedimento e template específicos; não marque CDB automaticamente para toda instalação.
6. Dimensione memória, processos, tablespaces, redo, FRA e ARCHIVELOG pelos requisitos do repositório. Use os scripts de parâmetros fornecidos para o tamanho escolhido; não altere `optimizer_adaptive_features` por hábito em releases que usam outros parâmetros.
7. Teste uma conexão ao serviço/SID exato do repositório. Em PDB, informe ao instalador o **nome completo do serviço**, não o SID da CDB nem um alias local.

## 2. Preparar diretórios e portas

Como root, para diretórios novos destinados ao proprietário `oracle` deste exemplo:

```bash
install -d -o oracle -g oinstall -m 750 /u01/app/oracle/INSTALL/EM
install -d -o oracle -g oinstall -m 750 /u01/app/oracle/middleware
install -d -o oracle -g oinstall -m 750 /u01/app/oracle/agent
```

Confira no guia os intervalos de portas efêmeras e portas reservadas do OMS/agente. Não aplique `11000 65000` indiscriminadamente a um host compartilhado. Quando uma alteração for exigida, registre-a em arquivo de `sysctl.d`, aplique o arquivo e confira com `sysctl net.ipv4.ip_local_port_range`. A sintaxe de uma aplicação direta é `sysctl -w net.ipv4.ip_local_port_range="INICIO FIM"`, com os valores reais substituídos.

Para interface gráfica, use sessão local ou X11 autenticado (`ssh -X`/`-Y` conforme a política e servidor X local). `DISPLAY` não deve ser apontado para um IP aleatório como tentativa de correção.

## 3. Instalar OMS — proprietário do software

1. Baixe **todas** as partes da mídia oficial 13.3, valide checksums e coloque-as no staging.
2. Conceda execução ao binário específico: `chmod u+x em13300_linux64.bin`.
3. Execute `./em13300_linux64.bin` em `/u01/app/oracle/INSTALL/EM`.
4. Preencha informações de suporte/atualização conforme a política. Resolva todos os pré-requisitos.
5. Selecione **Create a new Enterprise Manager system** e o tamanho de implantação correspondente ao template do repositório.
6. Informe Middleware home, Agent base e FQDN corretos. Ambos os homes devem atender às condições de instalação nova do assistente.
7. Informe host, porta e serviço/SID do repositório e a credencial administrativa de banco solicitada.
8. Defina as credenciais do administrador **SYSMAN** e demais credenciais solicitadas. A senha de `SYS` do banco não deve ser presumida como a senha de `SYSMAN` do EM.
9. Configure Software Library, localização compartilhada e BI Publisher somente quando necessários, compatíveis e dimensionados.
10. Revise, instale e execute como root o script indicado pelo assistente, normalmente `MIDDLEWARE_HOME/allroot.sh`. Não substitua o caminho exibido por um caminho de outra instalação.

## 4. Validar

Guarde o resumo da instalação, URL HTTPS do Console, portas e logs em local protegido. A URL é a **informada pelo assistente**, por exemplo `https://emhost.example.test:PORTA/em`; não presuma que seja TCP/5500.

```bash
/u01/app/oracle/middleware/bin/emctl status oms -details
```

Entre no Console com `SYSMAN` e a senha administrativa definida para o EM. Confira OMS, repositório, agente local, upload dos agentes e backups do repositório/configuração. Não encerre a instalação aceitando todas as opções sem ler seu efeito.

## Referências oficiais

- [EM 13.3 — instalação](https://docs.oracle.com/cd/cloud-control-13.3/EMBSC/toc.htm)
- [EM 13.3 — conexão ao repositório](https://docs.oracle.com/cd/cloud-control-13.3/EMADV/GUID-0E1412B5-BBB9-4051-985B-4E3687DAF203.htm)
