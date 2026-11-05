from support import Disk,session

D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(r'''
local map=workspace:FindFirstChild('Map')
GRASS=Instance.new('Part')GRASS.Name='GroundTile'GRASS.Material=Enum.Material.Grass GRASS.Color=Color3.new(.2,.5,.1)GRASS.Parent=map
ROCK=Instance.new('Part')ROCK.Material=Enum.Material.Rock ROCK.Color=Color3.new(.3,.3,.3)ROCK.Parent=map
TOY=Instance.new('Part')TOY.Material=Enum.Material.Grass TOY.Parent=workspace
OLD_COLOR=GRASS.Color
''')
lua.execute(source)
lua.execute(r'''
assert(not TEST_OPTIONS.mapAppearanceEnabled.Value)
TEST_OPTIONS.mapGrassMaterial:SetValue('Neon')TEST_OPTIONS.mapGrassTint:SetValue(true)
TEST_OPTIONS.mapGrassColor:SetValueRGB(Color3.new(.8,.1,.9))
assert(GRASS.Material==Enum.Material.Grass,'off-state edits applied')
TEST_OPTIONS.mapAppearanceEnabled:SetValue(true)
assert(GRASS.Material==Enum.Material.Neon and GRASS.Color.R==.8)
assert(ROCK.Material==Enum.Material.Rock and TOY.Material==Enum.Material.Grass,'category or map scope leaked')
TEST_OPTIONS.mapGrassTint:SetValue(false)
assert(GRASS.Color==OLD_COLOR and GRASS.Material==Enum.Material.Neon,'color clear removed material')
TEST_OPTIONS.mapGrassMaterial:SetValue('Original')
assert(GRASS.Material==Enum.Material.Grass)
TEST_OPTIONS.mapGrassMaterial:SetValue('ForceField')
assert(GRASS.Material==Enum.Material.ForceField,'classification changed after override')
LATE=Instance.new('Part')LATE.Material=Enum.Material.Grass LATE.Parent=GRASS.Parent
GRASS.Parent.DescendantAdded:Fire(LATE)assert(LATE.Material==Enum.Material.ForceField)
local map=GRASS.Parent local scans=0 local original=map.GetDescendants
map.GetDescendants=function(self)scans=scans+1 return original(self)end
for i=1,60 do TEST_SERVICES.RunService.Heartbeat:Fire(1)end
assert(scans==0,'steady state rescanned the map')
TEST_OPTIONS.mapAppearanceEnabled:SetValue(false)
assert(GRASS.Material==Enum.Material.Grass and LATE.Material==Enum.Material.Grass)
TEST_OPTIONS.mapAppearanceEnabled:SetValue(true)TEST_DRAIN()
TEST_ACTIONS['Unload script']()assert(GRASS.Material==Enum.Material.Grass)
''')
print('PASS map category isolation, map-only scope, disabled editing, independent property restore, cached classification, late parts and unload')
lua,source,_,_=session(D,execute=False)
lua.execute("G=Instance.new('Part')G.Material=Enum.Material.Grass G.Parent=workspace:FindFirstChild('Map')")
lua.execute(source)
lua.execute(r'''
assert(TEST_OPTIONS.mapAppearanceEnabled.Value and G.Material==Enum.Material.ForceField)
TEST_ACTIONS['Reset map surfaces']()assert(G.Material==Enum.Material.Grass)
TEST_OPTIONS.replacePresetExplosions:SetValue('Metallic blast')
TEST_OPTIONS.replacePresetAmbience:SetValue('Forest after rain')
TEST_OPTIONS.soundReplaceEnabled:SetValue(true)
local map=workspace:FindFirstChild('Map')
local noises=Instance.new('Folder')noises.Name='MapNoises'noises.Parent=map
SOUND=Instance.new('Sound')SOUND.Name='Wind'SOUND.SoundId='native:wind'SOUND.Parent=noises
workspace.DescendantAdded:Fire(SOUND)assert(SOUND.SoundId=='rbxassetid://9112762024')
TEST_OPTIONS.replaceAudioAmbience:SetValue('555555')
assert(SOUND.SoundId=='rbxassetid://9112762024','hidden custom ID replaced selected preset')
TEST_OPTIONS.replacePresetAmbience:SetValue('Custom')assert(SOUND.SoundId=='rbxassetid://555555')
TEST_OPTIONS.replacePresetAmbience:SetValue('Original')assert(SOUND.SoundId=='native:wind')
local own=Instance.new('Sound')own.Name='GrabSound'own.SoundId='own:native'own.Parent=TEST_SERVICES.Players.LocalPlayer.Character
local other=Instance.new('Sound')other.Name='GrabSound'other.SoundId='foreign:native'other.Parent=workspace
workspace.DescendantAdded:Fire(own)workspace.DescendantAdded:Fire(other)
TEST_OPTIONS.replaceSoundCategory:SetValue('Grab sound')TEST_OPTIONS.replacePresetGrab:SetValue('Air swoosh')
assert(own.SoundId=='rbxassetid://9126229716' and other.SoundId=='foreign:native')
TEST_DRAIN()
TEST_ACTIONS['Unload script']()
''')
print('PASS persisted map restore/reset, per-category presets, custom/Original switching and native audio restoration')
lua2,_,_,_=session(D)
lua2.execute("assert(TEST_OPTIONS.replacePresetGrab.Value=='Air swoosh' and TEST_OPTIONS.replacePresetExplosions.Value=='Metallic blast'); TEST_ACTIONS['Unload script']()")
print('PASS independent sound preset selections survive a cold restart')

