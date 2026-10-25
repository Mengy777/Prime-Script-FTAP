from support import Disk,session
import json
D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(r'''
TEST_CLOCK=0 os.clock=function()return TEST_CLOCK end
Color3.fromHSV=function(h,s,v)return Color3.new(h,s,v)end
ColorSequence.new=function(c)return {Keypoints={{Time=0,Value=c},{Time=1,Value=c}}}end
function TEST_BEAM(root)
 local beam=Instance.new('Beam') beam.Texture='native';beam.TextureSpeed=2;beam.Color=ColorSequence.new(Color3.new(1,1,1));beam.Segments=3;beam.Parent=root
 return beam
end
STALE=Instance.new('Folder') STALE.Name='GrabParts' STALE.Parent=workspace
LIVE=Instance.new('Folder') LIVE.Name='GrabParts' LIVE.Parent=workspace
BEAM=TEST_BEAM(LIVE)
function TEST_TICK(dt)
 TEST_CLOCK=TEST_CLOCK+dt
 TEST_SERVICES.RunService.Heartbeat:Fire(dt)
end
function TEST_LISTENERS(beam)
 local count=0
 for _,signal in pairs(beam._props._signals or {}) do for _,link in ipairs(signal.handlers) do if link.active then count=count+1 end end end
 return count
end
''')
lua.execute(source)
lua.execute(r'''
TEST_OPTIONS.lineEnabled:SetValue(true)
TEST_OPTIONS.lineRainbow:SetValue(true)
EXPECTED=BEAM.Texture
assert(EXPECTED~='native','selected stale first GrabParts')
for i=1,60 do
 local previous=BEAM
 LIVE:Destroy()
 TEST_TICK(1.01)
 assert(TEST_LISTENERS(previous)==0,'dead beam listeners retained')
 local scope=workspace
 if i%2==0 then scope=Instance.new('Folder');scope.Name='NestedScope';scope.Parent=workspace end
 LIVE=Instance.new('Folder');LIVE.Name='PendingName';LIVE.Parent=scope
 BEAM=TEST_BEAM(LIVE)
 TEST_SERVICES.Workspace.DescendantAdded:Fire(BEAM)
 LIVE.Name='GrabParts' -- rename does not produce another DescendantAdded event
 TEST_SERVICES.Players.LocalPlayer.CharacterAdded:Fire(TEST_SERVICES.Players.LocalPlayer.Character)
 TEST_DRAIN()
 TEST_TICK(1.01)
 assert(BEAM.Texture==EXPECTED and BEAM.Segments==3,'respawn lost line')
 assert(TEST_LISTENERS(BEAM)==3,'duplicate beam listeners')
 BEAM.Texture='game rewrite';BEAM.TextureSpeed=-8
 assert(BEAM.Texture==EXPECTED and BEAM.TextureSpeed==1,'late rewrite not repaired')
end
LIVE.Name='TemporarilyReusedScope';TEST_TICK(1.01)
assert(BEAM.Texture=='native')
LIVE.Name='GrabParts';TEST_TICK(1.01)
assert(BEAM.Texture==EXPECTED,'renamed nested scope did not recover')
local before=BEAM.Color.Keypoints[1].Value.R
for i=1,1800 do TEST_TICK(0.2) end
assert(BEAM.Texture==EXPECTED and BEAM.Color.Keypoints[1].Value.R~=before and TEST_LISTENERS(BEAM)==3)
TEST_OPTIONS.lineRainbow:SetValue(false)
local red=Color3.new(1,0,0);TEST_OPTIONS.lineColor:SetValueRGB(red)
BEAM.Texture='temporary conflicting hook'
local force=true
local hook=BEAM:GetPropertyChangedSignal('Texture'):Connect(function() if force then BEAM.Texture='game forced' end end)
BEAM.Texture='another reset'
force=false;TEST_TICK(0.2)
assert(BEAM.Texture==EXPECTED,'line did not recover after temporary contention') hook:Disconnect()
local target=Instance.new('Part');target.Name='CurrentHeldItem';target.Material=Enum.Material.Plastic;target.AssemblyMass=10;target.Parent=workspace
local attachment=Instance.new('Attachment');attachment.Parent=target;BEAM.Attachment1=attachment
TEST_OPTIONS.grabInfo:SetValue(true);TEST_TICK(0.2)
local info=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeVisualsGrabInfo'):FindFirstChildOfClass('TextLabel')
assert(info.Text:find('CurrentHeldItem',1,true),'grab info still used stale first folder')
TEST_OPTIONS.lineEnabled:SetValue(false)
assert(BEAM.Texture=='native' and BEAM.TextureSpeed==2 and TEST_LISTENERS(BEAM)==0)
TEST_OPTIONS.lineEnabled:SetValue(true);TEST_DRAIN()
''')
# Restart in the same game, leaving stale duplicate/nested folders in place.
lua.execute(source)
lua.execute(r'''
assert(TEST_OPTIONS.lineEnabled.Value and BEAM.Texture==EXPECTED,'reload still required a game rejoin')
TEST_ACTIONS['Unload script']()
assert(BEAM.Texture=='native' and TEST_LISTENERS(BEAM)==0)
assert(#TEST_NOTICES==0,'line manager reported feature errors')
''')
print('PASS 60 deaths, stale duplicate folders, nested/renamed scopes, delayed rewrites, 6 simulated minutes, listener bounds, grab info and script reload without rejoining')

