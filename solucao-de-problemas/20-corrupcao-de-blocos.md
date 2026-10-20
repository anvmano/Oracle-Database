# 20 · Corrupção de blocos ou falha de leitura de dados

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-01578 identifica bloco corrompido; ORA-01110 fornece contexto do arquivo. A abordagem depende de tipo, extensão, objeto afetado e fontes íntegras de recuperação.

## Arquivos do projeto

[corrupção de blocos](<../Diagnosticar corrupcao de blocos.md>), [corrupcao_blocos.sql](../scripts/diagnostico/corrupcao_blocos.sql), [alert log/ADRCI](<../Diagnosticar erros com ADRCI e alert log.md>), [comandos de restore](<../Comandos para restore.md>), [backup_pecas.sql](../scripts/diagnostico/backup_pecas.sql).

## Roteiro de solução

1. Preserve mensagem/trace, arquivo, bloco, container e horário. Confira falhas de storage/SO e evite intervenções que destruam a evidência.
2. Consulte corrupções registradas e faça o mapeamento do bloco para segmento pelo tutorial. Lista vazia não prova ausência de corrupção; nem todo problema lógico aparece da mesma forma.
3. Delimite o escopo e examine fontes de backup/redo íntegras. Distingua índice reconstruível de segmento de dados, poucos blocos de perda extensa e corrupção física de lógica.
4. Escolha o procedimento correspondente: recuperação de blocos quando suas pré-condições forem atendidas, restore/recover mais amplo ou recuperação específica/escalonamento. Não há reparo automático no SQL de diagnóstico.
5. Se faltar fonte íntegra/redo ou houver erro interno persistente, preserve o estado e encaminhe com as evidências e o objetivo de recuperação; não force abertura nem marque blocos para ignorar a perda.

## Confirmar a retomada

Recuperação aceita, objeto funcional e causa de armazenamento tratada quando existente. Ignorar blocos não recupera seu conteúdo; não declare dados íntegros apenas porque a consulta deixou de gerar erro.

## Referências oficiais

- [ORA-01578](https://docs.oracle.com/en/error-help/db/ora-01578/).

[← Problema 19](19-data-guard-atraso-e-gap.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md)
