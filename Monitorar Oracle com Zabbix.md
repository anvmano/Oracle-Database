# Monitorar Oracle com Zabbix

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** Oracle 19c single instance e Zabbix 7.0 Agent 2; serviço de laboratório e integração versionada.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use um servidor Zabbix já operacional e um host de coleta separado por função. Registre versões exatas do servidor, agente, plugin e template; não combine arquivos de branches diferentes. O template oficial consulta ASH: confirme direitos de uso antes de vinculá-lo. Sem esses direitos, use coleta própria revisada sem consultas dos packs, baseada no [checklist](<Checklist diario do banco Oracle.md>).

Defina serviço do banco, porta, acesso da rede e conta dedicada `ZBX_MON`. Não use SYS/SYSTEM nem execute o agente como proprietário Oracle para contornar privilégios. Em CDB, escolha explicitamente coleta de instância/root ou PDB; um serviço de PDB não representa automaticamente toda a CDB.

## 1. Preparar a coleta

Obtenha agente e dependências no repositório oficial compatível com o SO/arquitetura. Confira as instruções do plugin Oracle da versão 7.0 instalada. No host do agente:

```bash
zabbix_agent2 -V
systemctl status zabbix-agent2
```

Teste resolução e conexão ao serviço a partir desse host. Crie a conta local conforme o [guia de usuários](<User _ Profile _ Roles _ Grants.md>). Revise os grants do template 7.0 selecionado e conceda somente os acessos que seus itens exigem; uma conta mínima de ping não atende todas as métricas do template.

## 2. Configurar uma sessão nomeada

Em arquivo incluído pelo `zabbix_agent2.conf`, exemplo de configuração **incompleto até preencher a senha localmente**:

```ini
Plugins.Oracle.Sessions.lab.Uri=tcp://dbsrc.example.test:1521
Plugins.Oracle.Sessions.lab.Service=LABPDB
Plugins.Oracle.Sessions.lab.User=ZBX_MON
Plugins.Oracle.Sessions.lab.Password=<PREENCHER_LOCALMENTE_FORA_DO_GIT>
```

O serviço é um SERVICE_NAME, não o SID. Restrinja arquivo/diretório ao administrador e ao usuário do agente, por exemplo root:zabbix e 0640 quando apropriado à instalação. Não use 777. Proteja também o transporte agente/servidor e Oracle Net conforme a política; TCP sozinho não configura TLS.

## 3. Validar o item antes do template

Depois de validar a configuração e reiniciar o agente na janela prevista:

```bash
zabbix_agent2 -t 'oracle.ping[lab]' -c /etc/zabbix/zabbix_agent2.conf
```

Confira o valor de ping e o tipo retornado, logs e ausência de erro de conexão. No host Zabbix, configure interface, nome do host e acesso à sessão `lab`; vincule o template 7.0 e ajuste a macro de conexão para a sessão nomeada. Revise macros de usuário/serviço para não sobrescrever a sessão com valores de outro ambiente.

## 4. Aceitar e acompanhar

Confira Latest data, itens não suportados, coleta recente, unidade e atraso. Compare disponibilidade, sessões, tablespaces, FRA e backup com consultas manuais. Defina limites por capacidade e janela de negócio; ausência de coleta deve gerar problema, não consumo zero. Valide uma falha de conexão controlada sem desligar um banco de produção.

## 5. Retirar a integração

Desabilite a coleta no host antes de retirar sessão/credencial. Preserve histórico necessário e revogue apenas os grants exclusivos dessa integração. O agente pode atender outros serviços: confirme consumidores antes de pará-lo ou removê-lo.

## Referências oficiais

- [Integração e templates Oracle](https://www.zabbix.com/integrations/oracle)
- [Plugin Oracle 7.0](https://www.zabbix.com/documentation/7.0/en/manual/appendix/config/zabbix_agent2_plugins/oracle_plugin)
- [Packs Oracle](https://docs.oracle.com/en/database/oracle/oracle-database/19/dblic/Licensing-Information.html)
