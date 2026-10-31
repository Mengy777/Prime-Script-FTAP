from support import Disk,session
import json
D=Disk();lua,source,_,_=session(D)
lua.execute("TEST_OPTIONS.cameraFOV:SetValue(97); TEST_TAB_OBJECTS.Settings:Show(); TEST_DRAIN(); TEST_ACTIONS['Unload script']()")
for filename in ('autosave.json','autosave.backup.json'):
 path='PrimeVisuals/Configs/1234/'+filename
 doc=json.loads(D.files[path]);doc['payload']['ui']['tab']='Settings';D.files[path]=json.dumps(doc)
lua,source,_,_=session(D)
lua.execute("assert(TEST_ACTIVE_TAB=='Home' and TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==97)")
before=D.writes
lua.execute("TEST_TAB_OBJECTS.Graphics:Show(); TEST_TAB_OBJECTS.Settings:Show(); TEST_DRAIN(); for i=1,120 do TEST_SERVICES.RunService.RenderStepped:Fire(1/30) end; TEST_DRAIN()")
assert D.writes==before,'navigation wrote an unchanged profile'
lua.execute("TEST_OPTIONS.profileName:SetValue('Home test'); TEST_ACTIONS['Save to slot'](); TEST_ACTIONS['Load slot'](); assert(TEST_ACTIVE_TAB=='Home' and TEST_SERVICES.Workspace.CurrentCamera.FieldOfView==97); TEST_ACTIONS['Undo last config load'](); assert(TEST_ACTIVE_TAB=='Home')")
print('PASS legacy saved tab ignored on cold startup, config load and undo; settings/FOV preserved; tab navigation creates no config writes')

lua.execute("""
local art
for _,node in ipairs(TEST_LIBRARY.ScreenGui:GetDescendants()) do if node.Name=='VisualsPhoenix' then art=node break end end
assert(art,'Home artwork missing')
local parent=art
while parent do assert(parent.Visible~=false,'Home artwork is inside a hidden native column');parent=parent.Parent end
assert(TEST_GROUPS['Prime Visuals'].BoxHolder.Parent~=TEST_TAB_OBJECTS.Home.Sides[2])
""")
print('PASS Home artwork is parented into the visible custom column, not the hidden native side')

lua.execute("""
local hero=TEST_GROUPS['Prime Visuals'].BoxHolder
assert(hero.Parent.Name=='PrimeHomeScroll' and hero.LayoutOrder==0,'hero is not full-width first row')
local banner
for _,node in ipairs(TEST_LIBRARY.ScreenGui:GetDescendants())do if node.Name=='HomeHeroBanner' then banner=node end end
assert(banner and banner.ClipsDescendants,'hero banner missing')
assert(TEST_GROUPS['Profile'].BoxHolder.Parent.Name=='HomeProfileColumn')
assert(TEST_GROUPS['Session statistics'].BoxHolder.Parent.Name=='HomeSessionColumn')
TEST_ACTIONS['Camera & sky']() assert(TEST_ACTIVE_TAB=='View')
TEST_ACTIONS['Lighting & effects']() assert(TEST_ACTIVE_TAB=='Graphics')
TEST_ACTIONS['Settings & profiles']() assert(TEST_ACTIVE_TAB=='Settings')
""")
print('PASS full-width Home hero, profile/session composition and all three quick navigation callbacks')
