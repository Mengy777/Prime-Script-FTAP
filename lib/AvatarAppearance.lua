-- Shared early appearance snapshot for local camera visibility. No avatar recreation.
return function(c)
 local character,parts,added,removed=nil,{},nil,nil local dead=false
 local api={}
 local body={Head=true,Torso=true,UpperTorso=true,LowerTorso=true,["Left Arm"]=true,["Right Arm"]=true,["Left Leg"]=true,["Right Leg"]=true,
 LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,RightUpperArm=true,RightLowerArm=true,RightHand=true,
 LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,RightUpperLeg=true,RightLowerLeg=true,RightFoot=true}
 local function avatarPart(o)
  if o.Name=="HumanoidRootPart"then return false end
  if body[o.Name]and o.Parent==character then return true end
  local p=o.Parent
  while p and p~=character do if p:IsA("Accessory")or p:IsA("Hat")then return o.Name=="Handle"or not o:IsA("BasePart")end p=p.Parent end
  return (o:IsA("Decal")or o:IsA("Texture"))and o.Parent and o.Parent.Name=="Head"
 end
 local function track(o)
  if parts[o]or not(o:IsA("BasePart")or o:IsA("Decal")or o:IsA("Texture"))then return end
  local initial=o.Transparency
  local data={alpha=initial<1 and initial or avatarPart(o)and 0 or nil}parts[o]=data
  data.link=o:GetPropertyChangedSignal("Transparency"):Connect(function()
   local entry=c.Patches[o]and c.Patches[o].Transparency
   if not entry and o.Transparency<1 then data.alpha=o.Transparency end
   if not dead and c.FreecamActive and c.FreecamActive()and o.Transparency>=.999 then api:Reveal("freeAlpha")end
  end)
  if o:IsA("BasePart")then
   data.localLink=o:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
    if not dead and data.alpha~=nil and c.FreecamActive and c.FreecamActive()and o.LocalTransparencyModifier~=0 then c.Patch("freeBody",o,"LocalTransparencyModifier",0)end
   end)
  end
 end
 function api:Sync()
  local current=c.Player.Character
  if character==current then return end
  if added then added:Disconnect()end if removed then removed:Disconnect()end
  for _,data in pairs(parts)do if data.link then data.link:Disconnect()end if data.localLink then data.localLink:Disconnect()end end
  parts={}character=current
  if current then
   for _,o in ipairs(current:GetDescendants())do track(o)end
   added=current.DescendantAdded:Connect(track)
   removed=current.DescendantRemoving:Connect(function(o)local data=parts[o]if data then if data.link then data.link:Disconnect()end if data.localLink then data.localLink:Disconnect()end end parts[o]=nil end)
  end
 end
 function api:Alpha(o)self:Sync()track(o)return parts[o]and parts[o].alpha end
 function api:Reveal(feature)
  self:Sync()
  for o,data in pairs(parts)do
   if o.Parent and character and o:IsDescendantOf(character)and data.alpha~=nil then
    local entry=c.Patches[o]and c.Patches[o].Transparency local blocked=false
    if entry then for name in pairs(entry.layers)do if name~="thirdAlpha"and name~="freeAlpha"then blocked=true break end end end
    if not blocked and o.Transparency>=.999 then c.Patch(feature,o,"Transparency",data.alpha)end
   end
  end
 end
 function api:Destroy()
  if dead then return end dead=true
  if added then added:Disconnect()end if removed then removed:Disconnect()end
  for _,data in pairs(parts)do if data.link then data.link:Disconnect()end if data.localLink then data.localLink:Disconnect()end end parts={}
 end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 api:Sync()
 return api
end
