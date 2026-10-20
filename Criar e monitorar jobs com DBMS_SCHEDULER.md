# Criar e monitorar jobs com DBMS_SCHEDULER

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; job PL/SQL local no schema APP_LAB, sem execução de programas externos.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use LABPDB, privilégio `CREATE JOB`, quota e objetos próprios. Job roda com o contexto de seu proprietário; privilégios usados por PL/SQL com direitos do definidor precisam das concessões diretas aplicáveis. Confira `JOB_QUEUE_PROCESSES` e a política de agendamento; não mude parâmetros globais para contornar um teste.

## 1. Preparar o trabalho de teste — APP_LAB

Objetos novos e exclusivos do laboratório:

```sql
CREATE TABLE T_JOB_LAB (instante TIMESTAMP WITH TIME ZONE, mensagem VARCHAR2(100));
CREATE OR REPLACE PROCEDURE P_JOB_LAB AS
BEGIN
  INSERT INTO T_JOB_LAB VALUES (SYSTIMESTAMP,'execucao de teste');
  COMMIT;
END;
/
```

O COMMIT é intencional para um job independente. Não reutilize esse procedimento dentro de uma transação de aplicação esperando controlar seu commit externamente. O exemplo não é idempotente: cada execução acrescenta uma linha; em tarefa real, defina como tratar repetição e falhas parciais.

## 2. Criar inicialmente desabilitado

```sql
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name=>'JOB_LAB_ROTINA', job_type=>'STORED_PROCEDURE',
    job_action=>'APP_LAB.P_JOB_LAB',
    start_date=>SYSTIMESTAMP AT TIME ZONE 'America/Sao_Paulo',
    repeat_interval=>'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',
    enabled=>FALSE, auto_drop=>FALSE,
    comments=>'Exemplo local de laboratorio');
END;
/
```

Confirme nome inexistente, timezone e próximo horário. O fuso é explícito neste exemplo; não o confunda com o do host ou da sessão. Calendário diário não equivale a executar a cada 24 horas em qualquer regra de horário civil.

## 3. Testar manualmente e habilitar

```sql
EXEC DBMS_SCHEDULER.RUN_JOB('JOB_LAB_ROTINA',use_current_session=>TRUE);
SELECT * FROM T_JOB_LAB ORDER BY instante;
```

Esse teste síncrono não reproduz sozinho todo o histórico/contexto de um slave agendado. Após conferir, habilite e observe uma execução do agendador:

```sql
EXEC DBMS_SCHEDULER.ENABLE('JOB_LAB_ROTINA');
SELECT job_name, enabled, state, next_run_date, run_count, failure_count
FROM user_scheduler_jobs WHERE job_name='JOB_LAB_ROTINA';
SELECT log_date, job_name, status, error#, actual_start_date, run_duration, additional_info
FROM user_scheduler_job_run_details WHERE job_name='JOB_LAB_ROTINA' ORDER BY log_date;
```

Inspecione os detalhes de erro, log e efeito na tabela. Não considere apenas ENABLED como prova de sucesso. Configure logging e retenção conforme a política; uma notificação precisa de canal/supervisão configurados, não acontece só por existir um job.

## 4. Alterar, parar e retirar

Desabilitar evita execuções futuras, mas não é sinônimo de interromper uma execução já ativa. Consulte `USER_SCHEDULER_RUNNING_JOBS`, coordene consumidores e use o método STOP_JOB apropriado quando necessário; `force` exige avaliar rollback/efeitos já confirmados.

Para retirar somente o job de teste, depois de conferir que não está ativo:

```sql
EXEC DBMS_SCHEDULER.DISABLE('JOB_LAB_ROTINA');
EXEC DBMS_SCHEDULER.DROP_JOB('JOB_LAB_ROTINA',force=>FALSE);
```

Guarde a definição e histórico relevantes antes. Remover o job não desfaz dados já inseridos; decidir a limpeza de T_JOB_LAB e a remoção do procedimento é outra etapa, limitada aos objetos de teste.

## 5. Relacionar definição e execução sem multiplicar jobs

Como administrador autorizado na LABPDB, a junção precisa considerar proprietário **e** nome:

```sql
SELECT j.owner, j.job_name, j.state, j.enabled, j.next_run_date,
       r.session_id, r.elapsed_time
FROM dba_scheduler_jobs j
LEFT JOIN dba_scheduler_running_jobs r
  ON r.owner=j.owner AND r.job_name=j.job_name
WHERE j.owner='APP_LAB'
ORDER BY j.job_name;
```

A ausência de linha em RUNNING_JOBS é normal fora da execução; LEFT JOIN mantém a definição visível. Em RAC/jobs com múltiplas instâncias, acrescente a identidade pertinente e não presuma uma única linha por job. Confira erros e duração em JOB_RUN_DETAILS, timezone, logging e retenção. Job desabilitado, quebrado ou sem execução recente exige correlacionar agenda e falhas; não reative um job legado antes de ler sua ação e efeitos.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [scheduler_execucoes.sql](scripts/diagnostico/scheduler_execucoes.sql) — Consultar definicoes e logs do Scheduler.
- [jobs_legados.sql](scripts/diagnostico/jobs_legados.sql) — Consultar DBMS_JOB sem confundir com Scheduler.
- [alterar_estado_job.sql](scripts/manutencao/alterar_estado_job.sql) — Habilitar ou desabilitar um job local proprio.
- [scheduler_em_execucao.sql](scripts/diagnostico/scheduler_em_execucao.sql) — Consultar jobs Scheduler em execucao.
- [scheduler_janelas.sql](scripts/diagnostico/scheduler_janelas.sql) — Consultar janelas e resource plans do Scheduler.

## Roteiros de solução de problemas

- [16 · Job falhando, atrasado ou sem execução](solucao-de-problemas/16-jobs-com-falha-ou-atraso.md).

## Referências oficiais

- [Agendamento](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/scheduling-jobs-with-oracle-scheduler.html)
- [DBMS_SCHEDULER](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SCHEDULER.html)
