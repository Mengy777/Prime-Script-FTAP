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
  if ok and type(value)=="string"and value~=""then return value:match("(%d+)$")or value end
  local mesh=handle:FindFirstChildWhichIsA("SpecialMesh")
  local value=mesh and tostring(mesh.MeshId)or ""return value:match("(%d+)$")or value
 end
 local function isHeadHandle(o)
  for _,child in ipairs(o:GetChildren())do if child:IsA("Attachment")and headAttachments[child.Name]then return true end end
  return false
 end
 local function reference(o)
  if o:IsA("BasePart")and o.Name=="Handle"and o.Parent then
   local key=meshKey(o)
   return headReferences[o.Parent.Name.."|"..key]or(key~=""and isHeadHandle(o)and headReferences["@mesh:"..key]or nil)
  end
  if(o:IsA("Decal")or o:IsA("Texture"))and o.Parent==character:FindFirstChild("Head")then return faceReferences[o.ClassName.."|"..o.Name:lower()]end
 end
 local function requestReference()
  if referenceState=="pending"or referenceState=="ready"or os.clock()<referenceRetry or not character then return end
  local h=character:FindFirstChildWhichIsA("Humanoid")
  if not h or type(h.GetAppliedDescription)~="function"or not c.Players or type(c.Players.CreateHumanoidModelFromDescriptionAsync)~="function"then return end
  referenceState="pending"local token=generation local current=character
  task.spawn(function()
   local temporaries={}local heads,faces={},{}
   local function owned(o)if o then temporaries[#temporaries+1]=o end return o end
   local function currentGeneration()return not dead and token==generation and c.Player.Character==current end
   local function collect(model,faceOverride)
    for _,accessory in ipairs(model:GetChildren())do
     if accessory:IsA("Accessory")or accessory:IsA("Hat")then
      local handle=accessory:FindFirstChild("Handle")
      if handle and isHeadHandle(handle)and handle.Transparency<1 then
       local record={alpha=handle.Transparency}local mesh=meshKey(handle)
       heads[accessory.Name.."|"..mesh]=record if mesh~=""then heads["@mesh:"..mesh]=record end
      end
     end
    end
    local head=model:FindFirstChild("Head")
    if head then for _,o in ipairs(head:GetChildren())do
     if(o:IsA("Decal")or o:IsA("Texture"))and o.Transparency<1 then
      local key=o.ClassName.."|"..o.Name:lower()
      if faceOverride or not faces[key]then faces[key]={alpha=o.Transparency,texture=o.Texture}end
     end
    end end
   end
   local applied
   local ok,message=pcall(function()
    applied=owned(h:GetAppliedDescription())if not currentGeneration()then return end
    local model=owned(c.Players:CreateHumanoidModelFromDescriptionAsync(applied,h.RigType))
    if currentGeneration()then collect(model,true)end
   end)
   local incomplete=not ok
   if currentGeneration()then
    for _,o in ipairs(current:GetDescendants())do
     if o:IsA("BasePart")and o.Name=="Handle"and o.Parent and isHeadHandle(o)then
      local mesh=meshKey(o)
      if not heads[o.Parent.Name.."|"..mesh]and not heads["@mesh:"..mesh]then incomplete=true break end
     end
    end
   end
   local needsRetry=incomplete
   local defaultFace=applied and applied.Face==0
   if currentGeneration()and(incomplete or defaultFace)and type(c.Players.GetHumanoidDescriptionFromUserIdAsync)=="function"then
    local fallbackOK,fallbackError=pcall(function()
     local description=owned(c.Players:GetHumanoidDescriptionFromUserIdAsync(c.Player.UserId))
     if not currentGeneration()then return end
     local model=owned(c.Players:CreateHumanoidModelFromDescriptionAsync(description,h.RigType))
     if currentGeneration()then collect(model,not ok or(defaultFace and type(description.Face)=="number"and description.Face>0))end
    end)
    if fallbackOK then
     ok=true needsRetry=false
     if currentGeneration()then for _,o in ipairs(current:GetDescendants())do
      if o:IsA("BasePart")and o.Name=="Handle"and o.Parent and isHeadHandle(o)then
       local key=meshKey(o)
       if not heads[o.Parent.Name.."|"..key]and not heads["@mesh:"..key]then needsRetry=true break end
      end
     end end
    else message=fallbackError needsRetry=true end
   end
   for _,o in ipairs(temporaries)do pcall(function()o:Destroy()end)end
   if not currentGeneration()then return end
   if ok then
    headReferences,faceReferences=heads,faces
    if needsRetry then referenceState=nil referenceRetry=os.clock()+15 else referenceState="ready"end
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
