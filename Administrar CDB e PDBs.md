# Administrar CDB e PDBs

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c, CDB single instance com OMF; operações locais de laboratório.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use uma CDB de laboratório, backup recuperável e capacidade para nova PDB. Confira edição, limites de PDBs e licenciamento. O exemplo cria **LABPDB** a partir de PDB$SEED, com OMF já configurado no destino dedicado. Não altere o parâmetro de arquivos de toda a CDB apenas para fazer o exemplo passar.

## 1. Confirmar contexto — SQL*Plus SYSDBA

```sql
SELECT name, cdb, open_mode FROM v$database;
SHOW CON_NAME
SHOW PDBS
SHOW PARAMETER db_create_file_dest
SELECT name, open_mode, restricted FROM v$pdbs ORDER BY con_id;
```

Para criar a PDB, esteja em CDB$ROOT, com CDB aberta e diretório OMF válido, gravável e com espaço. Confirme que LABPDB **ainda não existe**. Sem OMF, planeje `FILE_NAME_CONVERT`/destinos pelo guia oficial; não reutilize paths da seed.

## 2. Criar a PDB

Não faça spool de credenciais. No SQL*Plus interativo:

```sql
SET VERIFY OFF
SET ECHO OFF
ACCEPT senha CHAR PROMPT 'Senha do administrador local da nova PDB: ' HIDE
CREATE PLUGGABLE DATABASE LABPDB ADMIN USER PDBADMIN IDENTIFIED BY "&senha";
UNDEFINE senha
ALTER PLUGGABLE DATABASE LABPDB OPEN;
ALTER PLUGGABLE DATABASE LABPDB SAVE STATE;
SHOW PDBS
```

Use uma senha que respeite a política e não contenha aspas duplas que quebrem essa substituição SQL*Plus. A criação exige os privilégios e arquivos de destino corretos; se falhar, diagnostique os logs e o estado antes de repetir.

## 3. Conectar e confirmar serviço

```sql
ALTER SESSION SET CONTAINER=LABPDB;
SHOW CON_NAME
SELECT SYS_CONTEXT('USERENV','SERVICE_NAME') servico,
       SYS_CONTEXT('USERENV','CON_NAME') container FROM dual;
```

Confirme os serviços em `DBA_SERVICES` e `lsnrctl services`. A aplicação deve usar o serviço apropriado da PDB, não o SID da CDB. Para aplicações permanentes, configure serviço próprio conforme [Oracle Net](<Configurar listener e conexões Oracle Net.md>).

## 4. Fechar e reabrir, em janela planejada

Conectado ao root, após interromper consumidores da LABPDB:

```sql
ALTER PLUGGABLE DATABASE LABPDB CLOSE IMMEDIATE;
ALTER PLUGGABLE DATABASE LABPDB OPEN;
SHOW PDBS
```

Essas operações derrubam conexões da PDB. Confirme estado salvo e abertura após um reboot de teste autorizado. Usuário local só existe no container correspondente; não use parâmetros ocultos para contornar regras de usuários comuns.

## 5. Clonagem, unplug e remoção

Clonagem exige capacidade, nomes/destinos distintos e pré-requisitos próprios; unplug exige o manifesto e preservação dos arquivos no fluxo definido. Para descartar uma PDB de teste, confirme backup, nome, container e política de dados antes de usar o procedimento de `DROP PLUGGABLE DATABASE` da versão. `INCLUDING DATAFILES` é destrutivo; não é a reversão automática de qualquer criação com falha.

**Aceitação:** PDB aberta no modo previsto, serviço acessível, usuário local autenticando e inventário de arquivos sem sobreposição. **Retorno:** reabra a PDB fechada ou restaure a partir do plano próprio; remover a PDB elimina seu conteúdo e não equivale a desfazer DDL com ROLLBACK.

## Roteiros de solução de problemas

- [01 · Falha de conexão, listener ou serviço](solucao-de-problemas/01-conexao-listener-servico.md).

## Referências oficiais

- [Administração Multitenant](https://docs.oracle.com/en/database/oracle/oracle-database/19/multi/)
- [CREATE PLUGGABLE DATABASE](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-PLUGGABLE-DATABASE.html)
