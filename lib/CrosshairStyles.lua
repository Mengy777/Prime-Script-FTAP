-- Pixel-clean local reticles: no remote image dependency for built-in styles.
return function(make)
 local states=setmetatable({},{__mode="k"})local api={}
 function api:Draw(parent,style,tint)
  local state=states[parent]
  if not state or state.style~=style or not state.root.Parent then
   if state then state.root:Destroy()end
   local root=make("Frame",{Name="PV_Reticle",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=parent.ZIndex or 1},parent)
   state={root=root,style=style,colors={}}states[parent]=state
   local function rect(x,y,w,h,rotation,round)
    local frame=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromScale(w,h),BorderSizePixel=0,BackgroundColor3=tint,Rotation=rotation or 0,ZIndex=root.ZIndex},root)
    state.colors[#state.colors+1]=frame
    if round then make("UICorner",{CornerRadius=UDim.new(1,0)},frame)end
   end
   local function ring(radius)
    for i=0,31 do local a=i*math.pi/16 rect(.5+radius*math.cos(a),.5+radius*math.sin(a),.075,.045,i*11.25+90,true)end
   end
   if style=="Precision dot"then rect(.5,.5,.13,.13,0,true)
   elseif style=="Halo"then ring(.32)rect(.5,.5,.09,.09,0,true)
   elseif style=="Tactical cross"then
    rect(.5,.17,.06,.24)rect(.5,.83,.06,.24)rect(.17,.5,.24,.06)rect(.83,.5,.24,.06)rect(.5,.5,.065,.065)
   elseif style=="Diamond sight"then
    rect(.35,.35,.43,.045,45)rect(.65,.35,.43,.045,-45)rect(.35,.65,.43,.045,-45)rect(.65,.65,.43,.045,45)rect(.5,.5,.08,.08,0,true)
   elseif style=="Target ring"then
    ring(.27)rect(.5,.08,.05,.15)rect(.5,.92,.05,.15)rect(.08,.5,.15,.05)rect(.92,.5,.15,.05)
   elseif style=="Corner brackets"then
    for _,x in ipairs({.16,.84})do for _,y in ipairs({.16,.84})do
     rect(x,y,.22,.045)rect(x<.5 and .07 or .93,y<.5 and .24 or .76,.045,.2)
    end end rect(.5,.5,.07,.07)
   end
  end
  state.root.Visible=style~="Custom image"
  for _,frame in ipairs(state.colors)do frame.BackgroundColor3=tint end
 end
 return api
end
