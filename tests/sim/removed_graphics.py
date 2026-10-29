from support import Disk,session,ROOT
import json

D=Disk();lua,source,_,_=session(D)
lua.execute("TEST_OPTIONS.lightEnabled:SetValue(true); TEST_OPTIONS.lightContrast:SetValue(.38); TEST_DRAIN()")
removed={'animationEnabled':True,'animationName':'Dance / Dab','animationSpeed':2,'giEnabled':True,'giQuality':'Ultra','giStrength':2,'giRange':30,'giDistance':200,'giLocalLights':True,
 'shaftEnabled':True,'shaftCount':24,'shaftLength':150,'shaftRadius':50,'shaftWidth':8,'shaftOpacity':.2,
 'shaftColor':{'kind':'color','r':1,'g':.5,'b':.1},'shaftColorRainbow':True}
for path,content in list(D.files.items()):
 if path.endswith(('autosave.json','autosave.backup.json')):
  doc=json.loads(content);doc['payload']['values'].update(removed)
  doc['payload']['applied'].update({key:True for key in removed})
  D.files[path]=json.dumps(doc)
restored,*_=session(D)
restored.execute(r"""
assert(TEST_OPTIONS.lightEnabled.Value and TEST_OPTIONS.lightContrast.Value==.38,'old experiment keys damaged manual lighting')
assert(not TEST_OPTIONS.giEnabled and not TEST_OPTIONS.shaftEnabled)
assert(not TEST_OPTIONS.animationEnabled and not TEST_OPTIONS.animationName and not TEST_OPTIONS.animationSpeed)
local bar=TEST_TAB_OBJECTS.Graphics.Container:FindFirstChild('PV_SectionBar')
assert(bar and not bar:FindFirstChild('Section_Experimental'))
assert(not workspace:FindFirstChild('PV_ExperimentalGraphics'))
TEST_OPTIONS.lightContrast:SetValue(.39)TEST_DRAIN()
""")
doc=json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])
assert len(doc['payload']['values'])==336
assert all(key not in doc['payload']['values'] for key in removed)
assert not (ROOT/'lib/ExperimentalGraphics.lua').exists()
assert 'ExperimentalGraphics' not in source
print('PASS experiment UI/module removed; old 353-key settings load without reset, preserve manual lighting and resave 336 keys')
