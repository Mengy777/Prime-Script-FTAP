from support import Disk,session,ROOT
import struct,zlib
for filename in ('vortex-demon-v1.png','visuals-phoenix-v1.png'):
 data=(ROOT/'assets'/filename).read_bytes()
 assert data[:8]==b'\x89PNG\r\n\x1a\n' and struct.unpack('>II',data[16:24])==(1254,1254) and data[25]==6
print('PASS original high-resolution RGBA PNG assets unchanged')
lua,_,_,_=session(Disk(),execute=False)
lua.globals().FACTORY=lua.execute((ROOT/'lib/AnimatedEmblem.lua').read_text(encoding='utf-8-sig'))
lua.execute(r'''
PNG=string.char(137)..'PNG\r\n'..string.char(26)..'\n'..'fixture'
CACHE={} DOWNLOADS=0 WRITES=0 VISIBLE=true
readfile=function(path) if not CACHE[path] then error('missing') end return CACHE[path] end
writefile=function(path,data) WRITES=WRITES+1 CACHE[path]=data end
isfolder=function()return true end makefolder=function()end
getcustomasset=function(path)return 'rbxasset://cache/'..path end
function OPTIONS(style)
 local parent=Instance.new('Frame') parent.Parent=TEST_SERVICES.Players.LocalPlayer
 local header=Instance.new('ImageLabel') header.Parent=parent
 return {Parent=parent,Header=header,Style=style,Accent=Color3.new(1,0,0),URL='test://image',Bytes=#PNG,CacheName='test.png',IsVisible=function()return VISIBLE end}
end
game.HttpGet=function() DOWNLOADS=DOWNLOADS+1 return PNG end
A=FACTORY(OPTIONS('phoenix'))
assert(A.TextureReady and not A.Ready and A.Base.ImageTransparency==0 and A.Base.Image~='','PNG incorrectly hidden by IsLoaded')
assert(#A.Root:GetChildren()==3,'extra preview layers were not removed')
assert(#A.Icon:GetChildren()==8,'header icon should remain compact')
A.Base.IsLoaded=true assert(A.Ready)
local image=A.Base.Image local tint=A.Base.ImageColor3
A:Step(0.1) A:Step(0.1)
assert(A.Base.Image==image and A.Base.ImageColor3==tint,'static illustration was animated/tinted')
A:Destroy()
B=FACTORY(OPTIONS('demon')) assert(DOWNLOADS==1 and WRITES==1)
B:Step(0.1) local angle=B.Icon.Rotation assert(angle>0)
VISIBLE=false B:Step(2) assert(B.Icon.Rotation==angle)
VISIBLE=true B:Step(0.1) assert(B.Icon.Rotation>angle)
assert(#B.Icon:GetChildren()==6,'vortex icon is too complex') B:Destroy()
-- Binary request fallback and bad cache repair.
CACHE={} game.HttpGet=function()return 'bad HTTP body'end
request=function(info) assert(info.Method=='GET')return {StatusCode=200,Body=PNG}end
C=FACTORY(OPTIONS('demon')) assert(C.TextureReady and C.Base.ImageTransparency==0) C:Destroy()
CACHE={} request=function()return {StatusCode=500,Body='error'}end
D=FACTORY(OPTIONS('demon')) assert(D.Error and not D.TextureReady and D.Root.Parent) D:Destroy()
-- Late HTTP response after unload may not write or mutate the removed UI.
CACHE={} PENDING={} task.spawn=function(fn)table.insert(PENDING,fn)end
local previousWrites=WRITES
game.HttpGet=function() E:Destroy() return PNG end
E=FACTORY(OPTIONS('phoenix')); PENDING[1]()
assert(E.Destroyed and WRITES==previousWrites)
''')
print('PASS opaque static PNG without IsLoaded gate, compact rainbow/spinning header marks, cache/retry transport, hidden pause and unload cleanup')

lua.execute(r"""
task.spawn=function(fn)fn()end
CACHE={} PNG_ATTEMPTS=0
request=nil
game.HttpGet=function()
 PNG_ATTEMPTS=PNG_ATTEMPTS+1
 if PNG_ATTEMPTS<3 then error('temporary image HTTP failure') end
 return PNG
end
F=FACTORY(OPTIONS('phoenix'))
assert(F.TextureReady and PNG_ATTEMPTS==3 and F.Base.ImageTransparency==0)
F:Destroy()
""")
print('PASS transient PNG download failure succeeds on the third bounded attempt')
