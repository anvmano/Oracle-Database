# 18 · Backup RMAN falhando ou não acontecendo

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

histórico FAILED, pilha RMAN/ORA ou backup previsto que não aparece. Ausência de registro pode ser falha do agendamento ou do início, não um backup concluído silenciosamente.

## Arquivos do projeto

[automação RMAN](<../Automatizar backups RMAN.md>), [parâmetros RMAN](<../Parametros RMAN.md>), [rman_execucoes.sql](../scripts/diagnostico/rman_execucoes.sql), [rman_em_execucao.sql](../scripts/diagnostico/rman_em_execucao.sql), [rman_configuracao.sql](../scripts/diagnostico/rman_configuracao.sql), [backup_pecas.sql](../scripts/diagnostico/backup_pecas.sql), [backup OCI](<../Configurar backup RMAN no OCI Object Storage.md>).

## Roteiro de solução

1. Confira agenda, log do disparador, código de saída e se a rotina entrou no RMAN. Preserve a pilha completa e a sequência das mensagens de causa, não apenas o resumo RMAN-03009/03002.
2. Consulte histórico, operações em andamento e peças no período, em root/non-CDB. Diferencie execução ausente, ainda em andamento, com avisos e falha.
3. Relacione o erro a destino cheio/desmontado, permissões, falta de archive, canal/SBT, autenticação ou configuração de mídia. Para SBT/OCI, consulte também os logs e requisitos do módulo correspondente.
4. Corrija o componente e execute a rotina do plano, mantendo a proteção contra concorrência e conferência do alvo. Não use exclusão de peças/lock como cancelamento de execução.
5. Reconcile os backups necessários à recuperação e sua cadeia; um novo incremental não recria automaticamente uma base perdida.

## Confirmar a retomada

Execução termina corretamente, peças previstas ficam disponíveis e a cobertura do plano de recuperação é restabelecida. A rotina de [restauração em laboratório](<../Testar restauracao completa em laboratorio.md>) documenta o exercício de recuperação; não é uma pendência nova de validação dos scripts deste projeto.

## Referências oficiais

- [Troubleshooting RMAN](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/troubleshooting-rman-operations.html).

[← Problema 17](17-falhas-no-data-pump.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 19 →](19-data-guard-atraso-e-gap.md)
