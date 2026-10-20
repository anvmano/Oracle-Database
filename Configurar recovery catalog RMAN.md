# Configurar e proteger um recovery catalog RMAN

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; catálogo em banco/PDB separado do alvo, com conta e tablespace dedicadas.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

O catálogo armazena metadados de backup; **não contém as peças nem as substitui**. Hospede-o em banco administrado e protegido separadamente do alvo. Confira a matriz de compatibilidade entre cliente RMAN, esquema do catálogo, banco que hospeda o catálogo e versão/licenciamento exigidos. Um catálogo atualizado pode deixar de aceitar clientes antigos.

## 1. Preparar o schema no banco do catálogo

Conecte ao serviço real da PDB escolhida, com administrador autorizado. Crie tablespace dedicada com OMF configurado ou path exclusivo. Exemplo somente se OMF estiver válido:

```sql
CREATE TABLESPACE RCAT DATAFILE SIZE 200M AUTOEXTEND ON NEXT 100M MAXSIZE 2G;
SET VERIFY OFF
SET ECHO OFF
ACCEPT senha CHAR PROMPT 'Senha do proprietario do catalogo: ' HIDE
CREATE USER RCAT IDENTIFIED BY "&senha" DEFAULT TABLESPACE RCAT
  TEMPORARY TABLESPACE TEMP QUOTA 2G ON RCAT;
UNDEFINE senha
GRANT RECOVERY_CATALOG_OWNER TO RCAT;
GRANT CREATE SESSION TO RCAT;
```

TEMP precisa existir e os tamanhos são exemplos. Use uma senha conforme política, sem aspas duplas que quebrem a substituição. Não instale o esquema em SYS/SYSTEM nem no banco-alvo que ele deve ajudar a recuperar.

## 2. Criar o catálogo — cliente RMAN compatível

No shell, conecte ao serviço do catálogo com senha no prompt:

```bash
rman catalog rcat@RCATPDB
```

No RMAN, confirme o banco/schema antes de criar:

```rman
CREATE CATALOG TABLESPACE RCAT;
```

`CREATE CATALOG` cria o esquema; não registra automaticamente todos os bancos. Guarde versão e logs.

## 3. Registrar um alvo

No host do banco-alvo, com SID/home corretos:

```bash
rman target / catalog rcat@RCATPDB
```

```rman
REPORT SCHEMA;
REGISTER DATABASE;
RESYNC CATALOG;
LIST INCARNATION OF DATABASE;
LIST BACKUP SUMMARY;
```

Confira o DBID do alvo e se já está registrado antes de REGISTER. O alvo pode ser protegido mesmo quando o catálogo está indisponível por um fluxo no control file, se isso estiver planejado; a ressincronização posterior precisa preservar o histórico necessário.

## 4. Operar e proteger

Faça backup independente do banco que hospeda o catálogo e mantenha cópia de sua configuração/credenciais protegidas. Documente DBIDs, conexões, retenção do control file e destinos físicos fora do catálogo. Stored scripts e virtual private catalogs têm privilégios/requisitos próprios; não compartilhe a conta proprietária com todos os operadores.

Antes de `UPGRADE CATALOG`, faça backup, confira todos os clientes consumidores e siga a confirmação exigida pela versão. Não automatize essa mudança após qualquer RU. `UNREGISTER DATABASE` remove metadados do registro, não apaga automaticamente as peças; avalie o efeito sobre recuperação/histórico antes de usar. `DROP CATALOG` é destrutivo e não é limpeza de instalação.

## 5. Validar e retornar

Execute um backup de teste conectado ao catálogo e confirme listagem/resync. Teste recuperação com o plano de indisponibilidade do catálogo e restauração do próprio catálogo em destino isolado. Para retirar um alvo, preserve inventário e plano de acesso aos backups; para desfazer uma atualização incompatível do esquema, use o backup/retorno planejado, não comandos de remoção indiscriminada.

## Referências oficiais

- [Gerenciar recovery catalog](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/managing-recovery-catalog.html)
- [CREATE CATALOG](https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/CREATE-CATALOG.html)
