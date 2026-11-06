from support import Disk,session
from pathlib import Path
D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(r'''
local char=TEST_SERVICES.Players.LocalPlayer.Character
local origin=Instance.new('Attachment')origin.Parent=char
local scope=Instance.new('Folder')scope.Name='GrabParts'scope.Parent=workspace
BEAM=Instance.new('Beam')BEAM.Texture='native'BEAM.TextureSpeed=1 BEAM.Width0=.4 BEAM.Width1=.7 BEAM.CurveSize0=0 BEAM.CurveSize1=0 BEAM.TextureLength=1 BEAM.Transparency=NumberSequence.new(0)BEAM.Segments=10 BEAM.FaceCamera=false BEAM.Attachment0=origin BEAM.Parent=scope
local speaker=Instance.new('Part')speaker.Name='Speaker'speaker.Parent=workspace
MUSIC=Instance.new('Sound')MUSIC.SoundId='native'speaker.SoundId='native'MUSIC.Volume=.7 MUSIC.PlaybackSpeed=1.2 MUSIC.Parent=speaker
GRASS=Instance.new('Part')GRASS.Material=Enum.Material.Grass GRASS.Color=Color3.new(.2,.5,.1)GRASS.Parent=workspace:FindFirstChild('Map')
''')
lua.execute(source)
lua.execute(r'''
TEST_OPTIONS.lineEnabled:SetValue(true)
assert(BEAM.Width0==.4 and BEAM.Width1==.7,'old line geometry changed at default')
TEST_OPTIONS.lineAdvanced:SetValue(true)TEST_OPTIONS.lineWidth:SetValue(2.3)TEST_OPTIONS.lineCurve:SetValue(5)
TEST_OPTIONS.lineTextureLength:SetValue(4)
assert(BEAM.Width0==2.3 and BEAM.Width1==2.3 and BEAM.CurveSize0==5 and BEAM.CurveSize1==-5 and BEAM.TextureLength==4)
TEST_OPTIONS.linePulse:SetValue(true)local before=BEAM.Transparency
TEST_CLOCK=TEST_CLOCK+.23 TEST_SERVICES.RunService.Heartbeat:Fire(.1)
assert(BEAM.Transparency~=before,'pulse did not update')
TEST_OPTIONS.lineAdvanced:SetValue(false)
assert(BEAM.Width0==.4 and BEAM.Width1==.7 and BEAM.Segments==10 and BEAM.FaceCamera==false,'advanced disable failed restore')
TEST_OPTIONS.lineAdvanced:SetValue(true)TEST_OPTIONS.lineEnabled:SetValue(false)
assert(BEAM.Width0==.4 and BEAM.Texture=='native')
TEST_OPTIONS.soundReplaceEnabled:SetValue(true)
TEST_OPTIONS.replaceGainBoomboxes:SetValue(1.5)TEST_OPTIONS.replaceSpeedBoomboxes:SetValue(.5)
assert(math.abs(MUSIC.Volume-1.05)<1e-8 and MUSIC.PlaybackSpeed==.6)
MUSIC.Volume=.4 assert(math.abs(MUSIC.Volume-.6)<1e-8,'native volume baseline was not updated')
TEST_OPTIONS.muteBoomboxes:SetValue(true)assert(MUSIC.Volume==0)
TEST_OPTIONS.replaceGainBoomboxes:SetValue(2)assert(MUSIC.Volume==0,'tuning defeated mute')
TEST_OPTIONS.muteBoomboxes:SetValue(false)assert(math.abs(MUSIC.Volume-.8)<1e-8,'unmute retained zero tuning')
TEST_OPTIONS.soundReplaceEnabled:SetValue(false)assert(MUSIC.Volume==.4 and MUSIC.PlaybackSpeed==1.2)
TEST_OPTIONS.mapPreset:SetValue('Cyber Violet')TEST_ACTIONS['Apply map palette']()
assert(TEST_OPTIONS.mapAppearanceEnabled.Value and GRASS.Material==Enum.Material.SmoothPlastic)
assert(math.abs(GRASS.Color.R-56/255)<1e-8 and TEST_OPTIONS.mapGrassTint.Value)
TEST_OPTIONS.mapGrassMaterial:SetValue('Glass')assert(GRASS.Material==Enum.Material.Glass,'preset cannot be edited')
TEST_OPTIONS.crossEnabled:SetValue(true)
for _,style in ipairs({'Precision dot','Halo','Tactical cross','Diamond sight','Target ring','Corner brackets'})do
 TEST_OPTIONS.crossStyle:SetValue(style)
 local gui=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeVisualsCrosshair')
 local image=gui:FindFirstChild('Crosshair')local reticle=image:FindFirstChild('PV_Reticle')
 assert(image.ImageTransparency==1 and reticle and #reticle:GetChildren()>0,style)
end
TEST_OPTIONS.crossStyle:SetValue('Custom image')
local image=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeVisualsCrosshair'):FindFirstChild('Crosshair')
assert(image.ImageTransparency==0 and not image:FindFirstChild('PV_Reticle').Visible)
TEST_DRAIN()TEST_ACTIONS['Unload script']()
assert(BEAM.Width0==.4 and MUSIC.Volume==.4 and GRASS.Material==Enum.Material.Grass)
''')
print('PASS actual line geometry/pulse/default/disable restore, audio tuning/native updates/mutes, editable map palette, six reticles/image fallback and unload')
lua2,_,_,_=session(D)
lua2.execute("assert(TEST_OPTIONS.mapPreset.Value=='Cyber Violet' and TEST_OPTIONS.mapGrassMaterial.Value=='Glass' and TEST_OPTIONS.replaceGainBoomboxes.Value==2 and TEST_OPTIONS.crossStyle.Value=='Custom image');TEST_ACTIONS['Unload script']()")
print('PASS all new controls persist across cold restart')

