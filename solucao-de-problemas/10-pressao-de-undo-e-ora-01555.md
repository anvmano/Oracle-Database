# 10 · Pressão de UNDO ou perda de versão para leitura

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-30036 é falta de espaço para expansão de undo; ORA-01555 é indisponibilidade da versão necessária à consistência de leitura. São ramos diferentes do mesmo assunto.

## Arquivos do projeto

[TEMP e UNDO](<../Monitorar TEMP e UNDO.md>), [transacoes_undo.sql](../scripts/diagnostico/transacoes_undo.sql), [parametros_instancia.sql](../scripts/diagnostico/parametros_instancia.sql), [datafiles_uso.sql](../scripts/diagnostico/datafiles_uso.sql).

## Roteiro de solução

1. Diferencie falha de DML por capacidade de falha de consulta por versão antiga; registre horário e duração da operação.
2. Use a consulta `V$UNDOSTAT` do tutorial para relacionar `SSOLDERRCNT`, `NOSPACEERRCNT`, duração máxima de consulta e retenção observada ao período do erro.
3. Identifique transações/consumidores com `transacoes_undo.sql`; ele usa o tamanho real do bloco para expressar o consumo.
4. Para falta de espaço, examine transações excepcionais, capacidade e limites de expansão. Trate o processo consumidor ou aumente a capacidade quando necessária.
5. Para ORA-01555, investigue duração da consulta, carga concorrente, retenção/capacidade e padrão transacional da aplicação. Reduza trabalho ou planeje retenção suficiente; aumentar `UNDO_RETENTION` isoladamente não cria espaço.

## Confirmar a retomada

A consulta ou DML que falhava conclui, e os contadores de erro não aumentam no período comparável. Não elimine undo ativa nem introduza COMMIT frequente como correção genérica; `RETENTION GUARANTEE` também pode causar falhas de DML sob falta de espaço.

## Referências oficiais

- [ORA-30036](https://docs.oracle.com/en/error-help/db/ora-30036/).
- [ORA-01555](https://docs.oracle.com/en/error-help/db/ora-01555/).

[← Problema 09](09-espaco-temporario.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 11 →](11-fra-e-arquivamento.md)
