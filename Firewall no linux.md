# Configurar firewalld para acesso ao Oracle

[← Índice](README.md)

**Escopo:** firewalld; exemplos IPv4 a adaptar à zona e às origens reais.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Use console de contingência ao alterar regras remotamente. Identifique a interface/zona **realmente ativa**, origem administrativa e serviços necessários. Não habilite firewalld em produção com regras ainda não revisadas. No OCI, security lists/NSGs e firewall local são controles complementares.

## 1. Inspecionar — root

```bash
rpm -q firewalld
systemctl status firewalld
firewall-cmd --get-active-zones
firewall-cmd --get-default-zone
firewall-cmd --get-services
```

Se não instalado, instale pelo gerenciador do SO (`yum install firewalld` em OL7). Prepare o acesso de contingência e a política antes de iniciar/habilitar o serviço. `firewall-cmd --get-services` lista definições disponíveis; não significa que estejam liberadas.

## 2. Conferir zona e regras

Defina no shell a zona encontrada, não necessariamente `public`:

```bash
ZONE=public
firewall-cmd --zone="$ZONE" --list-all
firewall-cmd --permanent --zone="$ZONE" --list-all
```

Revise diferenças entre configuração corrente (**runtime**) e persistente (**permanent**). Serviços e portas são coisas distintas: `--add-service=ssh` é válido; `--add-service=22/tcp` não é um nome de serviço.

## 3. Adicionar acesso restrito e testar

Exemplo: permita SSH de uma origem IPv4 **real a substituir**. `203.0.113.10/32` é apenas endereço de documentação. Registre a regra em uma variável para aplicar exatamente o mesmo texto:

```bash
RULE='rule family="ipv4" source address="203.0.113.10/32" port port="22" protocol="tcp" accept'
firewall-cmd --zone="$ZONE" --add-rich-rule="$RULE"
firewall-cmd --zone="$ZONE" --query-rich-rule="$RULE"
```

Mantenha a conexão atual aberta e teste **uma segunda conexão** da origem autorizada. Para o listener Oracle, crie outra regra com a origem da aplicação e TCP/1521 real; não exponha a porta a toda a internet. Caso IPv6 esteja em uso, planeje regras IPv6 também.

Depois de confirmar o acesso, persista a mesma regra:

```bash
firewall-cmd --permanent --zone="$ZONE" --add-rich-rule="$RULE"
```

Confira regras amplas existentes (`ssh`, `22/tcp`, outras rich rules): uma liberação restrita não revoga uma regra ampla já ativa. Remova a regra ampla **somente depois** de verificar a alternativa e o acesso de contingência, tanto no runtime quanto no permanente.

## 4. Recarregar e conferir persistência

```bash
firewall-cmd --reload
firewall-cmd --zone="$ZONE" --list-all
firewall-cmd --permanent --zone="$ZONE" --list-all
```

`--reload` substitui runtime pela configuração permanente; alterações apenas de runtime se perdem. Não recarregue imediatamente depois de uma alteração temporária que ainda deseja testar. Com a política aprovada e serviço ativo, `systemctl enable firewalld` garante início no boot.

## 5. Remover uma regra específica

Para reverter a regra de exemplo, depois de confirmar que sua remoção não interrompe o único acesso:

```bash
firewall-cmd --zone="$ZONE" --remove-rich-rule="$RULE"
firewall-cmd --permanent --zone="$ZONE" --remove-rich-rule="$RULE"
```

Para regras de porta/serviço existentes, use respectivamente `--remove-port=PORTA/tcp` ou `--remove-service=NOME_REAL` com valores substituídos. Recarregar não significa remover apenas a última regra temporária; pode eliminar várias mudanças de runtime.

## Diagnóstico

Timeout, erro SQL Developer 17002 e conexão recusada têm várias causas. Confira rota, endereço, listener, resolução de serviço, NSG/security list e logs do firewall; não conclua automaticamente que é necessário desabilitar a proteção.

## Referências oficiais

- [Manual firewall-cmd](https://firewalld.org/documentation/man-pages/firewall-cmd.html)
- [Segurança de rede OCI](https://docs.oracle.com/en-us/iaas/Content/Security/Reference/networking_security.htm)