# The real particle loop should move emitters without rebuilding their curves.
lua,_,_,_=session(Disk())
lua.execute(r'''
TEST_SERVICES.Workspace.CurrentCamera.CFrame=CFrame.new()
TEST_OPTIONS.snowEnabled:SetValue(true)
local emitters={}local curveWrites=0
for _,o in ipairs(workspace:GetDescendants())do if o:IsA('ParticleEmitter')and o.Parent.Name:find('PV_SnowLayer',1,true)then
 emitters[#emitters+1]=o o:GetPropertyChangedSignal('Size'):Connect(function()curveWrites=curveWrites+1 end)
end end
assert(#emitters==3)
for i=1,60 do TEST_CLOCK=TEST_CLOCK+.5 TEST_SERVICES.RunService.Heartbeat:Fire(.5)end
assert(curveWrites==0,'snow curves rewritten in steady state')
TEST_OPTIONS.snowColor:SetValueRGB(Color3.new(.2,.4,.9))
assert(curveWrites==0,'color-only edit rebuilt snow curves')
TEST_OPTIONS.snowDensity:SetValue(300)assert(curveWrites==3)
emitters[1].Enabled=false TEST_CLOCK=TEST_CLOCK+.6 TEST_SERVICES.RunService.Heartbeat:Fire(.6)
assert(emitters[1].Enabled,'optimized loop failed to recover disabled emitter')
TEST_ACTIONS['Unload script']()
''')
print('PASS snowfall curve writes eliminated during idle/color-only edits; density and recovery still apply')

lua,_,_,_=session(Disk())
lua.globals().PALETTES=lua.execute(Path('lib/MapPresets.lua').read_text(encoding='utf-8'))
lua.execute(r'''
local lighting=TEST_SERVICES.Lighting local brightness=lighting.Brightness
for _,palette in ipairs(PALETTES)do
 TEST_OPTIONS.mapPreset:SetValue(palette[1])TEST_ACTIONS['Apply map palette']()
 assert(TEST_OPTIONS.mapGrassMaterial.Value==palette[2][3] and TEST_OPTIONS.mapOceanMaterial.Value==palette[2][7])
 assert(lighting.Brightness==brightness,'map palette altered shader/lighting settings')
end
TEST_OPTIONS.crossStyle:SetValue('Halo')TEST_OPTIONS.crossEnabled:SetValue(true)
local image=TEST_SERVICES.Players.LocalPlayer:FindFirstChild('PlayerGui'):FindFirstChild('PrimeVisualsCrosshair'):FindFirstChild('Crosshair')
local root=image:FindFirstChild('PV_Reticle')local count=#ALL_INSTANCES
for i=1,100 do TEST_OPTIONS.crossColor:SetValueRGB(Color3.new(i/100,.1,.7))end
assert(root==image:FindFirstChild('PV_Reticle')and #ALL_INSTANCES==count,'color updates recreated reticle geometry')
TEST_ACTIONS['Unload script']()
''')
print('PASS all eight map palettes preserve lighting; reticle tint changes reuse geometry')

# No own-beam/target polling without a configured grab replacement; previews are manual stop.
factory=lua.execute(Path('lib/SoundOverrides.lua').read_text(encoding='utf-8'))
lua.globals().AUDIO_FACTORY=factory
lua.execute(r'''
local world=Instance.new('Folder')local calls,made=0,{}
local scope=Instance.new('Folder')scope.Name='GrabParts'scope.Parent=world
local beam=Instance.new('Beam')beam.Attachment1={}beam.Parent=scope
local api=AUDIO_FACTORY({Roots={world},Run=TEST_SERVICES.RunService,Categories={'Grab'},Patches={},Resolve=function(v)return v end,
 Matches=function()return false end,Patch=function()end,Unpatch=function()end,SoundRoot=world,
 OwnBeam=function()calls=calls+1 return false end,
 Make=function(class,props,parent)local o=Instance.new(class)for k,v in pairs(props)do o[k]=v end o.Play=function()end o.Parent=parent made[#made+1]=o return o end})
api:SetEnabled(true)
for i=1,100 do TEST_SERVICES.RunService.Heartbeat:Fire(.1)end assert(calls==0)
api:SetReplacement('Grab','123')TEST_SERVICES.RunService.Heartbeat:Fire(.1)assert(calls==1)
api:SetReplacement('Grab','')for i=1,100 do TEST_SERVICES.RunService.Heartbeat:Fire(.1)end assert(calls==1)
api:Preview('456')TEST_DRAIN()assert(made[1].Parent,'preview was cut off by a fixed timer')
api:StopPreview()assert(not made[1].Parent)api:Destroy()
''')
print('PASS inactive grab replacement avoids target polling; preview remains until stop/unload')
