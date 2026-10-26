from support import Disk,session,ROOT
import json,copy
COUNT=0
ROOT_PATH='PrimeVisuals/Configs/1234'
def done(text):
 global COUNT
 COUNT+=1;print('PASS',text)
def auto(d,user=1234):
 docs=[]
 for path in [f'PrimeVisuals/Configs/{user}/autosave.json',f'PrimeVisuals/Configs/{user}/autosave.backup.json']:
  try: docs.append(json.loads(d.files[path]))
  except (KeyError,ValueError): pass
 return max(docs,key=lambda x:x['revision'])
def select(lua,index):lua.execute(f"TEST_OPTIONS.profileSlot:SetValue(TEST_OPTIONS.profileSlot.Info.Values[{index}])")
# Actual main script: resolved sky, small parameters and simultaneous effects survive cold restart.
d=Disk();lua,s,_,_=session(d)
lua.execute(r'''
TEST_OPTIONS.cameraFOV:SetValue(93)
TEST_OPTIONS.camDistance:SetValue(34)
TEST_OPTIONS.camThird:SetValue(true)
TEST_OPTIONS.skyAsset:SetValue('570559352') TEST_ACTIONS.Load()
TEST_OPTIONS.skySun:SetValue(33) TEST_OPTIONS.skySunVisible:SetValue(true)
TEST_OPTIONS.skyCloudDensity:SetValue(0.73) TEST_OPTIONS.skyCloudCover:SetValue(0.61)
TEST_OPTIONS.skyClouds:SetValue(true)
TEST_OPTIONS.crossColor:SetValueRGB(Color3.new(0.23,0.34,0.45)) TEST_OPTIONS.crossEnabled:SetValue(true)
TEST_OPTIONS.crossColorRainbow:SetValue(true)
TEST_OPTIONS.lightTint:SetValueRGB(Color3.new(0.6,0.7,0.8)) TEST_OPTIONS.lightEnabled:SetValue(true)
TEST_OPTIONS.lightContrast:SetValue(0.37) TEST_OPTIONS.lightBlur:SetValue(2.5)
TEST_OPTIONS.particleEnabled:SetValue(true) TEST_OPTIONS.particleSize:SetValue(0.45)
TEST_OPTIONS.waterColor:SetValueRGB(Color3.new(0.1,0.2,0.3)) TEST_OPTIONS.waterEnabled:SetValue(true)
TEST_OPTIONS.muteScreams:SetValue(true)
TEST_SERVICES.RunService.Heartbeat:Fire(0.04)
TEST_DRAIN()
''')
expected=copy.deepcopy(auto(d)['payload'])
assert expected['values']['crossColor']=={'kind':'color','r':0.23,'g':0.34,'b':0.45}
lua.execute("TEST_ACTIONS['Unload script']()")
lua,s,_,_=session(d)
actual=auto(d)['payload']
assert actual['values']==expected['values'],[(k,expected['values'][k],v)for k,v in actual['values'].items() if v!=expected['values'][k]]
assert actual['sky']==expected['sky'] and actual['customSky'] and actual['fovApplied']
lua.execute(r'''
assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==93)
assert(TEST_SERVICES.Players.LocalPlayer.CameraMaxZoomDistance==80)
assert(TEST_SERVICES.Lighting:FindFirstChild('PrimeVisualsSky').SkyboxBk=='rbxassetid://570557514')
assert(TEST_SERVICES.Lighting:FindFirstChild('PrimeVisualsSky').SunAngularSize==33)
assert(TEST_SERVICES.Workspace.Terrain:FindFirstChildOfClass('Clouds').Enabled)
assert(TEST_OPTIONS.crossColorRainbow.Value and TEST_OPTIONS.lightEnabled.Value)
''')
done(f'all {len(actual["values"])} registered settings round-trip; active FOV/camera/sky/sun/clouds/shaders/water/particles/mutes and manual rainbow color restored')
# Animation is transient, saving is coalesced, and unloading flushes the final change.
before=d.writes
lua.execute("for i=1,120 do TEST_SERVICES.RunService.Heartbeat:Fire(1/30) end; TEST_DRAIN()")
assert d.writes==before,(d.writes,before)
lua.execute("for i=1,50 do TEST_OPTIONS.cameraFOV:SetValue(60+i) end")
assert d.writes==before
lua.execute('TEST_DRAIN()')
assert d.writes-before==2
lua.execute("TEST_OPTIONS.cameraFOV:SetValue(91); TEST_ACTIONS['Unload script']()")
assert auto(d)['payload']['values']['cameraFOV']==91
done('120 animation ticks cause zero disk writes; 50 edits coalesce to one journal write; unload flushes pending changes')
# All five named slots.
lua,s,_,_=session(d)
for i in range(1,6):
 select(lua,i)
 lua.execute(f"TEST_OPTIONS.cameraFOV:SetValue({80+i}); TEST_OPTIONS.profileName:SetValue('Preset {i}'); TEST_ACTIONS['Save to slot']()")
 doc=json.loads(d.files[f'{ROOT_PATH}/slots/slot{i}.json'])
 assert doc['name']==f'Preset {i}' and doc['payload']['values']['cameraFOV']==80+i
