-- Objetivo: Consultar espaco reservado e falhas de alocacao
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$SHARED_POOL_RESERVED.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar memoria SGA e PGA.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Tamanhos em bytes; algumas colunas dependem da configuracao do pool reservado. Nao altera parametros.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT free_space,avg_free_size,max_free_size,used_space,requests,request_misses,
       request_failures,last_failure_size,aborted_requests,con_id
FROM v$shared_pool_reserved;
