# Aplicar RUR histórico da linha 19.5

[← Índice](README.md)

**Escopo:** RUR histórico 19.5.1; detalhes do pacote dependem de acesso ao MOS.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

O texto original citava RUR `19.5.1`, patch `30446054`, de janeiro de 2020. Use esses dados somente para identificar o material histórico: a identidade, plataforma e combinação suportada precisam ser conferidas no README oficial. Este roteiro não recomenda esse nível de patch para uma instalação atual.

## 1. Conferir a base

Registre `opatch lsinventory -detail` e `DBA_REGISTRY_SQLPATCH` com ação/status/horário em todos os bancos do home. Compare a base instalada com a exigida pelo RUR exato. Uma descrição diferente não autoriza rollback automático; pode significar RU posterior, outro componente ou pacote incorreto.

## 2. Planejar e aplicar

1. Leia o README do RUR, inclusive convivência com RU, conflitos e versão mínima de OPatch.
2. Faça backup do banco/home/inventário e valide seu plano de recuperação.
3. Extraia o pacote e execute os pré-checks de conflitos/espaço.
4. Siga as etapas de parada e aplicação binária de [Aplicar RU no 19c](<Aplicar RU no Oracle 19c.md>), substituindo pelo diretório **real do RUR** e suas exigências.
5. Execute o pós-patch SQL em cada banco/PDB aplicável conforme o README. Não reverta um patch para contornar executáveis ainda ativos.

## 3. Confirmar resultado

Confira inventário, logs completos de datapatch, `DBA_REGISTRY_SQLPATCH`, objetos inválidos e conexão da aplicação. O resultado esperado é o RUR planejado registrado com sucesso; não uma string de descrição copiada do texto anterior que atribuía o mesmo ID a níveis diferentes.

## 4. Retorno

Se necessário, use a seção de reversão do guia 19c e o README desse RUR, com seu ID confirmado. Preserve outros patches instalados e valide também a reversão SQL.

## Referências oficiais

- [OPatch e datapatch](https://docs.oracle.com/en/cloud/paas/base-database/update-db/index.html)
- [My Oracle Support — README e certificação do patch](https://support.oracle.com/)
