# Monitorar TEMP e UNDO

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; consultas no container relevante e análise antes de expansão.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

TEMP atende operações temporárias; UNDO preserva informações para rollback e consistência de leitura. Conecte à PDB de aplicação para a investigação local e confira local undo/arquitetura. Em root/RAC, use as views/CON_ID/INST_ID apropriados sem somar o mesmo espaço várias vezes.

## 1. Conferir configuração e capacidade

```sql
SHOW CON_NAME
SHOW PARAMETER undo_management
SHOW PARAMETER undo_tablespace
SHOW PARAMETER undo_retention
SELECT tablespace_name, file_name, bytes, maxbytes, autoextensible FROM dba_temp_files;
SELECT tablespace_name, file_name, bytes, maxbytes, autoextensible
FROM dba_data_files WHERE tablespace_name IN
  (SELECT tablespace_name FROM dba_tablespaces WHERE contents='UNDO');
```

Compare com espaço real do filesystem/ASM. Autoextend habilitado não garante espaço disponível nem limite suficiente.

## 2. Medir TEMP e identificar consumidores

```sql
SELECT tablespace_name, SUM(bytes_used)/1024/1024 usado_mb,
       SUM(bytes_free)/1024/1024 livre_mb
FROM v$temp_space_header GROUP BY tablespace_name;
SELECT u.username, u.session_num, u.sql_id, u.tablespace, u.segtype,
       SUM(u.blocks) blocos
FROM v$tempseg_usage u
GROUP BY u.username, u.session_num, u.sql_id, u.tablespace, u.segtype
ORDER BY blocos DESC;
```

O tamanho em blocos não é MiB: use o block size da tablespace para converter. TEMP pode reter extents alocados para reutilização; diferencie arquivo grande, espaço alocado e consumo ativo. Associe o consumidor à sessão/SQL antes de cancelar ou expandir.

## 3. Medir UNDO e pressão de retenção

```sql
SELECT status, SUM(bytes)/1024/1024 mb FROM dba_undo_extents GROUP BY status;
SELECT begin_time, end_time, undoblks, txncount, maxquerylen,
       tuned_undoretention, ssolderrcnt, nospaceerrcnt
FROM v$undostat WHERE begin_time >= SYSDATE-1 ORDER BY begin_time;
SELECT s.sid, s.serial#, s.username, t.start_time, t.used_ublk, t.used_urec
FROM v$transaction t JOIN v$session s ON s.taddr=t.addr;
```

Relacione ORA-01555 com duração/consistência da consulta e disponibilidade de undo; aumentar `UNDO_RETENTION` não cria espaço nem garante retenção por si só. ORA-30036 indica necessidade de investigar capacidade/consumo. `RETENTION GUARANTEE` pode proteger consultas às custas de falha de DML quando faltar espaço.

## 4. Escolher uma ação

1. Identifique crescimento recorrente, SQL pesado ou transação excepcional e avalie impacto funcional.
2. Corrija consulta/processo quando houver causa identificada; planeje expansão se a carga legítima exigir.
3. Para adicionar/redimensionar tempfile/datafile, use [tablespaces](<Comandos sobre tablespace.md>), considerando limites e backup.
4. Não apague tempfile/datafile pelo SO, não elimine UNDO ativa e não encerre sessões sem investigar.

## 5. Validar e retornar

Repita métricas durante um intervalo representativo, confirme fim dos erros e capacidade livre. Registre mudança de tamanho/limite e crescimento observado. Redução posterior de arquivo é uma operação separada, limitada pelos blocos alocados; não presuma que expansão e transações possam ser desfeitas com ROLLBACK.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [transacoes_undo.sql](scripts/diagnostico/transacoes_undo.sql) — Medir UNDO por transacao com tamanho de bloco real.
- [temp_uso.sql](scripts/diagnostico/temp_uso.sql) — Relacionar segmentos temporarios a sessoes.

## Roteiros de solução de problemas

- [09 · Falta de espaço para operações temporárias](solucao-de-problemas/09-espaco-temporario.md).
- [10 · Pressão de UNDO ou perda de versão para leitura](solucao-de-problemas/10-pressao-de-undo-e-ora-01555.md).

## Referências oficiais

- [V$UNDOSTAT](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-UNDOSTAT.html)
- [V$TEMPSEG_USAGE](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-TEMPSEG_USAGE.html)
- [Gerenciar undo](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/managing-undo.html)
