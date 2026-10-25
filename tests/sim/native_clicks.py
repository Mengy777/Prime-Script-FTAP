from support import Disk,session,ROOT
import re
lua,_,_,_=session(Disk(),execute=False)
source=(ROOT/'lib/Obsidian.lua').read_text(encoding='utf-8-sig')
def lua_compat(code):
 code=re.sub(r':\s*(?:boolean|string|number|InputObject|GuiObject|Vector2)\??(?=[,)\s])','',code)
 code=re.sub(r'for ([_\w, ]+) in ([\w.]+) do',r'for \1 in pairs(\2) do',code)
 code=code.replace('Info.Visible = if typeof(Params.Visible) == "boolean" then Params.Visible else true',
                   'if typeof(Params.Visible) == "boolean" then Info.Visible=Params.Visible else Info.Visible=true end')
 return code
lua.execute(r"""
-- These stubs supply geometry/services, not replacements for native widget event handlers.
local mt=getmetatable(Instance.new('Frame'));local oldIndex=mt.__index
mt.__index=function(o,k)
 if k=='AbsoluteSize'then
  if o._class=='ScreenGui'then return Vector2.new(1280,720)end
  local s=o._props.Size or UDim2.new()local parent=o._props.Parent
  local ps=parent and parent.AbsoluteSize or Vector2.new(1280,720)
  return Vector2.new(s.X.Scale*ps.X+s.X.Offset,s.Y.Scale*ps.Y+s.Y.Offset)
 elseif k=='AbsolutePosition'then
  local pos=o._props.Position or UDim2.new()local anchor=o._props.AnchorPoint or Vector2.new()
  local parent=o._props.Parent local pp=parent and parent.AbsolutePosition or Vector2.new()
  local ps=parent and parent.AbsoluteSize or Vector2.new(1280,720)local size=o.AbsoluteSize
  return Vector2.new(pp.X+pos.X.Scale*ps.X+pos.X.Offset-anchor.X*size.X,pp.Y+pos.Y.Scale*ps.Y+pos.Y.Offset-anchor.Y*size.Y)
 end
 return oldIndex(o,k)
end
function typeof(v)if type(v)=='table'and rawget(v,'_class')then return'Instance'end return type(v)end
Library={Unloaded=false,Toggled=true,ForceCheckbox=false,Registry={},Corners={},CornerRadius=6,DraggableElements={},Scales={},Signals={},Unloads={},DPIScale=1,
 Scheme={AccentColor=Color3.new(.5,.2,1),MainColor=Color3.new(.1,.1,.1),FontColor=Color3.new(1,1,1),OutlineColor=Color3.new(.2,.2,.2),DarkColor=Color3.new()}}
function Library:Validate(info,template)
 info=info or{}for k,v in pairs(template or{})do if info[k]==nil then info[k]=v end end return info
end
function Library:GetDarkerColor(v)return v end
function Library:SafeCallback(fn,...)if fn then return fn(...)end end
function Library:UpdateDependencyBoxes()end
function Library:UpdateAddons()end
function Library:GetCustomIcon()return nil end
function Library:ApplyLucideIcon()end
function Library:GiveSignal(con)table.insert(self.Signals,con)return con end
function Library:OnUnload(fn)table.insert(self.Unloads,fn)end
function Library:MakeDraggable()end
function Library:AddTooltip()return{Destroy=function(self)self.Destroyed=true end}end
Templates={Toggle={Default=false,Disabled=false,Visible=true},Input={Default='',Disabled=false,Visible=true,AllowEmpty=true,EmptyReset='',ClearTextOnBlur=true},
 Slider={Default=50,Min=0,Max=100,Rounding=0,Disabled=false,Visible=true,Compact=false,Prefix='',Suffix=''}}
Funcs={}BaseAddons={__index={}};BaseGroupbox={__index=Funcs};Toggles={};Options={};Buttons={};CheckIcon=nil
TweenService=TEST_SERVICES.TweenService RunService=TEST_SERVICES.RunService UserInputService=TEST_SERVICES.UserInputService
Mouse=Vector2.new(120,120)
UserInputService.GetMouseLocation=function()return Mouse end
ScreenGui=Instance.new('ScreenGui')Floats=Instance.new('Frame')Floats.Size=UDim2.fromScale(1,1)Floats.Parent=ScreenGui
function New(class,props)
 local o=Instance.new(class)o.ZIndex=1
 for k,v in pairs(props or{})do
  if type(v)=='string'and(k=='Color'or k=='BackgroundColor3'or k=='TextColor3'or k=='ImageColor3')then v=Library.Scheme[v]or Color3.new()end
  o[k]=v
 end
 if class=='UIListLayout'then o.AbsoluteContentSize=Vector2.new(280,200)end
 Library.Registry[o]={}return o
end
function GROUP()
 local container=New('Frame',{Position=UDim2.fromOffset(100,100),Size=UDim2.fromOffset(500,500),Parent=ScreenGui})
 return setmetatable({Container=container,Elements={},DependencyBoxes={},Connections={},Resize=function()end},BaseGroupbox)
end
function Trim(s)return(s:gsub('^%s+',''):gsub('%s+$',''))end
function StopTween(t)if t then t:Cancel()end end
function Round(n,p)return math.floor(n*10^p+.5)/10^p end
function IsClickInput(input)return input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch end
DRAG_STEPS=0
function IsDragInput()if DRAG_STEPS>0 then DRAG_STEPS=DRAG_STEPS-1 return true end return false end
function TEST_SERVICES.RunService.RenderStepped:Wait()end
""")
# Actual hit-test contract is intentionally not replaced by a forgiving test double.
a=source.index('function Library:MouseIsOverFrame(');b=source.index('function Library:IsInsideFrame',a)
lua.execute(lua_compat(source[a:b]))
lua.execute(r"""
NATIVE_HIT=Library.MouseIsOverFrame
function Library:MouseIsOverFrame(frame,point)
 assert(point~=nil,'native widget omitted its pointer coordinates')
 return NATIVE_HIT(self,frame,point)
end
""")
for name,nextname in [('AddButton','AddCheckbox'),('AddCheckbox','AddToggle'),('AddToggle','AddInput'),('AddInput','AddSlider'),('AddSlider','AddDropdown')]:
 a=source.index('    function Funcs:'+name+'(');b=source.index('    function Funcs:'+nextname+'(',a)
 lua.execute(lua_compat(source[a:b]))
