# Atualizar Oracle Database 12.1.0.2 para 19c

[← Índice](README.md)

**Escopo:** 12.1.0.2 → 19c por DBUA, mesma plataforma; requer homologação no ambiente.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

O upgrade direto deste roteiro parte de **12.1.0.2**, não de qualquer versão chamada 12c. Confirme o caminho suportado, SO, arquitetura, edição, componentes, patches exigidos e compatibilidade da aplicação. O destino original era a mídia 19.3; planeje também a RU certificada do destino. Este roteiro mantém DBUA como método histórico. AutoUpgrade é outro método, com fluxo próprio; não misture suas etapas.

RAC, Data Guard, mudança de plataforma e conversão non-CDB → PDB exigem planos adicionais. O upgrade de versão não deve ser confundido com a aplicação de RU.

## 1. Preparar retorno e instalar o novo home

1. Faça backup consistente/recuperável do banco, archivelogs, control files, SPFILE/PFILE, password file, configurações e wallets/chaves. Teste restauração em ambiente isolado.
2. Registre versão, componentes, objetos inválidos, character set, timezone, tamanho, serviços e dependências de aplicações/jobs.
3. Defina janela, critérios de aceitação e de retorno. Flashback/restore point só é opção se os pré-requisitos e o espaço estiverem garantidos; não substitui um plano de recuperação validado.
4. Instale o software 19c em **outro Oracle home**, seguindo [Instalação 19c](<Instalação Oracle 19c.md>), sem criar um banco novo sobre o existente.
5. Aplique a RU de destino e as exigências do upgrade conforme o pacote/guia. Evite atualizar o SO indiscriminadamente na mesma janela; valide a combinação antes.

Exemplos de caminhos usados daqui em diante:

```bash
OLD_HOME=/u01/app/oracle/product/12.1.0.2/db_1
NEW_HOME=/u01/app/oracle/product/19.3/dbhome_1
export ORACLE_SID=ORCL
export ORACLE_HOME="$OLD_HOME"
export PATH="$OLD_HOME/bin:$PATH"
```

Adapte o SID e os caminhos ao banco existente. Os dois homes devem ter o proprietário compatível com o método DBUA.

## 2. Executar análise de pré-upgrade

Com o banco de origem em operação e ambiente apontado ao **home antigo**, use a ferramenta de pré-upgrade correspondente ao destino. No fluxo histórico, se `preupgrade.jar` estiver disponível no destino:

```bash
"$OLD_HOME/jdk/bin/java" -jar "$NEW_HOME/rdbms/admin/preupgrade.jar" TERMINAL TEXT
```

Se a mídia/RU não fornecer essa ferramenta, obtenha a versão e o método suportados indicados pelo guia Oracle; não invente o caminho do JAR. Leia o log inteiro e os caminhos dos fixups que a ferramenta efetivamente gerar. Não copie o SID pessoal do exemplo antigo.

Conecte ao banco de origem com SQL*Plus e execute `@CAMINHO_REAL/preupgrade_fixups.sql`, substituindo o marcador. Corrija **todas** as pendências não resolvidas automaticamente. Uma mensagem `PL/SQL procedure successfully completed` não significa que os checks passaram. Refaça a análise até cumprir os critérios do guia para prosseguir.

## 3. Executar DBUA — oracle

Pare aplicações/jobs e consumidores conforme o plano; não provoque uma parada adicional do banco fora da ordem exigida pelo DBUA. Carregue o ambiente do destino e execute:

```bash
export ORACLE_HOME="$NEW_HOME"
export PATH="$NEW_HOME/bin:$PATH"
"$NEW_HOME/bin/dbua"
```

1. Selecione **o banco de origem correto** e confira SID/home antigo.
2. Resolva os pré-checks. Defina recompilação, paralelismo e opções conforme a capacidade e a janela; não marque todas as opções sem avaliar.
3. Escolha recuperação com RMAN, flashback ou plano próprio **já testado**. Confirme espaço e localização dos arquivos.
4. Selecione listener/serviços e configuração de gerenciamento apropriados.
5. Revise o resumo e execute. Guarde logs, progresso e resultado final; não encerre por uma mensagem isolada de sucesso.

## 4. Concluir e verificar

No SQL*Plus do destino, execute o `postupgrade_fixups.sql` no caminho real gerado e resolva erros restantes. Para tabelas dependentes de tipos mantidos pela Oracle:

```sql
SELECT DISTINCT owner, table_name
FROM dba_tab_cols
WHERE data_upgraded = 'NO'
ORDER BY owner, table_name;
```

Se houver tabelas aplicáveis, siga o guia para `@?/rdbms/admin/utluptabdata.sql`, avaliando impacto e janela, e repita a consulta. Execute `@?/rdbms/admin/utlrp.sql` quando indicado e confira:

```sql
SELECT banner FROM v$version;
SELECT comp_id, version, status FROM dba_registry ORDER BY comp_id;
SELECT owner, object_type, COUNT(*) FROM dba_objects
WHERE status='INVALID' GROUP BY owner, object_type;
SELECT name, open_mode, log_mode FROM v$database;
SELECT patch_id, action, status, action_time, description
FROM dba_registry_sqlpatch ORDER BY action_time;
```

Em CDB, verifique o resultado em todos os containers previstos. Atualize `/etc/oratab`, perfis, serviços e scripts para o novo **Database home**; `GRID_HOME` continua apontando ao Grid real e não deve ser substituído pelo home do banco.

Teste autenticação, jobs, integrações, desempenho e aplicação. Confirme listener e backup pós-upgrade. Não eleve `COMPATIBLE` nem remova o home antigo/restore point antes da aceitação e da revisão das consequências para retorno. Voltar o `ORACLE_HOME` no perfil, sozinho, não desfaz o upgrade dos dados.

## Referências oficiais

- [Caminhos de upgrade direto](https://docs.oracle.com/en/database/oracle/oracle-database/19/upgrd/oracle-database-releases-that-support-direct-upgrade.html)
- [Ferramenta de pré-upgrade](https://docs.oracle.com/en/database/oracle/oracle-database/19/upgrd/using-preupgrade-information-tool-for-oracle-database.html)
- [Tabelas após upgrade](https://docs.oracle.com/en/database/oracle/oracle-database/19/spuss/upgrading-tables-dependent-on-oracle-maintained-types.html)
