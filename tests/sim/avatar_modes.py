from support import ROOT
setup=(ROOT/'tests/sim/visual_expansion.py').read_text(encoding='utf-8')
exec(setup[:setup.index('lua.execute(source)')])
lua.execute(r'''
local char=ME.Character
local function accessory(name,alpha)
 local a=Instance.new('Accessory')a.Name=name a.Parent=char
 local h=Instance.new('MeshPart')h.Name='Handle'h.Transparency=alpha h.LocalTransparencyModifier=1 h.Parent=a
 return h
end
HAIR=accessory('Hair',.2)
KEYBOARD=accessory('Keyboard',1)
OVERLAY=accessory('TorsoOverlay',1)
HELPER=Instance.new('Part')HELPER.Name='RagdollTouchedHitbox'HELPER.Transparency=1 HELPER.Parent=char
''')
lua.execute(source)
lua.execute(r'''
workspace.CurrentCamera.CFrame=CFrame.new(0,8,15)
TEST_OPTIONS.camThird:SetValue(true)
TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
assert(HAIR.Transparency==.2 and HAIR.LocalTransparencyModifier==0)
assert(KEYBOARD.Transparency==1 and OVERLAY.Transparency==1,'hidden accessory was reconstructed as visible')
assert(HELPER.Transparency==1)
for cycle=1,150 do
 TEST_OPTIONS.freeCameraEnabled:SetValue(true)TICK(2)
 assert(KEYBOARD.Transparency==1 and OVERLAY.Transparency==1,'Freecam exposed invisible accessory')
 assert(HAIR.Transparency==.2 and HAIR.LocalTransparencyModifier==0)
 TEST_OPTIONS.freeCameraEnabled:SetValue(false)TICK(2)
 TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
 assert(KEYBOARD.Transparency==1 and OVERLAY.Transparency==1)
end
TEST_ACTIONS['Unload script']()
assert(KEYBOARD.Transparency==1 and OVERLAY.Transparency==1)
''')
print('PASS v2.4.7 camera visibility baseline: invisible accessory keyboard/overlay preserved, visible hair preserved,150 Freecam switches and unload')
