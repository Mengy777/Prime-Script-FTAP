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
FACE=Instance.new('Decal')FACE.Name='CustomFace'FACE.Transparency=.1 FACE.Texture='custom://face'FACE.Parent=char:FindFirstChild('Head')
HIDDENFACE=Instance.new('Decal')HIDDENFACE.Name='UnusedFace'HIDDENFACE.Transparency=1 HIDDENFACE.Parent=char:FindFirstChild('Head')
HELPER=Instance.new('Part')HELPER.Name='RagdollTouchedHitbox'HELPER.Transparency=1 HELPER.Parent=char
''')
lua.execute(source)
lua.execute(r'''
workspace.CurrentCamera.CFrame=CFrame.new(0,8,15)
HAIR.Transparency=1 FACE.Transparency=1 -- Hidden after startup, before first camera enable.
TEST_OPTIONS.camThird:SetValue(true)
TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
assert(HAIR.Transparency==.2 and HAIR.LocalTransparencyModifier==0)
assert(KEYBOARD.Transparency==1 and OVERLAY.Transparency==1,'hidden accessory was reconstructed as visible')
assert(HELPER.Transparency==1)
assert(FACE.Transparency==.1 and HIDDENFACE.Transparency==1 and FACE.Texture=='custom://face')
for cycle=1,150 do
 TEST_OPTIONS.freeCameraEnabled:SetValue(true)TICK(2)
 assert(KEYBOARD.Transparency==1 and OVERLAY.Transparency==1,'Freecam exposed invisible accessory')
 assert(HAIR.Transparency==.2 and HAIR.LocalTransparencyModifier==0)
 -- Game grab/rotation listener runs AFTER our frame callback.
 HAIR.Transparency=1 FACE.Transparency=1
 assert(HAIR.Transparency==.2 and FACE.Transparency==.1,'ordinary alpha hide survived Freecam rotation')
 HAIR.LocalTransparencyModifier=1
 assert(HAIR.LocalTransparencyModifier==0,'late grab update hid own hair')
 local torso=ME.Character:FindFirstChild('Torso')
 if torso then torso.Transparency=1 assert(torso.Transparency==0,'ordinary alpha hid torso')torso.LocalTransparencyModifier=1 assert(torso.LocalTransparencyModifier==0,'late rotation update hid torso')end
 TEST_OPTIONS.freeCameraEnabled:SetValue(false)TICK(2)
 TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
 assert(KEYBOARD.Transparency==1 and OVERLAY.Transparency==1)
 assert(HAIR.Transparency==.2 and FACE.Transparency==.1,'third person failed after Freecam alpha repair')
end
TEST_OPTIONS.camThird:SetValue(false)
TEST_OPTIONS.freeCameraEnabled:SetValue(false)
HAIR.Transparency=.6 assert(HAIR.Transparency==.6,'disabled camera repaired alpha')
HAIR.LocalTransparencyModifier=.7 assert(HAIR.LocalTransparencyModifier==.7,'Freecam listener survived disable')
TEST_ACTIONS['Unload script']()
assert(KEYBOARD.Transparency==1 and OVERLAY.Transparency==1)
''')
print('PASS shared early avatar cache: hair/custom face hidden before enable,150 late ordinary/local alpha writes during Freecam, invisible accessories/decals preserved, mode handoff and disable cleanup')
