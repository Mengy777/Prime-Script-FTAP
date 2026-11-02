from support import Disk,session,ROOT
import json
D=Disk();lua,source,_,_=session(D)
lua.execute(r"""
for key,o in pairs(TEST_OPTIONS)do if key:sub(1,5)=='bind_'then assert(o.Value==(key=='bind_menu' and 'RightControl' or ''),'incorrect default bind')end end
local input=TEST_SERVICES.UserInputService
local function press(name)input.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode[name]},false)end
assert(TEST_LIBRARY.Toggled)press('RightControl')assert(not TEST_LIBRARY.Toggled)
press('RightControl')assert(TEST_LIBRARY.Toggled)
TEST_OPTIONS.bind_camThird:SetValue('K')
TEST_LIBRARY:Toggle(false)press('K')assert(TEST_OPTIONS.camThird.Value)
TEST_LIBRARY:Toggle(true)press('K')assert(TEST_OPTIONS.camThird.Value,'UI interaction triggered gameplay binding')
TEST_OPTIONS.bind_menu:SetValue('M')press('M')assert(not TEST_LIBRARY.Toggled)
TEST_OPTIONS.menuTheme:SetValue('Midnight')TEST_OPTIONS.menuCustomAccent:SetValue(true)
TEST_OPTIONS.menuAccent:SetValueRGB(Color3.new(.2,.5,.7))
TEST_OPTIONS.hudClock:SetValue(true)TEST_OPTIONS.hudEnabled:SetValue(false)
TEST_DRAIN()TEST_ACTIONS['Unload script']()
""")
lua,source,_,_=session(D)
lua.execute(r"""
assert(TEST_OPTIONS.bind_camThird.Value=='K'and TEST_OPTIONS.bind_menu.Value=='M')
assert(TEST_OPTIONS.menuTheme.Value=='Midnight' and TEST_OPTIONS.menuCustomAccent.Value)
assert(TEST_OPTIONS.menuAccent.Value.R==.2 and TEST_OPTIONS.hudClock.Value and not TEST_OPTIONS.hudEnabled.Value)
for _,tab in pairs(TEST_TAB_OBJECTS)do assert(not tab.Container:FindFirstChild('PV_SectionBar'))end
TEST_OPTIONS.bind_lightEnabled:SetValue('K')assert(TEST_OPTIONS.bind_lightEnabled.Value=='','duplicate binding accepted')
TEST_SERVICES.RunService.RenderStepped:Fire(1.1)
local root=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeStatus')
assert(root and root:FindFirstChild('Watermark'))
TEST_ACTIONS['Unload script']()assert(not root.Parent)
""")
print('PASS Major3 default RightControl menu / other binds empty, bindings execute/pause for UI, conflict rejection, theme/color/HUD cold restore and cleanup')
# Exercise capture against actual keybind module, including mouse and cancellation.
lua.globals().BIND_FACTORY=lua.execute((ROOT/'lib/Keybinds.lua').read_text(encoding='utf8'))
lua.execute(r"""
local input=TEST_SERVICES.UserInputService local assigned=nil local n=0
local b=BIND_FACTORY({Input=input,MenuOpen=function()return false end,Safe=function(fn)fn()end})
b:Register('test',function()n=n+1 end)
b:Capture('test',function(value)assigned=value b:Set('test',value)end)
input.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton3},false)
assert(assigned=='MouseButton3' and n==0)
input.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton3},false)assert(n==1)
b:Capture('test',function(value)assigned=value end)
input.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.Escape},false)
assert(assigned=='MouseButton3')b:Destroy()
input.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton3},false)assert(n==1)
""")
print('PASS actual key capture mouse3, no trigger during capture, Escape cancellation and disconnected router')

for kind in ('untouched','explicit_clear','occupied','rebound'):
 d=Disk();l,_,_,_=session(d);l.execute("TEST_OPTIONS.cameraFOV:SetValue(91); TEST_DRAIN(); TEST_ACTIONS['Unload script']()")
 for path in list(d.files):
  if path.endswith(('autosave.json','autosave.backup.json')):
   doc=json.loads(d.files[path]);p=doc['payload'];p['values']['bind_menu']='';p['applied'].pop('bind_menu',None)
   if kind=='explicit_clear':p['applied']['bind_menu']=True
   if kind=='occupied':p['values']['bind_camThird']='RightControl';p['applied']['bind_camThird']=True
   if kind=='rebound':p['values']['bind_menu']='M';p['applied']['bind_menu']=True
   d.files[path]=json.dumps(doc)
 l,_,_,_=session(d)
 expected='RightControl' if kind=='untouched' else 'M' if kind=='rebound' else ''
 assert l.globals().TEST_OPTIONS.bind_menu.Value==expected,kind
print('PASS menu default migration: untouched empty, explicit clear, occupied RightControl and custom rebind')
