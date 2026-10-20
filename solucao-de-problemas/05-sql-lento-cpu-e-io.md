# 05 · SQL lento e alto consumo de CPU ou I/O

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

uma operação passa a consumir mais tempo, CPU, leituras ou espera. É preciso identificar SQL, execução e gargalo; full scan ou custo estimado alto isoladamente não provam erro.

## Arquivos do projeto

[DBMS_XPLAN](<../Diagnosticar SQL lento com DBMS_XPLAN.md>), [trace e TKPROF](<../Rastrear SQL com DBMS_MONITOR e TKPROF.md>), [sessoes_ativas.sql](../scripts/diagnostico/sessoes_ativas.sql), [sql_por_id.sql](../scripts/diagnostico/sql_por_id.sql), [planos_cursor.sql](../scripts/diagnostico/planos_cursor.sql), [sessao_io.sql](../scripts/diagnostico/sessao_io.sql), [esperas_sistema.sql](../scripts/diagnostico/esperas_sistema.sql).

## Roteiro de solução

1. Localize o usuário/módulo e o SQL_ID da operação afetada. Registre instância, cursor filho, duração percebida e valores de entrada relevantes em local protegido.
2. Preencha `p_sql_id` e compare texto, contadores e linhas do plano. Para um período, compare amostras; a média acumulada de um cursor pode esconder a execução problemática.
3. Distinga execução cara de espera por lock, I/O ou recurso. Se o evento indicar bloqueio, siga o [caso 06 · Bloqueios e deadlocks](06-bloqueios-transacoes-e-deadlocks.md) antes de alterar o plano.
4. Pelo tutorial DBMS_XPLAN, interprete o cursor correto e, quando já disponíveis, linhas observadas versus estimadas. Procure filtros, conversões, joins, volume retornado e acessos inadequados. Trace curto pode complementar evidências ausentes.
5. Corrija a causa delimitada: SQL/acesso aos dados, estatísticas quando demonstradas, concorrência ou infraestrutura. Compare uma mudança de cada vez.

## Confirmar a retomada

Mesma operação e entradas retornam resultado correto dentro da meta, com leituras/CPU/tempo coerentes sob carga comparável. Não há uso automático de AWR/ASH ou advisor neste roteiro.

## Referências oficiais

- [Introdução ao SQL tuning](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/introduction-to-sql-tuning.html).

[← Problema 04](04-limite-de-processos-e-sessoes.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 06 →](06-bloqueios-transacoes-e-deadlocks.md)
