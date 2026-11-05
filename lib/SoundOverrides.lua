-- Local SoundId overrides; never changes playback, volume or server state.
return function(c)
 local api={}local enabled,dead,writing=false,false,false local values={}local records,links={},{}
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
   for o in pairs(records)do remove(o)end c.Unpatch("soundReplace")return
  end
  for _,root in ipairs(c.Roots)do
   links[#links+1]=root.DescendantAdded:Connect(track)
   links[#links+1]=root.DescendantRemoving:Connect(function(o)if records[o]then remove(o)end end)
   for _,o in ipairs(root:GetDescendants())do track(o)end
  end
  local elapsed=0
  links[#links+1]=c.Run.Heartbeat:Connect(function(dt)elapsed=elapsed+dt if elapsed>=.75 then elapsed=0 self:Refresh()end end)
 end
 function api:Destroy()if dead then return end self:SetEnabled(false)dead=true end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 return api
end