a=source.index('local ActiveFeatureSettings');b=source.index('function Library:SetFont',a)
lua.execute(source[a:b])
lua.execute(r"""
local function point(o,x)
 local p,s=o.AbsolutePosition,o.AbsoluteSize return Vector2.new(p.X+s.X*(x or .5),p.Y+s.Y*.5)
end
local callbackCount=0
for _,variant in ipairs({'Switch','Checkbox'})do
 local g=GROUP()
 local toggle=variant=='Switch'and g:AddToggle('native_'..variant,{Text='Native '..variant,Callback=function()callbackCount=callbackCount+1 end})
  or g:AddCheckbox('native_'..variant,{Text='Native '..variant,Callback=function()callbackCount=callbackCount+1 end})
 local panel=Library:AddFeatureSettings(toggle,{Docked=true,Window=g.Container})
 assert(table.find(Library.DraggableElements,panel.Holder),'docked inspector missing from native popup surfaces')
 Mouse=point(toggle.Holder,.2)
 toggle.Holder.MouseButton1Click:Fire()
 assert(toggle.Value,'native row click failed for '..variant)
 Mouse=point(toggle.SettingsButton)
 toggle.Holder.MouseButton1Click:Fire()
 assert(toggle.Value,'gear bubbling changed the feature state')
 toggle.SettingsButton.MouseButton1Click:Fire()assert(panel.Holder.Visible)
 Mouse=point(toggle.Holder,.95)
 toggle.Holder.MouseButton1Click:Fire()
 assert(not toggle.Value,'native switch click failed for '..variant)
 toggle:SetDisabled(true)
 toggle.Holder.MouseButton1Click:Fire()assert(not toggle.Value)
 panel:Destroy()assert(#Library.DraggableElements==0,'inspector surface leaked')toggle:Destroy()
end
assert(callbackCount==4,'unexpected or duplicated callbacks')
""")
print('PASS actual Switch/Checkbox MouseButton1Click + settings gear + switch area + disabled guard; callbacks fire exactly once')
lua.execute(r"""
local g=GROUP()local calls=0
local button=g:AddButton({Text='Native action',Func=function()calls=calls+1 end})
button.Base.MouseButton1Click:Fire()assert(calls==1)
button:SetDisabled(true)button.Base.MouseButton1Click:Fire()assert(calls==1)
button:SetDisabled(false)button.Base.MouseButton1Click:Fire()assert(calls==2)
local input=g:AddInput('native_live',{Text='Live input',Finished=false,Callback=function(v)LIVE_VALUE=v end})
local box=input.Holder:FindFirstChildWhichIsA('TextBox',true)
box.Text='570559352'assert(LIVE_VALUE=='570559352','live input did not commit before action')
local asset=g:AddInput('native_asset',{Text='Asset',Finished=true,CommitOnBlur=true,Callback=function(v)ASSET_VALUE=v end})
local abox=asset.Holder:FindFirstChildWhichIsA('TextBox',true)
abox.Text='123456789'abox.FocusLost:Fire(false,{KeyCode=Enum.KeyCode.Unknown})
assert(ASSET_VALUE=='123456789','clicking an action discarded a finished field')
abox.Text='not committed'abox.FocusLost:Fire(false,{KeyCode=Enum.KeyCode.Escape})
assert(ASSET_VALUE=='123456789'and abox.Text=='123456789','Escape should cancel editing')
local slider=g:AddSlider('native_slider',{Text='Distance',Min=2,Max=80,Default=12,Rounding=0,AllowRightClickInput=true,Callback=function(v)SLIDER_VALUE=v end})
local bar=slider.Holder:FindFirstChildWhichIsA('TextButton',true)
Mouse=Vector2.new(bar.AbsolutePosition.X+bar.AbsoluteSize.X*.5,bar.AbsolutePosition.Y+4)
DRAG_STEPS=1 bar.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1})
assert(slider.Value==41 and SLIDER_VALUE==41,'native drag failed')
local numeric=slider.Holder:FindFirstChildWhichIsA('TextBox',true)
numeric.CaptureFocus=function(self)self.Focused:Fire()end
local oldSpawn=task.spawn task.spawn=function(fn,...)return fn(...)end
bar.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton2})assert(numeric.Visible)
numeric.Text='79'numeric.FocusLost:Fire(true)assert(slider.Value==79 and SLIDER_VALUE==79)
task.spawn=oldSpawn
button:Destroy()input:Destroy()asset:Destroy()slider:Destroy()
""")
print('PASS actual action-button clicks, disabled actions, live text, commit-on-blur/cancel and native slider drag')
