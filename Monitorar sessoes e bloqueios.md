# Monitorar sessões e bloqueios

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c single instance; diagnóstico e intervenção individual planejada.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use conta autorizada a consultar o catálogo e confirme serviço/container. SID sozinho não identifica permanentemente uma sessão: ele pode ser reutilizado. Em RAC, consulte `GV$` e inclua instância; a sintaxe de intervenção também muda. Não encerre sessões por tempo de conexão ou estado INACTIVE isoladamente.

## 1. Identificar sessões de aplicação

```sql
SELECT sid, serial#, con_id, username, status, service_name, module, machine,
       sql_id, event, wait_class, state, seconds_in_wait
FROM v$session WHERE type='USER' ORDER BY username, sid;
```

`INACTIVE` não significa ausência de transação aberta. `SECONDS_IN_WAIT` depende do estado da espera e não é a duração universal do SQL.

## 2. Encontrar bloqueadores e transações

```sql
SELECT w.sid esperando_sid, w.serial# esperando_serial,
       w.sql_id esperando_sql, w.event, w.blocking_session,
       b.serial# bloqueador_serial, b.username bloqueador_usuario, b.module
FROM v$session w LEFT JOIN v$session b ON b.sid=w.blocking_session
WHERE w.blocking_session_status='VALID';
SELECT s.sid, s.serial#, s.username, t.start_time, t.used_ublk, t.used_urec
FROM v$session s JOIN v$transaction t ON t.addr=s.taddr;
```

Investigue a cadeia, não só a primeira sessão encontrada. Confira o dono da transação e coordene COMMIT/ROLLBACK pela aplicação; um administrador não confirma a transação de outra sessão com seu próprio COMMIT.

## 3. Examinar o SQL e o contexto

```sql
SELECT sql_id, child_number, executions, elapsed_time, sql_text
FROM v$sql WHERE sql_id='SUBSTITUIR_SQL_ID';
```

Os contadores são cumulativos do cursor, não duração de uma única chamada. O bloqueador pode estar entre comandos ou ter outro `PREV_SQL_ID`; texto SQL não identifica sozinho a transação que mantém o lock. Guarde sessão/serial, usuário, módulo, erro, horário e confirmação do responsável.

## 4. Intervir somente após avaliar o impacto

Antes de desconectar, consulte novamente SID/serial/usuário/transação. Escolha a ação apropriada da versão, com autorização operacional. Exemplo **não executável até substituir os números** pelo par atual confirmado:

```text
ALTER SYSTEM KILL SESSION 'SID_CONFIRMADO,SERIAL_CONFIRMADO' IMMEDIATE;
```

Isso pode gerar rollback demorado e erro na aplicação. Não é garantia de liberação instantânea de locks nem de eliminação imediata do processo. Em certos casos basta cancelar um SQL específico, com a sintaxe suportada, em vez de encerrar a sessão. Não use `kill -9` no processo do SO como atalho.

## 5. Validar e registrar

Confirme fim da espera, término do rollback e retomada funcional da aplicação. Se reaparecer, trate causa: transação longa, ordem inconsistente de acesso, conexão abandonada ou SQL inadequado. Uma sessão encerrada não pode ser reativada; a aplicação deve reconectar e tratar a transação segundo suas regras. O caso deve registrar a decisão e seu resultado.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [sessoes_ativas.sql](scripts/diagnostico/sessoes_ativas.sql) — Listar sessoes ativas e o cursor filho corrente.
- [sessao_por_processo.sql](scripts/diagnostico/sessao_por_processo.sql) — Relacionar processo do servidor a sessao.
- [bloqueadores.sql](scripts/diagnostico/bloqueadores.sql) — Relacionar espera e bloqueador entre instancias.
- [objetos_bloqueados.sql](scripts/diagnostico/objetos_bloqueados.sql) — Relacionar locks de objetos a sessoes.
- [sessao_io.sql](scripts/diagnostico/sessao_io.sql) — Consultar contadores de I/O por sessao.
- [encerrar_sessao.sql](scripts/manutencao/encerrar_sessao.sql) — Solicitar encerramento de uma sessao local identificada.
- [limites_recursos.sql](scripts/diagnostico/limites_recursos.sql) — Consultar consumo atual e maximo de recursos da instancia.
- [operacoes_longas.sql](scripts/diagnostico/operacoes_longas.sql) — Consultar progresso instrumentado de operacoes longas.
- [cursores_sessao.sql](scripts/diagnostico/cursores_sessao.sql) — Contar entradas de cursores por sessao e tipo.
- [esperas_sistema.sql](scripts/diagnostico/esperas_sistema.sql) — Consultar contadores acumulados de eventos de espera.

## Roteiros de solução de problemas

- [04 · Limite de processos ou sessões atingido](solucao-de-problemas/04-limite-de-processos-e-sessoes.md).
- [06 · Bloqueios, transações presas e deadlocks](solucao-de-problemas/06-bloqueios-transacoes-e-deadlocks.md).
- [13 · Excesso de cursores abertos por sessão](solucao-de-problemas/13-excesso-de-cursores.md).

## Referências oficiais

- [V$SESSION](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SESSION.html)
- [V$TRANSACTION](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-TRANSACTION.html)
- [ALTER SYSTEM](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/ALTER-SYSTEM.html)
