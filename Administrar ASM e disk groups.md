# Administrar ASM e disk groups

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** Grid Infrastructure/ASM 19c, operação de grupos já existentes; laboratório separado do cenário em file system.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Confirme Grid home, SID ASM, versão/RU, redundância e failure groups. Use `grid` e autenticação SYSASM somente para administração autorizada. Este guia não instala Grid nem prepara discos. O [roteiro GRID 12c](<Instalação GRID (12c).md>) é histórico e não deve ser executado como instalação 19c.

## 1. Confirmar identidade e clientes

Carregue o ambiente real do Grid, sem reutilizar o home do banco. No shell:

```bash
asmcmd lsdg
asmcmd lsct
sqlplus / as sysasm
```

No SQL*Plus ASM:

```sql
SELECT instance_name, version, status FROM v$instance;
SELECT group_number, instance_name, db_name, status FROM v$asm_client;
```

Confira quais bancos usam os grupos antes de qualquer manutenção.

## 2. Medir capacidade e estado

Para coleta periódica, use as variantes STAT que evitam repetir descoberta de discos:

```sql
SELECT name, state, type, total_mb, free_mb,
       required_mirror_free_mb, usable_file_mb,
       ROUND(100*(total_mb-free_mb)/NULLIF(total_mb,0),2) bruto_usado_pct
FROM v$asm_diskgroup_stat ORDER BY name;
SELECT group_number, disk_number, name, mount_status, header_status,
       mode_status, state, total_mb, free_mb
FROM v$asm_disk_stat ORDER BY group_number, disk_number;
```

FREE_MB é capacidade bruta livre. USABLE_FILE_MB considera redundância e reserva de recuperação; pode ficar negativo. Grupos FLEX/EXTEND e recursos específicos exigem interpretação própria. NULL no percentual evita divisão por zero e precisa ser tratado como métrica indisponível.

V$ASM_DISK/V$ASM_DISKGROUP podem ser úteis para descoberta pontual; não são a escolha padrão para polling frequente. Capacidade de um grupo não comprova independência física dos failure groups.

## 3. Acompanhar operações

```sql
SELECT group_number, operation, state, power, actual, sofar,
       est_work, est_rate, est_minutes
FROM v$asm_operation ORDER BY group_number;
```

Correlacione com alert log ASM, I/O e estado dos discos. Nenhuma linha pode significar ausência de operação ativa; não comprova saúde de todos os discos. Ajustar POWER muda consumo de recursos e requer plano específico. Não adicione/remova disco para corrigir um alerta sem inventário de WWN, espaço e redundância.

## 4. Preservar configuração e aceitar

O `md_backup` do ASMCMD preserva metadados; execute seu help na versão e grave em destino privado com nome novo. Ele não faz backup dos datafiles nem substitui RMAN. Confirme backup recuperável dos bancos consumidores.

Aceite a coleta quando grupo, clientes, capacidade útil, redundância e operações forem coerentes com o inventário. Registre tendência conforme o [guia de capacidade](<Monitorar capacidade e crescimento do banco.md>). Encerrar as consultas não muda o ASM; manutenção de discos precisa de roteiro e retorno próprios.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [asm_capacidade.sql](scripts/diagnostico/asm_capacidade.sql) — Consultar capacidade util dos disk groups.
- [asm_discos.sql](scripts/diagnostico/asm_discos.sql) — Consultar estado e capacidade dos discos ASM.

## Roteiros de solução de problemas

- [08 · Falta de espaço permanente ou quota](solucao-de-problemas/08-espaco-permanente-e-quota.md).

## Referências oficiais

- [Views ASM](https://docs.oracle.com/en/database/oracle/oracle-database/19/ostmg/views-asm-info.html)
- [ASMCMD](https://docs.oracle.com/en/database/oracle/oracle-database/19/ostmg/manage-asm-asmcmd.html)
