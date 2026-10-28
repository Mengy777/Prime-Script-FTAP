from support import Disk,session,ROOT
import json,copy

d=Disk();lua,source,_,_=session(d,execute=False)
lua.execute(r"""
local L=TEST_SERVICES.Lighting
L.Ambient=Color3.fromRGB(70,71,72)L.OutdoorAmbient=Color3.fromRGB(81,82,83)
L.ColorShift_Top=Color3.new()L.ColorShift_Bottom=Color3.new()
L.GlobalShadows=true L.ShadowSoftness=.3 L.GeographicLatitude=41.7
L.EnvironmentDiffuseScale=.2 L.EnvironmentSpecularScale=.3 L.FogColor=Color3.fromRGB(150,151,152)
TEST_NATIVE_AIR=Instance.new('Atmosphere')TEST_NATIVE_AIR.Name='GameAtmosphere'TEST_NATIVE_AIR.Density=.25 TEST_NATIVE_AIR.Haze=1 TEST_NATIVE_AIR.Glare=.3 TEST_NATIVE_AIR.Parent=L
TEST_NATIVE_BLOOM=Instance.new('BloomEffect')TEST_NATIVE_BLOOM.Name='GameBloom'TEST_NATIVE_BLOOM.Enabled=true TEST_NATIVE_BLOOM.Parent=L
""")
lua.execute(source)
lua.execute(r"""
local L=TEST_SERVICES.Lighting
assert(not L:FindFirstChild('PV_ManualAtmosphere')and TEST_NATIVE_AIR.Density==.25 and TEST_NATIVE_BLOOM.Enabled,'startup changed lighting')
function GETE(name)return assert(L:FindFirstChild(name),name)end
local function same(a,b)
 if type(a)=='table'and a.R~=nil then return a.R==b.R and a.G==b.G and a.B==b.B end
 return a==b
end
for _,name in ipairs({'Pale Frost','Dreamy Night','Tokyowami'})do
 TEST_ACTIONS['Reset filters']()
 if name=='Dreamy Night'then L.GlobalShadows=false end
 TEST_OPTIONS.visualPreset:SetValue(name)TEST_OPTIONS.visualPresetEnabled:SetValue(true)
 local expected={}
 for _,key in ipairs({'ClockTime','GeographicLatitude','Brightness','Ambient','OutdoorAmbient','FogColor','FogStart','FogEnd','EnvironmentDiffuseScale','EnvironmentSpecularScale','GlobalShadows','ExposureCompensation','ShadowSoftness','ColorShift_Top','ColorShift_Bottom'})do expected[key]=L[key]end
 local effectExpected={}
 for _,o in ipairs(L:GetChildren())do
  if o.Name:match('^PV_Preset_')then
   local fields={}
   for _,property in ipairs({'Brightness','Contrast','Saturation','TintColor','Intensity','Size','Threshold','Spread','FocusDistance','InFocusRadius','NearIntensity','FarIntensity','Density','Offset','Color','Decay','Glare','Haze'})do
    if o[property]~=nil then fields[property]=o[property]end
   end
   effectExpected[o.ClassName]=fields
  end
 end
 TEST_ACTIONS['Edit selected preset']()
 assert(TEST_OPTIONS.lightEnabled.Value and not TEST_OPTIONS.visualPresetEnabled.Value,'copy left source preset active')
 for key,value in pairs(expected)do assert(same(value,L[key]),name..' lighting mismatch '..key)end
 for class,fields in pairs(effectExpected)do
  local map={Atmosphere='PV_ManualAtmosphere',ColorCorrectionEffect='PV_Color',BloomEffect='PV_Bloom',DepthOfFieldEffect='PV_Depth',SunRaysEffect='PV_Rays',BlurEffect='PV_SoftBlur'}
  local o=GETE(map[class])
  for key,value in pairs(fields)do
   if class=='BloomEffect'and key=='Size'then value=math.min(value,56)end
   assert(same(value,o[key]),name..' effect mismatch '..class..'.'..key)
  end
 end
 TEST_OPTIONS.lightContrast:SetValue(.42)assert(GETE('PV_Color').Contrast==.42)
 assert(not TEST_OPTIONS.visualPresetEnabled.Value,'editing reenabled source')
 TEST_ACTIONS['Reset filters']()
 assert(TEST_NATIVE_AIR.Density==.25 and TEST_NATIVE_AIR.Haze==1 and TEST_NATIVE_BLOOM.Enabled,'reset did not restore game effects')
 assert(not L:FindFirstChild('PV_ManualAtmosphere'))
 for _,o in ipairs(L:GetChildren())do if o.Name=='PV_Depth'then assert(not o.Enabled)end end
 -- Selecting an original again must retain its original settings, not our edits.
 TEST_OPTIONS.visualPresetEnabled:SetValue(true)
 local found=false
 for _,o in ipairs(L:GetChildren())do if o.Name:match('^PV_Preset_')and o:IsA('ColorCorrectionEffect')then assert(o.Contrast~=.42)found=true end end
 assert(found)
 TEST_OPTIONS.visualPresetEnabled:SetValue(false)
end
""")
print('PASS exact copy of all three source scenes, independent edits, original presets unchanged and reset restoration')
lua.execute(r"""
TEST_OPTIONS.lightEnabled:SetValue(true)TEST_OPTIONS.lightEnvironment:SetValue(true)
TEST_OPTIONS.lightClock:SetValue(17.2)TEST_OPTIONS.lightLatitude:SetValue(72)
TEST_OPTIONS.lightShadows:SetValue(false)TEST_OPTIONS.lightSoftness:SetValue(.8)
TEST_OPTIONS.lightFogStart:SetValue(120)TEST_OPTIONS.lightFogEnd:SetValue(900)
TEST_OPTIONS.lightDiffuse:SetValue(.8)TEST_OPTIONS.lightSpecular:SetValue(.9)
TEST_OPTIONS.lightAmbient:SetValueRGB(Color3.new(.12,.23,.34))
TEST_OPTIONS.lightAtmosphere:SetValue(true)TEST_OPTIONS.lightAirDensity:SetValue(.6)
TEST_OPTIONS.lightAirGlare:SetValue(2)TEST_OPTIONS.lightAirHaze:SetValue(4)
TEST_OPTIONS.lightAirColor:SetValueRGB(Color3.new(.4,.3,.8))
TEST_OPTIONS.lightAirColorRainbow:SetValue(true)
TEST_OPTIONS.lightDepth:SetValue(true)TEST_OPTIONS.lightFocusDistance:SetValue(30)
TEST_OPTIONS.lightFocusRadius:SetValue(15)TEST_OPTIONS.lightNearBlur:SetValue(.2)TEST_OPTIONS.lightFarBlur:SetValue(.7)
TEST_OPTIONS.lightBloomSize:SetValue(46)TEST_OPTIONS.lightBloomThreshold:SetValue(.3)
TEST_OPTIONS.lightRaySpread:SetValue(.7)TEST_OPTIONS.lightReplaceEffects:SetValue(true)
assert(TEST_SERVICES.Lighting.ClockTime==17.2 and not TEST_SERVICES.Lighting.GlobalShadows)
assert(GETE('PV_ManualAtmosphere').Density==.6 and GETE('PV_Depth').FarIntensity==.7)
assert(GETE('PV_Bloom').Size==46 and GETE('PV_Rays').Spread==.7 and not TEST_NATIVE_BLOOM.Enabled)
TEST_OPTIONS.skyHaze:SetValue(true)
assert(not TEST_SERVICES.Lighting:FindFirstChild('PV_ManualAtmosphere')and TEST_SERVICES.Lighting.FogEnd==1000000,'Remove haze conflicts with editor')
TEST_OPTIONS.lightAtmosphere:SetValue(false)TEST_OPTIONS.lightAtmosphere:SetValue(true)
TEST_OPTIONS.skyHaze:SetValue(false)
assert(GETE('PV_ManualAtmosphere').Density==.6,'manual atmosphere failed to resume after haze override')
TEST_OPTIONS.lightEnvironment:SetValue(false)assert(TEST_SERVICES.Lighting.ClockTime==12,'environment layer not released')
TEST_OPTIONS.lightAtmosphere:SetValue(false)assert(TEST_NATIVE_AIR.Density==.25 and not TEST_SERVICES.Lighting:FindFirstChild('PV_ManualAtmosphere'))
TEST_OPTIONS.lightDepth:SetValue(false)assert(not GETE('PV_Depth').Enabled)
TEST_OPTIONS.lightReplaceEffects:SetValue(false)assert(TEST_NATIVE_BLOOM.Enabled)
TEST_OPTIONS.lightEnvironment:SetValue(true)TEST_OPTIONS.lightAtmosphere:SetValue(true)
TEST_OPTIONS.lightDepth:SetValue(true)TEST_OPTIONS.lightReplaceEffects:SetValue(true)
TEST_DRAIN()
""")
writes=d.writes
lua.execute(r"""
GETE('PV_ManualAtmosphere'):Destroy()GETE('PV_Depth'):Destroy()
TEST_SERVICES.RunService.Heartbeat:Fire(1.1)TEST_DRAIN()
assert(GETE('PV_ManualAtmosphere').Density==.6 and GETE('PV_Depth').FocusDistance==30,'maintenance did not rebuild active editor effects')
""")
assert d.writes==writes,'effect recovery wrote configs'
path='PrimeVisuals/Configs/1234/autosave.json'
expected=copy.deepcopy(json.loads(d.files[path])['payload']['values'])
assert len(expected)==353
lua.execute("TEST_ACTIONS['Unload script']();assert(TEST_NATIVE_AIR.Density==.25 and TEST_NATIVE_BLOOM.Enabled)")
# Cold startup restores extra values, active flags and edited sky, no action replay required.
lua2,*_=session(d)
lua2.execute(r"""
assert(TEST_OPTIONS.lightEnabled.Value and TEST_OPTIONS.lightEnvironment.Value and TEST_OPTIONS.lightAtmosphere.Value and TEST_OPTIONS.lightDepth.Value)
assert(TEST_SERVICES.Lighting.ClockTime==17.2 and not TEST_SERVICES.Lighting.GlobalShadows)
assert(TEST_SERVICES.Lighting:FindFirstChild('PV_ManualAtmosphere').Density==.6)
assert(TEST_SERVICES.Lighting:FindFirstChild('PV_Depth').FocusDistance==30)
assert(TEST_SERVICES.Lighting:FindFirstChild('PV_Bloom').Threshold==.3)
assert(TEST_OPTIONS.lightAirColorRainbow.Value)
assert(TEST_OPTIONS.lightAirColor.Value.R==.4)
TEST_DRAIN()
""")
actual=json.loads(d.files[path])['payload']['values']
for key,value in expected.items():
 if key.startswith('light'):assert actual[key]==value,key
print('PASS live advanced environment/atmosphere/Bloom/rays/DOF, boolean false copy, all 353 keys and cold-start restore')
# Old profiles have no new keys; validation fills defaults without enabling new effects.
old=Disk();old.files=copy.deepcopy(d.files);old.folders=set(d.folders)
for path,content in list(old.files.items()):
 if path.endswith(('autosave.json','autosave.backup.json')):
  doc=json.loads(content)
  for key in list(doc['payload']['values']):
   if key.startswith('light')and key not in {'lightEnabled','lightBrightness','lightExposure','lightSaturation','lightContrast','lightTint','lightTintRainbow','lightBloom','lightRays','lightBlur'}:doc['payload']['values'].pop(key)
  old.files[path]=json.dumps(doc)
lua3,*_=session(old)
lua3.execute("assert(TEST_OPTIONS.lightEnabled.Value and not TEST_OPTIONS.lightEnvironment.Value and not TEST_OPTIONS.lightAtmosphere.Value and not TEST_OPTIONS.lightDepth.Value)")
print('PASS legacy profiles missing every new lighting key keep old manual behavior')
