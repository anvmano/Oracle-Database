# Aplicar Bundle Patch em Oracle Database 12.1

[← Índice](README.md)

**Escopo:** Bundle Patch de Database 12.1.0.2; composição exata depende do pacote oficial.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## 1. Identificar o bundle correto

Este acervo citava `29698629` com subdiretórios `29509318` e `29496791`. Esses números são **referências históricas do texto original**, não uma confirmação de componentes, plataforma ou ordem para o seu ambiente. Confira os IDs e a relação entre componentes no README do pacote oficial que você efetivamente baixou.

## 2. Preparar a mudança

Siga o [procedimento completo de aplicação/reversão 12.1](<upgrade-rollback de patch (12cr1).md>): registre inventário/SQL patch, faça backup recuperável, confira OPatch, espaço e conflitos antes de parar os consumidores do home.

Para bundles, crie um arquivo de lista **com os caminhos dos subpatches indicados pelo README** e execute o pré-check de espaço conforme a sintaxe prescrita. Não execute duas vezes a mesma verificação em diretórios que só diferem por `Opatch`/`OPatch`: no Linux, o nome correto da ferramenta é `OPatch`.

## 3. Aplicar cada componente e alterações SQL

1. Pare todos os bancos e serviços afetados de forma ordenada.
2. Execute `"$ORACLE_HOME/OPatch/opatch" apply` em cada diretório exigido, na ordem do README. Não aplique somente um subdiretório por suposição.
3. Confira inventário e logs antes de iniciar a etapa SQL.
4. Inicie cada banco e abra as PDBs conforme o modo solicitado pelo patch; execute `"$ORACLE_HOME/OPatch/datapatch" -verbose` quando houver componente SQL.
5. Não execute `catbundle.sql` para tentar resolver objetos inválidos. Recompile com `utlrp.sql` quando indicado e investigue os erros restantes.

## 4. Validar ou reverter

Confira inventário binário e `DBA_REGISTRY_SQLPATCH` em cada container aplicável, incluindo ação, status e horário. Teste a aplicação e restabeleça o listener com `lsnrctl start`. Rollback **não é um pré-requisito universal** de aplicação de um bundle; faça-o somente se determinado pelo conflito/README ou pelo plano de retorno, seguindo a seção de reversão do guia principal.

## Referências oficiais

- [OPatch e datapatch](https://docs.oracle.com/en/cloud/paas/base-database/update-db/index.html)
- [My Oracle Support — README e certificação do patch](https://support.oracle.com/)
