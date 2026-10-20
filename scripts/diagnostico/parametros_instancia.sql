-- Objetivo: Consultar parametros suportados modificados ou selecionados
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$PARAMETER.
-- Parametros bind: p_nome opcional (nome exato minusculo)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Arquitetura e componentes do Oracle.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: V$PARAMETER reflete a sessao; valores podem identificar caminhos. Nao consulta parametros ocultos.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT name,display_value,isdefault,isses_modifiable,issys_modifiable,ispdb_modifiable
FROM v$parameter
WHERE (:p_nome IS NOT NULL AND name=:p_nome)
   OR (:p_nome IS NULL AND isdefault='FALSE')
ORDER BY name;
