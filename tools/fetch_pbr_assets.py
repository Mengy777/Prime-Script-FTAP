from pathlib import Path
import json,urllib.request,zipfile,io,hashlib
from concurrent.futures import ThreadPoolExecutor
r=Path(__file__).resolve().parents[1];manifest=json.loads((r/'tools/pbr-texture-manifest.json').read_text())
def asset(a):
 cache={}
 for m in a['Maps'].values():
  p=r/'assets/map-pbr'/m['File']
  if p.exists()and hashlib.sha256(p.read_bytes()).hexdigest()==m['SHA256']:continue
  url=m['URL']
  if url not in cache:
   req=urllib.request.Request(url,headers={'User-Agent':'PrimeVisuals-PBR-Importer/1.0 (github.com/Mengy777/Prime-Script-FTAP)'})
   cache[url]=urllib.request.urlopen(req,timeout=60).read()
  data=zipfile.ZipFile(io.BytesIO(cache[url])).read(m['ArchiveMember'])if 'ArchiveMember'in m else cache[url]
  assert hashlib.sha256(data).hexdigest()==m['SHA256'],m['File'];p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
 print('Verified',a['Name'],flush=True)
with ThreadPoolExecutor(max_workers=3)as pool:list(pool.map(asset,manifest['Assets']))
