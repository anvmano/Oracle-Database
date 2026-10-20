# Criar VCN e sub-rede no OCI

[← Índice](README.md)

**Escopo:** OCI Compute; laboratório com sub-rede pública ou acesso privado explicitamente escolhido.  
**Revisão documental:** 20/10/2026 · execução em laboratório pendente.

## Antes de começar

Tenha permissões IAM para redes no compartimento escolhido. Os CIDRs abaixo são exemplos: confirme que não se sobrepõem à rede local, VPN ou outras VCNs. Os nomes de telas podem variar no Console.

## 1. Criar a rede

1. Acesse **Networking → Virtual Cloud Networks** e selecione a região e o compartimento.
2. Crie uma VCN com nome identificável, CIDR `10.0.0.0/16` e DNS habilitado se precisar de nomes internos.
3. Crie uma sub-rede **regional**, por exemplo `10.0.0.0/24`.
4. Para este laboratório com SSH pela internet, permita IPs públicos na sub-rede. Para acesso por VPN ou Bastion, use uma sub-rede privada e siga essa arquitetura, sem adicionar IP público.

## 2. Configurar acesso à internet da sub-rede pública

1. Crie e habilite um **Internet Gateway** na mesma VCN.
2. Na tabela de rotas efetivamente associada à sub-rede, adicione destino `0.0.0.0/0` com o gateway como alvo.
3. Associe a tabela de rotas e as opções DHCP corretas à sub-rede.
4. Em uma security list ou NSG aplicado à instância, libere entrada TCP/22 somente a partir do CIDR autorizado, por exemplo o IP público do administrador com máscara `/32`.
5. Revise regras preexistentes: uma regra ampla em outra security list/NSG pode continuar permitindo acesso. Não exponha TCP/1521 ou EM Express indiscriminadamente.
6. Confira as regras de saída necessárias ao DNS e aos repositórios usados pela VM.

## 3. Validar

Na instância, confirme sub-rede, IP, rota, security lists e NSGs associados. Uma rota para o gateway, sozinha, não concede acesso: também são necessários IP público, regras de segurança e firewall do sistema operacional.

Continue em [Criar instância](<Criar Instancia no OCI.md>) e [Configurar firewall](<Firewall no linux.md>).

## Referências oficiais

- [Internet Gateway](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingIGs.htm)
- [Segurança de rede](https://docs.oracle.com/en-us/iaas/Content/Security/Reference/networking_security.htm)
