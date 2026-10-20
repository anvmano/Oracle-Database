# Diagnosticar SQL com DBMS_XPLAN

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; consulta controlada, plano de cursor e estatísticas locais sem AWR/ASH.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use APP_LAB na LABPDB. DISPLAY_CURSOR exige os acessos diretos aplicáveis às views `V$SQL`, `V$SQL_PLAN` e `V$SQL_PLAN_STATISTICS_ALL`; solicite apenas os privilégios necessários ao administrador. Não use SYS para reproduzir o plano de uma consulta da aplicação. Se a análise usar AWR/ASH, SQL Monitor ou recursos de packs em outro fluxo, confira o licenciamento antes; este exercício usa o cursor corrente.

## 1. Preparar dados de teste pequenos

Somente se os objetos ainda não existirem no schema dedicado:

```sql
CREATE TABLE T_PLANO_LAB (id NUMBER PRIMARY KEY, categoria NUMBER, descricao VARCHAR2(100));
INSERT INTO T_PLANO_LAB
SELECT LEVEL, MOD(LEVEL,10), 'linha '||TO_CHAR(LEVEL)
FROM dual CONNECT BY LEVEL<=1000;
COMMIT;
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER,'T_PLANO_LAB');
SELECT COUNT(*) FROM T_PLANO_LAB;
```

O resultado esperado é 1000 linhas. Não repita a inserção sobre a tabela populada; a PK deve impedir duplicação e o erro não deve ser ignorado.

## 2. Executar e capturar o cursor real

Execute a consulta e consuma todo o resultado:

```sql
SELECT /*+ gather_plan_statistics */ /* LAB_PLANO_20261020 */
       categoria, COUNT(*) quantidade
FROM T_PLANO_LAB WHERE categoria=1 GROUP BY categoria;
```

O hint coleta estatísticas para essa execução; não altere STATISTICS_LEVEL globalmente por esse teste. Localize SQL_ID e child number do texto executado na sessão, sem confundir com consultas anteriores:

```sql
SELECT sql_id, child_number, plan_hash_value, executions, last_active_time
FROM v$sql
WHERE sql_text LIKE 'SELECT /*+ gather_plan_statistics */ /* LAB_PLANO_20261020 */%'
ORDER BY last_active_time DESC;
```

Com o SQL_ID/child **reais** substituídos:

```text
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('SQL_ID_CONFIRMADO',CHILD_CONFIRMADO,'ALLSTATS LAST +PREDICATE'));
```

## 3. Interpretar

| Campo/conceito | O que comparar |
|---|---|
| E-Rows / A-Rows | Estimativa versus linhas observadas, considerando Starts |
| Starts | Quantas vezes o operador foi iniciado |
| Buffers / Reads | Leituras lógicas/físicas disponíveis na coleta |
| Predicates | Filtros e condições de acesso realmente aplicados |
| Plano / child | Contexto de otimização e cursores diferentes para o mesmo SQL_ID |

ALLSTATS não inventa métricas ausentes: confirme que a execução foi instrumentada e o resultado consumido. Plano estimado via EXPLAIN PLAN pode divergir do executado por binds, ambiente e objetos; não use apenas custo estimado como tempo em segundos.

## 4. Formular e testar uma hipótese

Verifique filtro, quantidade retornada, tipos/conversões, estatísticas, joins e acesso aos objetos. Se testar um índice, use o [guia de índices](<Administrar indices e constraints.md>) e compare a mesma consulta/binds antes e depois, sem forçar plano como primeira resposta. Em tabela pequena, full scan pode ser a melhor opção.

## 5. Aceitação e retorno

Registre resultado correto, tempo, leituras, plano, binds e condições da coleta. Mude uma variável por experimento e mantenha a definição anterior. Remova apenas objetos/hints de teste que você criou, após aceitação. Não aplique perfil, baseline, patch SQL ou flush global sem procedimento específico e avaliação de licença/impacto.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [sql_por_id.sql](scripts/diagnostico/sql_por_id.sql) — Consultar texto e contadores por cursor filho.
- [planos_cursor.sql](scripts/diagnostico/planos_cursor.sql) — Consultar linhas de plano por SQL_ID e cursor filho.

## Roteiros de solução de problemas

- [05 · SQL lento e alto consumo de CPU ou I/O](solucao-de-problemas/05-sql-lento-cpu-e-io.md).

## Referências oficiais

- [DBMS_XPLAN](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_XPLAN.html)
- [Planos de execução](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/generating-and-displaying-execution-plans.html)
- [Licenciamento](https://docs.oracle.com/en/database/oracle/oracle-database/19/dblic/)
