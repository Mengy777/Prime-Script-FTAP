-- Local map parts only. Cached classification never depends on our edited material.
return function(c)
 local v=c.Controls local root,dead,enabled=nil,false,false local parts,links,buckets={},{},{}
 local refresh
 local categories={"Snow","Sand","Grass","LushGrass","Rock","WasteGrass","Ocean","Dirt"}
 local names={}for _,name in ipairs(categories)do names[name:lower()]=name end
 local materials={Snow="Snow",Sand="Sand",Grass="Grass",LeafyGrass="LushGrass",Rock="Rock",Slate="Rock",Ground="Dirt",Mud="Dirt"}
 local function clear()
  for _,link in ipairs(links)do link:Disconnect()end links={}parts={}buckets={}root=nil c.Unpatch("mapMaterial")c.Unpatch("mapTint")
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
  local prefix="map"..key
  if v[prefix.."Material"]and v[prefix.."Material"]~="Original"then c.Patch("mapMaterial",o,"Material",Enum.Material[v[prefix.."Material"]])else c.Unpatch("mapMaterial",o)end
  if v[prefix.."Tint"]then c.Patch("mapTint",o,"Color",v[prefix.."Color"])else c.Unpatch("mapTint",o)end
 end
 local function forget(o)
  local key=parts[o]if key and buckets[key]then buckets[key][o]=nil end parts[o]=nil
  c.Unpatch("mapMaterial",o)c.Unpatch("mapTint",o)
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
 c.Toggle(g,"mapAppearanceEnabled","Map materials and colors",false,function(on)enabled=on if on then attach()else clear()end end)
 local panel=c.Panel("mapAppearanceEnabled")
 local visible
 visible=function()
  for _,key in ipairs(categories)do
   for _,suffix in ipairs({"Material","Tint","Color","ColorRainbow"})do
    local widget=c.Widgets["map"..key..suffix]if widget and widget.SetVisible then widget:SetVisible(v.mapSurface==key)end
   end
  end
 end
 local presets=c.LoadModule("MapPresets")local presetNames={}
 for _,entry in ipairs(presets)do presetNames[#presetNames+1]=entry[1]end
 c.Choice(panel,"mapPreset","Map palette",presetNames,"Obsidian",function()end)
 c.Action(panel,"Apply map palette",function()
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
 c.Action(panel,"Reset map surfaces",function()
  for _,key in ipairs(categories)do c.Setters["map"..key.."Material"]("Original",true)c.Setters["map"..key.."Tint"](false,true)c.Setters["map"..key.."ColorRainbow"](false,true)end
 end)
 visible()
 local elapsed=0 local heartbeat=c.Run.Heartbeat:Connect(function(dt)if enabled then elapsed=elapsed+dt if elapsed>=1 then elapsed=0 attach() end end end)
 local api={}
 function api:Destroy()if dead then return end dead=true enabled=false heartbeat:Disconnect()clear()end
 c.TrackCleanup(function()api:Destroy()end)
 return api
end
