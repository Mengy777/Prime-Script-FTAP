# Deterministic Roblox/Obsidian mocks for the simulation tests. Not a live game.
from pathlib import Path
import sys
from lupa import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
stub=r'''
math.clamp=function(v,a,b) return math.max(a,math.min(b,v)) end
math.round=function(v) return math.floor(v+0.5) end
math.atan2=math.atan
unpack=table.unpack
table.find=function(t,v) for i,x in ipairs(t) do if x==v then return i end end end
warn=function(...) end
local function namespace()
 return setmetatable({}, {__index=function(t,k) local v={Name=k} rawset(t,k,v) return v end})
end
Enum=setmetatable({}, {__index=function(t,k) local v=namespace() rawset(t,k,v) return v end})
local vmt={}
vmt.__index=function(v,k)
 if k=='Magnitude' then return math.sqrt(v.X*v.X+v.Y*v.Y+(v.Z or 0)^2) end
 if k=='Unit' then local m=math.sqrt(v.X*v.X+v.Y*v.Y+(v.Z or 0)^2) return setmetatable({X=v.X/m,Y=v.Y/m,Z=(v.Z or 0)/m},vmt) end
end
vmt.__add=function(a,b) return setmetatable({X=a.X+b.X,Y=a.Y+b.Y,Z=(a.Z or 0)+(b.Z or 0)},vmt) end
vmt.__sub=function(a,b) return setmetatable({X=a.X-b.X,Y=a.Y-b.Y,Z=(a.Z or 0)-(b.Z or 0)},vmt) end
vmt.__mul=function(a,b) return setmetatable({X=a.X*b,Y=a.Y*b,Z=(a.Z or 0)*b},vmt) end
vmt.__div=function(a,b) return a*(1/b) end
Vector2={new=function(x,y) return setmetatable({X=x or 0,Y=y or 0},vmt) end}
Vector3={new=function(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vmt) end}
Vector3.zero=Vector3.new() Vector3.yAxis=Vector3.new(0,1,0)
UDim={new=function(s,o) return {Scale=s or 0,Offset=o or 0} end}
UDim2={new=function(xs,xo,ys,yo) return {X=UDim.new(xs,xo),Y=UDim.new(ys,yo)} end}
UDim2.fromOffset=function(x,y) return UDim2.new(0,x,0,y) end
UDim2.fromScale=function(x,y) return UDim2.new(x,0,y,0) end
Color3={new=function(r,g,b) return {R=r or 0,G=g or 0,B=b or 0} end}
Color3.fromRGB=function(r,g,b) return Color3.new(r/255,g/255,b/255) end
Color3.fromHSV=function() return Color3.new(1,0,1) end
for _,n in ipairs({'NumberRange','NumberSequence','ColorSequence'}) do _G[n]={new=function(...) return {...} end} end
TweenInfo={new=function(...) return {...} end}
CFrame={new=function(...) return {Position=Vector3.new(),LookVector=Vector3.new(0,0,-1)} end}
local function signal()
 local s={handlers={}}
 function s:Connect(f) local c={active=true,fn=f} function c:Disconnect() self.active=false end self.handlers[#self.handlers+1]=c return c end
 function s:Once(f) return self:Connect(f) end
 function s:Fire(...) for _,c in ipairs(self.handlers) do if c.active then c.fn(...) end end end
 return s
end
ALL_INSTANCES={}
local methods={}
local mt={__index=function(o,k)
 if methods[k] then return methods[k] end
 if k=='ClassName' then return o._class end
 if k=='AbsolutePosition' then local p=o._props.Position or UDim2.new() return Vector2.new(p.X.Offset,p.Y.Offset) end
 if k=='AbsoluteSize' then local p=o._props.Size or UDim2.fromOffset(720,600) return Vector2.new(p.X.Offset>0 and p.X.Offset or 720,p.Y.Offset>0 and p.Y.Offset or 600) end
 if o._props[k]~=nil then return o._props[k] end
 if k:find('Click') or k:find('Changed') or k:find('Added') or k:find('Removing') or k:find('Input') or k=='Destroying' or k=='Activated' or k=='Focused' or k=='FocusLost' or k=='MouseEnter' or k=='MouseLeave' or k=='RenderStepped' or k=='Heartbeat' or k=='WindowFocusReleased' then
  local v=signal() o._props[k]=v return v
 end
 if k=='Position' then return UDim2.new() end
 if k=='Transparency' then return 0 end
end,
__newindex=function(o,k,v)
 if k=='Parent' then
  local old=o._props.Parent
  if old then for i,c in ipairs(old._children) do if c==o then table.remove(old._children,i) break end end end
  o._props.Parent=v if v then table.insert(v._children,o) end
 else
  local old=o._props[k] o._props[k]=v
  local signals=o._props._signals
  if old~=v and signals and signals[k] then signals[k]:Fire() end
 end
end}
Instance={new=function(class)
 local o=setmetatable({_class=class,_props={Name=class,Visible=true,Enabled=true,Text='',Anchored=false,Archivable=true},_children={}},mt)
 table.insert(ALL_INSTANCES,o) return o
end}
function methods:GetChildren() local t={} for _,c in ipairs(self._children) do table.insert(t,c) end return t end
function methods:GetDescendants() local t={} local function walk(o) for _,c in ipairs(o._children) do t[#t+1]=c walk(c) end end walk(self) return t end
function methods:FindFirstChild(name,recursive) for _,o in ipairs(recursive and self:GetDescendants() or self._children) do if o.Name==name then return o end end end
function methods:WaitForChild(name) local c=self:FindFirstChild(name) if c then return c end c=Instance.new('Folder') c.Name=name c.Parent=self return c end
function methods:FindFirstChildOfClass(class) for _,o in ipairs(self._children) do if o:IsA(class) then return o end end end
function methods:FindFirstChildWhichIsA(class,recursive) for _,o in ipairs(recursive and self:GetDescendants() or self._children) do if o:IsA(class) then return o end end end
function methods:IsA(class)
 if class==self._class or class=='Instance' then return true end
 if class=='GuiObject' then return ({Frame=true,CanvasGroup=true,ScrollingFrame=true,TextButton=true,TextBox=true,TextLabel=true,ImageLabel=true})[self._class] or false end
 if class=='BasePart' then return self._class=='Part' or self._class=='MeshPart' end
 if class=='PostEffect' then return ({ColorCorrectionEffect=true,BloomEffect=true,BlurEffect=true,DepthOfFieldEffect=true,SunRaysEffect=true})[self._class] or false end
 return false
end
function methods:IsDescendantOf(root) local p=self.Parent while p do if p==root then return true end p=p.Parent end return false end
function methods:GetPropertyChangedSignal(name) self._signals=self._signals or {} self._signals[name]=self._signals[name] or signal() return self._signals[name] end
function methods:GetAttribute(name) return nil end
function methods:Destroy() if self._props.Destroying then self._props.Destroying:Fire() end for _,c in ipairs(self:GetChildren()) do c:Destroy() end self.Parent=nil end
function methods:IsFocused() return false end
function methods:ReleaseFocus() end
local services={}
game={GetService=function(self,name) return services[name] end}
for _,name in ipairs({'Players','UserInputService','RunService','TweenService','Workspace','Lighting','SoundService'}) do services[name]=Instance.new(name) end
local ws=services.Workspace
ws.Name='Workspace'
workspace=ws
ws.CurrentCamera=Instance.new('Camera') ws.CurrentCamera.Parent=ws ws.CurrentCamera.FieldOfView=70 ws.CurrentCamera.ViewportSize=Vector2.new(1280,720)
ws.Terrain=Instance.new('Terrain') ws.Terrain.Parent=ws
ws.Terrain.WaterColor=Color3.fromRGB(30,100,150) ws.Terrain.WaterWaveSize=0.15 ws.Terrain.WaterWaveSpeed=10 ws.Terrain.WaterTransparency=0.4 ws.Terrain.WaterReflectance=0.5
local p=Instance.new('Player') services.Players.LocalPlayer=p
p.Name='TestPlayer' p.DisplayName='Test' p.CameraMode=Enum.CameraMode.Classic p.CameraMinZoomDistance=0.5 p.CameraMaxZoomDistance=128 p.DevCameraOcclusionMode=Enum.DevCameraOcclusionMode.Zoom
local pg=Instance.new('PlayerGui') pg.Name='PlayerGui' pg.Parent=p
services.Players.GetPlayers=function() return {p} end
local uis=services.UserInputService uis.MouseBehavior=Enum.MouseBehavior.LockCenter uis.MouseIconEnabled=true
uis.GetFocusedTextBox=function() return nil end
uis.GetMouseLocation=function() return Vector2.new(640,360) end
uis.GetMouseDelta=function() return Vector2.new() end
services.RunService.BindToRenderStep=function(self,name,priority,callback) self._render=self._render or {} self._render[name]=callback end
services.RunService.UnbindFromRenderStep=function(self,name) if self._render then self._render[name]=nil end end
services.TweenService.Create=function(self,obj,info,props)
 local tween={Completed=signal()}
 function tween:Cancel() end
 function tween:Play() for k,v in pairs(props) do obj[k]=v end end
 return tween
end
services.Lighting.ClockTime=12 services.Lighting.FogStart=0 services.Lighting.FogEnd=1000 services.Lighting.Brightness=2 services.Lighting.ExposureCompensation=0
TASKS={}
task={delay=function(_,f) table.insert(TASKS,f) end,spawn=function(f) f() end,defer=function(f) f() end,wait=function() end}
TEST_SERVICES=services
'''
lua.execute(stub)

