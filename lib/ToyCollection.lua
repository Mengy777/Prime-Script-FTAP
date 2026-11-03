-- Local ordering of existing native Your Toys cards. Never spawns or clones toys.
return function(c)
 local api={} local enabled,dead,writing,dirty=false,false,false,false
 local cards,layouts,links={}, {}, {} local order={}local lastStatus
 local defaults={"Rocket","Black Crystal","CreatureBlobman","Tetracub L","FoodCakePink","Cube","InstrumentBrassTrumpet","InstrumentWoodwindOcarina",
 "FoodDonut","InstrumentGuitarUkulele","InstrumentGuitarAcoustic","InstrumentPianoMelodica","InstrumentVoiceMicrophone","InstrumentDrumBongos",
 "Basketball","Balloon","Firework","Boombox","Chair","Couch","Ball","Snowboard","FoodHamburger","FoodPizzaCheese","FoodCoconut","PalletLightBrown","ShoppingCart","SantaSleigh"}
 local function norm(s)return tostring(s or ""):lower():gsub("[^%w]","")end
 local aliases={}
 local function alias(id,values)aliases[norm(id)]=norm(id)for _,v in ipairs(values)do aliases[norm(v)]=norm(id)end end
 alias("Rocket",{"BombMissile","Missile","FireworkRocket"})
 alias("Black Crystal",{"CrystalBlack","BlackCrystal","DarkCrystal","Crystal"})
 alias("CreatureBlobman",{"Blobman"})alias("Tetracub L",{"TetracubeL","TetraCubeL","TetraCube L","TetrisL"})
 alias("PalletLightBrown",{"Pallet","WoodPallet","Standard Pallet","Light Brown Pallet"})
 alias("Cube",{"BlockCube","WoodCube"})alias("FoodCakePink",{"Cake","Pink Cake"})alias("FoodDonut",{"Donut","Doughnut"})
 alias("InstrumentBrassTrumpet",{"Trumpet"})alias("InstrumentWoodwindOcarina",{"Ocarina"})
 for _,v in ipairs(defaults)do if not aliases[norm(v)]then aliases[norm(v)]=norm(v)end end
 local function id(s)local key=norm(s)return aliases[key]or key end
 local function status(code,count)
  local key=code..":"..tostring(count or 0)if key==lastStatus then return end lastStatus=key
  if c.Status then c.Status(code,count or 0)end
 end
 function api:DefaultOrder()return table.concat(defaults,",")end
 local function parse(value)
  local result={}for part in (tostring(value or "")..","):gmatch("(.-),")do
   if #result>=28 then break end result[#result+1]=part:match("^%s*(.-)%s*$")
  end
  for i=#result+1,28 do result[i]=""end return result
 end
 function api:SetOrder(value)order=parse(value)dirty=true end
 function api:Assign(value,slot,toy)
  local list=parse(value)slot=math.clamp(math.floor(tonumber(slot)or 1),1,28)
  toy=tostring(toy or ""):match("^%s*(.-)%s*$")
  assert(#toy<=100 and not toy:find(",",1,true),"Enter one toy name")
  if toy~=""then for i,v in ipairs(list)do if i~=slot and id(v)==id(toy)then list[i]=list[slot]break end end end
  list[slot]=toy return table.concat(list,",")
 end
 local function identity(card)
  local values={card.Name}
  for _,key in ipairs({"ToyName","ToyId","ItemName"})do local v=card:GetAttribute(key)if type(v)=="string"then values[#values+1]=v end end
  local candidates=card:GetDescendants()local cardLike=card:IsA("GuiButton")
  for i,o in ipairs(candidates)do
   if i>100 then break end
   if o:IsA("GuiButton")or o:IsA("ViewportFrame")then cardLike=true end
   if o:IsA("TextLabel")or o:IsA("TextButton")then values[#values+1]=o.Text end
   if o:IsA("Model")or o:IsA("StringValue")then values[#values+1]=o:IsA("StringValue")and o.Value or o.Name end
  end
  if card:IsA("TextButton")then values[#values+1]=card.Text end
  for _,v in ipairs(values)do
   local k=norm(v):gsub("button$",""):gsub("frame$","")
   if aliases[k]then return aliases[k],tostring(v),true end
  end
  if not cardLike then return end
  local name=norm(card.Name)
  if name~=""and name~="frame"and name~="button"and name~="template"then return name,card.Name,false end
  for _,v in ipairs(values)do if type(v)=="string"and norm(v)~=""and norm(v)~="frame"and norm(v)~="button"and norm(v)~="template"then return id(v),v,false end end
 end
 local function context(parent,recognized)
  local p=parent local toyMenu=false
  while p and p~=c.PlayerGui do
   local name=norm(p.Name)
   if name:find("prime",1,true)or name:find("pvvisual",1,true)then return false end
   if name:find("shop",1,true)or name:find("store",1,true)then return false end
   if name:find("yourtoys",1,true)or name:find("ownedtoys",1,true)or name:find("mytoys",1,true)then return true end
   if name:find("toy",1,true)and(name:find("menu",1,true)or name:find("inventory",1,true))then toyMenu=true end
   for _,child in ipairs(p:GetChildren())do
    if child:IsA("TextLabel")and(norm(child.Text)=="yourtoys"or norm(child.Text)=="mytoys")then return true end
   end
   p=p.Parent
  end
  return toyMenu and recognized>=8
 end
 local function disconnect(data)for _,link in ipairs(data.links)do link:Disconnect()end end
 local function restore()
  writing=true
  for _,data in pairs(cards)do disconnect(data)end
  for _,data in pairs(layouts)do disconnect(data)end
  cards={}layouts={}c.Unpatch("toyCollection")writing=false
 end
 local function original(o,property)
  local entry=c.Patches[o]and c.Patches[o][property]
  return entry and entry.original or o[property]
 end
 local function watch(o,property,data)
  data.links[#data.links+1]=o:GetPropertyChangedSignal(property):Connect(function()
   if writing or not enabled or dead then return end
   local entry=c.Patches[o]and c.Patches[o][property]
   if entry then entry.original=o[property]end
   if property=="LayoutOrder"then data.base=o.LayoutOrder end dirty=true
  end)
 end
 local function refresh()
  if not enabled or dead or not dirty then return end dirty=false
  local seenCards,seenLayouts={},{} local found,total=false,0
  writing=true
  local ok,message=pcall(function()
   for _,layout in ipairs(c.PlayerGui:GetDescendants())do
    if layout:IsA("UIGridLayout")and layout.Parent then
     local parent=layout.Parent local items={}local recognized=0
     for index,card in ipairs(parent:GetChildren())do
      if card:IsA("GuiObject")then
       local key,name,known=identity(card)
       if key then
        items[#items+1]={card=card,id=key,name=name,index=index,base=cards[card]and cards[card].base or original(card,"LayoutOrder")}
        if known then recognized=recognized+1 end
       end
      end
     end
     if #items>=2 and recognized>=2 and context(parent,recognized)then
      found=true seenLayouts[layout]=true
      if not layouts[layout]then local data={links={}}layouts[layout]=data watch(layout,"SortOrder",data)end
      local byName=original(layout,"SortOrder")==Enum.SortOrder.Name
      table.sort(items,function(a,b)
       if byName then if a.card.Name~=b.card.Name then return a.card.Name<b.card.Name end
       elseif a.base~=b.base then return a.base<b.base end return a.index<b.index
      end)
      local allItems=items items={}
      for _,item in ipairs(allItems)do
       seenCards[item.card]=true
       if not cards[item.card]then
        local data={links={},base=item.base}cards[item.card]=data watch(item.card,"LayoutOrder",data)
        data.links[#data.links+1]=item.card:GetPropertyChangedSignal("Visible"):Connect(function()if not writing then dirty=true end end)
       end
       if item.card.Visible~=false then items[#items+1]=item else c.Unpatch("toyCollection",item.card)end
      end
      local slots,used={},{}
      for slot=1,28 do for _,item in ipairs(items)do if not used[item]and order[slot]~=""and item.id==id(order[slot])then slots[slot]=item used[item]=true break end end end
      for slot=1,math.min(28,#items)do if not slots[slot]then for _,item in ipairs(items)do if not used[item]then slots[slot]=item used[item]=true break end end end end
      local ranks={}for slot,item in pairs(slots)do ranks[item.card]=-10000+slot total=total+1 end
      c.Patch("toyCollection",layout,"SortOrder",Enum.SortOrder.LayoutOrder)
      for index,item in ipairs(items)do
       c.Patch("toyCollection",item.card,"LayoutOrder",ranks[item.card]or index)
      end
     end
    end
   end
   for o,data in pairs(cards)do if not seenCards[o]then disconnect(data)cards[o]=nil c.Unpatch("toyCollection",o)end end
   for o,data in pairs(layouts)do if not seenLayouts[o]then disconnect(data)layouts[o]=nil c.Unpatch("toyCollection",o)end end
  end)
  writing=false
  if not ok then dirty=true status("error")if c.Warn then c.Warn(message)end
  else status(found and "ready"or "missing",total)end
 end
 function api:SetEnabled(on)
  if dead or enabled==(on==true)then return end enabled=on==true
  for _,link in ipairs(links)do link:Disconnect()end links={}
  if not enabled then restore()status("off")return end
  dirty=true
  links[#links+1]=c.PlayerGui.DescendantAdded:Connect(function()dirty=true end)
  links[#links+1]=c.PlayerGui.DescendantRemoving:Connect(function()dirty=true end)
  local elapsed=0
  links[#links+1]=c.Run.Heartbeat:Connect(function(dt)elapsed=elapsed+dt if elapsed>=.2 then elapsed=0 refresh()end end)
  refresh()
 end
 function api:Destroy()
  if dead then return end self:SetEnabled(false)dead=true restore()
 end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 order=defaults
 return api
end