# Isolated actual SoundOverrides factory: local grab transitions, previews and cleanup.
from pathlib import Path
factory=lua.execute(Path('lib/SoundOverrides.lua').read_text(encoding='utf-8'))
lua.globals().FACTORY=factory
lua.execute(r'''
local world=Instance.new('Folder')local run={Heartbeat=TEST_SERVICES.RunService.Heartbeat}
local localOrigin=Instance.new('Attachment')localOrigin.Parent=world
local remoteOrigin=Instance.new('Attachment')remoteOrigin.Parent=world
local scope=Instance.new('Folder')scope.Name='GrabParts'scope.Parent=world
local grab=Instance.new('Part')grab.Name='GrabPart'grab.Parent=scope
local target=Instance.new('Part')target.Parent=world
local a=Instance.new('Attachment')a.Parent=target
local weld=Instance.new('WeldConstraint')weld.Enabled=true weld.Active=true weld.Part0=grab weld.Part1=target weld.Parent=grab
local beam=Instance.new('Beam')beam.Attachment0=remoteOrigin beam.Attachment1=a beam.Parent=scope
local made={}
local api=FACTORY({Roots={world},Run=run,Categories={'Grab'},Patches={},Resolve=function(v)return 'rbxassetid://'..v end,
 Matches=function()return false end,Patch=function()end,Unpatch=function()end,SoundRoot=world,
 OwnBeam=function(b)return b.Attachment0==localOrigin end,
 Make=function(class,props,parent)local o=Instance.new(class)for k,v in pairs(props)do o[k]=v end o.Play=function(self)self.PlayCount=(self.PlayCount or 0)+1 end o.Parent=parent made[#made+1]=o return o end})
api:SetReplacement('Grab','9126229716')api:SetEnabled(true)
run.Heartbeat:Fire(.1)assert(#made==0,'foreign grab triggered sound')
beam.Attachment0=localOrigin run.Heartbeat:Fire(.1)assert(#made==1 and made[1].PlayCount==1)
for i=1,30 do run.Heartbeat:Fire(.1)end assert(#made==1,'held object repeated sound')
weld.Enabled=false run.Heartbeat:Fire(.1)weld.Enabled=true run.Heartbeat:Fire(.1)
assert(#made==2 and not made[1].Parent)
api:Preview('123456')assert(#made==3 and made[3].PlayCount==1)
api:Preview('234567')assert(not made[3].Parent and #made==4)
api:Destroy()for _,o in ipairs(made)do assert(not o.Parent,'owned audio survived unload')end
''')
print('PASS actual grab audio: foreign rejection, valid local weld onset, hold deduplication, release/regrab, preview replacement and unload')