lua.execute("\nloadstring=load\nlocal library\nTEST_OPTIONS={} TEST_ACTIONS={} TEST_TABS={} TEST_LABELS={} TEST_ORDER={} TEST_GROUPS={}\nfunction TEST_NEW_LIBRARY()\n local lib={Scheme={},Options={},Toggled=false,Unloaded=false}\n lib.ScreenGui=Instance.new('ScreenGui') lib.ScreenGui.Parent=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui')\n function lib:GiveSignal(signal) self.TestSignals=self.TestSignals or {} table.insert(self.TestSignals,signal) return signal end\n function lib:Notify(text) if text==\"Preview PNG could not load. Details are in the executor console.\" then TEST_IMAGE_NOTICES=TEST_IMAGE_NOTICES or {} table.insert(TEST_IMAGE_NOTICES,text) else table.insert(TEST_NOTICES,text) end end\n local function option(key,info,kind)\n  local o={Value=info.Default,Type=kind,Info=info,Values=info.Values}\n  if kind=='Dropdown' then o.Value=info.Values[info.Default] end\n  function o:SetValue(v) self.Value=v if info.Callback then info.Callback(v) end end\n  function o:SetValueRGB(v) self:SetValue(v) end\n  function o:SetValues(values) self.Values=values self.Info.Values=values end\n  TEST_OPTIONS[key]=o lib.Options[key]=o\n  return o\n end\n local function group()\n  local g={Type='Groupbox',BoxHolder=Instance.new('Frame')} g.BoxHolder.Parent=lib.ScreenGui g.Container=g.BoxHolder\n  function g:AddToggle(key,info) return option(key,info,'Toggle') end\n  function g:AddSlider(key,info) return option(key,info,'Slider') end\n  function g:AddInput(key,info) return option(key,info,'Input') end\n  function g:AddDropdown(key,info) return option(key,info,'Dropdown') end\n  function g:AddLabel(info)\n   local value=type(info)=='table' and info.Text or info\n   local label=Instance.new('TextLabel') label.Text=value label.Parent=g.BoxHolder\n   local l={Text=value,TextLabel=label}\n   function l:SetText(text) self.Text=text self.TextLabel.Text=text end function l:SetVisible(value)self.Visible=value self.TextLabel.Visible=value end\n   function l:AddColorPicker(key,info) option(key,info,'ColorPicker') return self end\n   table.insert(TEST_LABELS,l) return l\n  end\n  function g:AddDivider(text) return g:AddLabel(text) end\n  function g:AddImage(key,info)\n   local image={Image=info.Image,Holder=Instance.new('Frame')} image.Holder.Parent=g.BoxHolder\n   function image:SetImage(url) self.Image=url end\n   TEST_AVATAR=image return image\n  end\n  function g:AddButton(info) TEST_ACTIONS[info.Text]=info.Func return info end\n  return g\n end\n function lib:AddFeatureSettings(owner,info) local g=group() g.Type='FeatureSettings' g.Docked=info and info.Docked or false g.Owner=owner function g:AddPage(name)local p=group()p.Type='FeaturePage'p.PageName=name p.BoxHolder.Parent=g.BoxHolder return p end TEST_SETTINGS=TEST_SETTINGS or {} table.insert(TEST_SETTINGS,g) return g end\n function lib:CreateWindow(info)\n  assert(info.Title=='Prime Visuals') assert(info.Compact and (info.Font==Enum.Font.BuilderSans or info.Font==Enum.Font.Code)) lib.TestWindowInfo=info\n  local w={MainFrame=Instance.new('Frame'),IconHolder=Instance.new('ImageLabel')} w.IconHolder.ZIndex=1 w.IconHolder.Visible=true w.MainFrame.Name='Main' w.MainFrame.Parent=lib.ScreenGui w.MainFrame.ZIndex=1 w.MainFrame.Position=UDim2.fromOffset(100,100) w.MainFrame.Size=UDim2.fromOffset(720,600) w.MainFrame.AnchorPoint=Vector2.new() w.MainFrame.Rotation=0 w.MainFrame.Visible=false lib.TestMain=w.MainFrame local scale=Instance.new('UIScale') scale.Scale=1 scale.Parent=w.MainFrame\n  function w:AddTab(info)\n   TEST_TABS[info.Name]=info table.insert(TEST_ORDER,info.Name)\n   local tab={Container=Instance.new('Frame'),Sides={Instance.new('Frame'),Instance.new('Frame')}} tab.Container.Parent=lib.ScreenGui tab.Sides[1].Parent=tab.Container tab.Sides[2].Parent=tab.Container\n   function tab:AddGroupbox(info)if info.Side==2 then return self:AddRightGroupbox(info.Name)else return self:AddLeftGroupbox(info.Name)end end\n   function tab:AddLeftGroupbox(name,...) local g=group() g.BoxHolder.Parent=self.Sides[1] TEST_GROUPS[name]=g return g end\n   function tab:AddRightGroupbox(name,...) local g=group() g.BoxHolder.Parent=self.Sides[2] TEST_GROUPS[name]=g return g end\n   TEST_TAB_OBJECTS=TEST_TAB_OBJECTS or {} TEST_TAB_OBJECTS[info.Name]=tab\n   function tab:Show() lib.ActiveTab=tab TEST_ACTIVE_TAB=info.Name end\n   return tab\n  end\n  return w\n end\n function lib:CreateLoading(info) local loading={Info=info,Started=os.clock(),Destroyed=false} table.insert(TEST_INTROS,loading) self.ActiveLoading=loading function loading:SetMessage(v) self.Message=v end function loading:SetDescription(v) self.Description=v end function loading:SetCurrentStep(v) self.Step=v end function loading:Destroy() self.Destroyed=true self.Finished=os.clock() lib.ActiveLoading=nil if not lib.Unloaded then lib:Toggle(true) end end return loading end\n function lib:OnUnload(fn) self.onUnload=fn end\n function lib:Toggle(v) if v and self.ActiveLoading then return end self.Toggled=v if self.TestMain then self.TestMain.Visible=v end end\n function lib:Unload() self.Unloaded=true if self.ActiveLoading then self.ActiveLoading:Destroy() end if self.onUnload then self.onUnload() end self.ScreenGui:Destroy() end\n library=lib TEST_LIBRARY=lib\n return lib\nend\ngame.HttpGet=function() return 'return TEST_NEW_LIBRARY()' end\n")
lua.execute("TEST_SERVICES.Workspace.CurrentCamera.FieldOfView=70.4")
lua.execute("\nRaycastParams={new=function() return {} end}\nEnum.RenderPriority.Camera.Value=200\nlocal controller={locked=false,offset=Vector3.new(1,2,3)}\nfunction controller:GetIsMouseLocked() return self.locked end\nfunction controller:SetIsMouseLocked(v) self.locked=v end\nfunction controller:GetMouseLockOffset() return self.offset end\nfunction controller:SetMouseLockOffset(v) self.offset=v end\nTEST_CAMERA_CONTROLLER=controller\nlocal scripts=Instance.new('Folder') scripts.Name='PlayerScripts' scripts.Parent=TEST_SERVICES.Players.LocalPlayer\nlocal module=Instance.new('ModuleScript') module.Name='PlayerModule' module.Parent=scripts\nrequire=function() return {GetCameras=function() return {activeCameraController=controller} end} end\nlocal original=Instance.new('Sky') original.Name='OriginalSky' original.CelestialBodiesShown=true original.SunAngularSize=21 original.Parent=TEST_SERVICES.Lighting\nfunction original:Clone()\n local copy=Instance.new('Sky')\n for k,v in pairs(self._props) do if k~='Parent' and k~='_signals' then copy[k]=v end end\n return copy\nend\nTEST_ORIGINAL_SKY=original\nlocal cloud=Instance.new('Clouds') cloud.Enabled=true cloud.Parent=TEST_SERVICES.Workspace.Terrain TEST_ORIGINAL_CLOUD=cloud\nlocal disabled=Instance.new('Clouds') disabled.Enabled=false disabled.Parent=TEST_SERVICES.Workspace.Terrain TEST_DISABLED_CLOUD=disabled\n")
lua.globals().TEST_ICON_SOURCE=Path(REPO / "lib/PrimeIcon.lua").read_text(encoding="utf-8-sig")
lua.execute("local previous=game.HttpGet; game.HttpGet=function(self,url) if url:find('PrimeIcon.lua',1,true) then return TEST_ICON_SOURCE end return previous(self,url) end")
s=Path(REPO / "PrimeVisuals.lua").read_text(encoding="utf-8-sig")
lua.execute("\nlocal player=TEST_SERVICES.Players.LocalPlayer\nplayer.UserId=123456 player.Name='TestPlayer' player.DisplayName='Test Display'\nTEST_SERVICES.Players.MaxPlayers=20\nTEST_SERVICES.Stats={Network={ServerStatsItem={['Data Ping']={GetValue=function() return 42 end}}},GetTotalMemoryUsageMb=function() return 321 end}\n")
lua.execute("ColorSequenceKeypoint={new=function(t,c) return {Time=t,Value=c} end}")
lua.execute("Color3.fromHSV=function(h,s,v) return {R=h,G=s,B=v} end")
lua.execute("\nTEST_NOTICES={} TEST_INTROS={} TEST_CLOCK=0 TEST_WAITS=0\nos.clock=function() return TEST_CLOCK end\ntask.wait=function(dt)\n TEST_CLOCK=TEST_CLOCK+(dt or 0.016) TEST_WAITS=TEST_WAITS+1\n if TEST_CANCEL_WATER then TEST_CANCEL_WATER=false TEST_OPTIONS.waterEnabled:SetValue(false) end\nend\nlocal function region(low,high)\n local r={Min=low,Max=high,Size=high-low,CFrame={Position=(low+high)/2}}\n function r:ExpandToGrid(n)\n  return region(Vector3.new(math.floor(self.Min.X/n)*n,math.floor(self.Min.Y/n)*n,math.floor(self.Min.Z/n)*n),Vector3.new(math.ceil(self.Max.X/n)*n,math.ceil(self.Max.Y/n)*n,math.ceil(self.Max.Z/n)*n))\n end\n return r\nend\nRegion3={new=region}\nlocal terrain=TEST_SERVICES.Workspace.Terrain\nTEST_TERRAIN={} TEST_MAX_CELLS=0 TEST_WRITES=0\nlocal function key(x,y,z) return string.format('%d:%d:%d',x,y,z) end\nTEST_TERRAIN[key(0,30,0)]={Enum.Material.Water,1}\nTEST_TERRAIN[key(1,30,0)]={Enum.Material.Rock,1}\nfunction terrain:ReadVoxels(r,n)\n TEST_CLOCK=TEST_CLOCK+0.001\n local nx,ny,nz=r.Size.X/n,r.Size.Y/n,r.Size.Z/n\n TEST_MAX_CELLS=math.max(TEST_MAX_CELLS,nx*ny*nz)\n assert(nx*ny*nz<=32768,'unbounded voxel read')\n local materials,occupancy={},{}\n for x=1,nx do materials[x]={} occupancy[x]={}\n  for y=1,ny do materials[x][y]={} occupancy[x][y]={}\n   for z=1,nz do\n    local cell=TEST_TERRAIN[key(r.Min.X/n+x-1,r.Min.Y/n+y-1,r.Min.Z/n+z-1)]\n    materials[x][y][z]=cell and cell[1] or Enum.Material.Air occupancy[x][y][z]=cell and cell[2] or 0\n   end\n  end\n end\n return materials,occupancy\nend\nfunction terrain:WriteVoxels(r,n,materials,occupancy)\n TEST_CLOCK=TEST_CLOCK+0.002 TEST_WRITES=TEST_WRITES+1\n for x=1,#materials do for y=1,#materials[x] do for z=1,#materials[x][y] do\n  local k=key(r.Min.X/n+x-1,r.Min.Y/n+y-1,r.Min.Z/n+z-1)\n  if materials[x][y][z]==Enum.Material.Air and occupancy[x][y][z]==0 then TEST_TERRAIN[k]=nil else TEST_TERRAIN[k]={materials[x][y][z],occupancy[x][y][z]} end\n end end end\nend\nfunction terrain:FillRegion(r,n,material)\n for x=r.Min.X/n,r.Max.X/n-1 do for y=r.Min.Y/n,r.Max.Y/n-1 do for z=r.Min.Z/n,r.Max.Z/n-1 do\n  local k=key(x,y,z) if material==Enum.Material.Air then TEST_TERRAIN[k]=nil else TEST_TERRAIN[k]={material,1} end\n end end end\nend\nlocal parent=TEST_SERVICES.Workspace\nfor _,name in ipairs({'Map','AlwaysHereTweenedObjects','Ocean','Object','ObjectModel'}) do local o=Instance.new('Folder') o.Name=name o.Parent=parent parent=o end\nTEST_OCEAN=Instance.new('Part') TEST_OCEAN.Name='OceanPlane' TEST_OCEAN.Size=Vector3.new(2048,256,256) TEST_OCEAN.Position=Vector3.zero TEST_OCEAN.CFrame=CFrame.new() TEST_OCEAN.Transparency=0.3 TEST_OCEAN.CanCollide=true TEST_OCEAN.Parent=parent\nTEST_OVERLAP=Instance.new('Part') TEST_OVERLAP.Name='Overlap' TEST_OVERLAP.Size=Vector3.new(8,8,8) TEST_OVERLAP.Position=Vector3.new(0,120,0) TEST_OVERLAP.Transparency=0.6 TEST_OVERLAP.CanCollide=false TEST_OVERLAP.Parent=parent\nlocal character=Instance.new('Model') TEST_SERVICES.Players.LocalPlayer.Character=character\nlocal humanoid=Instance.new('Humanoid') humanoid.Parent=character humanoid.swim=true\nfunction humanoid:GetStateEnabled() return self.swim end\nfunction humanoid:SetStateEnabled(state,value) self.swim=value end\nfunction humanoid:GetState() return Enum.HumanoidStateType.Swimming end\nfunction humanoid:ChangeState(value) self.state=value end\nTEST_HUMANOID=humanoid\n")

