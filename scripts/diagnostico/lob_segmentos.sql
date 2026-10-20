-- Objetivo: Medir segmentos LOB agregando particoes antes do join
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_LOBS, DBA_SEGMENTS.
-- Parametros bind: p_owner; p_nome opcional (tabela)
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Administrar segmentos LOB.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Alocacao do segmento, nao tamanho dos valores; exclui LOBINDEX; NULL exige investigar mapeamento/segmento diferido.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

WITH segmentos AS (
 SELECT owner,segment_name,SUM(bytes) AS bytes
 FROM dba_segments WHERE segment_type IN ('LOBSEGMENT','LOB PARTITION','LOB SUBPARTITION')
 GROUP BY owner,segment_name
)
SELECT l.owner,l.table_name,l.column_name,l.segment_name,l.securefile,l.partitioned,
       ROUND(s.bytes/1048576,3) AS lob_alocado_mib
FROM dba_lobs l LEFT JOIN segmentos s ON s.owner=l.owner AND s.segment_name=l.segment_name
WHERE l.owner=:p_owner AND (:p_nome IS NULL OR l.table_name=:p_nome)
ORDER BY l.table_name,l.column_name;
