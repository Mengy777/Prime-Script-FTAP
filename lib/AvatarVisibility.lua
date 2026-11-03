-- One visibility owner for both camera modes. Never invent visible accessory baselines.
return function(c)
 local api={} local character,records=nil,{} local added,removed,characterAdded
 local busy,dead=false,false local lastMode,lastNear
 local body={Head=true,Torso=true,UpperTorso=true,LowerTorso=true,["Left Arm"]=true,["Right Arm"]=true,["Left Leg"]=true,["Right Leg"]=true,
 LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,RightUpperArm=true,RightLowerArm=true,RightHand=true,
 LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,RightUpperLeg=true,RightLowerLeg=true,RightFoot=true}
 local features={thirdBody=true,thirdNear=true,thirdAlpha=true,freeBody=true,freeAlpha=true}
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
   if o.Name=="Handle"and parent and(parent:IsA("Accessory")or parent:IsA("Hat"))and parent.Parent==character then return false,true end
  elseif(o:IsA("Decal")or o:IsA("Texture"))and o.Parent and o.Parent==character:FindFirstChild("Head")then return false,true end
 end
 local function blocked(o,property)
  local entry=c.Patches[o]and c.Patches[o][property]
  if entry then for name in pairs(entry.layers)do if not features[name]then return true end end end
  return false
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
  if o:IsA("BasePart")then data.links[#data.links+1]=o:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
   if not busy and not dead then api:Refresh()end
  end)end
 end
 local function sync()
  if c.Player.Character==character then return end
  if added then added:Disconnect()end if removed then removed:Disconnect()end
  for _,data in pairs(records)do disconnect(data)end
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
   local mode=c.Mode()local near=mode=="third"and c.Near()or false
   if mode~=lastMode or near~=lastNear then release()lastMode,lastNear=mode,near end
   if not mode then return end
   for o,data in pairs(records)do
    if o.Parent and character and o:IsDescendantOf(character)then
     if near then
      if data.head and o:IsA("BasePart")and not blocked(o,"LocalTransparencyModifier")then c.Patch("thirdNear",o,"LocalTransparencyModifier",1)end
     elseif data.alpha~=nil then
      -- First-person body fade is inactive in detached/far camera modes.
      c.Unpatch("body",o)
      if o:IsA("BasePart")and not blocked(o,"LocalTransparencyModifier")then c.Patch(mode=="free"and"freeBody"or"thirdBody",o,"LocalTransparencyModifier",0)end
      if o.Transparency>=.999 and not blocked(o,"Transparency")then c.Patch(mode=="free"and"freeAlpha"or"thirdAlpha",o,"Transparency",data.alpha)end
     end
    end
   end
  end)
  busy=false
  if not ok then warn("Prime Visuals / avatar visibility: "..tostring(message))end
 end
 function api:Destroy()
  if dead then return end dead=true busy=true
  if added then added:Disconnect()end if removed then removed:Disconnect()end if characterAdded then characterAdded:Disconnect()end
  for _,data in pairs(records)do disconnect(data)end records={}release()
 end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 if c.Player.CharacterAdded then characterAdded=c.Player.CharacterAdded:Connect(function()api:Refresh()end)end
 api:Refresh()
 return api
end
