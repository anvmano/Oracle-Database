# Reverter uma RU ou RUR de Oracle Database 19c

[← Índice](README.md)

**Escopo:** Reversão planejada de patch de Database 19c, single instance.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Apesar do nome antigo deste arquivo, seu conteúdo descrevia **rollback da RU 19.5**, não instalação de RUR. RUR significa Release Update Revision; rollback é outra operação. O ID `30125133` era o exemplo de RU do acervo e não deve ser aplicado a qualquer reversão.

## 1. Confirmar o alvo antes da parada

1. Registre `"$ORACLE_HOME/OPatch/opatch" lsinventory -detail`.
2. Com cada banco aberto, registre `DBA_REGISTRY_SQLPATCH`, incluindo `PATCH_ID`, `ACTION`, `STATUS`, `ACTION_TIME` e `DESCRIPTION`. A view contém histórico; presença de um ID, isoladamente, não significa que ele está atualmente aplicado.
3. Identifique o patch ativo a remover e confira permissões, dependências e instruções de rollback no README exato.
4. Garanta backup recuperável do banco, home e inventário, preserve `.patch_storage` e planeje indisponibilidade.

## 2. Reverter

Siga a seção **Reversão** de [Aplicar RU no 19c](<Aplicar RU no Oracle 19c.md>): pare aplicações/bancos/serviços do home, execute `opatch rollback -id` com o ID confirmado, abra os bancos e PDBs no modo prescrito e conclua o rollback SQL com datapatch, quando solicitado.

Não execute consulta de banco depois de desligá-lo sem iniciá-lo de novo. Em Linux, use `OPatch` com a capitalização correta. Se houver executáveis ativos, pare seus consumidores; não use `kill -9` como rotina.

## 3. Validar

Confira ação **ROLLBACK/SUCCESS**, nível binário resultante, logs, componentes, objetos inválidos e serviços em todos os containers relevantes. Teste a aplicação e o plano de backup. Não atualize o catálogo RMAN automaticamente depois de um rollback de patch.

## Referências oficiais

- [OPatch e datapatch](https://docs.oracle.com/en/cloud/paas/base-database/update-db/index.html)
- [My Oracle Support — README e certificação do patch](https://support.oracle.com/)
