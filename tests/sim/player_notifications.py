from support import Disk,session
D=Disk();lua,_,_,_=session(D)
lua.execute(r"""
assert(TEST_OPTIONS.playerSessionNotifications.Value==false)
local p=Instance.new('Player')p.Name='ExampleUser'p.DisplayName='Example'
local n=#TEST_NOTICES
TEST_SERVICES.Players.PlayerAdded:Fire(p)TEST_SERVICES.Players.PlayerRemoving:Fire(p)
assert(#TEST_NOTICES==n)
TEST_OPTIONS.playerSessionNotifications:SetValue(true)
n=#TEST_NOTICES
TEST_SERVICES.Players.PlayerAdded:Fire(p)TEST_SERVICES.Players.PlayerRemoving:Fire(p)
assert(#TEST_NOTICES==n+2 and TEST_NOTICES[n+1]=='Example (@ExampleUser) joined the server' and TEST_NOTICES[n+2]=='Example (@ExampleUser) left the server')
TEST_OPTIONS.uiLanguage:SetValue('Русский')
TEST_SERVICES.Players.PlayerAdded:Fire(p)
assert(TEST_NOTICES[#TEST_NOTICES]:find('зашёл',1,true))
TEST_DRAIN() TEST_ACTIONS['Unload script']()
n=#TEST_NOTICES TEST_SERVICES.Players.PlayerAdded:Fire(p)assert(#TEST_NOTICES==n)
""")
lua,_,_,_=session(D)
lua.execute("assert(TEST_OPTIONS.playerSessionNotifications.Value); TEST_OPTIONS.playerSessionNotifications:SetValue(false); local n=#TEST_NOTICES; local p=Instance.new('Player');p.Name='Test';TEST_SERVICES.Players.PlayerAdded:Fire(p);assert(#TEST_NOTICES==n);TEST_ACTIONS['Unload script']()")
print('PASS join/leave notices default off, English/Russian names, persistence, disabled silence and unload cleanup')
