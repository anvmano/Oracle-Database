# 09 · Falta de espaço para operações temporárias

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-01652 pode ocorrer em TEMP, mas também em segmento temporário de outra tablespace durante uma operação. Primeiro confirme a tablespace citada no erro; se for permanente, use também o [caso 08 · Espaço permanente e quota](08-espaco-permanente-e-quota.md).

## Arquivos do projeto

[TEMP e UNDO](<../Monitorar TEMP e UNDO.md>), [temp_uso.sql](../scripts/diagnostico/temp_uso.sql), [pga_workareas.sql](../scripts/diagnostico/pga_workareas.sql), [operacoes_longas.sql](../scripts/diagnostico/operacoes_longas.sql), [tablespaces](<../Comandos sobre tablespace.md>).

## Roteiro de solução

1. Identifique a tablespace, PDB e operação que falhou; confira tempfiles, teto e espaço físico pelo tutorial.
2. Localize os consumidores; com o usuário conhecido, use `temp_uso.sql` para associar consumo a SQL/sessão. O tamanho do tempfile não equivale a consumo ativo.
3. Investigue sorts, hash joins, criação de índices, paralelismo e execuções simultâneas. Consulte workareas para contextualizar pressão e passagens em disco.
4. Se a causa for SQL ou concorrência indevida, ajuste a operação ou sua simultaneidade. Cancelamento deve considerar quem usa a sessão e o efeito na aplicação.
5. Se a necessidade for legítima, amplie a área temporária pelo procedimento de tablespaces, com armazenamento disponível e crescimento delimitado.

## Confirmar a retomada

A operação conclui, consumo ativo recua e não há repetição do erro na carga prevista. TEMP pode conservar extents para reutilização; isso não exige apagar ou recriar tempfiles.

## Referências oficiais

- [ORA-01652](https://docs.oracle.com/en/error-help/db/ora-01652/).

[← Problema 08](08-espaco-permanente-e-quota.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 10 →](10-pressao-de-undo-e-ora-01555.md)
