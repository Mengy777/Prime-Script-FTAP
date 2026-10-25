from support import Disk,session
import json,copy,random
rng=random.Random(2000)
d=Disk();lua,s,_,_=session(d)
base=json.loads(d.files['PrimeVisuals/Configs/1234/autosave.json'])
# All registered keys receive non-default data in complete real imports, not a hand-written imitation of serialization.
for iteration in range(8):
 doc=copy.deepcopy(base);payload=doc['payload'];payload['applied']={k:True for k in payload['values']};payload['fovApplied']=True
 for key,value in list(payload['values'].items()):
  option=lua.globals().TEST_OPTIONS[key]; info=option['Info']; kind=option['Type']
  if isinstance(value,bool): payload['values'][key]=False
  elif isinstance(value,(float,int)):
   low,high=info['Min'],info['Max'];payload['values'][key]=round(low+(high-low)*rng.random(),3)
  elif isinstance(value,str):
   if kind=='Dropdown': vals=info['Values'];payload['values'][key]=vals[rng.randint(1,len(vals))]
   elif key=='mannequinName': payload['values'][key]='Builderman'
   else: payload['values'][key]='123456789'
  elif isinstance(value,dict) and value.get('kind')=='color':
   payload['values'][key]={'kind':'color','r':rng.random(),'g':rng.random(),'b':rng.random()}
  elif isinstance(value,dict) and value.get('kind')=='players':
   payload['values'][key]={'kind':'players','names':['AbsentFriend','OfflineEnemy']}
 payload['ui']={'position':{'xs':0,'x':110+iteration,'ys':0,'y':120+iteration},'tab':'Settings',
                'panels':{'camThird':{'xs':0,'x':210,'ys':0,'y':220}}}
 doc['name']='Random '+str(iteration)
 d.files['PrimeVisuals/Imports/random.json']=json.dumps(doc)
 # Pick an empty slot via fresh account so no confirmation influences property tests.
 user=20000+iteration
 lu,_,_,_=session(d,user)
 lu.execute("TEST_OPTIONS.profileImportFile:SetValue('random.json'); TEST_ACTIONS['Import into selected slot'](); TEST_ACTIONS['Load slot']()")
 actual=json.loads(d.files[f'PrimeVisuals/Configs/{user}/autosave.json'])['payload']
 for key,value in payload['values'].items(): assert actual['values'][key]==value,(iteration,key,value,actual['values'][key])
 expected_ui=dict(payload['ui'],tab='Home')
 assert actual['ui']==expected_ui,(actual['ui'],expected_ui)
 lu.execute("TEST_ACTIONS['Unload script']()")
 lu,_,_,_=session(d,user)
 persisted=json.loads(d.files[f'PrimeVisuals/Configs/{user}/autosave.json'])['payload']
 assert persisted['values']==actual['values'] and persisted['ui']==actual['ui']
print(f'PASS 8 seeded randomized complete profiles, {8*len(base["payload"]["values"]):,} varied setting values; imports, offline-player selections, UI positions/panels, Home startup and cold restart')
# Native main-script reload: repeat in the same simulated game and count effect resources.
e=Disk();lu,s,_,_=session(e)
lu.execute("TEST_OPTIONS.cameraFOV:SetValue(94); TEST_OPTIONS.lightEnabled:SetValue(true); TEST_OPTIONS.particleEnabled:SetValue(true); TEST_OPTIONS.crossEnabled:SetValue(true); TEST_OPTIONS.skyAsset:SetValue('570559352'); TEST_ACTIONS.Load(); TEST_DRAIN()")
lu.execute("game.GetObjects=function() error('Sky restore must not fetch a model') end")
for iteration in range(20):
 lu.execute(s)
 lu.execute("""
 assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==94 and TEST_OPTIONS.lightEnabled.Value and TEST_OPTIONS.particleEnabled.Value)
 local counts={}
 for _,service in ipairs({TEST_SERVICES.Workspace,TEST_SERVICES.Lighting,TEST_SERVICES.Players.LocalPlayer}) do
  for _,object in ipairs(service:GetDescendants()) do
   if object.Name=='PV_Particles' or object.Name=='PV_Color' or object.Name=='PrimeVisualsSky' or object.Name=='PrimeVisualsCrosshair' then counts[object.Name]=(counts[object.Name] or 0)+1 end
  end
 end
 assert(counts.PV_Particles==1 and counts.PV_Color==1 and counts.PrimeVisualsSky==1 and counts.PrimeVisualsCrosshair==1)
 """)
