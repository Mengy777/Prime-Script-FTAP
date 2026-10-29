"""Run every scenario in an isolated Python/Lua process; preserve failures/logs."""
from pathlib import Path
import argparse,subprocess,sys,time,re
from datetime import date
ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--report',type=Path)
parser.add_argument('--date',default=date.today().isoformat())
args=parser.parse_args()
helpers={'support','roblox_fixture','server_model'}
results=[]
for p in sorted((ROOT/'tests/sim').glob('*.py')):
 if p.stem in helpers:continue
 start=time.perf_counter()
 try:
  r=subprocess.run([sys.executable,'-u',str(p)],cwd=ROOT,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=90)
  output=r.stdout+r.stderr;code=r.returncode
 except subprocess.TimeoutExpired as e:output=str(e);code=-1
 entry={'name':p.name,'exit':code,'seconds':round(time.perf_counter()-start,2),'checks':output.count('PASS'),'output':output}
 results.append(entry)
 print(('PASS'if code==0 else'FAIL'),p.name,entry['seconds'],'s',flush=True)
 if code:print(output,flush=True)
failed=sum(r['exit']!=0 for r in results)
summary=f'{len(results)} scenario scripts; {sum(r["checks"]for r in results)} check groups; {failed} failures.'
print(summary,flush=True)
if args.report:
 version=re.search(r'local VERSION="([^"]+)"',(ROOT/'PrimeVisuals.lua').read_text(encoding='utf-8')).group(1)
 report=[f'# Prime Visuals {version} — simulation report','', f'Run date: {args.date}. Actual project source; simulated Roblox APIs, scene graphs, filesystem and event delivery. This is not a live Roblox/FTAP server or a physics/rendering benchmark.','',summary,'']
 for r in results:
  report.extend([f'## {r["name"]} — {"PASS"if r["exit"]==0 else"FAIL"} ({r["seconds"]} s)','', '```text',r['output'].rstrip(),'```',''])
 args.report.parent.mkdir(parents=True,exist_ok=True)
 args.report.write_text('\n'.join(report),encoding='utf-8')
sys.exit(1 if failed else 0)
