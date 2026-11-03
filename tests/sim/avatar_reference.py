from support import ROOT
setup=(ROOT/'tests/sim/visual_expansion.py').read_text(encoding='utf-8')
exec(setup[:setup.index('lua.execute(source)')])
lua.execute(r'''
local char=ME.Character
function ADD_ACCESSORY(parent,name,attachment,alpha)
 local a=Instance.new('Accessory')a.Name=name a.Parent=parent
 local h=Instance.new('MeshPart')h.Name='Handle'h.MeshId='mesh://'..name h.Transparency=alpha h.LocalTransparencyModifier=1 h.Parent=a
 local att=Instance.new('Attachment')att.Name=attachment att.Parent=h
 return h
end
HAIR=ADD_ACCESSORY(char,'RealHair','HairAttachment',1)
MASK=ADD_ACCESSORY(char,'FaceMask','FaceFrontAttachment',1)
KEYBOARD=ADD_ACCESSORY(char,'Keyboard','WaistFrontAttachment',1)
OVERLAY=ADD_ACCESSORY(char,'TorsoOverlay','BodyFrontAttachment',1)
FACE=Instance.new('Decal')FACE.Name='face'FACE.Transparency=1 FACE.Texture='classic://face'FACE.Parent=char:FindFirstChild('Head')
local human=char:FindFirstChildWhichIsA('Humanoid')human.RigType=Enum.HumanoidRigType.R6
REFERENCE_CALLS=0 DESTROYED_REFERENCES=0 DESTROYED_DESCRIPTIONS=0
human.GetAppliedDescription=function()
 local d=Instance.new('HumanoidDescription')
 d.Destroying:Connect(function()DESTROYED_DESCRIPTIONS=DESTROYED_DESCRIPTIONS+1 end)
 return d
end
TEST_SERVICES.Players.CreateHumanoidModelFromDescriptionAsync=function(_,description,rig)
 assert(rig==Enum.HumanoidRigType.R6)
 REFERENCE_CALLS=REFERENCE_CALLS+1
 local model=Instance.new('Model')
 model.Destroying:Connect(function()DESTROYED_REFERENCES=DESTROYED_REFERENCES+1 end)
 ADD_ACCESSORY(model,'RealHair','HairAttachment',.2)
 ADD_ACCESSORY(model,'FaceMask','FaceFrontAttachment',0)
 ADD_ACCESSORY(model,'Keyboard','WaistFrontAttachment',0)
 ADD_ACCESSORY(model,'TorsoOverlay','BodyFrontAttachment',0)
 local h=Instance.new('Part')h.Name='Head'h.Parent=model
 local f=Instance.new('Decal')f.Name='face'f.Transparency=0 f.Texture='custom://face'f.Parent=h
 return model
end
''')
lua.execute(source)
lua.execute(r'''
TEST_DRAIN()
assert(REFERENCE_CALLS==1 and DESTROYED_REFERENCES==1 and DESTROYED_DESCRIPTIONS==1,'reference lifecycle leaked '..tostring(REFERENCE_CALLS)..'/'..tostring(DESTROYED_REFERENCES)..'/'..tostring(DESTROYED_DESCRIPTIONS))
assert(HAIR.Transparency==1 and FACE.Texture=='classic://face','reference changed inactive game')
workspace.CurrentCamera.CFrame=CFrame.new(0,8,15)
TEST_OPTIONS.camThird:SetValue(true)
TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
assert(HAIR.Transparency==.2 and MASK.Transparency==0,'initially hidden genuine cosmetics not recovered')
assert(FACE.Transparency==0 and FACE.Texture=='custom://face','original face not restored')
assert(KEYBOARD.Transparency==1 and OVERLAY.Transparency==1,'body accessory was exposed by head reference')
for i=1,30 do
 TEST_OPTIONS.freeCameraEnabled:SetValue(true)TICK(.05)
 HAIR.Transparency=1 MASK.Transparency=1 FACE.Texture='classic://face'
 assert(HAIR.Transparency==.2 and MASK.Transparency==0 and FACE.Texture=='custom://face')
 TEST_OPTIONS.freeCameraEnabled:SetValue(false)
 TEST_SERVICES.RunService._render.PrimeVisualsThirdBody()
 assert(KEYBOARD.Transparency==1 and OVERLAY.Transparency==1)
end
assert(REFERENCE_CALLS==1,'reference rebuilt per frame')
TEST_ACTIONS['Unload script']()
assert(FACE.Texture=='classic://face'and HAIR.Transparency==1 and MASK.Transparency==1)
local previousCalls=REFERENCE_CALLS
-- Reference delivery after unload must only dispose its temporary result.
TEST_SERVICES.Players.CreateHumanoidModelFromDescriptionAsync=function()
 local model=Instance.new('Model')
 model.Destroying:Connect(function()DESTROYED_REFERENCES=DESTROYED_REFERENCES+1 end)
 TEST_ACTIONS['Unload script']()
 return model
end

''')
print('PASS avatar reference: initially hidden hair/face mask, original face texture, head-only filtering, one request/character, source model/description cleanup,30 mode switches and unload')

lua.execute("SAVED_SPAWN=task.spawn; PENDING_REFERENCE={}; task.spawn=function(fn) table.insert(PENDING_REFERENCE,fn)end")
lua.execute(source)
lua.execute(r'''
task.spawn=SAVED_SPAWN
for _,fn in ipairs(PENDING_REFERENCE)do fn()end
TEST_DRAIN()
assert(TEST_LIBRARY.Unloaded,'injected unload did not execute')
assert(DESTROYED_REFERENCES==2 and DESTROYED_DESCRIPTIONS==2,'stale reference result was not disposed')
assert(HAIR.Transparency==1 and KEYBOARD.Transparency==1)
''')
print('PASS reference completion after unload disposes model/description without modifying avatar')
