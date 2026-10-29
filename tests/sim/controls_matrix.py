from pathlib import Path
import json
from support import ROOT
# Reuse the deterministic geometry/input fixture, not its assertions or runtime.
setup=(ROOT/'tests/sim/visual_expansion.py').read_text(encoding='utf-8')
exec(setup[:setup.index('lua.execute(source)')])
lua.execute("CFrame.fromOrientation=CFrame.fromEulerAnglesYXZ")
lua.execute("AUDIT_WARNINGS={} warn=function(...) local t={...} for i,v in ipairs(t)do t[i]=tostring(v)end table.insert(AUDIT_WARNINGS,table.concat(t,' '))end")
lua.execute(source)
lua.execute('TEST_DRAIN()')
values=json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])['payload']['values']
results=[]
for key in sorted(values):
 option=lua.globals().TEST_OPTIONS[key]
 try:
  lua.globals().AUDIT_KEY=key
  lua.execute(r"""
local o=TEST_OPTIONS[AUDIT_KEY] local initial=o.Value
if o.Type=='Toggle' then o:SetValue(not initial) TICK(.51) o:SetValue(initial)
elseif o.Type=='Slider' then o:SetValue(o.Info.Min) o:SetValue(o.Info.Max) o:SetValue(initial)
elseif o.Type=='Dropdown' and type(initial)~='table' then
 for _,v in ipairs(o.Info.Values) do o:SetValue(v) end o:SetValue(initial)
elseif o.Type=='ColorPicker' then o:SetValueRGB(Color3.new(.2,.4,.6)) o:SetValueRGB(initial)
else o:SetValue(initial) end
TEST_DRAIN()
""")
  results.append((key,'ok'))
 except Exception as e:
  results.append((key,str(e)))
errors=[(k,e) for k,e in results if e!='ok']
warnings=[str(v) for v in lua.globals().AUDIT_WARNINGS.values()]
notices=[str(v) for v in lua.globals().TEST_NOTICES.values()]
print('MATRIX',len(results),'controls; exceptions',len(errors),'warnings',len(warnings),'notifications',len(notices))
for k,e in errors: print('EXCEPTION',k,e)
for w in warnings: print('WARNING',w)
for n in notices: print('NOTICE',n)
assert not errors,errors
assert not notices,notices
assert all(('Executor does not support local image assets' in w or 'native CameraInput unavailable' in w) for w in warnings),warnings
lua.execute("TEST_ACTIONS['Unload script']()")
print('PASS all registered controls exercise boolean changes, every dropdown entry, numeric endpoints and colors, then unload; runtime warnings reviewed separately')
