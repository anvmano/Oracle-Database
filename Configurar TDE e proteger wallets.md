# Configurar TDE e proteger o keystore

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c com suporte/licenciamento adequado; laboratório non-CDB, keystore FILE novo e exclusivo.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Este exemplo usa **non-CDB de laboratório**, sem wallet anterior. Em CDB united/isolated, ASM, Data Guard ou Oracle Key Vault, siga o fluxo específico de containers e distribuição de chaves. Não aplique a uma instalação TDE existente nem copie o keystore de outro banco para substituir o atual.

Confirme edição/RU, licenciamento, backup testado e capacidade. Separe administrador de chaves e administrador de banco conforme a política. Sem senha, chaves atuais e históricas recuperáveis, dados/backup TDE podem ficar inacessíveis.

## 1. Preparar diretório e parâmetros

Como administrador do SO, crie um diretório **novo**, exclusivo do banco, com proprietário Oracle e acesso restrito, por exemplo `/u01/app/oracle/admin/ORCL/tde_wallet`. Não versione seu conteúdo.

Como administrador autorizado no non-CDB, registre valores atuais e confirme SPFILE:

```sql
SHOW PARAMETER spfile
SHOW PARAMETER wallet_root
SHOW PARAMETER tde_configuration
SELECT * FROM v$encryption_wallet;
ALTER SYSTEM SET wallet_root='/u01/app/oracle/admin/ORCL/tde_wallet' SCOPE=SPFILE;
```

Planeje reinício para o parâmetro estático. Após reiniciar e confirmar o novo WALLET_ROOT, configure:

```sql
ALTER SYSTEM SET tde_configuration='KEYSTORE_CONFIGURATION=FILE' SCOPE=BOTH;
```

O keystore TDE será tratado no subdiretório `tde`. Não altere/remova `ENCRYPTION_WALLET_LOCATION` de uma configuração existente sem o procedimento de migração; este roteiro não faz essa conversão.

## 2. Criar, abrir e gerar a primeira chave

Conecte com privilégios de gerenciamento de chaves (`SYSKM`/`ADMINISTER KEY MANAGEMENT`) conforme a política. No SQL*Plus sem spool de senha:

```sql
SET VERIFY OFF
SET ECHO OFF
ACCEPT segredo CHAR PROMPT 'Senha do novo keystore: ' HIDE
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE IDENTIFIED BY "&segredo";
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY "&segredo";
ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY "&segredo" WITH BACKUP USING 'lab_chave_inicial';
UNDEFINE segredo
```

A forma sem caminho explícito de CREATE KEYSTORE depende de WALLET_ROOT/TDE_CONFIGURATION configurados e suportados na release; confirme o diretório resultante antes de continuar. Se houver keystore prévio, interrompa em vez de sobrescrever. Defina senha própria que não quebre a substituição SQL*Plus. `OPEN_NO_MASTER_KEY`, antes de gerar a chave, não equivale a uma configuração concluída.

## 3. Criar uma área criptografada de teste

Com keystore aberto/master key válida e OMF configurado:

```sql
CREATE TABLESPACE TBS_TDE_LAB DATAFILE SIZE 100M
  AUTOEXTEND ON NEXT 100M MAXSIZE 1G
  ENCRYPTION USING 'AES256' DEFAULT STORAGE (ENCRYPT);
SELECT status, wallet_type, wrl_parameter FROM v$encryption_wallet;
SELECT key_id, creation_time, activation_time FROM v$encryption_keys;
SELECT * FROM v$encrypted_tablespaces;
```

Crie/leia dados fictícios nessa tablespace com um usuário de teste e confirme os registros criptografados de acordo com o dicionário. A consulta funcional deve funcionar sem a aplicação descriptografar manualmente.

## 4. Proteger e testar recuperação

1. Faça backup do keystore pelo comando documentado, com identificador único, além do backup RMAN e dos arquivos/configuração relevantes.
2. Guarde cópia independente, acesso restrito e senha por canal distinto. Preserve chaves históricas ao rotacionar; não substitua o arquivo por uma wallet vazia.
3. Em destino isolado, restaure dados **e** configuração/chaves e comprove leitura após abertura do keystore.
4. Auto-login (`cwallet.sso`) tem outro modelo de proteção; local auto-login fica vinculado ao host. Planeje seu uso conforme a política e não suponha que serve automaticamente para clone/standby.
5. Em reinício de teste, confira quem abre a wallet, em que fase e o que acontece com aplicações se ela ficar fechada.

## 5. Retorno e descarte

Não apague keystores nem desative TDE para simular reversão. Remoção da tablespace de teste exige confirmação de objetos/arquivos e backup conforme o plano. Descriptografar dados, migrar wallet e alterar provedor são mudanças próprias; manter o banco acessível depende das chaves mesmo após apagar um objeto de teste.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [tde_wallet_status.sql](scripts/diagnostico/tde_wallet_status.sql) — Consultar estado do keystore TDE sem exportar chaves.

## Referências oficiais

- [Configurar TDE](https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/configuring-transparent-data-encryption.html)
- [Gerenciar chaves](https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/managing-keystore-and-tde-master-encryption-key.html)
- [WALLET_ROOT](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/WALLET_ROOT.html)
