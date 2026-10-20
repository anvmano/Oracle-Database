"""Verifica os novos guias, a política Git e as barreiras da rotina RMAN com mocks."""
from pathlib import Path
import hashlib
import os
import re
import shutil
import subprocess
import tempfile
from validar_incorporacao import INCORPORADOS, verificar_incorporacao

NOVOS_TUTORIAIS = {
    'Arquitetura e componentes do Oracle', 'Administrar CDB e PDBs',
    'Configurar listener e conexões Oracle Net', 'Checklist diario do banco Oracle',
    'Diagnosticar erros com ADRCI e alert log', 'Monitorar sessoes e bloqueios',
    'Monitorar TEMP e UNDO', 'Monitorar FRA e archivelogs', 'Automatizar backups RMAN',
    'Testar restauracao completa em laboratorio', 'Clonar banco com RMAN DUPLICATE',
    'Recuperacao pontual com RMAN', 'Flashback e restore points',
    'Configurar recovery catalog RMAN', 'Configurar TDE e proteger wallets',
    'Configurar auditoria unificada', 'Criar e monitorar jobs com DBMS_SCHEDULER',
    'Gerenciar estatisticas com DBMS_STATS', 'Diagnosticar SQL lento com DBMS_XPLAN',
    'Administrar indices e constraints', 'Atualizar banco com AutoUpgrade',
    'Instalar e configurar ORDS para APEX', 'Criar standby fisico com Data Guard',
    'Administrar Data Guard com Broker', 'Monitorar capacidade e crescimento do banco',
}
NOVOS_TUTORIAIS |= INCORPORADOS
APOIO = {'CONTRIBUTING.md', 'MODELO_DE_TUTORIAL.md', 'LABORATORIO.md', '.gitignore', 'LICENSE'}

def check(condition, message):
    if not condition:
        raise AssertionError(message)

