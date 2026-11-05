from support import Disk,session,ROOT
lua,_,_,_=session(Disk(),execute=False)
factory=lua.execute((ROOT/'lib/AvatarVisibility.lua').read_text(encoding='utf-8'))
lua.globals().VISIBILITY_FACTORY=factory
lua.execute(r"""
local p=TEST_SERVICES.Players.LocalPlayer local char=p.Character
local head=Instance.new('Part')head.Name='Head'head.Transparency=0 head.Parent=char
local face=Instance.new('Decal')face.Name='Face'face.Transparency=1 face.Texture='classic'face.Parent=head
local accessory=Instance.new('Accessory')accessory.Name='Renamed Hair'accessory.Parent=char
local hair=Instance.new('MeshPart')hair.Name='Handle'hair.MeshId='https://www.roblox.com/asset/?id=123456'hair.Transparency=1 hair.LocalTransparencyModifier=1 hair.Parent=accessory
local attachment=Instance.new('Attachment')attachment.Name='HairAttachment'attachment.Parent=hair
local waist=Instance.new('Accessory')waist.Name='Keyboard'waist.Parent=char
local helper=Instance.new('MeshPart')helper.Name='Handle'helper.MeshId='rbxassetid://123456'helper.Transparency=1 helper.Parent=waist
local wa=Instance.new('Attachment')wa.Name='WaistFrontAttachment'wa.Parent=helper
local humanoid=char:FindFirstChildWhichIsA('Humanoid')humanoid.RigType=Enum.HumanoidRigType.R6
local fallbackCalls,models,destroyed=0,0,0
humanoid.GetAppliedDescription=function()local d=Instance.new('HumanoidDescription')d.Face=0 return d end
TEST_SERVICES.Players.GetHumanoidDescriptionFromUserIdAsync=function(_,id)
 assert(id==p.UserId)fallbackCalls=fallbackCalls+1
 local d=Instance.new('HumanoidDescription')d.Face=999 d.Full=true return d
end
TEST_SERVICES.Players.CreateHumanoidModelFromDescriptionAsync=function(_,description)
 models=models+1 local m=Instance.new('Model')m.Destroying:Connect(function()destroyed=destroyed+1 end)
 local h=Instance.new('Part')h.Name='Head'h.Parent=m
 local f=Instance.new('Decal')f.Name='face'f.Transparency=0 f.Texture=description.Full and 'custom-face'or'classic'f.Parent=h
 if description.Full then
  local a=Instance.new('Accessory')a.Name='Original Hair'a.Parent=m
  local handle=Instance.new('MeshPart')handle.Name='Handle'handle.MeshId='rbxassetid://123456'handle.Transparency=0 handle.Parent=a
  local att=Instance.new('Attachment')att.Name='HairAttachment'att.Parent=handle
 end return m
end
local patches={}local busy=false
local function patch(feature,o,k,v)
 patches[o]=patches[o]or{}local entry=patches[o][k]
 if not entry then entry={original=o[k],layers={}}patches[o][k]=entry end
 entry.layers[feature]={value=v}o[k]=v
end
local function unpatch(feature,target)
 for o,props in pairs(patches)do if not target or target==o then
  for k,entry in pairs(props)do if entry.layers[feature]then entry.layers[feature]=nil o[k]=entry.original end end
 end end
end
local mode='third'
local manager=VISIBILITY_FACTORY({Player=p,Players=TEST_SERVICES.Players,Patches=patches,Patch=patch,Unpatch=unpatch,Mode=function()return mode end,Near=function()return false end})
manager:Refresh()
assert(hair.Transparency==0 and hair.LocalTransparencyModifier==0,'cold hidden/renamed hair not recovered')
assert(face.Texture=='custom-face'and face.Transparency==0,'cold default face not recovered')
assert(helper.Transparency==1,'waist accessory exposed by mesh fallback')
for i=1,100 do manager:Refresh()end
assert(fallbackCalls==1 and models==2 and destroyed==2,'reference per-frame work/leaked temporary model')
manager:Destroy()
assert(hair.Transparency==1 and face.Texture=='classic','unload did not restore original state')
""")
print('PASS third-person active at construction: incomplete applied description to UserId fallback, renamed/URL-mesh hair match, face-case match, no waist exposure, two disposed models and no per-frame API calls')
