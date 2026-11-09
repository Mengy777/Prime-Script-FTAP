from support import Disk,session
lua,_,_,_=session(Disk())
lua.execute('''
local function find(name)
 for _,o in ipairs(ALL_INSTANCES) do if o.Name==name then return o end end
end
local page=find('PV_ShaderPage')
assert(page and page.Parent==TEST_TAB_OBJECTS.Shaders.Container)
assert(page.Size.X.Scale==1 and page.Size.Y.Scale==1,'catalog does not fill shader page')
for _,side in ipairs(TEST_TAB_OBJECTS.Shaders.Sides) do assert(side.Visible==false,'old lighting cards still visible') end
assert(not find('PV_WraithCatalog') and not TEST_ACTIONS['Open shader catalog'],'separate popup remains')
assert(TEST_TAB_OBJECTS.View.Sides[1].Visible~=false,'other tabs changed')
TEST_LIBRARY:Toggle(true) TEST_TAB_OBJECTS.Shaders:Show()
assert(TEST_LIBRARY.ActiveTab==TEST_TAB_OBJECTS.Shaders)
for _,o in ipairs(page:GetDescendants()) do
 if o:IsA('TextLabel') or o:IsA('TextButton') or o:IsA('TextBox') then
  assert(o.Font~=Enum.Font.BuilderSans and o.Font~=Enum.Font.BuilderSansBold,'old catalog font remains')
 end
end
TEST_TAB_OBJECTS.View:Show() TEST_TAB_OBJECTS.Shaders:Show()
for _,side in ipairs(TEST_TAB_OBJECTS.Shaders.Sides) do assert(side.Visible==false) end
TEST_ACTIONS['Unload script']()
assert(not page.Parent)
''')
print('PASS full-page catalog directly in Shaders, no popup/lighting cards, new font, stable tab navigation and cleanup')
