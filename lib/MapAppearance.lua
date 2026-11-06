-- Local map parts only. Cached classification never depends on our edited material.
return function(c)
 local v=c.Controls local root,dead,enabled=nil,false,false local parts,links,buckets={},{},{}
 local updatePreview,refresh
 local catalog=c.LoadModule("MapTextureCatalog")
 local textures=c.LoadModule("MapTextures")({Catalog=catalog,MaterialService=c.MaterialService,Patch=c.Patch,Unpatch=c.Unpatch,
  AssetBase=c.AssetBase,ImageId=c.ImageId,Notify=c.Notify,Translate=c.Translate,Warn=c.Warn,
  OnReady=function()if not dead then if refresh then refresh()end if updatePreview then updatePreview()end end end})
 local categories={"Snow","Sand","Grass","LushGrass","Rock","WasteGrass","Ocean","Dirt"}
 local names={}for _,name in ipairs(categories)do names[name:lower()]=name end
 local materials={Snow="Snow",Sand="Sand",Grass="Grass",LeafyGrass="LushGrass",Rock="Rock",Slate="Rock",Ground="Dirt",Mud="Dirt"}
 local function clear()
  for _,link in ipairs(links)do link:Disconnect()end links={}parts={}buckets={}root=nil textures:Clear()c.Unpatch("mapMaterial")c.Unpatch("mapTint")c.Unpatch("mapTextureTint")
 end
 local function classify(o)
  if not root or not o:IsA("BasePart")or not o:IsDescendantOf(root)then return end
  local p=o
  while p and p~=root do
   local key=names[p.Name:lower():gsub("[%s_%-]","")]
   if key then return key end p=p.Parent
  end
  local entry=c.Patches[o]and c.Patches[o].Material
  local material=entry and entry.original or o.Material
  return material and materials[material.Name]
 end
 local function apply(o,key)
  if not enabled or not o.Parent or not o:IsDescendantOf(root)then c.Unpatch("mapMaterial",o)c.Unpatch("mapTint",o)return end
  if v.mapMode=="Custom textures"then
   c.Unpatch("mapMaterial",o)c.Unpatch("mapTint",o)
   local prefix="mapTexture"..key
   local ready=textures:Apply(o,key,v[prefix.."Style"]or "Original",v[prefix.."Scale"]or 12,v[prefix.."Image"])
   if ready and v[prefix.."Tint"]and v[prefix.."Style"]~="Original"then c.Patch("mapTextureTint",o,"Color",v[prefix.."Color"])else c.Unpatch("mapTextureTint",o)end
  else
   textures:Remove(o)c.Unpatch("mapTextureTint",o)
   local prefix="map"..key
   if v[prefix.."Material"]and v[prefix.."Material"]~="Original"then c.Patch("mapMaterial",o,"Material",Enum.Material[v[prefix.."Material"]])else c.Unpatch("mapMaterial",o)end
   if v[prefix.."Tint"]then c.Patch("mapTint",o,"Color",v[prefix.."Color"])else c.Unpatch("mapTint",o)end
  end
 end
 local function forget(o)
  local key=parts[o]if key and buckets[key]then buckets[key][o]=nil end parts[o]=nil
  textures:Remove(o)c.Unpatch("mapTextureTint",o)c.Unpatch("mapMaterial",o)c.Unpatch("mapTint",o)
 end
 local function track(o)
  local key=classify(o)if key then parts[o]=key buckets[key]=buckets[key]or{}buckets[key][o]=true apply(o,key)end
 end
 refresh=function(category)
  for o in pairs(category and(buckets[category]or{})or parts)do
   if not o.Parent or not o:IsDescendantOf(root)then forget(o)else apply(o,parts[o])end
  end
 end
 local function attach()
  local map=c.Workspace:FindFirstChild("Map")
  if root==map then return end clear()if not enabled or not map then return end root=map
  links[#links+1]=map.DescendantAdded:Connect(track)
  links[#links+1]=map.DescendantRemoving:Connect(function(o)if parts[o]then forget(o)end end)
  for _,o in ipairs(map:GetDescendants())do track(o)end
 end
 local g=c.Group("World","Map surfaces",1)
 c.Toggle(g,"mapAppearanceEnabled","Map materials and colors",false,function(on)enabled=on if on then attach()else clear()end if updatePreview then updatePreview()end end)
 local panel=c.Panel("mapAppearanceEnabled")
 local visible
 local previewRow=panel:AddImage("mapTexturePreview",{Image="rbxassetid://0",Height=64,Transparency=1})
 local preview=c.Make("ImageLabel",{Name="PV_MapTexturePreview",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ScaleType=Enum.ScaleType.Tile,TileSize=UDim2.fromOffset(64,64),ZIndex=((previewRow.Holder or previewRow.ImageLabel).ZIndex or 1)+2},previewRow.Holder or previewRow.ImageLabel)
 updatePreview=function()
  if not enabled or v.mapMode~="Custom textures"then preview.Image=""return end
  local key=v.mapSurface or "Grass"local prefix="mapTexture"..key
  preview.Image=textures:GetImage(v[prefix.."Style"]or "Original",v[prefix.."Image"])
  preview.ImageColor3=v[prefix.."Tint"]and v[prefix.."Color"]or Color3.new(1,1,1)
 end
 visible=function()
  local custom=v.mapMode=="Custom textures"
  for _,key in ipairs(categories)do
   for _,suffix in ipairs({"Material","Tint","Color","ColorRainbow"})do
    local widget=c.Widgets["map"..key..suffix]if widget and widget.SetVisible then widget:SetVisible(not custom and v.mapSurface==key)end
   end
   for _,suffix in ipairs({"Style","Image","Scale","Tint","Color","ColorRainbow"})do
    local prefix="mapTexture"..key local widget=c.Widgets[prefix..suffix]
    if widget and widget.SetVisible then widget:SetVisible(custom and v.mapSurface==key and(suffix~="Image"or v[prefix.."Style"]=="Custom image"))end
   end
  end
  for _,entry in ipairs({{"mapPreset",not custom},{"mapTexturePreset",custom}})do local widget=c.Widgets[entry[1]]if widget and widget.SetVisible then widget:SetVisible(entry[2])end end
  if previewRow.SetVisible then previewRow:SetVisible(custom)end updatePreview()
 end
 c.Choice(panel,"mapMode","Map appearance mode",{"Classic materials","Custom textures"},"Classic materials",function()
  if v.mapMode~="Custom textures"then textures:Clear()end refresh()visible()
 end)
 local presets=c.LoadModule("MapPresets")local presetNames={}
 for _,entry in ipairs(presets)do presetNames[#presetNames+1]=entry[1]end
 c.Choice(panel,"mapPreset","Map palette",presetNames,"Obsidian",function()end)
 local themeNames={}for _,theme in ipairs(catalog.Themes)do themeNames[#themeNames+1]=theme.Name end
 c.Choice(panel,"mapTexturePreset","Texture theme",themeNames,catalog.Themes[1].Name,function()end,catalog.LegacyThemeAliases)
 c.Action(panel,"Apply map palette",function()
  if v.mapMode=="Custom textures"then
   for _,theme in ipairs(catalog.Themes)do if theme.Name==v.mapTexturePreset then
    for i,key in ipairs(categories)do
     local prefix="mapTexture"..key local hex=theme.Colors[i]
     c.Setters[prefix.."ColorRainbow"](false,true)c.Setters[prefix.."Style"](theme.Styles[i],true)
     c.Setters[prefix.."Scale"](theme.Scale,true)c.Setters[prefix.."Tint"](true,true)
     c.Setters[prefix.."Color"](Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16)),true)
    end
    c.Setters.mapAppearanceEnabled(true,true)break
   end end return
  end
  for _,entry in ipairs(presets)do if entry[1]==v.mapPreset then
   for i,key in ipairs(categories)do
    local hex=entry[3][i]local tint=Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16))
    c.Setters["map"..key.."ColorRainbow"](false,true)c.Setters["map"..key.."Material"](entry[2][i],true)
    c.Setters["map"..key.."Color"](tint,true)c.Setters["map"..key.."Tint"](true,true)
   end
   c.Setters.mapAppearanceEnabled(true,true)break
  end end
 end)
 c.Choice(panel,"mapSurface","Surface",categories,"Grass",visible)
 local choices={"Original","SmoothPlastic","Plastic","Neon","ForceField","Glass","Ice","Snow","Sand","Sandstone","Grass","LeafyGrass","Rock","Slate","Concrete","Brick","Cobblestone","Wood","WoodPlanks","Metal","Basalt","Marble","Granite","Ground","Mud"}
 for _,key in ipairs(categories)do
  local prefix="map"..key
  c.Choice(panel,prefix.."Material","Material",choices,"Original",function()refresh(key)end)
  c.Toggle(panel,prefix.."Tint","Override surface color",false,function()refresh(key)end)
  c.ColorOwners[prefix.."Color"]=prefix.."Tint"
  c.Color(panel,prefix.."Color","Surface color",Color3.new(1,1,1),function()refresh(key)end,function()refresh(key)end)
 end
 local styleNames={"Original","Custom image"}local sorted={}
 for name in pairs(catalog.Styles)do sorted[#sorted+1]=name end table.sort(sorted)for _,name in ipairs(sorted)do styleNames[#styleNames+1]=name end
 for _,key in ipairs(categories)do
  local prefix="mapTexture"..key
  local function changed()refresh(key)updatePreview()end
  c.Choice(panel,prefix.."Style","Texture",styleNames,"Original",function()changed()visible()end,catalog.LegacyStyleAliases)
  c.Field(panel,prefix.."Image","Image ID","",changed)
  c.Slider(panel,prefix.."Scale","Texture scale",1,64,12,1,changed)
  c.Toggle(panel,prefix.."Tint","Override texture color",false,changed)
  c.ColorOwners[prefix.."Color"]=prefix.."Tint"
  c.Color(panel,prefix.."Color","Texture color",Color3.new(1,1,1),changed,changed)
 end
 c.Action(panel,"Retry texture loading",function()textures:RetryFailed()end)
 c.Action(panel,"Reset map surfaces",function()
  for _,key in ipairs(categories)do c.Setters["mapTexture"..key.."ColorRainbow"](false,true)c.Setters["mapTexture"..key.."Tint"](false,true)c.Setters["mapTexture"..key.."Style"]("Original",true)c.Setters["map"..key.."Material"]("Original",true)c.Setters["map"..key.."Tint"](false,true)c.Setters["map"..key.."ColorRainbow"](false,true)end
 end)
 visible()
 local elapsed=0 local heartbeat=c.Run.Heartbeat:Connect(function(dt)if enabled then elapsed=elapsed+dt if elapsed>=1 then elapsed=0 attach()if v.mapMode=="Custom textures"then textures:Maintain()end end end end)
 local api={}
 function api:Destroy()if dead then return end dead=true enabled=false heartbeat:Disconnect()clear()textures:Destroy()end
 c.TrackCleanup(function()api:Destroy()end)
 return api
end
