from support import Disk,session
D=Disk();lua,source,_,_=session(D,execute=False)
lua.execute(r"""
local speaker=Instance.new('Part')speaker.Name='Speaker'speaker.Parent=workspace
MUSIC=Instance.new('Sound')MUSIC.Name='Song'MUSIC.SoundId='native://music'MUSIC.Volume=.7 MUSIC.Parent=speaker
local map=workspace:FindFirstChild('Map')or Instance.new('Folder')map.Name='Map'map.Parent=workspace
local noises=Instance.new('Folder')noises.Name='MapNoises'noises.Parent=map
AMBIENT=Instance.new('Sound')AMBIENT.Name='Wind'AMBIENT.SoundId='native://wind'AMBIENT.Volume=.5 AMBIENT.Parent=noises
""")
lua.execute(source)
lua.execute(r"""
assert(MUSIC.SoundId=='native://music'and not TEST_OPTIONS.soundReplaceEnabled.Value)
assert(TEST_TAB_OBJECTS.Personalization and TEST_GROUPS['Toy collection'].NavigationCategory=='Personalization')
assert(TEST_GROUPS['Game interface'].NavigationCategory=='Personalization'and TEST_GROUPS['Mute sounds'].NavigationCategory=='Personalization')
TEST_OPTIONS.replaceAudioBoomboxes:SetValue('123456')
TEST_OPTIONS.soundReplaceEnabled:SetValue(true)
assert(MUSIC.SoundId=='rbxassetid://123456'and AMBIENT.SoundId=='native://wind'and MUSIC.Volume==.7)
MUSIC.SoundId='native://next-song'
assert(MUSIC.SoundId=='rbxassetid://123456','game rewrite lost override')
TEST_OPTIONS.muteBoomboxes:SetValue(true)assert(MUSIC.Volume==0)
TEST_OPTIONS.muteBoomboxes:SetValue(false)assert(MUSIC.Volume==.7 and MUSIC.SoundId=='rbxassetid://123456')
local late=Instance.new('Sound')late.Name='LaterSong'late.SoundId='native://late'late.Parent=MUSIC.Parent
workspace.DescendantAdded:Fire(late)assert(late.SoundId=='rbxassetid://123456')
TEST_OPTIONS.replaceAudioAmbience:SetValue('rbxassetid://654321')assert(AMBIENT.SoundId=='rbxassetid://654321')
TEST_OPTIONS.replaceAudioBoomboxes:SetValue('')assert(MUSIC.SoundId=='native://next-song'and late.SoundId=='native://late',tostring(MUSIC.SoundId)..' / '..tostring(late.SoundId))
TEST_OPTIONS.replaceSoundName:SetValue('Song')TEST_OPTIONS.replaceAudioNamed:SetValue('777777')
assert(MUSIC.SoundId=='rbxassetid://777777'and late.SoundId=='native://late')
TEST_OPTIONS.soundReplaceEnabled:SetValue(false)
assert(MUSIC.SoundId=='native://next-song'and AMBIENT.SoundId=='native://wind')
TEST_OPTIONS.soundReplaceEnabled:SetValue(true)TEST_DRAIN()
TEST_ACTIONS['Unload script']()
assert(MUSIC.SoundId=='native://next-song'and AMBIENT.SoundId=='native://wind')
""")
print('PASS Personalization routing, category/exact-name audio replacement, live native/new sounds, volume-mute coexistence, clear/latest-native restore and disable/unload')
lua,source,_,_=session(D,execute=False)
lua.execute("local f=workspace:FindFirstChild('Map')or Instance.new('Folder');f.Name='Map'f.Parent=workspace;local n=Instance.new('Folder')n.Name='MapNoises'n.Parent=f;S=Instance.new('Sound')S.Name='Wind'S.SoundId='original'S.Parent=n")
lua.execute(source)
lua.execute("assert(TEST_OPTIONS.soundReplaceEnabled.Value and S.SoundId=='rbxassetid://654321'); TEST_ACTIONS['Unload script'](); assert(S.SoundId=='original')")
print('PASS audio replacement configuration cold restore')
