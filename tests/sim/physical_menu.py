from support import ROOT

# Reuse the project's deterministic transforms and input fixture.
setup=(ROOT/'tests/sim/visual_expansion.py').read_text(encoding='utf8')
exec(setup[:setup.index('lua.execute(source)')])
lua.execute('''
local mt=getmetatable(workspace.CurrentCamera.CFrame)
function mt:PointToWorldSpace(p)
 local y=self.yaw or 0 local cs,sn=math.cos(y),math.sin(y)
 return self.Position+Vector3.new(cs*p.X+sn*p.Z,p.Y,-sn*p.X+cs*p.Z)
end
function mt:PointToObjectSpace(p)
 local d=p-self.Position local y=self.yaw or 0 local cs,sn=math.cos(y),math.sin(y)
 return Vector3.new(cs*d.X-sn*d.Z,d.Y,sn*d.X+cs*d.Z)
end
mt.__sub=function(a,b)local f=CFrame.new(a.Position-b)f.yaw=a.yaw return f end
local cas=TEST_SERVICES.ContextActionService
cas.callbacks={}
function cas:BindActionAtPriority(name,fn,touch,priority) self.callbacks[name]=fn end
function cas:UnbindAction(name) self.callbacks[name]=nil end
HIT_X=nil HIT_Y=nil
workspace.Raycast=function(self,origin,direction,params)
 local p=self:FindFirstChild('PV_PhysicalMenu') if not p or not HIT_X then return nil end
 local localPoint=Vector3.new((.5-HIT_X/1000)*p.Size.X,(.5-HIT_Y/720)*p.Size.Y,TEST_BACK and .04 or -.04)
 return {Instance=p,Position=p.CFrame:PointToWorldSpace(localPoint)}
end
''')
lua.execute(source)
lua.execute('''
local cas=TEST_SERVICES.ContextActionService
local function panel()return workspace:FindFirstChild('PV_PhysicalMenu')end
local function pressMenu()TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.RightControl},false)end
local function click(x,y)
 HIT_X=x HIT_Y=y
 local handler=cas.callbacks.PrimePhysicalMenu assert(handler)
 local result=handler(nil,Enum.UserInputState.Begin)
 if cas.callbacks.PrimePhysicalMenu then cas.callbacks.PrimePhysicalMenu(nil,Enum.UserInputState.End)end
 return result
end
assert(TEST_OPTIONS.worldMenuEnabled.Value==false and not panel(),'experimental mode enabled by default')
TEST_SERVICES.UserInputService.MouseIconEnabled=true
TEST_OPTIONS.worldMenuEnabled:SetValue(true)
assert(panel() and not TEST_LIBRARY.Toggled,'native menu not replaced')
assert(panel().Anchored and not panel().CanCollide and panel().Transparency==.75)
assert(panel():FindFirstChildOfClass('SurfaceGui') and TEST_SERVICES.UserInputService.MouseIconEnabled==false)
HIT_X=nil
assert(cas.callbacks.PrimePhysicalMenu(nil,Enum.UserInputState.Begin)==Enum.ContextActionResult.Pass,'outside click intercepted')
TEST_BACK=true assert(click(400,160)==Enum.ContextActionResult.Pass,'back-face click accepted')TEST_BACK=false
local values={} for key,o in pairs(TEST_OPTIONS)do if o.Type=='Toggle'then values[key]=o.Value end end
local clicked=false
for _,node in ipairs(panel():FindFirstChildOfClass('SurfaceGui'):GetChildren())do
 if node.Text and (node.Text:sub(1,4)=='[ON]' or node.Text:sub(1,5)=='[OFF]')then
  click(500,node.Position.Y.Offset+20)clicked=true break
 end
end
assert(clicked)
local changed=0 for key,value in pairs(values)do if TEST_OPTIONS[key].Value~=value then changed=changed+1 end end
assert(changed==1,'line click did not change exactly one registered toggle')
click(350,100) click(500,155)
assert(TEST_OPTIONS.visualPresetEnabled.Value,'physical shader selection not applied')
HIT_X=500 HIT_Y=35
assert(cas.callbacks.PrimePhysicalMenu(nil,Enum.UserInputState.Begin)==Enum.ContextActionResult.Sink)
local old=panel().CFrame.Position
workspace.CurrentCamera.CFrame=CFrame.new(3,8,0)
TEST_SERVICES.RunService.RenderStepped:Fire(.016)
assert((panel().CFrame.Position-old).Magnitude>1,'header drag did not move panel')
cas.callbacks.PrimePhysicalMenu(nil,Enum.UserInputState.End)
local fixed=panel().CFrame.Position
workspace.CurrentCamera.CFrame=CFrame.new(20,8,0) HIT_X=nil
TEST_SERVICES.RunService.RenderStepped:Fire(.016)
assert((panel().CFrame.Position-fixed).Magnitude<.001,'panel follows player after release')
pressMenu() assert(not panel(),'menu key did not hide world panel')
assert(not cas.callbacks.PrimePhysicalMenu and TEST_SERVICES.UserInputService.MouseIconEnabled==true)
pressMenu() assert(panel() and panel().CFrame.Position.X==20,'reopen did not recenter at current camera')
click(850,100)
assert(not TEST_OPTIONS.worldMenuEnabled.Value and not panel() and TEST_LIBRARY.Toggled,'2D fallback failed')
TEST_OPTIONS.worldMenuEnabled:SetValue(true) assert(panel())
TEST_DRAIN()
TEST_ACTIONS['Unload script']()
assert(not panel() and not cas.callbacks.PrimePhysicalMenu)
for _,o in ipairs(workspace:GetDescendants())do assert(o.Name~='PV_PhysicalMenuLine','line survived unload')end
''')
lua.execute(source)
lua.execute("assert(TEST_OPTIONS.worldMenuEnabled.Value and workspace:FindFirstChild('PV_PhysicalMenu'));TEST_OPTIONS.worldMenuEnabled:SetValue(false);assert(TEST_LIBRARY.Toggled);TEST_ACTIONS['Unload script']()")
print('PASS physical-menu default off, front-face line input, native setters, outside pass-through, header dragging, stationary release, menu hide/recenter, 2D fallback and cleanup')
