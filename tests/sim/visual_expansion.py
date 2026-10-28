from support import Disk,session
import json
D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(r"""
-- Deterministic transforms/projection and input: engine rendering is not simulated.
local vectorMT=getmetatable(Vector3.zero)
local previousIndex=vectorMT.__index
vectorMT.__index=function(t,k)
 if k=='Lerp' then return function(a,b,t)return a+(b-a)*t end end
 return previousIndex(t,k)
end
Vector2.zero=Vector2.new(0,0)
NumberSequenceKeypoint={new=function(t,v)return {Time=t,Value=v}end}
local cfmt={}
cfmt.__index=cfmt
function cfmt:ToEulerAnglesYXZ()return self.pitch or 0,self.yaw or 0,0 end
function cfmt:VectorToWorldSpace(v)return v end
function cfmt:PointToWorldSpace(v)return self.Position+v end
cfmt.__mul=function(a,b)
 local yaw=(a.yaw or 0)+(b.yaw or 0) local pitch=(a.pitch or 0)+(b.pitch or 0)
 return setmetatable({Position=a.Position+b.Position,yaw=yaw,pitch=pitch,LookVector=Vector3.new(-math.sin(yaw)*math.cos(pitch),math.sin(pitch),-math.cos(yaw)*math.cos(pitch))},cfmt)end
cfmt.__sub=function(a,b)return CFrame.new(a.Position-b)end
function cfmt:Lerp(b,t)return CFrame.new(self.Position:Lerp(b.Position,t))end
CFrame.new=function(x,y,z)
 local v=type(x)=='table' and x or Vector3.new(x,y,z)
 return setmetatable({Position=v,LookVector=Vector3.new(0,0,-1)},cfmt)
end
CFrame.fromEulerAnglesYXZ=function(p,y,r)local c=CFrame.new()c.pitch=p c.yaw=y return c end
CFrame.Angles=CFrame.fromEulerAnglesYXZ
RaycastParams={new=function()return {}end}
Enum.RenderPriority.Camera.Value=200
local camera=workspace.CurrentCamera
camera.CFrame=CFrame.new(0,8,0)camera.Focus=CFrame.new(0,8,-16)camera.CameraType=Enum.CameraType.Custom
camera.WorldToViewportPoint=function(self,p)return Vector3.new(640+p.X*10,360-p.Y*10,50-p.Z),p.Z<50 end
workspace.Raycast=function(self,p,d,params)return {Position=Vector3.new(p.X,0,p.Z)}end
local rawNew=Instance.new
Instance.new=function(class)
 local o=rawNew(class)
 if class=='ParticleEmitter' then o.Emit=function(self,count)self.Emitted=(self.Emitted or 0)+count end end
 if class=='Animator' then
  o.LoadAnimation=function(self,object)
   local track={Stopped=rawNew('Folder').Changed,Plays=0,Asset=object.AnimationId}
   function track:Play(fade,weight,speed)self.Plays=self.Plays+1 self.Speed=speed self.IsPlaying=true end
   function track:Stop()self.IsPlaying=false self.Stopped:Fire()end
   function track:Destroy()self.Destroyed=true end
   function track:AdjustSpeed(speed)assert(not self.Destroyed);self.Speed=speed end
   TEST_TRACK=track return track
  end
 end
 return o
end
local function character(name,x)
 local char=Instance.new('Model')char.Name=name char.Parent=workspace
 for _,name in ipairs({'HumanoidRootPart','Head','Torso','Left Arm','Right Arm','Left Leg','Right Leg'})do
  local part=Instance.new('Part')part.Name=name part.Size=Vector3.new(2,2,1)part.Position=Vector3.new(x,name=='Head' and 6 or 3,0)
  part.CFrame=CFrame.new(part.Position)part.Color=Color3.new(.1,.2,.3)part.Transparency=0 part.LocalTransparencyModifier=0 part.Parent=char
 end
 char.GetBoundingBox=function()return CFrame.new(x,3,0),Vector3.new(5,6,2)end
 local h=Instance.new('Humanoid')h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer h.NameDisplayDistance=100 h.Health=100 h.WalkSpeed=16 h.JumpPower=50 h.JumpHeight=7 h.AutoRotate=true h.Died=Instance.new('Folder').Changed h.Parent=char
 return char
end
CREATE_CHARACTER=character
ME=TEST_SERVICES.Players.LocalPlayer ME.Character=character('LocalCharacter',0)
ENEMY=Instance.new('Player')ENEMY.Name='Enemy'ENEMY.DisplayName='Opponent'ENEMY.UserId=77 ENEMY.Character=character('EnemyCharacter',10)ENEMY.Parent=TEST_SERVICES.Players
TEST_SERVICES.Players.GetPlayers=function()return {ME,ENEMY}end
camera.CameraSubject=ME.Character:FindFirstChildOfClass('Humanoid')
local input=TEST_SERVICES.UserInputService
KEYS={};input.IsKeyDown=function(_,key)return KEYS[key.Name] or false end
RMB=false input.IsMouseButtonPressed=function()return RMB end
input.WindowFocused=Instance.new('Folder').Changed
TEST_SERVICES.ContextActionService={BindActionAtPriority=function(self,name,fn)self.bound=fn end,UnbindAction=function(self)self.bound=nil end}
function TICK(dt)
 TEST_CLOCK=TEST_CLOCK+dt
 TEST_SERVICES.RunService.Heartbeat:Fire(dt)
 TEST_SERVICES.RunService.RenderStepped:Fire(dt)
 for name,fn in pairs(TEST_SERVICES.RunService._render or {})do fn(dt)end
end
function FIND(name,scope)
 for _,o in ipairs((scope or workspace):GetDescendants())do if o.Name==name then return o end end
end
""")
lua.execute(source)
lua.execute(r"""
assert(TEST_OPTIONS.holeSprite and TEST_OPTIONS.bodyAppearance and TEST_OPTIONS.visualPresetEnabled,'pack startup failed')
TEST_LIBRARY:Toggle(false)
TEST_OPTIONS.bodyTrailEnabled:SetValue(true)
local trail=FIND('PV_BodyTrail') assert(trail and trail.Attachment0.Position.Y==2 and trail.Attachment1.Position.Y==-2)
TEST_OPTIONS.bodyTrailGradient:SetValue(true) TEST_OPTIONS.bodyTrailLife:SetValue(1.7) TICK(.1)
assert(trail.Lifetime==1.7)
local old=ME.Character
ME.Character=CREATE_CHARACTER('Respawn',0)
TICK(.51)
assert(FIND('PV_BodyTrail',ME.Character) and not trail.Parent,'trail failed after respawn')
TEST_OPTIONS.bodyTrailEnabled:SetValue(false)assert(not FIND('PV_BodyTrail',ME.Character))
TEST_OPTIONS.jumpCircleEnabled:SetValue(true)
ME.Character:FindFirstChildOfClass('Humanoid').StateChanged:Fire(Enum.HumanoidStateType.Running,Enum.HumanoidStateType.Jumping)
local ring=FIND('PV_JumpCircle') assert(ring and ring.Size.X==15)
TICK(.5) assert(ring.Parent and FIND('Ring',ring).ImageTransparency>0)
TICK(2) assert(not ring.Parent)
TEST_OPTIONS.jumpCircleEnabled:SetValue(false)
""")
print('PASS source jump-circle ground/radius/fade, native trail parameters, respawn and disable cleanup')
lua.execute(r"""
TEST_OPTIONS.snowEnabled:SetValue(true)TICK(.51)
for i=1,3 do
 local p=FIND('PV_SnowLayer'..i)assert(p and p.Size.X==320)
 local e=p:FindFirstChildOfClass('ParticleEmitter')assert(e and e.Rate>0 and e.Lifetime[1]==7+i)
end
TEST_OPTIONS.snowWind:SetValue(-12)TEST_OPTIONS.snowHeight:SetValue(90)TICK(.1)
assert(FIND('PV_SnowLayer1'):FindFirstChildOfClass('ParticleEmitter').Acceleration.X<0)
FIND('PV_SnowLayer2'):Destroy()TICK(.51)assert(FIND('PV_SnowLayer2'))
TEST_OPTIONS.snowEnabled:SetValue(false)assert(not FIND('PV_SnowLayer1'))
TEST_OPTIONS.deathDustEnabled:SetValue(true)
local char=ENEMY.Character;local h=char:FindFirstChildOfClass('Humanoid')
h.Health=0 h.Died:Fire()h.HealthChanged:Fire(0)
local f=FIND('PV_DeathDust')assert(f)
local counts={}
for _,o in ipairs(f:GetDescendants())do if o:IsA('ParticleEmitter')then counts[o.Emitted]=(counts[o.Emitted] or 0)+1 end end
for _,n in ipairs({55,35,12,28})do assert(counts[n]==36,'wrong original dust emission count')end
assert(char:FindFirstChild('Head').LocalTransparencyModifier==1)
TICK(8.1)assert(not f.Parent)
TEST_OPTIONS.deathDustEnabled:SetValue(false)assert(char:FindFirstChild('Head').LocalTransparencyModifier==0)
h.Health=100
""")
print('PASS exact three snow layers, wind/height/recovery; four source dust layers, death deduplication, 8-second expiry and visibility restoration')
lua.execute(r"""
TEST_OPTIONS.boxEnabled:SetValue(true)TEST_OPTIONS.skeletonEnabled:SetValue(true)TICK(.1)
local f=FIND('PV_Geometry_Enemy',ME:FindFirstChild('PlayerGui'))assert(f)
local n=0 for _,l in ipairs(f:GetChildren())do if l.Visible then n=n+1 end end assert(n==9,'R6 box/skeleton segments incorrect')
TEST_OPTIONS.boxEnabled:SetValue(false)TEST_OPTIONS.skeletonEnabled:SetValue(false)TICK(.1)assert(not f.Parent)
local enemy=ENEMY.Character
ENEMY.Character=CREATE_CHARACTER('R15Enemy',10)
for _,name in ipairs({'UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot'})do
 local p=Instance.new('Part')p.Name=name p.Position=Vector3.new(10,3,0)p.CFrame=CFrame.new(p.Position)p.Size=Vector3.new(1,1,1)p.Parent=ENEMY.Character
end
TEST_OPTIONS.skeletonEnabled:SetValue(true)TICK(.1)
local r15=FIND('PV_Geometry_Enemy',ME:FindFirstChild('PlayerGui'))local lines=0
for _,l in ipairs(r15:GetChildren())do if l.Visible then lines=lines+1 end end assert(lines==14,'R15 links incorrect')
TEST_OPTIONS.boxEnabled:SetValue(true)
ENEMY.Character.GetBoundingBox=function()return CFrame.new(10,3,50),Vector3.new(5,6,2)end TICK(.1)
lines=0 for _,l in ipairs(r15:GetChildren())do if l.Visible then lines=lines+1 end end assert(lines==14,'near-plane box should be hidden')
TEST_OPTIONS.boxEnabled:SetValue(false)TEST_OPTIONS.skeletonEnabled:SetValue(false)
ENEMY.Character=enemy TICK(.1)

TEST_OPTIONS.visualTarget:SetValue('Enemy')TEST_OPTIONS.traceEnabled:SetValue(true)TEST_OPTIONS.traceMarker:SetValue(true)TICK(.1)
assert(FIND('PV_TraceMarker',ME:FindFirstChild('PlayerGui')).Enabled)
TEST_OPTIONS.visualTarget:SetValue('Offline')TICK(.1)assert(not FIND('PV_TraceMarker',ME:FindFirstChild('PlayerGui')).Enabled)
TEST_OPTIONS.traceEnabled:SetValue(false)
TEST_OPTIONS.selfESP:SetValue(true)TICK(.51)assert(FIND('PV_SelfESP'))
TEST_OPTIONS.selfESP:SetValue(false)assert(not FIND('PV_SelfESP'))
TEST_OPTIONS.espPlayersHealth:SetValue(true)TEST_OPTIONS.espPlayersShowDistance:SetValue(true)TEST_OPTIONS.espPlayers:SetValue(true)TICK(.2)
local names=FIND('PV_ESP'):GetDescendants() local found=false
for _,o in ipairs(names)do if o:IsA('TextLabel')and o.Text:find('100 HP',1,true)and o.Text:find('st',1,true)then found=true end end assert(found)
TEST_OPTIONS.espPlayers:SetValue(false)
""")
print('PASS R6/R15 projected box/skeleton, near-plane clipping, target marker with absent-target hiding, own highlight, existing ESP health/distance integration')
lua.execute(r"""
local toys=Instance.new('Folder')toys.Name='EnemySpawnedInToys'toys.Parent=workspace
local function toy(name)
 local m=Instance.new('Model')m.Name=name m.Parent=toys
 local p=Instance.new('Part')p.Name='Body'p.Position=Vector3.new(10,2,1)p.CFrame=CFrame.new(p.Position)p.Size=Vector3.new(2,2,2)p.Parent=m return m
end
local blob=toy('CreatureBlobman')local kunai=toy('Kunai')local peel=toy('BananaPeel')
TEST_OPTIONS.blobESP:SetValue(true)TEST_OPTIONS.combatESP:SetValue(true)TEST_OPTIONS.antiKickESP:SetValue(true)TICK(.51)
assert(FIND('PV_BlobESP')and FIND('PV_CombatESP')and FIND('PV_AntiKickESP'))
local n=0 for _,o in ipairs(workspace:GetDescendants())do if o.Name=='PV_CombatESP'then n=n+1 end end assert(n==1,'duplicate or wrong item match')
TEST_OPTIONS.blobESP:SetValue(false)TEST_OPTIONS.combatESP:SetValue(false)TEST_OPTIONS.antiKickESP:SetValue(false)
assert(not FIND('PV_BlobESP')and not FIND('PV_CombatESP')and not FIND('PV_AntiKickESP'))
local head=ENEMY.Character:FindFirstChild('Head');head.Transparency=1
TEST_OPTIONS.revealInvisible:SetValue(true)assert(head.Transparency==.55)
TEST_OPTIONS.revealInvisible:SetValue(false)assert(head.Transparency==1)head.Transparency=0
local hole=Instance.new('Model')hole.Name='BlackHoleKick'hole.Parent=workspace
local part=Instance.new('Part')part.Name='Hole'part.Position=Vector3.new(100,3,0)part.CFrame=CFrame.new(part.Position)part.LocalTransparencyModifier=0 part.Parent=hole
TEST_OPTIONS.holeSprite:SetValue(true)TICK(.1)
local sprite=FIND('PV_BlackholeSprite')assert(sprite and part.LocalTransparencyModifier==1)
TEST_OPTIONS.holeHideOriginal:SetValue(false)TICK(.1)assert(part.LocalTransparencyModifier==0)
TEST_OPTIONS.holeHideOriginal:SetValue(true)TICK(.1)
sprite:Destroy()TICK(.1)assert(FIND('PV_BlackholeSprite'),'deleted sprite did not recover')
TICK(10.2)assert(not FIND('PV_BlackholeSprite'),'expired sprite retained')
TEST_OPTIONS.holeHideOriginal:SetValue(false)TICK(.1)assert(part.LocalTransparencyModifier==0)
TEST_OPTIONS.holeSprite:SetValue(false)
TEST_OPTIONS.serverGhostEnabled:SetValue(true)TICK(.1)
local n=0 for _,o in ipairs(workspace:GetDescendants())do if o.Name=='PV_EstimatedServerPosition'then n=n+1 end end assert(n==32)
TEST_OPTIONS.serverGhostEnabled:SetValue(false)assert(not FIND('PV_EstimatedServerPosition'))
TEST_OPTIONS.animationEnabled:SetValue(true)assert(TEST_TRACK.Asset=='rbxassetid://183412246')
local track=TEST_TRACK TEST_OPTIONS.animationSpeed:SetValue(2.5)assert(track.Speed==2.5)
TEST_OPTIONS.animationName:SetValue('Emote / Super Faint')assert(track.Destroyed)
track=TEST_TRACK assert(track.Asset=='rbxassetid://181525546'and track.Speed==1.25)
track.Stopped:Fire()assert(track.Plays==2)
TEST_OPTIONS.animationEnabled:SetValue(false)assert(track.Destroyed)
TEST_OPTIONS.animationEnabled:SetValue(true)track=TEST_TRACK track:Destroy()TICK(.51)assert(TEST_TRACK~=track,'destroyed animation did not recover')
TEST_OPTIONS.animationEnabled:SetValue(false)
""")
print('PASS source object matching/icon deduplication, invisibility restore, animated blackhole repair/expiry/live controls, 32-part position ghost and emote assets/repeats/speed/recovery')
lua.execute(r"""
local w=ME.Character:FindFirstChildOfClass('Humanoid')local originalSubject=workspace.CurrentCamera.CameraSubject
local camera=workspace.CurrentCamera local originalCF=camera.CFrame
local gameUI=Instance.new('ScreenGui')gameUI.Name='GameHUD'gameUI.Enabled=true gameUI.Parent=ME:FindFirstChild('PlayerGui')
local menu=Instance.new('Frame')menu.Name='UnlabelledSelectionPanel'menu.Size=UDim2.fromOffset(400,300)menu.Visible=false menu.Parent=gameUI
for _,part in ipairs(ME.Character:GetDescendants())do if part:IsA('BasePart')then part.LocalTransparencyModifier=1 end end
local oldType=camera.CameraType
local cameraHook=camera:GetPropertyChangedSignal('CameraType'):Connect(function() if camera.CameraType==Enum.CameraType.Scriptable then menu.Visible=true end end)
TEST_OPTIONS.freeCameraEnabled:SetValue(true)TICK(.1)assert(w.WalkSpeed==0 and camera.CameraType==Enum.CameraType.Scriptable)
assert(not menu.Visible,'game menu opened on freecam activation without any E press')
for _,part in ipairs(ME.Character:GetDescendants())do if part:IsA('BasePart')and part.Name~='HumanoidRootPart'then assert(part.LocalTransparencyModifier==0)end end
assert(not TEST_OPTIONS.smoothCameraEnabled and not TEST_OPTIONS.smoothCameraAmount)
local hud=FIND('PV_FreecamHUD',ME:FindFirstChild('PlayerGui'))assert(hud and hud.Visible)
local beforeYaw=camera.CFrame.yaw or 0
RMB=false TEST_SERVICES.UserInputService.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseMovement,Delta=Vector2.new(30,12)})TICK(.05)
assert(camera.CFrame.yaw~=beforeYaw,'freecam still requires RMB')
for i=1,40 do TEST_SERVICES.UserInputService.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseWheel,Position=Vector3.new(0,0,1)})end
assert(TEST_OPTIONS.freeCameraSpeed.Value==600)
for i=1,40 do TEST_SERVICES.UserInputService.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseWheel,Position=Vector3.new(0,0,-1)})end
assert(TEST_OPTIONS.freeCameraSpeed.Value==10)
TEST_OPTIONS.freeCameraSpeed:SetValue(80)
TEST_SERVICES.UserInputService.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseWheel,Position=Vector3.new(0,0,0)})
assert(TEST_OPTIONS.freeCameraSpeed.Value==80,'zero wheel input changed speed')
TEST_SERVICES.UserInputService.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseWheel,Position=Vector3.new(0,0,2)})
assert(TEST_OPTIONS.freeCameraSpeed.Value==125,'high-resolution wheel delta ignored')
TEST_OPTIONS.freeCameraSpeed:SetValue(80)
TEST_LIBRARY.Toggled=true TICK(.1)assert(not hud.Visible)
TEST_LIBRARY.Toggled=false TICK(.1)assert(hud.Visible)
TEST_SERVICES.UserInputService.WindowFocusReleased:Fire()TICK(.1)
assert(TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.Default)
TEST_SERVICES.UserInputService.WindowFocused:Fire()TICK(.1)
assert(TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter)
menu.Visible=true assert(not menu.Visible,'game menu reopened during flight')
local shell=Instance.new('ScreenGui')shell.Name='ToyMenuGui'shell.Enabled=false shell.Parent=ME:FindFirstChild('PlayerGui')
local frozen=camera.CFrame.Position
TEST_SERVICES.ContextActionService.bound('PrimeVisualsFreecam',Enum.UserInputState.Begin,{KeyCode=Enum.KeyCode.E})menu.Visible=true shell.Enabled=true TICK(.1)
assert(hud.Visible and TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.Default)
menu.Visible=true assert(menu.Visible,'manual toy menu blocked in interaction mode')
assert(TEST_SERVICES.ContextActionService.bound()==Enum.ContextActionResult.Pass)
KEYS.W=true TICK(.1)KEYS.W=false
assert((camera.CFrame.Position-frozen).Magnitude<.001,'camera moved while interacting')
local beforeSpeed=TEST_OPTIONS.freeCameraSpeed.Value
TEST_SERVICES.UserInputService.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseWheel,Position=Vector3.new(0,0,1)})
assert(TEST_OPTIONS.freeCameraSpeed.Value==beforeSpeed,'menu scrolling changed freecam speed')
TEST_SERVICES.ContextActionService.bound('PrimeVisualsFreecam',Enum.UserInputState.Begin,{KeyCode=Enum.KeyCode.E})menu.Visible=false TICK(.1)
assert(not menu.Visible and TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter,'persistent enabled GUI shell froze flight')
for cycle=1,10 do
 TEST_SERVICES.ContextActionService.bound('PrimeVisualsFreecam',Enum.UserInputState.Begin,{KeyCode=Enum.KeyCode.E})
 menu.Visible=true TICK(.05)
 assert(TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.Default,'E opening became out of sync')
 -- A native selection/close button closes without another E.
 menu.Visible=false TICK(.05)
 assert(TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter,'native close left flight frozen')
end
-- Native menus can close by tweening offscreen while Visible remains true.
TEST_SERVICES.ContextActionService.bound('PrimeVisualsFreecam',Enum.UserInputState.Begin,{KeyCode=Enum.KeyCode.E})
menu.Visible=true TICK(.05)
local priorPosition=menu.Position local priorViewport=camera.ViewportSize
camera.ViewportSize=Vector2.new(1280,720)menu.Position=UDim2.fromOffset(2000,0)TICK(.05)
assert(TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter,'offscreen menu left flight paused')
menu.Visible=false menu.Position=priorPosition camera.ViewportSize=priorViewport
-- Rejected/processed native menu action must not create a phantom interaction mode.
TEST_SERVICES.ContextActionService.bound('PrimeVisualsFreecam',Enum.UserInputState.Begin,{KeyCode=Enum.KeyCode.E})TICK(.05)
assert(TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter)


local position=ME.Character:FindFirstChild('HumanoidRootPart').Position
KEYS.W=true for i=1,20 do TICK(.05)end KEYS.W=false
assert(camera.CFrame.Position.Z<originalCF.Position.Z and ME.Character:FindFirstChild('HumanoidRootPart').Position==position)
local avatarRoot=ME.Character:FindFirstChild('HumanoidRootPart')
local avatarStart=avatarRoot.CFrame
local previousRay=workspace.Raycast
TEST_GRAB_TARGET=Instance.new('Part')TEST_GRAB_TARGET.Anchored=false TEST_GRAB_TARGET.Parent=workspace
local ground=Instance.new('Part')ground.Name='ExperimentalGround'ground.Anchored=true ground.Parent=workspace
workspace.Raycast=function(_,origin,direction,params)
 return {Instance=(direction and direction.Y==-88) and ground or TEST_GRAB_TARGET,Position=Vector3.new(origin.X,0,origin.Z),Normal=Vector3.new(0,1,0)}
end
local function rightClick(state)
 return TEST_SERVICES.ContextActionService.bound('PrimeVisualsFreecam',state or Enum.UserInputState.Begin,{UserInputType=Enum.UserInputType.MouseButton2})
end
local function leftClick()
 TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1},false)
 TEST_SERVICES.UserInputService.InputEnded:Fire({UserInputType=Enum.UserInputType.MouseButton1})
end
leftClick()assert(avatarRoot.CFrame==avatarStart,'LMB unexpectedly approached')
assert(rightClick()==Enum.ContextActionResult.Sink)TICK(.05)
assert((avatarRoot.CFrame.Position-avatarStart.Position).Magnitude>10,'RMB did not approach')
local atTarget=avatarRoot.CFrame
local otherHumanoid=ENEMY.Character:FindFirstChildOfClass('Humanoid')
assert(otherHumanoid.DisplayDistanceType==Enum.HumanoidDisplayDistanceType.Subject and otherHumanoid.NameDisplayDistance==1000000,'native freecam names not enabled')
local holding=Instance.new('Folder')holding.Name='GrabParts'holding.Parent=workspace
local grabPart=Instance.new('Part')grabPart.Name='GrabPart'grabPart.Parent=holding
local weld=Instance.new('WeldConstraint')weld.Part1=TEST_GRAB_TARGET weld.Parent=grabPart
assert(rightClick()==Enum.ContextActionResult.Pass,'throw RMB blocked')
assert(avatarRoot.CFrame==atTarget,'throw returned avatar')
weld.Part1=nil
assert(rightClick(Enum.UserInputState.End)==Enum.ContextActionResult.Pass,'throw release was swallowed after weld removed')
assert(avatarRoot.CFrame==atTarget)
holding:Destroy()

rightClick(Enum.UserInputState.End)
leftClick()TEST_DRAIN()TICK(.05)
assert(avatarRoot.CFrame==atTarget,'mouse release or LMB unexpectedly returned avatar')
assert(TEST_SERVICES.UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter,'approach stopped camera look')
local hitPoint=Vector3.new(camera.CFrame.Position.X,0,camera.CFrame.Position.Z)
local offset=avatarRoot.CFrame.Position-hitPoint
local sideways=Vector3.new(-camera.CFrame.LookVector.Z,0,camera.CFrame.LookVector.X).Unit
assert(math.abs(offset.X*sideways.X+offset.Z*sideways.Z)>=5.99,'avatar overlaps target ray')
local previousCamera=camera.CFrame
TEST_SERVICES.UserInputService.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseMovement,Delta=Vector3.new(25,0,0)})TICK(.05)
assert(camera.CFrame.LookVector.X~=previousCamera.LookVector.X,'look frozen at target')
workspace.Raycast=function()return nil end
rightClick()assert(avatarRoot.CFrame==avatarStart,'second RMB failed to return without raycast target')
rightClick()assert(avatarRoot.CFrame==avatarStart,'no target moved avatar')
workspace.Raycast=function(_,origin)return {Instance=TEST_GRAB_TARGET,Position=Vector3.new(origin.X,0,origin.Z),Normal=Vector3.new(0,1,0)}end
for cycle=1,10 do
 rightClick()assert(avatarRoot.CFrame~=avatarStart)
 leftClick()rightClick()assert(avatarRoot.CFrame==avatarStart)
end
rightClick()TEST_OPTIONS.freeCameraEnabled:SetValue(false)
assert(avatarRoot.CFrame==avatarStart,'disable failed to return')
assert(otherHumanoid.DisplayDistanceType==Enum.HumanoidDisplayDistanceType.Viewer and otherHumanoid.NameDisplayDistance==100,'native names not restored')
TEST_OPTIONS.freeCameraEnabled:SetValue(true)TICK(.05)
w.Sit=true rightClick()w.Sit=false
assert(avatarRoot.CFrame==avatarStart,'seated avatar moved')
TEST_GRAB_TARGET.Anchored=true rightClick()
assert(avatarRoot.CFrame~=avatarStart,'anchored hit did not approach')
TEST_SERVICES.UserInputService.WindowFocusReleased:Fire()
assert(avatarRoot.CFrame==avatarStart,'focus loss failed to return')
TEST_SERVICES.UserInputService.WindowFocused:Fire()
TEST_GRAB_TARGET:Destroy()
workspace.Raycast=previousRay ground:Destroy()
TEST_OPTIONS.freeCameraEnabled:SetValue(false)
assert(not hud.Visible)
menu.Visible=true assert(menu.Visible,'game UI stayed locked after freecam')
cameraHook:Disconnect()gameUI:Destroy()shell:Destroy()
for i=1,4 do
 TEST_OPTIONS.freeCameraEnabled:SetValue(true)TICK(.05)
 TEST_SERVICES.UserInputService.InputBegan:Fire({KeyCode=Enum.KeyCode.F4},false)
 assert(not TEST_OPTIONS.freeCameraEnabled.Value and not hud.Visible)
 assert(not TEST_SERVICES.ContextActionService.bound,'F4 left movement binding active')
 assert(w.WalkSpeed==16 and camera.CameraType==oldType,'F4 failed to restore camera/movement')
end
TEST_OPTIONS.freeCameraEnabled:SetValue(true)TICK(.05)
TEST_SERVICES.ContextActionService.bound('PrimeVisualsFreecam',Enum.UserInputState.Begin,{KeyCode=Enum.KeyCode.E})TICK(.05)
FIND('CloseFreecam',hud).MouseButton1Click:Fire()
assert(not TEST_OPTIONS.freeCameraEnabled.Value and not hud.Visible and not TEST_SERVICES.ContextActionService.bound)
assert(w.WalkSpeed==16 and w.JumpPower==50 and w.JumpHeight==7 and w.AutoRotate and camera.CameraType==Enum.CameraType.Custom)
local visitor=Instance.new('Player')visitor.Name='Visitor'visitor.DisplayName='Guest'visitor.UserId=88 visitor.Parent=TEST_SERVICES.Players
local previousGet=TEST_SERVICES.Players.GetPlayers
TEST_SERVICES.Players.GetPlayers=function()return {ME,ENEMY,visitor}end
TEST_SERVICES.Players.PlayerAdded:Fire(visitor)
assert(TEST_OPTIONS.spectateTarget.Info.ValueImages.Visitor:find('id=88',1,true))
assert(TEST_OPTIONS.spectateTarget.Info.FormatListValue('Visitor')=='Guest (@Visitor)')
TEST_SERVICES.Players.PlayerRemoving:Fire(visitor)
TEST_SERVICES.Players.GetPlayers=previousGet
assert(not TEST_OPTIONS.spectateTarget.Info.ValueImages.Visitor)
assert(TEST_OPTIONS.spectateTarget.Info.ValueImages.Enemy:find('id=77',1,true))
assert(TEST_OPTIONS.spectateTarget.Info.FormatListValue('Enemy')=='Opponent (@Enemy)')
TEST_OPTIONS.spectateTarget:SetValue('Enemy')TEST_OPTIONS.spectateEnabled:SetValue(true)TICK(.1)
assert(camera.CameraSubject==ENEMY.Character:FindFirstChildOfClass('Humanoid'))
TEST_OPTIONS.spectateEnabled:SetValue(false)assert(camera.CameraSubject==w)
TEST_OPTIONS.fullbrightEnabled:SetValue(true)assert(TEST_SERVICES.Lighting.ClockTime==14)
TEST_OPTIONS.fullbrightEnabled:SetValue(false)
local originallyOff=Instance.new('BloomEffect')originallyOff.Name='OriginalOff'originallyOff.Enabled=false originallyOff.Parent=TEST_SERVICES.Lighting
local originallyOn=Instance.new('ColorCorrectionEffect')originallyOn.Name='OriginalOn'originallyOn.Enabled=true originallyOn.Parent=TEST_SERVICES.Lighting
TEST_OPTIONS.visualPresetEnabled:SetValue(true)assert(FIND('PV_Preset_1',TEST_SERVICES.Lighting))
assert(not originallyOn.Enabled and not originallyOff.Enabled)
TEST_OPTIONS.visualPresetEnabled:SetValue(false)assert(originallyOn.Enabled and not originallyOff.Enabled)
TEST_OPTIONS.visualPresetEnabled:SetValue(true)
TEST_OPTIONS.visualPreset:SetValue('Dreamy Night')assert(TEST_SERVICES.Lighting.Brightness==.5)
TEST_OPTIONS.visualPreset:SetValue('Tokyowami')assert(FIND('PV_PresetSky',TEST_SERVICES.Lighting))
TEST_OPTIONS.visualPresetEnabled:SetValue(false)assert(not FIND('PV_PresetSky',TEST_SERVICES.Lighting))
TEST_OPTIONS.collectionSky:SetValue('Crimson')TEST_ACTIONS['Apply selected skybox']()
assert(FIND('PrimeVisualsSky',TEST_SERVICES.Lighting).SkyboxBk:find('401664839',1,true))
TEST_OPTIONS.visualPreset:SetValue('Tokyowami')TEST_OPTIONS.visualPresetEnabled:SetValue(true)
TEST_ACTIONS['Apply selected skybox']()
assert(not TEST_OPTIONS.visualPresetEnabled.Value and not FIND('PV_PresetSky',TEST_SERVICES.Lighting))
local count=0 for _,o in ipairs(TEST_SERVICES.Lighting:GetChildren())do if o:IsA('Sky')then count=count+1 end end
assert(count==1,'sky apply left competing Sky instances after preset')

""")
print('PASS camera-only freecam translation, original movement/camera restoration, native spectate, shader switching and exact skybox face IDs')
lua.execute(r"""
TEST_OPTIONS.oceanAppearance:SetValue(true)TEST_OPTIONS.oceanMaterial:SetValue('Neon')TEST_OPTIONS.oceanTint:SetValue(true)TICK(.51)
assert(TEST_OCEAN.Material==Enum.Material.Neon)
TEST_OPTIONS.oceanAppearance:SetValue(false)
TEST_OPTIONS.bodyAppearance:SetValue(true)TEST_OPTIONS.bodyHeadAlpha:SetValue(.7)assert(ME.Character:FindFirstChild('Head').Transparency==.7)
TEST_OPTIONS.bodyAppearance:SetValue(false)assert(ME.Character:FindFirstChild('Head').Transparency==0)
TEST_OPTIONS.bodyTrailEnabled:SetValue(true)TEST_OPTIONS.snowEnabled:SetValue(true)TEST_OPTIONS.freeCameraEnabled:SetValue(true)TICK(.2)
TEST_DRAIN()TEST_ACTIONS['Unload script']()
assert(not FIND('PV_VisualExpansion')and not FIND('PV_VisualOverlay',ME:FindFirstChild('PlayerGui')))
assert(not TEST_SERVICES.RunService._render.PrimeVisualsCinematicCamera)
assert(ME.Character:FindFirstChildOfClass('Humanoid').WalkSpeed==16)
""")
print('PASS ocean/body appearance restore, simultaneous active-feature unload, camera binding removal and original movement restoration')

