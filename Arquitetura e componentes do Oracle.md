# Identificar a arquitetura e os componentes do Oracle

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** Database 19c single instance; consultas de inventário, sem alteração.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use o laboratório descrito em [LABORATORIO](LABORATORIO.md). Para consultar views administrativas, use uma conta autorizada; a conexão local SYSDBA é destinada ao administrador. Em CDB, confira se está no root ou em uma PDB. As consultas abaixo não exigem AWR/ASH.

## 1. Distinguir os componentes

| Componente | Papel |
|---|---|
| Instância | Memória e processos que acessam os arquivos do banco |
| Database | Estruturas persistentes: datafiles, control files e redo online |
| CDB / PDB | Container raiz e bancos conectáveis; PDB não é uma instância separada |
| Serviço | Nome lógico usado pela aplicação para se conectar |
| SID | Identificador local da instância; não é sinônimo universal de serviço |
| Oracle home | Diretório dos binários; não é o diretório dos dados |
| SGA / PGA | Memória compartilhada da instância e memória privada dos processos |
| FRA | Área gerenciada para arquivos de recuperação; capacidade deve ser monitorada |

## 2. Identificar instância, banco e container — SQL*Plus

```sql
SELECT instance_name, host_name, version, status, startup_time FROM v$instance;
SELECT name, dbid, db_unique_name, database_role, open_mode, log_mode, cdb FROM v$database;
SHOW CON_NAME
SHOW PARAMETER spfile
SHOW PARAMETER db_create_file_dest
```

Registre nome/DBID, papel e home antes de executar qualquer outro guia. Um banco montado ou standby tem capacidades de consulta/operação diferentes de um primário READ WRITE.

## 3. Identificar arquivos e serviços

```sql
SELECT name FROM v$controlfile;
SELECT file#, name FROM v$datafile ORDER BY file#;
SELECT file#, name FROM v$tempfile ORDER BY file#;
SELECT group#, member FROM v$logfile ORDER BY group#, member;
SELECT name, network_name, pdb FROM dba_services ORDER BY name;
```

Em root, a visão de arquivos pode abranger containers; use `CON_ID`/views CDB quando precisar separar proprietários. Tempfiles são diferentes de datafiles e não seguem a mesma restauração RMAN.

## 4. Inspecionar processos e memória

```sql
SELECT name, description FROM v$bgprocess WHERE paddr <> '00' ORDER BY name;
SELECT name, bytes FROM v$sgainfo ORDER BY name;
SELECT name, value, unit FROM v$pgastat ORDER BY name;
SHOW PARAMETER memory_target
SHOW PARAMETER sga_target
SHOW PARAMETER pga_aggregate_target
```

Views mostram medidas e limites distintos; não some alocações como se todas fossem consumo residente do SO. Relacione os resultados com `free`, `ps` e [monitoramento do SO](<Script monitorar SO.md>).

## 5. Validar o inventário

Confirme que SID/home, banco/DBID, serviços, arquivos e containers correspondem ao cenário esperado. Guarde o inventário em local privado; paths e nomes internos não devem ser publicados como dados reais. Este guia não muda parâmetros e não requer reversão. Se algo divergir, identifique o ambiente antes de seguir para criação, patch ou recuperação.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [identidade_banco.sql](scripts/diagnostico/identidade_banco.sql) — Confirmar identidade, papel, abertura e container.
- [parametros_instancia.sql](scripts/diagnostico/parametros_instancia.sql) — Consultar parametros suportados modificados ou selecionados.

## Referências oficiais

- [Conceitos](https://docs.oracle.com/en/database/oracle/oracle-database/19/cncpt/)
- [Referência de views e parâmetros](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/)
