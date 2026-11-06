from support import Disk,session
D=Disk();lua,_,_,_=session(D)
lua.execute(r"""
local screen=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeInputOverlay')
local root=screen:FindFirstChild('Keyboard')local input=TEST_SERVICES.UserInputService
assert(not screen.Enabled and not TEST_OPTIONS.inputOverlayEnabled.Value)
for _,name in ipairs({'W','A','S','D','E','Shift','Ctrl','Space','MouseButton1','MouseButton2','MouseButton3','WheelUp','WheelDown'})do assert(root:FindFirstChild(name),name)end
assert(not root:FindFirstChild('Q')and not root:FindFirstChild('Alt'))
TEST_OPTIONS.inputOverlayEnabled:SetValue(true)
local function event(name)return{UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode[name],Position=Vector3.zero}end
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
 assert(root:FindFirstChild(name).BackgroundColor3.R>.3)
 input.InputEnded:Fire(e)
end
input.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseWheel,Position=Vector3.new(0,0,1)})
TEST_SERVICES.RunService.RenderStepped:Fire(.05)assert(root:FindFirstChild('WheelUp').BackgroundColor3.R>.3)
input.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseWheel,Position=Vector3.new(0,0,-1)})
TEST_SERVICES.RunService.RenderStepped:Fire(.05)assert(root:FindFirstChild('WheelDown').BackgroundColor3.R>.3)
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
