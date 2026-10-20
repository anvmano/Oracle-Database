# 04 · Limite de processos ou sessões atingido

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-00020 refere-se ao limite de processos; ORA-00018, ao de sessões. Pools crescentes ou conexões não devolvidas podem esgotar capacidade.

## Arquivos do projeto

[sessões e bloqueios](<../Monitorar sessoes e bloqueios.md>), [limites_recursos.sql](../scripts/diagnostico/limites_recursos.sql), [parametros_instancia.sql](../scripts/diagnostico/parametros_instancia.sql), [sessoes_ativas.sql](../scripts/diagnostico/sessoes_ativas.sql), [relatório do SO](<../Script monitorar SO.md>).

## Roteiro de solução

1. Na instância afetada, consulte consumo atual, máximo desde startup e limite com `limites_recursos.sql` no escopo indicado.
2. Examine `processes` e `sessions` usando `parametros_instancia.sql`, com `p_nome` igual ao parâmetro de cada consulta.
3. Use a consulta de inventário de sessões do tutorial para localizar usuários, módulos e pools que multiplicam conexões. `sessoes_ativas.sql` mostra somente ativas e não basta para investigar conexões INACTIVE.
4. Se houver vazamento/rajada, corrija devolução de conexões e limites dos pools, coordenando a redução de carga. INACTIVE, sozinho, não justifica encerramento: pode existir transação aberta.
5. Se a demanda for legítima, dimensione limites junto com memória e recursos do SO; parâmetros estáticos exigem mudança planejada e eventual reinício, não apenas um valor maior.

## Confirmar a retomada

Novas conexões funcionam, consumo fica estável e não volta a crescer sem relação com a carga. Se não houver conexão administrativa disponível, use os meios operacionais previstos para o ambiente, sem tentar uma conexão por segundo.

## Referências oficiais

- [ORA-00020](https://docs.oracle.com/en/error-help/db/ora-00020/).
- [ORA-00018](https://docs.oracle.com/en/error-help/db/ora-00018/).

[← Problema 03](03-privilegios-e-acesso-a-objetos.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 05 →](05-sql-lento-cpu-e-io.md)
