# Transportar tablespaces entre bancos

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c, duas PDBs em bancos distintos, file system e mesmo endian; conjunto não criptografado de laboratório.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Este fluxo transporta datafiles de uma tablespace de aplicação e seus metadados. Confirme compatibilidade, charset, timezone, versões e suporte do recurso nas edições envolvidas. Use origem LABPDB e destino TTSDEST em outro banco/host, com discos exclusivos. Transporte entre endians, TDE e tabelas particionadas requerem procedimentos adicionais.

Defina janela sem escrita no conjunto, backup, capacidade e plano de retorno. Não transporte SYSTEM, SYSAUX, TEMP ou UNDO. Arquivos do destino devem ser cópias novas, sem referência gravável ao armazenamento da origem.

## 1. Preparar um conjunto pequeno

Crie previamente `TBS_TTS_LAB` pelo [guia de tablespaces](<Comandos sobre tablespace.md>) e conceda quota limitada a APP_LAB na origem. Como APP_LAB, com CREATE TABLE, crie um objeto ainda inexistente:

```sql
CREATE TABLE T_TTS_LAB (id NUMBER, descricao VARCHAR2(80))
  TABLESPACE TBS_TTS_LAB;
INSERT INTO T_TTS_LAB VALUES (1,'transporte de laboratorio');
COMMIT;
```

Se acrescentar índices ou constraints, confira se seus segmentos e dependências também pertencem ao conjunto. No destino, prepare o proprietário APP_LAB e seus privilégios/quotas, sem tabela T_TTS_LAB nem tablespace com o mesmo nome.

## 2. Conferir autocontenção e congelar a origem

Como administrador da PDB de origem:

```sql
EXEC DBMS_TTS.TRANSPORT_SET_CHECK('TBS_TTS_LAB',TRUE,TRUE);
SELECT * FROM transport_set_violations;
SELECT file_name FROM dba_data_files WHERE tablespace_name='TBS_TTS_LAB';
```

Resolva todas as violações e confirme a janela antes de alterar o modo:

```sql
ALTER TABLESPACE TBS_TTS_LAB READ ONLY;
```

## 3. Exportar metadados e copiar arquivos

Prepare `EXP_DUMPS` na origem conforme [EXPDP](EXPDP.md), com pasta privada, privilégios e nomes novos. No shell do cliente configurado:

```bash
expdp system@LABPDB directory=EXP_DUMPS dumpfile=tts_lab_01.dmp logfile=tts_lab_01.log transport_tablespaces=TBS_TTS_LAB transport_full_check=y
```

Confira log e código de saída. Copie o dump e **todos** os datafiles listados enquanto a origem continua READ ONLY. Compare checksums e tamanhos. Reabrir a origem antes de concluir a cópia quebra esse procedimento. Não converta endian por tentativa; aqui ambos os lados devem ter a mesma representação confirmada.

## 4. Importar no destino identificado

Prepare `IMP_DUMPS` em TTSDEST conforme [IMPDP](IMPDP.md). Exemplo de forma, com todos os paths reais copiados substituídos:

```text
impdp system@TTSDEST directory=IMP_DUMPS dumpfile=tts_lab_01.dmp
  logfile=tts_import_01.log transport_datafiles='/CAMINHO_DESTINO/ARQUIVO_REAL_01.dbf'
```

Liste todos os arquivos do conjunto, não só o primeiro. Confirme que destino e origem são bancos distintos. Não use FULL=Y como substituto do transporte selecionado.

## 5. Validar e decidir a abertura

No destino, confira datafiles, tablespace, objetos inválidos, constraints, grants e a linha id=1 de APP_LAB.T_TTS_LAB. Se o destino for de escrita, altere a tablespace para READ WRITE somente após aceitar a importação. Devolva a origem a READ WRITE conforme o plano de uso; em migração, defina qual lado pode receber novas transações para evitar divergência.

Se a importação falhar, não repita sobre um conjunto parcialmente anexado sem inventário e plano de limpeza. A origem preservada permite retornar ao serviço anterior; mudanças já aceitas no destino exigem reconciliação própria.

## Referências oficiais

- [Transporte de dados](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/transporting-data.html)
- [DBMS_TTS](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_TTS.html)
- [Data Pump Import](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/datapump-import-utility.html)
