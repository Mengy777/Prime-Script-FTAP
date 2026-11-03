from support import ROOT
setup=(ROOT/'tests/sim/visual_expansion.py').read_text(encoding='utf-8')
exec(setup[:setup.index('lua.execute(source)')])
lua.execute(r'''
local char=ME.Character
local accessory=Instance.new('Accessory')accessory.Name='Hair' accessory.Parent=char
HAIR=Instance.new('MeshPart')HAIR.Name='Handle'HAIR.Transparency=.2 HAIR.LocalTransparencyModifier=0 HAIR.Parent=accessory
FACE=Instance.new('Decal')FACE.Name='face'FACE.Transparency=0 FACE.Texture='custom://face'FACE.Parent=char:FindFirstChild('Head')
TOOL=Instance.new('Tool')TOOL.Name='Keyboard'TOOL.Parent=char
KEYBOARD=Instance.new('Part')KEYBOARD.Name='Handle'KEYBOARD.Transparency=0 KEYBOARD.LocalTransparencyModifier=1 KEYBOARD.Parent=TOOL
OVERLAY=Instance.new('Part')OVERLAY.Name='TorsoHitbox'OVERLAY.Transparency=0 OVERLAY.LocalTransparencyModifier=1 OVERLAY.Parent=char
HELPER=Instance.new('Part')HELPER.Name='RagdollTouchedHitbox'HELPER.Transparency=1 HELPER.Parent=char
''')
lua.execute(source)
lua.execute(r'''
-- First-person game code has already hidden the avatar before enabling modes.
for _,part in ipairs(ME.Character:GetDescendants())do if part:IsA('BasePart')then part.Transparency=1 part.LocalTransparencyModifier=1 end end
FACE.Transparency=1
KEYBOARD.Transparency=0 OVERLAY.Transparency=0
workspace.CurrentCamera.CFrame=CFrame.new(0,8,15)
TEST_OPTIONS.camThird:SetValue(true)
TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
assert(HAIR.Transparency==.2 and HAIR.LocalTransparencyModifier==0,'third person lost hair baseline')
assert(FACE.Transparency==0 and FACE.Texture=='custom://face','face decal not restored')
assert(HELPER.Transparency==1,'helper exposed')
assert(KEYBOARD.LocalTransparencyModifier==1 and OVERLAY.LocalTransparencyModifier==1,'third person exposed game geometry')
TEST_OPTIONS.camThird:SetValue(false)
for cycle=1,150 do
 for _,part in ipairs(ME.Character:GetDescendants())do if part:IsA('BasePart')then part.Transparency=1 part.LocalTransparencyModifier=1 end end
 FACE.Transparency=1 KEYBOARD.Transparency=0 OVERLAY.Transparency=0
 TEST_OPTIONS.freeCameraEnabled:SetValue(true)TICK(2)
 assert(HAIR.Transparency==.2 and FACE.Transparency==0)
 assert(KEYBOARD.LocalTransparencyModifier==1 and OVERLAY.LocalTransparencyModifier==1,'freecam exposed game geometry')
 for _,part in ipairs(ME.Character:GetDescendants())do
  if part:IsA('BasePart')and part.Name~='HumanoidRootPart'and part~=HELPER and part~=KEYBOARD and part~=OVERLAY then
   part.Transparency=1 part.LocalTransparencyModifier=1
   assert(part.Transparency<1 and part.LocalTransparencyModifier==0,'late freecam hide survived')
  end
 end
 TEST_OPTIONS.freeCameraEnabled:SetValue(false)TICK(2)
end
TEST_OPTIONS.camThird:SetValue(true)TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
assert(HAIR.Transparency==.2 and FACE.Transparency==0)
TEST_ACTIONS['Unload script']()
''')
print('PASS early hair/face cache, third-person and 150 delayed Freecam switches, late hiding repair, helper protection and unload')
