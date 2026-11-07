from support import Disk,session
D=Disk();lua,_,_,_=session(D)
lua.execute(r"""
local screen=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeInputOverlay')
local root=screen:FindFirstChild('Keyboard')local input=TEST_SERVICES.UserInputService
assert(not screen.Enabled and not TEST_OPTIONS.inputOverlayEnabled.Value)
for _,name in ipairs({'R','W','A','S','D','E','Shift','Ctrl','Space','MouseButton1','MouseButton2','MouseButton3','WheelUp','WheelDown'})do assert(root:FindFirstChild(name),name)end
assert(not root:FindFirstChild('Q')and not root:FindFirstChild('Alt'))
TEST_OPTIONS.inputOverlayEnabled:SetValue(true)
local function event(name)return{UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode[name],Position=Vector3.zero}end
local r=root:FindFirstChild('R')assert(r.Position.X.Offset<root:FindFirstChild('W').Position.X.Offset and r.Position.Y.Offset==root:FindFirstChild('W').Position.Y.Offset)
input.InputBegan:Fire(event('R'))TEST_SERVICES.RunService.RenderStepped:Fire(.1)assert(r.BackgroundColor3.R>.3)input.InputEnded:Fire(event('R'))
local press=event('W')input.InputBegan:Fire(press,true)
TEST_SERVICES.RunService.RenderStepped:Fire(.1)
local w=root:FindFirstChild('W')local active=w.BackgroundColor3.R
input.InputEnded:Fire(press)TEST_SERVICES.RunService.RenderStepped:Fire(.1)
assert(w.BackgroundColor3.R<active,'key release did not animate')
input.InputBegan:Fire(event('LeftShift'))input.InputBegan:Fire(event('RightShift'))input.InputEnded:Fire(event('LeftShift'))
TEST_SERVICES.RunService.RenderStepped:Fire(.1)assert(root:FindFirstChild('Shift').BackgroundColor3.R>.3)
input.WindowFocusReleased:Fire()for i=1,5 do TEST_SERVICES.RunService.RenderStepped:Fire(.1)end
assert(root:FindFirstChild('Shift').BackgroundColor3.R<.11,'focus loss stuck key')
for _,name in ipairs({'MouseButton1','MouseButton2','MouseButton3'})do
 local e={UserInputType=Enum.UserInputType[name],Position=Vector3.zero}
 input.InputBegan:Fire(e)TEST_SERVICES.RunService.RenderStepped:Fire(.1)
 local zone=root:FindFirstChild(name)assert(zone:IsA('ImageLabel')and zone.ImageTransparency<.9 )
 input.InputEnded:Fire(e)
end
input.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseWheel,Position=Vector3.new(0,0,1)})
TEST_SERVICES.RunService.RenderStepped:Fire(.05)assert(root:FindFirstChild('WheelUp').ImageTransparency<.9)
input.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseWheel,Position=Vector3.new(0,0,-1)})
TEST_SERVICES.RunService.RenderStepped:Fire(.05)assert(root:FindFirstChild('WheelDown').ImageTransparency<.9)
local drag={UserInputType=Enum.UserInputType.MouseButton1,Position=Vector3.new(30,366,0)}
root.InputBegan:Fire(drag)input.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseMovement,Position=Vector3.new(406,256,0)})
assert(TEST_OPTIONS.inputOverlayX.Value==24)
input.InputEnded:Fire(drag)
assert(TEST_OPTIONS.inputOverlayX.Value==400 and TEST_OPTIONS.inputOverlayY.Value==250,tostring(TEST_OPTIONS.inputOverlayX.Value)..","..tostring(TEST_OPTIONS.inputOverlayY.Value))
TEST_OPTIONS.inputOverlayScale:SetValue(1.5)
TEST_OPTIONS.inputOverlayAccent:SetValueRGB(Color3.new(.8,.2,.3))
TEST_DRAIN()TEST_ACTIONS['Unload script']()assert(screen.Parent==nil)
""")
lua,_,_,_=session(D)
lua.execute(r"""
assert(TEST_OPTIONS.inputOverlayEnabled.Value and TEST_OPTIONS.inputOverlayScale.Value==1.5)
assert(TEST_OPTIONS.inputOverlayX.Value==400 and TEST_OPTIONS.inputOverlayY.Value==250,tostring(TEST_OPTIONS.inputOverlayX.Value)..","..tostring(TEST_OPTIONS.inputOverlayY.Value))
assert(TEST_OPTIONS.inputOverlayAccent.Value.R==.8)
TEST_OPTIONS.inputOverlayEnabled:SetValue(false)
TEST_ACTIONS['Unload script']()
""")
print('PASS overlay default off, exact keys, processed input, smooth press/release, dual modifiers, all mouse buttons/wheel, focus loss, final-only drag persistence, cold restore and unload')

# Exercise the actual lazy artwork/cache branch with module-local image/file APIs.
from pathlib import Path
from support import ROOT
from PIL import Image
files={p.name:p.stat().st_size for p in (ROOT/'assets/input-overlay').glob('*.png')}
for name in files:
 with Image.open(ROOT/'assets/input-overlay'/name)as img:
  assert img.mode=='RGBA' and img.size==(941,1672)
  img.verify()
D2=Disk();lua,source,_,_=session(D2,execute=False)
prefix="""local cached={}local getcustomasset=function(p)return 'rbxasset://test/'..p end
local readfile=function(p)return cached[p]end local writefile=function(p,b)cached[p]=b end
local isfolder=function()return true end local makefolder=function()end
"""
lua.globals().TEST_INPUT_ART_SOURCE=prefix+(ROOT/'lib/InputOverlay.lua').read_text(encoding='utf-8')
meta=','.join('["'+name+'"]='+str(size)for name,size in files.items())
lua.execute('local sizes={'+meta+'};TEST_MOUSE_FETCHES=0;local previous=game.HttpGet;game.HttpGet=function(self,url)if url:find("/lib/InputOverlay.lua",1,true)then return TEST_INPUT_ART_SOURCE elseif url:find("/assets/input-overlay/",1,true)then local n=url:match("/([^/]+)$");assert(sizes[n]);TEST_MOUSE_FETCHES=TEST_MOUSE_FETCHES+1;return string.char(137,80,78,71,13,10,26,10)..string.rep("x",sizes[n]-8)end return previous(self,url)end')
lua.execute(source)
lua.execute("""
assert(TEST_MOUSE_FETCHES==0,'disabled overlay fetched artwork')
TEST_OPTIONS.inputOverlayEnabled:SetValue(true)TEST_DRAIN()
local root=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeInputOverlay'):FindFirstChild('Keyboard')
assert(root:FindFirstChild('Mouse'):FindFirstChild('MouseArtwork').Image:find('gaming-mouse.png',1,true))
assert(not root:FindFirstChild('Mouse'):FindFirstChild('MouseFallback').Visible)
assert(TEST_MOUSE_FETCHES==6)
for _,name in ipairs({'MouseButton1','MouseButton2','MouseButton3','WheelUp','WheelDown'})do
 assert(root:FindFirstChild(name).Image~='' and root:FindFirstChild(name).ImageTransparency==1)
end
TEST_OPTIONS.inputOverlayEnabled:SetValue(false)TEST_OPTIONS.inputOverlayEnabled:SetValue(true)TEST_DRAIN()
assert(TEST_MOUSE_FETCHES==6,'re-enable refetched artwork')
TEST_ACTIONS['Unload script']()
""")
print('PASS real lazy artwork loader, six mask/body assets, no startup requests, cache reuse and native PNG alpha/dimensions')
