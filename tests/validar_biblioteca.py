"""Contratos da biblioteca e regressões com SELECTs reais em dados sintéticos.

SQLite verifica somente as associações/agregações escolhidas. Não compila Oracle.
"""
from pathlib import Path
import re
import sqlite3


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def selects(path):
    """Lê as consultas simples usadas nestas fixtures, sem analisar PL/SQL."""
    code = '\n'.join(line for line in path.read_text(encoding='utf-8').splitlines()
                     if not line.startswith(('--', 'SET ', 'WHENEVER ')))
    # Somente o preambulo de validacao conhecido das consultas desta biblioteca.
    code = re.sub(r'\ABEGIN\n.*?\nEND;\n/\n', '', code.lstrip(), flags=re.S)
    return [part.strip() for part in code.split(';') if part.strip()]


def verificar_biblioteca(root):
    base = root / 'scripts'
    counts = {'diagnostico': 77, 'manutencao': 7, 'geradores': 6}
    subjects = (base/'CATALOGO.md').read_text(encoding='utf-8')
    all_files = []
    for group, count in counts.items():
        paths = sorted((base/group).glob('*.sql'))
        require(len(paths) == count, f'Biblioteca: grupo {group} incompleto')
        index = (base/group/'README.md').read_text(encoding='utf-8')
        for path in paths:
            code = path.read_text(encoding='utf-8')
            require(f']({path.name})' in index, f'Sem catálogo: {path.name}')
            for field in ('Objetivo:', 'Ambiente:', 'Escopo:', 'Privilegios:', 'Parametros bind:', 'Efeito:', 'Tutorial:', 'Referencia:', 'Revisao:'):
                require(f'-- {field}' in code, f'{path.name}: cabeçalho incompleto {field}')
            require('organizacao editorial do acervo previamente tratado' in code, f'{path.name}: estado editorial não declarado')
            require(f']({group}/{path.name})' in subjects, f'{path.name}: ausente no catálogo por assunto')
            tutorial = re.search(r'^-- Tutorial: (.+)$', code, re.M).group(1)
            require((path.parent/tutorial).resolve().is_file(), f'{path.name}: tutorial inexistente')
            require(path.name in (path.parent/tutorial).resolve().read_text(encoding='utf-8'), f'{path.name}: falta vínculo no tutorial')
            require('SET DEFINE OFF' in code and '&' not in code, f'{path.name}: substituição textual proibida')
            for policy in ('WHENEVER OSERROR EXIT FAILURE ROLLBACK', 'WHENEVER SQLERROR EXIT FAILURE ROLLBACK'):
                require(policy in code, f'{path.name}: falha não propagada')
            require(not re.search(r'^\s*(CONNECT|CONN|HOST|SPOOL|EXIT|QUIT|START|@)', code, re.I | re.M), f'{path.name}: operação de cliente inesperada')
            require(not re.search(r'(?i)identified\s+by|password\s*=|D:\\Google|DBA_HIST_|V\$ACTIVE_SESSION_HISTORY|DBMS_SQLTUNE', code), f'{path.name}: conteúdo fora do escopo')
            require('\ufffd' not in code and '\x00' not in code and not code.startswith('\ufeff'), f'{path.name}: encoding')
            if group == 'diagnostico':
                # Remove comentários e literais, sem confundir palavras em nomes/títulos.
                executable = re.sub(r"'(?:''|[^'])*'", "''", re.sub(r'--[^\n]*', '', code))
                require(not re.search(r'\b(INSERT|UPDATE|DELETE|MERGE|ALTER|DROP|TRUNCATE|CREATE|EXECUTE|DBMS_\w+)\b', executable, re.I), f'{path.name}: diagnóstico altera ambiente')
            if group == 'manutencao':
                require(code.count('\n/\n') == 1, f'{path.name}: guardas e ação devem estar no mesmo bloco')
                for guard in (':p_confirmacao := NULL', ':p_dbid_esperado', ':p_container_esperado', "l_role<>'PRIMARY'", "l_open<>'READ WRITE'", "l_pdb_open<>'READ WRITE'", "l_comum<>'NO'", "l_mantido<>'N'", "SYS_CONTEXT('USERENV','CURRENT_SCHEMA')"):
                    require(guard in code, f'{path.name}: guarda ausente {guard}')
                require(code.index(':p_confirmacao := NULL') < code.index('SELECT dbid'), f'{path.name}: consumir confirmação antes da ação')
                require(not re.search(r'WHEN\s+OTHERS|force\s*=>\s*TRUE|KILL SESSION[^\n]*IMMEDIATE', code, re.I), f'{path.name}: falha mascarada/força')
            if group == 'geradores':
                require(not re.search(r'\bEXECUTE\s+IMMEDIATE\b', code, re.I), f'{path.name}: não executar DDL gerado')
            all_files.append(path)

    init = (base/'iniciar_sessao.sql').read_text(encoding='utf-8')
    declared = set(re.findall(r'^VARIABLE\s+(p_\w+)\b', init, re.M))
    used = set(re.findall(r':(p_\w+)\b', '\n'.join(p.read_text(encoding='utf-8') for p in all_files)))
    require(used <= declared, f'Binds não declarados: {used-declared}')
    require(all(f':{name}:=' in init for name in declared), 'Inicializador deve limpar todos os parâmetros')
    collect = (base/'manutencao/coletar_estatisticas_tabela.sql').read_text(encoding='utf-8')
    require(collect.index('DBMS_STATS.EXPORT_TABLE_STATS') < collect.index('DBMS_STATS.GATHER_TABLE_STATS'), 'Preservar estatísticas antes da coleta')
    require('NULLIF' in (base/'diagnostico/hit_ratios.sql').read_text(encoding='utf-8'), 'Divisor desprotegido')
    kill = (base/'manutencao/encerrar_sessao.sql').read_text(encoding='utf-8')
    require(':p_instancia_esperada<>l_instancia' in kill and kill.index(':p_instancia_esperada<>l_instancia') < kill.index('ALTER SYSTEM KILL SESSION'), 'Conferir instância do alvo antes de KILL')

    db = sqlite3.connect(':memory:')
    db.create_function('SYS_CONTEXT', 2, lambda area, key: '3' if key == 'CON_ID' else 'APP_LAB')
    db.create_function('TO_NUMBER', 1, lambda value: int(value))
    db.create_function('GREATEST', 2, max)
    checks = 0

    def execute(name, binds=None, statement=0):
        sql = selects(base/'diagnostico'/f'{name}.sql')[statement]
        # SQLite aceita $ no identificador, mas # precisa de aspas.
        sql = re.sub(r'\b([A-Za-z_]\w*#)', r'"\1"', sql)
        cursor = db.execute(sql, binds or {})
        return [dict(zip([column[0] for column in cursor.description], row)) for row in cursor.fetchall()]

    db.executescript('''
    CREATE TABLE dba_tablespaces(tablespace_name TEXT,status TEXT,block_size INTEGER);
    CREATE TABLE dba_data_files(file_id INTEGER,tablespace_name TEXT,file_name TEXT,bytes INTEGER,maxbytes INTEGER,autoextensible TEXT,online_status TEXT,status TEXT);
    CREATE TABLE dba_free_space(file_id INTEGER,tablespace_name TEXT,bytes INTEGER);
    INSERT INTO dba_tablespaces VALUES ('DADOS','ONLINE',8192),('OFF','OFFLINE',16384),('ZERO','ONLINE',8192);
    INSERT INTO dba_data_files VALUES (1,'DADOS','f1',104857600,209715200,'YES','ONLINE','AVAILABLE'),(2,'DADOS','f2',104857600,0,'NO','ONLINE','AVAILABLE'),(3,'OFF','f3',104857600,0,'NO','OFFLINE','AVAILABLE'),(4,'ZERO','f4',0,0,'NO','ONLINE','AVAILABLE');
    INSERT INTO dba_free_space VALUES (1,'DADOS',20971520),(1,'DADOS',10485760),(2,'DADOS',20971520);
    ''')
    rows = {r['tablespace_name']:r for r in execute('tablespaces_uso')}
    require(rows['DADOS']['usado_mib'] == 150 and rows['DADOS']['livre_mib'] == 50, 'Espaço duplicado por datafile/extent')
    require(rows['DADOS']['pct_usado'] == 75 and rows['DADOS']['teto_configurado_mib'] == 300, 'Percentual/teto incorreto')
    require(rows['OFF']['usado_mib'] is None and rows['ZERO']['pct_usado'] is None, 'Offline/zero não podem inventar ocupação')
    files = {r['file_id']:r for r in execute('datafiles_uso')}
    require(files[1]['usado_mib'] == 70 and files[2]['usado_mib'] == 80 and files[3]['usado_mib'] is None, 'Granularidade de arquivo incorreta')
    checks += 4

    db.executescript('''
    CREATE TABLE gv$session(inst_id INTEGER,con_id INTEGER,sid INTEGER,"serial#" INTEGER,username TEXT,service_name TEXT,status TEXT,event TEXT,wait_class TEXT,sql_id TEXT,sql_child_number INTEGER,type TEXT,taddr TEXT,paddr TEXT,program TEXT,blocking_instance INTEGER,blocking_session INTEGER,blocking_session_status TEXT,seconds_in_wait INTEGER,saddr TEXT);
    CREATE TABLE gv$sql(inst_id INTEGER,con_id INTEGER,sql_id TEXT,child_number INTEGER,plan_hash_value INTEGER,sql_text TEXT);
    INSERT INTO gv$session VALUES(1,3,7,101,'APP_LAB','lab','ACTIVE','e','w','abc',1,'USER','tx1','pr1','prog',2,7,'VALID',30,'addr1');
    INSERT INTO gv$session VALUES(2,3,7,202,'APP_LAB','lab','ACTIVE','e','w','xyz',0,'USER','tx2','pr2','prog',NULL,NULL,'NO HOLDER',0,'addr2');
    INSERT INTO gv$session VALUES(1,4,9,303,'APP_LAB','other','ACTIVE','e','w','abc',1,'USER','tx3','pr3','prog',NULL,NULL,'NO HOLDER',0,'addr3');
    INSERT INTO gv$sql VALUES(1,3,'abc',0,100,'filho errado'),(1,3,'abc',1,101,'filho certo'),(2,3,'abc',1,102,'instancia errada'),(1,4,'abc',1,103,'container errado'),(2,3,'xyz',0,200,'segunda instancia');
    CREATE TABLE gv$process(inst_id INTEGER,addr TEXT,spid TEXT);
    INSERT INTO gv$process VALUES(1,'pr1','123'),(2,'pr1','456');
    CREATE TABLE gv$transaction(inst_id INTEGER,con_id INTEGER,addr TEXT,start_date TEXT,used_ublk INTEGER,used_urec INTEGER,ubafil INTEGER);
    CREATE TABLE gv$datafile(inst_id INTEGER,con_id INTEGER,"file#" INTEGER,block_size INTEGER);
    INSERT INTO gv$transaction VALUES(1,3,'tx1','2026-10-20',128,10,8),(2,3,'tx2','2026-10-20',128,10,8);
    INSERT INTO gv$datafile VALUES(1,3,8,8192),(2,3,8,16384);
    CREATE TABLE gv$tempseg_usage(inst_id INTEGER,con_id INTEGER,session_addr TEXT,session_num INTEGER,username TEXT,tablespace TEXT,segtype TEXT,sql_id TEXT,blocks INTEGER);
    INSERT INTO gv$tempseg_usage VALUES(1,3,'addr1',101,'APP_LAB','DADOS','SORT','abc',128),(2,3,'addr2',202,'APP_LAB','OFF','SORT','xyz',128),(1,3,'addr1',999,'APP_LAB','DADOS','SORT','old',1);
    ''')
    binds = {'p_owner':'APP_LAB'}
    rows = execute('sessoes_ativas',binds)
    require(len(rows)==2 and rows[0]['plan_hash_value']==101 and rows[1]['plan_hash_value']==200, 'Cursor/instância/container associados incorretamente')
    rows = execute('bloqueadores',binds)
    require(len(rows)==1 and rows[0]['bloqueador_serial']==202, 'Bloqueador de outra instância perdido/incorreto')
    require(len(execute('sessao_por_processo',{'p_spid':'123'}))==1, 'Processo multiplicado por instância')
    rows = execute('transacoes_undo',binds)
    require(sorted(r['undo_mib'] for r in rows)==[1,2], 'UNDO deve usar bloco real por arquivo/instância')
    rows = execute('temp_uso',binds)
    require(sorted(r['temp_mib'] for r in rows if r['sid'] is not None)==[1,2], 'TEMP usa tamanho real do tablespace')
    require(any(r['sid'] is None for r in rows), 'TEMP não deve associar sessão com SERIAL reutilizado')
    checks += 6

    db.executescript('''
    CREATE TABLE v$sysstat(name TEXT,value INTEGER);
    INSERT INTO v$sysstat VALUES('db block gets from cache',0),('consistent gets from cache',0),('physical reads cache',0);
    CREATE TABLE v$filestat("file#" INTEGER,con_id INTEGER,phyrds INTEGER,phywrts INTEGER,readtim INTEGER,writetim INTEGER);
    INSERT INTO v$filestat VALUES(1,3,0,0,0,0),(2,3,0,0,0,0),(1,4,900,900,900,900);
    ''')
    require(execute('hit_ratios')[0]['cache_hit_pct'] is None, 'Hit ratio divide por zero')
    rows = execute('io_tablespaces')
    require(len(rows)==1 and rows[0]['pct_leituras'] is None, 'I/O zero/container incorreto')
    db.execute('UPDATE v$filestat SET phyrds=30 WHERE "file#"=1 AND con_id=3')
    db.execute('UPDATE v$filestat SET phyrds=70 WHERE "file#"=2 AND con_id=3')
    require([r['pct_leituras'] for r in execute('io_datafiles')]==[30,70], 'Participação I/O incorreta')
    checks += 3

    db.executescript('''
    CREATE TABLE dba_scheduler_jobs(owner TEXT,job_name TEXT,enabled TEXT,state TEXT);
    CREATE TABLE dba_scheduler_job_run_details(owner TEXT,job_name TEXT,log_date REAL,status TEXT,"error#" INTEGER,run_duration TEXT);
    INSERT INTO dba_scheduler_jobs VALUES('APP_LAB','MESMO_NOME','TRUE','SCHEDULED'),('OUTRO','MESMO_NOME','FALSE','DISABLED');
    INSERT INTO dba_scheduler_job_run_details VALUES('APP_LAB','MESMO_NOME',100,'SUCCEEDED',0,'1'),('APP_LAB','REMOVIDO',100,'FAILED',1,'1'),('OUTRO','MESMO_NOME',100,'FAILED',2,'1');
    ''')
    sql=selects(base/'diagnostico/scheduler_execucoes.sql')[1]
    # Somente a função de relógio/intervalo é adaptada; o join é o SQL publicado.
    sql=sql.replace("SYSTIMESTAMP-NUMTODSINTERVAL(:p_dias,'DAY')",'99-:p_dias')
    sql=re.sub(r'\b([A-Za-z_]\w*#)',r'"\1"',sql)
    rows=db.execute(sql,{'p_owner':'APP_LAB','p_nome':None,'p_dias':1}).fetchall()
    require(len(rows)==2 and {r[1] for r in rows}=={'MESMO_NOME','REMOVIDO'}, 'Scheduler perdeu removido ou multiplicou owner')
    require(any(r[-1] is None for r in rows), 'Logs removidos devem manter definição desconhecida')
    require(not db.execute(sql,{'p_owner':'APP_LAB','p_nome':None,'p_dias':0}).fetchall(), 'Período inválido aceito')
    checks += 3
    db.close()
    print(f'OK: biblioteca: {len(all_files)+1} SQL, catálogos por finalidade/assunto, contratos de entrada/falha e {checks} regressões com SELECTs sintéticos.')


if __name__=='__main__':
    verificar_biblioteca(Path(__file__).resolve().parents[1])
