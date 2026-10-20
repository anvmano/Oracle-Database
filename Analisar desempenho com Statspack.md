# Analisar desempenho com Statspack

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c non-CDB de laboratório, snapshots PERFSTAT; sem alterar o cenário CDB principal.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use uma instância non-CDB separada e registre edição/RU. Confira `SPDOC.TXT` em `$ORACLE_HOME/rdbms/admin` da instalação real para restrições e opções; a documentação pública histórica não garante compatibilidade de todo procedimento antigo. Planeje espaço, custo de coleta, retenção e conta PERFSTAT. Não instale outra cópia se o repositório já existir.

## 1. Inventariar e instalar uma única vez

Como administrador no banco confirmado:

```sql
SELECT name, dbid, cdb FROM v$database;
SELECT username, account_status FROM dba_users WHERE username='PERFSTAT';
SELECT tablespace_name, contents, status FROM dba_tablespaces;
```

Prepare tablespace permanente dedicada e TEMP com capacidade definida, conforme o [guia de tablespaces](<Comandos sobre tablespace.md>). No SQL*Plus SYSDBA, apenas se PERFSTAT ainda não existir:

```sql
@?/rdbms/admin/spcreate.sql
```

Responda aos prompts com senha própria, tablespace permanente e temporária confirmadas. Proteja logs de instalação; não grave a senha no Git. Se falhar, examine os logs antes de repetir ou remover o usuário.

## 2. Capturar um intervalo conhecido

Abra nova conexão PERFSTAT com senha solicitada no prompt, no serviço do banco non-CDB. Comece com a coleta padrão documentada:

```sql
EXEC statspack.snap;
SELECT snap_id, snap_time, startup_time, instance_number
FROM stats$snapshot ORDER BY snap_id;
```

Anote o snapshot inicial, execute uma carga pequena e autorizada de laboratório, e capture outro snapshot. Compare somente snapshots do mesmo DBID/instância e período de startup. Um único snapshot não constitui uma análise por intervalo.

## 3. Gerar e interpretar o relatório

Como PERFSTAT, com diretório de saída privado e gravável no cliente SQL*Plus:

```sql
@?/rdbms/admin/spreport.sql
```

Escolha os IDs inicial/final e nome novo do relatório. Relacione tempo decorrido, DB time/carga, waits, I/O e SQLs mais caros ao comportamento da aplicação. Hit ratio alto não comprova desempenho; contadores cumulativos precisam do intervalo correto. Statspack não é ASH e não substitui diagnóstico de sessão ou [trace](<Rastrear SQL com DBMS_MONITOR e TKPROF.md>).

## 4. Agendamento e retenção

Só agende depois de medir custo e validar captura manual. Confira se já há job de coleta e use um único mecanismo. Planeje frequência, limites de espaço e purge conforme SPDOC.TXT; não execute shrink automático de tabelas PERFSTAT como parte da instalação. Preserve snapshots necessários a incidentes antes de qualquer remoção.

## 5. Validar e encerrar

Confirme duas capturas válidas, relatório legível e ausência de erro no alert log. Para retirar a coleta, desabilite apenas o job identificado, preservando o repositório. Desinstalação é uma mudança distinta com dependências e backup conferidos; não use DROP USER CASCADE para limpar uma tentativa sem inventário.

## Referências oficiais

- [Statspack, referência histórica e SPDOC.TXT](https://docs.oracle.com/cd/B10501_01/server.920/a96533/statspac.htm)
- [Diagnóstico de desempenho](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/)
