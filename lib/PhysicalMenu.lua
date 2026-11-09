-- Local solid block carrying the ORIGINAL live UI tree. No cloned controls or beam.
return function(c)
 local lib,v=c.Library,c.Controls local api={} local shown,dead=false,false
 local block,surface local saved={} local links={} local mountLinks={} local pending
 local oldPointer,oldPhysical,oldCantDrag
 local watched={} local enforcing=false
 local action="PrimePhysicalMenuGuard" local captured=false
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
  pending=nil
  if not captured then c.Actions:UnbindAction(action)end
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
 function api:IsVisible()return shown end
 function api:SetVisible(on)
  if dead then return end
  if shown or block or surface then
   pcall(c.NativeToggle,lib,false) shown=false restore()
  end
  if not on then return end
  local camera=c.Workspace.CurrentCamera if not camera then return end
  c.NativeToggle(lib,false)
  oldPointer,oldPhysical,oldCantDrag=lib.PointerProvider,lib.PhysicalGui,lib.CantDragForced
  local width=math.max(1,math.ceil(c.Main.AbsoluteSize.X))local height=math.max(1,math.ceil(c.Main.AbsoluteSize.Y))
  local scale=v.worldMenuScale or 1
  block=make("Part",{Name="PV_PhysicalMenu",Size=Vector3.new(12*scale,12*scale*(height+32)/(width+32),2*scale),
   CFrame=camera.CFrame*CFrame.new(0,0,-(v.worldMenuDistance or 9))*CFrame.Angles(0,math.pi,0),
   Anchored=true,CanCollide=true,CanTouch=false,CanQuery=true,Transparency=0,Color=Color3.new(0,0,0),Material=Enum.Material.SmoothPlastic},c.Workspace)
  surface=make("SurfaceGui",{Name="PV_PhysicalMenuSurface",Adornee=block,Face=Enum.NormalId.Front,
   SizingMode=Enum.SurfaceGuiSizingMode.FixedSize,CanvasSize=Vector2.new(width+32,height+32),LightInfluence=0,
   AlwaysOnTop=false,Active=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},c.PlayerGui)
  lib.PhysicalGui=surface lib.CantDragForced=true
  if lib.Animations then c.Patch("physicalMenuUI",lib.Animations,"ToggleWindow",false)end
  lib.PointerProvider=function()return api:Pointer()or Vector2.new(-100000,-100000)end
  local roots={}
  for _,o in ipairs(lib.ScreenGui:GetChildren())do
   if o:IsA("GuiObject")and (o.ZIndex or 1)>=0 and (o.ZIndex or 1)<10000 then roots[#roots+1]=o end
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
  c.Actions:BindActionAtPriority(action,function(_,state)
   if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then
    local consume=captured captured=false
    if not shown then c.Actions:UnbindAction(action)end
    return consume and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
   end
   if shown and state==Enum.UserInputState.Begin and rayHit() then captured=true return Enum.ContextActionResult.Sink end
   return Enum.ContextActionResult.Pass
  end,false,6000,Enum.UserInputType.MouseButton1)
  c.NativeToggle(lib,true)
  c.Patch("physicalMenuCursor",c.Input,"MouseIconEnabled",false)
 end
 function api:Configure()
  if block then local scale=v.worldMenuScale or 1
   block.Size=Vector3.new(12*scale,12*scale*surface.CanvasSize.Y/surface.CanvasSize.X,2*scale)block.Transparency=0
  end
 end
 local function finish()
  local dragging=pending and pending.dragging pending=nil
  if dragging then
   task.defer(function()if not dead then c.Unpatch("physicalMenuDrag")lib.PhysicalDragging=false if surface then surface.Active=true end end end)
  end
 end
 links[#links+1]=c.Input.InputBegan:Connect(function(input)
  if dead or not shown or input.UserInputType~=Enum.UserInputType.MouseButton1 or c.Input:GetFocusedTextBox()then return end
  if not c.Input:IsKeyDown(Enum.KeyCode.LeftAlt) and not c.Input:IsKeyDown(Enum.KeyCode.RightAlt) then return end
  local pos,from=rayHit() if pos then
   pending={at=os.clock(),depth=(pos-from).Magnitude,offset=pos-block.CFrame.Position,rotation=block.CFrame-block.CFrame.Position}
  end
 end)
 links[#links+1]=c.Input.InputEnded:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then finish()end end)
 if c.Input.WindowFocusReleased then links[#links+1]=c.Input.WindowFocusReleased:Connect(finish)end
 links[#links+1]=c.Run.RenderStepped:Connect(function()
  if dead or not shown then return end
  if not block or not block.Parent or not surface or not surface.Parent then api:SetVisible(false)return end
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
    block.CFrame=CFrame.new(from+dir*pending.depth-pending.offset)*pending.rotation
   end
  end
 end)
 function api:Destroy()
  if dead then return end
  if shown or block or surface then pcall(c.NativeToggle,lib,false)shown=false restore()end
  dead=true captured=false c.Actions:UnbindAction(action) for _,link in ipairs(links)do link:Disconnect()end links={}
 end
 return api
end
