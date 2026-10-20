# Criar, alterar e consultar tablespaces

[← Índice](README.md)

**Escopo:** SQL 12.1–19c; exemplos independentes de DDL, sujeitos ao container e à versão.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Exemplos **independentes**, para executar no banco/container correto como administrador autorizado. Os diretórios devem existir, pertencer ao proprietário Oracle e ter capacidade. Substitua caminhos/nomes pelo planejamento real. DDL pode confirmar transações implicitamente; não é desfeito por um `ROLLBACK` comum.

Em CDB, confira `SHOW CON_NAME`; para objetos locais, conecte à PDB de destino. Use OMF quando configurado ou nomes explícitos exclusivos, nunca misturando caminhos de outros bancos.

## 1. Criar tablespaces permanentes

Smallfile com crescimento limitado:

```sql
CREATE SMALLFILE TABLESPACE TBS_APP
  DATAFILE '/u01/oradata/ORCL/tbs_app01.dbf' SIZE 100M
  AUTOEXTEND ON NEXT 100M MAXSIZE 1G
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE
  SEGMENT SPACE MANAGEMENT AUTO;
```

Com dois datafiles, configure tamanho/crescimento por arquivo:

```sql
CREATE SMALLFILE TABLESPACE TBS_APP2
  DATAFILE '/u01/oradata/ORCL/tbs_app201.dbf' SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 1G,
           '/u01/oradata/ORCL/tbs_app202.dbf' SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 1G
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE
  SEGMENT SPACE MANAGEMENT AUTO;
```

Bigfile possui um único datafile:

```sql
CREATE BIGFILE TABLESPACE TBS_BIG
  DATAFILE '/u01/oradata/ORCL/tbs_big01.dbf' SIZE 1G
  AUTOEXTEND ON NEXT 100M MAXSIZE 5G
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE
  SEGMENT SPACE MANAGEMENT AUTO;
```

Sem `BLOCKSIZE`, usa-se o padrão do banco. Um block size não padrão exige cache compatível e suporte. Não copie `REUSE`: ele pode reutilizar um arquivo existente.

## 2. Alterar datafiles

```sql
ALTER TABLESPACE TBS_APP ADD DATAFILE '/u01/oradata/ORCL/tbs_app02.dbf'
  SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 1G;
SELECT file_id, file_name, tablespace_name, bytes/1024/1024 tamanho_mb, autoextensible
FROM dba_data_files WHERE tablespace_name='TBS_APP';
```

Para redimensionar um arquivo confirmado, por exemplo:

```sql
ALTER DATABASE DATAFILE '/u01/oradata/ORCL/tbs_app01.dbf' RESIZE 200M;
```

Redução é limitada por blocos alocados e pode falhar; não force remoção de dados para atingir um tamanho arbitrário. `DROP DATAFILE` só se aplica a arquivos elegíveis, vazios e dentro das restrições da versão; confira antes de executar. Um bigfile não aceita adicionar um segundo datafile.

## 3. Temporary, grupo temporário e UNDO

```sql
CREATE TEMPORARY TABLESPACE TEMP_APP
  TEMPFILE '/u01/oradata/ORCL/temp_app01.dbf' SIZE 100M
  AUTOEXTEND ON NEXT 100M MAXSIZE 2G;
ALTER TABLESPACE TEMP_APP TABLESPACE GROUP TEMP_GROUP;
```

Para tornar o grupo padrão, avalie o impacto e use `ALTER DATABASE DEFAULT TEMPORARY TABLESPACE TEMP_GROUP;`. Para retirar uma tablespace do grupo, a sintaxe é `ALTER TABLESPACE TEMP_APP TABLESPACE GROUP '';`. Não apague a área temporária em uso como rotina de manutenção.

```sql
CREATE UNDO TABLESPACE UNDO_APP
  DATAFILE '/u01/oradata/ORCL/undo_app01.dbf' SIZE 100M
  AUTOEXTEND ON NEXT 100M MAXSIZE 2G
  RETENTION NOGUARANTEE;
```

