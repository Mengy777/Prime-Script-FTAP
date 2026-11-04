-- Local replacement of the native balance icon. Never edits balance text/value.
return function(c)
 local api={}local enabled,dead=false,false local icon,root,connection local colors={}
 local function clear()
  if root then root:Destroy()root=nil end
  c.Unpatch("coinIcon")icon=nil colors={}
 end
 local function find()
  local o=c.PlayerGui
  for _,name in ipairs({"MenuGui","TopRight","CoinsFrame","CoinsDisplay","CoinImage"})do o=o and o:FindFirstChild(name)end
  if o and(o:IsA("ImageLabel")or o:IsA("ImageButton"))then return o end
 end
 local function make(parent,props)
  local o=Instance.new("Frame")o.BorderSizePixel=0 o.Active=false o.BackgroundColor3=Color3.new(0,0,0)
  for key,value in pairs(props)do o[key]=value end o.Parent=parent return o
 end
 local points={{.5,.06},{.6,.4},{.94,.5},{.6,.6},{.5,.94},{.4,.6},{.06,.5},{.4,.4}}
 local function build(source)
  clear()icon=source
  root=make(source,{Name="PV_CoinSymbol",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=source.ZIndex})
  -- Horizontal spans fill the concave sparkle black; no font/glyph or asset dependency.
  for row=0,47 do
   local y=(row+.5)/48 local crossings={}
   for i,a in ipairs(points)do local b=points[i%#points+1]
    if(a[2]<=y and b[2]>y)or(b[2]<=y and a[2]>y)then crossings[#crossings+1]=a[1]+(y-a[2])*(b[1]-a[1])/(b[2]-a[2])end
   end
   table.sort(crossings)
   if #crossings>=2 then make(root,{Position=UDim2.fromScale(crossings[1],row/48),Size=UDim2.new(crossings[2]-crossings[1],0,1/48,.3),ZIndex=source.ZIndex})end
  end
  local strokes={}
  for i,a in ipairs(points)do local b=points[i%#points+1]
   local dx,dy=b[1]-a[1],b[2]-a[2]
   for _,style in ipairs({{6,.92},{3,.72},{1.3,.02}})do
    local line=make(root,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale((a[1]+b[1])/2,(a[2]+b[2])/2),
     Size=UDim2.new(0,0,0,style[1]),Rotation=math.deg(math.atan2(dy,dx)),BackgroundTransparency=style[2],ZIndex=source.ZIndex+1})
    strokes[#strokes+1]={line=line,dx=dx,dy=dy}colors[#colors+1]=line
   end
  end
  local function resize()
   if not root then return end local size=root.AbsoluteSize
   for _,stroke in ipairs(strokes)do
    stroke.line.Size=UDim2.fromOffset(math.sqrt((stroke.dx*size.X)^2+(stroke.dy*size.Y)^2),stroke.line.Size.Y.Offset)
    stroke.line.Rotation=math.deg(math.atan2(stroke.dy*size.Y,stroke.dx*size.X))
   end
  end
  root:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)resize()
  c.Patch("coinIcon",source,"ImageTransparency",1)
 end
 function api:SetEnabled(on)
  if dead or enabled==(on==true)then return end enabled=on==true
  if connection then connection:Disconnect()connection=nil end
  if not enabled then clear()return end
  local source=find()if source then build(source)end
  local elapsed,retry=0,0
  connection=c.Run.Heartbeat:Connect(function(dt)
   elapsed=elapsed+dt retry=retry+dt
   if retry>=.5 then
    retry=0 local current=find()
    if current~=icon or(icon and(not root or root.Parent~=icon))then if current then build(current)else clear()end end
    if icon then c.Patch("coinIcon",icon,"ImageTransparency",1)end
   end
   if elapsed<1/30 then return end elapsed=0
   if not root or not root.Parent then return end
   local o=root while o and o~=c.PlayerGui do if(o:IsA("GuiObject")and o.Visible==false)or(o:IsA("ScreenGui")and o.Enabled==false)then return end o=o.Parent end
   local color=Color3.fromHSV((os.clock()%8)/8,.9,1)
   for _,line in ipairs(colors)do line.BackgroundColor3=color end
  end)
 end
 function api:Destroy()if dead then return end self:SetEnabled(false)dead=true clear()end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 return api
end
