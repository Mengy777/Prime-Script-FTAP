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
assert(hero.Parent.Name=='HomeProfileColumn' and hero.LayoutOrder==1)
assert(TEST_GROUPS['Profile'].BoxHolder.Parent.Name=='HomeProfileColumn')
assert(TEST_GROUPS['Session statistics'].BoxHolder.Parent.Name=='HomeSessionColumn')
for _,node in ipairs(TEST_LIBRARY.ScreenGui:GetDescendants())do
 assert(node.Name~='PrimeHomeScroll' and node.Name~='HomeHeroBanner','obsolete scrolling banner survived')
end
assert(not TEST_GROUPS['Quick access'] and not TEST_ACTIONS['Camera & sky'])
TEST_ACTIONS['Session details']()
TEST_ACTIONS['Session details']()
""")
print('PASS compact non-scrolling Home, profile/phoenix composition, removed shortcuts and session detail toggle')
