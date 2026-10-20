-- Objetivo: Consultar janelas e resource plans do Scheduler
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_SCHEDULER_WINDOWS.
-- Parametros bind: p_nome opcional (janela)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Criar e monitorar jobs com DBMS_SCHEDULER.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Consultar no container do agendamento; nao ativa janelas nem altera planos de recursos.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT window_name,resource_plan,enabled,active,next_start_date,duration
FROM dba_scheduler_windows WHERE :p_nome IS NULL OR window_name=:p_nome ORDER BY window_name;
