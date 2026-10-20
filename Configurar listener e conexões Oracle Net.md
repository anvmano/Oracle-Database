# Configurar listener, serviços e conexões Oracle Net

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c single instance sem Oracle Restart; listener TCP em rede de laboratório.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Confirme nome do host, IP, porta livre, home e serviço da PDB. Se Oracle Restart/RAC gerencia listener/serviços, use `srvctl` e o procedimento correspondente; não edite arquivos/duplique listeners por este roteiro. Faça backup da configuração atual e mantenha acesso local ao host.

## 1. Identificar os arquivos usados — shell oracle

```bash
printf '%s\n' "$ORACLE_HOME" "${TNS_ADMIN:-nao_definido}"
command -v lsnrctl
lsnrctl status LISTENER
lsnrctl services LISTENER
```

O status informa o arquivo de parâmetros do listener e endpoints. `TNS_ADMIN`, quando definido, pode mudar o diretório de configuração; não presuma que o arquivo ativo seja sempre `$ORACLE_HOME/network/admin/listener.ora`.

## 2. Criar ou ajustar um listener

Prefira NETCA para uma instalação nova. Exemplo de conteúdo de `listener.ora`, a adaptar ao FQDN real:

```text
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = dbsrc.example.test)(PORT = 1521))
    )
  )
```

Não substitua um arquivo compartilhado por esse bloco. Para um listener novo, use `lsnrctl start LISTENER`; para alterações suportadas com serviço ativo, avalie `lsnrctl reload LISTENER` e confira o resultado. Mudança de endereço/porta pode exigir reinício e atualização de clientes/regras de rede.

## 3. Conferir registro dos serviços — SQL*Plus

```sql
SELECT name, network_name, pdb FROM dba_services ORDER BY name;
SHOW PARAMETER local_listener
ALTER SYSTEM REGISTER;
```

Em porta padrão, o registro local pode funcionar sem `LOCAL_LISTENER` explícito. Para outra porta, configure um alias/endereço resolvível no host do banco segundo o guia e o escopo correto; teste antes de persistir. Não crie SID_LIST estática para toda conexão comum de aplicação. Registro estático pode ser necessário para auxiliary/standby e tem outro objetivo.

Para um serviço de aplicação sem Restart, crie/gerencie com `DBMS_SERVICE` no container apropriado e planeje sua partida. Não use o parâmetro `SERVICE_NAMES` como substituto universal do gerenciamento de serviços.

## 4. Configurar o cliente

Exemplo de alias em `tnsnames.ora` do **cliente**, usando o serviço efetivamente encontrado:

```text
LABPDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = dbsrc.example.test)(PORT = 1521))
    (CONNECT_DATA = (SERVICE_NAME = labpdb.example.test))
  )
```

```bash
tnsping LABPDB
sqlplus -L APP_LAB@LABPDB
```

Digite a senha no prompt. `tnsping` não valida senha, abertura da PDB nem execução SQL. Após conectar, consulte `SYS_CONTEXT('USERENV','CON_NAME')` e `SERVICE_NAME` para confirmar o destino real.

## 5. Diagnosticar e aceitar

| Erro/sintoma | Primeiro caminho de investigação |
|---|---|
| ORA-12154 | Alias, arquivo do cliente, TNS_ADMIN e métodos de resolução |
| ORA-12541 | Endpoint, listener ativo, endereço e porta |
| ORA-12514 | Nome de serviço, PDB aberta e registro no listener |
| Timeout | DNS, rota, firewall, NSG/security list e endpoint |

Confirme uma conexão real da origem autorizada e ausência de exposição desnecessária. Para retorno, restaure somente os arquivos/parâmetros modificados e reinicie/recarregue o recurso planejado, sem interromper outros consumidores do home.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [servicos_banco.sql](scripts/diagnostico/servicos_banco.sql) — Consultar servicos registrados no container.

## Roteiros de solução de problemas

- [01 · Falha de conexão, listener ou serviço](solucao-de-problemas/01-conexao-listener-servico.md).

## Referências oficiais

- [Oracle Net Services](https://docs.oracle.com/en/database/oracle/oracle-database/19/netag/)
- [DBMS_SERVICE](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SERVICE.html)
