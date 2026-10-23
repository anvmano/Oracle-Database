# Curadoria do acervo SQL

**Organização editorial:** 20/10/2026 · conteúdo previamente tratado, conforme informado pelo mantenedor.

A triagem do acervo privado identificou duplicatas, cadernos com assuntos misturados e arquivos de mesmo nome com conteúdos diferentes. Esses registros de origem permanecem privados; não constituem métricas reproduzíveis pelo repositório público. Igualdade de nome ou semelhança textual não foi tratada como equivalência funcional.

O resultado público é uma biblioteca de **90 tarefas**, distribuídas pelos três grupos, e um inicializador. A curadoria cobre os assuntos administrativos selecionados, sem declarar que cada arquivo do acervo privado foi integralmente auditado, corrigido ou publicado. Arquivos de acesso foram excluídos da leitura de conteúdo; binários, documentos, bibliotecas e código de aplicação não foram transformados automaticamente em SQL público.

## Decisões aplicadas

| Família encontrada | Decisão nesta biblioteca |
|---|---|
| Percentuais de I/O equivalentes | Consultas canônicas por tablespace/datafile, divisores protegidos e ressalva de contadores acumulados. |
| Espaço livre repetido por arquivo | Agregar alocado e livre no mesmo nível; preservar desconhecido em arquivos offline. |
| Cadernos com latch, Data Pump, sessões, transações, backup e comandos de alteração | Separar por objetivo; nenhuma execução conjunta do caderno. |
| Locks misturados com KILL/DISCONNECT | Diagnóstico de bloqueadores/objetos separado de intervenção local com alvo e confirmação. |
| Consultas com SID isolado ou cursor duplicado | Preservar instância/container e cursor filho; a leitura continua sendo uma fotografia dinâmica. |
| UNDO com bloco fixo de 8192 bytes | Ler o tamanho real no arquivo de UNDO; deixar NULL quando não resolvido. |
| Scheduler e DBMS_JOB | Arquivos diferentes; logs Scheduler associados por owner e nome, preservando jobs removidos. |
| SGA misturada com histórico RMAN | Separar memória e backup. |
| Grandes listas de coleta de estatísticas | Substituir por rotina de uma tabela própria, preservando estatísticas antes da coleta. |
| Recompilação em massa com erros ocultos | Uma rotina por objeto/tipo permitido, com erro propagado; gerador separado para revisão. |
| Geradores antigos de índices e grants | Usar DBMS_METADATA para objetos próprios, com CLOB e limites explícitos. |
| Texto de SQL truncado ou blocos incompletos | Não importar; consulta por SQL_ID usa GV$SQL, sem reconstruir código incompleto. |
| Usuários/senhas, DROP CASCADE, grants amplos e parâmetros ocultos | Não incorporar esses trechos. Consulta de usuários não mostra senhas ou hashes. |
| Bibliotecas externas e scripts de autores identificados | Não copiar/relicenciar automaticamente. Referenciar a origem quando necessário. |
| Scripts de aplicação, clientes, saídas reais e outros SGBDs | Manter fora da biblioteca Oracle DBA pública. |

Não foram apagados, renomeados ou fundidos arquivos da pasta de origem. A fusão ocorreu no **resultado editorial**: uma implementação por tarefa, enquanto os originais continuam privados. Não há uma meta de publicar tudo que recebeu extensão `.sql`.

## Rastreabilidade e estado

O catálogo privado preserva paths/hashes e decisões de triagem fora do Git. A biblioteca pública contém apenas objetivos genéricos, parâmetros e links aos tutoriais. O código novo segue a [licença GPLv3 do projeto](../LICENSE); isso não muda direitos sobre os originais de terceiros.

Cada arquivo publicado foi lido na revisão textual, recebeu cabeçalho e foi incluído no catálogo. O mantenedor informou que o conteúdo já foi tratado, sem necessidade de nova validação para esta publicação. O [roteiro Oracle](../tests/oracle/README.md) permanece como referência opcional. Nesta etapa foi feita organização editorial, sem execução de intervenções em banco.

Voltar à [biblioteca](README.md).

## Ampliação por assunto

A biblioteca passou a oferecer 90 tarefas em 17 assuntos, com 77 consultas, 7 intervenções e 6 geradores, mais o inicializador. Foram incorporadas informações sobre tabelas sem PK/índice, constraints e colunas de FKs, uso de índices, recyclebin, quotas, links/sinônimos, materialized views, serviços, recursos, operações longas, cursores, caches, workareas, resize de SGA, switches de redo, peças/configuração RMAN, gap, discos ASM, janelas/jobs em andamento, histórico/tarefa de estatísticas, profiles, ACL, wallet TDE, componentes, timezone e planos de cursor.

O [catálogo por assunto](CATALOGO.md) reúne todas as tarefas em um único ponto de navegação. Os SQLs continuam separados por finalidade; nenhuma tabela com links funciona como executador de todos os scripts. O conjunto disponibilizado é uma consolidação administrativa; não afirma reproduzir integralmente arquivos operacionais preenchidos, código de aplicações ou coleções de terceiros.
