# 13 · Excesso de cursores abertos por sessão

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-01000 pode representar um limite insuficiente para demanda legítima ou cursores que a aplicação não fecha.

## Arquivos do projeto

[cursores_sessao.sql](../scripts/diagnostico/cursores_sessao.sql), [parametros_instancia.sql](../scripts/diagnostico/parametros_instancia.sql), [sessões](<../Monitorar sessoes e bloqueios.md>).

## Roteiro de solução

1. Identifique usuário, instância e sessão da falha. Execute `cursores_sessao.sql` com o usuário afetado para localizar tipos e concentração de entradas.
2. Compare amostras da mesma sessão/SERIAL para saber se o número cresce sem estabilizar após as operações.
3. Consulte `open_cursors` com `parametros_instancia.sql`. O relatório de cursores inclui cache: sua contagem não é a medida exata de cursores atualmente abertos. Confirme `opened cursors current` em `V$SESSTAT` conforme as consultas da referência oficial, na instância correta.
4. Se houver vazamento, corrija fechamento de statements/result sets e uso do driver/pool. Planeje eventual renovação das conexões afetadas com os consumidores.
5. Se a demanda simultânea for legítima, ajuste `OPEN_CURSORS` de forma dimensionada, considerando o custo por sessão.

## Confirmar a retomada

O consumo estabiliza e a mesma sequência de operações deixa de gerar ORA-01000. Apenas elevar o limite pode adiar o reaparecimento de um vazamento.

## Referências oficiais

- [ORA-01000 e consultas de diagnóstico oficiais](https://docs.oracle.com/en/error-help/db/ora-01000/).

[← Problema 12](12-memoria-sga-e-pga.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 14 →](14-indices-inutilizaveis.md)
