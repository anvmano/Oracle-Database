# Inventariar recursos e packs Oracle

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; inventário técnico para revisão administrativa, sem conclusão contratual automatizada.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Confirme versão, edição, RU, plataforma, virtualização, serviços contratados e topologia. A disponibilidade de uma opção no software não demonstra direito de uso. Uma view sem ocorrências também não comprova ausência histórica de utilização. Registre a interpretação com quem administra os contratos; este guia coleta sinais técnicos.

Use conta administrativa autorizada e repositório privado para resultados. Em CDB, declare o container e o alcance de cada consulta. Não copie limites de slides antigos nem habilite packs para testar se a instalação os possui.

## 1. Identificar o software

```sql
SELECT banner_full FROM v$version;
SELECT name, dbid, db_unique_name, cdb, database_role FROM v$database;
SELECT instance_name, version, host_name FROM v$instance;
SELECT parameter, value FROM v$option ORDER BY parameter;
```

V$OPTION informa disponibilidade no software, não contrato, uso efetivo ou direito de acesso. Registre DBID e período privadamente; não publique inventário de um cliente no Git.

## 2. Examinar configuração e indicadores

```sql
SELECT name, value FROM v$parameter
WHERE name='control_management_pack_access';
SELECT name, detected_usages, currently_used, first_usage_date, last_usage_date
FROM dba_feature_usage_statistics WHERE detected_usages>0 ORDER BY name;
SELECT name, category, status, created FROM dba_sql_profiles ORDER BY name;
```

Os dados possuem regras de coleta, periodicidade e escopo. Um SQL Profile existente merece investigação de origem/uso; sua contagem não calcula licenças. O valor de CONTROL_MANAGEMENT_PACK_ACCESS não concede licença e não governa sozinho todos os meios possíveis de acesso.

## 3. Relacionar com ferramentas e automações

Revise jobs, scripts, monitoramento e interfaces que consultam AWR/ASH ou chamam advisors. Um template de monitoramento pode acionar recursos além do checklist manual. Inclua componentes remotos, serviços de nuvem e scripts de suporte conforme o escopo; não se limite ao que aparece no console.

No [Zabbix](<Monitorar Oracle com Zabbix.md>), a seleção da versão/template deve incluir essa conferência. Para [AWR/ASH](<Analisar relatorios AWR e ASH.md>), confirme o cenário permitido antes da primeira consulta.

## 4. Encaminhar divergências

Confronte o inventário com a documentação de licenciamento da versão, condições do serviço e contratos aplicáveis. Limites por edição, opções, packs e métricas não são inferidos de V$OPTION. Preserve evidências sem apagar histórico ou alterar indicadores para produzir aparência de conformidade.

Se uma ferramenta usa recurso fora do escopo autorizado, planeje a interrupção dessa coleta e alternativa com seus responsáveis. Desabilitar um item não altera obrigações anteriores; não modifique dados do dicionário.

## 5. Validar e encerrar

O resultado esperado é uma relação rastreável entre configuração, indícios observados, ferramentas e pendências. Nenhuma consulta altera o banco. Guarde saídas privadamente, com data e escopo; o repositório recebe apenas consultas e exemplos fictícios. Repita após mudanças relevantes de topologia, edição ou automação.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [componentes_registrados.sql](scripts/diagnostico/componentes_registrados.sql) — Consultar componentes instalados e seus estados.

## Referências oficiais

- [Licensing Information 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/dblic/Licensing-Information.html)
- [DBA_FEATURE_USAGE_STATISTICS](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_FEATURE_USAGE_STATISTICS.html)
- [CONTROL_MANAGEMENT_PACK_ACCESS](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/CONTROL_MANAGEMENT_PACK_ACCESS.html)
