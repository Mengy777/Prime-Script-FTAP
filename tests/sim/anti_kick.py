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
local toy=toys:GetChildren()[1]toy:Destroy()
for i=1,20 do tick()end TEST_DRAIN()
for i=1,5 do tick()end assert(status=='Attached')
protector:SetEnabled(false)assert(status=='Off'and #toys:GetChildren()==0)
protector:SetEnabled(true)tick()protector:SetEnabled(false)TEST_DRAIN()
assert(#toys:GetChildren()==0,'queued spawn executed after disable')
protector:SetEnabled(true)build()
human.Health=0 tick()assert(status=='Waiting for character'and #toys:GetChildren()==0)
human.Health=100 build()
protector:Destroy()assert(#toys:GetChildren()==0)
local count=spawned for i=1,20 do tick()end assert(spawned==count)
CFrame.new,CFrame.Angles=oldNew,oldAngles
""")
print('PASS actual AntiKick module: self-only attachment confirmed, no duplicate spawns, recovery after toy destruction/death, disable-before-async-spawn and unload cleanup')
