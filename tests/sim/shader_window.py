from support import Disk,session
lua,_,_,_=session(Disk())
lua.execute('''
local function find(name)
 for _,o in ipairs(ALL_INSTANCES) do if o.Name==name then return o end end
 error('missing '..name)
end
local screen=find('PV_WraithCatalog') local window=find('WraithWindow')
assert(screen.Enabled==false,'catalog opens at startup')
local originalTab=TEST_ACTIVE_TAB
TEST_LIBRARY:Toggle(true)
TEST_LIBRARY.ShowCustomCursor=true
TEST_ACTIONS['Open shader catalog']()
assert(screen.Enabled and window.GroupTransparency==0 and TEST_LIBRARY.Toggled)
assert(TEST_LIBRARY.ShowCustomCursor==false and TEST_SERVICES.UserInputService.MouseIconEnabled)
assert(TEST_ACTIVE_TAB==originalTab,'catalog changes main navigation')
find('CloseCatalog').Activated:Fire()
-- Reopening cancels a pending close: old delayed callbacks cannot hide it.
TEST_ACTIONS['Open shader catalog']() TEST_DRAIN()
assert(screen.Enabled,'old close callback hid reopened catalog')
TEST_LIBRARY:Toggle(false)
TEST_SERVICES.RunService.Heartbeat:Fire(.6)
assert(not screen.Enabled,'catalog outlived main menu input state')
assert(TEST_LIBRARY.ShowCustomCursor==true,'main custom cursor was not restored')
TEST_LIBRARY:Toggle(true) TEST_ACTIONS['Open shader catalog']()
find('EditShader').Activated:Fire()
assert(not screen.Enabled and TEST_OPTIONS.lightEnabled.Value,'edit did not return to native editor')
TEST_ACTIONS['Open shader catalog']()
local camera=workspace.CurrentCamera camera.ViewportSize=Vector2.new(400,300)
TEST_SERVICES.RunService.Heartbeat:Fire(.6)
assert(window:FindFirstChildOfClass('UIScale').Scale<1,'catalog does not fit small viewport')
find('CatalogBackdrop').Activated:Fire() TEST_DRAIN()
assert(not screen.Enabled)
TEST_ACTIONS['Open shader catalog']()
TEST_ACTIONS['Unload script']() TEST_DRAIN()
assert(not screen.Parent and not screen.Enabled)
find('CloseCatalog').Activated:Fire()
''')
print('PASS separate shader window: default closed, reopen race, main-menu ownership, native editor handoff, viewport fit and unload')
