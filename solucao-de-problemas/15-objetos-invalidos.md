# 15 · Objeto inválido ou erro de compilação

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-04063/06508 pode acompanhar erro na fonte, dependência ausente/inválida ou falta de acesso. Recompilar não restaura automaticamente uma dependência removida.

## Arquivos do projeto

[objetos inválidos](<../Diagnosticar objetos invalidos.md>), [objetos_invalidos.sql](../scripts/diagnostico/objetos_invalidos.sql), [objetos_dependencias.sql](../scripts/diagnostico/objetos_dependencias.sql), [privilegios_usuario.sql](../scripts/diagnostico/privilegios_usuario.sql), [recompilar_objeto.sql](../scripts/manutencao/recompilar_objeto.sql), [gerar_recompilacao.sql](../scripts/geradores/gerar_recompilacao.sql).

## Roteiro de solução

1. Consulte objeto e erros com `p_owner` e `p_nome` exatos, preservando tipo, linha, mensagem e alteração recente.
2. Examine dependências e grants. Corrija primeiro a causa: fonte incorreta, objeto faltante, dependência inválida ou concessão direta necessária.
3. Se precisar compilar, use a intervenção de um objeto/tipo no próprio schema, conforme seus parâmetros. PACKAGE e PACKAGE BODY são alvos distintos; preserve a fonte anterior se houve alteração.
4. Consulte novamente erros/status e dependentes. O gerador de recompilação cria texto e não resolve sozinho toda a ordem de dependências.

## Confirmar a retomada

O objeto fica válido e a operação de aplicação produz o resultado esperado. Compilar um body vazio só para zerar inválidos não é uma solução; DDL e mudanças de código precisam do retorno próprio quando houver regressão.

## Referências oficiais

- [ORA-04063](https://docs.oracle.com/en/error-help/db/ora-04063/).
- [ORA-06508](https://docs.oracle.com/en/error-help/db/ora-06508/).

[← Problema 14](14-indices-inutilizaveis.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 16 →](16-jobs-com-falha-ou-atraso.md)
