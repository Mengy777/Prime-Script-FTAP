from pathlib import Path
import sys,json
from lupa import lua_type
ROOT=Path(__file__).resolve().parents[2]
BASE=Path(__file__).with_name('roblox_fixture.py').read_text(encoding='utf-8-sig')
class Disk:
 def __init__(self): self.files={}; self.folders=set(); self.writes=0; self.fail=False; self.corrupt=False
 def read(self,path):
  if path not in self.files: raise RuntimeError('File not found: '+path)
  return self.files[path]
 def write(self,path,text):
  self.writes+=1
  if self.fail: raise RuntimeError('Injected disk write error')
  self.files[path]='broken' if self.corrupt else text
 def mkdir(self,path): self.folders.add(path)
def session(disk,user=1234,execute=True):
 ns={'REPO':ROOT};exec(BASE,ns);lua,s=ns['lua'],ns['s']
 def to_py(value):
  if lua_type(value)=='table':
   keys=list(value.keys())
   if keys and all(isinstance(k,(float,int)) and int(k)==k for k in keys) and sorted(keys)==list(range(1,len(keys)+1)):
    return [to_py(value[i]) for i in range(1,len(keys)+1)]
   return {str(k):to_py(v) for k,v in value.items()}
  return value
 def to_lua(value):
  if isinstance(value,dict): return lua.table_from({k:to_lua(v) for k,v in value.items()})
  if isinstance(value,list): return lua.table_from([to_lua(v) for v in value])
  return value
 g=lua.globals();g.PY_ENCODE=lambda v:json.dumps(to_py(v),ensure_ascii=False,allow_nan=False,separators=(',',':'))
 g.PY_DECODE=lambda v:to_lua(json.loads(v));g.PY_READ=disk.read;g.PY_WRITE=disk.write;g.PY_FOLDER=lambda v:v in disk.folders;g.PY_MKDIR=disk.mkdir
 lua.execute('''
 readfile=function(p)return PY_READ(p)end
 writefile=function(p,t)return PY_WRITE(p,t)end
 isfolder=function(p)return PY_FOLDER(p)end
 makefolder=function(p)return PY_MKDIR(p)end
 TEST_SERVICES.HttpService={JSONEncode=function(_,v)return PY_ENCODE(v)end,JSONDecode=function(_,v)return PY_DECODE(v)end}
 TEST_SERVICES.Players.LocalPlayer.UserId='''+str(user)+'''
 for _,property in ipairs({'SkyboxBk','SkyboxDn','SkyboxFt','SkyboxLf','SkyboxRt','SkyboxUp','SunTextureId','MoonTextureId'}) do TEST_ORIGINAL_SKY[property]='rbxassetid://123' end
 TEST_ORIGINAL_SKY.MoonAngularSize=11 TEST_ORIGINAL_SKY.StarCount=3000
 function TEST_DRAIN()
  local pending=TASKS TASKS={}
  for _,fn in ipairs(pending) do fn() end
 end
 ''')
 if execute: lua.execute(s)
 return lua,s,to_py,to_lua
if __name__=='__main__':
 d=Disk();lua,s,_,_=session(d)
 print('initial files',list(d.files),'writes',d.writes)
 lua.execute("TEST_OPTIONS.cameraFOV:SetValue(90); TEST_OPTIONS.camDistance:SetValue(31); TEST_OPTIONS.camThird:SetValue(true); TEST_DRAIN()")
 lua.execute("TEST_ACTIONS['Unload script']()")
 lua,s,_,_=session(d)
 lua.execute("assert(TEST_OPTIONS.cameraFOV.Value==90 and TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==90); assert(TEST_OPTIONS.camDistance.Value==31 and TEST_OPTIONS.camThird.Value)")
 print('PASS basic actual-script persistence/restart')