lua.execute(source)
lua.execute(r"""
assert(TEST_OPTIONS.bodyTrailEnabled.Value and TEST_OPTIONS.snowEnabled.Value and TEST_OPTIONS.freeCameraEnabled.Value)
assert(FIND('PV_BodyTrail',ME.Character)and FIND('PV_SnowLayer1'))
TEST_LIBRARY:Toggle(false)TICK(.1)assert(workspace.CurrentCamera.CameraType==Enum.CameraType.Scriptable)
for i=1,12 do
 local previous=ME.Character
 ME.Character=CREATE_CHARACTER('RepeatedRespawn'..i,0)previous:Destroy()
 ME.CharacterAdded:Fire(ME.Character)TEST_DRAIN()TICK(.6)
 assert(FIND('PV_BodyTrail',ME.Character)and ME.Character:FindFirstChildOfClass('Humanoid').WalkSpeed==0)
end
TEST_OPTIONS.freeCameraEnabled:SetValue(false)
assert(ME.Character:FindFirstChildOfClass('Humanoid').WalkSpeed==16)
TEST_ACTIONS['Unload script']()
assert(not FIND('PV_VisualExpansion'))
""")
print('PASS actual autosave/re-execution of enabled expansion features, 12 repeated character replacements and final restore/unload')

# Exact catalog size/complete faces; gradients intentionally share horizontal faces.
from support import ROOT
data=lua.execute((ROOT/'lib/VisualPresets.lua').read_text(encoding='utf-8'))
skies=data['Skies'];assert len(list(skies.keys()))==20
fingerprints=set()
for name in skies.keys():
 faces=tuple(skies[name]['Skybox'+key] for key in ['Bk','Dn','Ft','Lf','Rt','Up'])
 assert all(isinstance(face,str) and face.startswith(('rbxassetid://','rbxasset://','http://')) for face in faces),name
 fingerprints.add(faces)
assert len(fingerprints)==20,'catalog contains duplicate six-face sets'
print('PASS 20 distinct complete skybox sets; texture availability still requires live Roblox')
