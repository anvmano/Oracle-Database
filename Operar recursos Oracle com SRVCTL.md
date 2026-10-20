# Operar recursos Oracle com SRVCTL

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c Oracle Restart, banco single instance já registrado; comandos RAC não são intercambiáveis.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use laboratório separado com Grid/Restart instalado. Registre versão dos recursos, Grid/DB homes, DB_UNIQUE_NAME, serviços e dependências ASM/listener. Não use este guia no banco controlado apenas por systemd/dbstart. Cada recurso deve ter um único gerenciador.

Use o SRVCTL compatível com o recurso gerenciado e o proprietário autorizado. Em geral, operações de banco pertencem ao dono do DB home; operações de Grid/ASM têm contexto próprio. Confirme o manual e help locais antes de usar uma opção. Não dispare comandos concorrentes para o mesmo recurso.

## 1. Inventariar sem alterar

No DB home correto do banco registrado:

```bash
srvctl -version
srvctl config database
srvctl config database -db ORCL
srvctl status database -db ORCL
srvctl config service -db ORCL
srvctl status service -db ORCL
```

ORCL é exemplo de DB_UNIQUE_NAME, não necessariamente SID/DB_NAME. Substitua-o pelo nome retornado. No contexto Grid autorizado, confira ASM/listener e dependências. Para Restart, `crsctl check has` e `crsctl stat res -t` ajudam na inspeção; não altere recursos `ora.*` manualmente por CRSCTL.

## 2. Planejar a operação

Identifique aplicações, jobs, conexões, serviços dependentes e janela. Preserve a configuração obtida no inventário. Confira modo/papel do banco e plano de retorno. Não confunda resource enabled com estado running ou serviço disponível para a aplicação.

## 3. Executar uma parada e partida de laboratório

Após a confirmação do alvo e da janela, como dono do banco, exemplo para a base registrada ORCL:

```bash
srvctl stop database -db ORCL -stopoption IMMEDIATE
srvctl status database -db ORCL
srvctl start database -db ORCL
srvctl status database -db ORCL
```

Esses comandos interrompem o banco. Execute um de cada vez e pare no primeiro erro. O bloco representa um teste planejado, não coleta de monitoramento. IMMEDIATE pode aguardar rollback; não escale automaticamente para ABORT ou FORCE.

## 4. Validar e retornar

Valide SQL pelo serviço, OPEN_MODE, papel, PDBs previstas, listener e logs. Um retorno zero do SRVCTL não substitui o teste funcional. Se a partida falhar, confira dependências e erro; não acrescente outro serviço systemd para disputar o controle.

O retorno deve restaurar o estado operacional registrado. Remoção/recriação de recursos não faz parte do teste. RAC exige operação por instância/nó, políticas e serviços específicos, portanto não reutilize esta sequência como procedimento de failover RAC.

## Roteiros de solução de problemas

- [01 · Falha de conexão, listener ou serviço](solucao-de-problemas/01-conexao-listener-servico.md).

## Referências oficiais

- [SRVCTL 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/racad/server-control-utility-reference.html)
- [Oracle Restart](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/configuring-automatic-restart-of-an-oracle-database.html)
