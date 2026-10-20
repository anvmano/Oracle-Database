# Clonar um banco com RMAN DUPLICATE

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c, backup-based duplicate para outro host isolado, sem catálogo e com OMF.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use origem ORCL e destino CLONE em hosts distintos, com mesma plataforma/versão/RU e capacidade suficiente. O clone normal recebe **outro DBID**; standby físico é outra operação. Não disponibilize ao destino mounts/ASM/FRA graváveis da origem. Não use NOFILENAMECHECK para suprimir uma verificação de sobreposição.

Prepare um conjunto completo de backups do banco/control file/SPFILE e archives que permita o ponto de clonagem. Copie para uma pasta exclusiva `/u04/incoming` do destino e confira checksums e DBID de origem. Não misture backups de bancos diferentes e não use a FRA como pasta de entrada do duplicate. TDE exige as chaves/keystore recuperáveis e o procedimento específico.

## 1. Preparar a instância auxiliar — destino

Instale o home certificado e crie diretórios vazios, privados e com espaço: `/u02/clone`, `/u03/clone_fra`. Confira que CLONE não identifica uma instância existente. Como `oracle`:

```bash
export ORACLE_HOME=/u01/app/oracle/product/19.3/dbhome_1
export ORACLE_SID=CLONE
export PATH="$ORACLE_HOME/bin:$PATH"
```

Crie **um PFILE novo**, no destino padrão `$ORACLE_HOME/dbs/initCLONE.ora`, sem sobrescrever parâmetros existentes. Exemplo para CDB, memória e FRA a dimensionar:

```ini
db_name=CLONE
db_unique_name=CLONE
control_files='/u02/clone/control01.ctl'
db_create_file_dest='/u02/clone'
db_create_online_log_dest_1='/u02/clone'
db_recovery_file_dest='/u03/clone_fra'
db_recovery_file_dest_size=8G
enable_pluggable_database=true
sga_target=2G
pga_aggregate_target=512M
```

A origem precisa ser compatível com esse contexto CDB. Em non-CDB, use a configuração adequada. Não configure DB_FILE_NAME_CONVERT/LOG_FILE_NAME_CONVERT de outro cenário junto do OMF sem revisar a precedência.

## 2. Duplicar — somente no host de destino

```bash
rman auxiliary /
```

No RMAN, confirme que a conexão é à auxiliar CLONE; **não conecte TARGET/CATALOG** neste método:

```rman
STARTUP NOMOUNT;
DUPLICATE DATABASE TO CLONE BACKUP LOCATION '/u04/incoming';
```

O RMAN reinicia a auxiliar em fases; mantenha o PFILE padrão acessível. OMF controla os novos nomes no destino planejado. A operação pode abrir o clone com RESETLOGS ao terminar; não emita outro RESETLOGS apenas por hábito. Se o conjunto estiver incompleto ou houver conflito de nome, interrompa e preserve os logs antes de tentar outra execução.

## 3. Validar isolamento e conteúdo

No clone, confirme nome, DBID **diferente da origem**, papel, modo e arquivos. Consulte control files, datafiles, tempfiles, redo, FRA, destinos de archive e parâmetros. Todos devem ser do clone, inclusive SPFILE/wallet conforme o plano.

Abra apenas as PDBs previstas, teste as tabelas/evidências e revise DB links, jobs, credenciais, e-mails e integrações antes de liberar rede/aplicações. O isolamento precisa existir desde o início: não espere o clone enviar mensagens para depois desabilitar jobs.

## 4. Variação ativa e retorno

Duplicate ativo lê a origem pela rede e exige conectividade Oracle Net, autenticação, password files e registro da auxiliar adequados; segue outro fluxo (`FROM ACTIVE DATABASE`). Não acrescente essa cláusula ao método BACKUP LOCATION. Para standby, use [Data Guard](<Criar standby fisico com Data Guard.md>).

O clone não é um teste de recuperação completo de todos os cenários. Registre ponto copiado e tempo gasto. Se falhar ou encerrar o laboratório, preserve logs e descarte apenas recursos de destino inventariados, em mudança separada. A origem deve permanecer sem alterações de arquivos/configuração por esse método.

## Referências oficiais

- [Duplicar bancos](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/rman-duplicating-databases.html)
- [DUPLICATE](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/DUPLICATE.html)
