from support import Disk,session,ROOT
import struct,json,hashlib
from PIL import Image
from pathlib import Path
D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(r'''
local map=workspace:FindFirstChild('Map')
GRASS=Instance.new('Part')GRASS.Material=Enum.Material.Grass GRASS.Color=Color3.new(.3,.6,.2)GRASS.MaterialVariant='nativeVariant'GRASS.Parent=map
MESH=Instance.new('MeshPart')MESH.Material=Enum.Material.Rock MESH.TextureID='nativeMeshTexture'MESH.MaterialVariant=''MESH.Parent=map
DECAL=Instance.new('Decal')DECAL.Transparency=.2 DECAL.Parent=GRASS
SURFACE=Instance.new('SurfaceAppearance')SURFACE.ColorMap='originalMap'SURFACE.Parent=MESH
TOY=Instance.new('Part')TOY.Material=Enum.Material.Grass TOY.MaterialVariant='toy' TOY.Parent=workspace
NATIVE_VARIANT=Instance.new('MaterialVariant')NATIVE_VARIANT.Name='nativeVariant'NATIVE_VARIANT.Parent=TEST_SERVICES.MaterialService
''')
# Real PBR catalogue structure, synthetic binary bodies in transport mocks only.
lua.globals().TEST_PBR_CATALOG=lua.execute((ROOT/'lib/MapTextureCatalog.lua').read_text(encoding='utf-8'))
lua.execute(r'''
local cache={}local previousRead,previousWrite=readfile,writefile
for _,style in pairs(TEST_PBR_CATALOG.Styles)do for _,image in pairs(style.Maps)do image.Bytes=32 end end
readfile=function(path)if path:find('PrimeVisuals/Assets/',1,true)then assert(cache[path])return cache[path]end return previousRead(path)end
writefile=function(path,data)if path:find('PrimeVisuals/Assets/',1,true)then cache[path]=data else previousWrite(path,data)end end
getcustomasset=function(path)return 'rbxasset://cache/'..path end
local previousHttp=game.HttpGet
game.HttpGet=function(self,url)
 if url:find('MapTextureCatalog.lua',1,true)then return 'return TEST_PBR_CATALOG'end
 if url:find('/assets/map-pbr/',1,true)then
  if url:find('.png',1,true)then return string.char(137)..'PNG\r\n'..string.char(26)..'\n'..string.rep('x',24)end
  return string.char(255,216,255)..string.rep('x',29)
 end
 return previousHttp(self,url)
end
''')
lua.execute(source)
lua.globals().CATALOG=lua.execute((ROOT/'lib/MapTextureCatalog.lua').read_text(encoding='utf-8'))
lua.execute(r'''
assert(TEST_OPTIONS.mapMode.Value=='Classic materials'and GRASS.MaterialVariant=='nativeVariant')
TEST_OPTIONS.mapGrassMaterial:SetValue('Neon')TEST_OPTIONS.mapAppearanceEnabled:SetValue(true)
assert(GRASS.Material==Enum.Material.Neon)
TEST_OPTIONS.mapMode:SetValue('Custom textures')
assert(GRASS.Material==Enum.Material.Grass,'texture mode changed native base material/physics')
for _,theme in ipairs(CATALOG.Themes)do
 TEST_OPTIONS.mapTexturePreset:SetValue(theme.Name)TEST_ACTIONS['Apply map palette']()
 assert(GRASS.MaterialVariant:find('PVMap_',1,true)and MESH.MaterialVariant:find('PVMap_',1,true),theme.Name)
 assert(GRASS.Material==Enum.Material.Grass and TOY.MaterialVariant=='toy')
 assert(DECAL.Transparency==1 and SURFACE.Parent==nil and MESH.TextureID=='')
 assert(TEST_OPTIONS.mapTextureGrassStyle.Value==theme.Styles[3])
end
local service=TEST_SERVICES.MaterialService local count=#service:GetChildren()
assert(count<=10,'variants accumulated on preset changes: '..count)
TEST_OPTIONS.mapTextureGrassScale:SetValue(24)
local variant=service:FindFirstChild(GRASS.MaterialVariant)assert(variant and variant.StudsPerTile==24)
variant:Destroy()TEST_SERVICES.RunService.Heartbeat:Fire(1.1)
assert(service:FindFirstChild(GRASS.MaterialVariant),'removed local material did not recover')
TEST_OPTIONS.mapTextureGrassStyle:SetValue('Custom image')TEST_OPTIONS.mapTextureGrassImage:SetValue('123456789')
variant=service:FindFirstChild(GRASS.MaterialVariant)assert(variant.ColorMap=='rbxassetid://123456789')
TEST_OPTIONS.mapMode:SetValue('Classic materials')
assert(GRASS.Material==Enum.Material.Neon and GRASS.MaterialVariant=='nativeVariant')
assert(DECAL.Transparency==.2 and SURFACE.Parent==MESH and MESH.TextureID=='nativeMeshTexture')
assert(#service:GetChildren()==1 and NATIVE_VARIANT.Parent==service)
TEST_OPTIONS.mapMode:SetValue('Custom textures')
assert(GRASS.Material==Enum.Material.Grass and GRASS.MaterialVariant~='nativeVariant')
TEST_DRAIN()TEST_ACTIONS['Unload script']()
assert(GRASS.MaterialVariant=='nativeVariant'and MESH.TextureID=='nativeMeshTexture'and SURFACE.Parent==MESH and #service:GetChildren()==1 and NATIVE_VARIANT.Parent==service)
''')
print('PASS twenty themes, native materials/physics and toys untouched, bounded variants, texture scale/custom ID, recreation, independent classic mode and full decoration restore')
lua,_,_,_=session(D)
lua.execute("assert(TEST_OPTIONS.mapMode.Value=='Custom textures' and TEST_OPTIONS.mapTextureGrassImage.Value=='123456789' and TEST_OPTIONS.mapTextureGrassScale.Value==24); TEST_ACTIONS['Unload script']()")
print('PASS texture mode, category choices, image ID and scale survive cold restore')

