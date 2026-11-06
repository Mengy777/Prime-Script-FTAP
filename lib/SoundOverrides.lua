-- Local audio replacements/tuning; playback position and server state stay native.
return function(c)
 local api={}local enabled,dead,writing=false,false,false local values={}local records,links={},{}local tuning={}
 local beams,preview,grabSound,lastTarget={},nil,nil,nil local previewCategory
 local function stop(sound)if sound then sound:Destroy()end end
 function api:StopPreview()stop(preview)preview=nil previewCategory=nil end
 function api:Preview(value,category)
  if dead then return end self:StopPreview()
  local sound=c.Make("Sound",{Name="PV_AudioPreview",SoundId=c.Resolve(value),Volume=.5*((tuning[category]or{}).gain or 1),PlaybackSpeed=(tuning[category]or{}).speed or 1,Looped=false},c.SoundRoot)
  preview=sound previewCategory=category sound:Play()
  task.delay(4,function()
   if preview==sound and sound.IsLoaded==false and c.Notify then
    c.Notify(c.Translate("Audio could not load; check asset permissions or try another preset."))
   end
  end)

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
    stop(grabSound)grabSound=c.Make("Sound",{Name="PV_GrabFeedback",SoundId=values.Grab,Volume=.5*((tuning.Grab or{}).gain or 1),PlaybackSpeed=(tuning.Grab or{}).speed or 1,Looped=false},c.SoundRoot)
    grabSound:Play()
   end
  end
  lastTarget=target
 end
 local function remove(o)
  local data=records[o]if data then for _,link in ipairs(data)do link:Disconnect()end records[o]=nil end
  c.Unpatch("soundReplace",o)c.Unpatch("soundVolume",o)c.Unpatch("soundSpeed",o)
 end
 local function apply(o)
  if dead or not enabled or writing or not o.Parent then return end
  local wanted,gain,speed=nil,1,1
  for _,category in ipairs(c.Categories)do
   local tune=tuning[category]or{}local relevant=values[category]or(tune.gain and tune.gain~=1)or(tune.speed and tune.speed~=1)
   if relevant and c.Matches(category,o)then wanted=values[category]gain=tune.gain or 1 speed=tune.speed or 1 break end
  end
  writing=true
  local ok,message=pcall(function()
   if wanted then c.Patch("soundReplace",o,"SoundId",wanted)else c.Unpatch("soundReplace",o)end
   local function tuneProperty(feature,property,factor)
    if factor==1 then c.Unpatch(feature,o)return end
    local entry=c.Patches[o]and c.Patches[o][property]
    local baseline=entry and entry.original or o[property]
    local value=(baseline or 1)*factor
    if property=="Volume"then value=math.clamp(value,0,10)if c.IsMuted and c.IsMuted(o)then value=0 end end
    c.Patch(feature,o,property,value)
   end
   tuneProperty("soundVolume","Volume",gain) tuneProperty("soundSpeed","PlaybackSpeed",speed)
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
  for _,property in ipairs({"Volume","PlaybackSpeed"})do
   data[#data+1]=o:GetPropertyChangedSignal(property):Connect(function()
    if writing then return end
    local entry=c.Patches[o]and c.Patches[o][property]
    if entry then
     for feature,layer in pairs(entry.layers)do if(feature=="soundVolume"or feature=="soundSpeed"or feature=="mutes")and o[property]==layer.value then return end end
     entry.original=o[property]
    end
    apply(o)
   end)
  end
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
  values[category]=resolved
  if category=="Grab"then stop(grabSound)grabSound=nil end
  self:Refresh()
 end
 function api:SetTuning(category,gain,speed)
  tuning[category]={gain=math.clamp(tonumber(gain)or 1,0,2),speed=math.clamp(tonumber(speed)or 1,.25,3)}self:Refresh()
  if preview and preview.Parent and previewCategory==category then preview.Volume=.5*tuning[category].gain preview.PlaybackSpeed=tuning[category].speed end
  if category=="Grab"and grabSound and grabSound.Parent then grabSound.Volume=.5*tuning[category].gain grabSound.PlaybackSpeed=tuning[category].speed end
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
   if values.Grab and grabElapsed>=.05 then grabElapsed=0 updateGrab()elseif not values.Grab then grabElapsed=0 lastTarget=nil end
   if elapsed>=.75 then elapsed=0 self:Refresh()end
  end)
 end
 function api:Destroy()if dead then return end self:SetEnabled(false)self:StopPreview()stop(grabSound)grabSound=nil dead=true end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 return api
end
