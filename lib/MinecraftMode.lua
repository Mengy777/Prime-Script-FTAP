-- Local Minecraft presentation only. No remotes, grabbing, damage or input sinking.
return function(c)
 local v=c.Controls local me=c.Players.LocalPlayer
 local dead=false local screen,arm local phase,blend=0,0 local selected=1
 local selection local data local images local hearts={} local previousHealth
 local function clear()
  c.Job("Minecraft presentation")
  if screen then screen:Destroy()screen=nil end
  if arm then arm:Destroy()arm=nil end
  selection=nil hearts={}previousHealth=nil phase=0 blend=0
  c.Unpatch("minecraftCamera")
 end
 local function loadImages()
  if images then return end
  data=data or c.LoadModule("MinecraftAssets")
  local getAsset=getcustomasset or getsynasset
  assert(type(getAsset)=="function","Minecraft textures require executor local image support")
  assert(type(writefile)=="function" and type(readfile)=="function" and type(isfolder)=="function" and type(makefolder)=="function","Minecraft texture cache is unavailable")
  for _,path in ipairs({"PrimeVisuals","PrimeVisuals/Assets","PrimeVisuals/Assets/Minecraft"})do if not isfolder(path)then makefolder(path)end end
  local loaded={}
  local version=c.MinecraftAssetRoot:match("tags/v([^/]+)/") or "test"
  for key,file in pairs(data.Files)do
   local path="PrimeVisuals/Assets/Minecraft/"..version.."-"..file.Name
   local function valid(bytes)return type(bytes)=="string"and #bytes==file.Bytes and bytes:sub(1,8)==string.char(137,80,78,71,13,10,26,10)end
   local ok,bytes=pcall(readfile,path)
   if not ok or not valid(bytes)then
    bytes=game:HttpGet(c.MinecraftAssetRoot..file.Name)
    assert(valid(bytes),"Invalid Minecraft texture: "..file.Name)
    writefile(path,bytes)
   end
   local uri=getAsset(path)assert(type(uri)=="string"and #uri>0,"Minecraft local image failed: "..file.Name)
   loaded[key]=uri
  end
  images=loaded
 end
 local function build()
  screen=c.Make("ScreenGui",{Name="PrimeMinecraft",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=20},c.PlayerGui)
  local bar=c.Make("ImageLabel",{Name="Hotbar",AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,0),
   Size=UDim2.fromOffset(364,44),BackgroundTransparency=1,Image=images.Hotbar,ResampleMode=Enum.ResamplerMode.Pixelated},screen)
  local scale=c.Make("UIScale",{Scale=v.minecraftHotbarScale or 1},bar)
  c.Make("ImageLabel",{Name="Experience",BackgroundTransparency=1,Position=UDim2.fromOffset(0,-14),Size=UDim2.fromOffset(364,10),
   Image=images.Experience,ResampleMode=Enum.ResamplerMode.Pixelated},bar)
  for i=1,10 do
   local heart=c.Make("ImageLabel",{Name="Heart"..i,BackgroundTransparency=1,Position=UDim2.fromOffset((i-1)*16,-40),Size=UDim2.fromOffset(18,18),
    Image=images.HeartEmpty,ResampleMode=Enum.ResamplerMode.Pixelated},bar)
   hearts[i]=c.Make("ImageLabel",{Name="Fill",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),
    Image=images.HeartFull,ResampleMode=Enum.ResamplerMode.Pixelated},heart)
   local food=c.Make("ImageLabel",{Name="Food"..i,BackgroundTransparency=1,Position=UDim2.fromOffset(202+(i-1)*16,-40),Size=UDim2.fromOffset(18,18),
    Image=images.FoodEmpty,ResampleMode=Enum.ResamplerMode.Pixelated},bar)
   c.Make("ImageLabel",{Name="Fill",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Image=images.FoodFull,ResampleMode=Enum.ResamplerMode.Pixelated},food)
  end

  for i=1,9 do
   local slot=c.Make("Frame",{Name="Slot"..i,Position=UDim2.fromOffset(2+(i-1)*40,2),Size=UDim2.fromOffset(40,40),BackgroundTransparency=1},bar)
   if i==9 then c.Make("ImageLabel",{Name="DiamondSword",BackgroundTransparency=1,Position=UDim2.fromOffset(4,4),
    Size=UDim2.fromOffset(32,32),Image=images.Sword,ResampleMode=Enum.ResamplerMode.Pixelated,ZIndex=2},slot)end
  end
  selection=c.Make("ImageLabel",{Name="Selection",BackgroundTransparency=1,Position=UDim2.fromOffset((selected-1)*40-2,-2),
   Size=UDim2.fromOffset(48,46),Image=images.Selection,ResampleMode=Enum.ResamplerMode.Pixelated,ZIndex=3},bar)
  arm=c.Make("ImageLabel",{Name="PrimeSteveArm",BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),
   Position=UDim2.new(1,0,1,0),Size=UDim2.fromOffset(320,320),Image=images.Hand,
   ResampleMode=Enum.ResamplerMode.Pixelated,ScaleType=Enum.ScaleType.Fit,ZIndex=0},screen)
  return scale
 end
 local function update()
  if dead then return end
  if not v.minecraftEnabled then
   local wasActive=screen~=nil
   clear()
   if wasActive then c.Notify(c.Translate("Minecraft mode disabled."))end
   return
  end
  loadImages()
  local wasThird=v.camThird==true
  if c.Setters.camThird then c.Setters.camThird(false,true)end
  c.Patch("minecraftCamera",me,"CameraMode",Enum.CameraMode.LockFirstPerson)
  c.Patch("minecraftCamera",me,"CameraMinZoomDistance",.5)
  c.Patch("minecraftCamera",me,"CameraMaxZoomDistance",.5)
  if screen then return end
  local scale=build()
  c.Notify(c.Translate(wasThird and "Third-person disabled. Minecraft mode enabled."or"Minecraft mode enabled."))
  c.Job("Minecraft presentation",c.Run.RenderStepped,function(dt)
   if dead or not v.minecraftEnabled or not arm then return end
   local camera=c.Workspace.CurrentCamera if not camera then return end
   local character=me.Character local humanoid=character and character:FindFirstChildOfClass("Humanoid")
   local living=humanoid and humanoid.Health>0
   local visible=living and not v.freeCameraEnabled and not v.spectateEnabled
   screen.Enabled=humanoid~=nil
   local health=humanoid and math.clamp(humanoid.Health/math.max(humanoid.MaxHealth or 100,1),0,1)or 0
   local units=health>0 and math.ceil(health*20-1e-6)or 0
   if units~=previousHealth then
    previousHealth=units
    for i,fill in ipairs(hearts)do
     local value=units-(i-1)*2
     fill.Visible=value>0
     fill.Image=value>=2 and images.HeartFull or images.HeartHalf
    end
   end
   arm.Visible=visible==true
   local direction=humanoid and humanoid.MoveDirection
   local moving=visible and direction and direction.Magnitude>.05 and 1 or 0
   blend=blend+(moving-blend)*(1-math.exp(-12*math.min(dt,.1)))
   phase=phase+math.min(dt,.1)*8
   local amount=(v.minecraftBobbing or .7)*blend
   -- Screen-space reference sprite: camera FOV never changes pose or proportions.
   local viewport=camera.ViewportSize
   local height=math.max(1,viewport.Y)
   local pixels=height*.31*((v.minecraftHandScale or .7)/.7)
   arm.Size=UDim2.fromOffset(pixels,pixels)
   arm.Position=UDim2.new(1,math.sin(phase)*height*.003*amount,1,math.cos(phase*2)*height*.003*amount)
   scale.Scale=v.minecraftHotbarScale or 1
  end)
 end
 local group=c.Group("Favorites","Minecraft",1)
 c.Toggle(group,"minecraftEnabled","Minecraft mode",false,update)
 local panel=c.Panel("minecraftEnabled")
 c.Choice(panel,"minecraftMode","Mode",{"Interactive (test)"},"Interactive (test)",function()end)
 c.Slider(panel,"minecraftHandScale","Hand size",.45,1.1,.7,.05,function()end)
 c.Slider(panel,"minecraftBobbing","Hand bobbing",0,1,.7,.05,function()end)
 c.Slider(panel,"minecraftHotbarScale","Hotbar size",.6,1.6,1,.05,function()if screen then update()end end)
 local numbers={One=1,Two=2,Three=3,Four=4,Five=5,Six=6,Seven=7,Eight=8,Nine=9}
 local input=c.Input.InputBegan:Connect(function(event,processed)
  local index=event.KeyCode and numbers[event.KeyCode.Name]
  if not index or dead or not v.minecraftEnabled or processed or c.MenuOpen()or c.Input:GetFocusedTextBox()then return end
  if index then selected=index if selection then selection.Position=UDim2.fromOffset((selected-1)*40-2,-2)end end
 end)
 return {Destroy=function()if dead then return end dead=true input:Disconnect()clear()end}
end
