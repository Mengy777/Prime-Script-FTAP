from server_model import Server
from support import Disk
import json
server=Server();a=server.connect(101,'Alpha',Disk());b=server.connect(202,'Beta',Disk());server.advance(.5)
a.run("assert(#TEST_SERVICES.Players:GetPlayers()==2)")
b.run("assert(#TEST_SERVICES.Players:GetPlayers()==2)")
a.run("TEST_OPTIONS.lightBrightness:SetValue(4);TEST_OPTIONS.lightEnabled:SetValue(true);TEST_OPTIONS.lineEnabled:SetValue(true);TEST_OPTIONS.lineRainbow:SetValue(true);TEST_OPTIONS.bodyAppearance:SetValue(true);TEST_OPTIONS.bodyHeadAlpha:SetValue(.7)")
server.advance(1.2)
assert a.run('return TEST_SERVICES.Lighting.Brightness')==4
assert b.run('return TEST_SERVICES.Lighting.Brightness')==2
assert a.run("return workspace:FindFirstChild('GrabParts'):FindFirstChildOfClass('Beam').Texture")!='native'
assert b.run("return workspace:FindFirstChild('GrabParts'):FindFirstChildOfClass('Beam').Texture")=='native'
assert server.roster[101]['name']=='Alpha'
print('PASS two independent live-script clients: local lighting/body/line settings do not alter peer scene or authoritative roster')
a.run("TEST_OPTIONS.espPlayers:SetValue(true);TEST_OPTIONS.espAllPlayers:SetValue(false);TEST_OPTIONS.espSelectedPlayers:SetValue({Beta=true})")
server.schedule(202,"error('stale event from disconnected session')",1.0)
server.disconnect(202);server.advance(.6)
a.run("assert(#TEST_SERVICES.Players:GetPlayers()==1)")
b=server.connect(202,'Beta',b.disk);server.advance(.7)
a.run("assert(TEST_OPTIONS.espSelectedPlayers.Value.Beta,'returning selected player not restored')")
print('PASS delayed player leave/rejoin restores selected ESP target; queued old-session events are discarded')
for i in range(25):
 server.respawn(101);server.advance(.65)
 server.schedule(101,'SERVER_CLEAR_BEAM()',0)
 server.schedule(101,'SERVER_BEAM()',.12)
 server.advance(1.1)
 a.run("assert(workspace:FindFirstChild('GrabParts'):FindFirstChildOfClass('Beam').Texture~='native','line lost after delayed server replacement')")
print('PASS 25 delayed respawns plus streamed beam destruction/recreation; enabled line and lifecycle recover')
# Real mannequin and R6 ragdoll constructors, deterministic parts/contacts only.
a.run("TEST_OPTIONS.mannequinEnabled:SetValue(true);TEST_ACTIONS['Spawn mannequin']()")
a.run("local f=workspace:FindFirstChild('PV_LocalMannequins');assert(f and #f:GetChildren()==1,'mannequin spawn failed')")
a.run("TEST_OPTIONS.mannequinName:SetValue('Builderman');TEST_ACTIONS['Apply avatar to last']()")
a.run("local f=workspace:FindFirstChild('PV_LocalMannequins');assert(#f:GetChildren()==1 and f:GetChildren()[1].SourceUserId==777)")
b.run("assert(not workspace:FindFirstChild('PV_LocalMannequins'),'local mannequin leaked to peer')")
a.run("for i=1,12 do TEST_ACTIONS['Spawn mannequin']() end;assert(#workspace:FindFirstChild('PV_LocalMannequins'):GetChildren()==10)")
a.run("TEST_OPTIONS.mannequinName:SetValue('MissingUser');TEST_ACTIONS['Apply avatar to last']();assert(#workspace:FindFirstChild('PV_LocalMannequins'):GetChildren()==10)")
a.run(r"""
TEST_LIBRARY:Toggle(false)
local m=workspace:FindFirstChild('PV_LocalMannequins'):GetChildren()[1]
local part=m:FindFirstChild('Torso')
workspace.CurrentCamera.ScreenPointToRay=function(self)return {Origin=self.CFrame.Position,Direction=self.CFrame.LookVector}end
local oldRay=workspace.Raycast
workspace.Raycast=function()return {Instance=part,Position=part.Position}end
local ui=TEST_SERVICES.UserInputService
ui.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1},false)
assert(part:FindFirstChildOfClass('AlignPosition'),'local grab constraint missing')
local count=0 for _,o in ipairs(m:GetDescendants())do if o:IsA('BallSocketConstraint')and o.Enabled then count=count+1 end end
assert(count==5,'ragdoll joints not activated')
ui.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseWheel,Position=Vector3.new(0,0,1000)})
ui.InputBegan:Fire({KeyCode=Enum.KeyCode.R},false)TICK(.1)
ui.InputEnded:Fire({KeyCode=Enum.KeyCode.R})
ui.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton2},false)
assert(not part:FindFirstChildOfClass('AlignPosition'),'throw retained grab constraints')
assert(m:FindFirstChild('HumanoidRootPart').AssemblyLinearVelocity.Magnitude>0,'throw velocity missing')
ui.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1},false)
ui.WindowFocusReleased:Fire()
assert(not part:FindFirstChildOfClass('AlignPosition'),'focus loss retained grab constraints')
TEST_OPTIONS.mannequinPhysics:SetValue(false)
workspace.Raycast=oldRay
""")
a.run("TEST_OPTIONS.mannequinEnabled:SetValue(false);assert(not workspace:FindFirstChild('PV_LocalMannequins'))")
print('PASS actual mannequin/R6 ragdoll modules: spawn/avatar replacement/10-object limit/failure retention/disable; no physical solver or asset appearance assertion')
a.run("TEST_ACTIONS['Unload script']()")
b.run("TEST_ACTIONS['Unload script']()")
assert a.run('return TEST_SERVICES.Lighting.Brightness')==2
for c in [a,b]:
 c.run("assert(not workspace:FindFirstChild('PV_LocalMannequins'))")
 assert json.loads(c.disk.files[f'PrimeVisuals/Configs/{c.user}/autosave.json'])['payload']['ui']['tab']=='Home'
for c in [a,b]:
 warnings=[str(v) for v in c.lua.globals().AUDIT_WARNINGS.values()]
 assert all('Executor does not support local image assets' in w or 'User does not exist' in w for w in warnings),warnings
print('PASS both clients unload independently, restore baseline lighting and keep isolated per-user autosaves')
