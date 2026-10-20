# Atualizar Oracle APEX

[← Índice](README.md)

**Escopo:** Fluxo histórico de APEX 19.2; container e ORDS dependem da instalação existente.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

O material original misturava link de **APEX 19.1**, mídia **19.2** e instruções de remoção para APEX 5.0. Este roteiro histórico usa **APEX 19.2** como destino; para outra versão, use o guia integral dessa versão, incluindo compatibilidade com Oracle Database, ORDS e Java.

Identifique se o APEX está instalado em non-CDB, root ou PDB. Execute os scripts no **container de instalação correto**, conforme o guia; não aplique `apexins.sql` no root de qualquer CDB por padrão.

## 1. Inventariar e fazer backup

No container pretendido:

```sql
SHOW CON_NAME
SELECT version FROM apex_release;
SELECT comp_id, version, status FROM dba_registry WHERE comp_id='APEX';
SELECT owner, object_name, object_type FROM dba_objects WHERE status='INVALID';
```

Exporte aplicações/workspaces e arquivos relevantes, faça backup recuperável do banco/PDB e das configurações do ORDS e teste o retorno. Reserve janela, interrompa acessos da aplicação e confirme espaço em SYSAUX/TEMP e requisitos do destino.

## 2. Preparar a mídia e instalar

1. Baixe o APEX 19.2 da fonte oficial, valide o arquivo e extraia a mídia completa, por exemplo em `/home/oracle/stage/apex`.
2. Confira o caminho de imagens e o método de serviço web usados. O prefixo `/i/` precisa corresponder à configuração do servidor de imagens/ORDS.
3. Entre no diretório extraído `apex`; conecte como SYSDBA **ao container confirmado**.
4. Para o fluxo de instalação completa indicado pelo guia 19.2, execute:

```sql
SPOOL apex_upgrade.log
@apexins.sql SYSAUX SYSAUX TEMP /i/
SPOOL OFF
```

Esses três nomes de tablespace são exemplos que devem existir e ter capacidade adequada. Leia o spool/log completo e interrompa se houver falhas; o aparecimento de objetos inválidos não demonstra, por si só, que sejam resíduos da versão anterior.

## 3. Concluir a integração web

Siga os pós-passos **da versão instalada**: configuração REST quando exigida (`apex_rest_config.sql`), compatibilidade/configuração do ORDS e publicação das imagens da nova mídia. Não reutilize instruções de APEX Listener/EPG/ORDS indistintamente. Atualize a senha administrativa com a ferramenta indicada (`apxchpwd.sql`, quando aplicável) de forma interativa.

## 4. Validar e só depois limpar

Repita as consultas de versão/registro, verifique logs, acesse Administration Services, um workspace e aplicações reais. Teste autenticação, arquivos estáticos, REST, impressão e jobs usados pelo ambiente.

Liste candidatos a schemas antigos pelo procedimento oficial. Só remova um schema depois de confirmar que **não é o schema da instalação ativa**, que não há dependências relevantes e que o plano de retorno foi encerrado. Não execute `DROP USER APEX_040200 CASCADE` como passo universal de atualização. Recompile objetos aplicáveis com `utlrp.sql` e investigue os inválidos restantes por causa.

## Referências oficiais

- [Instalação APEX 19.2](https://docs.oracle.com/en/database/oracle/application-express/19.2/htmig/)
- [Pós-instalação e schemas antigos](https://docs.oracle.com/en/database/oracle/application-express/19.2/htmig/performing-post-installation-tasks-for-upgrade-installations.html)
