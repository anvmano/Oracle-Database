"""Checks locais do acervo. Não executa comandos Oracle nem operações no host Linux."""
from pathlib import Path
import csv
import io
import os
import re
import shutil
import subprocess
import sys
from urllib.parse import unquote, urlsplit
from validar_expansao import NOVOS_TUTORIAIS, verificar_expansao
from validar_biblioteca import verificar_biblioteca

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = {
    'README', 'Acessar instancia no OCI', 'Aplicando o Bundle Patch Oracle 12cr1',
    'Aplicar RU no Oracle 19c', 'Atualização Apex', 'Aumentar swap e partições',
    'Comandos para restore', 'Comandos sobre tablespace', 'Command Line Interface (CLI)',
    'Criar Chave SSH', 'Criar Instancia no OCI', 'Criar maquina para EM 13', 'Criar VCN no OCI',
    'EXPDP', 'Firewall no linux', 'IMPDP', 'Informações e parâmetros de backup',
    'Instalação do Oracle 19c no OCI', 'Instalação GRID (12c)', 'Instalação Oracle 12c',
    'Instalação Oracle 18c', 'Instalação Oracle 19c', 'Instalação Oracle 19c em Silent mode',
    'Instalação oracle linux', 'Migrando uma VM do VB para o OCI', 'multiplexando control file',
    'Multiplexar grupos de redo logs', 'Parametros do GLOGIN', 'Parametros RMAN',
    'Release Update Revision 19.5', 'RUR Oracle 19.5', 'Script monitorar SO',
    'script startup automatico', 'SQLLoader', 'Upgrade do oracle 12c para 19.3',
    'upgrade-rollback de patch (12cr1)', 'User _ Profile _ Roles _ Grants', 'visualizar DDL',
}

def blocks(text, language=None):
    items = re.findall(r'^```(\w*)\n(.*?)^```\s*$', text, re.M | re.S)
    return [(lang, code) for lang, code in items if language is None or lang == language]

def require(condition, message):
    if not condition:
        raise AssertionError(message)

