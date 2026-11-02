from support import Disk,session
D=Disk();lua,source,_,_=session(D,execute=False)
# Expose the real UI constructor only in this test, not the production entrypoint.
source=source.replace('local purple=Color3.fromRGB(160,106,255)','TEST_LOCALIZED_MAKE=make\nlocal purple=Color3.fromRGB(160,106,255)',1)
lua.execute(source)
lua.execute(r'''
local function section(name)
 for _,node in ipairs(TEST_LIBRARY.ScreenGui:GetDescendants())do if node.Name=='Section_'..name then return node end end
 error('missing section '..name)
end
local tools=section('Tools')
assert(tools.Text=='Tools')
TEST_OPTIONS.uiLanguage:SetValue('Русский')
assert(tools.Text=='Инструменты')
local status=TEST_LOCALIZED_MAKE('TextLabel',{Text='Anti-Kick: Attached'},TEST_LIBRARY.ScreenGui)
assert(status.Text=='Защита от кика: Закреплено','late-created label not translated')
status.Text='Anti-Kick: Waiting for character'
assert(status.Text=='Защита от кика: Ожидание персонажа','dynamic status not translated')
local label=TEST_LOCALIZED_MAKE('TextLabel',{Text='Material'},TEST_LIBRARY.ScreenGui)
assert(label.Text=='Материал')
for i=1,10 do
 TEST_OPTIONS.uiLanguage:SetValue('English')
 assert(tools.Text=='Tools' and label.Text=='Material')
 assert(status.Text=='Anti-Kick: Waiting for character')
 TEST_OPTIONS.uiLanguage:SetValue('Русский')
 assert(tools.Text=='Инструменты' and label.Text=='Материал')
end
TEST_ACTIONS['Unload script']()
''')
print('PASS actual Tools label, late-created controls, dynamic protection statuses and ten RU/EN round-trips')
lua,_,_,_=session(D)
lua.execute(r'''
local found=0
for _,node in ipairs(TEST_LIBRARY.ScreenGui:GetDescendants())do
 if node.Name=='Section_Tools'then assert(node.Text=='Инструменты')found=found+1 end
end
assert(found==1,'saved Russian did not restore')
''')
print('PASS saved Russian restored on cold startup; stable settings keys retained')
