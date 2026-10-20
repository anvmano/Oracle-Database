# Instalar Oracle Database 19c em modo silencioso

[← Índice](README.md)

**Escopo:** 19c, Linux x86-64, instalação por imagem e assistentes silenciosos.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Siga os pré-requisitos, diretórios, usuário e ambiente do [guia 19c](<Instalação Oracle 19c.md>). Os exemplos usam `/u01/app/oracle/product/19.3/dbhome_1`, inventário `/u01/app/oraInventory`, SID `ORCL` e uma PDB `PDB1`. Ajuste todos em conjunto. Execute os assistentes como `oracle`, não como root.

## 1. Preparar respostas

Após extrair a mídia no Oracle home vazio, copie os **modelos fornecidos pela própria mídia** para uma pasta privada. Preserve os campos e identificadores de versão não mencionados abaixo.

```bash
umask 077
mkdir -p /home/oracle/response
cp "$ORACLE_HOME/install/response/db_install.rsp" /home/oracle/response/db_install.rsp
cp "$ORACLE_HOME/assistants/netca/netca.rsp" /home/oracle/response/netca.rsp
cp "$ORACLE_HOME/assistants/dbca/dbca.rsp" /home/oracle/response/dbca.rsp
chmod 600 /home/oracle/response/*.rsp
```

Edite `db_install.rsp`; valores de grupos devem corresponder aos existentes e às funções escolhidas:

```ini
oracle.install.option=INSTALL_DB_SWONLY
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
ORACLE_HOME=/u01/app/oracle/product/19.3/dbhome_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.OSDBA_GROUP=dba
oracle.install.db.OSOPER_GROUP=oper
oracle.install.db.OSBACKUPDBA_GROUP=backupdba
oracle.install.db.OSDGDBA_GROUP=dgdba
oracle.install.db.OSKMDBA_GROUP=kmdba
oracle.install.db.OSRACDBA_GROUP=racdba
oracle.install.db.rootconfig.executeRootScript=false
```

Não selecione grupos inexistentes: crie/atribua os grupos conforme o guia ou use um mapeamento de funções autorizado. A edição EE é um exemplo, não uma concessão de licença.

## 2. Conferir e instalar binários

```bash
cd "$ORACLE_HOME"
./runInstaller -executePrereqs -silent -responseFile /home/oracle/response/db_install.rsp
```

Corrija todas as falhas, depois execute:

```bash
./runInstaller -silent -waitforcompletion -responseFile /home/oracle/response/db_install.rsp
```

Confirme conclusão nos logs, não apenas o lançamento do processo. Como root, execute os scripts indicados pelo instalador, normalmente `/u01/app/oraInventory/orainstRoot.sh` e `/u01/app/oracle/product/19.3/dbhome_1/root.sh`.

## 3. Configurar listener

No modelo `netca.rsp`, mantenha a sintaxe original de strings/listas e configure o listener necessário. Não use `db_netca.rsp`, aspas duplicadas nem a porta digitada como `1512`. Para um novo listener TCP/1521, confira os campos correspondentes no modelo e execute:

```bash
"$ORACLE_HOME/bin/netca" -silent -responsefile /home/oracle/response/netca.rsp
"$ORACLE_HOME/bin/lsnrctl" status
```

Use o listener existente quando gerenciado pelo Grid. Antes do DBCA, ausência de serviços registrados pode ser normal.

## 4. Criar o banco

Edite **o modelo** `dbca.rsp`; não copie parênteses explicativos como valores. Para um exemplo CDB com uma PDB:

```ini
gdbName=ORCL
sid=ORCL
databaseConfigType=SI
createAsContainerDatabase=true
numberOfPDBs=1
pdbName=PDB1
useLocalUndoForPDBs=true
templateName=General_Purpose.dbc
emConfiguration=NONE
datafileDestination=/u01/app/oracle/oradata
recoveryAreaDestination=/u01/app/oracle/fast_recovery_area
storageType=FS
characterSet=AL32UTF8
sampleSchema=false
automaticMemoryManagement=false
```

Defina também `sysPassword`, `systemPassword` e `pdbAdminPassword` com senhas próprias no arquivo protegido. Preencha os parâmetros de memória, tamanho da FRA e listener **com valores dimensionados** conforme o help/modelo da mídia. Não defina simultaneamente opções de memória contraditórias. Confira o template existente em `$ORACLE_HOME/assistants/dbca/templates`.

```bash
"$ORACLE_HOME/bin/dbca" -silent -createDatabase -responseFile /home/oracle/response/dbca.rsp
```

Interrompa o fluxo se houver erro; examine `$ORACLE_BASE/cfgtoollogs/dbca`. Não repita uma criação parcialmente concluída sem diagnosticar o estado e o destino dos arquivos.

## 5. Validar

No SQL*Plus, confira `V$INSTANCE`, `V$DATABASE`, `DBA_REGISTRY` e `SHOW PDBS`, como no guia 19c. Teste conexão ao serviço da PDB, confira ARCHIVELOG e estabeleça backup. Apague ou guarde de forma protegida os response files com credenciais quando não forem mais necessários; não os versione.

## Referências oficiais

- [Instalação Linux 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/)
- [NETCA com response file](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/running-net-configuration-assistant-using-response-files.html)
