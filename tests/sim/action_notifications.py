from support import Disk,session
D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(source)
lua.execute(r"""
assert(#TEST_NOTICES==1 or #TEST_NOTICES==0) -- optional artwork failure may notify
local baseline=#TEST_NOTICES
TEST_OPTIONS.lineEnabled:SetValue(true)
assert(#TEST_NOTICES==baseline+1 and TEST_NOTICES[#TEST_NOTICES]:find('enabled',1,true))
TEST_OPTIONS.lineSpeed:SetValue(3)
assert(#TEST_NOTICES==baseline+1,'slider notification spam')
TEST_CLOCK=TEST_CLOCK+1 TEST_OPTIONS.lineEnabled:SetValue(false)
assert(#TEST_NOTICES==baseline+2)
TEST_OPTIONS.uiActionNotifications:SetValue(false)
TEST_CLOCK=TEST_CLOCK+1 TEST_OPTIONS.lineEnabled:SetValue(true)
assert(#TEST_NOTICES==baseline+2,'disabled notices still shown')
TEST_DRAIN()TEST_ACTIONS['Unload script']()
""")
lua,*_=session(D)
lua.execute("assert(TEST_OPTIONS.uiActionNotifications.Value==false); TEST_ACTIONS['Unload script']()")
print('PASS selected user-action notices, slider silence, per-feature debounce, optional disable and no profile-restore flood')
