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
TEST_SERVICES.Workspace.Raycast=function()return nil end
local synthetic={}
TEST_SERVICES.VirtualInputManager={SendMouseButtonEvent=function(self,x,y,button,down)
 local callback=TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftAttack
 assert(callback('PrimeMinecraftAttack',down and Enum.UserInputState.Begin or Enum.UserInputState.End)==Enum.ContextActionResult.Pass,'forwarded click sunk')
 synthetic[#synthetic+1]=down
end}

local humanoid=player.Character:FindFirstChildOfClass('Humanoid')
humanoid.WalkSpeed=16 humanoid.MaxHealth=100 humanoid.Health=100 humanoid.MoveDirection=Vector3.new(0,0,-1)
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
-- Native E menu visibility, not an E toggle counter, drives pointer state.
local shell=Instance.new('ScreenGui')shell.Name='MenuGui' shell.Enabled=true shell.Parent=player:FindFirstChild('PlayerGui')
local menu=Instance.new('Frame')menu.Name='Menu' menu.Visible=true menu.Parent=shell
TEST_SERVICES.RunService.RenderStepped:Fire(0)
assert(TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.Default and TEST_SERVICES.UserInputService.MouseIconEnabled)
assert(gui:FindFirstChild('MinecraftCursorUnlocker').Visible and not gui:FindFirstChild('MinecraftCrosshair').Visible)
menu.Visible=false TEST_SERVICES.RunService.RenderStepped:Fire(0)
assert(TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter and not TEST_SERVICES.UserInputService.MouseIconEnabled)
assert(not gui:FindFirstChild('MinecraftCursorUnlocker').Visible and gui:FindFirstChild('MinecraftCrosshair').Visible)
menu.Visible=true shell.Enabled=false TEST_SERVICES.RunService.RenderStepped:Fire(0)
assert(gui:FindFirstChild('MinecraftCrosshair').Visible,'disabled menu shell released pointer')
menu.Visible=false shell.Enabled=true
assert(not TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftSprint,'Shift crouch is intercepted')
assert(humanoid.WalkSpeed==16)
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
-- Only an active local grab may pass RMB to the native throw, including sky aim.
local scope=Instance.new('Folder')scope.Name='GrabParts' scope.Parent=TEST_SERVICES.Workspace
local held=Instance.new('Part')held.Name='GrabPart'held.Parent=scope
local weld=Instance.new('WeldConstraint')weld.Part0=held weld.Part1=target weld.Enabled=true weld.Active=true weld.Parent=held
local origin=Instance.new('Attachment')origin.Parent=player.Character
local beam=Instance.new('Beam')beam.Attachment0=origin beam.Enabled=true beam.Parent=scope
mouse.Target=nil
local beforeThrow=#synthetic
assert(grab('PrimeMinecraftGrab',Enum.UserInputState.Begin)==Enum.ContextActionResult.Pass,'held object did not allow native sky throw')
weld:Destroy()
assert(grab('PrimeMinecraftGrab',Enum.UserInputState.End)==Enum.ContextActionResult.Pass,'throw release interrupted')
assert(#synthetic==beforeThrow,'throw generated a grab click')
assert(grab('PrimeMinecraftGrab',Enum.UserInputState.Begin)==Enum.ContextActionResult.Sink,'empty sky passed native throw')
assert(#synthetic==beforeThrow)
-- A stale/foreign grab must not enable native sky throw.
local foreignWeld=Instance.new('WeldConstraint')foreignWeld.Part0=held foreignWeld.Part1=target foreignWeld.Enabled=true foreignWeld.Active=true foreignWeld.Parent=held
origin.Parent=target
assert(grab('PrimeMinecraftGrab',Enum.UserInputState.Begin)==Enum.ContextActionResult.Sink)
scope:Destroy()mouse.Target=target
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
-- Local comparison path: exact mass-normalized hand/sword impulse ratio.
TEST_OPTIONS.minecraftHitMethod:SetValue("Local impulse")
local head=Instance.new('Part')head.Name='Head'head.Position=Vector3.new(0,0,0)head.Parent=player.Character
local punchTarget=Instance.new('Part')punchTarget.Position=Vector3.new(0,0,-3)punchTarget.AssemblyMass=2;punchTarget.Parent=TEST_SERVICES.Workspace
local impulses={}
punchTarget.ApplyImpulse=function(self,impulse)impulses[#impulses+1]=impulse end
TEST_SERVICES.Workspace.Raycast=function(self,origin,ray,params)
 assert(math.abs(ray.Magnitude-8)<1e-9 and params.FilterDescendantsInstances[1]==player.Character)
 return {Instance=punchTarget,Position=punchTarget.Position}
end
TEST_OPTIONS.minecraftHitStrength:SetValue(1.5)
TEST_SERVICES.RunService.RenderStepped:Fire(.4)TEST_SERVICES.RunService.RenderStepped:Fire(.4)TEST_SERVICES.RunService.RenderStepped:Fire(.4)TEST_SERVICES.RunService.RenderStepped:Fire(.4)
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)
assert(#impulses==1 and math.abs(impulses[1].Magnitude-math.sqrt(54^2+12^2))<1e-9)
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)assert(#impulses==2,'separate local clicks were ignored')
table.remove(impulses,2)
TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.Nine},false)
TEST_SERVICES.RunService.RenderStepped:Fire(.1)
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)
assert(#impulses==2 and math.abs(impulses[2].Magnitude-2*impulses[1].Magnitude)<1e-9,'sword is not exactly double')
TEST_SERVICES.RunService.RenderStepped:Fire(.1)
-- Anchored world geometry cannot be moved.
punchTarget.Anchored=true
for i=1,4 do TEST_SERVICES.RunService.RenderStepped:Fire(.1)end
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)assert(#impulses==2)
punchTarget.Anchored=false punchTarget.Position=Vector3.new(0,0,-20)
for i=1,4 do TEST_SERVICES.RunService.RenderStepped:Fire(.1)end
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)assert(#impulses==2,'distant surface hit')
punchTarget.Position=Vector3.new(0,0,-3)
TEST_OPTIONS.minecraftHitStrength:SetValue(0)
for i=1,4 do TEST_SERVICES.RunService.RenderStepped:Fire(.1)end
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)assert(#impulses==2,'zero strength moved object')
TEST_OPTIONS.minecraftHitStrength:SetValue(1.5)
local npc=Instance.new('Model')npc.Parent=TEST_SERVICES.Workspace
local npcHumanoid=Instance.new('Humanoid')npcHumanoid.Parent=npc punchTarget.Parent=npc
for i=1,4 do TEST_SERVICES.RunService.RenderStepped:Fire(.1)end
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)assert(#impulses==3,'character excluded from test')
punchTarget.Parent=TEST_SERVICES.Workspace npc:Destroy()
-- Native-contact experiment: grab same target, confirm drop, then impulse exactly once.
TEST_OPTIONS.minecraftHitMethod:SetValue('Native contact (test)')
mouse.Target=punchTarget
TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.One},false)
TEST_SERVICES.RunService.RenderStepped:Fire(.1)
local beforeNative=#impulses
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)
assert(#impulses==beforeNative,'native test applied before contact')
TEST_SERVICES.RunService.Heartbeat:Fire(.01)
local nativeScope=Instance.new('Folder')nativeScope.Name='GrabParts'nativeScope.Parent=TEST_SERVICES.Workspace
local nativePart=Instance.new('Part')nativePart.Name='GrabPart'nativePart.Parent=nativeScope
local nativeWeld=Instance.new('WeldConstraint')nativeWeld.Part0=nativePart nativeWeld.Part1=punchTarget nativeWeld.Enabled=true nativeWeld.Active=true nativeWeld.Parent=nativePart
local nativeOrigin=Instance.new('Attachment')nativeOrigin.Parent=player.Character
local nativeBeam=Instance.new('Beam')nativeBeam.Attachment0=nativeOrigin nativeBeam.Enabled=true nativeBeam.Parent=nativeScope
TEST_SERVICES.RunService.Heartbeat:Fire(.04)
assert(#impulses==beforeNative,'native test hit before release')
TEST_SERVICES.RunService.Heartbeat:Fire(.15)
local afterUp=#synthetic
TEST_SERVICES.RunService.Heartbeat:Fire(.05)
assert(#synthetic==afterUp+2 and #impulses==beforeNative,'toggle-drop fallback missing')
nativeWeld:Destroy()
TEST_SERVICES.RunService.Heartbeat:Fire(.04)
assert(#impulses==beforeNative+1,'native contact/drop did not apply hit')
TEST_SERVICES.RunService.Heartbeat:Fire(.04)assert(#impulses==beforeNative+1,'native hit repeated')
nativeScope:Destroy()
-- No server/local grab confirmation: timeout is inert, never fake an impulse.
TEST_SERVICES.RunService.RenderStepped:Fire(.1)
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)
for i=1,6 do TEST_SERVICES.RunService.Heartbeat:Fire(.2)end
assert(#impulses==beforeNative+1,'timeout hit an unconfirmed target')
-- Focus loss cancels a pending attempt without a later impulse.
TEST_SERVICES.RunService.RenderStepped:Fire(.1)
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)
TEST_SERVICES.UserInputService.WindowFocusReleased:Fire()
TEST_SERVICES.RunService.Heartbeat:Fire(.2)
assert(#impulses==beforeNative+1)
-- Three physical clicks during a busy handshake all execute, including deduped button edges.
local originalMouseSend=TEST_SERVICES.VirtualInputManager.SendMouseButtonEvent
local downState=true local burstScope local burstWeld
TEST_SERVICES.VirtualInputManager.SendMouseButtonEvent=function(self,x,y,button,down)
 if downState==down then return end
 downState=down originalMouseSend(self,x,y,button,down)
 if down then
  if burstWeld then burstWeld:Destroy()burstWeld=nil
  else
   if burstScope then burstScope:Destroy()end
   burstScope=Instance.new('Folder')burstScope.Name='GrabParts'burstScope.Parent=TEST_SERVICES.Workspace
   local part=Instance.new('Part')part.Name='GrabPart'part.Parent=burstScope
   burstWeld=Instance.new('WeldConstraint')burstWeld.Part0=part burstWeld.Part1=punchTarget burstWeld.Enabled=true burstWeld.Active=true burstWeld.Parent=part
   local origin=Instance.new('Attachment')origin.Parent=player.Character
   local beam=Instance.new('Beam')beam.Enabled=true beam.Attachment0=origin beam.Parent=burstScope
  end
 end
end
TEST_OPTIONS.minecraftHitStrength:SetValue(20)
local beforeBurst=#impulses
for i=1,3 do
 attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)
 attack('PrimeMinecraftAttack',Enum.UserInputState.End)
end
for i=1,36 do TEST_SERVICES.RunService.Heartbeat:Fire(.016)end
assert(#impulses==beforeBurst+3,'busy native contact lost burst clicks')
assert(math.abs(impulses[#impulses].Magnitude-math.sqrt(720^2+160^2))<1e-6,'hand strength20 was clamped')
TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.Nine},false)
attack('PrimeMinecraftAttack',Enum.UserInputState.Begin)
for i=1,16 do TEST_SERVICES.RunService.Heartbeat:Fire(.016)end
assert(#impulses==beforeBurst+4)
assert(math.abs(impulses[#impulses].Magnitude-2*impulses[#impulses-1].Magnitude)<1e-6,'sword strength40 mismatch')
if burstScope then burstScope:Destroy()end
TEST_SERVICES.VirtualInputManager.SendMouseButtonEvent=originalMouseSend
TEST_SERVICES.Workspace.Raycast=function()return nil end
TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.One},false)
TEST_SERVICES.RunService.RenderStepped:Fire(0)
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
assert len(doc['payload']['values'])==545
lua.execute("""
local h=TEST_SERVICES.Players.LocalPlayer.Character:FindFirstChild('Humanoid')
TEST_OPTIONS.minecraftEnabled:SetValue(false)
assert(h.WalkSpeed==16 and not TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftSprint)
assert(not TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftAttack and not TEST_SERVICES.ContextActionService.bindings.PrimeMinecraftGrab)
assert(not TEST_SERVICES.Workspace:FindFirstChild('PrimeSteveArm'))
assert(not TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeMinecraft'))
TEST_OPTIONS.camThird:SetValue(true) assert(TEST_OPTIONS.camThird.Value)
TEST_OPTIONS.minecraftEnabled:SetValue(true)
TEST_ACTIONS['Unload script']()
assert(not TEST_SERVICES.Workspace:FindFirstChild('PrimeSteveArm'))
""")
print('PASS Minecraft default-off, third-person toggle gate, local arm/hotbar, persistence and unload cleanup')
