-- Local SoundId overrides; never changes playback, volume or server state.
return function(c)
 local api={}local enabled,dead,writing=false,false,false local values={}local records,links={},{}
 local beams,preview,grabSound,lastTarget={},nil,nil,nil
 local function stop(sound)if sound then sound:Destroy()end end
 function api:StopPreview()stop(preview)preview=nil end
 function api:Preview(value)
  if dead then return end self:StopPreview()
  local sound=c.Make("Sound",{Name="PV_AudioPreview",SoundId=c.Resolve(value),Volume=.5,Looped=false},c.SoundRoot)
  preview=sound sound:Play()
  task.delay(4,function()
   if preview==sound and sound.IsLoaded==false and c.Notify then
    c.Notify(c.Translate("Audio could not load; check asset permissions or try another preset."))
   end
  end)
  task.delay(8,function()if preview==sound then self:StopPreview()end end)
 end
 local function updateGrab()
  local target
  for beam in pairs(beams)do
   if not beam.Parent then beams[beam]=nil
   elseif beam.Enabled~=false and beam.Attachment1 and c.OwnBeam(beam)then
    local scope=beam.Parent
    while scope and scope.Name~="GrabParts"do scope=scope.Parent end
    local part=scope and scope:FindFirstChild("GrabPart")
    local weld=part and part:FindFirstChild("WeldConstraint")
    if weld and weld.Enabled~=false and weld.Active~=false then
     local a,b=weld.Part0,weld.Part1 local other=a==part and b or(b==part and a or nil)
     if other and other.Parent then target=other break end
    end
   end
  end
  if target and target~=lastTarget and values.Grab then
   local native=false for sound in pairs(records)do if sound.Parent and c.Matches("Grab",sound)then native=true break end end
   if not native then
    stop(grabSound)grabSound=c.Make("Sound",{Name="PV_GrabFeedback",SoundId=values.Grab,Volume=.5,Looped=false},c.SoundRoot)
    grabSound:Play()
   end
  end
  lastTarget=target
 end
 local function remove(o)
  local data=records[o]if data then for _,link in ipairs(data)do link:Disconnect()end records[o]=nil end
  c.Unpatch("soundReplace",o)
 end
 local function apply(o)
  if dead or not enabled or writing or not o.Parent then return end
  local wanted
  for _,category in ipairs(c.Categories)do if values[category]and c.Matches(category,o)then wanted=values[category]break end end
  writing=true
  local ok,message=pcall(function()
   if wanted then c.Patch("soundReplace",o,"SoundId",wanted)else c.Unpatch("soundReplace",o)end
  end)
  writing=false if not ok then error(message,0)end
 end
 local function track(o)
  if o:IsA("Beam")then beams[o]=true return end
  if o.Name=="PV_AudioPreview"or o.Name=="PV_GrabFeedback"then return end
  if not o:IsA("Sound")or records[o]then return end
  local data={}records[o]=data
  data[#data+1]=o:GetPropertyChangedSignal("SoundId"):Connect(function()
   if writing then return end
   local entry=c.Patches[o]and c.Patches[o].SoundId
   if entry and entry.layers.soundReplace and o.SoundId==entry.layers.soundReplace.value then return end
   if entry then entry.original=o.SoundId end apply(o)
  end)
  data[#data+1]=o:GetPropertyChangedSignal("Name"):Connect(function()apply(o)end)
  data[#data+1]=o:GetPropertyChangedSignal("Parent"):Connect(function()if o.Parent then apply(o)else remove(o)end end)
  apply(o)
 end
 function api:Refresh()
  for o in pairs(records)do if not o.Parent then remove(o)else apply(o)end end
 end
 function api:SetReplacement(category,value)
  assert(table.find(c.Categories,category),"Unknown sound category")
  value=tostring(value or ""):match("^%s*(.-)%s*$")
  local resolved=value~=""and c.Resolve(value)or nil
  values[category]=resolved self:Refresh()
 end
 function api:SetEnabled(on)
  if dead or enabled==(on==true)then return end enabled=on==true
  if not enabled then
   for _,link in ipairs(links)do link:Disconnect()end links={}
   for o in pairs(records)do remove(o)end c.Unpatch("soundReplace")
   beams={}lastTarget=nil stop(grabSound)grabSound=nil self:StopPreview()return
  end
  for _,root in ipairs(c.Roots)do
   links[#links+1]=root.DescendantAdded:Connect(track)
   links[#links+1]=root.DescendantRemoving:Connect(function(o)if records[o]then remove(o)end end)
   for _,o in ipairs(root:GetDescendants())do track(o)end
  end
  local elapsed,grabElapsed=0,0
  links[#links+1]=c.Run.Heartbeat:Connect(function(dt)
   elapsed=elapsed+dt grabElapsed=grabElapsed+dt
   if grabElapsed>=.05 then grabElapsed=0 updateGrab()end
   if elapsed>=.75 then elapsed=0 self:Refresh()end
  end)
 end
 function api:Destroy()if dead then return end self:SetEnabled(false)self:StopPreview()stop(grabSound)grabSound=nil dead=true end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 return api
end
