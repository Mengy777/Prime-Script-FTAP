from support import Disk,session
D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(r"""
ME=TEST_SERVICES.Players.LocalPlayer
function CHARACTER(name)
 local char=Instance.new('Model')char.Name=name char.Parent=workspace
 for _,name in ipairs({'HumanoidRootPart','Head','Torso','Left Arm','Right Arm','Left Leg','Right Leg'})do
  local p=Instance.new('Part')p.Name=name p.LocalTransparencyModifier=1 p.Transparency=name=='HumanoidRootPart'and 1 or 0 p.Parent=char
 end
 local hat=Instance.new('Accessory')hat.Parent=char
 local handle=Instance.new('MeshPart')handle.Name='Handle'handle.LocalTransparencyModifier=1 handle.Transparency=.2 handle.Parent=hat
 return char
end
ME.Character=CHARACTER('Original')
TEST_SERVICES.UserInputService.MouseDeltaSensitivity=.63
""")
lua.execute(source)
lua.execute(r"""
TEST_OPTIONS.camThird:SetValue(true)
local char=ME.Character
for _,p in ipairs(char:GetDescendants())do
 if p:IsA('BasePart')and p.Name~='HumanoidRootPart'then assert(p.LocalTransparencyModifier==0,p.Name..' stayed hidden')end
end
assert(char:FindFirstChild('HumanoidRootPart').Transparency==1)
local handle=char:FindFirstChildWhichIsA('Accessory'):FindFirstChild('Handle')assert(handle.Transparency==.2)
for i=1,100 do
 char:FindFirstChild('Head').LocalTransparencyModifier=1
 TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
 assert(char:FindFirstChild('Head').LocalTransparencyModifier==0)
end
TEST_OPTIONS.camBody:SetValue(true)
TEST_SERVICES.RunService.RenderStepped:Fire(.016)
TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
assert(char:FindFirstChild('Torso').LocalTransparencyModifier==0,'first-person body alpha competed with third person')
TEST_OPTIONS.camDistance:SetValue(30)
assert(ME.CameraMinZoomDistance==.5 and ME.CameraMaxZoomDistance==80)
local lateAccessory=Instance.new('Accessory')lateAccessory.Name='LateAccessory'lateAccessory.Parent=char
local later=Instance.new('MeshPart')later.Name='Handle' later.LocalTransparencyModifier=1 later.Transparency=.4 later.Parent=lateAccessory
char.DescendantAdded:Fire(later)TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
assert(later.LocalTransparencyModifier==0 and later.Transparency==.4)
local camera=workspace.CurrentCamera
camera.CFrame={Position=Vector3.new(0,0,0)}camera.Focus={Position=Vector3.new(0,0,.5)}
TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
TEST_SERVICES.RunService.RenderStepped:Fire(.016)
assert(char:FindFirstChild('Head').LocalTransparencyModifier==1,'head must be hidden when wheel zoom reaches first person')
assert(char:FindFirstChild('Torso').LocalTransparencyModifier==.3,'first-person body stopped working at close zoom')
camera.Focus={Position=Vector3.new(0,0,12)}
TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
assert(char:FindFirstChild('Head').LocalTransparencyModifier==0,'skin did not return when zooming back out')
-- Custom camera Focus can remain close even when the actual camera is far.
local head=char:FindFirstChild('Head')
head.Position=Vector3.new(0,0,0)
camera.CFrame={Position=Vector3.new(0,0,12)} camera.Focus={Position=Vector3.new(0,0,12.5)}
for cycle=1,150 do
 camera.CFrame={Position=Vector3.new(0,0,.5)}
 TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
 head.LocalTransparencyModifier=1
 camera.CFrame={Position=Vector3.new(0,0,12)}
 TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
 for _,p in ipairs(char:GetDescendants())do
  if p:IsA('BasePart')and p.Name~='HumanoidRootPart'then
   p.LocalTransparencyModifier=1 -- A game listener AFTER our render callback.
   assert(p.LocalTransparencyModifier==0,'late game visibility write hid '..p.Name)
  end
 end
end
-- Pitch offsets can move first-person camera >1 stud from Head centre.
for cycle=1,60 do
 for _,position in ipairs({Vector3.new(0,1.4,.4),Vector3.new(0,-1.4,.4),Vector3.new(1.3,0,.6)})do
  camera.CFrame={Position=position}
  TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
  head.LocalTransparencyModifier=0 handle.LocalTransparencyModifier=0
  assert(head.LocalTransparencyModifier==1 and handle.LocalTransparencyModifier==1,'first-person pitch exposed head/hair')
  TEST_SERVICES.RunService.RenderStepped:Fire(.016)
  assert(char:FindFirstChild('Torso').LocalTransparencyModifier==.3,'near guard hid intended first-person body')
 end
 camera.CFrame={Position=Vector3.new(0,0,12)}
 TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
 assert(head.LocalTransparencyModifier==0 and handle.LocalTransparencyModifier==0,'head/hair stayed hidden on zoom out')
 assert(handle.Transparency==.2,'true accessory transparency changed')
end
local removed=Instance.new('Part')removed.Name='Removed' removed.LocalTransparencyModifier=0 removed.Parent=char
char.DescendantAdded:Fire(removed)
removed.Parent=workspace TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
removed.LocalTransparencyModifier=1 assert(removed.LocalTransparencyModifier==1,'detached part still guarded')
removed:Destroy()
camera.Focus={Position=Vector3.new(0,0,0)} -- End stale-Focus case before legacy respawn scenarios.
-- Ordinary Transparency (not LTM) can hide the mesh while its face decal stays.
local helper=Instance.new('Part')helper.Name='RagdollTouchedHitbox'helper.Transparency=1 helper.LocalTransparencyModifier=1 helper.Parent=char
char.DescendantAdded:Fire(helper)
for cycle=1,360 do
 TEST_CLOCK=TEST_CLOCK+2 -- More than ten simulated minutes, without respawn.
 camera.CFrame={Position=Vector3.new(0,0,.5)}
 TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
 for _,part in ipairs(char:GetDescendants())do
  if part:IsA('BasePart') and part.Name~='HumanoidRootPart' and part~=helper then
   part.Transparency=1 part.LocalTransparencyModifier=1
  end
 end
 camera.CFrame={Position=Vector3.new(0,0,12)}
 TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
 for _,part in ipairs(char:GetDescendants())do
  if part:IsA('BasePart') and part.Name~='HumanoidRootPart' and part~=helper then
   local expected=part==handle and .2 or part==later and .4 or 0
   assert(part.Transparency==expected,'actual alpha remained hidden: '..part.Name)
   part.Transparency=1 -- Late ordinary-alpha write after camera visibility callback.
   assert(part.Transparency==expected,'late ordinary alpha hide was not repaired')
   assert(part.LocalTransparencyModifier==0)
  end
 end
 assert(helper.Transparency==1,'invisible hitbox was exposed')
end
helper:Destroy()
local clamps=0
local me=TEST_SERVICES.Players.LocalPlayer
local observer=me:GetPropertyChangedSignal('CameraMinZoomDistance'):Connect(function()
 if me.CameraMinZoomDistance==25 then clamps=clamps+1 end
end)
TEST_OPTIONS.camDistance:SetValue(25)
assert(clamps==1 and me.CameraMinZoomDistance==.5 and me.CameraMaxZoomDistance==80)
for i=1,5 do TEST_SERVICES.RunService.Heartbeat:Fire(1.1)end
assert(clamps==1,'maintenance snapped the user zoom back to slider distance')
observer:Disconnect()
for i=1,12 do
 local previous=ME.Character ME.Character=CHARACTER('Respawn'..i) previous:Destroy()
 ME.Character:FindFirstChild('Torso').Transparency=1 -- Already hidden when first observed.
 TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
 assert(ME.Character:FindFirstChild('Head').LocalTransparencyModifier==0)
 assert(ME.Character:FindFirstChild('Torso').Transparency==0,'known body fallback did not recover hidden torso')
end
TEST_OPTIONS.camThird:SetValue(false)
assert(not TEST_SERVICES.RunService._render.PrimeVisualsThirdBody)
assert(ME.Character:FindFirstChild('Head').LocalTransparencyModifier==1)
TEST_SERVICES.RunService.RenderStepped:Fire(.016)
assert(ME.Character:FindFirstChild('Torso').LocalTransparencyModifier==.3)
assert(TEST_SERVICES.UserInputService.MouseDeltaSensitivity==.63)
TEST_OPTIONS.camThird:SetValue(true)
TEST_ACTIONS['Unload script']()
assert(not TEST_SERVICES.RunService._render.PrimeVisualsThirdBody)
assert(ME.Character:FindFirstChild('Head').LocalTransparencyModifier==1)
""")
print('PASS stale first-person hiding, 100 camera rewrites, accessory loading, 12 respawns, first-person-body coexistence, native live distance, unchanged sensitivity and unload restore')
