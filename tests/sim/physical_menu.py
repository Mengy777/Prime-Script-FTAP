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
TEST_OVERLAP=false TEST_WALL=false TEST_SWEEPS=0 TEST_NO_GROUND=false
OverlapParams={new=function()return {}end}
local oldAdd=mt.__add
mt.__add=function(a,b)local f=CFrame.new(a.Position+b)f.yaw=a.yaw return f end
CFrame.lookAt=function(pos,target)local f=CFrame.new(pos)f.yaw=math.pi return f end
workspace.GetPartBoundsInBox=function()return TEST_OVERLAP and {{}}or{}end
workspace.Blockcast=function(self,cf,size,delta,params)
 TEST_SWEEPS=(TEST_SWEEPS or 0)+1
 if TEST_WALL then return {Distance=0}end
end
local cas=TEST_SERVICES.ContextActionService
cas.callbacks={}
function cas:BindActionAtPriority(name,fn,touch,priority) self.callbacks[name]=fn end
function cas:UnbindAction(name) self.callbacks[name]=nil end
HIT_X=nil HIT_Y=nil
workspace.Raycast=function(self,origin,direction,params)
 if direction.Y < -100 then if TEST_NO_GROUND then return nil end return {Position=Vector3.new(origin.X,0,origin.Z),Normal=Vector3.new(0,1,0)}end
 local p=self:FindFirstChild('PV_PhysicalMenu') if not p or not HIT_X then return nil end
 local canvas=TEST_LIBRARY.PhysicalGui.CanvasSize
 local localPoint=Vector3.new((.5-HIT_X/1000)*p.Size.X,(.5-HIT_Y/720)*p.Size.Y,TEST_BACK and .04 or -.04)
 return {Instance=p,Position=p.CFrame:PointToWorldSpace(localPoint)}
