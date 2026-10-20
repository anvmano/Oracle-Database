# Extrair DDL com DBMS_METADATA

[← Índice](README.md)

**Escopo:** Inspeção de metadados em SQL*Plus; contexto de schema e container explícito.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Conecte ao container que contém o objeto. O proprietário pode extrair seus próprios objetos; outros schemas exigem permissões de metadados adequadas. Não use SYS por padrão só para consultar DDL. Identificadores comuns aparecem em maiúsculas no dicionário; nomes criados com aspas preservam a grafia.

## 1. Preparar saída — SQL*Plus

```sql
SET LONG 10000000
SET LONGCHUNKSIZE 1000000
SET PAGESIZE 0
SET LINESIZE 32767
SET TRIMSPOOL ON
SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);
```

Esses limites controlam apresentação do CLOB; confira se a saída não foi truncada. Para omitir atributos físicos **quando essa for a intenção**, execute `EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',FALSE);`. A omissão muda o DDL produzido e pode não servir para reproduzir o armazenamento original.

## 2. Extrair objetos específicos

Exemplos independentes; substitua nomes por objetos existentes:

```sql
SELECT DBMS_METADATA.GET_DDL('TABLE','CLIENTES','APP_OWNER') FROM dual;
SELECT DBMS_METADATA.GET_DDL('VIEW','V_CLIENTES','APP_OWNER') FROM dual;
SELECT DBMS_METADATA.GET_DDL('MATERIALIZED_VIEW','MV_CLIENTES','APP_OWNER') FROM dual;
SELECT DBMS_METADATA.GET_DDL('PROCEDURE','ATUALIZAR_CLIENTES','APP_OWNER') FROM dual;
SELECT DBMS_METADATA.GET_DDL('TRIGGER','TRG_CLIENTES','APP_OWNER') FROM dual;
SELECT DBMS_METADATA.GET_DDL('INDEX','IDX_CLIENTES_NOME','APP_OWNER') FROM dual;
```

O terceiro argumento identifica o proprietário; omiti-lo usa o schema padrão da chamada, não pesquisa todos os schemas.

## 3. Dependências de uma tabela

```sql
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('REF_CONSTRAINT','CLIENTES','APP_OWNER') FROM dual;
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('CONSTRAINT','CLIENTES','APP_OWNER') FROM dual;
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('TRIGGER','CLIENTES','APP_OWNER') FROM dual;
SELECT DBMS_METADATA.GET_DEPENDENT_DDL('INDEX','CLIENTES','APP_OWNER') FROM dual;
```

Essas chamadas podem informar objeto/dependência inexistente quando a tabela não possui aquele tipo. Não ignore toda exceção como se fosse ausência legítima; confira nome, container e privilégio. FKs de outras tabelas que **referenciam** CLIENTES não são necessariamente o mesmo conjunto de FKs definidas **em** CLIENTES.

## 4. Exportar DDL das tabelas do schema conectado

```sql
SPOOL tabelas.sql
SELECT DBMS_METADATA.GET_DDL('TABLE',table_name,USER)
FROM user_tables
WHERE nested='NO'
  AND (iot_type IS NULL OR iot_type<>'IOT_OVERFLOW')
ORDER BY table_name;
SPOOL OFF
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'DEFAULT');
```

Confira abertura/fechamento do spool, terminadores, tamanho e conteúdo. Essa saída é para inspeção e não garante ordem de dependências para recriar todo o schema. Não execute o arquivo sem revisar destinos, objetos já existentes e privilégios.

## 5. Obter metadados de um schema completo

Não converta indiscriminadamente todos os valores de `DBA_OBJECTS.OBJECT_TYPE` para `GET_DDL`: há tipos não suportados, subobjetos já incorporados e dependências especiais. Para um conjunto abrangente e ordenado de metadados, faça uma exportação de schema com `CONTENT=METADATA_ONLY` e gere `SQLFILE` com [EXPDP](EXPDP.md)/[IMPDP](IMPDP.md), revisando filtros e permissões. O SQLFILE não contém os dados e não é um backup completo da aplicação.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [extrair_ddl_objeto.sql](scripts/geradores/extrair_ddl_objeto.sql) — Extrair DDL de um objeto proprio.
- [extrair_indices_tabela.sql](scripts/geradores/extrair_indices_tabela.sql) — Extrair DDL dos indices de uma tabela propria.
- [extrair_constraints_tabela.sql](scripts/geradores/extrair_constraints_tabela.sql) — Extrair constraints definidas em uma tabela propria.
- [extrair_privilegios_usuario.sql](scripts/geradores/extrair_privilegios_usuario.sql) — Extrair grants diretos do usuario conectado.
- [gerar_recompilacao.sql](scripts/geradores/gerar_recompilacao.sql) — Gerar comandos para objetos invalidos sem executa-los.
- [extrair_grants_objeto.sql](scripts/geradores/extrair_grants_objeto.sql) — Extrair grants publicados em um objeto proprio.

## Referências oficiais

- [DBMS_METADATA](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_METADATA.html)
- [Data Pump Import / SQLFILE](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/datapump-import-utility.html)
