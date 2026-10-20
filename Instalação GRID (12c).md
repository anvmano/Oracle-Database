# Instalar Grid Infrastructure 12.1 para servidor independente

[← Índice](README.md)

**Escopo:** Grid 12.1.0.2 standalone/Oracle Restart; requer adaptação certificada do armazenamento.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Roteiro histórico para **Oracle Restart/ASM 12.1.0.2**, sem RAC. Verifique SO, kernel, ASMLIB e certificação do banco que usará o ASM. Use a separação de usuários/grupos planejada: exemplos abaixo adotam proprietário `grid`, grupos `oinstall`, `asmadmin`, `asmdba` e `asmoper`, e proprietário de banco `oracle` com acesso a `asmdba`. Crie-os conforme o guia antes de continuar.

> Rotular/particionar discos é uma operação destrutiva. Identifique os volumes por serial/WWN, confira que não estão montados nem pertencem a LVM/ASM existente. Não selecione `/dev/sdb` apenas porque aparece em um exemplo.

## 1. Preparar ASMLIB e discos — root

1. Instale `oracleasm-support`, `oracleasmlib` e o componente de kernel **compatível com a versão do SO/kernel**, a partir dos repositórios Oracle. A necessidade de `kmod-oracleasm` depende do kernel; não reutilize RPMs antigos fixos de outro sistema.
2. Confira `lsblk -f`, `blkid`, `pvs` e a identidade dos discos vazios reservados.
3. Se o layout escolhido exigir partições, crie-as no dispositivo confirmado com `fdisk`/`parted`; não crie filesystem nesses dispositivos ASM.
4. Configure ASMLIB para proprietário `grid` e grupo `asmadmin`:

```bash
/usr/sbin/oracleasm configure -i
/usr/sbin/oracleasm init
/usr/sbin/oracleasm status
```

5. Para cada partição vazia confirmada, use `oracleasm createdisk ROTULO /dev/dispositivo_confirmado`. Substitua ambos os valores; não execute literalmente o dispositivo genérico.
6. Descubra e confira os rótulos:

```bash
/usr/sbin/oracleasm scandisks
/usr/sbin/oracleasm listdisks
```

## 2. Instalar Grid — grid

1. Prepare `GRID_HOME=/u01/app/12.1.0.2/grid` vazio, fora do Oracle home do banco e com proprietário/permissões de instalação conforme o guia. Prepare `ORACLE_BASE=/u01/app/grid` e o inventário compartilhado conforme a política.
2. Extraia todas as partes da mídia oficial Grid 12.1.0.2 no mesmo staging. Use os nomes efetivamente baixados, com extensão `.zip`.
3. Instale o `cvuqdisk` do diretório `rpm` da mídia como root somente quando requerido pelo guia/pré-checks da instalação.
4. Como `grid`, entre no diretório extraído `grid` e execute `./runInstaller`.
5. Selecione **Install and configure Oracle Grid Infrastructure for a Standalone Server**.
6. Crie o primeiro disk group com discos reservados, credenciais próprias e redundância coerente. **External** depende de proteção externa e não cria espelhamento ASM. **Normal/High** exigem failure groups independentes; apenas contar discos no mesmo armazenamento não garante proteção.
7. Associe OSASM a `asmadmin`, OSDBA de ASM a `asmdba` e OSOPER de ASM a `asmoper`; confira membros e permissões.
8. Confirme Grid home, base e inventário. Corrija os pré-requisitos; não use **Ignore all** para falta de memória.
9. Como root, execute os scripts exibidos: `orainstRoot.sh`, se solicitado, e **`GRID_HOME/root.sh`**, nunca o `root.sh` do home do banco.

## 3. Criar DATA e FRA — grid

Carregue o home Grid e SID `+ASM`, execute `asmca` e crie `DATA`/`FRA` com capacidade e failure groups planejados. Não reaproveite um disco já membro de outro grupo. O número de discos e a capacidade devem contemplar espaço útil após espelhamento e rebalanceamento.

## 4. Validar

No shell do proprietário Grid:

```bash
export ORACLE_HOME=/u01/app/12.1.0.2/grid
export ORACLE_SID=+ASM
export PATH="$ORACLE_HOME/bin:$PATH"
crsctl check has
crsctl stat res -t
srvctl status asm
srvctl status listener
asmcmd lsdg
sqlplus / as sysasm
```

No SQL*Plus ASM:

```sql
SELECT instance_name, status FROM v$instance;
SELECT name, state, type, total_mb, free_mb, usable_file_mb FROM v$asm_diskgroup;
SELECT name, path, header_status, mount_status, state FROM v$asm_disk ORDER BY group_number, disk_number;
SHOW PARAMETER asm_diskgroups
SHOW PARAMETER asm_power_limit
SHOW PARAMETER diagnostic_dest
```

## 5. Administração posterior

Use `srvctl` para os recursos Oracle e confira o `-help` da versão para opções. `srvctl start asm` e `srvctl start listener` iniciam recursos distintos. Para parar o Oracle Restart inteiro, root usa `crsctl stop has`; para iniciar, `crsctl start has`, depois de uma parada planejada dos bancos dependentes. Não gerencie recursos `ora.*` diretamente com `crsctl ... -init` como rotina.

No SQL*Plus ASM, exemplos administrativos independentes:

```sql
ALTER DISKGROUP DATA CHECK ALL;
ALTER DISKGROUP DATA REBALANCE POWER 4;
SELECT group_number, operation, state, power, sofar, est_work FROM v$asm_operation;
```

Adição e remoção de discos exigem planejamento de espaço/failure groups, backup e acompanhamento do rebalanceamento. `DROP DISKGROUP` e `asmcmd rm` são destrutivos; não fazem parte da instalação.

Em `asmcmd`, use `help`, `lsdg`, `lsdsk`, `lsct`, `ls`, `du`, `find` e `pwd` para inspeção. `md_backup`/`md_restore` tratam **metadados de disk groups**, não substituem backup RMAN dos dados do banco. Localize o alert log pelo ADR (`adrci`), sem presumir uma pasta fixa de outro proprietário.

## 6. Separar instalação histórica de operação atual

Para administração contínua, consulte [ASM e disk groups](<Administrar ASM e disk groups.md>) e [SRVCTL](<Operar recursos Oracle com SRVCTL.md>), que declaram cenário 19c separado. Não execute seus comandos como continuação automática desta instalação 12.1. Em coleta periódica, avalie V$ASM_DISKGROUP_STAT/V$ASM_DISK_STAT para evitar descoberta repetitiva; confirme disponibilidade e semântica na versão instalada. Operações de discos, redundância e rebalanceamento permanecem fora de um checklist de leitura.

## Referências oficiais

- [Grid 12.1 para Linux](https://docs.oracle.com/database/121/CWLIN/toc.htm)
- [Manual ASM 12.1](https://docs.oracle.com/database/121/OSTMG/toc.htm)
- [ASMLIB](https://docs.oracle.com/en/database/oracle/oracle-database/18/ladbi/administering-oracle-asmlib-and-disks.html)
