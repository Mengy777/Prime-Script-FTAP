-- Local ordering of existing native Your Toys cards. Never spawns or clones toys.
return function(c)
 local api={} local enabled,dead,writing,dirty=false,false,false,false
 local cards,layouts,links={}, {}, {} local order={}local lastStatus
 local LIMIT=27 local nativeParent
 local diagnosticSize=-1 local diagnosticTime=-math.huge
 local defaults={"FlyingToyUfo","Campfire","FoodMushroomPoison","PaperPlane","FoodHotSauce","ToiletWhite","BombBalloon","FireworkSparkler","FireworkSmokeBomb",
 "BallSnowball","GlassBoxGray","InstrumentGuitarAcoustic","BombDarkMatter","BombMissile","TetracubeL","InstrumentBrassTrumpet","InstrumentWoodwindOcarina","FoodCakePink",
 "FoodHamburger","LadderLightBrown","FloatingIsland","YouDecoy","PalletLightBrown","CreatureBlobman","DiscoColorBall","BallMagicLight","JukeboxBlue"}
 local function norm(s)return tostring(s or ""):lower():gsub("[^%w]","")end
 local aliases={}
 local function alias(id,values)aliases[norm(id)]=norm(id)for _,v in ipairs(values)do aliases[norm(v)]=norm(id)end end
 alias("Rocket",{"BombMissile","Missile","FireworkRocket"})
 alias("Black Crystal",{"CrystalBlack","BlackCrystal","DarkCrystal","Crystal","BombDarkMatter"})
 alias("CreatureBlobman",{"Blobman"})alias("Tetracub L",{"TetracubeL","TetraCubeL","TetraCube L","TetrisL"})
 alias("PalletLightBrown",{"Pallet","WoodPallet","Standard Pallet","Light Brown Pallet"})
 alias("Basketball",{"BallBasketball"})alias("Balloon",{"BombBalloon"})alias("Chair",{"ChildrensChair"})alias("Couch",{"CouchBlue"})alias("Ball",{"BallSnowball"})alias("Firework",{"FireworkSparkler"})
 alias("Cube",{"BlockCube","WoodCube","TetracubeO"})alias("FoodCakePink",{"Cake","Pink Cake"})alias("FoodDonut",{"Donut","Doughnut"})
 alias("InstrumentBrassTrumpet",{"Trumpet"})alias("InstrumentWoodwindOcarina",{"Ocarina"})
 for _,v in ipairs(defaults)do if not aliases[norm(v)]then aliases[norm(v)]=norm(v)end end
 local function id(s)local key=norm(s)return aliases[key]or key end
 function api:Canonical(value)return id(value)end
 local function status(code,count)
  local key=code..":"..tostring(count or 0)if key==lastStatus then return end lastStatus=key
  if c.Status then c.Status(code,count or 0)end
 end
 function api:DefaultOrder()return table.concat(defaults,",")end
 local function parse(value)
  local result={}for part in (tostring(value or "")..","):gmatch("(.-),")do
   if #result>=LIMIT then break end result[#result+1]=part:match("^%s*(.-)%s*$")
  end
  for i=#result+1,LIMIT do result[i]=""end
  local _,commas=tostring(value or ""):gsub(",",",")
  if commas>=27 and id(result[26])==id("PalletLightBrown")then result[23],result[26]=result[26],result[23]end
  return result
 end
 function api:SetOrder(value)order=parse(value)dirty=true end
 local function identity(card)
  local values={card.Name}
  for _,key in ipairs({"ToyName","ToyId","ItemName"})do local v=card:GetAttribute(key)if type(v)=="string"then values[#values+1]=v end end
  local candidates=card:GetDescendants()local cardLike=card:IsA("GuiButton")or card:IsA("ViewportFrame")
  for i,o in ipairs(candidates)do
   if i>100 then break end
   if o:IsA("GuiButton")or o:IsA("ViewportFrame")then cardLike=true end
   if o:IsA("TextLabel")or o:IsA("TextButton")then values[#values+1]=o.Text end
   if o:IsA("ObjectValue")and o.Value then values[#values+1]=o.Value.Name end
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
  -- Verified native capture: only the owned Toys tab, never shop/templates/destroy.
  if parent.Name=="Contents" and parent.Parent and parent.Parent.Name=="Toys" then
   local tabs=parent.Parent.Parent local menu=tabs and tabs.Parent
   if tabs and tabs.Name=="TabContents" and menu and menu.Name=="Menu" and menu.Parent and menu.Parent.Name=="MenuGui" then return true end
  end
  local p=parent local toyMenu=false
  while p and p~=c.PlayerGui do
   local name=norm(p.Name)
   if name:find("prime",1,true)or name:find("pvvisual",1,true)then return false end
   if name:find("shop",1,true)or name:find("store",1,true)or name=="toydestroy"or name=="toytemplates"then return false end
   if name:find("yourtoys",1,true)or name:find("ownedtoys",1,true)or name:find("mytoys",1,true)then return true end
   if name:find("toy",1,true)and(name:find("menu",1,true)or name:find("inventory",1,true))then toyMenu=true end
   for _,child in ipairs(p:GetChildren())do
    if child:IsA("TextLabel")and(norm(child.Text)=="yourtoys"or norm(child.Text)=="mytoys")then return true end
   end
   p=p.Parent
  end
  return toyMenu and recognized>=8
 end
 local function disconnect(data)for _,link in ipairs(data.links)do link:Disconnect()end if data.star then data.star:Destroy()end end
 local function restore()
  writing=true
  for _,data in pairs(cards)do disconnect(data)end
  for _,data in pairs(layouts)do disconnect(data)end
  cards={}layouts={}nativeParent=nil c.Unpatch("toyCollection")writing=false
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
   -- Native reopening/favorite sorting cannot displace a prepared collection.
   local target=data.targets and data.targets[property]
   if target~=nil then writing=true c.Patch("toyCollection",o,property,target)writing=false return end
   if property=="LayoutOrder"then data.base=o.LayoutOrder elseif property=="Position"then data.position=o.Position data.origin=o.AbsolutePosition end dirty=true
  end)
 end
 local function preview(card)
  return card:IsA("ViewportFrame")and card or card:FindFirstChildWhichIsA("ViewportFrame",true)
 end
 local function star(card,data,selected)
  if not selected then if data.star then data.star:Destroy()data.star=nil end return end
  if data.star and data.star.Parent then return end
  local source
  for _,o in ipairs(card:GetDescendants())do
   if(o:IsA("ImageLabel")or o:IsA("ImageButton")or o:IsA("TextLabel")or o:IsA("TextButton"))and(norm(o.Name):find("star",1,true)or norm(o.Name):find("favor",1,true)or (o.Parent and norm(o.Parent.Name):find("favor",1,true))or ((o:IsA("TextLabel")or o:IsA("TextButton"))and o.Text==utf8.char(9733)))then source=o break end
  end
  local holder=Instance.new("Frame")holder.Name="PV_CollectionStar"holder.BackgroundTransparency=1 holder.Active=false
  holder.Position=source and source.Position or UDim2.new(1,-3,1,-3)
  holder.AnchorPoint=source and source.AnchorPoint or Vector2.new(1,1)
  local size=source and source.Size or UDim2.fromOffset(25,25)
  holder.Size=UDim2.new(size.X.Scale*.65,size.X.Offset*.65,size.Y.Scale*.65,size.Y.Offset*.65)holder.Rotation=source and source.Rotation or 0
  holder.ZIndex=(source and source.ZIndex or card.ZIndex or 1)+2 holder.ClipsDescendants=false
  local image=source and(source:IsA("ImageLabel")or source:IsA("ImageButton"))and source.Image~=""
  local function layer(scale,black)
   local o=Instance.new(image and "ImageLabel"or "TextLabel")o.Name=black and "Fill"or "Outline"
   o.BackgroundTransparency=1 o.Active=false o.AnchorPoint=Vector2.new(.5,.5)o.Position=UDim2.fromScale(.5,.5)o.Size=UDim2.fromScale(scale,scale)o.ZIndex=holder.ZIndex+(black and 1 or 0)
   if image then o.Image=source.Image o.ImageRectOffset=source.ImageRectOffset o.ImageRectSize=source.ImageRectSize o.ImageColor3=black and Color3.new(0,0,0)or Color3.fromHSV(0,1,1)
   else o.Text=source and(source:IsA("TextLabel")or source:IsA("TextButton"))and source.Text or utf8.char(9733)o.TextScaled=true o.Font=Enum.Font.Gotham o.TextColor3=black and Color3.new(0,0,0)or Color3.fromHSV(0,1,1)o.TextStrokeTransparency=1 end
   o.Parent=holder return o
  end
  data.outline=layer(1.16,false)layer(1,true)
  holder.Parent=source and source.Parent or card data.star=holder
 end
 local function refresh()
  if not enabled or dead or not dirty then return end dirty=false
  local seenCards,seenLayouts={},{} local found,total=false,0
  local ok,message=pcall(function()
   local groups={}
   local screen=c.PlayerGui:FindFirstChild("MenuGui")local menu=screen and screen:FindFirstChild("Menu")
   local tabs=menu and menu:FindFirstChild("TabContents")local toys=tabs and tabs:FindFirstChild("Toys")
   nativeParent=toys and toys:FindFirstChild("Contents")
   local descendants={}
   if nativeParent then
    local grid=nativeParent:FindFirstChildWhichIsA("UIGridLayout")or nativeParent:FindFirstChildWhichIsA("UIListLayout")
    if grid then groups[nativeParent]={layout=grid}end
   else descendants=c.PlayerGui:GetDescendants()end
   if not nativeParent and c.CaptureDiagnostic and #descendants~=diagnosticSize and os.clock()-diagnosticTime>=2 then
    diagnosticSize=#descendants diagnosticTime=os.clock()pcall(c.CaptureDiagnostic)
   end
   for _,o in ipairs(descendants)do
    if(o:IsA("UIGridLayout")or o:IsA("UIListLayout"))and o.Parent then groups[o.Parent]={layout=o}end
   end
   -- Native menus may position viewport cards directly, without any grid instance.
   for _,o in ipairs(descendants)do if o:IsA("ViewportFrame")then
    local node=o
    for depth=1,6 do
     local parent=node.Parent if not parent or parent==c.PlayerGui then break end
     if groups[parent]then break end
     local count=0 for _,child in ipairs(parent:GetChildren())do if child:IsA("GuiObject")and preview(child)then count=count+1 end end
     if count>=4 then groups[parent]={}break end node=parent
    end
   end end
   writing=true
   for parent,group in pairs(groups)do
    local layout=group.layout local items={}local recognized=0
    for index,card in ipairs(parent:GetChildren())do if card:IsA("GuiObject")and not card.Name:find("PV_",1,true)then
     local cached=cards[card]
     local key,name,known
     if cached and cached.key then key,name,known=cached.key,cached.name,cached.known
     elseif parent==nativeParent then key,name,known=id(card.Name),card.Name,aliases[norm(card.Name)]~=nil
     else key,name,known=identity(card)end
     if key then
      local data=cards[card]
      items[#items+1]={card=card,id=key,name=name,index=index,base=data and data.base or original(card,"LayoutOrder")or 0,
       position=data and data.position or original(card,"Position"),origin=data and data.origin or card.AbsolutePosition}
      if known then recognized=recognized+1 end
     end
    end end
    if #items>=2 and context(parent,recognized)then
     found=true
     if layout then
      seenLayouts[layout]=true
      if not layouts[layout]then local data={links={},targets={SortOrder=Enum.SortOrder.LayoutOrder}}layouts[layout]=data watch(layout,"SortOrder",data)end
     end
     local byName=layout and original(layout,"SortOrder")==Enum.SortOrder.Name
     table.sort(items,function(a,b)
      if not layout then
       if math.abs(a.origin.Y-b.origin.Y)>2 then return a.origin.Y<b.origin.Y end
       if a.origin.X~=b.origin.X then return a.origin.X<b.origin.X end
      elseif byName then if a.card.Name~=b.card.Name then return a.card.Name<b.card.Name end
      elseif a.base~=b.base then return a.base<b.base end return a.index<b.index
     end)
     local allItems=items items={}
     for _,item in ipairs(allItems)do
      seenCards[item.card]=true
      if not cards[item.card]then
       local data={links={},base=item.base,position=item.position,origin=item.origin,key=item.id,name=item.name,known=true,targets={}}cards[item.card]=data
       watch(item.card,"LayoutOrder",data)if not layout then watch(item.card,"Position",data)end
       if parent~=nativeParent then data.links[#data.links+1]=item.card:GetPropertyChangedSignal("Visible"):Connect(function()if not writing then dirty=true end end)end
      end
      if parent==nativeParent or item.card.Visible~=false then items[#items+1]=item else star(item.card,cards[item.card],false)c.Unpatch("toyCollection",item.card)end
     end
     local slots,used={},{}
     for slot=1,LIMIT do for _,item in ipairs(items)do if not used[item]and order[slot]~=""and item.id==id(order[slot])then slots[slot]=item used[item]=true break end end end
     for slot=1,math.min(LIMIT,#items)do if not slots[slot]then for _,item in ipairs(items)do if not used[item]then slots[slot]=item used[item]=true break end end end end
     local ranks,ordered={},{}
     for slot=1,LIMIT do local item=slots[slot]if item then ranks[item.card]=-10000+slot ordered[#ordered+1]=item total=total+1 end end
     for _,item in ipairs(items)do if not used[item]then ordered[#ordered+1]=item end end
     if layout then c.Patch("toyCollection",layout,"SortOrder",Enum.SortOrder.LayoutOrder)end
     for index,item in ipairs(ordered)do
      local data=cards[item.card]
      if layout then data.targets.LayoutOrder=ranks[item.card]or index c.Patch("toyCollection",item.card,"LayoutOrder",data.targets.LayoutOrder)
      else data.targets.Position=items[index].position c.Patch("toyCollection",item.card,"Position",data.targets.Position)end
      star(item.card,cards[item.card],ranks[item.card]~=nil)
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
  local function nativeChanged(o)
   if nativeParent and nativeParent.Parent and not o:IsDescendantOf(nativeParent)and o~=nativeParent then return end
   local node=o while node and node~=c.PlayerGui do
    if node.Name:find("PV_",1,true)or norm(node.Name):find("prime",1,true)or norm(node.Name):find("obsidian",1,true)then return end node=node.Parent
   end dirty=true
  end
  links[#links+1]=c.PlayerGui.DescendantAdded:Connect(nativeChanged)
  links[#links+1]=c.PlayerGui.DescendantRemoving:Connect(nativeChanged)
  local elapsed=0
  links[#links+1]=c.Run.Heartbeat:Connect(function(dt)
   elapsed=elapsed+dt
   if dirty then refresh()end
   if elapsed<.1 then return end elapsed=0
   local visible=nativeParent
   while visible and visible~=c.PlayerGui do
    if visible:IsA("GuiObject")and visible.Visible==false then return end visible=visible.Parent
   end
   local color=Color3.fromHSV((os.clock()%8)/8,1,1)
   for card,data in pairs(cards)do if data.star and data.star.Parent and card.Visible~=false then
    if data.outline:IsA("ImageLabel")then data.outline.ImageColor3=color else data.outline.TextColor3=color end
   end end
  end)
  refresh()
 end
 function api:Destroy()
  if dead then return end self:SetEnabled(false)dead=true restore()
 end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 order=defaults
 return api
end
