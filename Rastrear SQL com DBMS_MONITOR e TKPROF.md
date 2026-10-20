# Rastrear SQL com DBMS_MONITOR e TKPROF

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; trace curto da própria sessão de laboratório, com waits e sem captura de binds.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use APP_LAB no serviço LABPDB, sessão dedicada e espaço de diagnóstico disponível. Solicite acesso autorizado ao pacote e ao arquivo de trace; não dê DBA ao schema apenas para este exercício. Trace pode registrar SQL e dados sensíveis mesmo com binds desabilitados. Defina duração, carga e responsável por interromper a captura.

## 1. Identificar a sessão e o arquivo

Na mesma sessão que executará a carga:

```sql
SELECT SYS_CONTEXT('USERENV','DB_NAME') banco,
       SYS_CONTEXT('USERENV','CON_NAME') container,
       SYS_CONTEXT('USERENV','SID') sid FROM dual;
ALTER SESSION SET tracefile_identifier='LAB_TRACE_01';
SELECT value FROM v$diag_info WHERE name='Default Trace File';
```

Se a consulta à view não for permitida, peça ao administrador para localizar o trace desse processo. Não suponha que um arquivo encontrado pelo nome seja da sessão certa.

## 2. Capturar uma carga pequena

Omitir SID/serial nos procedimentos abaixo seleciona a própria sessão. Não use números de sessão de outro exemplo:

```sql
EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE(waits=>TRUE,binds=>FALSE);
SELECT object_type, COUNT(*) quantidade
FROM user_objects GROUP BY object_type ORDER BY object_type;
EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE;
```

Se o SQL falhar, desabilite o trace na mesma sessão antes de investigar. Não habilite trace global. Para capturar outra sessão, o administrador precisa confirmar instância, SID, SERIAL# e ciclo de vida, e manter uma sessão de controle para desabilitar a coleta.

## 3. Formatar no host que possui o trace

Copie somente o arquivo confirmado para diretório privado ou processe com acesso autorizado. No shell, substitua os nomes do exemplo pelos arquivos reais e use saída ainda inexistente:

```bash
tkprof /home/oracle/coletas/lab_trace_01.trc /home/oracle/coletas/lab_trace_01.prf sort=exeela,fchela
```

Não acrescente EXPLAIN com credenciais em argumentos. Um plano obtido por EXPLAIN posteriormente não prova o plano da execução capturada. Se a sessão produziu múltiplos traces, planeje sua consolidação com os utilitários documentados antes de concluir a análise.

## 4. Interpretar e validar

Compare parse/execute/fetch, linhas, CPU, elapsed e leituras. O total das chamadas não é automaticamente o tempo de resposta fim a fim da aplicação. Verifique se a janela capturada contém a operação e correlacione o cursor com [DBMS_XPLAN](<Diagnosticar SQL lento com DBMS_XPLAN.md>).

Confirme que a coleta terminou. Em sessão administrativa autorizada, V$SESSION.SQL_TRACE ajuda a conferir o estado da sessão alvo. Revise o relatório antes de compartilhar. Limpeza de traces segue retenção e preservação de evidências; não apague o diretório ADR inteiro.

## Roteiros de solução de problemas

- [05 · SQL lento e alto consumo de CPU ou I/O](solucao-de-problemas/05-sql-lento-cpu-e-io.md).

## Referências oficiais

- [DBMS_MONITOR](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_MONITOR.html)
- [Tracing e TKPROF](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/performing-application-tracing.html)
