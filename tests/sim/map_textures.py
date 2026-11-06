from support import Disk,session,ROOT
import json
D=Disk();lua,_,_,_=session(D)
lua.execute("assert(TEST_OPTIONS.mapMode==nil and TEST_OPTIONS.mapTexturePreset==nil and TEST_OPTIONS.mapTextureGrassStyle==nil); TEST_OPTIONS.cameraFOV:SetValue(99); TEST_DRAIN(); TEST_ACTIONS['Unload script']()")
for path,body in list(D.files.items()):
 try: doc=json.loads(body)
 except (ValueError,TypeError): continue
 if isinstance(doc,dict)and 'payload'in doc:
  doc['payload']['values'].update(mapMode='Custom textures',mapTexturePreset='Rainbow Atelier',mapTextureGrassStyle='Colorful Spangles')
  D.files[path]=json.dumps(doc)
lua,_,_,_=session(D)
lua.execute("assert(TEST_OPTIONS.cameraFOV.Value==99); assert(TEST_OPTIONS.mapGrassMaterial and TEST_OPTIONS.mapPreset); assert(TEST_OPTIONS.mapTextureGrassStyle==nil); TEST_ACTIONS['Unload script']()")
assert not (ROOT/'lib/MapTextures.lua').exists() and not (ROOT/'lib/MapTextureCatalog.lua').exists()
assert 'MapTextureCatalog'not in(ROOT/'PrimeVisuals.lua').read_text(encoding='utf-8')
print('PASS custom texture UI/modules removed, classic materials retained and legacy texture config ignored without losing FOV')
