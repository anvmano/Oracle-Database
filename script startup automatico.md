# Configurar inicialização e parada automática do banco

[← Índice](README.md)

**Escopo:** systemd, single instance sem Oracle Restart/RAC; oratab e paths a adaptar.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Exemplo para Linux com **systemd**, banco single instance em file system, usuário `oracle`, sem Oracle Restart/RAC e sem outro serviço que já controle o mesmo banco. Se houver Oracle Restart, use `srvctl` e a política correspondente. Se a instalação por RPM já fornece serviço habilitado, revise-o antes de adicionar outro.

O exemplo usa `/u01/app/oracle/product/19.3/dbhome_1`; adapte o home **em todos os campos** à instalação real. `dbstart`/`dbshut` usam `/etc/oratab`; inventarie todas as entradas marcadas `Y`, pois o script pode percorrê-las. Não crie uma unidade por SID se todas acionarem o mesmo conjunto via oratab.

## 1. Confirmar operação manual

Verifique versão, home, listener, armazenamento e credenciais locais. Como `oracle`, teste partida/parada manual em janela aprovada e confirme o resultado no banco. Não prossiga se perfis pedirem entrada interativa.

Como root, faça backup de `/etc/oratab`. Mantenha **uma única entrada** do banco e ajuste seu último campo de `N` para `Y`:

```text
ORCL:/u01/app/oracle/product/19.3/dbhome_1:Y
```

Não duplique a entrada. Se houver outras instâncias/homes em `Y`, planeje o controle conjunto antes de habilitar este serviço.

## 2. Criar uma unidade systemd — root

Salve em `/etc/systemd/system/oracle-db.service`:

```ini
[Unit]
Description=Oracle Database startup and shutdown
Wants=network-online.target
After=network-online.target local-fs.target
RequiresMountsFor=/u01/app/oracle

[Service]
Type=oneshot
RemainAfterExit=yes
User=oracle
Group=oinstall
Environment=ORACLE_HOME=/u01/app/oracle/product/19.3/dbhome_1
ExecStart=/u01/app/oracle/product/19.3/dbhome_1/bin/dbstart /u01/app/oracle/product/19.3/dbhome_1
ExecStop=/u01/app/oracle/product/19.3/dbhome_1/bin/dbshut /u01/app/oracle/product/19.3/dbhome_1
TimeoutStartSec=900
TimeoutStopSec=900

[Install]
WantedBy=multi-user.target
```

Complete `RequiresMountsFor` com **todos os pontos de montagem reais necessários** a dados, redo, control files e FRA, não apenas software. Adapte limites do usuário/serviço e os tempos de 900 segundos à carga e aos requisitos; timeout insuficiente durante shutdown pode interromper a parada. Nenhum comando de parada fica em background.

## 3. Conferir antes de habilitar

```bash
systemd-analyze verify /etc/systemd/system/oracle-db.service
systemctl daemon-reload
systemctl start oracle-db.service
systemctl status oracle-db.service
journalctl -u oracle-db.service -b
```

O estado `active (exited)` é normal para `Type=oneshot` e **não prova** que o banco está aberto: `dbstart`/`dbshut` possuem seus próprios logs e comportamento de erro. Confira `V$INSTANCE`, `V$DATABASE`, listener e alert log. Em CDB, confira as PDBs e configure o estado salvo das PDBs que devem abrir automaticamente, conforme a política.

## 4. Testar parada, boot e retorno

1. Em janela aprovada, execute `systemctl stop oracle-db.service` e confirme encerramento limpo do banco e dos serviços controlados.
2. Execute `systemctl start oracle-db.service` e repita a validação funcional.
3. Só após sucesso, habilite `systemctl enable oracle-db.service`.
4. Faça um reboot de teste planejado e confira ordem de mounts, listener, banco e PDBs. Valide também o tempo de parada.
5. Para retirar a automação, planeje o impacto e use `systemctl disable oracle-db.service`; `disable` não para uma instância já em operação.

Não use em paralelo os links SysV `dbora` do texto antigo. Caso existam, identifique quem os instalou e remova/desabilite apenas o mecanismo que estiver sendo substituído, depois de preservar a configuração e validar o novo controle.

## 5. Proteger unidade e impedir controle duplicado

Confirme proprietário root e permissão sem escrita por usuários comuns na unidade e nos diretórios que a contêm. Um arquivo root com modo 777 permite alterar o comando que será iniciado e não é aceitável. Preserve a política de execução do software e dos scripts Oracle, sem chmod recursivo no Oracle Home.

Se detectar Grid/Oracle Restart gerenciando a mesma base, interrompa a implantação desta unidade e use o [guia SRVCTL](<Operar recursos Oracle com SRVCTL.md>). Não habilite os dois gerenciadores. Teste falha de montagem e confira que a unidade não inicia antes dos volumes requeridos; estado ativo de oneshot não substitui consulta ao banco e teste do serviço da aplicação.

## Referências oficiais

- [Automatizar partida/parada Oracle](https://docs.oracle.com/en/database/oracle/oracle-database/19/unxar/stopping-and-starting-oracle-software.html)
- [Serviços systemd](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html)
- [Dependências de montagem](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html)
