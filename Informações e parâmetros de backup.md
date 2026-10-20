# Planejar, executar e validar backups RMAN

[← Índice](README.md)

**Escopo:** Backup RMAN de banco inteiro; recuperação efetiva deve ser testada fora da origem.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Defina RPO (quanto dado pode ser perdido), RTO (tempo para recuperar), retenção, capacidade e cópias independentes. Exemplo para banco inteiro single instance em ARCHIVELOG, conexão local como proprietário do banco. Em RAC/Data Guard, TDE e catálogo separado, incorpore as exigências específicas.

## 1. Conferir banco e destinos

No SQL*Plus como SYSDBA:

```sql
SELECT name, dbid, log_mode, open_mode FROM v$database;
ARCHIVE LOG LIST
SHOW PARAMETER db_recovery_file_dest
SHOW PARAMETER db_recovery_file_dest_size
SELECT dest_id, status, destination, error FROM v$archive_dest WHERE destination IS NOT NULL;
SELECT name, space_limit, space_used, space_reclaimable FROM v$recovery_file_dest;
```

A FRA não tem um limiar universal de 10% que pare o banco. Falta de espaço utilizável para archives e impossibilidade de liberar arquivos pode impedir o arquivamento e bloquear atividade; monitore espaço, limites e erros reais. Não apague archives com `rm`.

## 2. Habilitar ARCHIVELOG, se necessário

Essa mudança exige parada planejada; faça-a apenas depois de preparar destino/capacidade. No SQL*Plus:

```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ARCHIVE LOG LIST
```

Depois da mudança, faça um novo backup adequado ao plano. Em NOARCHIVELOG, um backup consistente exige o banco fechado de forma limpa e montado; não execute hot backup como se estivesse em ARCHIVELOG.

Para alterar um destino de archive, preserve previamente a configuração, confirme diretório/permissões e o impacto em Data Guard. `SCOPE=SPFILE` só tem efeito após reinício; use o escopo suportado e planejado, valide `V$ARCHIVE_DEST.ERROR` e force um archive para testar. Não substitua `LOG_ARCHIVE_DEST_1` de outro ambiente sem avaliar seu uso.

## 3. Preparar diretório/configuração

Como root, para destinos **novos e dedicados** do exemplo:

```bash
install -d -o oracle -g oinstall -m 750 /u02/backup
install -d -o oracle -g oinstall -m 750 /u02/backup/controlfile
```

Confira que `/u02` é realmente o volume montado esperado e tem capacidade; não permita que uma falha de montagem leve backups para o filesystem raiz. Configure [RMAN](<Parametros RMAN.md>), registre DBID, nomes, configuração e localização dos backups fora do host.

## 4. Executar backup — RMAN

Em `rman target /`:

```rman
SHOW ALL;
BACKUP AS COMPRESSED BACKUPSET DATABASE
  FORMAT '/u02/backup/DB_%d_%T_%U.bkp'
  PLUS ARCHIVELOG FORMAT '/u02/backup/ARC_%d_%T_%U.bkp';
BACKUP CURRENT CONTROLFILE FORMAT '/u02/backup/CTL_%d_%T_%U.bkp';
LIST BACKUP SUMMARY;
```

O autobackup preserva também o SPFILE quando a instância o utiliza. Guarde adicionalmente password file, rede, scripts, configurações do SO e wallets/chaves TDE; eles não devem ser presumidos como conteúdo do backup de datafiles. TDE exige keystore correto e disponível; não inclua senha fixa em script para contornar `wallet is not open`.

O exemplo **não apaga archives nem backups automaticamente**. Se automatizar, registre log/código de saída e alerte falha. Exclusão depende da política aprovada e da proteção de standby/cópias.

## 5. Validar recuperabilidade

```rman
LIST BACKUP;
LIST BACKUP OF CONTROLFILE;
LIST BACKUP OF SPFILE;
LIST BACKUP OF ARCHIVELOG ALL;
RESTORE DATABASE PREVIEW;
RESTORE DATABASE VALIDATE;
BACKUP VALIDATE DATABASE;
```

`RESTORE ... VALIDATE` lê as peças selecionadas sem restaurar datafiles. `BACKUP VALIDATE DATABASE` verifica arquivos do banco, não cria um backup. Para uma peça específica, use `VALIDATE BACKUPSET` com chave numérica obtida em `LIST BACKUP`. Valide também a cadeia de archives e realize uma restauração real **em destino isolado**; uma validação sem erro não prova todo o plano de desastre.

No SQL*Plus, examine `V$DATABASE_BLOCK_CORRUPTION` e o histórico RMAN disponível, como `V$RMAN_BACKUP_JOB_DETAILS`. Consulte o [guia de recuperação](<Comandos para restore.md>) para cenários de perda.

## 6. Incrementais e limpeza, operações separadas

Exemplos alternativos de estratégia, em RMAN:

```rman
BACKUP INCREMENTAL LEVEL 0 DATABASE;
BACKUP INCREMENTAL LEVEL 1 DATABASE;
BACKUP INCREMENTAL LEVEL 1 CUMULATIVE DATABASE;
```

Level 1 diferencial considera o level 0/1 anterior aplicável; cumulativo considera o level 0. Um `BACKUP FULL` não é automaticamente a base level 0 de uma cadeia incremental. Block Change Tracking é uma configuração separada e deve seguir suporte, espaço e licenciamento da versão.

Antes de limpar, execute `CROSSCHECK BACKUP`, `LIST EXPIRED BACKUP` e `REPORT OBSOLETE`; investigue qualquer armazenamento indisponível. Só então use `DELETE EXPIRED BACKUP` (registros de itens ausentes) ou `DELETE OBSOLETE` (itens obsoletos), com confirmação e política revisada. `DELETE BACKUP` sem filtro não é uma limpeza genérica segura. Não execute `NOPROMPT` em material de consulta sem transformar isso em uma rotina controlada e testada.

## Referências oficiais

- [Backup e recuperação](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/)
- [BACKUP](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/BACKUP.html)
- [RESTORE](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/RESTORE.html)
- [VALIDATE](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/VALIDATE.html)
