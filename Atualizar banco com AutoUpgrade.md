# Atualizar um banco com AutoUpgrade

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 12.1.0.2 → 19c, mesma plataforma e proprietário; análise e implantação separadas.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Confirme caminho de upgrade suportado, RU do destino, SO, Java exigido pelo JAR, componentes e compatibilidade da aplicação. O AutoUpgrade recebe atualizações próprias: obtenha a versão oficial indicada pela Oracle, confira versão/checksum e guarde o JAR usado. Não trate o JAR embutido em uma mídia antiga como automaticamente atual.

Prepare backup recuperável/testado de banco, home, configuração e wallets, janela e plano de retorno. Este roteiro não combina mudança de plataforma, conversão non-CDB → PDB, RAC ou Data Guard; cada uma exige configuração e plano específicos. Leia também [o roteiro de upgrade histórico](<Upgrade do oracle 12c para 19.3.md>).

## 1. Preparar destino e ferramenta

Instale software 19c em home separado e aplique o patch certificado de destino, sem criar um banco sobre o existente. Como proprietário, com o Java compatível selecionado:

```bash
java -version
java -jar /home/oracle/tools/autoupgrade.jar -version
java -jar /home/oracle/tools/autoupgrade.jar -help
```

Use o mesmo JAR/configuração controlados entre análise, correções e implantação. O uso de um `java` diferente após mudar PATH precisa ser validado.

## 2. Criar configuração

Arquivo privado `/home/oracle/tools/upgrade_orcl.cfg`, com valores reais:

```ini
global.autoupg_log_dir=/u04/autoupgrade_logs
upg1.dbname=ORCL
upg1.sid=ORCL
upg1.source_home=/u01/app/oracle/product/12.1.0.2/db_1
upg1.target_home=/u01/app/oracle/product/19.3/dbhome_1
upg1.log_dir=/u04/autoupgrade_logs/ORCL
upg1.start_time=NOW
```

Confirme permissões, montagens, espaço e identidade do banco. Os parâmetros de recuperação, restore points, elevação de COMPATIBLE e conversões devem ser revisados no guia da versão **antes** de deploy; não presuma seus defaults como política de retorno.

## 3. Analisar e corrigir

```bash
java -jar /home/oracle/tools/autoupgrade.jar -config /home/oracle/tools/upgrade_orcl.cfg -mode analyze
```

Leia todos os relatórios gerados e resolva cada bloqueio/aviso aplicável. Registre o que precisa de correção manual. A análise verifica prontidão, não executa o upgrade.

Quando as correções automáticas forem apropriadas e a mudança estiver preparada:

```bash
java -jar /home/oracle/tools/autoupgrade.jar -config /home/oracle/tools/upgrade_orcl.cfg -mode fixups
```

Fixups **podem alterar a origem**; não são outra análise sem efeito. Leia logs e repita analyze até cumprir os critérios de prontidão. Não avance apenas porque o processo retornou ao shell.

## 4. Implantar na janela aprovada

Pare consumidores conforme o plano, confirme backup/retorno e capacidade de recuperação. Então:

```bash
java -jar /home/oracle/tools/autoupgrade.jar -config /home/oracle/tools/upgrade_orcl.cfg -mode deploy
```

Acompanhe o console/logs e use comandos da versão para status dos jobs. Não execute em paralelo DBUA, um segundo deploy ou scripts de upgrade manual sobre o mesmo banco. Se houver falha, preserve o job e os logs para retomar pelo mecanismo suportado; apagar diretórios de controle não é uma correção.

## 5. Validar e retornar quando necessário

Confirme conclusão de todas as fases, versão/RU, registro SQL de patches, componentes, PDBs, objetos inválidos, timezone, listener, serviços e aplicação. Compare desempenho/carga com a base anterior e confirme atualização de oratab/perfis/automação para o novo home. Faça backup pós-upgrade e documente aceitação.

A opção `-restore -jobs JOB_CONFIRMADO` só deve ser usada se a versão/cenário oferecem os meios de restauração necessários e o impacto foi aceito. Elevar COMPATIBLE ou remover informações/restore points de recuperação pode retirar opções de retorno. Não basta trocar ORACLE_HOME para desfazer alterações nos dados. Mantenha o backup independente mesmo quando o AutoUpgrade oferece restauração automatizada.

## Referências oficiais

- [Parâmetros AutoUpgrade](https://docs.oracle.com/en/database/oracle/oracle-database/19/upgrd/autoupgrade-command-line-parameters.html)
- [Modos de processamento](https://docs.oracle.com/en/database/oracle/oracle-database/19/upgrd/about-autoupgrade-processing-modes.html)
- [Upgrade direto](https://docs.oracle.com/en/database/oracle/oracle-database/19/upgrd/oracle-database-releases-that-support-direct-upgrade.html)
