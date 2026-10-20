# Cenário de laboratório dos novos guias

[← Índice](README.md) · [Contribuição](CONTRIBUTING.md)

**Estado:** referência de planejamento; máquinas, dados e serviços não foram criados ou homologados nesta revisão.

## 1. Plataforma de referência

Os novos exercícios de banco usam Oracle Database **19c single instance x86-64**, com RU exata registrada por quem executar. Escolha Oracle Linux/kernel certificados para a combinação; não copie a seleção histórica de OL7 sem verificar. Confirme edição/licenciamento para Multitenant, TDE, Data Guard e quaisquer packs. SQL*Plus, RMAN e auxiliares devem ser compatíveis com o alvo.

O cenário base usa file system, sem RAC/ASM. Os guias de operação ASM e SRVCTL usam um ambiente 19c com Grid/Restart já instalado, separado do cenário base. Statspack, LogMiner e AWR/ASH declaram non-CDB isolado; não são passos a executar automaticamente na LABPDB. Alguns recursos têm arquitetura própria: TDE foi descrito para non-CDB separado, recovery catalog fica em PDB/banco separado e AutoUpgrade parte de 12.1.0.2. Esses cenários não devem ser executados todos sobre a mesma instância como se fossem passos cumulativos.

## 2. Nomes fictícios e topologia

| Papel | Nome/IP de documentação | Identidade do banco |
|---|---|---|
| Origem | dbsrc.example.test / 192.0.2.10 | DB_NAME ORCL; SID ORCL; CDB com LABPDB |
| Clone/restore isolado | dbclone.example.test / 192.0.2.20 | CLONE para duplicate; ORCL_RESTORE como DB_UNIQUE_NAME no restore |
| Standby | dbstby.example.test / 192.0.2.30 | DB_NAME ORCL; DB_UNIQUE_NAME ORCL_STB |
| Primário Data Guard | dbsrc.example.test | DB_UNIQUE_NAME ORCL_PRI, configurado explicitamente |
| Catálogo | host/banco de catálogo separado | Serviço RCATPDB; schema RCAT |
| Serviço web | host/usuário ORDS separados conforme o plano | ORDS 25.3 + Java/APEX compatíveis |

Endereços acima não devem ser usados como IPs reais. Defina DNS/hosts e serviços reais antes de conectar. Nenhuma máquina de restore/clone pode ter acesso gravável aos volumes da origem. Para teste de aplicação, restrinja saída para impedir jobs, e-mails e integrações não desejados.

## 3. Diretórios de referência

| Uso | Exemplo |
|---|---|
| Software 19c | `/u01/app/oracle/product/19.3/dbhome_1` |
| Dados OMF da origem | `/u02/oradata` |
| FRA da origem | `/u03/fra` |
| Montagem de backup | `/u04`, com pasta `/u04/backup` |
| Entrada de peças no destino | `/u04/incoming`, apenas no host de destino |
| Restore isolado | `/u02/restore` e `/u03/restore_fra` |
| Clone isolado | `/u02/clone` e `/u03/clone_fra` |
| Standby | `/u02/standby` e `/u03/standby_fra` |

Esses destinos diferem de exemplos históricos em `/u01` ou `/u02/backup`; adapte o guia inteiro de forma consistente. Crie/monte os volumes e confira capacidade, dono, permissões e identidade antes de usar qualquer caminho. OMF só deve ser presumido depois de confirmar `DB_CREATE_FILE_DEST` e o destino físico. Redo/control files também precisam de destino planejado.

## 4. Dimensionar antes da execução

Registre CPU/RAM, SGA/PGA, swap, software, dados, TEMP, FRA, backups e espaço de operações auxiliares conforme requisitos e carga. Cada host de restauração/standby pode precisar de capacidade próxima ao banco inteiro, além das peças. Os números de um exemplo de PFILE não constituem dimensionamento universal.

Registre versão, edição e patches, DBID, nomes/serviços, arquivos e histórico de mudanças num inventário privado. Não coloque senhas, wallets, dumps, logs ou dados reais neste repositório. Uma cópia de VM/snapshot não dispensa teste de backup/restore do banco.

## 5. Conta de aplicação de teste

Na LABPDB, crie `APP_LAB` pelo [guia de usuários](<User _ Profile _ Roles _ Grants.md>), com senha própria, CREATE SESSION, quota limitada e apenas os privilégios de criação necessários aos exercícios (tabelas, procedimentos, jobs). Não dê DBA ao schema para contornar falta de privilégio. Verifique a tablespace padrão/temporária existentes e o serviço de conexão.

Os objetos `T_PLANO_LAB`, `T_RESTORE_LAB`, `T_JOB_LAB`, `T_AUDIT_LAB` e `STATS_BKP` são novos, fictícios e criados nos respectivos guias. Se já existirem, inventarie-os antes de executar; não substitua silenciosamente. Contas administrativas e de auditoria/chaves devem ser separadas conforme a política.

## 6. Critérios mínimos de aceitação

Antes de registrar um guia como testado: confirme identidade/contexto, execução nominal, falha relevante, resultado funcional e retorno/limpeza planejados. Para recuperação, comprove os dados no ponto esperado e meça o tempo. Para Data Guard, comprove transporte/apply e troca de papéis planejada. Para TDE, comprove restauração das chaves/dados em destino isolado.

Ao encerrar, preserve evidências e remova apenas recursos inventariados do laboratório em uma mudança própria. Confirme a capacidade de recuperação da origem antes de excluir qualquer cópia.

## 7. Cenários operacionais adicionais

Zabbix requer servidor/agente e template compatíveis, identidade de monitoramento própria e conferência de direitos para os itens coletados. Backup em Object Storage requer identidade/bucket OCI e proteção de wallet/chaves. Transportable tablespaces e database links usam uma segunda base independente com serviço explicitamente configurado. Nomes de endpoints `example.test` são fictícios e precisam de resolução para hosts controlados no laboratório.

Os guias de SQL, PL/SQL, LOB e transporte criam somente objetos próprios com nomes T_SQL_DBA_LAB, P_LAB_CONTAR_OBJETOS, T_LOB_DBA_LAB e T_TTS_LAB. Confira existência antes de criar; não substitua objetos de outro exercício. Nenhum cenário importa dados, relatórios ou senhas do acervo profissional. Cada guia declara pré-condições, alterações e limites de retorno; modelos de documentação de clientes não integram esta expansão.

## Referências oficiais

- [Instalação 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/ladbi/)
- [Licenciamento 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/dblic/)
- [Oracle Linux](https://docs.oracle.com/en/operating-systems/oracle-linux/)
