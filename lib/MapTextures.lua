-- Local MaterialVariant library. Does not change part material, physics or global overrides.
return function(c)
 local api={}local dead=false local records,variants,assets={},{},{}
 local prefix="PVMap_"..tostring({}):gsub("%W","").."_"local warned=false
 local function uri(value)return value and value~=""and("rbxassetid://"..value)or""end
 local function warning(message)
  if c.Warn then c.Warn("Map textures",message)end
  if not warned and c.Notify then warned=true c.Notify(c.Translate("Some custom images could not load; Roblox texture fallbacks are active."))end
 end
 local function localImage(style)
  if not style.File then return uri(style.ColorMap)end
  local item=assets[style.File]
  if item then return item.URI or uri(style.ColorMap)end
  item={}assets[style.File]=item
  task.spawn(function()
   local ok,message=pcall(function()
    local getAsset=getcustomasset or getsynasset
    assert(type(getAsset)=="function"and type(readfile)=="function"and type(writefile)=="function"and type(isfolder)=="function"and type(makefolder)=="function","Custom asset file API unavailable")
    local path="PrimeVisuals/Assets/map-"..style.File
    local function valid(data)return type(data)=="string"and #data==style.Bytes and data:sub(1,8)=="\137PNG\r\n\26\n"end
    local cached,data=pcall(readfile,path)
    if not cached or not valid(data)then
     local lastError
     for attempt=1,2 do
      if dead then return end
      local fetched,body=pcall(game.HttpGet,game,c.AssetBase..style.File..(attempt>1 and "?retry=2"or""))
      data=fetched and body or nil lastError=body
      if not valid(data)then
       local requestAPI=request or http_request or(type(syn)=="table"and syn.request)
       if type(requestAPI)=="function"then
        local sent,response=pcall(requestAPI,{Url=c.AssetBase..style.File,Method="GET"})
        if sent and response and response.StatusCode==200 then data=response.Body end
       end
      end
      if valid(data)then break end
     end
     assert(valid(data),"Invalid texture PNG: "..style.File.." / "..tostring(lastError))
     if dead then return end
     for _,directory in ipairs({"PrimeVisuals","PrimeVisuals/Assets"})do if not isfolder(directory)then makefolder(directory)end end
     writefile(path,data)assert(valid(readfile(path)),"Texture cache verification failed")
    end
    if dead then return end
    item.URI=getAsset(path)assert(type(item.URI)=="string"and item.URI~="","Invalid custom asset URI")
    api:RefreshAssets()
   end)
   if not ok and not dead then warning(tostring(message))end
  end)
  return item.URI or uri(style.ColorMap)
 end
 local function updateVariant(entry)
  local style=entry.style
  local color=entry.custom or localImage(style)
  local properties={BaseMaterial=entry.base,ColorMap=color,NormalMap=uri(style.NormalMap),RoughnessMap=uri(style.RoughnessMap),MetalnessMap=uri(style.MetalnessMap),StudsPerTile=entry.scale}
  if not entry.object or not entry.object.Parent then
   entry.object=Instance.new("MaterialVariant")entry.object.Name=entry.name
  end
  for key,value in pairs(properties)do if entry.object[key]~=value then entry.object[key]=value end end
  if entry.object.Parent~=c.MaterialService then entry.object.Parent=c.MaterialService end
 end
 function api:RefreshAssets()if dead then return end for _,entry in pairs(variants)do updateVariant(entry)end if c.OnReady then c.OnReady()end end
 function api:Remove(part)
  local entry=records[part]if not entry then return end records[part]=nil
  if entry.link then entry.link:Disconnect()end
  c.Unpatch("mapTexture",part)
  for object in pairs(entry.hidden)do c.Unpatch("mapTexture",object)end
 end
 function api:Clear()
  for part in pairs(records)do self:Remove(part)end
  for _,entry in pairs(variants)do if entry.object then entry.object:Destroy()end end variants={}
 end
 function api:Apply(part,key,styleName,scale,custom)
  if dead or styleName=="Original"then self:Remove(part)return end
  local style=c.Catalog.Styles[styleName]
  if styleName=="Custom image"then if not custom or custom==""then self:Remove(part)return end style={}end
  if not style then self:Remove(part)return end
  local base=part.Material local baseName=base and base.Name or"SmoothPlastic"
  local variantKey=key.."_"..baseName
  local entry=variants[variantKey]or{name=prefix..variantKey}variants[variantKey]=entry
  entry.style=style entry.base=base entry.scale=scale entry.custom=styleName=="Custom image"and c.ImageId(custom)or nil
  local ok,message=pcall(updateVariant,entry)
  if not ok then self:Remove(part)warning(tostring(message))return end
  local record=records[part]
  if not record then
   record={hidden={}}records[part]=record
   local function hide(object)
    if records[part]~=record or record.hidden[object]then return end
    if object:IsA("SurfaceAppearance")then record.hidden[object]=true c.Patch("mapTexture",object,"Parent",nil)
    elseif object:IsA("Decal")or object:IsA("Texture")then record.hidden[object]=true c.Patch("mapTexture",object,"Transparency",1)end
   end
   record.link=part.ChildAdded:Connect(hide)
   for _,object in ipairs(part:GetChildren())do hide(object)end
   if part:IsA("MeshPart")then c.Patch("mapTexture",part,"TextureID","")end
  end
  c.Patch("mapTexture",part,"MaterialVariant",entry.name)
 end
 function api:GetImage(styleName,custom)
  if styleName=="Custom image"then return custom and custom~=""and c.ImageId(custom)or""end
  local style=c.Catalog.Styles[styleName]return style and localImage(style)or""
 end
 function api:Maintain()
  if dead then return end
  for _,entry in pairs(variants)do if not entry.object or not entry.object.Parent then local ok,message=pcall(updateVariant,entry)if not ok then warning(tostring(message))end end end
 end
 function api:Destroy()if dead then return end dead=true self:Clear()end
 return api
end
