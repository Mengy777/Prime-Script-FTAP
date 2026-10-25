from support import Disk,session,ROOT
import struct,zlib
for name in ('vortex-demon-v1.png','visuals-phoenix-v1.png'):
 data=(ROOT/'assets'/name).read_bytes()
 assert data[:8]==b'\x89PNG\r\n\x1a\n'
 assert struct.unpack('>II',data[16:24])==(1254,1254) and data[25]==6
 offset=8
 while offset<len(data):
  size=struct.unpack('>I',data[offset:offset+4])[0]
  chunk=data[offset+4:offset+8+size]
  crc=struct.unpack('>I',data[offset+8+size:offset+12+size])[0]
  assert zlib.crc32(chunk)&0xffffffff==crc
  offset+=size+12
print('PASS generated assets: 1254x1254 RGBA PNGs and all PNG chunk CRCs')
lua,_,_,_=session(Disk(),execute=False)
factory=lua.execute((ROOT/'lib/AnimatedEmblem.lua').read_text(encoding='utf-8-sig'))
lua.globals().FACTORY=factory
lua.execute(r'''
NumberSequenceKeypoint={new=function(t,v)return {Time=t,Value=v}end}
CACHE={} REQUESTS=0 WRITES=0 ASSET_CALLS=0 WARNINGS=0
PNG=string.char(137)..'PNG\r\n'..string.char(26)..'\n'..'test image bytes'
warn=function() WARNINGS=WARNINGS+1 end
readfile=function(path) if not CACHE[path] then error('missing') end return CACHE[path] end
writefile=function(path,data) if WRITE_ERROR then error('disk blocked') end WRITES=WRITES+1 CACHE[path]=data end
isfolder=function()return true end makefolder=function()end
getcustomasset=function(path) ASSET_CALLS=ASSET_CALLS+1 return 'rbxasset://cache/'..path end
VISIBLE=true
function OPTIONS(style)
 local parent=Instance.new('Frame') parent.Name='Scene' parent.Parent=TEST_SERVICES.Players.LocalPlayer
 local header=Instance.new('ImageLabel') header.ZIndex=3 header.Visible=true header.Parent=parent
 local old=Instance.new('Frame') old.Name='PrimePrism' old.Visible=true old.Parent=header
 return {Parent=parent,Header=header,Name='Emblem',Style=style or 'demon',Accent=Color3.new(1,0,0),
  URL='test://emblem.png',CacheName='fixture.png',Bytes=#PNG,IsVisible=function()return VISIBLE end}
end
game.HttpGet=function(_,url) assert(url=='test://emblem.png') REQUESTS=REQUESTS+1 return PNG end
A=FACTORY(OPTIONS())
assert(A.TextureReady and not A.Ready and REQUESTS==1 and WRITES==1)
assert(A.Base.ResampleMode==Enum.ResamplerMode.Default and A.Base.Image:find('rbxasset://',1,true))
A.Base.IsLoaded=true
assert(A.Ready and A.Base.ImageTransparency==0)
local g=A.Sheen:FindFirstChildOfClass('UIGradient')
A:Step(1/120) assert(g.Offset==nil)
A:Step(0.04) local offset=g.Offset assert(offset~=nil)
VISIBLE=false A:Step(2) assert(g.Offset==offset)
VISIBLE=true A:Step(0.04) assert(g.Offset~=offset)
A:Destroy() assert(A.Destroyed and A.Root.Parent==nil)
local after=g.Offset A:Step(1) assert(g.Offset==after)
B=FACTORY(OPTIONS('phoenix')) assert(B.TextureReady and REQUESTS==1 and WRITES==1)
B:Destroy()
-- Cache corruption must trigger one repair, not per-frame downloads.
CACHE['PrimeVortex/Assets/fixture.png']='broken'
C=FACTORY(OPTIONS()) assert(C.TextureReady and REQUESTS==2 and WRITES==2)
C:Destroy()
CACHE={} game.HttpGet=function() REQUESTS=REQUESTS+1 return '<html>bad response</html>' end
D=FACTORY(OPTIONS()) assert(D.Error and not D.TextureReady and not D.Destroyed and D.Root.Parent)
D:Step(0.1) D:Destroy()
CACHE={} WRITE_ERROR=true game.HttpGet=function() return PNG end
E=FACTORY(OPTIONS()) assert(E.Error and not E.TextureReady) E:Destroy() WRITE_ERROR=false
getcustomasset=nil
F=FACTORY(OPTIONS()) assert(F.Error and F.Root:FindFirstChild('NativeEmblemFallback').Visible~=false) F:Destroy()
-- Unload while HTTP is pending: the request may finish, but it cannot touch a destroyed GUI or create a cache.
getcustomasset=function(path)return 'rbxasset://cache/'..path end
PENDING={} task.spawn=function(fn)table.insert(PENDING,fn)end
CACHE={} local before=WRITES
game.HttpGet=function() G:Destroy() return PNG end
G=FACTORY(OPTIONS()) PENDING[1]()
assert(G.Destroyed and not G.TextureReady and WRITES==before)
assert(WARNINGS==3)
''')
print('PASS real emblem module: cache miss/hit/repair, deferred IsLoaded reveal, 30Hz throttle, hidden pause, no late writes after unload, invalid HTTP/files/API fallbacks and cleanup')
