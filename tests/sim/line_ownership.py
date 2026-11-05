from support import Disk,session
lua,source,_,_=session(Disk(),execute=False)
lua.execute(r"""
local pg=TEST_SERVICES.Players
local char=pg.LocalPlayer.Character
local root=Instance.new('Part')root.Name='HumanoidRootPart'root.Parent=char root.Position=Vector3.new(0,0,0)
local peer=Instance.new('Player')peer.Name='OtherPlayer'peer.UserId=321
local peerChar=Instance.new('Model')peerChar.Parent=workspace peer.Character=peerChar
local head=Instance.new('Part')head.Name='Head'head.Position=Vector3.new(40,0,0)head.Parent=peerChar
pg.GetPlayers=function()return {pg.LocalPlayer,peer}end
local function attach(parent)local a=Instance.new('Attachment')a.Parent=parent return a end
OWN_ORIGIN=attach(char)FOREIGN_ORIGIN=attach(peerChar)
local function beam(origin)
 local scope=Instance.new('Folder')scope.Name='GrabParts'scope.Parent=workspace
 local b=Instance.new('Beam')b.Texture='native'b.TextureSpeed=4 b.Color=ColorSequence.new(Color3.new(1,1,1))b.Attachment0=origin b.Attachment1=attach(root)b.Parent=scope
 return b
end
OWN=beam(OWN_ORIGIN)FOREIGN=beam(FOREIGN_ORIGIN)UNKNOWN=beam(nil)
local sourcePart=Instance.new('Part')sourcePart.Position=Vector3.new(40,0,0)sourcePart.Parent=workspace
SPATIAL=beam(attach(sourcePart))
""")
lua.execute(source)
lua.execute(r"""
TEST_OPTIONS.lineEnabled:SetValue(true)
TEST_OPTIONS.lineRainbow:SetValue(true)
assert(OWN.Texture~='native')
for i=1,30 do TEST_SERVICES.RunService.Heartbeat:Fire(.11)end
assert(FOREIGN.Texture=='native'and FOREIGN.TextureSpeed==4,'other player line modified')
assert(UNKNOWN.Texture=='native'and SPATIAL.Texture=='native','unowned/foreign BeamPart styled')
FOREIGN.Texture='other-real-texture'FOREIGN.TextureSpeed=9
TEST_SERVICES.RunService.Heartbeat:Fire(1.01)
assert(FOREIGN.Texture=='other-real-texture'and FOREIGN.TextureSpeed==9,'native foreign update overwritten')
OWN.Attachment0=FOREIGN_ORIGIN TEST_SERVICES.RunService.Heartbeat:Fire(.11)
assert(OWN.Texture=='native'and OWN.TextureSpeed==4,'reassigned beam kept custom appearance')
OWN.Attachment0=OWN_ORIGIN TEST_SERVICES.RunService.Heartbeat:Fire(1.01)
assert(OWN.Texture~='native','local ownership recovery failed')
TEST_OPTIONS.lineEnabled:SetValue(false)
assert(OWN.Texture=='native'and FOREIGN.Texture=='other-real-texture')
TEST_ACTIONS['Unload script']()
""")
print('PASS own-source-only texture/rainbow/speed; foreign line targeting self stays native; unknown/spatial foreign excluded; foreign updates preserved; reassignment restores and local recovery works')
