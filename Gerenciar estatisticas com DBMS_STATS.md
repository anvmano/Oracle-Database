# Gerenciar estatísticas com DBMS_STATS

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; estatísticas de uma tabela de teste, com exportação anterior e retorno.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use APP_LAB na LABPDB e a tabela `T_PLANO_LAB` criada no [exercício DBMS_XPLAN](<Diagnosticar SQL lento com DBMS_XPLAN.md>). Não colete estatísticas de todo o banco como solução genérica para lentidão. Confira janela, volume, preferências e tarefas automáticas já existentes.

Estatísticas alteram estimativas do otimizador e podem mudar planos. Esse guia não altera dados de negócio; o retorno é das estatísticas, não de transações.

## 1. Registrar estado e preferências

```sql
SELECT table_name, num_rows, blocks, last_analyzed, stale_stats, stattype_locked
FROM user_tab_statistics WHERE table_name='T_PLANO_LAB';
SELECT DBMS_STATS.GET_PREFS('STALE_PERCENT',USER,'T_PLANO_LAB') FROM dual;
SELECT DBMS_STATS.GET_PREFS('METHOD_OPT',USER,'T_PLANO_LAB') FROM dual;
```

Registre plano/tempos do SQL-alvo e volume atual. NUM_ROWS é a estimativa da última coleta, não um COUNT em tempo real. Estatísticas bloqueadas exigem entender a decisão anterior, não executar FORCE indiscriminadamente.

## 2. Exportar as estatísticas existentes

Crie `STATS_BKP` uma única vez, se ainda não existir; a tabela não é de dados da aplicação:

```sql
EXEC DBMS_STATS.CREATE_STAT_TABLE(ownname=>'APP_LAB',stattab=>'STATS_BKP');
BEGIN
  DBMS_STATS.EXPORT_TABLE_STATS(ownname=>'APP_LAB',tabname=>'T_PLANO_LAB',
    stattab=>'STATS_BKP',statid=>'ANTES_TESTE_01',statown=>'APP_LAB');
END;
/
```

Use STATID novo por experimento e confira o resultado. Se a tabela nunca teve estatísticas, não presuma que uma exportação vazia ofereça o mesmo retorno de uma versão anterior válida; registre essa condição e crie uma base controlada primeiro.

## 3. Coletar apenas o escopo planejado

```sql
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname=>'APP_LAB',tabname=>'T_PLANO_LAB',
    estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE,
    method_opt=>'FOR ALL COLUMNS SIZE AUTO',degree=>1,cascade=>TRUE,
    no_invalidate=>DBMS_STATS.AUTO_INVALIDATE);
END;
/
```

As opções são do teste pequeno; tabelas particionadas, estatísticas incrementais, globais e histogramas exigem planejamento próprio. Não force histogramas em todas as colunas nem invalide todos os cursores como rotina.

## 4. Comparar e aceitar

Repita estatísticas, plano e execução real com o mesmo conjunto de binds/dados. Confira estimativas versus linhas observadas, CPU/leituras e tempo, respeitando variação de cache e concorrência. Uma coleta bem-sucedida não prova ganho de desempenho. Não limpe buffer cache/shared pool para tornar uma comparação artificialmente diferente.

## 5. Retornar as estatísticas se necessário

Com a mesma tabela/STATID previamente preservados:

```sql
BEGIN
  DBMS_STATS.IMPORT_TABLE_STATS(ownname=>'APP_LAB',tabname=>'T_PLANO_LAB',
    stattab=>'STATS_BKP',statid=>'ANTES_TESTE_01',statown=>'APP_LAB',
    no_invalidate=>DBMS_STATS.AUTO_INVALIDATE);
END;
/
```

Confira retorno do plano/comportamento no momento em que os cursores forem usados/reparseados; não prometa alteração instantânea de toda sessão. O histórico automático também pode permitir RESTORE_TABLE_STATS, dentro da retenção real, mas não substitui conferir a existência da versão desejada. Guarde evidências antes de eliminar a tabela de estatísticas.

## 6. Selecionar candidatos sem executar coleta geral

No próprio schema, levante tabelas com estatísticas ausentes ou marcadas como desatualizadas:

```sql
SELECT table_name, partition_name, object_type, last_analyzed,
       stale_stats, stattype_locked
FROM user_tab_statistics
WHERE last_analyzed IS NULL OR stale_stats='YES'
ORDER BY table_name, partition_name;
```

Revise se a linha representa tabela, partição ou estatística global e se a tabela é temporária/externa. Esse levantamento é uma fila de análise, não autorização para gerar e executar GATHER_SCHEMA_STATS sobre todos os owners. Combine volume, preferências, bloqueios e janela automática antes da intervenção. Registre também candidatos que não devem ser coletados e o motivo. Em caso de regressão, use a exportação/histórico confirmado, sem FORCE ou limpeza global de cursores.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [estatisticas_pendentes.sql](scripts/diagnostico/estatisticas_pendentes.sql) — Identificar estatisticas ausentes, stale ou bloqueadas.
- [criar_tabela_estatisticas.sql](scripts/manutencao/criar_tabela_estatisticas.sql) — Criar repositorio de estatisticas no proprio schema.
- [exportar_estatisticas_tabela.sql](scripts/manutencao/exportar_estatisticas_tabela.sql) — Exportar estatisticas de uma tabela sem sobrescrever statid.
- [coletar_estatisticas_tabela.sql](scripts/manutencao/coletar_estatisticas_tabela.sql) — Preservar e coletar estatisticas de uma tabela propria.
- [importar_estatisticas_tabela.sql](scripts/manutencao/importar_estatisticas_tabela.sql) — Restaurar estatisticas exportadas da mesma tabela.
- [estatisticas_historico.sql](scripts/diagnostico/estatisticas_historico.sql) — Consultar datas do historico de estatisticas por tabela.
- [estatisticas_automaticas.sql](scripts/diagnostico/estatisticas_automaticas.sql) — Consultar estado da tarefa automatica de estatisticas.

## Roteiros de solução de problemas

- [07 · Plano ruim associado a estatísticas ausentes ou alteradas](solucao-de-problemas/07-estatisticas-e-regressao-de-plano.md).

## Referências oficiais

- [DBMS_STATS](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_STATS.html)
- [Transportar estatísticas](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/transporting-optimizer-statistics.html)
