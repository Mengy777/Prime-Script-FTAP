from support import Disk,session
import json
D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(r"""
local mt=getmetatable(Vector3.zero)local originalIndex=mt.__index
mt.__index=function(t,key)
 if key=='Dot'then return function(a,b)return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
 return originalIndex(t,key)
end
local rawCF=CFrame.new
CFrame.new=function(x,y,z)return {Position=type(x)=='table'and x or Vector3.new(x,y,z),LookVector=Vector3.new(0,0,-1),RightVector=Vector3.new(1,0,0),UpVector=Vector3.new(0,1,0)}end
local camera=workspace.CurrentCamera camera.CFrame=CFrame.new(0,6,0)camera.Focus=CFrame.new(0,6,-16)
camera.ViewportPointToRay=function(self,x,y)return {Origin=self.CFrame.Position,Direction=Vector3.new((x/1280-.5)*.7,-.3,-1).Unit}end
SUN=Vector3.new(0,1,0)BLOCK_SUN=false
TEST_SERVICES.Lighting.GetSunDirection=function()return SUN end
HIT=Instance.new('Part')HIT.Name='SampleWall'HIT.Position=Vector3.new()HIT.Color=Color3.new(1,.3,.1)HIT.Material=Enum.Material.Plastic HIT.Transparency=0 HIT.Parent=workspace
RAYS=0 SAMPLE_RAYS=0
workspace.Raycast=function(_,origin,direction,params)
 RAYS=RAYS+1
 if direction.Y>100 and math.abs(direction.Z)<.01 then
  if BLOCK_SUN then return {Instance=HIT,Position=Vector3.new(),Normal=Vector3.new(0,1,0)}end
  return nil
 end
 if math.abs(direction.Z)<.01 then return {Instance=HIT,Position=Vector3.new(origin.X,0,origin.Z),Normal=Vector3.new(0,1,0),Material=Enum.Material.Plastic}end
 SAMPLE_RAYS=SAMPLE_RAYS+1
 return {Instance=HIT,Position=Vector3.new((SAMPLE_RAYS%7)*8,0,-(SAMPLE_RAYS%9)*8),Normal=Vector3.new(0,1,0),Material=Enum.Material.Plastic}
end
function TICKFX(dt)TEST_CLOCK=TEST_CLOCK+dt TEST_SERVICES.RunService.Heartbeat:Fire(dt)end
function COUNT(class)
 local n=0 local root=workspace:FindFirstChild('PV_ExperimentalGraphics')
 if root then for _,o in ipairs(root:GetDescendants())do if o:IsA(class)then n=n+1 end end end
 return n
end
function FXROOT()return workspace:FindFirstChild('PV_ExperimentalGraphics')end
""")
lua.execute(source)
lua.execute(r"""
assert(not TEST_OPTIONS.giEnabled.Value and not TEST_OPTIONS.shaftEnabled.Value and not FXROOT())
local rays=RAYS for i=1,20 do TICKFX(.1)end assert(RAYS==rays,'disabled graphics performed raycasts')
TEST_OPTIONS.giQuality:SetValue('Low')TEST_OPTIONS.giLocalLights:SetValue(false)TEST_OPTIONS.giEnabled:SetValue(true)
TEST_DRAIN()
""")
before=D.writes
lua.execute(r"""
for i=1,120 do
 local rays=RAYS TICKFX(.2)assert(RAYS-rays<=4,'Low quality exceeded two samples/tick')
 assert(COUNT('PointLight')<=12,'Low pool exceeded budget')
end
assert(COUNT('PointLight')>0,'sunlit probes not created')
local energy=false
for _,o in ipairs(FXROOT():GetDescendants())do if o:IsA('PointLight')and o.Brightness>0 then energy=true end end
assert(energy,'bounce lights never faded in')
TEST_DRAIN()
""")
assert D.writes==before,'animation loop wrote profiles'
lua.execute(r"""
TEST_OPTIONS.giQuality:SetValue('Ultra')
for i=1,100 do local rays=RAYS TICKFX(.1)assert(RAYS-rays<=16)assert(COUNT('PointLight')<=64)end
TEST_OPTIONS.giStrength:SetValue(0)TICKFX(.2)
TEST_OPTIONS.giEnabled:SetValue(false)assert(COUNT('PointLight')==0)
-- No direct sun and no local light: no fake brightening of unlit surfaces.
BLOCK_SUN=true TEST_OPTIONS.giEnabled:SetValue(true)
for i=1,8 do TICKFX(.2)end assert(COUNT('PointLight')==0,'occluded sun created bounce lights')
-- A real local light can contribute when direct sunlight is blocked.
local lampPart=Instance.new('Part')lampPart.Name='LampBody'lampPart.Position=Vector3.new(20,12,-20)lampPart.Parent=workspace
local lamp=Instance.new('PointLight')lamp.Name='RealLamp'lamp.Enabled=true lamp.Shadows=false lamp.Range=120 lamp.Brightness=8 lamp.Color=Color3.new(.2,1,.2)lamp.Parent=lampPart
TEST_OPTIONS.giLocalLights:SetValue(true)
for i=1,5 do TICKFX(.2)end assert(COUNT('PointLight')>0,'local light not sampled')
lamp.Enabled=false TEST_OPTIONS.giLocalLights:SetValue(false)TEST_OPTIONS.giLocalLights:SetValue(true)
for i=1,6 do TICKFX(.2)end assert(COUNT('PointLight')==0,'disabled local light still contributes')
TEST_OPTIONS.giEnabled:SetValue(false)lampPart:Destroy()BLOCK_SUN=false
TEST_OPTIONS.shaftEnabled:SetValue(true)TICKFX(.2)
assert(COUNT('Beam')==12)
for _,o in ipairs(FXROOT():GetDescendants())do if o:IsA('Beam')then assert(o.Enabled and o.FaceCamera and o.Attachment0 and o.Attachment1)end end
TEST_OPTIONS.shaftCount:SetValue(24)TICKFX(.2)assert(COUNT('Beam')==24)
SUN=Vector3.new(0,-1,0)TICKFX(.2)assert(COUNT('Beam')==0,'night shafts remained')
SUN=Vector3.new(0,1,0)TICKFX(.2)assert(COUNT('Beam')==24)
TEST_OPTIONS.shaftEnabled:SetValue(false)assert(COUNT('Beam')==0)
TEST_OPTIONS.giEnabled:SetValue(true)TEST_OPTIONS.shaftEnabled:SetValue(true)
for i=1,8 do TICKFX(.2)end
FXROOT():Destroy()TICKFX(.2)TICKFX(.2)
assert(COUNT('Beam')==24 and COUNT('PointLight')>0,'deleted effects did not recover')
TEST_OPTIONS.visualPreset:SetValue('Pale Frost')TEST_OPTIONS.visualPresetEnabled:SetValue(true)
local brightness=TEST_SERVICES.Lighting.Brightness
TICKFX(.2)assert(TEST_SERVICES.Lighting.Brightness==brightness,'experimental effects changed scene brightness')
TEST_DRAIN()
""")
auto=json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])
assert len(auto['payload']['values'])==353
lua.execute("TEST_ACTIONS['Unload script']();assert(not FXROOT())")
lua2,*_=session(D)
lua2.execute("assert(TEST_OPTIONS.giEnabled.Value and TEST_OPTIONS.shaftEnabled.Value and TEST_OPTIONS.giQuality.Value=='Ultra');TEST_ACTIONS['Unload script']();assert(not workspace:FindFirstChild('PV_ExperimentalGraphics'))")
print('PASS disabled/no-ray default; Low/Ultra sample and light budgets; sunlight/occlusion/local-light paths; zero per-tick config writes')
print('PASS 12/24 shafts, night cleanup, destroyed-folder recovery, presets unchanged, 353-key persistence and full unload')
