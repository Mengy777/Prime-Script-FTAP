-- Local Minecraft presentation only. No remotes, grabbing, damage or input sinking.
return function(c)
 local v=c.Controls local me=c.Players.LocalPlayer
 local dead=false local screen,arm local phase,blend=0,0 local selected=1
 local slots={} local data local palette
 local function clear()
  c.Job("Minecraft presentation")
  if screen then screen:Destroy()screen=nil end
  if arm then arm:Destroy()arm=nil end
  slots={}phase=0 blend=0
  c.Unpatch("minecraftCamera")
 end
 local function pixels(parent,rows)
  local height,width=#rows,#rows[1]
  for y,row in ipairs(rows)do
   local x=1
   while x<=width do
    local value=row[x]local finish=x+1
    while finish<=width and row[finish]==value do finish=finish+1 end
    if value~=0 then c.Make("Frame",{BorderSizePixel=0,BackgroundColor3=palette[value],
     Position=UDim2.fromScale((x-1)/width,(y-1)/height),Size=UDim2.fromScale((finish-x)/width,1/height)},parent)end
    x=finish
   end
  end
 end
 local function build()
  if not data then
   data=c.LoadModule("MinecraftAssets")palette={}
   for i,rgb in ipairs(data.Palette)do palette[i]=Color3.fromRGB(math.floor(rgb/65536)%256,math.floor(rgb/256)%256,rgb%256)end
  end
  screen=c.Make("ScreenGui",{Name="PrimeMinecraft",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=20},c.PlayerGui)
  local bar=c.Make("Frame",{Name="Hotbar",AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-8),
   Size=UDim2.fromOffset(364,44),BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(24,24,24)},screen)
  local scale=c.Make("UIScale",{Scale=v.minecraftHotbarScale or 1},bar)
  for i=1,9 do
   local slot=c.Make("Frame",{Name="Slot"..i,Position=UDim2.fromOffset(2+(i-1)*40,2),Size=UDim2.fromOffset(40,40),
    BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(108,108,108)},bar)
   c.Make("Frame",{Position=UDim2.fromOffset(3,3),Size=UDim2.new(1,-6,1,-6),BorderSizePixel=0,
    BackgroundColor3=Color3.fromRGB(37,37,37),BackgroundTransparency=.25},slot)
   local border=c.Make("UIStroke",{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=2,
    Color=Color3.fromRGB(232,232,232),Enabled=i==selected},slot)
   slots[i]=border
   if i==9 then
    local icon=c.Make("Frame",{Name="DiamondSword",BackgroundTransparency=1,Position=UDim2.fromOffset(5,5),Size=UDim2.fromOffset(30,30)},slot)
    pixels(icon,data.Sword)
   end
  end
  arm=c.Make("Part",{Name="PrimeSteveArm",Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,
   Size=Vector3.new(.52,1.56,.52),Color=Color3.fromRGB(171,125,100),Material=Enum.Material.SmoothPlastic},c.Workspace)
  for face,rows in pairs(data.Arm)do
   local surface=c.Make("SurfaceGui",{Name=face,Face=Enum.NormalId[face],CanvasSize=Vector2.new(#rows[1]*16,#rows*16),
    LightInfluence=0,AlwaysOnTop=false},arm)
   pixels(surface,rows)
  end
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
   screen.Enabled=living~=nil and living~=false
   arm.Parent=visible and c.Workspace or nil
   local direction=humanoid and humanoid.MoveDirection
   local moving=visible and direction and direction.Magnitude>.05 and 1 or 0
   blend=blend+(moving-blend)*(1-math.exp(-12*math.min(dt,.1)))
   phase=phase+math.min(dt,.1)*8
   local amount=(v.minecraftBobbing or .7)*blend
   local fov=math.clamp(camera.FieldOfView,30,120)
   local projection=math.tan(math.rad(fov/2))/math.tan(math.rad(35))
   arm.Size=Vector3.new(.52*projection,1.56*projection,.52)
   arm.CFrame=camera.CFrame*CFrame.new((.78+math.sin(phase)*.035*amount)*projection,(-.77+math.cos(phase*2)*.035*amount)*projection,-1.12)
    *CFrame.Angles(math.rad(-18)+math.sin(phase)*.025*amount,math.rad(-20),math.rad(-8)+math.sin(phase)*.035*amount)
   scale.Scale=v.minecraftHotbarScale or 1
  end)
 end
 local group=c.Group("Favorites","Minecraft",1)
 c.Toggle(group,"minecraftEnabled","Minecraft mode",false,update)
 local panel=c.Panel("minecraftEnabled")
 c.Choice(panel,"minecraftMode","Mode",{"Interactive (test)"},"Interactive (test)",function()end)
 c.Slider(panel,"minecraftBobbing","Hand bobbing",0,1,.7,.05,function()end)
 c.Slider(panel,"minecraftHotbarScale","Hotbar size",.6,1.6,1,.05,function()if screen then update()end end)
 local numbers={One=1,Two=2,Three=3,Four=4,Five=5,Six=6,Seven=7,Eight=8,Nine=9}
 local input=c.Input.InputBegan:Connect(function(event,processed)
  local index=event.KeyCode and numbers[event.KeyCode.Name]
  if not index or dead or not v.minecraftEnabled or processed or c.MenuOpen()or c.Input:GetFocusedTextBox()then return end
  if index then selected=index for i,border in ipairs(slots)do border.Enabled=i==selected end end
 end)
 return {Destroy=function()if dead then return end dead=true input:Disconnect()clear()end}
end
