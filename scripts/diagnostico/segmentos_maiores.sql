-- Objetivo: Consultar os 50 maiores segmentos do schema
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_SEGMENTS.
-- Parametros bind: p_owner; p_nome opcional (segmento exato)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Monitorar capacidade e crescimento do banco.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Alocacao por segmento/particao; nao mede tamanho logico dos dados nem soma tabela, indices e LOBs.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,segment_name,partition_name,segment_type,tablespace_name,
       ROUND(bytes/1048576,3) AS alocado_mib,blocks,extents
FROM dba_segments WHERE owner=:p_owner AND (:p_nome IS NULL OR segment_name=:p_nome)
ORDER BY bytes DESC,segment_name,partition_name
FETCH FIRST 50 ROWS ONLY;
