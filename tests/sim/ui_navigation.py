from support import Disk,session,ROOT
import json,re
D=Disk();lua,source,_,_=session(D)
lua.execute(r"""
function SECTION(category,name)
 local container=TEST_TAB_OBJECTS[category].Container
 return container:FindFirstChild('PV_SectionBar'):FindFirstChild('Section_'..name)
end
assert(TEST_LIBRARY.TestWindowInfo.Font==Enum.Font.BuilderSans)
assert(TEST_GROUPS.Camera.BoxHolder.Visible and not TEST_GROUPS['Custom skybox'].BoxHolder.Visible)
assert(TEST_GROUPS.Camera.NavigationCategory=='View' and TEST_GROUPS.Camera.NavigationPage=='Camera')
SECTION('View','Sky').MouseButton1Click:Fire()
assert(not TEST_GROUPS.Camera.BoxHolder.Visible and TEST_GROUPS['Custom skybox'].BoxHolder.Visible)
SECTION('View','Camera').MouseButton1Click:Fire()
SECTION('Graphics','Weather').MouseButton1Click:Fire()
assert(TEST_GROUPS.Particles.BoxHolder.Visible and TEST_GROUPS.Snowfall.BoxHolder.Visible and not TEST_GROUPS.Lighting.BoxHolder.Visible)
SECTION('ESP','Objects').MouseButton1Click:Fire()
assert(TEST_GROUPS['World markers'].BoxHolder.Visible and not TEST_GROUPS['Player highlight'].BoxHolder.Visible)
assert(TEST_OPTIONS.camThird.Info.Text=='Third-person camera' and TEST_OPTIONS.camThird.Info.Tooltip)
assert(TEST_OPTIONS.espPlayers.Info.Text=='Players')
""")
print('PASS actual navigation: short subpages, merged cards, page visibility, readable labels and explanations')
lua.execute('TEST_DRAIN()')
before=D.writes
lua.execute(r"""
for i=1,40 do SECTION('View','Sky').MouseButton1Click:Fire()SECTION('View','Camera').MouseButton1Click:Fire()end
TEST_DRAIN()
""")
assert D.writes==before,'presentation-only navigation saved/changed profile'
auto=json.loads(D.files['PrimeVisuals/Configs/1234/autosave.json'])
assert len(auto['payload']['values'])==339
lua.execute(r"""
local label
for _,item in ipairs(TEST_LABELS)do if item.Text=='Tint'then label=item break end end assert(label)
local rainbow=TEST_OPTIONS.lightTintRainbow
rainbow.Text=rainbow.Info.Text rainbow.Holder=Instance.new('TextButton')rainbow.TextLabel=Instance.new('TextLabel')
rainbow.Holder.Parent=label.TextLabel rainbow.TextLabel.Parent=rainbow.Holder
local previousParent=label.TextLabel.Parent
function label:Destroy()self.TextLabel:Destroy()end
TEST_OPTIONS.lightTint.SetValueRGB=function()error('injected swatch failure after inline layout')end
TEST_ACTIONS['Reset filters']()
assert(rainbow.Holder.Parent==previousParent,'failed swatch destroyed the independent rainbow setting')
rainbow:SetValue(true)assert(rainbow.Value)
rainbow:SetValue(false)
""")
print('PASS inline rainbow survives native swatch failure, fallback and Reset filters')
lua.execute("TEST_ACTIONS['Unload script']()")
print('PASS navigation creates no profile writes; 339 current settings retained (advanced lighting editor included)')
# Exercise the actual native feature-panel implementation rather than the main UI stub.
native=(ROOT/'lib/Obsidian.lua').read_text(encoding='utf-8-sig')
block=native[native.index('local ActiveFeatureSettings'):native.index('function Library:SetFont')]
lua.execute(r"""
Library={Toggled=true,Unloaded=false,DPIScale=1,Registry={},Scales={},DraggableElements={},Signals={},Unloads={},
 Scheme={AccentColor=Color3.new(.6,.3,1),FontColor=Color3.new(1,1,1),MainColor=Color3.new(.05,.05,.05)}}
ScreenGui=Instance.new('ScreenGui')
Floats=Instance.new('Frame')Floats.Size=UDim2.fromOffset(1600,1000)Floats.Parent=ScreenGui
RunService=TEST_SERVICES.RunService UserInputService=TEST_SERVICES.UserInputService
CURRENT_POINT=Vector2.new(500,250)
UserInputService.GetMouseLocation=function()return CURRENT_POINT end
function Library:GiveSignal(c)table.insert(self.Signals,c)return c end
function Library:OnUnload(f)table.insert(self.Unloads,f)end
function Library:MakeDraggable()end
function Library:GetCustomIcon()return {}end
function Library:ApplyLucideIcon()end
function Library:AddTooltip()return {Destroy=function(self)self.Destroyed=true end}end
function Library:MouseIsOverFrame(frame,point)
 point=point or CURRENT_POINT local p,s=frame.AbsolutePosition,frame.AbsoluteSize
 return point.X>=p.X and point.Y>=p.Y and point.X<=p.X+s.X and point.Y<=p.Y+s.Y
end
BaseGroupbox={}
function New(class,props)
 local o=Instance.new(class)
 for k,v in pairs(props)do
  if type(v)=='string'and(k=='Color'or k=='BackgroundColor3'or k=='TextColor3')then v=Library.Scheme[v]or Color3.new()end
  o[k]=v
 end
 if class=='UIListLayout'then o.AbsoluteContentSize=Vector2.new(280,200)end
 Library.Registry[o]={BackgroundColor3='MainColor'}return o
end
OWNER={Value=false,Text='Sample feature',Holder=Instance.new('TextButton'),TextLabel=Instance.new('TextLabel'),Display=function()end}
OWNER.Holder.Parent=ScreenGui OWNER.Holder.Size=UDim2.fromOffset(300,24)OWNER.TextLabel.Size=UDim2.new(1,-40,1,0)OWNER.TextLabel.Text='Sample feature'
WINDOW=Instance.new('Frame')WINDOW.Position=UDim2.fromOffset(200,100)WINDOW.Size=UDim2.fromOffset(720,600)WINDOW.Parent=ScreenGui
""")
lua.execute(block)
lua.execute(r"""
PANEL=Library:AddFeatureSettings(OWNER,{Docked=true,Window=WINDOW})
assert(OWNER.SettingsButton and not PANEL.Holder.Visible)
PANEL:Open()assert(not PANEL.Holder.Visible,'disabled effect settings opened')
OWNER.Value=true OWNER:Display()OWNER.SettingsButton.MouseButton1Click:Fire()
assert(PANEL.Holder.Visible and PANEL.Docked)
assert(PANEL.Holder.Position.X.Offset>=WINDOW.AbsolutePosition.X)
assert(PANEL.Holder.Position.X.Offset+PANEL.Holder.Size.X.Offset<=WINDOW.AbsolutePosition.X+WINDOW.AbsoluteSize.X)
local p=PANEL.Holder.AbsolutePosition
CURRENT_POINT=Vector2.new(p.X+20,p.Y+50)
UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1,Position=CURRENT_POINT})
assert(PANEL.Holder.Visible,'inside click closed the inspector')
local holder=Instance.new('Frame')holder.Parent=PANEL.Holder
local menu=Instance.new('Frame')menu.Position=UDim2.fromOffset(1100,300)menu.Size=UDim2.fromOffset(200,200)menu.Parent=Floats
CurrentMenu={Holder=holder,Menu=menu,Close=function(self)self.Menu.Visible=false end}
CURRENT_POINT=Vector2.new(1150,350)
UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1,Position=CURRENT_POINT})
assert(PANEL.Holder.Visible,'child dropdown outside panel incorrectly dismissed it')
CurrentMenu=nil
WINDOW.Position=UDim2.fromOffset(300,170)RunService.Heartbeat:Fire(.1)
assert(PANEL.Holder.Position.Y.Offset==224 and not PANEL.LastPosition,'docked following polluted saved float coordinates')
for _,dpi in ipairs({1,1.5,2})do
 Library.DPIScale=dpi WINDOW.Position=UDim2.fromOffset(20,20)WINDOW.Size=UDim2.fromOffset(560,360)
 RunService.Heartbeat:Fire(.1)
 assert(PANEL.Holder.Position.X.Offset>=20 and PANEL.Holder.Position.X.Offset+PANEL.Holder.Size.X.Offset*dpi<=580)
 assert(PANEL.Holder.Position.Y.Offset>=20 and PANEL.Holder.Position.Y.Offset+PANEL.Holder.Size.Y.Offset*dpi<=380)
end
Library.DPIScale=1 WINDOW.Position=UDim2.fromOffset(300,170)WINDOW.Size=UDim2.fromOffset(720,600)RunService.Heartbeat:Fire(.1)
local general=PANEL:AddPage('General')local appearance=PANEL:AddPage('Appearance')
assert(general.Container.Visible and not appearance.Container.Visible)
appearance:Show()assert(not general.Container.Visible and appearance.Container.Visible)
CURRENT_POINT=Vector2.new(20,20)
UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1,Position=CURRENT_POINT})assert(not PANEL.Holder.Visible)
PANEL:Open()OWNER.Holder.Visible=false RunService.Heartbeat:Fire(.1)assert(not PANEL.Holder.Visible)
OWNER.Holder.Visible=true PANEL:Open()
UserInputService.InputBegan:Fire({KeyCode=Enum.KeyCode.Escape})assert(not PANEL.Holder.Visible)
local label={TextLabel=Instance.new('TextLabel')}label.TextLabel.Parent=ScreenGui local toggle={Holder=Instance.new('TextButton'),TextLabel=Instance.new('TextLabel'),Text='Rainbow: Color'}
Library:CompactColorRainbow(label,toggle)
assert(toggle.Holder.Parent==label.TextLabel and toggle.TextLabel.Text=='Rainbow')
local count=0
for i=1,8 do table.insert(appearance.Elements,{Destroy=function()count=count+1 table.remove(appearance.Elements)end})end
PANEL:Destroy()assert(count==8 and PANEL.Destroyed and not OWNER.SettingsButton)
for _,con in ipairs(Library.Signals)do con:Disconnect()end
""")
print('PASS actual Obsidian docked inspector: gear, enabled-only access, bounds/following, inside/outside/dropdown clicks, Escape/hidden owner, parameter pages, inline rainbow and full cleanup')
case=native[native.index('local function SearchCasefold'):native.index('local function NormalizeSearch')]
case=case.replace('(Text: string): string','(Text)')
lua.execute(case+'\nassert(SearchCasefold("НЕБО Ёж") == "небо ёж")')
print('PASS actual Unicode casefold for Russian search labels')

