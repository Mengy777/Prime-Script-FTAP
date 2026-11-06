-- Downloaded multi-map PBR materials. No stock/procedural image substitutions.
return function(c)
 local api={}local dead=false local records,variants,assets={},{},{}
 local queue,head,workers={},1,0 local readyQueued=false local warned=false
 local prefix="PVMap_"..tostring({}):gsub("%W","").."_"
 local function warning(message)
  if c.Warn then c.Warn("Map PBR",message)end
  if not warned and c.Notify then warned=true c.Notify(c.Translate("PBR images could not load. Original surfaces are kept; check executor file support or retry loading."))end
 end
 local function signalReady()
  if readyQueued or dead then return end readyQueued=true
  task.defer(function()
   readyQueued=false if dead then return end
   api:RefreshAssets()if c.OnReady then c.OnReady()end
  end)
 end
 local function valid(data,descriptor)
  if type(data)~="string"or #data~=descriptor.Bytes then return false end
  if descriptor.File:match("%.png$")then return data:sub(1,8)=="\137PNG\r\n\26\n"end
  return data:sub(1,3)==string.char(255,216,255)
 end
 local function fetch(descriptor,item)
  local ok,message=pcall(function()
   local getAsset=getcustomasset or getsynasset
   assert(type(getAsset)=="function"and type(readfile)=="function"and type(writefile)=="function"and type(isfolder)=="function"and type(makefolder)=="function","Custom asset file API unavailable")
   local path="PrimeVisuals/Assets/pbr-"..descriptor.File
   local cached,data=pcall(readfile,path)
   if not cached or not valid(data,descriptor)then
    for attempt=1,2 do
     if dead then return end
     local got,body=pcall(game.HttpGet,game,c.AssetBase..descriptor.File..(attempt>1 and "?retry=2"or""))
     data=got and body or nil
     if not valid(data,descriptor)then
      local requestAPI=request or http_request or(type(syn)=="table"and syn.request)
      if type(requestAPI)=="function"then
       local sent,response=pcall(requestAPI,{Url=c.AssetBase..descriptor.File,Method="GET"})
       if sent and response and response.StatusCode==200 then data=response.Body end
      end
     end
     if valid(data,descriptor)then break end
    end
    assert(valid(data,descriptor),"Invalid PBR image: "..descriptor.File)
    if dead then return end
    for _,folder in ipairs({"PrimeVisuals","PrimeVisuals/Assets"})do if not isfolder(folder)then makefolder(folder)end end
    writefile(path,data)assert(valid(readfile(path),descriptor),"PBR cache verification failed")
   end
   if dead then return end
   local uri=getAsset(path)assert(type(uri)=="string"and uri~="","Invalid local PBR URI")
   item.URI=uri
  end)
  item.Done=true
  if not ok and not dead then item.Failed=true warning(tostring(message))end
  if not dead then signalReady()end
 end
 local function pump()
  while not dead and workers<3 and head<=#queue do
   workers=workers+1
   task.spawn(function()
    while not dead and head<=#queue do local work=queue[head]head=head+1 fetch(work.descriptor,work.item)end
    workers=workers-1
    if workers==0 and head>#queue then queue={}head=1 end
   end)
  end
 end
 local function image(descriptor)
  if not descriptor then return ""end
  local item=assets[descriptor.File]
  if not item then
   item={}assets[descriptor.File]=item queue[#queue+1]={descriptor=descriptor,item=item}pump()
  end
  return item.URI
 end
 local function updateVariant(entry)
  local maps={}local ready=true
  if entry.custom then maps.ColorMap=entry.custom maps.NormalMap=""maps.RoughnessMap=""maps.MetalnessMap=""
  else
   for _,property in ipairs({"ColorMap","NormalMap","RoughnessMap","MetalnessMap"})do
    local descriptor=entry.style.Maps[property]
    maps[property]=image(descriptor)
    if descriptor and not maps[property]then ready=false end
   end
  end
  entry.ready=ready if not ready then return false end
  if not entry.object or not entry.object.Parent then entry.object=Instance.new("MaterialVariant")entry.object.Name=entry.name end
  maps.BaseMaterial=entry.base maps.StudsPerTile=entry.scale
  for key,value in pairs(maps)do if entry.object[key]~=value then entry.object[key]=value end end
  if entry.object.Parent~=c.MaterialService then entry.object.Parent=c.MaterialService end
  return true
 end
 function api:RefreshAssets()
  if dead then return end
  for _,entry in pairs(variants)do local ok,message=pcall(updateVariant,entry)if not ok then warning(tostring(message))end end
 end
 function api:Remove(part)
  local record=records[part]if not record then return end records[part]=nil
  if record.link then record.link:Disconnect()end c.Unpatch("mapTexture",part)
  for object in pairs(record.hidden)do c.Unpatch("mapTexture",object)end
 end
 function api:Clear()
  for part in pairs(records)do self:Remove(part)end
  for _,entry in pairs(variants)do if entry.object then entry.object:Destroy()end end variants={}
 end
 function api:Apply(part,key,styleName,scale,custom)
  if dead or styleName=="Original"then self:Remove(part)return false end
  local style=c.Catalog.Styles[styleName]
  if styleName=="Custom image"then if not custom or custom==""then self:Remove(part)return false end style={Maps={}}end
  if not style then self:Remove(part)return false end
  local base=part.Material local baseName=base and base.Name or"SmoothPlastic"
  local variantKey=key.."_"..baseName
  local entry=variants[variantKey]or{name=prefix..variantKey}variants[variantKey]=entry
  entry.style=style entry.base=base entry.scale=scale entry.custom=styleName=="Custom image"and c.ImageId(custom)or nil
  local ok,ready=pcall(updateVariant,entry)
  if not ok then self:Remove(part)warning(tostring(ready))return false end
  if not ready then self:Remove(part)return false end
  local record=records[part]
  if not record then
   record={hidden={}}records[part]=record
   local function hide(object)
    if records[part]~=record or record.hidden[object]then return false end
    if object:IsA("SurfaceAppearance")then record.hidden[object]=true c.Patch("mapTexture",object,"Parent",nil)
    elseif object:IsA("Decal")or object:IsA("Texture")then record.hidden[object]=true c.Patch("mapTexture",object,"Transparency",1)end
   end
   record.link=part.ChildAdded:Connect(hide)
   for _,object in ipairs(part:GetChildren())do hide(object)end
   if part:IsA("MeshPart")then c.Patch("mapTexture",part,"TextureID","")end
  end
  c.Patch("mapTexture",part,"MaterialVariant",entry.name)
  return true
 end
 function api:GetImage(styleName,custom)
  if styleName=="Custom image"then return custom and custom~=""and c.ImageId(custom)or""end
  local style=c.Catalog.Styles[styleName]return style and image(style.Maps.ColorMap)or""
 end
 function api:RetryFailed()
  for file,item in pairs(assets)do if item.Failed then assets[file]=nil end end warned=false
  self:RefreshAssets()if c.OnReady then c.OnReady()end
 end
 function api:Maintain()
  if dead then return end
  for _,entry in pairs(variants)do if not entry.object or not entry.object.Parent then local ok,message=pcall(updateVariant,entry)if not ok then warning(tostring(message))end end end
 end
 function api:Destroy()if dead then return end dead=true queue={}self:Clear()end
 -- Remove only the eight rejected generated cache files, when the executor supports deletion.
 if type(isfile)=="function"and type(delfile)=="function"then
  for _,name in ipairs({"candy","checker","circuit","clouds","grid","hex","rose","stars"})do
   local path="PrimeVisuals/Assets/map-"..name..".png"local ok,present=pcall(isfile,path)if ok and present then pcall(delfile,path)end
  end
 end
 return api
end