# Binary transport is exercised in Lua, keeping PNG bytes away from UTF-8 mock disk hooks.
lua,_,_,_=session(Disk(),execute=False)
lua.globals().TEXTURE_FACTORY=lua.execute((ROOT/'lib/MapTextures.lua').read_text(encoding='utf-8'))
lua.execute(r'''
PNG=string.char(137)..'PNG\r\n'..string.char(26)..'\n'..'fixture'
local disk={}local writes,requests=0,0 local variants=Instance.new('Folder')
readfile=function(p)assert(disk[p])return disk[p]end writefile=function(p,s)writes=writes+1 disk[p]=s end
isfolder=function()return true end makefolder=function()end
getcustomasset=function(p)return 'rbxasset://cache/'..p end
game.HttpGet=function()requests=requests+1 return PNG end
local config={Catalog={Styles={Test={Maps={ColorMap={File='test.png',Bytes=#PNG}}}}},MaterialService=variants,AssetBase='test://textures/',ImageId=function(v)return v end,Patch=function(f,o,k,v)o[k]=v end,Unpatch=function()end}
local api=TEXTURE_FACTORY(config)
assert(api:GetImage('Test'):find('rbxasset://cache/',1,true))
assert(api:GetImage('Test'):find('rbxasset://cache/',1,true)and requests==1 and writes==1)
api:Destroy()
local api2=TEXTURE_FACTORY(config)assert(api2:GetImage('Test'):find('rbxasset://cache/',1,true)and requests==1)api2:Destroy()
disk={}game.HttpGet=function()requests=requests+1 return '<html>bad response</html>'end
request=function()return{StatusCode=200,Body=PNG}end
local api3=TEXTURE_FACTORY(config)assert(api3:GetImage('Test'):find('rbxasset://cache/',1,true))api3:Destroy()
disk={}request=nil local tasks={}task.spawn=function(fn)tasks[#tasks+1]=fn end
local api4=TEXTURE_FACTORY(config)local initialWrites=writes
assert(api4:GetImage('Test')=='')api4:Destroy()tasks[1]()
assert(writes==initialWrites,'unloaded texture task wrote cache')
''')
print('PASS binary image download/cache, one request per file, request fallback, no stock-image substitution and cancellation before cache mutation')
manifest=json.loads((ROOT/'tools/pbr-texture-manifest.json').read_text())
assert len(manifest['Assets'])==35 and len({a['Library']for a in manifest['Assets']})==3
for asset in manifest['Assets']:
 assert all(k in asset['Maps']for k in ['ColorMap','NormalMap','RoughnessMap'])
 for image in asset['Maps'].values():
  path=ROOT/'assets/map-pbr'/image['File'];data=path.read_bytes()
  assert len(data)==image['Bytes']and hashlib.sha256(data).hexdigest()==image['SHA256']
  with Image.open(path)as im:assert max(im.size)==1024 and min(im.size)>=512
