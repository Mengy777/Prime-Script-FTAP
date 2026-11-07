from support import Disk,session
import json
D=Disk();lua,_,_,_=session(D)
lua.execute("""
local cache={} local read,write=readfile,writefile
readfile=function(p)if cache[p]then return cache[p]end return read(p)end
writefile=function(p,b)if p:find("/Assets/Minecraft/",1,true)then cache[p]=b else write(p,b)end end
-- This fixture checks lifecycle/HUD, not 3D transform correctness.
local cf={}local mt={__mul=function()return cf end}setmetatable(cf,mt)
CFrame.new=function()return cf end CFrame.Angles=function()return cf end
TEST_SERVICES.Workspace.CurrentCamera.CFrame=cf
local player=TEST_SERVICES.Players.LocalPlayer
local humanoid=player.Character:FindFirstChildOfClass('Humanoid')
humanoid.MaxHealth=100 humanoid.Health=100 humanoid.MoveDirection=Vector3.new(0,0,-1)
assert(TEST_OPTIONS.minecraftEnabled.Value==false)
TEST_OPTIONS.camThird:SetValue(true)
TEST_OPTIONS.minecraftEnabled:SetValue(true)
assert(TEST_OPTIONS.minecraftEnabled.Value and not TEST_OPTIONS.camThird.Value)
TEST_OPTIONS.camThird:SetValue(true)
assert(not TEST_OPTIONS.camThird.Value,'Minecraft third-person gate failed')
TEST_OPTIONS.bind_camThird:SetValue('K') TEST_LIBRARY:Toggle(false)
local notices=#TEST_NOTICES
TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.K},false)
assert(not TEST_OPTIONS.camThird.Value,'Minecraft bind gate failed');assert(#TEST_NOTICES==notices,'blocked bind dispatched')

local gui=player:FindFirstChild('PlayerGui'):FindFirstChild('PrimeMinecraft')
local arm=gui:FindFirstChild('PrimeSteveArm');assert(arm and arm:IsA('ImageLabel'))
local bar=gui and gui:FindFirstChild("Hotbar");assert(bar and bar:FindFirstChild("Slot9"):FindFirstChild("DiamondSword"))
for i=1,8 do assert(not bar:FindFirstChild('Slot'..i):FindFirstChild('DiamondSword'))end
for i=1,10 do TEST_SERVICES.RunService.RenderStepped:Fire(1/60)end
assert(bar.Image:find('hotbar.png',1,true))
local initialFov=TEST_SERVICES.Workspace.CurrentCamera.FieldOfView
TEST_OPTIONS.minecraftBobbing:SetValue(0)
TEST_SERVICES.RunService.RenderStepped:Fire(1/60)
local width,height=arm.Size.X.Offset,arm.Size.Y.Offset
local x,y=arm.Position.X.Offset,arm.Position.Y.Offset
for _,fov in ipairs({30,70,120})do
 TEST_SERVICES.Workspace.CurrentCamera.FieldOfView=fov
 TEST_SERVICES.RunService.RenderStepped:Fire(1/60)
 assert(arm.Size.X.Offset==width and arm.Size.Y.Offset==height,'FOV changed sprite size')
 assert(arm.Position.X.Offset==x and arm.Position.Y.Offset==y,'FOV moved sprite')
end
TEST_SERVICES.Workspace.CurrentCamera.FieldOfView=initialFov
humanoid.Health=50 TEST_SERVICES.RunService.RenderStepped:Fire(1/60)
assert(bar:FindFirstChild('Heart5'):FindFirstChild('Fill').Visible)
assert(not bar:FindFirstChild('Heart6'):FindFirstChild('Fill').Visible)
humanoid.Health=5 TEST_SERVICES.RunService.RenderStepped:Fire(1/60)
assert(bar:FindFirstChild('Heart1'):FindFirstChild('Fill').Image:find('heart_half.png',1,true))
humanoid.Health=0 TEST_SERVICES.RunService.RenderStepped:Fire(1/60)
assert(gui.Enabled and not bar:FindFirstChild('Heart1'):FindFirstChild('Fill').Visible)
assert(bar:FindFirstChild('Food10'):FindFirstChild('Fill').Visible~=false)
humanoid.Health=100 TEST_SERVICES.RunService.RenderStepped:Fire(1/60)
local old=TEST_SERVICES.Workspace.CurrentCamera
local replacement=Instance.new('Camera') replacement.Parent=TEST_SERVICES.Workspace
replacement.CFrame=old.CFrame replacement.FieldOfView=old.FieldOfView replacement.ViewportSize=old.ViewportSize
TEST_SERVICES.Workspace.CurrentCamera=replacement old:Destroy()
TEST_SERVICES.RunService.RenderStepped:Fire(1/60)
assert(gui:FindFirstChild('PrimeSteveArm')==arm,'camera replacement destroyed sprite')
TEST_DRAIN()
""")
doc=json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])
assert doc['payload']['values']['minecraftEnabled'] is True
assert len(doc['payload']['values'])==543
lua.execute("""
TEST_OPTIONS.minecraftEnabled:SetValue(false)
assert(not TEST_SERVICES.Workspace:FindFirstChild('PrimeSteveArm'))
assert(not TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeMinecraft'))
TEST_OPTIONS.camThird:SetValue(true) assert(TEST_OPTIONS.camThird.Value)
TEST_OPTIONS.minecraftEnabled:SetValue(true)
TEST_ACTIONS['Unload script']()
assert(not TEST_SERVICES.Workspace:FindFirstChild('PrimeSteveArm'))
""")
print('PASS Minecraft default-off, third-person toggle gate, local arm/hotbar, persistence and unload cleanup')