`RETENTION GUARANTEE` protege undo não expirado, mas pode fazer DML falhar quando faltar espaço; ative somente com dimensionamento adequado. Criar uma UNDO não a torna automaticamente a UNDO ativa. Confirme `UNDO_TABLESPACE`, local undo/CDB e o procedimento de troca da versão. Não especifique `BLOCKSIZE` em temporary/undo como no exemplo antigo.

## 4. Tablespace criptografada

Pré-condições: TDE suportado/autorizado, keystore corretamente configurado, aberto no container apropriado, master key existente e backup protegido do keystore/senhas. Não use senhas de exemplo fixas nem trate abertura de wallet como solução genérica para qualquer falha.

```sql
SELECT status, wallet_type FROM v$encryption_wallet;
CREATE TABLESPACE TBS_SEC
  DATAFILE '/u01/oradata/ORCL/tbs_sec01.dbf' SIZE 100M
  AUTOEXTEND ON NEXT 100M MAXSIZE 1G
  ENCRYPTION USING 'AES256'
  DEFAULT STORAGE (ENCRYPT);
```

Confirme suporte ao algoritmo/configuração no banco e consulte `V$ENCRYPTED_TABLESPACES`. Sem wallet/chaves recuperáveis, o backup dos dados criptografados pode não ser utilizável. A configuração inicial do keystore tem procedimento próprio de TDE e não deve ser improvisada por este exemplo.

## 5. Mudanças de estado — escolher apenas a necessária

| Objetivo | Exemplo SQL | Condição |
|---|---|---|
| Offline planejado | `ALTER TABLESPACE TBS_APP OFFLINE NORMAL;` | Avaliar indisponibilidade e restrições; não usar para SYSTEM/UNDO ativa |
| Online | `ALTER TABLESPACE TBS_APP ONLINE;` | Arquivos íntegros ou recuperados |
| Somente leitura | `ALTER TABLESPACE TBS_APP READ ONLY;` | Planejar consumidores/transações |
| Leitura/escrita | `ALTER TABLESPACE TBS_APP READ WRITE;` | Validar necessidade |
| Renomear | `ALTER TABLESPACE TBS_APP RENAME TO TBS_APP_NEW;` | Atualizar referências e checar restrições |
| Desabilitar flashback da área | `ALTER TABLESPACE TBS_APP FLASHBACK OFF;` | Avaliar consequências para recuperação; seguir procedimento de flashback |

## 6. Exclusão — fora da rotina de criação

Faça backup e inventário de segmentos, usuários, quotas e dependências. `DROP TABLESPACE NOME_CONFIRMADO;` não é um comando para liberar espaço automaticamente; por padrão, áreas não vazias têm restrições. `INCLUDING CONTENTS AND DATAFILES` é destrutivo e remove conteúdo/arquivos conforme as regras Oracle; `CASCADE CONSTRAINTS` pode afetar relações externas. Use somente após confirmação do escopo e capacidade de recuperação. Não execute exemplos de drop depois dos exemplos de criação como uma sequência única.

## 7. Consultas de validação

```sql
SELECT tablespace_name, status, contents, bigfile FROM dba_tablespaces;
SELECT tablespace_name, file_name, bytes, maxbytes FROM dba_data_files;
SELECT tablespace_name, file_name, bytes FROM dba_temp_files;
SELECT * FROM dba_tablespace_groups;
SELECT * FROM dba_tablespace_usage_metrics;
SELECT * FROM v$datafile_header;
SHOW PARAMETER db_create_file_dest
```

`DBA_*` mostra informações administrativas e exige privilégio; não representa apenas objetos acessíveis ao usuário comum. Em CDB root, use as views `CDB_*` e `CON_ID` quando precisar de visão entre containers, respeitando permissões.

## Roteiros de solução de problemas

- [08 · Falta de espaço permanente ou quota](solucao-de-problemas/08-espaco-permanente-e-quota.md).
- [09 · Falta de espaço para operações temporárias](solucao-de-problemas/09-espaco-temporario.md).

## Referências oficiais

- [CREATE TABLESPACE](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-TABLESPACE.html)
- [ALTER TABLESPACE](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/ALTER-TABLESPACE.html)
- [TDE](https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/introduction-to-transparent-data-encryption.html)