end
''')
lua.execute(source)
lua.execute('''
local function block()return workspace:FindFirstChild('PV_PhysicalMenu')end
local function pressMenu()TEST_SERVICES.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.RightControl},false)end
local main=TEST_LIBRARY.TestMain local parent=main.Parent local position=main.Position
local option=TEST_OPTIONS.cameraFOV local tab=TEST_TAB_OBJECTS.Shaders
for _,t in pairs(TEST_TAB_OBJECTS)do t.Container.Parent=main end
assert(not TEST_OPTIONS.worldMenuEnabled.Value and not block())
TEST_SERVICES.UserInputService.MouseIconEnabled=true
local notice=Instance.new('Frame') notice.Name='ObsidianNotifications' notice.ZIndex=200 notice.Parent=TEST_LIBRARY.ScreenGui
TEST_LIBRARY.NotificationArea=notice
TEST_OPTIONS.worldMenuEnabled:SetValue(true)
assert(notice.Parent==TEST_LIBRARY.ScreenGui,'notifications moved into the world menu')
assert(block() and block().Transparency==0 and block().CanCollide==true and block().Anchored==false and block().Size.Z>.5)
local surface=TEST_LIBRARY.PhysicalGui
assert(math.abs(block().CFrame.Position.Y-block().Size.Y/2-.06)<.001,'not placed on ground')
assert(surface.ToolPunchThroughDistance==100)
assert(surface.ResetOnSpawn==false,'surface destroys original UI on respawn')
assert(surface and surface.Adornee==block() and surface.Parent==TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'))
assert(main.Parent==surface and TEST_LIBRARY.Toggled and option==TEST_OPTIONS.cameraFOV)
main.BackgroundTransparency=.5 assert(main.BackgroundTransparency==0,'physical UI became transparent')
assert(tab.Container:IsDescendantOf(main),'actual shader page was not moved')
local guard=TEST_SERVICES.ContextActionService.callbacks.PrimePhysicalMenuGuard
HIT_X=nil assert(guard(nil,Enum.UserInputState.Begin)==Enum.ContextActionResult.Pass)
HIT_X=500 HIT_Y=360 assert(guard(nil,Enum.UserInputState.Begin)==Enum.ContextActionResult.Pass,'normal GUI click swallowed')
assert(guard(nil,Enum.UserInputState.End)==Enum.ContextActionResult.Pass)
TEST_BACK=true assert(guard(nil,Enum.UserInputState.Begin)==Enum.ContextActionResult.Sink)
HIT_X=nil assert(guard(nil,Enum.UserInputState.End)==Enum.ContextActionResult.Sink)TEST_BACK=false
assert(not surface:FindFirstChild('PV_MenuInputBackplane').Active)
for _,o in ipairs(workspace:GetDescendants())do assert(not o:IsA('Beam'),'artificial beam created')end
local original=option.Value option:SetValue(original+5)
assert(workspace.CurrentCamera.FieldOfView==original+5,'original setter stopped working')
HIT_X=750 HIT_Y=360
local point=TEST_LIBRARY.PointerProvider()
assert(math.abs(point.X-surface.CanvasSize.X*.75)<.001 and math.abs(point.Y-surface.CanvasSize.Y*.5)<.001)
TEST_BACK=true assert(TEST_LIBRARY.PointerProvider().X<0,'back face accepted')TEST_BACK=false
-- Ordinary clicks remain with the native SurfaceGui controls.
local input={UserInputType=Enum.UserInputType.MouseButton1}
local before=block().CFrame.Position
TEST_SERVICES.UserInputService.InputBegan:Fire(input,true)
workspace.CurrentCamera.CFrame=CFrame.new(3,8,0)TEST_SERVICES.RunService.RenderStepped:Fire(.016)
assert((block().CFrame.Position-before).Magnitude<.001,'ordinary control click moves the block')
TEST_SERVICES.UserInputService.InputEnded:Fire(input,false)
-- Alt-drag works from any front pixel, including the body rather than a header.
KEYS.LeftAlt=true
TEST_SERVICES.UserInputService.InputBegan:Fire(input,true)
workspace.CurrentCamera.CFrame=CFrame.new(8,8,0)TEST_SERVICES.RunService.RenderStepped:Fire(.016)
assert((block().CFrame.Position-before).Magnitude>1 and TEST_LIBRARY.PhysicalDragging and block().Anchored)
local stopped=block().CFrame.Position TEST_WALL=true
workspace.CurrentCamera.CFrame=CFrame.new(10,8,0)TEST_SERVICES.RunService.RenderStepped:Fire(.016)
assert((block().CFrame.Position-stopped).Magnitude<.001,'drag tunneled through wall')TEST_WALL=false
assert(TEST_SWEEPS>0)
TEST_SERVICES.UserInputService.InputEnded:Fire(input,false)KEYS.LeftAlt=false TEST_DRAIN()
assert(not TEST_LIBRARY.PhysicalDragging and not block().Anchored)
local right={UserInputType=Enum.UserInputType.MouseButton2}
local guard=TEST_SERVICES.ContextActionService.callbacks.PrimePhysicalMenuGuard
assert(guard(nil,Enum.UserInputState.Begin,right)==Enum.ContextActionResult.Sink and TEST_LIBRARY.PhysicalDragging)
workspace.CurrentCamera.CFrame=CFrame.new(12,8,0)TEST_SERVICES.RunService.RenderStepped:Fire(.016)
assert(guard(nil,Enum.UserInputState.End,right)==Enum.ContextActionResult.Sink)TEST_DRAIN()
assert(not TEST_LIBRARY.PhysicalDragging and not block().Anchored)
local fixed=block().CFrame.Position
workspace.CurrentCamera.CFrame=CFrame.new(20,8,0)HIT_X=nil TEST_SERVICES.RunService.RenderStepped:Fire(.016)
assert((block().CFrame.Position-fixed).Magnitude<.001)
pressMenu()assert(not block() and main.Parent==parent and main.Position==position and TEST_LIBRARY.PointerProvider==nil)
pressMenu()assert(block() and block().CFrame.Position.X==20 and main.Parent==TEST_LIBRARY.PhysicalGui)
-- Respawn/water teleport recovery preserves the SAME native UI and screen notifications.
TEST_SERVICES.Players.LocalPlayer.CharacterAdded:Fire(TEST_SERVICES.Players.LocalPlayer.Character)
assert(not block() and main.Parent==parent and notice.Parent==TEST_LIBRARY.ScreenGui)
pressMenu()assert(block() and main.Parent==TEST_LIBRARY.PhysicalGui,'cannot reopen after respawn')
-- An externally deleted block does not lose its surface controls.
block():Destroy()
pressMenu()assert(block() and main.Parent==TEST_LIBRARY.PhysicalGui,'stale native Toggled prevents reopening')
KEYS.LeftShift=true pressMenu()KEYS.LeftShift=false
assert(not TEST_OPTIONS.worldMenuEnabled.Value)
assert(not block() and main.Parent==parent and TEST_LIBRARY.Toggled)
local rawNew=Instance.new
Instance.new=function(class)if class=='SurfaceGui'then error('injected surface construction failure')end return rawNew(class)end
TEST_OPTIONS.worldMenuEnabled:SetValue(true)
Instance.new=rawNew
assert(not TEST_OPTIONS.worldMenuEnabled.Value and not block() and main.Parent==parent and TEST_LIBRARY.Toggled,'failed mount trapped UI')
local camera=workspace.CurrentCamera workspace.CurrentCamera=nil
TEST_OPTIONS.worldMenuEnabled:SetValue(true)workspace.CurrentCamera=camera
assert(not TEST_OPTIONS.worldMenuEnabled.Value and TEST_LIBRARY.Toggled,'missing camera trapped UI')
TEST_NO_GROUND=true TEST_OPTIONS.worldMenuEnabled:SetValue(true)
assert(not TEST_OPTIONS.worldMenuEnabled.Value and not block() and TEST_LIBRARY.Toggled,'no ground trapped UI')TEST_NO_GROUND=false
TEST_OVERLAP=true TEST_OPTIONS.worldMenuEnabled:SetValue(true)
assert(not TEST_OPTIONS.worldMenuEnabled.Value and not block() and TEST_LIBRARY.Toggled,'blocked placement trapped UI')TEST_OVERLAP=false
TEST_OPTIONS.worldMenuEnabled:SetValue(true)assert(block()) TEST_DRAIN()
TEST_ACTIONS['Unload script']()
assert(not block() and TEST_LIBRARY.PhysicalGui==nil and TEST_LIBRARY.PointerProvider==nil)
''')
lua.execute(source)
lua.execute("assert(TEST_OPTIONS.worldMenuEnabled.Value and workspace:FindFirstChild('PV_PhysicalMenu'));TEST_OPTIONS.worldMenuEnabled:SetValue(false);assert(TEST_LIBRARY.Toggled);TEST_ACTIONS['Unload script']()")
print('PASS original UI identity/callbacks on opaque local block, no Beam, local-block game-input guard, surface pointer, Alt-drag body, stationary release, recenter, 2D restore and cold reload')
