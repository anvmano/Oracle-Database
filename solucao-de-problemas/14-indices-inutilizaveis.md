# 14 · Índice ou partição de índice inutilizável

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-01502 ou estado UNUSABLE após carga/DDL pode afetar um índice, partição ou subpartição.

## Arquivos do projeto

[índices e constraints](<../Administrar indices e constraints.md>), [indices_status.sql](../scripts/diagnostico/indices_status.sql), [constraints_status.sql](../scripts/diagnostico/constraints_status.sql), [indices_colunas.sql](../scripts/diagnostico/indices_colunas.sql), [extrair_indices_tabela.sql](../scripts/geradores/extrair_indices_tabela.sql).

## Roteiro de solução

1. Localize o índice citado e a tabela correspondente. Nas consultas da biblioteca, `p_owner` é o dono da tabela e `p_nome` é a **tabela**, não o índice.
2. Leia os três conjuntos de `indices_status.sql`: índice, partições e subpartições. N/A no índice particionado não equivale a todas as partições utilizáveis.
3. Confira constraints, operação que gerou o estado e tipo de índice. Preserve o DDL e examine espaço/locks necessários à intervenção.
4. Repare o alvo apropriado pelo procedimento de índices: índice inteiro ou unidade afetada, conforme o tipo. Não aplique reconstrução geral ao schema nem elimine índice de constraint como atalho.
5. Corrija o processo de carga/DDL que deixou o objeto indisponível; opções online ou específicas de índice precisam corresponder ao ambiente.

## Confirmar a retomada

A unidade afetada está utilizável e a consulta/DML original funciona com as constraints preservadas. O gerador somente fornece DDL; a biblioteca não executa rebuild automático.

## Referências oficiais

- [ORA-01502](https://docs.oracle.com/en/error-help/db/ora-01502/).

[← Problema 13](13-excesso-de-cursores.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 15 →](15-objetos-invalidos.md)
