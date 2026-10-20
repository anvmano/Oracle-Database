# 03 · Privilégio insuficiente ou objeto não acessível

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-01031 aponta falta de privilégio; ORA-00942 também pode indicar objeto/schema incorreto ou objeto que não está acessível ao usuário.

## Arquivos do projeto

[usuários e grants](<../User _ Profile _ Roles _ Grants.md>), [links e sinônimos](<../Administrar database links e sinonimos.md>), [privilegios_usuario.sql](../scripts/diagnostico/privilegios_usuario.sql), [sinonimos.sql](../scripts/diagnostico/sinonimos.sql), [objetos_dependencias.sql](../scripts/diagnostico/objetos_dependencias.sql), [extrair_grants_objeto.sql](../scripts/geradores/extrair_grants_objeto.sql).

## Roteiro de solução

1. Confirme usuário, PDB, schema atual, comando e objeto efetivamente referenciado. Diferencie chamada direta de execução dentro de PL/SQL.
2. Consulte concessões com `p_owner` igual ao grantee. Examine as roles relevantes separadamente; esse relatório não expande toda a cadeia de privilégios.
3. Se houver sinônimo, use `p_owner` como dono do sinônimo e `p_nome` como seu nome para verificar o destino. Se houver código armazenado, confira dependências no schema do código.
4. Corrija a referência ou conceda apenas o privilégio necessário, pelo proprietário/administrador responsável. PL/SQL com direitos do definidor normalmente precisa das concessões diretas aplicáveis ao proprietário, e não somente de uma role.

## Confirmar a retomada

Repetir a mesma operação como o usuário e no contexto originais. A execução administrativa bem-sucedida não demonstra que a aplicação recebeu o acesso correto. O gerador de grants é uma referência de DDL; ele não concede permissões automaticamente.

## Referências oficiais

- [ORA-01031](https://docs.oracle.com/en/error-help/db/ora-01031/).
- [ORA-00942](https://docs.oracle.com/en/error-help/db/ora-00942/).

[← Problema 02](02-conta-bloqueada-senha-expirada.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 04 →](04-limite-de-processos-e-sessoes.md)
