from support import Disk,session
import json
D=Disk();lua,_,_,_=session(D)
lua.execute("""
local player=TEST_SERVICES.Players.LocalPlayer
local humanoid=player.Character:FindFirstChildOfClass('Humanoid')
humanoid.Health=100 humanoid.MoveDirection=Vector3.new(0,0,-1)
assert(TEST_OPTIONS.minecraftEnabled.Value==false)
TEST_OPTIONS.camThird:SetValue(true)
TEST_OPTIONS.minecraftEnabled:SetValue(true)
assert(TEST_OPTIONS.minecraftEnabled.Value and not TEST_OPTIONS.camThird.Value)
TEST_OPTIONS.camThird:SetValue(true)
assert(not TEST_OPTIONS.camThird.Value,'Minecraft third-person gate failed')
TEST_OPTIONS.bind_camThird:SetValue('K') TEST_LIBRARY:Toggle(false)
TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.K},false)
assert(not TEST_OPTIONS.camThird.Value,'Minecraft bind gate failed')
local arm=TEST_SERVICES.Workspace:FindFirstChild('PrimeSteveArm')
assert(arm and not arm.CanCollide and not arm.CanTouch and not arm.CanQuery)
local gui=player:FindFirstChild('PlayerGui'):FindFirstChild('PrimeMinecraft')
local bar=gui and gui:FindFirstChild("Hotbar");assert(bar and bar:FindFirstChild("Slot9"):FindFirstChild("DiamondSword"))
for i=1,8 do assert(not bar:FindFirstChild('Slot'..i):FindFirstChild('DiamondSword'))end
for i=1,10 do TEST_SERVICES.RunService.RenderStepped:Fire(1/60)end
local old=TEST_SERVICES.Workspace.CurrentCamera
local replacement=Instance.new('Camera') replacement.Parent=TEST_SERVICES.Workspace
replacement.CFrame=old.CFrame replacement.FieldOfView=old.FieldOfView replacement.ViewportSize=old.ViewportSize
TEST_SERVICES.Workspace.CurrentCamera=replacement old:Destroy()
TEST_SERVICES.RunService.RenderStepped:Fire(1/60)
assert(TEST_SERVICES.Workspace:FindFirstChild('PrimeSteveArm')==arm,'camera replacement destroyed viewmodel')
TEST_DRAIN()
""")
doc=json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])
assert doc['payload']['values']['minecraftEnabled'] is True
assert len(doc['payload']['values'])==542
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
