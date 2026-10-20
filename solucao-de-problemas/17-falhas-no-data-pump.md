# 17 · Exportação/importação Data Pump falhando ou parada

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

erros de logfile, dump, permissão ou espaço; job que não progride; importação que termina com erros em parte dos objetos. A mensagem principal pode ser apenas um resumo de erros seguintes.

## Arquivos do projeto

[EXPDP](../EXPDP.md), [IMPDP](../IMPDP.md), [datapump_jobs.sql](../scripts/diagnostico/datapump_jobs.sql), [directories.sql](../scripts/diagnostico/directories.sql), [operacoes_longas.sql](../scripts/diagnostico/operacoes_longas.sql), [quotas_tablespaces.sql](../scripts/diagnostico/quotas_tablespaces.sql).

## Roteiro de solução

1. Guarde parfile sem segredo, log completo, modo, origem/destino, owner e nome do job. Localize o erro específico de arquivo, objeto ou worker.
2. Consulte jobs pelo owner e DIRECTORY pelo nome. O caminho é no servidor; confira arquivos, espaço e permissões do processo Oracle, além dos grants do objeto DIRECTORY.
3. Para importação, confira schema/PDB/tablespace de destino, quota, remapeamentos e compatibilidade. Para falta de espaço ou locks, siga os casos correspondentes.
4. Se o job existe, acompanhe-o pelo mecanismo ATTACH/STATUS documentado, em vez de iniciar uma segunda cópia. NOT RUNNING não autoriza excluir a master table.
5. Depois de corrigir a causa, retome ou reprocesse somente o escopo decidido. Antes de repetir importação, considere os objetos/dados já criados; não use substituição/truncamento como tentativa genérica.

## Confirmar a retomada

Job/log reconciliados, objetos esperados presentes, dados e dependências coerentes. Barra de progresso ou mensagem final sem examinar os erros não demonstra importação completa.

## Referências oficiais

- [Data Pump Import](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/datapump-import-utility.html).
- [ORA-39070](https://docs.oracle.com/en/error-help/db/ora-39070/).
- [ORA-31640](https://docs.oracle.com/en/error-help/db/ora-31640/).

[← Problema 16](16-jobs-com-falha-ou-atraso.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 18 →](18-falhas-no-backup-rman.md)
