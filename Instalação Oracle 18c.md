# Instalar Oracle Database 18c em Linux

[← Índice](README.md)

**Escopo:** Oracle Database 18.3 x86-64; single instance, sem RAC.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Roteiro para 18.3, single instance e armazenamento em file system. Preserve esta versão para reproduzir o laboratório histórico; confirme mídia, sistema operacional, kernel, edição e patches certificados antes de instalar. Para ASM, prepare primeiro o [Grid Infrastructure](<Instalação GRID (12c).md>) da combinação certificada; não use automaticamente Grid 12.1 para qualquer versão do banco.

Conclua a [preparação do SO](<Instalação oracle linux.md>). Dimensione memória, swap, `/tmp`, inventário, dados e FRA pelos requisitos. Corrija **todos** os pré-requisitos reprovados; não ignore falta de RAM. Se usar interface gráfica, configure X11 autenticado ou uma sessão gráfica local; não use `xhost +`.

## 1. Preparar usuário e diretórios — root

Em Oracle Linux compatível e com repositórios habilitados:

```bash
yum install oracle-database-preinstall-18c
id oracle
passwd oracle
```

O RPM configura dependências, usuário/grupos e parâmetros do kernel. Confira seu resultado e os limites em uma **nova sessão** do usuário. Se falhar, corrija a causa ou execute a configuração manual descrita no guia específico do SO; não replique números de `shmmax`, `memlock` e bibliotecas de outra plataforma.

```bash
install -d -o oracle -g oinstall -m 775 /u01/app/oracle
install -d -o oracle -g oinstall -m 775 /u01/app/oracle/product/18.3/dbhome_1
install -d -o oracle -g oinstall -m 775 /u01/app/oraInventory
install -d -o oracle -g oinstall -m 750 /home/oracle/stage
```

Esses comandos pressupõem diretórios novos e não compartilhados. Não altere recursivamente proprietário/permissões de todo `/u01`. Para separação de funções, crie e atribua os grupos conforme o guia; selecione no instalador apenas grupos que existam e aos quais o proprietário pertença. Se usar `usermod`, `-aG` preserva os grupos suplementares existentes.

## 2. Definir ambiente — oracle

Salve em `~/db_env`, substituindo `ORCL` pelo SID planejado:

```bash
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/18.3/dbhome_1
export ORACLE_SID=ORCL
export TMP=/tmp
export TMPDIR="$TMP"
export PATH="$ORACLE_HOME/bin:$PATH"
```

Carregue com `. ~/db_env`. Mantenha o arquivo pertencente a `oracle`, com modo `640`. O perfil pode carregá-lo em uma sessão dedicada ao banco. Para alternar entre homes já registrados, prefira `. oraenv`; não misture binários do Grid e do Database no mesmo ambiente.

## 3. Instalar os binários — oracle

Obtenha a mídia oficial (LINUX.X64_180000_db_home.zip) e confira seu checksum. Extraia a imagem diretamente no **Oracle home vazio**:

```bash
cd "$ORACLE_HOME"
unzip /home/oracle/stage/LINUX.X64_180000_db_home.zip
./runInstaller
```

O nome e a capitalização de `runInstaller` são significativos no Linux.

No assistente, selecione **software only**, **single instance**, a edição autorizada, `ORACLE_BASE`, o home acima e o inventário `/u01/app/oraInventory`. Associe os grupos de administração existentes, resolva os pré-requisitos e instale. Políticas de suporte/atualização são escolhas do ambiente, não etapas a desmarcar automaticamente.

Execute como root **somente os scripts e caminhos apresentados pelo instalador**, normalmente:

```bash
/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/18.3/dbhome_1/root.sh
```

O primeiro pode não ser solicitado quando o inventário já existir.

## 4. Configurar listener — oracle

```bash
"$ORACLE_HOME/bin/netca"
```

Escolha **Listener configuration → Add → LISTENER → TCP → 1521**, se a porta estiver livre, e finalize. Use o listener já gerenciado por Oracle Restart quando aplicável; não crie um segundo na mesma porta.

```bash
"$ORACLE_HOME/bin/lsnrctl" status
```

Antes de criar o banco, o listener pode ainda não mostrar serviços registrados. Para conexões remotas, configure o [firewall](<Firewall no linux.md>) e as regras da rede somente para origens autorizadas.

## 5. Criar o banco — oracle

```bash
"$ORACLE_HOME/bin/dbca"
```

1. Selecione **Create database → Advanced → Single instance → General purpose** conforme as telas da versão.
2. Defina nome global e SID. Escolha explicitamente CDB/PDB ou non-CDB segundo a aplicação e o licenciamento; em CDB, informe PDB e credenciais próprias.
3. Escolha file system e OMF, defina diretório de dados e FRA com tamanho e espaço monitorados. Para ASM, use disk groups existentes e certificados.
4. Associe o listener correto. Defina AL32UTF8 somente se compatível com a aplicação, SGA/PGA dimensionadas e modo de conexão apropriado.
5. Habilite ARCHIVELOG se o plano exigir recuperação pontual. Schemas de exemplo, Database Vault, Label Security e EM Express são opcionais; ative apenas o que for necessário e autorizado.
6. Revise credenciais, caminhos e o resumo antes de criar. Guarde logs e, se desejado, os scripts gerados pelo DBCA.

## 6. Validar e preparar operação

No SQL*Plus, como administrador local:

```sql
SELECT instance_name, status FROM v$instance;
SELECT banner FROM v$version;
SELECT name, open_mode, log_mode, cdb FROM v$database;
SELECT comp_id, version, status FROM dba_registry ORDER BY comp_id;
```

Para CDB, execute `SHOW PDBS`; abra as PDBs de aplicação e salve seu estado se essa for a política definida. Confirme registro no `lsnrctl status` e uma conexão real pelo serviço da aplicação. `tnsping` testa resolução/contato com listener, não autenticação no banco.

Configure [backup](<Informações e parâmetros de backup.md>), teste recuperação e só então prepare [inicialização automática](<script startup automatico.md>). Aplique o patch planejado conforme seu README e registre a versão final; instalar a mídia base não conclui o planejamento de atualização.

## Referências oficiais

- [Guia de instalação 18c](https://docs.oracle.com/en/database/oracle/oracle-database/18/ladbi/)
