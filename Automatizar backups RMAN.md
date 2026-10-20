# Automatizar backups RMAN com log e controle de execução

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** Linux/19c single instance em ARCHIVELOG; um SID por rotina, sem limpeza automática.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Faça primeiro um backup e um teste de restauração manuais. O exemplo usa `oracle`, SID `ORCL`, montagem dedicada `/u04`, pasta `/u04/backup`, logs e locks privados em `/home/oracle/backup`. Ajuste todos os caminhos e confirme DBID, home, ARCHIVELOG e política RMAN. O sistema precisa de `flock` e `findmnt` (util-linux).

Crie diretórios/permissões e confirme a montagem antes de instalar a rotina. O agendador não carrega necessariamente `.bash_profile`; o ambiente deve ser explícito. TDE requer keystore disponível pelo mecanismo aprovado, sem senha embutida.

## 1. Salvar o script — oracle

Grave como `/home/oracle/backup/backup_rman.sh`, em UTF-8/LF. Substitua `EXPECTED_DBID` pelo DBID **numérico real** registrado no inventário. O marcador impede que o exemplo rode sem configuração.

```bash
#!/usr/bin/env bash
set -euo pipefail
umask 077
export ORACLE_HOME=/u01/app/oracle/product/19.3/dbhome_1
export ORACLE_SID=ORCL
export PATH="$ORACLE_HOME/bin:/usr/bin:/bin"
EXPECTED_DBID=SUBSTITUIR_DBID_NUMERICO
WORK=/home/oracle/backup

[[ "$EXPECTED_DBID" =~ ^[0-9]+$ ]] || { printf 'Configure o DBID esperado.\n' >&2; exit 64; }
[[ -d "$WORK" && -w "$WORK" ]] || { printf 'Diretorio de trabalho indisponivel.\n' >&2; exit 73; }
findmnt -rn --mountpoint /u04 --output TARGET >/dev/null
[[ -d /u04/backup && -w /u04/backup ]] || { printf 'Destino de backup indisponivel.\n' >&2; exit 73; }
exec 9>"$WORK/backup_rman.lock"
flock -n 9 || { printf 'Outra execucao ainda esta ativa.\n' >&2; exit 75; }
dbid=$("$ORACLE_HOME/bin/sqlplus" -s -L / as sysdba <<'SQL'
WHENEVER OSERROR EXIT FAILURE
WHENEVER SQLERROR EXIT FAILURE
SET HEADING OFF FEEDBACK OFF PAGESIZE 0 VERIFY OFF ECHO OFF
SELECT TO_CHAR(dbid) FROM v$database
WHERE database_role='PRIMARY' AND open_mode='READ WRITE' AND log_mode='ARCHIVELOG';
EXIT SUCCESS
SQL
)
dbid=${dbid//[[:space:]]/}
[[ "$dbid" == "$EXPECTED_DBID" ]] || { printf 'Alvo/estado do banco nao confere.\n' >&2; exit 65; }
log="$WORK/rman_$(date +%Y%m%d_%H%M%S).log"
"$ORACLE_HOME/bin/rman" target / log="$log" <<'RMAN'
BACKUP DATABASE FORMAT '/u04/backup/DB_%d_%T_%U.bkp'
  PLUS ARCHIVELOG FORMAT '/u04/backup/ARC_%d_%T_%U.bkp';
BACKUP CURRENT CONTROLFILE FORMAT '/u04/backup/CTL_%d_%T_%U.bkp';
EXIT;
RMAN
printf 'Backup concluido; confira %s\n' "$log"
```

O erro de RMAN deve resultar em código não zero; valide esse comportamento na versão instalada. O exemplo não limpa backups/archives, não gera política de retenção e não comprova cópia externa. Use o [guia RMAN](<Parametros RMAN.md>) para as configurações persistentes.

## 2. Testar antes de agendar

```bash
bash -n /home/oracle/backup/backup_rman.sh
bash /home/oracle/backup/backup_rman.sh
```

Confirme código de saída, log completo, peças, inventário e recuperação. Teste também: DBID incorreto, montagem ausente, execução concorrente e falha de RMAN, em laboratório. Nenhuma dessas condições pode terminar com mensagem de backup concluído.

## 3. Agendar uma única execução

Na crontab do usuário `oracle`, exemplo de horário local do servidor a confirmar com `timedatectl`:

```text
0 2 * * * /bin/bash /home/oracle/backup/backup_rman.sh >> /home/oracle/backup/agendador.log 2>&1
```

Não configure cron e timer para o mesmo script. `flock` protege concorrência no mesmo host/arquivo; múltiplos hosts precisam de coordenação própria. Se usar um disparador externo, ele deve observar o código de saída, registrar falha e notificar o responsável pelo canal aprovado. Cron sozinho não oferece toda essa supervisão.

## 4. Operar e retornar

Mantenha rotação/retenção de logs, monitore falhas e ausência de execução e execute testes de restore periódicos. Para retirar a automação, remova/desabilite a entrada planejada; preserve a execução em andamento até decidir sua parada por RMAN. Não apague lock/peças como tentativa de cancelar um job.

## 5. Planejar incrementais sem perder a cadeia

Uma política de incremental é alternativa à rotina full acima. Nível 0 é a base para incrementais; backup full comum não é automaticamente nível 0. Defina nível 1 diferencial ou cumulativo, arquivos de controle, SPFILE, archives e frequência segundo o ponto de recuperação e a janela disponível.

Formas RMAN para um plano previamente definido, **não acrescentar todas ao script nem agendar como uma sequência**:

```rman
BACKUP INCREMENTAL LEVEL 0 DATABASE TAG 'LAB_N0';
BACKUP INCREMENTAL LEVEL 1 DATABASE TAG 'LAB_N1_DIF';
BACKUP INCREMENTAL LEVEL 1 CUMULATIVE DATABASE TAG 'LAB_N1_CUM';
```

Cada alternativa precisa de destino configurado, proteção de archives e integração às mesmas barreiras de DBID, montagem, lock, log e erro do script. Inventarie a cadeia com LIST BACKUP e comprove restore/recover que realmente use a base e os incrementais. Não reduza a retenção pelo simples término de um nível 1. Para SBT, siga [backup OCI](<Configurar backup RMAN no OCI Object Storage.md>); a configuração de canal e chaves é própria, não uma troca de extensão do arquivo.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [rman_execucoes.sql](scripts/diagnostico/rman_execucoes.sql) — Consultar execucoes RMAN no periodo.
- [rman_em_execucao.sql](scripts/diagnostico/rman_em_execucao.sql) — Consultar operacoes RMAN ainda marcadas como running.
- [backup_pecas.sql](scripts/diagnostico/backup_pecas.sql) — Consultar pecas de backup registradas no periodo.

## Roteiros de solução de problemas

- [18 · Backup RMAN falhando ou não acontecendo](solucao-de-problemas/18-falhas-no-backup-rman.md).

## Referências oficiais

- [RMAN em linha de comando](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/)
- [Backup e recuperação](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/)
- [flock e util-linux](https://github.com/util-linux/util-linux)
