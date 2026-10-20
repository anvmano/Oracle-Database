# 12 · Falta de memória compartilhada ou pressão de PGA

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-04031 refere-se a alocação em memória compartilhada; ORA-04030 indica falha de alocação de memória de processo; ORA-04036 indica limite agregado de PGA excedido.

## Arquivos do projeto

[memória SGA/PGA](<../Diagnosticar memoria SGA e PGA.md>), [sga_componentes.sql](../scripts/diagnostico/sga_componentes.sql), [shared_pool_reserved.sql](../scripts/diagnostico/shared_pool_reserved.sql), [biblioteca_cache.sql](../scripts/diagnostico/biblioteca_cache.sql), [pga_workareas.sql](../scripts/diagnostico/pga_workareas.sql), [sga_redimensionamentos.sql](../scripts/diagnostico/sga_redimensionamentos.sql), [relatório do SO](<../Script monitorar SO.md>).

## Roteiro de solução

1. Preserve mensagem completa/trace e identifique qual ramo de memória falhou; não conclua que todo erro de alocação exige aumentar a SGA.
2. Confira a configuração e os componentes locais. Relacione falhas no shared pool a alocações/reloads/invalidações, e pressão de PGA a workareas e concorrência.
3. Pelo guia, confronte memória disponível, swap, limites de processo e configuração do host. ORA-04030 também exige examinar esses limites.
4. Corrija carga, SQL, concorrência ou vazamento quando demonstrados. Dimensione memória somente em conjunto com recursos físicos e demais instâncias.
5. Ao mudar parâmetro/configuração, preserve valores anteriores e seu escopo; considere a necessidade de reinício indicada pelo parâmetro.

## Confirmar a retomada

Erros deixam de ocorrer e a carga funciona sem deslocar o problema para swap, I/O ou outra instância. Flush global de shared pool/cache e restart não são correções iniciais deste roteiro.

## Referências oficiais

- [ORA-04031](https://docs.oracle.com/en/error-help/db/ora-04031/).
- [ORA-04030](https://docs.oracle.com/en/error-help/db/ora-04030/).
- [ORA-04036](https://docs.oracle.com/en/error-help/db/ora-04036/).

[← Problema 11](11-fra-e-arquivamento.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 13 →](13-excesso-de-cursores.md)
