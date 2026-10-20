# 16 · Job falhando, atrasado ou sem execução

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

falhas no histórico, job quebrado/desabilitado ou ausência de execução prevista. ENABLED não demonstra execução nem sucesso.

## Arquivos do projeto

[DBMS_SCHEDULER](<../Criar e monitorar jobs com DBMS_SCHEDULER.md>), [scheduler_execucoes.sql](../scripts/diagnostico/scheduler_execucoes.sql), [scheduler_em_execucao.sql](../scripts/diagnostico/scheduler_em_execucao.sql), [scheduler_janelas.sql](../scripts/diagnostico/scheduler_janelas.sql), [jobs_legados.sql](../scripts/diagnostico/jobs_legados.sql), [alterar_estado_job.sql](../scripts/manutencao/alterar_estado_job.sql).

## Roteiro de solução

1. Diferencie Scheduler de DBMS_JOB e identifique owner/nome. Use a consulta correspondente; não aplique uma API ao outro tipo.
2. Para Scheduler, consulte definição, última falha, próximo horário e execução atual; amplie o período de logs quando necessário. Examine mensagem adicional de erro pelo tutorial, pois o resumo da biblioteca não mostra todo o contexto.
3. Confira timezone, ação, dependências e privilégios diretos; se não houver execução, investigue agendamento/janelas, recursos e `JOB_QUEUE_PROCESSES`.
4. Corrija a causa e confirme se repetir a tarefa pode duplicar efeitos já confirmados. Desabilitar impede novas execuções, mas não equivale a parar a atual.
5. A intervenção de estado da biblioteca serve somente para job próprio local simples, não em execução. Habilitar pode disparar agendamento vencido; revisão da ação vem antes.

## Confirmar a retomada

A execução agendada registra resultado esperado e produz o efeito funcional único/correto. Não apague e recrie o job apenas para remover seu histórico de falhas.

## Referências oficiais

- [Administração do Scheduler](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/scheduling-jobs-with-oracle-scheduler.html).

[← Problema 15](15-objetos-invalidos.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 17 →](17-falhas-no-data-pump.md)
