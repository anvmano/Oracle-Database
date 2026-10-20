-- Objetivo: Consultar objetos DIRECTORY visiveis
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de ALL_DIRECTORIES.
-- Parametros bind: p_nome opcional (DIRECTORY_NAME)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../EXPDP.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: O caminho e no servidor; existencia no dicionario nao comprova permissoes do SO ou acesso a arquivos.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT owner,directory_name,directory_path,origin_con_id
FROM all_directories WHERE :p_nome IS NULL OR directory_name=:p_nome
ORDER BY directory_name;