E=Disk();lu,s,_,_=session(E,execute=False)
lu.execute(r'''
TEST_CLOCK=0 os.clock=function()return TEST_CLOCK end
TEST_SERVICES.Workspace.CurrentCamera.CFrame=CFrame.new()
local head=Instance.new('Part');head.Name='Head';head.Position=Vector3.new();head.Parent=TEST_SERVICES.Players.LocalPlayer.Character
''')
lu.execute(s)
lu.execute(r'''
TEST_OPTIONS.cameraFOV:SetValue(93)
TEST_OPTIONS.camDistance:SetValue(23);TEST_OPTIONS.camThird:SetValue(true)
local detector=Instance.new('Part');detector.Name='PlayerCharacterLocationDetector';detector.Size=Vector3.new(1,1,1);detector.Position=Vector3.new(20,0,0);detector.CFrame=CFrame.new();detector.Parent=workspace
TEST_OPTIONS.espServerSmooth:SetValue(false);TEST_OPTIONS.espServer:SetValue(true)
TEST_OPTIONS.lightEnabled:SetValue(true)
TEST_OPTIONS.particleEnabled:SetValue(true)
TEST_OPTIONS.hatEnabled:SetValue(true)
TEST_OPTIONS.crossEnabled:SetValue(true)
TEST_OPTIONS.skyAsset:SetValue('570559352');TEST_ACTIONS.Load()
TEST_OPTIONS.skyClouds:SetValue(true)
TEST_DRAIN()
''')
initial_writes=E.writes
lu.execute(r'''
for cycle=1,12 do
 TEST_SERVICES.Workspace.CurrentCamera.FieldOfView=70
 TEST_SERVICES.Players.LocalPlayer.CameraMaxZoomDistance=128
 workspace:FindFirstChild('PV_ESP'):Destroy()
 TEST_SERVICES.Lighting:FindFirstChild('PV_Color'):Destroy()
 workspace:FindFirstChild('PV_Particles'):Destroy()
 workspace:FindFirstChild('PV_ConeHat'):FindFirstChildOfClass('SpecialMesh'):Destroy()
 TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeVisualsCrosshair'):Destroy()
 TEST_SERVICES.Lighting:FindFirstChild('PrimeVisualsSky'):Destroy()
 workspace.Terrain:FindFirstChildOfClass('Clouds'):Destroy()
 TEST_CLOCK=TEST_CLOCK+1.1;TEST_SERVICES.RunService.Heartbeat:Fire(1.1)
 assert(TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==93 and TEST_SERVICES.Players.LocalPlayer.CameraMaxZoomDistance==23)
 assert(workspace:FindFirstChild('PV_ESP'):FindFirstChildOfClass('Highlight'))
 assert(TEST_SERVICES.Lighting:FindFirstChild('PV_Color').Enabled)
 assert(workspace:FindFirstChild('PV_Particles'):FindFirstChildOfClass('ParticleEmitter').Enabled)
 assert(workspace:FindFirstChild('PV_ConeHat'):FindFirstChildOfClass('SpecialMesh'))
 assert(TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeVisualsCrosshair'))
 assert(TEST_SERVICES.Lighting:FindFirstChild('PrimeVisualsSky').SkyboxBk=='rbxassetid://570557514')
 assert(workspace.Terrain:FindFirstChildOfClass('Clouds').Enabled)
 TEST_SERVICES.RunService.RenderStepped:Fire(0.1)
end
assert(#TEST_NOTICES==0,'effect recovery errors')
''')
assert E.writes==initial_writes,'recovery wrote unchanged configs'
lu.execute("TEST_ACTIONS['Unload script'](); assert(not workspace:FindFirstChild('PV_Particles') and not workspace:FindFirstChild('PV_ConeHat'))")
print('PASS 12 game-driven clearing cycles restore camera/ESP and recreate enabled shaders, particles, hat mesh, crosshair, skybox and clouds; no duplicate config writes')

lu,s,_,_=session(Disk(),execute=False)
injection=r'''
TEST_RETRIES=0
job('Transient simulation',Run.Heartbeat,function()
 TEST_RETRIES=TEST_RETRIES+1
 if TEST_RETRIES==1 then error('injected transient callback error')end
end)
'''
s=s.replace('    -- HOME: profile',injection+'    -- HOME: profile',1)
lu.execute('TEST_CLOCK=0;os.clock=function()return TEST_CLOCK end')
lu.execute(s)
lu.execute(r'''
TEST_SERVICES.RunService.Heartbeat:Fire(0.01)
assert(TEST_RETRIES==1)
for i=1,20 do TEST_SERVICES.RunService.Heartbeat:Fire(0.01)end
assert(TEST_RETRIES==1,'retry cooldown ignored')
TEST_CLOCK=0.6;TEST_SERVICES.RunService.Heartbeat:Fire(0.01)
assert(TEST_RETRIES==2,'transient error permanently disconnected the job')
TEST_SERVICES.RunService.Heartbeat:Fire(0.01);assert(TEST_RETRIES==3)
assert(#TEST_NOTICES==1,'repeated error notifications')
TEST_ACTIONS['Unload script']();TEST_CLOCK=5;TEST_SERVICES.RunService.Heartbeat:Fire(1)
assert(TEST_RETRIES==3)
''')
print('PASS temporary callback error retries with cooldown instead of permanently disabling the feature; unload stops it')
