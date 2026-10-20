# Instalar Oracle Database 19c por RPM em Compute OCI

[← Índice](README.md)

**Escopo:** 19c RPM em Compute OCI; banco single instance autogerenciado.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Este roteiro instala um banco **autogerenciado em Compute**, não um DB System. Use imagem Oracle Linux x86-64 compatível com o RPM e o patch planejados. Confira RAM, swap, disco, licença e certificação. Conclua [criação](<Criar Instancia no OCI.md>) e [acesso SSH](<Acessar instancia no OCI.md>).

## 1. Preparar o host — root

Mantenha firewall e SELinux ativos conforme a configuração suportada. Libere somente as origens/portas necessárias nas regras OCI e no [firewall local](<Firewall no linux.md>). Não desative as duas proteções para resolver falha de conexão.

```bash
yum install oracle-database-preinstall-19c
id oracle
passwd oracle
df -hT
free -h
```

Baixe o RPM da Oracle ou de um repositório privado controlado, confira o checksum publicado e copie-o para o host. Não use o bucket pessoal do documento antigo como fonte de software.

## 2. Instalar software — root

O exemplo pressupõe o RPM oficial salvo em `/tmp`:

```bash
cd /tmp
yum localinstall oracle-database-ee-19c-1.0-1.x86_64.rpm
```

O home desse método é `/opt/oracle/product/19c/dbhome_1`. Não troque depois para `/u01/.../19.3`. Se estiver usando outro pacote/arquitetura, confirme o home informado por ele e adapte o roteiro inteiro.

## 3. Configurar o banco — root

Leia `/etc/sysconfig/oracledb_ORCLCDB-19c.conf` e altere apenas as opções documentadas, como porta do listener e localização de dados. Dimensione armazenamento e memória; não altere a porcentagem de memória do template de forma arbitrária nem edite o script de serviço para mudar nomes internos.

```bash
/etc/init.d/oracledb_ORCLCDB-19c configure
```

No exemplo padrão, são criados `ORCLCDB`, `ORCLPDB1` e listener TCP/1521. Siga os prompts de credenciais e guarde-as fora do acervo. Se falhar, examine logs de instalação e DBCA. Não execute `delete` nem `rm *.ora` como limpeza genérica: isso pode excluir banco ou configurações válidas.

## 4. Carregar o ambiente — oracle

Como root, inicie `su - oracle`; então:

```bash
export ORACLE_SID=ORCLCDB
export ORAENV_ASK=NO
. /usr/local/bin/oraenv
unset ORAENV_ASK
printf '%s\n' "$ORACLE_HOME"
sqlplus / as sysdba
```

Confirme que `/etc/oratab` aponta para `/opt/oracle/product/19c/dbhome_1`. Se o perfil tiver um `ORACLE_HOME` antigo, corrija-o. Não é necessário permitir login SSH direto como `oracle`: use o acesso administrativo e `sudo`/`su` conforme a política.

## 5. Validar no SQL*Plus

```sql
SELECT instance_name, status FROM v$instance;
SELECT name, open_mode, log_mode FROM v$database;
SHOW PDBS
SELECT comp_id, version, status FROM dba_registry ORDER BY comp_id;
```

Abra a PDB de aplicação se necessário e planeje persistência de seu estado. Teste conexão pelo serviço da PDB e confira `lsnrctl status`. Configure [backup](<Informações e parâmetros de backup.md>) e aplique o RU planejado pelo README do patch.

Para inicialização automática, use **um único mecanismo**: o serviço fornecido pelo pacote, se configurado para esse fim, ou o [guia específico](<script startup automatico.md>). Não duplique o script `dbora` nem combine controladores para a mesma instância.

## Referências oficiais

- [Instalação 19c por RPM](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/running-rpm-packages-to-install-oracle-database.html)
- [Modelo RPM](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/about-rpm-based-oracle-database-installation.html)