select(lua,3)
lua.execute("TEST_OPTIONS.profileName:SetValue('Replacement'); TEST_OPTIONS.cameraFOV:SetValue(102)")
before=copy.deepcopy(d.files[f'{ROOT_PATH}/slots/slot3.json'])
lua.execute("TEST_ACTIONS['Save to slot']()")
assert d.files[f'{ROOT_PATH}/slots/slot3.json']==before
lua.execute("TEST_ACTIONS['Save to slot']()")
assert json.loads(d.files[f'{ROOT_PATH}/slots/slot3.json'])['name']=='Replacement'
done('five independent named slots; occupied slot cannot be overwritten on the first click')
select(lua,1)
lua.execute("TEST_OPTIONS.cameraFOV:SetValue(107); TEST_ACTIONS['Load slot']()")
lua.execute("assert(TEST_OPTIONS.cameraFOV.Value==81 and TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==81)")
lua.execute("TEST_ACTIONS['Undo last config load'](); assert(TEST_OPTIONS.cameraFOV.Value==107)")
assert auto(d)['payload']['values']['cameraFOV']==107
done('loading a slot restores actual camera and autosave; undo returns exactly to the previous FOV')
# Export is portable; isolated autosaves for another Roblox account.
select(lua,1);lua.execute("TEST_ACTIONS['Export selected slot']()")
export_path=f'{ROOT_PATH}/exports/slot1.json'
assert export_path in d.files
d.files['PrimeVisuals/Imports/friend.json']=d.files[export_path]
lua2,s,_,_=session(d,5678)
lua2.execute("assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==70.4); TEST_OPTIONS.profileImportFile:SetValue('friend.json'); TEST_ACTIONS['Import into selected slot'](); TEST_ACTIONS['Load slot'](); assert(TEST_OPTIONS.cameraFOV.Value==81)")
assert auto(d,5678)['payload']['values']['cameraFOV']==81 and auto(d)['payload']['values']['cameraFOV']==107
done('JSON export/import between accounts; local autosaves and five slots isolated by UserId')
# Confirmation applies to import and delete, too.
backup=d.files['PrimeVisuals/Configs/5678/slots/slot1.json']
lua2.execute("TEST_ACTIONS['Import into selected slot']()")
assert d.files['PrimeVisuals/Configs/5678/slots/slot1.json']==backup
lua2.execute("TEST_ACTIONS['Delete slot']()")
assert d.files['PrimeVisuals/Configs/5678/slots/slot1.json']==backup
lua2.execute("TEST_ACTIONS['Delete slot']()")
assert json.loads(d.files['PrimeVisuals/Configs/5678/slots/slot1.json'])['deleted']
done('import and deletion require their own confirmation; delete creates a recoverable journal tombstone without old settings')
# Invalid JSON, data types, ranges, schema and paths cannot overwrite a good slot.
lua3,s,_,_=session(d,9999)
valid=json.loads(d.files[export_path])
cases=[]
for label,mutate in [
 ('schema',lambda x:x.update(schema=99)),
 ('fov',lambda x:x['payload']['values'].update(cameraFOV=999)),
 ('toggle',lambda x:x['payload']['values'].update(camThird='yes')),
 ('color',lambda x:x['payload']['values'].update(crossColor={'kind':'color','r':2,'g':0,'b':0})),
 ('dropdown',lambda x:x['payload']['values'].update(uiLanguage='nonexistent')),
 ('sky',lambda x:x['payload']['sky'].update(SkyboxBk=123)),
 ('window',lambda x:x['payload']['ui'].update(position={'xs':0,'x':9999999,'ys':0,'y':0})),
]:
 doc=copy.deepcopy(valid);mutate(doc);cases.append((label,json.dumps(doc)))
