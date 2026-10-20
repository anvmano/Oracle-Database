-- Objetivo: Consultar estado da tarefa automatica de estatisticas
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_AUTOTASK_CLIENT.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Gerenciar estatisticas com DBMS_STATS.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Configuracao no container; ENABLED nao comprova ultima execucao bem-sucedida nem estatisticas atuais.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT client_name,status,window_group
FROM dba_autotask_client WHERE client_name='auto optimizer stats collection';
