-- Local solid block carrying the ORIGINAL live UI tree. No cloned controls or beam.
return function(c)
 local lib,v=c.Library,c.Controls local api={} local shown,dead=false,false
 local block,surface local saved={} local links={} local mountLinks={} local pending
 local oldPointer,oldPhysical,oldCantDrag
 local watched={} local enforcing=false
 local action="PrimePhysicalMenuGuard" local captured={}
 local beginDrag,finish
 local epoch=0
 local function make(class,props,parent)return c.Make(class,props,parent)end
 local function rayHit()
  local camera=c.Workspace.CurrentCamera if not camera or not block then return end
  local from,direction=camera.CFrame.Position,camera.CFrame.LookVector
  if c.Input.GetMouseLocation and camera.ScreenPointToRay then
   local p=c.Input:GetMouseLocation() local r=camera:ScreenPointToRay(p.X,p.Y)from=r.Origin direction=r.Direction
  end
  local params=RaycastParams.new()params.FilterType=Enum.RaycastFilterType.Exclude
  local char=c.Players.LocalPlayer.Character params.FilterDescendantsInstances=char and {char}or{}
  local hit=c.Workspace:Raycast(from,direction*100,params)
  if hit and hit.Instance==block then return hit.Position,from,direction end
 end
 function api:Pointer()
  local position=rayHit() if not position then return end
  local p=block.CFrame:PointToObjectSpace(position)
  if p.Z>-.01 then return end
  return Vector2.new((.5-p.X/block.Size.X)*surface.CanvasSize.X,(.5-p.Y/block.Size.Y)*surface.CanvasSize.Y)
 end
 -- World queries exclude our avatar/UI body, but respect solid map geometry.
 local function worldParams(overlap)
  local params=overlap and OverlapParams.new()or RaycastParams.new()
  params.FilterType=Enum.RaycastFilterType.Exclude
  local char=c.Players.LocalPlayer.Character
  params.FilterDescendantsInstances=char and {char,block}or{block}
  params.RespectCanCollide=true
  return params
 end
 local function fits(cf,size)
  return #c.Workspace:GetPartBoundsInBox(cf,size-Vector3.new(.06,.06,.06),worldParams(true))==0
 end
 local function groundPlacement(camera,size)
  local look=camera.CFrame.LookVector local flat=Vector3.new(look.X,0,look.Z)
  if flat.Magnitude<.01 then flat=Vector3.new(0,0,-1)else flat=flat.Unit end
  local origin=camera.CFrame.Position
  for distance=(v.worldMenuDistance or 9),5,-1 do
   local center=origin+flat*distance
   local hit=c.Workspace:Raycast(center+Vector3.new(0,32,0),Vector3.new(0,-288,0),worldParams(false))
   if hit and hit.Normal.Y>.65 then
    local pos=Vector3.new(center.X,hit.Position.Y+size.Y/2+.06,center.Z)
    local cf=CFrame.lookAt(pos,pos-flat)
    local obstruction=c.Workspace:Raycast(origin,pos-origin,worldParams(false))
    if not obstruction and fits(cf,size)then return cf end
   end
  end
  error("No clear ground for physical menu")
 end
 local function moveBody(target)
  local delta=target.Position-block.CFrame.Position
  if delta.Magnitude<.001 then return end
  local hit=c.Workspace:Blockcast(block.CFrame,block.Size-Vector3.new(.04,.04,.04),delta,worldParams(false))
  if hit then
   target=CFrame.new(block.CFrame.Position+delta.Unit*math.max(0,hit.Distance-.04))*(block.CFrame-block.CFrame.Position)
  end
  if fits(target,block.Size)then block.CFrame=target end
 end
 local function opaque(o)
  if not o:IsA("GuiObject") or watched[o] then return end watched[o]=true
  if type(o.BackgroundTransparency)=="number" and o.BackgroundTransparency<1 then c.Patch("physicalMenuUI",o,"BackgroundTransparency",0)end
  mountLinks[#mountLinks+1]=o:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
   if shown and not enforcing and o.Parent and type(o.BackgroundTransparency)=="number" and o.BackgroundTransparency<1 then
    enforcing=true c.Patch("physicalMenuUI",o,"BackgroundTransparency",0) enforcing=false
   end
  end)
 end
 local function restore()
  epoch=epoch+1 pending=nil
  if not next(captured) then c.Actions:UnbindAction(action)end
  for _,link in ipairs(mountLinks)do link:Disconnect()end mountLinks={}
  -- Restore native controls before destroying their temporary GUI parent.
  for _,item in ipairs(saved)do
   if item.object.Parent then item.object.Parent=item.parent end
  end
  c.Unpatch("physicalMenuUI")c.Unpatch("physicalMenuDrag")c.Unpatch("physicalMenuCursor")
  saved={} watched={}
  lib.PointerProvider=oldPointer lib.PhysicalGui=oldPhysical lib.CantDragForced=oldCantDrag lib.PhysicalDragging=false
  if surface then surface:Destroy()end if block then block:Destroy()end
  surface=nil block=nil
  if c.RestoreMenuStyle then c.RestoreMenuStyle()end
 end
 function api:IsVisible()return shown and block~=nil and block.Parent~=nil and surface~=nil and surface.Parent~=nil and c.Main.Parent~=nil end
 function api:SetVisible(on)
  if dead then return end
  if shown or block or surface then
   pcall(c.NativeToggle,lib,false) shown=false restore()
  end
  if not on then return end
  local ok,message=xpcall(function()
  local camera=c.Workspace.CurrentCamera assert(camera,"Camera unavailable")
  -- Disable fading BEFORE closing: otherwise native Toggle(true) can be
  -- rejected by its in-flight Fading guard, leaving a visible but inactive UI.
  if lib.Animations then c.Patch("physicalMenuUI",lib.Animations,"ToggleWindow",false)end
  c.NativeToggle(lib,false)
  oldPointer,oldPhysical,oldCantDrag=lib.PointerProvider,lib.PhysicalGui,lib.CantDragForced
  local width=math.max(1,math.ceil(c.Main.AbsoluteSize.X))local height=math.max(1,math.ceil(c.Main.AbsoluteSize.Y))
  local scale=v.worldMenuScale or 1
  local size=Vector3.new(12*scale,12*scale*(height+32)/(width+32),2*scale)
  local placement=groundPlacement(camera,size)
  block=make("Part",{Name="PV_PhysicalMenu",Size=size,
   CFrame=placement,
   Anchored=false,CanCollide=true,CanTouch=false,CanQuery=true,Transparency=0,Color=Color3.new(0,0,0),Material=Enum.Material.SmoothPlastic},c.Workspace)
  surface=make("SurfaceGui",{Name="PV_PhysicalMenuSurface",Adornee=block,Face=Enum.NormalId.Front,
   SizingMode=Enum.SurfaceGuiSizingMode.FixedSize,CanvasSize=Vector2.new(width+32,height+32),LightInfluence=0,
   AlwaysOnTop=false,Active=true,ToolPunchThroughDistance=100,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},c.PlayerGui)
  make("Frame",{Name="PV_MenuInputBackplane",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Active=false,ZIndex=0},surface)
  lib.PhysicalGui=surface lib.CantDragForced=true
  lib.PointerProvider=function()return api:Pointer()or Vector2.new(-100000,-100000)end
  local roots={}
  for _,o in ipairs(lib.ScreenGui:GetChildren())do
   if o~=lib.NotificationArea and o.Name~="ObsidianNotifications" and o:IsA("GuiObject")and (o.ZIndex or 1)>=0 and (o.ZIndex or 1)<10000 then roots[#roots+1]=o end
  end
  if not table.find(roots,c.Main)then roots[#roots+1]=c.Main end
  for _,o in ipairs(roots)do saved[#saved+1]={object=o,parent=o.Parent}o.Parent=surface end
  c.Patch("physicalMenuUI",c.Main,"AnchorPoint",Vector2.new(0,0))
  c.Patch("physicalMenuUI",c.Main,"Position",UDim2.fromOffset(16,16))
  local dpi=lib.DPIScale or 1
  c.Patch("physicalMenuUI",c.Main,"Size",UDim2.fromOffset(width/dpi,height/dpi))
  c.Patch("physicalMenuUI",c.Main,"Visible",true)
  for _,o in ipairs(surface:GetDescendants())do opaque(o)end
  mountLinks[#mountLinks+1]=surface.DescendantAdded:Connect(opaque)
  shown=true
  c.Actions:BindActionAtPriority(action,function(_,state,input)
   local kind=input and input.UserInputType or Enum.UserInputType.MouseButton1
   if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then
    local consume=captured[kind] captured[kind]=nil
    if pending and pending.input==kind then finish()end
    if not shown and not next(captured)then c.Actions:UnbindAction(action)end
    return consume and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
   end
   if shown and state==Enum.UserInputState.Begin then
    local pos,from=rayHit()
    if pos then
     local grab=kind==Enum.UserInputType.MouseButton2 or (c.Input.IsKeyDown and (c.Input:IsKeyDown(Enum.KeyCode.LeftAlt)or c.Input:IsKeyDown(Enum.KeyCode.RightAlt)))
     -- Let native SurfaceGui receive ordinary front-face clicks. Its active
     -- canvas handles GUI input; CAS must not swallow widget activation.
     if not grab and api:Pointer()then return Enum.ContextActionResult.Pass end
     captured[kind]=true
     if grab then beginDrag(pos,from,kind)end
     return Enum.ContextActionResult.Sink
    end
   end
   return Enum.ContextActionResult.Pass
  end,false,6000,Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2)
  c.NativeToggle(lib,true)
  c.Patch("physicalMenuCursor",c.Input,"MouseBehavior",Enum.MouseBehavior.Default)
  c.Patch("physicalMenuCursor",c.Input,"MouseIconEnabled",true)
  end,debug.traceback)
  if not ok then
   shown=false pcall(c.NativeToggle,lib,false)restore()
   if c.Setters.worldMenuEnabled then c.Setters.worldMenuEnabled(false,true)end
   pcall(c.NativeToggle,lib,true)
   c.Notify(c.Main.Parent and "Physical menu failed; returned to 2D" or "Menu UI was removed; reload script") warn(message)
  end
 end
 function api:Configure()
  if block then local scale=v.worldMenuScale or 1
   local size=Vector3.new(12*scale,12*scale*surface.CanvasSize.Y/surface.CanvasSize.X,2*scale)
   local cf=block.CFrame+Vector3.new(0,(size.Y-block.Size.Y)/2,0)
   if fits(cf,size)then block.Size=size block.CFrame=cf end block.Transparency=0
  end
 end
 finish=function()
  local dragging=pending and pending.dragging pending=nil
  if block and block.Parent then
   block.AssemblyLinearVelocity=Vector3.zero block.AssemblyAngularVelocity=Vector3.zero block.Anchored=false
  end
  if dragging then
   local token=epoch
   task.defer(function()if not dead and token==epoch then c.Unpatch("physicalMenuDrag")lib.PhysicalDragging=false if surface then surface.Active=true end end end)
  end
 end
 beginDrag=function(pos,from,kind)
  if not shown or pending then return end
  pending={depth=(pos-from).Magnitude,offset=pos-block.CFrame.Position,rotation=block.CFrame-block.CFrame.Position,input=kind,dragging=true}
  block.Anchored=true block.AssemblyLinearVelocity=Vector3.zero block.AssemblyAngularVelocity=Vector3.zero
  lib.PhysicalDragging=true surface.Active=false
  for _,o in ipairs(surface:GetDescendants())do if o:IsA("GuiButton")then pcall(c.Patch,"physicalMenuDrag",o,"Interactable",false)end end
 end
 links[#links+1]=c.Input.InputBegan:Connect(function(input)
  if dead or not shown or input.UserInputType~=Enum.UserInputType.MouseButton1 or c.Input:GetFocusedTextBox()then return end
  if not c.Input:IsKeyDown(Enum.KeyCode.LeftAlt) and not c.Input:IsKeyDown(Enum.KeyCode.RightAlt) then return end
  local pos,from=rayHit() if pos then
   beginDrag(pos,from,Enum.UserInputType.MouseButton1)
  end
 end)
 links[#links+1]=c.Input.InputEnded:Connect(function(input)if pending and pending.input==input.UserInputType then finish()end end)
 if c.Input.WindowFocusReleased then links[#links+1]=c.Input.WindowFocusReleased:Connect(function()
  finish()captured={}if not shown then c.Actions:UnbindAction(action)end
 end)end
 links[#links+1]=c.Players.LocalPlayer.CharacterAdded:Connect(function()
  if shown or surface or block then api:SetVisible(false)end
 end)
 links[#links+1]=c.Run.RenderStepped:Connect(function()
  if dead or not shown then return end
  if not block or not block.Parent or not surface or not surface.Parent then api:SetVisible(false)return end
  c.Input.MouseBehavior=Enum.MouseBehavior.Default c.Input.MouseIconEnabled=true
  if pending then
   if not pending.dragging then
    pending.dragging=true lib.PhysicalDragging=true surface.Active=false
    for _,o in ipairs(surface:GetDescendants())do if o:IsA("GuiButton")then
     pcall(c.Patch,"physicalMenuDrag",o,"Interactable",false)
    end end
   end
   local camera=c.Workspace.CurrentCamera if camera then
    local from,dir=camera.CFrame.Position,camera.CFrame.LookVector
    if c.Input.GetMouseLocation and camera.ScreenPointToRay then local p=c.Input:GetMouseLocation()local r=camera:ScreenPointToRay(p.X,p.Y)from=r.Origin dir=r.Direction end
    moveBody(CFrame.new(from+dir*pending.depth-pending.offset)*pending.rotation)
   end
  end
 end)
 function api:Destroy()
  if dead then return end
  if shown or block or surface then pcall(c.NativeToggle,lib,false)shown=false restore()end
  dead=true captured={} c.Actions:UnbindAction(action) for _,link in ipairs(links)do link:Disconnect()end links={}
 end
 return api
end
