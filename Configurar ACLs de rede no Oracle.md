# Configurar ACLs de rede no Oracle

[← Índice](README.md) · [Cenário de laboratório](LABORATORIO.md)

**Escopo:** 19c; ACE para uma conta, host e porta de laboratório, no container da aplicação.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use APP_LAB já criado na LABPDB e um endpoint HTTP de teste controlado. O domínio `api.example.test` é fictício: configure um host real de laboratório antes de testar. O DBA administra ACL; APP_LAB testa o acesso permitido. Firewall, DNS, TLS, wallet e permissões de rede são camadas diferentes. Não conceda acesso a `*` para resolver erro sem diagnóstico.

## 1. Inventariar permissões existentes

Como administrador na LABPDB:

```sql
SELECT host, lower_port, upper_port, ace_order, principal,
       privilege, grant_type FROM dba_host_aces
WHERE principal='APP_LAB' ORDER BY host, lower_port, ace_order;
```

Registre regras anteriores e consumidores. Se a ACE proposta já existir, não a adicione de novo. Defina host/porta exatos e confirme que o recurso de teste não expõe dados reais.

## 2. Acrescentar uma ACE específica

Exemplo para um endpoint sem TLS na porta 8080, apenas em rede isolada de laboratório:

```sql
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host=>'api.example.test', lower_port=>8080, upper_port=>8080,
    ace=>xs$ace_type(privilege_list=>xs$name_list('connect'),
                    principal_name=>'APP_LAB',principal_type=>xs_acl.ptype_db));
END;
/
COMMIT;
```

Conceda EXECUTE no pacote de rede usado somente se necessário e pela política da instalação. Se precisar de privilégio `resolve` para resolução explícita via pacote correspondente, trate-o em ACE separada sem intervalo de portas. Não reproduza CREATE_ACL/ASSIGN_ACL dos roteiros antigos como padrão de novos procedimentos.

## 3. Testar como o usuário da aplicação

Em conexão APP_LAB, se UTL_HTTP estiver autorizado e o endpoint estiver preparado:

```sql
SELECT UTL_HTTP.REQUEST('http://api.example.test:8080/health') resposta FROM dual;
```

Use resposta curta e sem dados de negócio. Confira conteúdo esperado. ORA-24247, falha de DNS, timeout e erro HTTP têm causas distintas. HTTPS requer cadeia de confiança e configuração própria; esta concessão não instala certificados nem habilita acesso a qualquer host redirecionado.

## 4. Validar restrição e retornar

Confira a ACE pela consulta inicial. Em endpoint controlado adicional não autorizado, valide a recusa sem tentar endereços de terceiros. Para retirar somente a ACE criada pelo exercício, com alvo confirmado:

```sql
BEGIN
  DBMS_NETWORK_ACL_ADMIN.REMOVE_HOST_ACE(
    host=>'api.example.test', lower_port=>8080, upper_port=>8080,
    ace=>xs$ace_type(privilege_list=>xs$name_list('connect'),
                    principal_name=>'APP_LAB',principal_type=>xs_acl.ptype_db));
END;
/
COMMIT;
```

Não remova uma concessão anterior de outro consumidor. Repita o teste e preserve o estado esperado; revogar essa ACE não desfaz requisições já realizadas.

## Scripts da biblioteca

Consulte o [catálogo por assunto](scripts/CATALOGO.md) e o [contrato de execução e parâmetros](scripts/README.md). O conteúdo dos scripts é considerado previamente tratado pelo mantenedor.

- [acl_rede.sql](scripts/diagnostico/acl_rede.sql) — Consultar entradas de ACL de rede para um principal.

## Referências oficiais

- [Administração de ACLs](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html)
- [UTL_HTTP](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/UTL_HTTP.html)