cases.extend([('broken','{not json}'),('oversized','x'*(512*1024+1))])
for label,text in cases:
 d.files['PrimeVisuals/Imports/bad.json']=text
 lua3.execute("TEST_OPTIONS.profileImportFile:SetValue('bad.json'); TEST_ACTIONS['Import into selected slot']()")
 assert 'PrimeVisuals/Configs/9999/slots/slot1.json' not in d.files,label
for filename in ['../friend.json','C:/evil.json','nested/friend.json','..\\friend.json']:
 lua3.globals().BAD_FILENAME=filename
 lua3.execute("TEST_OPTIONS.profileImportFile:SetValue(BAD_FILENAME); TEST_ACTIONS['Import into selected slot']()")
 assert 'PrimeVisuals/Configs/9999/slots/slot1.json' not in d.files
assert 'PrimeVisuals/Configs/1234/slots/slot1.json' in d.files
done('reject malformed/oversized JSON, future schema, wrong types/ranges, invalid sky/UI data and path traversal before replacing slots')
# Journal recovery, corrupt writes and failure retry.
e=Disk();lu,s,_,_=session(e)
lu.execute("TEST_OPTIONS.cameraFOV:SetValue(96); TEST_DRAIN()")
e.files['PrimeVisuals/Configs/1234/autosave.json']='broken'
lu,s,_,_=session(e)
lu.execute('assert(TEST_OPTIONS.cameraFOV.Value==96)')
assert auto(e)['payload']['values']['cameraFOV']==96
e.fail=True
lu.execute("TEST_OPTIONS.cameraFOV:SetValue(99); TEST_DRAIN()")
assert auto(e)['payload']['values']['cameraFOV']==96
e.fail=False
lu.execute("TEST_OPTIONS.cameraFOV:SetValue(98); TEST_DRAIN()")
assert auto(e)['payload']['values']['cameraFOV']==98
e.corrupt=True
lu.execute("TEST_OPTIONS.cameraFOV:SetValue(97); TEST_DRAIN()")
assert auto(e)['payload']['values']['cameraFOV']==98
e.corrupt=False
lu,s,_,_=session(e);lu.execute('assert(TEST_OPTIONS.cameraFOV.Value==98)')
done('corrupt primary recovers from backup; failed/truncated writes preserve the previous config; later retry succeeds')
# Total corruption must not be overwritten just by opening/closing the UI.
f=Disk();lu,s,_,_=session(f)
f.files['PrimeVisuals/Configs/1234/autosave.json']='broken A';f.files['PrimeVisuals/Configs/1234/autosave.backup.json']='broken B'
lu,s,_,_=session(f)
lu.execute("assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==70.4); TEST_ACTIONS['Unload script']()")
assert f.files['PrimeVisuals/Configs/1234/autosave.json']=='broken A'
done('both autosaves corrupt: startup remains usable, effects stay default, damaged files are preserved for recovery')
# Reset clears last-session state, not the user's named configs.
select(lua,1)
lua.execute("TEST_ACTIONS['Reset all settings'](); assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==70.4); assert(not TEST_OPTIONS.camThird.Value and not TEST_OPTIONS.lightEnabled.Value)")
assert not auto(d)['payload']['fovApplied']
assert json.loads(d.files[f'{ROOT_PATH}/slots/slot1.json'])['name']=='Preset 1'
lu,s,_,_=session(d);lu.execute("assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==70.4 and not TEST_OPTIONS.camThird.Value)")
done('reset replaces autosave with clean game defaults and preserves all named slots across restart')
print(f'PASS {COUNT} scenario groups; actual main script and actual storage module executed, simulated Roblox/file APIs')