def main():
    docs = {p.stem: p.read_text(encoding='utf-8') for p in ROOT.glob('*.md')}
    require(EXPECTED <= docs.keys(), f'Documentos ausentes: {EXPECTED - docs.keys()}')
    require(NOVOS_TUTORIAIS <= docs.keys(), f'Novos guias ausentes: {NOVOS_TUTORIAIS - docs.keys()}')
    links = 0
    all_docs = {p: p.read_text(encoding='utf-8') for p in ROOT.rglob('*.md')}
    for doc_path, text in all_docs.items():
        name = doc_path.stem
        require(text.startswith('# '), f'{name}: título ausente')
        require('\ufffd' not in text and '\x00' not in text, f'{name}: caractere inválido')
        require(not text.startswith('\ufeff'), f'{name}: BOM inesperado')
        fences = re.findall(r'^```[^\n]*$', text, re.M)
        require(len(fences) % 2 == 0, f'{name}: bloco não fechado')
        for raw in re.findall(r'\]\((<[^>]+>|[^\s)]+)\)', text):
            target = raw.strip('<>')
            if urlsplit(target).scheme or target.startswith('#'):
                continue
            path = (doc_path.parent / unquote(target.split('#')[0])).resolve()
            require(path.is_relative_to(ROOT), f'{name}: link fora do acervo: {target}')
            require(path.is_file(), f'{name}: link inexistente: {target}')
            links += 1
        if doc_path.parent == ROOT and name in EXPECTED | NOVOS_TUTORIAIS:
            require('## Referências oficiais' in text, f'{name}: fontes ausentes')
            if name != 'README':
                require('execução em laboratório pendente' in text, f'{name}: status ausente')

    # Regressões verificadas nos blocos executáveis, sem confundir menções explicativas.
    executable = '\n'.join(code for text in all_docs.values() for _, code in blocks(text))
    require(not re.search(r'(?i)shutdowm|dba_objetcts|AUTOALLOCATESEGMENT|whit admin', executable), 'Erro antigo reintroduzido')
    require(not re.search(r'(?i)impdp[^\n]*reuse_dumpfiles', executable), 'Opção de export em import')
    require(not re.search(r'(?i)firewall-cmd[^\n]*--add-service=\d', executable), 'Porta usada como serviço')
    require(not re.search(r'(?m)^\s*(?:rm\s+\*\.ora|kill\s+-9|systemctl\s+(?:disable|stop)\s+firewalld)', executable), 'Operação insegura de exemplo reintroduzida')

    # O CASE real da saudação deve cobrir todas as horas, incluindo os limites.
    greeting = docs['Parametros do GLOGIN']
    case = re.search(r'CASE\s+(.*?)\s+END cSaudacao', greeting, re.S).group(1)
    rules = [(int(n), label) for n, label in re.findall(r"< (\d+) THEN '([^']+)'", case)]
    fallback = re.search(r"ELSE '([^']+)'", case).group(1)
    for hour in range(24):
        actual = next((label for limit, label in rules if hour < limit), fallback)
        expected = 'Bom dia' if hour < 12 else 'Boa tarde' if hour < 18 else 'Boa noite'
        require(actual == expected, f'Saudação incorreta às {hour}h')

    # O CSV e a tabela/controle devem concordar; IDs de exemplo devem ser numéricos.
    loader = docs['SQLLoader']
    sample = blocks(loader, 'csv')[0][1]
    rows = list(csv.reader(io.StringIO(sample)))
    schema = re.search(r'CREATE TABLE CARGA_ARTIGOS \((.*?)\);', loader, re.S).group(1)
    columns = [line.strip().split()[0] for line in schema.splitlines() if line.strip()]
    require(len(rows) == 2 and all(len(row) == len(columns) == 4 for row in rows), 'CSV/schema inconsistentes')
    require(all(row[0].isdigit() for row in rows), 'IDs inválidos no CSV de sucesso')
    control = next(code for _, code in blocks(loader, 'text') if 'LOAD DATA' in code)
    for column in columns:
        require(re.search(r'^\s*'+column+r'\s+', control, re.M) is not None, f'Campo ausente no control: {column}')

    shell = os.environ.get('ORACLE_DOCS_BASH') or shutil.which('bash') or shutil.which('sh')
    shell_checks = 0
    if shell:
        version = subprocess.run([shell, '--version'], capture_output=True, text=True)
        if 'GNU bash' not in version.stdout:
            shell = None
    if shell:
        env = os.environ.copy()
        env['PATH'] = str(Path(shell).parent) + os.pathsep + env.get('PATH', '')
        for name, text in all_docs.items():
            for _, code in blocks(text, 'bash'):
                result = subprocess.run([shell, '-n'], input=code, text=True, capture_output=True, env=env)
                require(result.returncode == 0, f'{name}: sintaxe Bash: {result.stderr}')
                shell_checks += 1

        # Executa somente o relatório com coletores simulados; não consulta processos do host.
        monitor = next(code for _, code in blocks(docs['Script monitorar SO'], 'bash') if code.startswith('#!/'))
        mocks = r'''
date() { printf '2026-10-20T12:00:00-03:00\n'; }
uptime() { printf 'up 1 day\n'; }
who() { :; }
df() { printf 'Filesystem Size Used Avail Use%% Mounted\ntmpfs 4G 0 4G 0%% /dev/shm\n/dev/root 50G 25G 25G 50%% /\n'; }
free() { printf '              total used free shared buff/cache available\nMem: 16000 6000 2000 100 8000 9000\nSwap: 4000 1000 3000\n'; }
ps() {
  if [[ "$*" != '-eo pid,user,pcpu,pmem,comm --sort=-pcpu' ]]; then return 64; fi
  printf 'PID USER CPU MEM COMMAND\n'
  for ((i=1;i<=15;i++)); do printf '%s oracle 1 1 teste\n' "$i"; done
}
'''
        result = subprocess.run([shell, '-c', mocks+'\n'+monitor], text=True, capture_output=True, env=env)
        require(result.returncode == 0, f'Relatório simulado falhou: {result.stderr}')
        require('/dev/root 50G 25G 25G' in result.stdout, 'Filesystem de dados omitido')
        require('Mem: 16000 6000 2000' in result.stdout and 'Swap: 4000 1000 3000' in result.stdout, 'RAM/swap confundidas')
        process_lines = result.stdout.split('PID USER CPU MEM COMMAND\n', 1)[1].strip().splitlines()
        require(len(process_lines) == 10, 'Quantidade de processos exibidos incorreta')
        failure = subprocess.run([shell, '-c', mocks+'\nfree() { return 42; }\n'+monitor], text=True, capture_output=True, env=env)
        require(failure.returncode != 0 and 'Processos por CPU' not in failure.stdout, 'Falha de coleta mascarada')
    else:
        print('PENDENTE: Bash não disponível; sintaxe e execução simulada do relatório não testadas.')

    verificar_expansao(ROOT, shell)
    verificar_biblioteca(ROOT)
    print(f'OK: {len(EXPECTED)} textos originais e {len(NOVOS_TUTORIAIS)} novos tutoriais cobertos; {len(all_docs)} Markdown; {links} links locais válidos.')
    print('OK: regressões dos comandos, saudação (24 horas) e exemplo CSV/control/schema.')
    if shell:
        print(f'OK: sintaxe de {shell_checks} blocos Bash; relatório simulado e propagação de falha.')
    print('Oracle/Linux real, certificação e pacotes MOS não são executados por este teste.')

if __name__ == '__main__':
    try:
        main()
    except (AssertionError, IndexError, AttributeError) as error:
        print(f'FALHA: {error}', file=sys.stderr)
        sys.exit(1)
