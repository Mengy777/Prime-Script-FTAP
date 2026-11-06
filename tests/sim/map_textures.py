from support import Disk,session,ROOT
import struct
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
local config={Catalog={Styles={Test={File='test.png',Bytes=#PNG,ColorMap='123456'}}},MaterialService=variants,AssetBase='test://textures/',ImageId=function(v)return v end,Patch=function(f,o,k,v)o[k]=v end,Unpatch=function()end}
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
assert(api4:GetImage('Test')=='rbxassetid://123456')api4:Destroy()tasks[1]()
assert(writes==initialWrites,'unloaded texture task wrote cache')
''')
print('PASS binary image download/cache, one request per file, request fallback, documented Roblox image fallback and cancellation before cache mutation')
for path in (ROOT/'assets/map-textures').glob('*.png'):
 data=path.read_bytes()
 assert data[:8]==b'\x89PNG\r\n\x1a\n'and struct.unpack('>II',data[16:24])==(512,512)
print('PASS eight authored 512px PNG texture files have valid headers/dimensions')
