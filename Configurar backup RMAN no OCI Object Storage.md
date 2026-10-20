# Configurar backup RMAN no OCI Object Storage

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c/Linux; módulo Oracle Database Cloud Backup para OCI, bucket de laboratório e RMAN SBT.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use conta OCI e bucket próprios do laboratório. Confirme compatibilidade do módulo/SO/banco, custos, região, rede de saída, proxy/TLS, capacidade e direitos de uso de criptografia/compressão. Credenciais IAM/API, wallet do módulo e keystore TDE são elementos diferentes e precisam de recuperação planejada. Não reutilize instaladores ou endpoints históricos do acervo.

Faça primeiro backup em disco e [restore isolado](<Testar restauracao completa em laboratorio.md>). Registre DBID, políticas RMAN atuais e retenção do bucket. Object Storage sozinho não fornece o módulo SBT e copiar peças com OCI CLI não é o mesmo fluxo.

## 1. Preparar IAM e software

Crie ou selecione identidade de laboratório e políticas IAM restritas ao destino necessário. Obtenha o instalador oficial do módulo OCI e confira a origem/README. Como `oracle`, prepare diretórios privados e inéditos para wallet/configuração e biblioteca, sem substituir wallet existente.

No diretório que contém o instalador oficial:

```bash
java -jar oci_install.jar
```

Leia o help dessa distribuição e confira Java e plataforma exigidos antes da instalação efetiva.

## 2. Instalar o módulo com parâmetros reais

Estrutura dos parâmetros, **não executar sem substituir e revisar todos os valores**:

```text
java -jar oci_install.jar -host https://objectstorage.REGIAO.oraclecloud.com
  -pvtKeyFile /CAMINHO_PRIVADO/CHAVE_API.pem -pubFingerPrint FINGERPRINT_REAL
  -uOCID OCID_USUARIO_REAL -tOCID OCID_TENANCY_REAL -cOCID OCID_COMPARTIMENTO_REAL
  -bucket BUCKET_LAB_REAL -walletDir /CAMINHO_PRIVADO/WALLET_NOVA
  -libDir /CAMINHO_PRIVADO/BIBLIOTECA -configFile /CAMINHO_PRIVADO/opcORCL.ora
```

A representação está em várias linhas para leitura; monte a chamada conforme o shell. Use arquivo de argumentos protegido quando indicado no help; nunca versione arquivos preenchidos. Confira o bucket explicitamente para evitar criação no local inesperado. Registre os paths efetivamente gerados, permissões e sucesso no log privado.

## 3. Testar canal e backup de escopo pequeno

No RMAN, com alvo/DBID conferidos e biblioteca/configuração reais, forma do teste:

```text
RUN {
  ALLOCATE CHANNEL c_oci DEVICE TYPE SBT
    PARMS 'SBT_LIBRARY=/CAMINHO_REAL/libopc.so,ENV=(OPC_PFILE=/CAMINHO_REAL/opcORCL.ora)';
  BACKUP CURRENT CONTROLFILE TAG 'LAB_OCI_CTL';
  RELEASE CHANNEL c_oci;
}
```

Configure a proteção criptográfica exigida pelo serviço e o método de recuperação de suas chaves antes do backup; use entrada segura, sem senha no script. Se a configuração exigir criptografia por senha/TDE, conclua esse pré-requisito conforme o manual do módulo. Não declare backup utilizável só porque o canal alocou.

## 4. Ampliar e provar recuperação

Após o teste pequeno, planeje backup do banco/archives e recuperação no [guia de automação](<Automatizar backups RMAN.md>). Confirme status RMAN e as peças no destino. Execute restore/validação via SBT em host isolado, com módulo/configuração e credenciais próprios; inclua chaves TDE quando aplicáveis. Avalie também tempo/custo de leitura da nuvem.

## 5. Operar e retirar

Alinhe retenção RMAN com lifecycle/retention rules do bucket. Não permita que lifecycle apague peças ainda necessárias à cadeia. Não exclua backups como parte do teste de instalação. Para retirar o módulo, primeiro preserve alternativas de recuperação, desative somente o agendamento correspondente e revise consumidores antes de revogar IAM/chaves ou remover arquivos.

## Roteiros de solução de problemas

- [18 · Backup RMAN falhando ou não acontecendo](solucao-de-problemas/18-falhas-no-backup-rman.md).

## Referências oficiais

- [Instalação e parâmetros do módulo OCI](https://docs.oracle.com/en/cloud/paas/db-backup-cloud/mgdbb/parameters-run-oracle-database-cloud-backup-module-oci.html)
- [Guia do serviço de backup](https://docs.oracle.com/en/cloud/paas/db-backup-cloud/)
- [Backup e recuperação RMAN](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/)
