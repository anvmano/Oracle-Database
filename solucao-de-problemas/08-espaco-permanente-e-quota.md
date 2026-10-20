# 08 · Falta de espaço permanente ou quota

[← Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Preparação comum](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) · [Catálogo de scripts](../scripts/CATALOGO.md)

**Escopo:** administração Oracle Database 19c; roteiro específico apoiado nos arquivos do projeto.  
**Organização editorial:** 20/10/2026 · conteúdo dos scripts considerado previamente tratado pelo mantenedor.

## Antes de começar

Siga o [roteiro comum de atendimento](../SOLUCAO_DE_PROBLEMAS.md#roteiro-comum-de-atendimento) e a [preparação dos parâmetros](../SOLUCAO_DE_PROBLEMAS.md#preparar-uma-investigação-com-a-biblioteca). Os caminhos de execução dos scripts partem da raiz do projeto. Escolha a conexão, o container e a instância correspondentes ao caso.

## Sintomas e identificação

ORA-01653/01654 apontam falha de expansão de segmento; ORA-01950/01536 direcionam para quota. Autoextend configurado não garante espaço no armazenamento.

## Arquivos do projeto

[tablespaces](<../Comandos sobre tablespace.md>), [capacidade e crescimento](<../Monitorar capacidade e crescimento do banco.md>), [tablespaces_uso.sql](../scripts/diagnostico/tablespaces_uso.sql), [datafiles_uso.sql](../scripts/diagnostico/datafiles_uso.sql), [segmentos_maiores.sql](../scripts/diagnostico/segmentos_maiores.sql), [quotas_tablespaces.sql](../scripts/diagnostico/quotas_tablespaces.sql), [ASM](<../Administrar ASM e disk groups.md>).

## Roteiro de solução

1. Extraia da mensagem o segmento e a tablespace; confira se a falha é de capacidade ou quota.
2. Compare alocado, livre, teto e estado dos arquivos. Valores desconhecidos em arquivo offline não são espaço zero. Em `segmentos_maiores.sql`, `p_nome` é segmento exato, não tablespace.
3. Confira espaço físico no filesystem/ASM e crescimento de outros bancos no mesmo armazenamento. Para quota, consulte o usuário afetado e os privilégios relacionados.
4. Escolha a correção: quota delimitada quando essa for a restrição; expansão suportada do arquivo/tablespace e armazenamento quando a carga legítima precisar. Bigfile não aceita segundo datafile; respeite o tipo e os limites.
5. Se houver crescimento anormal, trate sua origem e a retenção dos dados com o responsável. Não apague datafiles nem segmentos para liberar espaço sem decisão sobre os dados.

## Confirmar a retomada

A operação consegue alocar espaço e o crescimento deixa margem compatível com a carga. Aumentar quota não amplia disco, e ampliar arquivo não corrige falta de quota.

## Referências oficiais

- [ORA-01653](https://docs.oracle.com/en/error-help/db/ora-01653/).
- [ORA-01950](https://docs.oracle.com/en/error-help/db/ora-01950/).
- [ORA-01536](https://docs.oracle.com/en/error-help/db/ora-01536/).

[← Problema 07](07-estatisticas-e-regressao-de-plano.md) · [Índice dos 20 problemas](../SOLUCAO_DE_PROBLEMAS.md) · [Problema 09 →](09-espaco-temporario.md)
