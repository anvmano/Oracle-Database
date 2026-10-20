# 06 · Bloqueios, transações presas e deadlocks

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

espera de lock ou ORA-00054 pode ser contenção normal com impacto indevido. ORA-00060 identifica um ciclo de dependências: o deadlock precisa de análise do trace e da transação, mesmo depois que o banco interrompe a instrução envolvida.

## Arquivos do projeto

[sessões e bloqueios](<../Monitorar sessoes e bloqueios.md>), [alert log e ADRCI](<../Diagnosticar erros com ADRCI e alert log.md>), [bloqueadores.sql](../scripts/diagnostico/bloqueadores.sql), [objetos_bloqueados.sql](../scripts/diagnostico/objetos_bloqueados.sql), [transacoes_undo.sql](../scripts/diagnostico/transacoes_undo.sql), [encerrar_sessao.sql](../scripts/manutencao/encerrar_sessao.sql).

## Roteiro de solução

1. Em `bloqueadores.sql`, filtre o usuário em espera e localize a cadeia até o bloqueador. Na consulta de objetos, `p_owner` é o dono do objeto, que pode ser outro schema.
2. Confira transação, usuário, instância, SID/SERIAL e SQL/contexto do bloqueador. Ele pode estar INACTIVE e manter uma transação; o SQL corrente pode não ser o que obteve o lock.
3. Para deadlock, preserve o trace indicado no ADR e identifique objetos/ordem de acesso. Não trate como apenas uma espera longa nem presuma rollback da transação inteira.
4. Coordene conclusão ou rollback pela aplicação responsável. Se a sessão precisar ser encerrada, confirme novamente o alvo e use a intervenção individual documentada, incluindo instância esperada.
5. Corrija a recorrência: transações longas, conexões abandonadas, ordem inconsistente de atualização ou DDL concorrente.

## Confirmar a retomada

Espera terminou, rollback foi acompanhado e a aplicação recuperou a operação segundo suas regras. O encerramento não reativa a sessão nem garante liberação instantânea dos recursos.

## Referências oficiais

- [ORA-00054](https://docs.oracle.com/en/error-help/db/ora-00054/).
- [ORA-00060](https://docs.oracle.com/en/error-help/db/ora-00060/).

[← Problema 05](05-sql-lento-cpu-e-io.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 07 →](07-estatisticas-e-regressao-de-plano.md)
