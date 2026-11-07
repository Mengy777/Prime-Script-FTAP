from support import Disk,session
import json
D=Disk();lua,_,_,_=session(D)
lua.execute("""
local cache={} local read,write=readfile,writefile
readfile=function(p)if cache[p]then return cache[p]end return read(p)end
writefile=function(p,b)if p:find("/Assets/Minecraft/",1,true)then cache[p]=b else write(p,b)end end
-- Real rigid-transform math for the hand's source-derived pose/FOV checks.
local mt={}
local function cf(r,x,y,z)return setmetatable({r=r,p=Vector3.new(x or 0,y or 0,z or 0)},mt)end
mt.__index=function(a,k)if k=='Position'then return a.p elseif k=='LookVector'then return Vector3.new(-a.r[3],-a.r[6],-a.r[9])end end
mt.__mul=function(a,b)
 local r={}for i=0,2 do for j=0,2 do local n=0 for k=0,2 do n=n+a.r[i*3+k+1]*b.r[k*3+j+1]end r[i*3+j+1]=n end end
 local v=b.p local u=a.r
 return cf(r,a.p.X+u[1]*v.X+u[2]*v.Y+u[3]*v.Z,a.p.Y+u[4]*v.X+u[5]*v.Y+u[6]*v.Z,a.p.Z+u[7]*v.X+u[8]*v.Y+u[9]*v.Z)
end
CFrame.new=function(x,y,z)return cf({1,0,0,0,1,0,0,0,1},x,y,z)end
CFrame.Angles=function(x,y,z)
 local sx,cx,sy,cy,sz,cz=math.sin(x),math.cos(x),math.sin(y),math.cos(y),math.sin(z),math.cos(z)
 return cf({cy*cz,-cy*sz,sy,cx*sz+sx*sy*cz,cx*cz-sx*sy*sz,-sx*cy,sx*sz-cx*sy*cz,sx*cz+cx*sy*sz,cx*cy})
end
TEST_SERVICES.Workspace.CurrentCamera.CFrame=CFrame.new()
local player=TEST_SERVICES.Players.LocalPlayer
local mouse={Target=nil}player.GetMouse=function()return mouse end
local synthetic={}
TEST_SERVICES.VirtualInputManager={SendMouseButtonEvent=function(self,x,y,button,down)
 local callback=TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftAttack
 assert(callback('PrimeMinecraftAttack',down and Enum.UserInputState.Begin or Enum.UserInputState.End)==Enum.ContextActionResult.Pass,'forwarded click sunk')
 synthetic[#synthetic+1]=down
end}

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
local view=gui:FindFirstChild('HandView');assert(view and view:IsA('ViewportFrame'))
local arm=view:FindFirstChild('PrimeSteveArm');assert(arm and arm:IsA('Part'))
assert(#arm:GetChildren()==6 and view.CurrentCamera.FieldOfView==70)
local sword
for _,object in ipairs(ALL_INSTANCES)do if object.Name=='PrimeDiamondSword'then sword=object end end
assert(sword and #sword:GetChildren()>0)
sword.PivotTo=function(self,pose)self.lastPose=pose end
sword.ScaleTo=function(self,scale)self.testScale=scale end

local bar=gui and gui:FindFirstChild("Hotbar");assert(bar and bar:FindFirstChild("Slot9"):FindFirstChild("DiamondSword"))
for i=1,8 do assert(not bar:FindFirstChild('Slot'..i):FindFirstChild('DiamondSword'))end
TEST_SERVICES.RunService.RenderStepped:Fire(0)
-- Independent matrix calculation of Java1.8.9 arm center at equip-start.
local start=arm.CFrame.Position
assert(math.abs(start.X-.61692154)<1e-6 and math.abs(start.Y+1.24071865)<1e-6 and math.abs(start.Z+.81166968)<1e-6,'source transform order drifted')
for i=1,10 do TEST_SERVICES.RunService.RenderStepped:Fire(1/60)end
assert(bar.Image:find('hotbar.png',1,true))
local initialFov=TEST_SERVICES.Workspace.CurrentCamera.FieldOfView
TEST_OPTIONS.minecraftBobbing:SetValue(0)
TEST_SERVICES.RunService.RenderStepped:Fire(1/60)
local width,height,depth=arm.Size.X,arm.Size.Y,arm.Size.Z
local pose=arm.CFrame
for _,fov in ipairs({30,70,120})do
 TEST_SERVICES.Workspace.CurrentCamera.FieldOfView=fov
 TEST_SERVICES.RunService.RenderStepped:Fire(0)
 for i=1,9 do assert(math.abs(arm.CFrame.r[i]-pose.r[i])<1e-9)end
 assert((arm.CFrame.Position-pose.Position).Magnitude<1e-9,"FOV changed hand position")
 assert(arm.Size.X==width and arm.Size.Y==height and arm.Size.Z==depth,'FOV changed model size')
 assert(view.CurrentCamera.FieldOfView==70,'world FOV leaked into hand camera')
end
assert(math.abs(height/width-3)<1e-9 and width==depth)
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
local idle=arm.CFrame.Position
local attack=TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftAttack
assert(attack and attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)==Enum.ContextActionResult.Sink)
assert(attack('PrimeMinecraftAttack',Enum.UserInputState.End)==Enum.ContextActionResult.Pass)
TEST_LIBRARY:Toggle(true)
assert(attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)==Enum.ContextActionResult.Pass)
TEST_LIBRARY:Toggle(false)
TEST_SERVICES.RunService.RenderStepped:Fire(.1)
assert((arm.CFrame.Position-idle).Magnitude>.01,'click did not animate hand')
local grab=TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftGrab
assert(grab and grab('PrimeMinecraftGrab',Enum.UserInputState.Begin)==Enum.ContextActionResult.Sink)
assert(#synthetic==0,'sky click generated grab')
local target=Instance.new('Part')target.Parent=TEST_SERVICES.Workspace mouse.Target=target
assert(grab('PrimeMinecraftGrab',Enum.UserInputState.Begin)==Enum.ContextActionResult.Sink)
assert(synthetic[1]==true)
assert(grab('PrimeMinecraftGrab',Enum.UserInputState.End)==Enum.ContextActionResult.Sink and synthetic[2]==false)
TEST_LIBRARY:Toggle(true)
assert(grab('PrimeMinecraftGrab',Enum.UserInputState.Begin)==Enum.ContextActionResult.Pass and #synthetic==2,'UI click forwarded into world')
TEST_LIBRARY:Toggle(false)
grab('PrimeMinecraftGrab',Enum.UserInputState.Begin)
local activeCamera=TEST_SERVICES.Workspace.CurrentCamera
TEST_SERVICES.Workspace.CurrentCamera=nil
TEST_SERVICES.UserInputService.WindowFocusReleased:Fire()
assert(synthetic[#synthetic]==false,'focus/camera loss left mouse held')
TEST_SERVICES.Workspace.CurrentCamera=activeCamera
-- Some runtimes dispatch synthetic events after SendMouseButtonEvent returns.
local synchronous=TEST_SERVICES.VirtualInputManager.SendMouseButtonEvent
TEST_SERVICES.VirtualInputManager.SendMouseButtonEvent=function()end
grab('PrimeMinecraftGrab',Enum.UserInputState.Begin)
assert(attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)==Enum.ContextActionResult.Pass,'deferred press sunk')
grab('PrimeMinecraftGrab',Enum.UserInputState.End)
assert(attack('PrimeMinecraftAttack',Enum.UserInputState.End)==Enum.ContextActionResult.Pass,'deferred release sunk')
assert(attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)==Enum.ContextActionResult.Sink,'physical LMB bypassed swing gate')
TEST_SERVICES.VirtualInputManager.SendMouseButtonEvent=synchronous
TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.Nine},false)
TEST_SERVICES.RunService.RenderStepped:Fire(.1)
assert(sword.Parent==view and arm.Parent==nil and sword.lastPose and sword.testScale,'sword not equipped')
local swordPose=sword.lastPose.Position
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)
TEST_SERVICES.RunService.RenderStepped:Fire(.1)
assert((sword.lastPose.Position-swordPose).Magnitude>.01,'sword did not swing')
TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.One},false)
TEST_SERVICES.RunService.RenderStepped:Fire(.1)
assert(arm.Parent==view and sword.Parent==nil,'empty hand not restored')
local old=TEST_SERVICES.Workspace.CurrentCamera
local replacement=Instance.new('Camera') replacement.Parent=TEST_SERVICES.Workspace
replacement.CFrame=old.CFrame replacement.FieldOfView=old.FieldOfView replacement.ViewportSize=old.ViewportSize
TEST_SERVICES.Workspace.CurrentCamera=replacement old:Destroy()
TEST_SERVICES.RunService.RenderStepped:Fire(1/60)
assert(view:FindFirstChild('PrimeSteveArm')==arm,'world camera replacement destroyed hand')
TEST_DRAIN()
""")
doc=json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])
assert doc['payload']['values']['minecraftEnabled'] is True
assert len(doc['payload']['values'])==543
lua.execute("""
TEST_OPTIONS.minecraftEnabled:SetValue(false)
assert(not TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftAttack and not TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftGrab)
assert(not TEST_SERVICES.Workspace:FindFirstChild('PrimeSteveArm'))
assert(not TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeMinecraft'))
TEST_OPTIONS.camThird:SetValue(true) assert(TEST_OPTIONS.camThird.Value)
TEST_OPTIONS.minecraftEnabled:SetValue(true)
TEST_ACTIONS['Unload script']()
assert(not TEST_SERVICES.Workspace:FindFirstChild('PrimeSteveArm'))
""")
print('PASS Minecraft default-off, third-person toggle gate, local arm/hotbar, persistence and unload cleanup')