def verificar_expansao(root, bash=None):
    root = Path(root)
    check(len(NOVOS_TUTORIAIS) == 45, 'Lista de novos tutoriais inconsistente')
    for name in APOIO:
        check((root/name).is_file(), f'Arquivo de apoio ausente: {name}')
    check(hashlib.sha256((root/'LICENSE').read_bytes()).hexdigest() ==
          '3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986',
          'LICENSE difere do texto oficial GPLv3 preservado')
    readme = (root/'README.md').read_text(encoding='utf-8')
    for name in NOVOS_TUTORIAIS:
        text = (root/(name+'.md')).read_text(encoding='utf-8')
        check('## Antes de começar' in text and '## Referências oficiais' in text, f'{name}: estrutura incompleta')
        check('execução em laboratório pendente' in text, f'{name}: status de teste incorreto')
        check(name+'.md' in readme, f'{name}: não consta no índice')

    verificar_incorporacao(root)
    git = shutil.which('git')
    if git:
        with tempfile.TemporaryDirectory(prefix='oracle-gitignore-') as tmp:
            folder = Path(tmp)
            shutil.copyfile(root/'.gitignore',folder/'.gitignore')
            subprocess.run([git, 'init', '--quiet', str(folder)], check=True, capture_output=True)
            ignored = {'.env', '.env.local', '.oci/config', 'chaves/segredo.pem', 'wallets/ewallet.p12',
                       'copia.bkp', 'base.dmp', 'logs/rman.log', 'control01.ctl', 'midia.zip', 'autoupgrade.jar',
                       'db_install.rsp', 'tests/__pycache__/verificador.pyc'}
            allowed = {'README.md', 'LICENSE', '.env.example', 'exemplos/artigos.ctl',
                       'exemplos/criar.sql', 'scripts/backup.sh', 'db_install.rsp.example', 'tests/validar_acervo.py'}
            result = subprocess.run([git,'-C',str(folder),'check-ignore','--no-index','--stdin','-z'],
                                    input=('\0'.join(sorted(ignored|allowed))+'\0').encode(),capture_output=True)
            check(result.returncode in {0,1}, f'git check-ignore falhou: {result.stderr}')
            actual = set(result.stdout.decode('utf-8').rstrip('\0').split('\0'))
            check(actual == ignored, f'.gitignore: faltam {ignored-actual}; excluídos indevidamente {actual-ignored}')
        print('OK: .gitignore protege segredos/artefatos e permite exemplos .sql/.ctl/.sh.')
    else:
        print('PENDENTE: Git não disponível; comportamento de .gitignore não testado.')

    if not bash:
        print('PENDENTE: Bash não disponível; barreiras da rotina RMAN não simuladas.')
        return
    doc=(root/'Automatizar backups RMAN.md').read_text(encoding='utf-8')
    script=next(code for code in re.findall(r'^```bash\n(.*?)^```\s*$',doc,re.M|re.S)
                if code.startswith('#!/'))
    check('WHENEVER' not in script.split("<<'RMAN'",1)[1].split('\nRMAN',1)[0],
          'Diretiva SQL*Plus inserida no prompt RMAN')
    mocks=r'''
findmnt() { return "${SIM_MOUNT_RC:-0}"; }
flock() { return "${SIM_LOCK_RC:-0}"; }
date() { printf '20261020_020000'; }
mock_sqlplus() { printf '%s\n' "${SIM_DBID-1234}"; return "${SIM_SQLPLUS_RC:-0}"; }
mock_rman() {
  printf 'chamado\n' > "$SIM_WORK/rman.called"
  while IFS= read -r linha; do printf '%s\n' "$linha"; done > "$SIM_WORK/rman.input"
  return "${SIM_RMAN_RC:-0}"
}
'''
    cases=[
        ('sucesso',{},0,True,True),
        ('sem_configuracao',{'unconfigured':True},64,False,False),
        ('work_ausente',{'missing_work':True},73,False,False),
        ('montagem_ausente',{'SIM_MOUNT_RC':'1'},1,False,False),
        ('destino_ausente',{'missing_dest':True},73,False,False),
        ('execucao_concorrente',{'SIM_LOCK_RC':'1'},75,False,False),
        ('dbid_incorreto',{'SIM_DBID':'9999'},65,False,False),
        ('banco_fora_do_estado',{'SIM_DBID':''},65,False,False),
        ('sqlplus_falhou',{'SIM_SQLPLUS_RC':'1'},1,False,False),
        ('rman_falhou',{'SIM_RMAN_RC':'8'},8,True,False),
    ]
    for name,options,expected_rc,should_call,should_succeed in cases:
        with tempfile.TemporaryDirectory(prefix='oracle-rman-mock-') as tmp:
            folder=Path(tmp); work=folder/'work'; dest=folder/'backup'
            if not options.get('missing_work'): work.mkdir()
            if not options.get('missing_dest'): dest.mkdir()
            env=os.environ.copy()
            env.update({'SIM_WORK':work.as_posix(),'SIM_DEST':dest.as_posix()})
            env.update({k:v for k,v in options.items() if k.startswith('SIM_')})
            adapted=script.replace('export ORACLE_HOME=/u01/app/oracle/product/19.3/dbhome_1',
                                   'export ORACLE_HOME=/caminho_nao_utilizado_pelos_mocks')
            adapted=adapted.replace('WORK=/home/oracle/backup','WORK="$SIM_WORK"')
            adapted=adapted.replace('/u04/backup','${SIM_DEST}')
            adapted=adapted.replace('"$ORACLE_HOME/bin/sqlplus"','mock_sqlplus')
            adapted=adapted.replace('"$ORACLE_HOME/bin/rman"','mock_rman')
            if not options.get('unconfigured'):
                adapted=adapted.replace('EXPECTED_DBID=SUBSTITUIR_DBID_NUMERICO','EXPECTED_DBID=1234')
            result=subprocess.run([bash,'-c',mocks+'\n'+adapted],text=True,capture_output=True,env=env)
            check(result.returncode==expected_rc, f'{name}: retorno {result.returncode}, esperado {expected_rc}; {result.stderr}')
            check((work/'rman.called').exists()==should_call, f'{name}: chamada indevida/ausente a RMAN')
            check(('Backup concluido' in result.stdout)==should_succeed, f'{name}: estado de sucesso incorreto')
            if should_call:
                payload=(work/'rman.input').read_text(encoding='utf-8')
                check('BACKUP DATABASE' in payload and 'PLUS ARCHIVELOG' in payload, 'Escopo de backup mudou')
                check(not re.search(r'(?i)\bDELETE\b',payload),'Exclusão automática acrescentada ao backup')
    print(f'OK: automação RMAN simulada em {len(cases)} cenários; nenhuma conexão Oracle ou alteração Linux.')

if __name__ == '__main__':
    bash=os.environ.get('ORACLE_DOCS_BASH') or shutil.which('bash')
    verificar_expansao(Path(__file__).resolve().parents[1],bash)
