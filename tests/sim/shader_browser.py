from support import Disk,session,ROOT
disk=Disk()
lua,_,_,_=session(disk)
lua.globals().CAT_SOURCE=(ROOT/'lib/ShaderCatalog.lua').read_text(encoding='utf8')
lua.execute('TEST_CATALOG=assert(loadstring(CAT_SOURCE))()')
lua.execute('''
local root
for _,o in ipairs(ALL_INSTANCES) do if o.Name=='PV_ShaderBrowser' then root=o end end
assert(root and root.Parent and root.Parent.Name=='CatalogContent')
TEST_LIBRARY:Toggle(true) TEST_TAB_OBJECTS.Shaders:Show()
assert(TEST_OPTIONS.visualPreset.Visible==false and TEST_OPTIONS.shaderCollection.Visible==false,'list controls still visible')
local cards=root:FindFirstChild('ShaderCards'):FindFirstChild('Cards')
local categories for _,o in ipairs(ALL_INSTANCES) do if o.Name=='Collections' then categories=o end end
local search=root:FindFirstChild('ShaderSearch')
local function visibleCards()
 local n=0 for _,o in ipairs(cards:GetChildren()) do if o:IsA('TextButton') and o.Visible then n=n+1 end end return n
end
local function card(title,source)
 for _,o in ipairs(cards:GetChildren()) do
  if o:IsA('TextButton') and o:GetAttribute('ShaderId')==source..' / '..title then return o end
 end
 error('Missing card '..title..' / '..source)
end
assert(visibleCards()==45)
local rain=card('Rain','Mercury')
rain.Activated:Fire()
assert(TEST_OPTIONS.visualPreset.Value=='Mercury / Rain' and TEST_OPTIONS.visualPresetEnabled.Value)
assert(rain:FindFirstChild('Selected').Visible)
categories:FindFirstChild('Collection_3').Activated:Fire()
assert(visibleCards()>0 and visibleCards()<45)
categories:FindFirstChild('Collection_1').Activated:Fire()
search.Text='night' assert(visibleCards()>=2)
search.Text='[]' assert(visibleCards()==0 and root:FindFirstChild('EmptyResults').Visible,'search treated as pattern')
categories:FindFirstChild('Collection_1').Activated:Fire()
search.Text='НОЧЬ' assert(visibleCards()>=1,'Cyrillic search: '..tostring(visibleCards())..' text='..search.Text)
card('Ночь','Eris').Activated:Fire()
assert(TEST_OPTIONS.visualPreset.Value=='Eris / Ночь')
search.Text='' assert(visibleCards()==45 and not root:FindFirstChild('EmptyResults').Visible)
local night=card('Ночь','Eris')
local sortRoot=categories.Parent:FindFirstChild('SortControls')
assert(sortRoot,'parameter sort missing')
sortRoot:FindFirstChild('Sort_Time').Activated:Fire()
local ordered={} for _,b in ipairs(cards:GetChildren()) do if b:IsA('TextButton') then ordered[#ordered+1]=b end end
table.sort(ordered,function(a,b)return a.LayoutOrder<b.LayoutOrder end)
local last=-1
for _,b in ipairs(ordered) do
 local id=b:GetAttribute('ShaderId') local data=TEST_CATALOG[id]
 if data and data.light.ClockTime then assert(data.light.ClockTime>=last,'time sort out of order') last=data.light.ClockTime end
end
sortRoot:FindFirstChild('SortDirection').Activated:Fire()
table.sort(ordered,function(a,b)return a.LayoutOrder<b.LayoutOrder end) last=100
for _,b in ipairs(ordered) do
 local data=TEST_CATALOG[b:GetAttribute('ShaderId')]
 if data and data.light.ClockTime then assert(data.light.ClockTime<=last,'descending sort out of order') last=data.light.ClockTime end
end
categories:FindFirstChild('Collection_3').Activated:Fire()
assert(not night.Visible,'daytime Eris preset classified from its name instead of parameters')
categories:FindFirstChild('Collection_1').Activated:Fire()

root:FindFirstChild('NextShader').Activated:Fire()
assert(TEST_OPTIONS.visualPreset.Value~='Eris / Ночь')
root:FindFirstChild('PreviousShader').Activated:Fire()
card('Ночь','Eris').Activated:Fire()
search.Text='nothing' root:FindFirstChild('ClearSearch').Activated:Fire()
assert(search.Text=='' and visibleCards()==45)
night.MouseEnter:Fire() night.MouseLeave:Fire()
root:FindFirstChild('ShaderPower').Activated:Fire()
assert(not TEST_OPTIONS.visualPresetEnabled.Value)
root:FindFirstChild('ShaderPower').Activated:Fire()
assert(TEST_OPTIONS.visualPresetEnabled.Value)
assert(categories:FindFirstChildOfClass('UIGridLayout'),'categories require horizontal scrolling')
TEST_LIBRARY:Toggle(true)
local accent=Color3.fromRGB(20,180,220) TEST_LIBRARY.Scheme.AccentColor=accent
TEST_SERVICES.RunService.Heartbeat:Fire(.6)
local grid=cards:FindFirstChildOfClass('UIGridLayout')
assert(grid.FillDirectionMaxCells==5 and grid.CellSize.X.Scale==0 and 5*grid.CellSize.X.Offset+24<=cards.AbsoluteSize.X-2,'not five shaders per row')
for _,scale in ipairs({.75,1,1.25,1.5,2}) do
 TEST_LIBRARY.DPIScale=scale
 for _,width in ipairs({300,413,499,503,640,900}) do
  cards.Size=UDim2.fromOffset(width,0)
  cards:GetPropertyChangedSignal('AbsoluteSize'):Fire()
  local available=width/scale
  assert(5*grid.CellSize.X.Offset+24+2<=available,'five columns overflow at DPI '..scale)
  assert(6*grid.CellSize.X.Offset+30>available,'cell calculation leaves excessive empty width')
 end
end
TEST_LIBRARY.DPIScale=1 cards.Size=UDim2.new(1,-7,0,0) cards:GetPropertyChangedSignal('AbsoluteSize'):Fire()
TEST_OPTIONS.uiLanguage:SetValue('Русский') TEST_SERVICES.RunService.Heartbeat:Fire(.6)
for _,o in ipairs(cards:GetChildren()) do if o:IsA('TextButton') then
 assert(not o:FindFirstChild('Title').Text:find('[A-Za-z]'),'untranslated Russian shader name: '..o:FindFirstChild('Title').Text)
end end
assert(card('Spring','Mercury'):FindFirstChild('Title').Text=='Весна')
assert(card('Ночь','Eris'):FindFirstChild('Title').Text=='Ночь')
assert(root:FindFirstChild('ShaderPower').Text=='Выключить')
TEST_OPTIONS.uiLanguage:SetValue('English') TEST_SERVICES.RunService.Heartbeat:Fire(.6)
for _,o in ipairs(cards:GetChildren()) do if o:IsA('TextButton') then
 assert(not o:FindFirstChild('Title').Text:find(string.char(208),1,true),'Russian shader name in English menu')
end end
assert(card('Ночь','Eris'):FindFirstChild('Title').Text=='Night')
assert(categories.Parent.ClassName=='Frame','left panel still scrolls')
assert(sortRoot.Position.Y.Offset+sortRoot.Size.Y.Offset<=394,'left panel is too tall')
assert(not night:FindFirstChild('Source') and not night:FindFirstChild('Palette'),'extra card details remain')
local page=root.Parent.Parent
for _,o in ipairs(page:GetDescendants()) do
 for _,property in ipairs({'BackgroundColor3','TextColor3','ScrollBarImageColor3','Color','PlaceholderColor3'}) do
  local value=o[property]
  if type(value)=='table' and value.R~=nil then assert(value.R==value.G and value.G==value.B,'colored catalog '..property) end
 end
 if o:IsA('UIStroke') then assert(o.ApplyStrokeMode==Enum.ApplyStrokeMode.Border,'text outline creates bold letters') end
 if o:IsA('TextLabel') or o:IsA('TextButton') or o:IsA('TextBox') then assert(o.Font~=Enum.Font.GothamBold and o.Font~=Enum.Font.GothamMedium,'bold font remains') end
end
TEST_OPTIONS.visualPresetEnabled:SetValue(false)
assert(root:FindFirstChild('ShaderSelection').Text:sub(1,3)=='○')
TEST_DRAIN()
TEST_ACTIONS['Unload script']()
assert(not root.Parent)
rain.Activated:Fire()
assert(TEST_OPTIONS.visualPreset.Value=='Eris / Ночь','unloaded card still receives clicks')
''')
lua,_,_,_=session(disk)
lua.execute("assert(TEST_OPTIONS.visualPreset.Value=='Eris / Ночь' and not TEST_OPTIONS.visualPresetEnabled.Value); TEST_ACTIONS['Unload script']()")
print('PASS 45 clickable shader cards, auto-apply, collection chips, EN/RU literal search, empty results, selection/theme sync, persistence and disconnected unload')