factory=lua.execute((ROOT/'lib/Navigation.lua').read_text(encoding='utf-8'))
lua.globals().NAV_FACTORY=factory
lua.execute(r"""
local allGroups={}local tabs={}
for _,category in ipairs({'View','Graphics','Character','ESP','FTAP','Settings'})do
 local tab={Container=Instance.new('Frame'),Sides={Instance.new('ScrollingFrame'),Instance.new('ScrollingFrame')}}tabs[category]=tab
 function tab:AddGroupbox(info)
  local g={Name=info.Name,Visible=true,BoxHolder=Instance.new('Frame')}allGroups[#allGroups+1]=g return g
 end
end
local lib={Scheme={},Searching=false}
local calls=0
function lib:UpdateSearch(text)
 calls=calls+1 self.Searching=text~=''
 for _,g in ipairs(allGroups)do g.BoxHolder.Visible=text==''or g.Name:find(text,1,true)~=nil end
end
function lib:ClearSearch()self:UpdateSearch('')end
local originalSearch=lib.UpdateSearch
local nav=NAV_FACTORY({Library=lib,Tabs=tabs,Make=function(class,props,parent)
 local o=Instance.new(class)for k,v in pairs(props)do o[k]=v end o.Parent=parent return o
end,Listen=function(signal,fn)return signal:Connect(fn)end})
local camera=nav:Group('Camera','Camera',1,'camera')local sky=nav:Group('Sky','Skybox',1,'cloud')
assert(camera.BoxHolder.Visible and not sky.BoxHolder.Visible)
lib:UpdateSearch('skybox')assert(sky.BoxHolder.Visible and not camera.BoxHolder.Visible and calls==1)
lib:ClearSearch()assert(camera.BoxHolder.Visible and not sky.BoxHolder.Visible)
lib:UpdateSearch('no-such-feature')assert(nav.States.View.empty.Visible)
lib:ClearSearch()assert(not nav.States.View.empty.Visible)
lib:UpdateSearch('skybox')
nav.States.View.buttons.Sky.MouseButton1Click:Fire()
assert(not lib.Searching and sky.BoxHolder.Visible and not camera.BoxHolder.Visible)
nav:Destroy()assert(lib.UpdateSearch==originalSearch)
""")
print('PASS search reaches unselected subpages; clearing search restores selection; subsection clicks exit search and cleanup restores the original handler')
