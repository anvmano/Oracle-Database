# 11 · FRA cheia ou falha de arquivamento

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-19809/19804 sugerem pressão na área de recuperação; ORA-00257 indica falha do archiver que precisa da causa no log. Nem todo erro de arquivamento é FRA cheia.

## Arquivos do projeto

[FRA e archivelogs](<../Monitorar FRA e archivelogs.md>), [fra_uso.sql](../scripts/diagnostico/fra_uso.sql), [redo_archives.sql](../scripts/diagnostico/redo_archives.sql), [redo_switches.sql](../scripts/diagnostico/redo_switches.sql), [rman_execucoes.sql](../scripts/diagnostico/rman_execucoes.sql).

## Roteiro de solução

1. Em root/non-CDB, preserve alert log e consulte erro do destino de archive pelo tutorial. Diferencie limite lógico, disco cheio, destino desmontado/permissão e falha de proteção.
2. Confira consumo/recuperável da FRA e aumento da geração de redo. Não some cópias de uma sequência como geração distinta.
3. Antes de liberar arquivos, confira backups, política de retenção/exclusão e sequences necessárias a todos os standbys exigidos.
4. Corrija o destino indisponível ou forneça capacidade real. Alterar apenas o limite da FRA não cria disco.
5. Se houver arquivos elegíveis, trate a limpeza pelo RMAN e pela política correspondente, com limites conferidos. `EXPIRED` não é sinônimo de obsoleto; estado recuperável não é autorização para apagar pelo SO.

## Confirmar a retomada

Arquivamento e operações da aplicação voltam a funcionar, erros de destino cessam e a projeção de esgotamento melhora. Não remova archives em massa para apenas baixar o percentual.

## Referências oficiais

- [ORA-19809](https://docs.oracle.com/en/error-help/db/ora-19809/).
- [ORA-19804](https://docs.oracle.com/en/error-help/db/ora-19804/).
- [ORA-00257](https://docs.oracle.com/en/error-help/db/ora-00257/).

[← Problema 10](10-pressao-de-undo-e-ora-01555.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 12 →](12-memoria-sga-e-pga.md)
