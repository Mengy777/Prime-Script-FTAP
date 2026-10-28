from support import Disk,session,ROOT
import json,hashlib

# Loading uses real collection/main handlers; GetObjects is a synthetic asset fixture.
d=Disk();lua,source,_,_=session(d)
lua.execute(r"""
TEST_MODEL_CALLS=0 TEST_MODEL_DESTROYED=0
local faces={'Bk','Dn','Ft','Lf','Rt','Up'}
game.GetObjects=function(_,url)
 TEST_MODEL_CALLS=TEST_MODEL_CALLS+1 TEST_MODEL_URL=url
 local package=Instance.new('Model')
 local sky=Instance.new('Sky')sky.Parent=package
 for i,face in ipairs(faces)do sky['Skybox'..face]='rbxassetid://'..tostring(900000+i)end
 sky.CelestialBodiesShown=false sky.SunAngularSize=0 sky.MoonAngularSize=0 sky.StarCount=0
 sky.SunTextureId='rbxassetid://1'sky.MoonTextureId='rbxassetid://2'
 package.Destroying:Connect(function()TEST_MODEL_DESTROYED=TEST_MODEL_DESTROYED+1 end)
 return {package}
end
local function sky()return TEST_SERVICES.Lighting:FindFirstChild('PrimeVisualsSky')end
for name,id in pairs({['Rainbow Galaxy']='4943578383',['Dark Matter']='110290405998332',['Milky Way']='545702970'})do
 TEST_OPTIONS.collectionSky:SetValue(name)TEST_ACTIONS['Apply selected skybox']()
 assert(TEST_MODEL_URL=='rbxassetid://'..id,'wrong Creator Store model')
 assert(sky().SkyboxBk=='rbxassetid://900001'and sky().SkyboxUp=='rbxassetid://900006','model faces not resolved')
end
assert(TEST_MODEL_CALLS==3 and TEST_MODEL_DESTROYED==3,'unparented model cleanup failed')
TEST_OPTIONS.collectionSky:SetValue('Dark Matter')TEST_ACTIONS['Apply selected skybox']()
assert(TEST_MODEL_CALLS==3,'successful model not cached')
TEST_OPTIONS.collectionSky:SetValue('Purple Radiance')TEST_ACTIONS['Apply selected skybox']()
assert(sky().SkyboxBk=='rbxassetid://570557514'and sky().SkyboxUp=='rbxassetid://570557727')
TEST_OPTIONS.collectionSky:SetValue('Dark Matter')TEST_ACTIONS['Apply selected skybox']()
TEST_DRAIN()TEST_ACTIONS['Unload script']()
""")
# Saved resolved faces restore with no second model request on cold startup.
lua2,*_=session(d)
lua2.execute("assert(TEST_OPTIONS.collectionSky.Value=='Dark Matter'); assert(TEST_SERVICES.Lighting:FindFirstChild('PrimeVisualsSky').SkyboxUp=='rbxassetid://900006')")
print('PASS exact model IDs, six-face extraction, model disposal, success cache, static Purple Radiance and persisted resolved faces')

# A failure never removes the previous working sky.
lua3,*_=session(Disk())
lua3.execute(r"""
TEST_OPTIONS.collectionSky:SetValue('Crimson')TEST_ACTIONS['Apply selected skybox']()
local sky=TEST_SERVICES.Lighting:FindFirstChild('PrimeVisualsSky')local prior=sky.SkyboxBk
game.GetObjects=function()error('fixture unavailable')end
TEST_OPTIONS.collectionSky:SetValue('Milky Way')TEST_ACTIONS['Apply selected skybox']()
assert(sky.SkyboxBk==prior,'failed model replaced the current sky')
""")
print('PASS inaccessible model leaves existing sky unchanged')

# All old selected names still validate and migrate, even in old named-profile payloads.
for old,new in {'Vaporwave':'Rainbow Galaxy','Lavender Gradient':'Purple Radiance','Rose Gradient':'Dark Matter','Golden Hour':'Milky Way'}.items():
 disk=Disk();initial,*_=session(disk);initial.execute('TEST_DRAIN()')
 for path,content in list(disk.files.items()):
  if path.endswith(('autosave.json','autosave.backup.json')):
   doc=json.loads(content);doc['payload']['values']['collectionSky']=old;disk.files[path]=json.dumps(doc)
 restored,*_=session(disk)
 assert restored.globals().TEST_OPTIONS.collectionSky.Value==new,(old,new)
print('PASS four removed collection names migrate without invalidating saved settings')

# Original thirteen and three accepted additions must remain byte-for-byte equivalent data.
from lupa import LuaRuntime
runtime=LuaRuntime()
current=runtime.execute((ROOT/'lib/VisualPresets.lua').read_text(encoding='utf-8'))['Skies']
expected={'Nebula': '11ce57e8bffe61fbe3ba566fd127bd2de95e6ce0d86a7a46c1e4fd30b246eeb7', 'Crimson': 'e2fdfa115872c08fc77eb2876589c7a9591394bff36d5bba142dacc1629a9832', 'Midnight': '8437ef75038cfa635a303c6a73b819d8f8e4f5a0620c2069715fb1cb0d046ed2', 'Arctic': '42fcb592d0c024a3e805a0efef9bdeac0891130a04ade5bc033081b2e300eb11', 'Deep Space': '6b7e644dd9b577e6d562c176f566f5f916b11d9c8a1e2e8224c35f1711b29f09', 'Stylized': 'dba8e64c0aeef013524879892b3b9cff2153c299225dc1d7862b5ba8e8744180', 'Blossom': 'c4eac4ae266219315ec6d9fc65fdca0936c174e88147893d1f7f855d4a0035bd', 'Blue Horizon': '30467489d6fbdc231010702548cd4790cb3bf41166977c04991fcb9ca98ca326', 'Galaxy': '533d7324ef814d38cb80beff9e7011519319b56e8631daca3010807b3c23ce4e', 'Overcast': '7015f779ea7dad833c9d1abdebc7ef03f03dbc3222533362401bb01ab8d1c8b9', 'Pink Morning': 'e68d24e3da48dc98b0137a5f88bd18b35df1615c32366d0b7371a6b89efe01d2', 'Sunset': '86b476ce2c24d2371642a0d9f449a779024b605e330fd529678d0e01022d9ddc', 'Storm': 'fad154174d608abddb3742a989e125fb3787129eaf31511cdfbec57a7ea6a116', 'Frostfall': '392a7a6fcf9934d61df13de8b596c198165dd2d9d36a8c046e7baa60ff78fada', 'Purple Nebula': '3ac10476de3151dea46534d328f0a652b8858e795bbc0c53cc2b56f30b4ca1a6', 'Default': '6268032d17f936d01f46e62e68a217ac529aad0d7cbfbe949239391f379dba0b'}
for name,digest in expected.items():
 assert hashlib.sha256(json.dumps(dict(current[name].items()),sort_keys=True).encode()).hexdigest()==digest,name
print('PASS all 16 retained sky definitions unchanged')