assert not list((ROOT/'assets/map-textures').glob('*.png'))
print('PASS35 downloaded PBR sets from3 libraries, all map hashes and1K dimensions; rejected generated assets absent')

lua.execute(r'''
task.spawn=function(fn)fn()end
local files={}readfile=function(p)assert(files[p])return files[p]end writefile=function(p,b)files[p]=b end
local normalBroken=true
game.HttpGet=function(_,url)if normalBroken and url:find('normal.png',1,true)then return 'bad'end return PNG end
local part=Instance.new('Part')part.Material=Enum.Material.Grass part.MaterialVariant='native'
local service=Instance.new('Folder')local config={Catalog={Styles={PBR={Maps={ColorMap={File='color.png',Bytes=#PNG},NormalMap={File='normal.png',Bytes=#PNG},RoughnessMap={File='rough.png',Bytes=#PNG}}}}},
 MaterialService=service,AssetBase='test://',ImageId=function(v)return v end,Patch=function(f,o,k,v)o[k]=v end,Unpatch=function()end}
local api=TEXTURE_FACTORY(config)
assert(not api:Apply(part,'Grass','PBR',8,''))
assert(part.MaterialVariant=='native'and #service:GetChildren()==0,'partial PBR or generic substitute applied')
normalBroken=false api:RetryFailed()
assert(api:Apply(part,'Grass','PBR',8,''))
local variant=service:FindFirstChild(part.MaterialVariant)
assert(variant.ColorMap~=''and variant.NormalMap~=''and variant.RoughnessMap~='')api:Destroy()
-- Cooperative HTTP: seven pending images, at most three live transport calls.
local threads={}local active,maximum,total=0,0,0
task.spawn=function(fn)local co=coroutine.create(fn)threads[#threads+1]=co local ok,msg=coroutine.resume(co)assert(ok,msg)end
game.HttpGet=function()active=active+1 total=total+1 maximum=math.max(maximum,active)coroutine.yield('HTTP');active=active-1 return PNG end
files={}local styles={}
for i=1,7 do styles['Style'..i]={Maps={ColorMap={File='bounded'..i..'.png',Bytes=#PNG}}}end
config.Catalog={Styles=styles}
local bounded=TEXTURE_FACTORY(config)
for i=1,7 do assert(bounded:GetImage('Style'..i)=='')end
assert(active==3 and #threads==3)
for step=1,10 do for _,co in ipairs(threads)do if coroutine.status(co)=='suspended'then local ok,msg=coroutine.resume(co)assert(ok,msg)end end end
assert(maximum==3 and active==0 and total==7)
for i=1,7 do assert(bounded:GetImage('Style'..i)~='')end
bounded:Destroy()
''')
print('PASS all required PBR maps must load before replacement, failed-map retry, no fake fallback and bounded three-worker downloads')

# Removed 3.2.2a texture names must not discard unrelated autosaved settings.
migration_disk=Disk();migration_lua,_,_,_=session(migration_disk)
migration_lua.execute("TEST_OPTIONS.cameraFOV:SetValue(99); TEST_DRAIN(); TEST_ACTIONS['Unload script']()")
changed=0
for path,body in list(migration_disk.files.items()):
 try: profile=json.loads(body)
 except (ValueError,TypeError): continue
 if isinstance(profile,dict) and isinstance(profile.get('payload',{}).get('values'),dict):
  profile['scriptVersion']='3.2.2a'
  profile['payload']['values']['mapTextureGrassStyle']='Circuit traces'
  profile['payload']['values']['mapTexturePreset']='Dreamcore'
  migration_disk.files[path]=json.dumps(profile);changed+=1
assert changed>0
migration_lua,_,_,_=session(migration_disk)
migration_lua.execute("assert(TEST_OPTIONS.cameraFOV.Value==99); assert(TEST_OPTIONS.mapTextureGrassStyle.Value=='Original'); assert(TEST_OPTIONS.mapTexturePreset.Value=='Dreamcore Atrium')")
print('PASS removed texture names migrate to original surfaces/new theme while unrelated autosave settings survive')
