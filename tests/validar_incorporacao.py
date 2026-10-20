"""Checks documentais e SQL portável com fixtures locais; não conecta a Oracle."""
from pathlib import Path
import re
import sqlite3

INCORPORADOS = {
    'Monitorar Oracle com Zabbix', 'Administrar ASM e disk groups',
    'Analisar desempenho com Statspack', 'Rastrear SQL com DBMS_MONITOR e TKPROF',
    'Investigar alteracoes com LogMiner', 'Diagnosticar corrupcao de blocos',
    'Configurar backup RMAN no OCI Object Storage', 'Diagnosticar memoria SGA e PGA',
    'Transportar tablespaces entre bancos', 'Configurar ACLs de rede no Oracle',
    'Administrar database links e sinonimos', 'Diagnosticar objetos invalidos',
    'Administrar segmentos LOB', 'Diagnosticar character set e NLS',
    'Operar recursos Oracle com SRVCTL', 'Coletar diagnosticos com AHF e TFA',
    'Inventariar recursos e packs Oracle', 'Analisar relatorios AWR e ASH',
    'Fundamentos de SQL para administracao Oracle', 'Fundamentos de PL-SQL para automacao DBA',
}


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def sql_blocks(text):
    return re.findall(r'^```sql\n(.*?)^```\s*$', text, re.M | re.S)


def verificar_incorporacao(root):
    root = Path(root)
    require(len(INCORPORADOS) == 20, 'Manifesto de incorporação inconsistente')
    readme = (root/'README.md').read_text(encoding='utf-8')
    for name in INCORPORADOS:
        text = (root/(name+'.md')).read_text(encoding='utf-8')
        require(name+'.md' in readme, f'{name}: falta no índice')
        for section in ('## Antes de começar', '## Referências oficiais'):
            require(section in text, f'{name}: falta {section}')
        require('execução em laboratório pendente' in text, f'{name}: status incorreto')
        require(not re.search(r'(?i)Google Drive|Arquivo profissional|Scripts Clientes|C:\\Users\\|D:\\', text),
                f'{name}: caminho privado incorporado')
    models = {'MODELO_DE_GMUD.md', 'MODELO_DE_ANALISE_DE_AMBIENTE.md',
              'MODELO_DE_POLITICA_DE_BACKUP.md', 'MODELO_DE_TESTE_DE_RESTAURACAO.md',
              'MODELO_DE_IMPLANTACAO_ORACLE.md'}
    require(not any((root/name).exists() for name in models), 'Modelo de documentação fora do escopo')

    # Exercita os próprios trechos portáveis dos documentos. SQLite não valida o dialeto Oracle.
    basics = (root/'Fundamentos de SQL para administracao Oracle.md').read_text(encoding='utf-8')
    blocks = sql_blocks(basics)
    setup = next(block for block in blocks if 'CREATE TABLE T_SQL_DBA_LAB' in block)
    setup = re.sub(r"DATE ('\d{4}-\d{2}-\d{2}')", r'\1', setup)
    with sqlite3.connect(':memory:') as db:
        db.executescript('BEGIN;\n'+setup)
        queries = next(block for block in blocks if 'COUNT(valor)' in block)
        queries = re.sub(r"DATE ('\d{4}-\d{2}-\d{2}')", r'\1', queries)
        results = [db.execute(query).fetchall() for query in queries.split(';') if query.strip()]
        require(results == [[('BACKUP', 2, 1, 10), ('JOB', 1, 1, 5)], [(2,)], [(1,), (2,)]],
                f'Agregação, NULL ou intervalo incorretos: {results}')
        transaction = next(block for block in blocks if block.startswith('UPDATE T_SQL_DBA_LAB'))
        db.execute('BEGIN')
        observed = []
        for statement in transaction.split(';'):
            if statement.strip():
                cursor = db.execute(statement)
                if statement.strip().startswith('SELECT'):
                    observed.append(cursor.fetchall())
        require(observed == [[(99,)], [(10,)]], 'Rollback não preservou o valor da fixture')

    alert = (root/'Diagnosticar erros com ADRCI e alert log.md').read_text(encoding='utf-8')
    query = next(block for block in sql_blocks(alert) if 'FROM v$diag_alert_ext' in block)
    query = query.replace("SYSTIMESTAMP-INTERVAL '1' DAY", ':inicio')
    with sqlite3.connect(':memory:') as db:
        db.create_function('REGEXP_LIKE', 2, lambda value, pattern: bool(re.search(pattern, value or '')))
        db.execute('CREATE TABLE v$diag_alert_ext (originating_timestamp TEXT, message_text TEXT)')
        db.executemany('INSERT INTO v$diag_alert_ext VALUES (?,?)', [
            ('2026-10-20T08:00:00', 'ORA-01578: exemplo'),
            ('2026-10-20T09:00:00', 'LAB_INFO_A: ORA-00001: sintetico'),
            ('2026-10-20T10:00:00', 'LAB_INFO_B: ORA-00002: sintetico'),
            ('2026-10-20T11:00:00', 'sem erro'),
            ('2026-10-18T11:00:00', 'ORA-01578: antigo'),
            ('2026-10-20T12:00:00', None),
        ])
        result = db.execute(query, {'inicio': '2026-10-19T12:00:00'}).fetchall()
        require(result == [('2026-10-20T08:00:00', 'ORA-01578: exemplo')],
                f'Filtro de alertas deixa passar exclusão/data inválida: {result}')

    scheduler = (root/'Criar e monitorar jobs com DBMS_SCHEDULER.md').read_text(encoding='utf-8')
    query = next(block for block in sql_blocks(scheduler) if 'LEFT JOIN dba_scheduler_running_jobs' in block)
    with sqlite3.connect(':memory:') as db:
        db.execute('CREATE TABLE dba_scheduler_jobs (owner,job_name,state,enabled,next_run_date)')
        db.execute('CREATE TABLE dba_scheduler_running_jobs (owner,job_name,session_id,elapsed_time)')
        db.executemany('INSERT INTO dba_scheduler_jobs VALUES (?,?,?,?,?)', [
            ('APP_LAB', 'A_RODANDO', 'RUNNING', 'TRUE', None),
            ('APP_LAB', 'B_AGENDADO', 'SCHEDULED', 'TRUE', '2026-10-21'),
            ('OUTRO', 'A_RODANDO', 'RUNNING', 'TRUE', None),
        ])
        db.executemany('INSERT INTO dba_scheduler_running_jobs VALUES (?,?,?,?)', [
            ('APP_LAB', 'A_RODANDO', 42, '10 segundos'),
            ('OUTRO', 'A_RODANDO', 99, '20 segundos'),
        ])
        result = db.execute(query).fetchall()
        require(len(result) == 2 and result[0][-2:] == (42, '10 segundos')
                and result[1][-2:] == (None, None),
                f'Junção de jobs cruza owners ou perde job inativo: {result}')
    print('OK: 20 guias operacionais; modelos excluídos; fixtures SQLite de agregação/NULL, datas, rollback, alertas e jobs.')


if __name__ == '__main__':
    verificar_incorporacao(Path(__file__).resolve().parents[1])
