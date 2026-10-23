# 07 · Plano ruim associado a estatísticas ausentes ou alteradas

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

regressão após carga/coleta ou estimativas muito diferentes das linhas observadas. `STALE_STATS=YES` é uma pista, não prova isolada da causa do plano.

## Arquivos do projeto

[DBMS_STATS](<../Gerenciar estatisticas com DBMS_STATS.md>), [estatisticas_pendentes.sql](../scripts/diagnostico/estatisticas_pendentes.sql), [estatisticas_historico.sql](../scripts/diagnostico/estatisticas_historico.sql), [estatisticas_automaticas.sql](../scripts/diagnostico/estatisticas_automaticas.sql), [coletar_estatisticas_tabela.sql](../scripts/manutencao/coletar_estatisticas_tabela.sql), [importar_estatisticas_tabela.sql](../scripts/manutencao/importar_estatisticas_tabela.sql).

## Roteiro de solução

1. Identifique SQL/objeto e correlacione mudança de plano, carga e horário de atualização das estatísticas.
2. Consulte pendências/histórico com `p_owner`, `p_nome` igual à tabela e período pertinente. Confira bloqueios de estatísticas e funcionamento da coleta automática.
3. Se as estatísticas forem a causa, preserve o estado anterior e defina o escopo. A rotina de coleta da biblioteca exporta antes de coletar, exige repositório existente e statid novo.
4. O uso dessas intervenções exige conexão do dono local e tabela dentro do escopo do cabeçalho. Confira `PUBLISH=TRUE`, ausência de estatísticas pendentes e, para coleta, `PREFERENCE_OVERRIDES_PARAMETER=FALSE`. Casos incompatíveis, primeira coleta sem estatísticas anteriores e tabelas particionadas seguem tratamento específico; não altere preferências ou pendências automaticamente.
5. Compare o SQL afetado. Se piorar, use a importação do backup correto conforme o procedimento, considerando a reutilização/invalidação dos cursores.

## Confirmar a retomada

Estimativas, plano, resultado e desempenho melhoram na operação relevante. Não reutilize na coleta um statid já preenchido por exportação separada; a rotina recusa sobrescrita. Não colete todos os schemas como resposta a um SQL.

## Referências oficiais

- [Conceitos de estatísticas](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/optimizer-statistics-concepts.html).

[← Problema 06](06-bloqueios-transacoes-e-deadlocks.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 08 →](08-espaco-permanente-e-quota.md)