lua.execute("""
Vector3int16={new=Vector3.new}
Region3int16={new=function(a,b) return {Min=a,Max=b} end}
local terrain=TEST_SERVICES.Workspace.Terrain
local function key(x,y,z) return string.format('%d:%d:%d',x,y,z) end
TEST_COPIES=0 TEST_FILLS=0 TEST_PASTES=0 TEST_DESTROYED_SNAPSHOTS=0
function terrain:CopyRegion(r)
 TEST_COPIES=TEST_COPIES+1
 local snapshot={Cells={},Min=r.Min,Max=r.Max}
 for x=r.Min.X,r.Max.X do for y=r.Min.Y,r.Max.Y do for z=r.Min.Z,r.Max.Z do
  local k=key(x,y,z) local c=TEST_TERRAIN[k] if c then snapshot.Cells[k]={c[1],c[2]} end
 end end end
 function snapshot:Destroy() TEST_DESTROYED_SNAPSHOTS=TEST_DESTROYED_SNAPSHOTS+1 end
 return snapshot
end
function terrain:PasteRegion(snapshot,corner,empty)
 assert(empty and corner.X==snapshot.Min.X and corner.Y==snapshot.Min.Y and corner.Z==snapshot.Min.Z)
 TEST_PASTES=TEST_PASTES+1
 for x=snapshot.Min.X,snapshot.Max.X do for y=snapshot.Min.Y,snapshot.Max.Y do for z=snapshot.Min.Z,snapshot.Max.Z do
  local k=key(x,y,z) TEST_TERRAIN[k]=snapshot.Cells[k]
 end end end
end
local fill=terrain.FillRegion
function terrain:FillRegion(r,n,m)
 assert(TEST_OCEAN.Transparency==1 and TEST_OVERLAP.Transparency==1,'ocean tiles not hidden up front')
 assert(r.Size.X<=128 and r.Size.Y<=128 and r.Size.Z<=128,'chunk too large')
 TEST_CLOCK=TEST_CLOCK+0.003 TEST_FILLS=TEST_FILLS+1
 fill(self,r,n,m)
end
function TEST_SERVICES.RunService.Heartbeat:Wait() task.wait() end
TEST_OCEAN.Size=Vector3.new(260,80,132) TEST_OCEAN.Position=Vector3.new(0,100,0)
""")

