from support import Disk, session, ROOT

disk=Disk()
STRICT_DROPDOWN='''
local createLibrary=TEST_NEW_LIBRARY
TEST_NEW_LIBRARY=function()
 local lib=createLibrary()
 setmetatable(lib.Options,{__newindex=function(options,key,widget)
  rawset(options,key,widget)
  if key~='visualPreset' then return end
  local setValue,setValues=widget.SetValue,widget.SetValues
  function widget:SetValue(value)
   if value~=nil and not table.find(self.Values,value) then return end
   setValue(self,value)
  end
  function widget:SetValues(values)
   setValues(self,values)
   if self.Value~=nil and not table.find(values,self.Value) then setValue(self,nil) end
  end
 end})
 return lib
end
'''
lua,source,_,_=session(disk,execute=False)
lua.execute(STRICT_DROPDOWN)
lua.globals().CATALOG_SOURCE=(ROOT/'lib/ShaderCatalog.lua').read_text(encoding='utf8')
lua.execute('''
CATALOG=assert(loadstring(CATALOG_SOURCE))()
local count=0 local sources={}
for name,data in pairs(CATALOG) do
 count=count+1 sources[data.source]=(sources[data.source] or 0)+1
 assert(name:find(data.source,1,true)==1 and type(data.light)=='table' and type(data.effects)=='table')
end
assert(count==42 and sources.Mercury==20 and sources.SAVITAR==7 and sources.Fosfor==5 and sources.Eris==5 and sources['Silent Target']==5)
-- Independent source anchors include surprising original values, not inferred names.
assert(CATALOG['Eris / Ночь'].light.ClockTime==12)
assert(CATALOG['Silent Target / Twilight'].light.Brightness==3.5)
assert(CATALOG['SAVITAR / Scarlet Atmosphere'].light.Brightness==2.14)
assert(CATALOG['SAVITAR / Scarlet Atmosphere'].sky.SkyboxUp=='rbxassetid://323493360')
assert(CATALOG['SAVITAR / Golden Hour'].sky.StarCount==1200 and CATALOG['SAVITAR / Golden Hour'].sky.MoonAngularSize==11)
assert(CATALOG['Eris / Ночь'].light.GlobalShadows==false)
assert(CATALOG['Fosfor / Rainy Shader'].light.Brightness==-.1)
assert(CATALOG['Mercury / Rain'].clouds.Cover==.9)
FOREIGN_CC=Instance.new('ColorCorrectionEffect') FOREIGN_CC.Enabled=true FOREIGN_CC.Parent=TEST_SERVICES.Lighting
FOREIGN_ATMO=Instance.new('Atmosphere') FOREIGN_ATMO.Density=.43 FOREIGN_ATMO.Haze=2 FOREIGN_ATMO.Glare=.2 FOREIGN_ATMO.Parent=TEST_SERVICES.Lighting
''')
lua.execute(source)
lua.execute('''
local L=TEST_SERVICES.Lighting local originalBrightness=L.Brightness
TERRAIN=workspace:FindFirstChildOfClass('Terrain')
if not TERRAIN then TERRAIN=Instance.new('Terrain') TERRAIN.Parent=workspace end
NATIVE_CLOUDS=TERRAIN:FindFirstChildOfClass('Clouds') or Instance.new('Clouds') NATIVE_CLOUDS.Cover=.1 NATIVE_CLOUDS.Density=.2 if not NATIVE_CLOUDS.Parent then NATIVE_CLOUDS.Parent=TERRAIN end
local function same(a,b)
 if type(a)=='table' and a.R~=nil then return a.R==b.R and a.G==b.G and a.B==b.B end
 return a==b
end
local function owned()
 local out={} for _,o in ipairs(L:GetChildren()) do if o.Name:find('PV_Preset',1,true)==1 then out[#out+1]=o end end return out
end
TEST_OPTIONS.visualPresetEnabled:SetValue(true)
for name,data in pairs(CATALOG) do
 TEST_OPTIONS.visualPreset:SetValue(name)
 assert(TEST_OPTIONS.visualPreset.Value==name,'selection failed: '..name)
 for k,value in pairs(data.light) do assert(same(L[k],value),name..' / '..k) end
 assert(FOREIGN_CC.Enabled==false and FOREIGN_ATMO.Parent==nil,'foreign filters stacked')
 local objects=owned()
 for _,definition in ipairs(data.effects) do
  local found
  for _,o in ipairs(objects) do if o.ClassName==definition[1] then found=o break end end
  assert(found,name..' missing '..definition[1])
  for k,value in pairs(definition[2]) do assert(same(found[k],value),name..' effect '..k) end
 end
 if data.sky then
  local skies=0 for _,o in ipairs(L:GetChildren()) do if o:IsA('Sky') then skies=skies+1 end end
  assert(skies==1,'competing skies')
  for k,value in pairs(data.sky) do
   for _,o in ipairs(objects) do if o:IsA('Sky') then assert(same(o[k],value),name..' sky '..k) end end
  end
 end
 if data.clouds then for k,value in pairs(data.clouds) do assert(same(NATIVE_CLOUDS[k],value),name..' clouds '..k..' actual='..tostring(NATIVE_CLOUDS[k])..' expected='..tostring(value)..' parent='..tostring(NATIVE_CLOUDS.Parent==TERRAIN)) end end
end
TEST_OPTIONS.visualPresetEnabled:SetValue(false)
assert(#owned()==0 and FOREIGN_CC.Enabled and FOREIGN_ATMO.Density==.43)
assert(FOREIGN_CC.Parent==L and FOREIGN_ATMO.Parent==L and TEST_ORIGINAL_SKY.Parent==L)
assert(same(L.Brightness,originalBrightness))
assert(NATIVE_CLOUDS.Cover==.1 and NATIVE_CLOUDS.Density==.2)
TEST_OPTIONS.visualPreset:SetValue('Fosfor / Adaptive Map') TEST_OPTIONS.visualPresetEnabled:SetValue(true)
TEST_LIBRARY.Scheme.AccentColor=Color3.fromRGB(10,20,30)
TEST_SERVICES.RunService.Heartbeat:Fire(.6)
assert(same(L.FogColor,TEST_LIBRARY.Scheme.AccentColor),'adaptive accent did not update')
TEST_OPTIONS.visualPresetEnabled:SetValue(false)
-- Persist an active shader while browsing a different collection.
TEST_OPTIONS.visualPreset:SetValue('SAVITAR / Neon Night')
TEST_OPTIONS.shaderCollection:SetValue('Mercury')
TEST_OPTIONS.visualPresetEnabled:SetValue(true)
TEST_DRAIN()
TEST_ACTIONS['Unload script']()
assert(FOREIGN_CC.Parent==L and FOREIGN_CC.Enabled and TEST_ORIGINAL_SKY.Parent==L)
''')
lua,source,_,_=session(disk,execute=False)
lua.execute(STRICT_DROPDOWN)
lua.execute(source)
lua.execute('''
assert(TEST_OPTIONS.visualPreset.Value=='SAVITAR / Neon Night')
assert(TEST_OPTIONS.shaderCollection.Value=='Mercury')
assert(TEST_OPTIONS.visualPresetEnabled.Value)
TEST_ACTIONS['Unload script']()
''')
print('PASS 42 catalog definitions, source anchors, every preset application, effect replacement/restoration, sky exclusivity, profile restart and unload')
