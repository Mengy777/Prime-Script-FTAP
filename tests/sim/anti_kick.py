from support import Disk,session,ROOT
lua,_,_,_=session(Disk(),execute=False)
lua.globals().PROTECTION_SOURCE=(ROOT/'lib/AntiKick.lua').read_text(encoding='utf-8')
lua.execute(r"""
local player=TEST_SERVICES.Players.LocalPlayer
local world=TEST_SERVICES.Workspace
local run=TEST_SERVICES.RunService
local storage=Instance.new('Folder')
local function make(class,name,parent)local p=Instance.new(class)p.Name=name p.Parent=parent return p end
local toys=make('Folder',player.Name..'SpawnedInToys',world)
local char=make('Model','TestCharacter',world)player.Character=char
local root=make('Part','HumanoidRootPart',char)
local cf=setmetatable({},{__add=function(self)return self end,__mul=function(self)return self end})root.CFrame=cf
local hitbox=make('Part','RagdollTouchedHitbox',root)
local human=make('Humanoid','Humanoid',char)human.Health=100
local oldNew,oldAngles=CFrame.new,CFrame.Angles CFrame.new=function()return cf end CFrame.Angles=function()return cf end
local menu=make('Folder','MenuToys',storage)
local grab=make('Folder','GrabEvents',storage)
local events=make('Folder','PlayerEvents',storage)
local spawn=make('RemoteFunction','SpawnToyRemoteFunction',menu)
local destroy=make('RemoteEvent','DestroyToy',menu)
local owner=make('RemoteEvent','SetNetworkOwner',grab)
local attach=make('RemoteEvent','StickyPartEvent',events)
local spawned,destroyed,attached=0,0,0
function spawn:InvokeServer(name,position,velocity)
 assert(name=='NinjaShuriken')spawned=spawned+1
 local model=make('Model',name,toys)
 local sticky=make('Part','StickyPart',model)sticky.CFrame=cf
 make('WeldConstraint','StickyWeld',sticky)
 local partOwner=make('StringValue','PartOwner',sticky)partOwner.Value=''
 toys.ChildAdded:Fire(model)
end
function owner:FireServer(part)part:FindFirstChild('PartOwner').Value=player.Name end
function attach:FireServer(part,target,offset)assert(target==hitbox)attached=attached+1 part:FindFirstChild('StickyWeld').Part1=target end
function destroy:FireServer(model)destroyed=destroyed+1 model:Destroy()end
local clock=0 os.clock=function()return clock end
local status
local protector=load(PROTECTION_SOURCE)()({Player=player,Workspace=world,Storage=storage,Run=run,Status=function(s)status=s end})
local function tick()clock=clock+.2 run.Heartbeat:Fire(.2)end
local function build()
 tick()TEST_DRAIN()
 for i=1,5 do tick()end
 assert(status=='Attached',tostring(status))
end
protector:SetEnabled(true)build()assert(spawned==1 and attached==1)
for i=1,100 do tick()end assert(spawned==1,'duplicate spawn while attached')
for i=1,10 do protector:SetEnabled(true)tick()assert(status=='Attached','reapplied setting overwrote active status')end
assert(spawned==1,'reapplied enabled setting respawned toy')
local toy=toys:GetChildren()[1]
local sticky=toy:FindFirstChild('StickyPart')
assert(sticky.LocalTransparencyModifier==1 and sticky:FindFirstChild('StickyWeld').Part1==hitbox)
local late=make('MeshPart','LateMesh',toy)late.Transparency=.25
local decal=make('Decal','LateDecal',late)decal.Transparency=0
tick()assert(late.LocalTransparencyModifier==1 and late.Transparency==.25 and decal.Transparency==1)
sticky.LocalTransparencyModifier=0 tick()assert(sticky.LocalTransparencyModifier==1)
assert(sticky:FindFirstChild('StickyWeld').Part1==hitbox,'hiding detached protection')
toy:Destroy()
for i=1,20 do tick()end TEST_DRAIN()
for i=1,5 do tick()end assert(status=='Attached')
protector:SetEnabled(false)assert(status=='Off'and #toys:GetChildren()==0)
protector:SetEnabled(true)tick()protector:SetEnabled(false)TEST_DRAIN()
assert(#toys:GetChildren()==0,'queued spawn executed after disable')
protector:SetEnabled(true)build()
human.Health=0 tick()assert(status=='Waiting for character'and #toys:GetChildren()==0)
human.Health=100 build()
-- Reattach existing owned protection without creating another toy.
local before=spawned
toys:GetChildren()[1]:FindFirstChild('StickyPart'):FindFirstChild('StickyWeld').Part1=nil
tick()tick()assert(status=='Attached' and spawned==before,'lost weld did not reattach existing toy')
-- Thirty full character replacements, including late/nested hitboxes.
for cycle=1,30 do
 human.Health=0 tick()
 char=make('Model','Respawn'..cycle,world)player.Character=char
 root=make('Part','HumanoidRootPart',char)root.CFrame=cf
 human=make('Humanoid','Humanoid',char)human.Health=100
 tick()assert(status=='Waiting for character hitbox')
 local container=cycle%2==0 and make('Folder','RagdollParts',char) or root
 hitbox=make('Part','RagdollTouchedHitbox',container)
 build()assert(#toys:GetChildren()==1,'respawn leaked or duplicated own toys')
end
-- A never-returning local InvokeServer coroutine must not hold busy forever.
protector:SetEnabled(false)
local originalSpawn,originalCancel,originalInvoke=task.spawn,task.cancel,spawn.InvokeServer
local hang=true
task.spawn=function(fn)local co=coroutine.create(fn)local ok,err=coroutine.resume(co)assert(ok,err)return co end
task.cancel=function(co)if coroutine.status(co)~='dead'then coroutine.close(co)end end
spawn.InvokeServer=function(self,...)if hang then coroutine.yield()else return originalInvoke(self,...)end end
protector:SetEnabled(true)tick()
for i=1,25 do tick()end
assert(status=='Waiting: toy did not appear','spawn timeout did not release stuck request')
hang=false
for i=1,25 do tick()end
assert(status=='Attached','timed-out spawn permanently held busy')
task.spawn,task.cancel,spawn.InvokeServer=originalSpawn,originalCancel,originalInvoke
-- The old InvokeServer completion must not touch the new generation's pending toy.
protector:SetEnabled(false)
local first=true
spawn.InvokeServer=function(self,...)
 originalInvoke(self,...)
 if first then
  first=false human.Health=0 tick()human.Health=100 tick()TEST_DRAIN()
 end
end
protector:SetEnabled(true)build()
assert(#toys:GetChildren()==1,'stale completion destroyed or duplicated current protection')
spawn.InvokeServer=originalInvoke
protector:Restart()build()assert(#toys:GetChildren()==1)
local scope=make('Folder','GrabParts',world)
local grabPart=make('Part','GrabPart',scope)
local holding=make('WeldConstraint','WeldConstraint',grabPart)holding.Part1=root
local before=spawned
protector:Restart()
for i=1,30 do tick()end
assert(spawned==before,'protection spawn interrupted held object')
scope:Destroy()
for i=1,9 do tick()end
build()assert(spawned==before+1)
local foreign=make('BoolValue','InPlot',player)foreign.Value=true
tick()foreign.Value=false tick()
before=spawned
for i=1,15 do tick()end
assert(spawned==before,'protection consumed immediate post-plot cooldown')
for i=1,8 do tick()end
build()assert(spawned==before+1)
protector:Destroy()assert(#toys:GetChildren()==0)
local count=spawned for i=1,20 do tick()end assert(spawned==count)
CFrame.new,CFrame.Angles=oldNew,oldAngles
""")
print('PASS actual AntiKick module: self-only attachment confirmed, no duplicate spawns, recovery after toy destruction/death, disable-before-async-spawn and unload cleanup')
