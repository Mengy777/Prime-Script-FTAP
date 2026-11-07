-- Local Minecraft presentation. No remotes/damage; mode-scoped LMB sink blocks native grabbing.
return function(c)
 local v=c.Controls local me=c.Players.LocalPlayer
 local dead=false local screen,arm,sword,handView,handCamera local blend=0 local selected=1
 local age,swing,step,pitch=0,1,0,0
 local swordScale
 local lagPitch,lagYaw,lastCamera
 local crosshair
 local actions=game:GetService("ContextActionService")
 local attackAction="PrimeMinecraftAttack"
 local grabAction="PrimeMinecraftGrab"
 local throwing=false
 local forwarding=false local injectedDown=false local inputBackend local inputPoint local inputWarned=false
 local forwardedEvents={}
 local function forwardedEvent(state)
  while forwardedEvents[1]and forwardedEvents[1].expires<os.clock()do table.remove(forwardedEvents,1)end
  if forwardedEvents[1]and forwardedEvents[1].state==state then table.remove(forwardedEvents,1)return true end
  return forwarding
 end
 local function nativeButton(down)
  if down==injectedDown then return true end
  local camera=c.Workspace.CurrentCamera
  if down and not camera then return false end
  if camera then inputPoint=camera.ViewportSize/2 end
  local token={state=down and Enum.UserInputState.Begin or Enum.UserInputState.End,expires=os.clock()+.25}
  forwardedEvents[#forwardedEvents+1]=token
  forwarding=true
  local ok,err=pcall(function()
   if inputBackend=="executor"then
    local fn=down and mouse1press or mouse1release assert(type(fn)=="function","Mouse input unavailable")fn()
   else
    local point=inputPoint or Vector2.new(0,0)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(point.X,point.Y,0,down,game,0)
   end
  end)
  if not ok and not inputBackend and type(mouse1press)=="function"and type(mouse1release)=="function"then
   inputBackend="executor"ok,err=pcall(down and mouse1press or mouse1release)
  end
  forwarding=false
  if ok then injectedDown=down inputBackend=inputBackend or "native" return true end
  for i,event in ipairs(forwardedEvents)do if event==token then table.remove(forwardedEvents,i)break end end
  c.WarnOnce("Minecraft input",err)
  if not inputWarned then inputWarned=true c.Notify(c.Translate("Minecraft grab input is unavailable in this executor."))end return false
 end
 local selection local data local images local hearts={} local previousHealth
 local function clear()
  c.Job("Minecraft presentation")
  nativeButton(false)
  actions:UnbindAction(attackAction)
  actions:UnbindAction(grabAction)
  inputWarned=false forwardedEvents={}throwing=false
  c.Unpatch("minecraftCursor")
  if screen then screen:Destroy()screen=nil end
  if arm then arm:Destroy()arm=nil end
  if sword then sword:Destroy()sword=nil end
  swordScale=nil selection=nil crosshair=nil hearts={}previousHealth=nil handView=nil handCamera=nil blend=0 age=0 swing=1 step=0 pitch=0 lagPitch=nil lagYaw=nil lastCamera=nil
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
  crosshair=c.Make("ImageLabel",{Name="MinecraftCrosshair",BackgroundTransparency=1,AnchorPoint=Vector2.new(.5,.5),
   Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(30,30),Image=images.Crosshair,
   ResampleMode=Enum.ResamplerMode.Pixelated,ZIndex=5},screen)
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
  -- Independent camera prevents world FOV, world lighting and walls from distorting the hand.
  handView=c.Make("ViewportFrame",{Name="HandView",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
   Ambient=Color3.fromRGB(185,185,185),LightColor=Color3.fromRGB(85,85,85),LightDirection=Vector3.new(-.4,-1,-.6),
   Active=false,ZIndex=0},screen)
  handCamera=c.Make("Camera",{Name="HandCamera",CFrame=CFrame.new(),FieldOfView=70},handView)
  handView.CurrentCamera=handCamera
  arm=c.Make("Part",{Name="PrimeSteveArm",Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,
   CastShadow=false,Size=Vector3.new(.25,.75,.25),Color=Color3.new(1,1,1),Material=Enum.Material.SmoothPlastic},handView)
  for _,face in ipairs({"Front","Back","Right","Left","Top","Bottom"})do
   local target=face=="Top"and"Bottom"or face=="Bottom"and"Top"or face=="Right"and"Left"or face=="Left"and"Right"or face
   c.Make("Decal",{Name="Steve"..face,Face=Enum.NormalId[target],Texture=images["Arm"..face]},arm)
  end
  sword=c.Make("Model",{Name="PrimeDiamondSword"})
  for _,run in ipairs(data.SwordRuns)do
   c.Make("Part",{Name="TexelStrip",Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,
    Size=Vector3.new(run[3]/16,1/16,1/16),CFrame=CFrame.new((run[1]+run[3]/2)/16-.5,.5-(run[2]+.5)/16,0),
    Color=Color3.fromRGB(run[4],run[5],run[6]),Material=Enum.Material.SmoothPlastic},sword)
  end
  sword.WorldPivot=CFrame.new()
  return scale
 end
 local function overInterface()
  if c.MenuOpen()or c.Input:GetFocusedTextBox()then return true end
  if type(c.PlayerGui.GetGuiObjectsAtPosition)=="function"and type(c.Input.GetMouseLocation)=="function"then
   local pointer=c.Input:GetMouseLocation()
   for _,object in ipairs(c.PlayerGui:GetGuiObjectsAtPosition(pointer.X,pointer.Y))do
    if object:IsA("GuiButton")or object:IsA("TextBox")then return true end
   end
  end
  return false
 end
 local function holdingObject()
  for _,scope in ipairs(c.Workspace:GetChildren())do
   if scope.Name=="GrabParts"then
    local part=scope:FindFirstChild("GrabPart")
    local weld=part and part:FindFirstChild("WeldConstraint")
    if part and part:IsA("BasePart")and weld and weld:IsA("WeldConstraint")
     and weld.Enabled~=false and weld.Active~=false then
     local a,b=weld.Part0,weld.Part1 local target=a==part and b or b==part and a or nil
     if target and target~=part and target:IsA("BasePart")and target:IsDescendantOf(c.Workspace)then
      for _,beam in ipairs(scope:GetDescendants())do
       if beam:IsA("Beam")and beam.Enabled~=false and c.IsLocalGrabBeam(beam)then return true end
      end
     end
    end
   end
  end
  return false
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
  actions:BindActionAtPriority(attackAction,function(_,state)
   if forwardedEvent(state)or dead or not v.minecraftEnabled or overInterface()then return Enum.ContextActionResult.Pass end
   if state==Enum.UserInputState.Begin then if swing>=1 then swing=0 end end
   -- End passes through so an object held before enabling can still be released.
   if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then return Enum.ContextActionResult.Pass end
   return Enum.ContextActionResult.Sink
  end,false,10000,Enum.UserInputType.MouseButton1)
  actions:BindActionAtPriority(grabAction,function(_,state)
   -- Keep the complete native throw gesture intact after the constraint disappears.
   if throwing then
    if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then throwing=false end
    return Enum.ContextActionResult.Pass
   end
   if state==Enum.UserInputState.Begin and not dead and v.minecraftEnabled and not overInterface()
    and holdingObject()then throwing=true return Enum.ContextActionResult.Pass end
   if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then
    if injectedDown then nativeButton(false)return Enum.ContextActionResult.Sink end
    return Enum.ContextActionResult.Pass
   end
   if dead or not v.minecraftEnabled or overInterface()then return Enum.ContextActionResult.Pass end
   if state==Enum.UserInputState.Begin and not v.freeCameraEnabled and not v.spectateEnabled then
    local mouse=me:GetMouse()local target=mouse.Target
    if target and target:IsA("BasePart")and target:IsDescendantOf(c.Workspace)
     and not(me.Character and target:IsDescendantOf(me.Character))then nativeButton(true)end
   end
   return Enum.ContextActionResult.Sink
  end,false,10000,Enum.UserInputType.MouseButton2)


  c.Notify(c.Translate(wasThird and "Third-person disabled. Minecraft mode enabled."or"Minecraft mode enabled."))
  c.Job("Minecraft presentation",c.Run.RenderStepped,function(dt)
   if dead or not v.minecraftEnabled or not arm then return end
   local camera=c.Workspace.CurrentCamera if not camera then return end
   local character=me.Character local humanoid=character and character:FindFirstChildOfClass("Humanoid")
   local living=humanoid and humanoid.Health>0
   local visible=living and not v.freeCameraEnabled and not v.spectateEnabled
   if not visible and injectedDown then nativeButton(false)end
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
   handView.Visible=visible==true
   local pointer=c.MenuOpen()or c.Input.MouseBehavior~=Enum.MouseBehavior.LockCenter
   crosshair.Visible=visible==true and not pointer
   if pointer then c.Unpatch("minecraftCursor",c.Input)else c.Patch("minecraftCursor",c.Input,"MouseIconEnabled",false)end
   local nativeCross=c.PlayerGui:FindFirstChild("Crosshairs")
   if nativeCross and nativeCross:IsA("ScreenGui")then c.Patch("minecraftCursor",nativeCross,"Enabled",false)end

   local direction=humanoid and humanoid.MoveDirection
   local moving=visible and direction and direction.Magnitude>.05 and 1 or 0
   blend=blend+(moving-blend)*(1-math.exp(-12*math.min(dt,.1)))
   local delta=math.min(dt,.1)
   age=age+delta swing=math.min(1,swing+delta/.35)
   -- Minecraft's distance-based view bob; standing still freezes walking phase.
   local root=character and character:FindFirstChild("HumanoidRootPart")
   local velocity=root and root.AssemblyLinearVelocity
   local speed=velocity and math.sqrt(velocity.X^2+velocity.Z^2)or moving*16
   -- One gentle walking cycle per ~1.33 seconds at standard WalkSpeed16.
   step=step+math.min(speed,24)*delta/10.6666667
   local amount=(v.minecraftBobbing or .7)*blend*.1
   local walk=-step*math.pi
   local targetPitch=velocity and math.clamp(-velocity.Y*.35,-10,10)or 0
   pitch=pitch+(targetPitch-pitch)*(1-math.exp(-10*delta))
   local bob=CFrame.new(math.sin(walk)*amount*.5,-math.abs(math.cos(walk))*amount,0)
    *CFrame.Angles(0,0,math.rad(math.sin(walk)*amount*3))
    *CFrame.Angles(math.rad(math.abs(math.cos(walk-.2)*amount)*5+pitch),0,0)
   local attack=math.sin(math.sqrt(swing)*math.pi)
   local attackTwist=math.sin(swing*swing*math.pi)
   local equip=math.max(0,1-age/.25)
   -- Minecraft Java ItemRenderer.renderPlayerArm, transform order preserved.
   local pose=CFrame.new(-.3*attack,.4*math.sin(math.sqrt(swing)*math.pi*2),-.4*math.sin(swing*math.pi))
    *CFrame.new(.64000005,-.6-equip*.6,-.71999997)
    *CFrame.Angles(0,math.rad(45),0)
    *CFrame.Angles(0,math.rad(attack*70),0)
    *CFrame.Angles(0,0,math.rad(attackTwist*-20))
    *CFrame.new(-1,3.6,3.5)
    *CFrame.Angles(0,0,math.rad(120))
    *CFrame.Angles(math.rad(200),0,0)
    *CFrame.Angles(0,math.rad(-135),0)
    *CFrame.new(5.6,0,0)
    *CFrame.new(-5/16,2/16,0)
    *CFrame.Angles(math.sin(age*.067)*.05,0,math.cos(age*.09)*.05+.05)
    *CFrame.new(-1/16,4/16,0)
   -- Minecraft rotateWithPlayerRotations: small lag behind camera pitch/yaw.
   local look=camera.CFrame.LookVector
   local lookPitch=math.asin(math.clamp(look.Y,-1,1))
   local lookYaw=math.atan2(-look.X,-look.Z)
   if lastCamera~=camera then lagPitch=lookPitch lagYaw=lookYaw lastCamera=camera end
   local yawGap=math.atan2(math.sin(lookYaw-lagYaw),math.cos(lookYaw-lagYaw))
   local catchup=1-math.exp(-14*delta)
   lagPitch=lagPitch+(lookPitch-lagPitch)*catchup lagYaw=lagYaw+yawGap*catchup
   local lookLag=CFrame.Angles((lookPitch-lagPitch)*.1,0,0)
    *CFrame.Angles(0,math.atan2(math.sin(lookYaw-lagYaw),math.cos(lookYaw-lagYaw))*.1,0)
   local handScale=(v.minecraftHandScale or .7)/.7
   arm.Size=Vector3.new(.25,.75,.25)*handScale
   -- Offset zoom only for explicit hand-size setting, never the world camera FOV.
   local equipped=selected==9
   arm.Parent=not equipped and handView or nil
   sword.Parent=equipped and handView or nil
   arm.CFrame=bob*lookLag*pose
   if equipped then
    local desiredScale=.68*handScale
    if desiredScale~=swordScale then sword:ScaleTo(desiredScale)swordScale=desiredScale end
    -- Java handheld item transform + original handheld.json right-hand display pose.
    local item=CFrame.new(-.4*attack,.2*math.sin(math.sqrt(swing)*math.pi*2),-.2*math.sin(swing*math.pi))
     *CFrame.new(.56,-.52-equip*.6,-.71999997)
     *CFrame.Angles(0,math.rad(45-attackTwist*20),0)
     *CFrame.Angles(0,0,math.rad(attack*-20))
     *CFrame.Angles(math.rad(attack*-80),0,0)
     *CFrame.new(1.13/16,3.2/16,1.13/16)
     *CFrame.Angles(0,math.rad(-90),math.rad(25))
    sword:PivotTo(bob*lookLag*item)
   end
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
  if index and selected~=index then selected=index age=0 swing=1 if selection then selection.Position=UDim2.fromOffset((selected-1)*40-2,-2)end end
 end)
 local focus=c.Input.WindowFocusReleased:Connect(function()throwing=false nativeButton(false)end)
 return {Destroy=function()if dead then return end dead=true input:Disconnect()focus:Disconnect()clear()end}
end
