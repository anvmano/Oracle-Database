-- Objetivo: Consultar estado do keystore TDE sem exportar chaves
-- Ambiente: Oracle 19c; SQL*Plus 19c; executar iniciar_sessao.sql antes.
-- Escopo: container conectado; GV$ inclui instancias, V$ somente a local.
-- Privilegios: leitura de V$ENCRYPTION_WALLET.
-- Parametros bind: nenhum
-- Efeito: Consulta; nao altera objetos ou recursos.
-- Tutorial: ../../Configurar TDE e proteger wallets.md
-- Referencia: https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/index.html
-- Revisao: 20/10/2026; organizacao editorial do acervo previamente tratado.
-- Limite: Nao abre wallet nem exporta chave; WRL_PARAMETER e um caminho potencialmente sensivel.
SET DEFINE OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SELECT con_id,wrl_type,wrl_parameter,status,wallet_type,wallet_order,keystore_mode,fully_backed_up
FROM v$encryption_wallet ORDER BY con_id,wallet_order;
