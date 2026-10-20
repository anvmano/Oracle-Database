# Analisar relatórios AWR e ASH

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c EE non-CDB de laboratório com Diagnostics Pack autorizado; análise por intervalo, sem tuning automático.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Confirme direitos de uso do Diagnostics Pack e das ferramentas adicionais antes de consultar AWR/ASH ou gerar relatórios. CONTROL_MANAGEMENT_PACK_ACCESS não substitui essa confirmação. SQL Tuning Advisor e outros recursos do Tuning Pack têm requisitos próprios e não fazem parte deste exercício.

Este cenário usa non-CDB separado. Em CDB/PDB e RAC, escopo, IDs, snapshots e relatórios precisam de revisão específica. Sem o cenário autorizado, use [DBMS_XPLAN](<Diagnosticar SQL lento com DBMS_XPLAN.md>), [trace](<Rastrear SQL com DBMS_MONITOR e TKPROF.md>) e [Statspack](<Analisar desempenho com Statspack.md>) conforme seus pré-requisitos.

## 1. Selecionar a janela correta

Como administrador autorizado no banco confirmado:

```sql
SELECT dbid, name, cdb FROM v$database;
SELECT snap_id, dbid, instance_number, startup_time,
       begin_interval_time, end_interval_time
FROM dba_hist_snapshot
WHERE end_interval_time >= SYSTIMESTAMP-INTERVAL '1' DAY
ORDER BY snap_id, instance_number;
```

Escolha dois snapshots da mesma base/instância e startup que envolvam o problema. Registre duração e fuso. Não crie snapshots ou amplie retenção automaticamente: há consumo de espaço e coleta a considerar. Se a janela não existe, não atribua ao relatório uma evidência que ele não tem.

## 2. Gerar o AWR

No SQL*Plus do Oracle Home correto e em diretório privado gravável:

```sql
@?/rdbms/admin/awrrpt.sql
```

Selecione formato, dias, snapshots e nome novo conforme os prompts. Confira DBID, instância e timestamps no cabeçalho antes de interpretar. O arquivo pode conter SQL e informações operacionais; não o publique neste repositório.

## 3. Relacionar carga e espera

Examine carga, DB time, CPU, waits, leituras e SQLs mais relevantes. Diferencie tempo decorrido do intervalo de tempo agregado do trabalho de múltiplas sessões. Percentual alto com volume pequeno pode ser irrelevante; médias podem esconder picos. Compare com janela saudável de carga semelhante e métricas da aplicação.

Um SQL no topo não demonstra por si só a causa raiz. Confira plano, execuções, linhas, binds quando autorizados e concorrência. Não execute automaticamente recomendações de índices, profiles ou parâmetros.

## 4. Usar ASH para uma pergunta delimitada

Se o problema exigir distribuição de sessões ativas no tempo, no mesmo contexto autorizado:

```sql
@?/rdbms/admin/ashrpt.sql
```

Escolha intervalo/saída pelos prompts e confira o período realmente disponível. ASH é amostragem de sessões ativas: ausência de amostra não prova que uma operação não ocorreu, e contagem de amostras não é contagem exata de execuções. Correlacione evento, sessão, SQL_ID e aplicação.

## 5. Validar a hipótese e encerrar

Formule hipótese verificável e teste mudança única em laboratório. Compare a mesma carga, incluindo resposta da aplicação, consumo e erros. A análise termina sem alteração automática de parâmetro/objeto. Proteja os relatórios e preserve-os conforme retenção do incidente; limpeza de AWR/SYSAUX não integra este roteiro.

## Referências oficiais

- [Licenciamento dos packs](https://docs.oracle.com/en/database/oracle/oracle-database/19/dblic/Licensing-Information.html)
- [AWR e relatórios](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/gathering-database-statistics.html)
- [ASH](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/analyzing-sampled-data.html)