lua.globals().TEST_CONFIG_SOURCE=Path(REPO / "lib/ConfigStore.lua").read_text(encoding="utf-8-sig")
lua.execute("local previous=game.HttpGet; game.HttpGet=function(self,url) if url:find('ConfigStore.lua',1,true) then return TEST_CONFIG_SOURCE end return previous(self,url) end")

lua.execute("NumberSequenceKeypoint={new=function(t,v) return {Time=t,Value=v} end}")
lua.globals().TEST_EMBLEM_SOURCE=Path(REPO / "lib/AnimatedEmblem.lua").read_text(encoding="utf-8-sig")
lua.execute("local previous=game.HttpGet; game.HttpGet=function(self,url) if url:find('AnimatedEmblem.lua',1,true) then return TEST_EMBLEM_SOURCE end return previous(self,url) end")

# Execute the actual source-reviewed pack and preset data, not a replacement stub.
for module in ("VisualExpansion","VisualPresets","Navigation","AntiKick","LightingEditor"):
 lua.globals().TEST_VISUAL_SOURCE=Path(REPO / ("lib/"+module+".lua")).read_text(encoding="utf-8-sig")
 lua.execute("local source=TEST_VISUAL_SOURCE; local previous=game.HttpGet; game.HttpGet=function(self,url) if url:find('"+module+".lua',1,true) then return source end return previous(self,url) end")