print('PASS 20 re-executions in the same simulated game: restored effects remain singular; resolved sky uses no model fetch')
# Recoverable journal interrupted at every write point.
for first_failure in (1,2):
 f=Disk();lu,s,_,_=session(f)
 lu.execute("TEST_OPTIONS.cameraFOV:SetValue(88); TEST_DRAIN()")
 old_write=f.write;number=[0]
 def interrupted(path,text):
  number[0]+=1
  if number[0]==first_failure: f.files[path]='truncated';raise RuntimeError('Interrupted write')
  return old_write(path,text)
 f.write=interrupted
 # New session obtains the injected fs function; initial restore can also write, so reset the counter afterwards.
 lu,s,_,_=session(f);number[0]=0
 lu.execute("TEST_OPTIONS.cameraFOV:SetValue(99); TEST_DRAIN()")
 # At least one complete old/new config always remains.
 readable=[]
 for path in ('autosave.json','autosave.backup.json'):
  try: readable.append(json.loads(f.files['PrimeVisuals/Configs/1234/'+path]))
  except ValueError: pass
 assert readable and max(readable,key=lambda x:x['revision'])['payload']['values']['cameraFOV'] in (88,99)
print('PASS journal interruption on first and mirrored write retains a readable old/new profile')
# Confirmation timeout and changing operation never share authorization.
g=Disk();lu,s,_,_=session(g)
lu.execute("TEST_OPTIONS.profileName:SetValue('Protected'); TEST_ACTIONS['Save to slot'](); TEST_TIME=0; os.clock=function()return TEST_TIME end; TEST_OPTIONS.cameraFOV:SetValue(100)")
original=g.files['PrimeVisuals/Configs/1234/slots/slot1.json']
lu.execute("TEST_ACTIONS['Save to slot'](); TEST_TIME=7; TEST_ACTIONS['Save to slot']()")
assert g.files['PrimeVisuals/Configs/1234/slots/slot1.json']==original
lu.execute("TEST_ACTIONS['Delete slot']()")
assert g.files['PrimeVisuals/Configs/1234/slots/slot1.json']==original
lu.execute("TEST_ACTIONS['Save to slot']()")
assert g.files['PrimeVisuals/Configs/1234/slots/slot1.json']==original
lu.execute("TEST_ACTIONS['Save to slot']()")
assert json.loads(g.files['PrimeVisuals/Configs/1234/slots/slot1.json'])['payload']['values']['cameraFOV']==100
print('PASS expired overwrite confirmation and switching Save/Delete cannot overwrite a slot')

H=Disk();lu,s,_,_=session(H)
lu.execute("TEST_OPTIONS.uiLanguage:SetValue('Русский'); TEST_OPTIONS.profileName:SetValue('Ночная атмосфера 🌙'); TEST_ACTIONS['Save to slot']()")
assert json.loads(H.files['PrimeVisuals/Configs/1234/slots/slot1.json'])['name']=='Ночная атмосфера 🌙'
lu.execute("TEST_ACTIONS['Export selected slot']()")
assert json.loads(H.files['PrimeVisuals/Configs/1234/exports/slot1.json'])['name']=='Ночная атмосфера 🌙'
print('PASS UTF-8 config names with Cyrillic/emoji and Russian language survive slot save/export')
