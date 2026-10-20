# 02 · Conta bloqueada ou senha expirada

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-28000 pode resultar de tentativas inválidas ou bloqueio administrativo; ORA-28001 exige tratamento da expiração da senha. Desbloqueio e troca de senha têm efeitos diferentes.

## Arquivos do projeto

[usuários, profiles e grants](<../User _ Profile _ Roles _ Grants.md>), [usuarios.sql](../scripts/diagnostico/usuarios.sql), [profiles_limites.sql](../scripts/diagnostico/profiles_limites.sql).

## Roteiro de solução

1. Na PDB da conta, use `usuarios.sql` com `p_owner` igual ao usuário afetado; confira `ACCOUNT_STATUS`, datas, profile e se a conta é local/comum.
2. Execute `profiles_limites.sql` com `p_nome` igual ao profile encontrado; examine limites de tentativas, duração de bloqueio e expiração.
3. Identifique aplicação, pool, integração ou job que continua enviando credencial antiga. Interrompa essas tentativas antes de liberar a conta.
4. Se o bloqueio foi administrativo, confirme sua finalidade. Quando a liberação for apropriada, faça o desbloqueio pontual; se houver expiração, troque a senha pelo fluxo protegido e atualize os consumidores envolvidos.

## Confirmar a retomada

Autenticar pelo consumidor correto e acompanhar novos bloqueios no período seguinte. Não remova globalmente as regras de profile como solução de uma conta. A biblioteca fornece o diagnóstico; não há script que desbloqueie ou altere senhas em massa.

## Referências oficiais

- [ORA-28000](https://docs.oracle.com/en/error-help/db/ora-28000/).
- [ORA-28001](https://docs.oracle.com/en/error-help/db/ora-28001/).

[← Problema 01](01-conexao-listener-servico.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 03 →](03-privilegios-e-acesso-a-objetos.md)
