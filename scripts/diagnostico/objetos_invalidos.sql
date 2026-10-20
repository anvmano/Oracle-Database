-- Objetivo: Listar objetos invalidos e seus erros
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de DBA_OBJECTS, DBA_ERRORS.
-- Parametros bind: p_owner; p_nome opcional
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Diagnosticar objetos invalidos.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

BEGIN
  IF :p_owner IS NULL THEN RAISE_APPLICATION_ERROR(-20044,'Informar p_owner exato.'); END IF;
END;
/

SELECT owner,object_name,subobject_name,object_type,status,last_ddl_time
FROM dba_objects WHERE owner=:p_owner AND status='INVALID'
 AND (:p_nome IS NULL OR object_name=:p_nome) ORDER BY object_type,object_name;
SELECT owner,name,type,sequence,line,position,attribute,text
FROM dba_errors WHERE owner=:p_owner AND (:p_nome IS NULL OR name=:p_nome)
ORDER BY name,type,sequence;
