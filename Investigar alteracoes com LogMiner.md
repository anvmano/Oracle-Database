# Investigar alterações com LogMiner

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c non-CDB isolado; mineração manual de redo compatível, sem CONTINUOUS_MINE.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use non-CDB de laboratório separado. CDB/PDB tem requisitos de container e mineração próprios, descritos no manual; não aplique este fluxo à LABPDB automaticamente. Confirme versão, privilégios administrativos necessários, disponibilidade de redo e dicionário, charset e intervalo de SCN. O recurso permite consultar alterações; não é uma restauração automática.

Prepare uma tabela fictícia e algumas transações confirmadas pelo [guia de SQL](<Fundamentos de SQL para administracao Oracle.md>). Registre SCNs antes/depois e faça arquivamento planejado conforme a política. Supplemental logging altera a geração de redo: identifique o que o cenário exige e configure antes da carga, sem habilitar opções amplas por padrão.

## 1. Selecionar os logs

Como administrador autorizado, na instância de teste:

```sql
SELECT name, dbid, cdb, current_scn, supplemental_log_data_min FROM v$database;
SELECT thread#, sequence#, first_change#, next_change#, name
FROM v$archived_log
WHERE name IS NOT NULL AND deleted='NO'
ORDER BY first_change#, thread#, sequence#;
```

Escolha todos os logs da mesma origem/incarnation que cobrem o intervalo; registros duplicados de um mesmo log não exigem adicionar todas as cópias. Confirme existência, acesso e integridade dos arquivos. A existência de uma linha no control file não prova disponibilidade física.

## 2. Adicionar os arquivos e iniciar

Modelo no SQL*Plus: substitua arquivo e SCNs numéricos; os marcadores não são comandos prontos. Adicione demais arquivos com ADDFILE antes de iniciar:

```text
EXEC DBMS_LOGMNR.ADD_LOGFILE(logfilename=>'/u04/miner/ARCHIVE_REAL_01.arc',options=>DBMS_LOGMNR.NEW);
EXEC DBMS_LOGMNR.ADD_LOGFILE(logfilename=>'/u04/miner/ARCHIVE_REAL_02.arc',options=>DBMS_LOGMNR.ADDFILE);
BEGIN
  DBMS_LOGMNR.START_LOGMNR(
    startScn=>SCN_INICIAL_REAL,
    endScn=>SCN_FINAL_REAL,
    options=>DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG + DBMS_LOGMNR.COMMITTED_DATA_ONLY);
END;
/
```

Online catalog pressupõe dicionário compatível com o redo analisado e limita o cenário a essa origem. Não misture arquivos de bancos diferentes. A opção de mineração contínua não está disponível no 19c.

## 3. Consultar durante a sessão de mineração

Na mesma sessão SQL:

```sql
SELECT scn, timestamp, operation, seg_owner, table_name, xid,
       status, csf, sql_redo, sql_undo
FROM v$logmnr_contents
WHERE seg_owner='APP_LAB' AND table_name='T_SQL_DBA_LAB'
ORDER BY scn;
```

O schema/tabela devem existir no non-CDB escolhido. Confira STATUS e CSF: SQL pode estar incompleto ou fragmentado, e operações/tipos têm restrições. Não execute SQL_UNDO/SQL_REDO como script de correção; eles não substituem análise transacional, dependências e plano de recuperação.

## 4. Encerrar e aceitar

Somente depois das consultas e da preservação privada dos resultados:

```sql
EXEC DBMS_LOGMNR.END_LOGMNR;
```

Confirme que as transações fictícias esperadas foram observadas no intervalo. Ausência de linha pode resultar de logs, filtros, privilégios ou restrições; não prova ausência de alteração. Finalizar a mineração não desfaz transações e não elimina redo. Proteja a saída e devolva configurações temporárias apenas conforme o estado anterior registrado.

## Referências oficiais

- [LogMiner 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-logminer-utility.html)
- [DBMS_LOGMNR](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_LOGMNR.html)
