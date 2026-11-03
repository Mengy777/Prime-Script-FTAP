-- One visibility owner for both camera modes. Never invent visible accessory baselines.
return function(c)
 local api={} local character,records=nil,{} local added,removed,characterAdded,appearanceLoaded
 local busy,dead=false,false local lastMode,lastNear
 local generation,referenceState,referenceRetry,headReferences,faceReferences=0,nil,0,{},{}
 local body={Head=true,Torso=true,UpperTorso=true,LowerTorso=true,["Left Arm"]=true,["Right Arm"]=true,["Left Leg"]=true,["Right Leg"]=true,
 LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,RightUpperArm=true,RightLowerArm=true,RightHand=true,
 LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,RightUpperLeg=true,RightLowerLeg=true,RightFoot=true}
 local features={thirdBody=true,thirdNear=true,thirdAlpha=true,freeBody=true,freeAlpha=true,cameraFace=true}
 local function release()
  for name in pairs(features)do c.Unpatch(name)end
 end
 local function disconnect(data)
  for _,link in ipairs(data.links)do link:Disconnect()end
 end
 local function classify(o)
  if o:IsA("BasePart")then
   if body[o.Name]and o.Parent==character and character:FindFirstChild(o.Name)==o then return true,o.Name=="Head"end
   local parent=o.Parent
   if o.Name=="Handle"and parent and(parent:IsA("Accessory")or parent:IsA("Hat"))and parent:IsDescendantOf(character)then return false,true end
  elseif(o:IsA("Decal")or o:IsA("Texture"))and o.Parent and o.Parent==character:FindFirstChild("Head")then return false,true end
 end
 local function blocked(o,property)
  local entry=c.Patches[o]and c.Patches[o][property]
  if entry then for name in pairs(entry.layers)do if not features[name]then return true end end end
  return false
 end
 local headAttachments={HairAttachment=true,HatAttachment=true,FaceFrontAttachment=true,FaceCenterAttachment=true}
 local function meshKey(handle)
  local ok,value=pcall(function()return handle.MeshId end)
  if ok and type(value)=="string"and value~=""then return value end
  local mesh=handle:FindFirstChildWhichIsA("SpecialMesh")
  return mesh and tostring(mesh.MeshId)or ""
 end
 local function reference(o)
  if o:IsA("BasePart")and o.Name=="Handle"and o.Parent then return headReferences[o.Parent.Name.."|"..meshKey(o)]end
  if(o:IsA("Decal")or o:IsA("Texture"))and o.Parent==character:FindFirstChild("Head")then return faceReferences[o.ClassName.."|"..o.Name]end
 end
 local function requestReference()
  if referenceState=="pending"or referenceState=="ready"or os.clock()<referenceRetry or not character then return end
  local h=character:FindFirstChildWhichIsA("Humanoid")
  if not h or type(h.GetAppliedDescription)~="function"or not c.Players or type(c.Players.CreateHumanoidModelFromDescriptionAsync)~="function"then return end
  referenceState="pending"local token=generation local current=character
  task.spawn(function()
   local description,model local heads,faces={},{}
   local ok,message=pcall(function()
    description=h:GetAppliedDescription()
    if dead or token~=generation or c.Player.Character~=current then return end
    model=c.Players:CreateHumanoidModelFromDescriptionAsync(description,h.RigType)
    if dead or token~=generation or c.Player.Character~=current then return end
    for _,accessory in ipairs(model:GetChildren())do
     if accessory:IsA("Accessory")or accessory:IsA("Hat")then
      local handle=accessory:FindFirstChild("Handle")local isHead=false
      if handle then for _,child in ipairs(handle:GetChildren())do if child:IsA("Attachment")and headAttachments[child.Name]then isHead=true break end end end
      if isHead and handle.Transparency<1 then heads[accessory.Name.."|"..meshKey(handle)]={alpha=handle.Transparency}end
     end
    end
    local head=model:FindFirstChild("Head")
    if head then for _,o in ipairs(head:GetChildren())do
     if(o:IsA("Decal")or o:IsA("Texture"))and o.Transparency<1 then faces[o.ClassName.."|"..o.Name]={alpha=o.Transparency,texture=o.Texture}end
    end end
   end)
   if description then pcall(function()description:Destroy()end)end
   if model then pcall(function()model:Destroy()end)end
   if dead or token~=generation or c.Player.Character~=current then return end
   if ok then headReferences,faceReferences=heads,faces referenceState="ready"
   else referenceState=nil referenceRetry=os.clock()+15 warn("Prime Visuals / avatar reference: "..tostring(message))end
   api:Refresh()
  end)
 end
 local function track(o)
  if records[o]then return end
  local standard,head=classify(o)if standard==nil then return end
  local entry=c.Patches[o]and c.Patches[o].Transparency
  local alpha=entry and entry.original or o.Transparency
  local data={alpha=alpha<1 and alpha or standard and 0 or nil,head=head,links={}}
  records[o]=data
  data.links[#data.links+1]=o:GetPropertyChangedSignal("Transparency"):Connect(function()
   if busy or dead then return end
   -- A later visible state provides evidence; a hide never replaces the baseline.
   if not(c.Patches[o]and c.Patches[o].Transparency)and o.Transparency<1 then data.alpha=o.Transparency end
   api:Refresh()
  end)
  if o:IsA("Decal")or o:IsA("Texture")then data.links[#data.links+1]=o:GetPropertyChangedSignal("Texture"):Connect(function()
   if not busy and not dead then api:Refresh()end
  end)end
  if o:IsA("BasePart")then data.links[#data.links+1]=o:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
   if not busy and not dead then api:Refresh()end
  end)end
 end
 local function sync()
  if c.Player.Character==character then return end
  if added then added:Disconnect()end if removed then removed:Disconnect()end
  for _,data in pairs(records)do disconnect(data)end
  generation=generation+1 referenceState=nil referenceRetry=0 headReferences={}faceReferences={}
  records={}character=c.Player.Character lastMode=nil lastNear=nil release()
  if character then
   for _,o in ipairs(character:GetDescendants())do track(o)end
   added=character.DescendantAdded:Connect(function(o)track(o)api:Refresh()end)
   removed=character.DescendantRemoving:Connect(function(o)
    local data=records[o]if data then disconnect(data)records[o]=nil end
    local previous=busy busy=true for name in pairs(features)do c.Unpatch(name,o)end busy=previous
   end)
  end
 end
 function api:Refresh()
  if dead or busy then return end busy=true
  local ok,message=pcall(function()
   sync()
   requestReference()
   local mode=c.Mode()local near=mode=="third"and c.Near()or false
   if mode~=lastMode or near~=lastNear then release()lastMode,lastNear=mode,near end
   if not mode then return end
   for o,data in pairs(records)do
    if o.Parent and character and o:IsDescendantOf(character)then
     local known=reference(o)
     if known then data.alpha=known.alpha data.texture=known.texture end
     if near then
      if data.head and o:IsA("BasePart")and not blocked(o,"LocalTransparencyModifier")then c.Patch("thirdNear",o,"LocalTransparencyModifier",1)end
     elseif data.alpha~=nil then
      -- First-person body fade is inactive in detached/far camera modes.
      c.Unpatch("body",o)
      if o:IsA("BasePart")and not blocked(o,"LocalTransparencyModifier")then c.Patch(mode=="free"and"freeBody"or"thirdBody",o,"LocalTransparencyModifier",0)end
      if data.texture and o.Texture~=data.texture and not blocked(o,"Texture")then c.Patch("cameraFace",o,"Texture",data.texture)end
      if o.Transparency>=.999 and not blocked(o,"Transparency")then c.Patch(mode=="free"and"freeAlpha"or"thirdAlpha",o,"Transparency",data.alpha)end
     end
    end
   end
  end)
  busy=false
  if not ok then warn("Prime Visuals / avatar visibility: "..tostring(message))end
 end
 function api:Destroy()
  if dead then return end dead=true busy=true generation=generation+1
  if added then added:Disconnect()end if removed then removed:Disconnect()end if characterAdded then characterAdded:Disconnect()end if appearanceLoaded then appearanceLoaded:Disconnect()end
  for _,data in pairs(records)do disconnect(data)end records={}release()
 end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 if c.Player.CharacterAdded then characterAdded=c.Player.CharacterAdded:Connect(function()api:Refresh()end)end
 if c.Player.CharacterAppearanceLoaded then appearanceLoaded=c.Player.CharacterAppearanceLoaded:Connect(function(char)
  if char==c.Player.Character then
   generation=generation+1 referenceState=nil referenceRetry=0 headReferences={}faceReferences={}
   api:Refresh()
  end
 end)end
 api:Refresh()
 return api
end
