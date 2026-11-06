-- Local input visualizer. Observes input without binding/sinking game controls.
return function(c)
 local v=c.Controls local links,keys,held={},{},{} local dead=false local drag local wheelUp,wheelDown=0,0
 local screen=c.Make("ScreenGui",{Name="PrimeInputOverlay",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=99,Enabled=false},c.PlayerGui)
 local root=c.Make("Frame",{Name="Keyboard",Active=true,BorderSizePixel=0,Size=UDim2.fromOffset(292,146)},screen)
 c.Make("UICorner",{CornerRadius=UDim.new(0,10)},root)
 local border=c.Make("UIStroke",{Thickness=1,Transparency=.45},root)
 local scale=c.Make("UIScale",{Scale=1},root)
 local function connect(signal,fn)links[#links+1]=signal:Connect(fn)end
 local function key(name,label,x,y,w,h)
  local frame=c.Make("TextLabel",{Name=name,Text=label,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BorderSizePixel=0,Font=Enum.Font.GothamMedium,TextSize=12,Active=false},root)
  c.Make("UICorner",{CornerRadius=UDim.new(0,5)},frame)
  local outline=c.Make("UIStroke",{Thickness=1,Transparency=.6,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},frame)
  keys[name]={frame=frame,outline=outline,amount=0}
 end
 -- Compact spatial keyboard: E next to W, wide modifiers and space below.
 key("W","W",80,10,38,36)key("E","E",124,10,38,36)
 key("A","A",36,52,38,36)key("S","S",80,52,38,36)key("D","D",124,52,38,36)
 key("Shift","SHIFT",10,100,56,36)key("Ctrl","CTRL",72,100,48,36)key("Space","SPACE",126,100,74,36)
 local mouse=c.Make("Frame",{Name="Mouse",Position=UDim2.fromOffset(212,10),Size=UDim2.fromOffset(70,126),BorderSizePixel=0},root)
 c.Make("UICorner",{CornerRadius=UDim.new(0,22)},mouse)
 local mouseBorder=c.Make("UIStroke",{Thickness=1,Transparency=.45},mouse)
 key("MouseButton1","L",219,19,25,40)key("MouseButton2","R",250,19,25,40)
 key("MouseButton3","•",237,65,20,24)key("WheelUp","↑",220,96,24,25)key("WheelDown","↓",250,96,24,25)
 local function position(x,y)
  local camera=c.Workspace.CurrentCamera local view=camera and camera.ViewportSize or Vector2.new(1280,720)
  local factor=v.inputOverlayScale or 1
  root.Position=UDim2.fromOffset(math.clamp(x,0,math.max(0,view.X-292*factor)),math.clamp(y,0,math.max(0,view.Y-146*factor)))
 end
 local function update()
  screen.Enabled=v.inputOverlayEnabled==true
  scale.Scale=v.inputOverlayScale or 1
  root.BackgroundColor3=v.inputOverlayBackground or Color3.fromRGB(12,12,17)
  root.BackgroundTransparency=v.inputOverlayTransparency or .15
  mouse.BackgroundColor3=root.BackgroundColor3 mouse.BackgroundTransparency=root.BackgroundTransparency
  border.Color=v.inputOverlayAccent or Color3.fromRGB(160,106,255)mouseBorder.Color=border.Color
  if not drag then position(v.inputOverlayX or 24,v.inputOverlayY or 360)end
  if not screen.Enabled then held={}wheelUp=0 wheelDown=0 drag=nil for _,entry in pairs(keys)do entry.amount=0 end end
 end
 local function finish()
  local previous=drag drag=nil
  if previous and previous.moved then local x,y=root.Position.X.Offset,root.Position.Y.Offset c.Setters.inputOverlayX(x,true)c.Setters.inputOverlayY(y,true)end
 end
 local group=c.Group("Personalization","Input display",1)
 c.Toggle(group,"inputOverlayEnabled","Keyboard and mouse",false,update)
 local panel=c.Panel("inputOverlayEnabled")
 c.Slider(panel,"inputOverlayScale","Size",.5,2,1,.05,update)
 c.Slider(panel,"inputOverlayTransparency","Background transparency",0,.9,.15,.05,update)
 c.Color(panel,"inputOverlayAccent","Pressed keys",Color3.fromRGB(160,106,255),update,update)
 c.Color(panel,"inputOverlayBackground","Panel background",Color3.fromRGB(12,12,17),update,update)
 c.Color(panel,"inputOverlayText","Key text",Color3.fromRGB(235,235,245),update,update)
 c.Slider(panel,"inputOverlayX","Horizontal position",0,8192,24,1,update)
 c.Slider(panel,"inputOverlayY","Vertical position",0,8192,360,1,update)
 local function identify(event)
  if event.UserInputType==Enum.UserInputType.Keyboard then return event.KeyCode and event.KeyCode.Name or "" end
  return event.UserInputType and event.UserInputType.Name or ""
 end
 connect(c.Input.InputBegan,function(event)if screen.Enabled then held[identify(event)]=true end end)
 connect(c.Input.InputEnded,function(event)
  held[identify(event)]=nil
  if drag and(event==drag.input or event.UserInputType==Enum.UserInputType.MouseButton1)then finish()end
 end)
 connect(root.InputBegan,function(event)
  if not screen.Enabled then return end
  if event.UserInputType==Enum.UserInputType.MouseButton1 or event.UserInputType==Enum.UserInputType.Touch then
   drag={input=event,x=event.Position.X,y=event.Position.Y,ox=root.Position.X.Offset,oy=root.Position.Y.Offset}
  end
 end)
 connect(c.Input.InputChanged,function(event)
  if not screen.Enabled then return end
  if event.UserInputType==Enum.UserInputType.MouseWheel then
   if event.Position.Z>0 then wheelUp=.18 elseif event.Position.Z<0 then wheelDown=.18 end
  end
  if drag and(event.UserInputType==Enum.UserInputType.MouseMovement or event==drag.input)then
   local dx,dy=event.Position.X-drag.x,event.Position.Y-drag.y
   if math.abs(dx)+math.abs(dy)>3 then drag.moved=true end
   if drag.moved then position(drag.ox+dx,drag.oy+dy)end
  end
 end)
 connect(c.Input.WindowFocusReleased,function()held={}wheelUp=0 wheelDown=0 finish()end)
 connect(c.Run.RenderStepped,function(dt)
  if dead or not screen.Enabled or dt<=0 or dt~=dt or dt==math.huge then return end
  wheelUp=math.max(0,wheelUp-dt)wheelDown=math.max(0,wheelDown-dt)
  local blend=1-math.exp(-24*math.min(dt,.1))
  for name,entry in pairs(keys)do
   local down=held[name]
   if name=="Shift"then down=held.LeftShift or held.RightShift elseif name=="Ctrl"then down=held.LeftControl or held.RightControl
   elseif name=="WheelUp"then down=wheelUp>0 elseif name=="WheelDown"then down=wheelDown>0 end
   entry.amount=entry.amount+((down and 1 or 0)-entry.amount)*blend
   local idle=Color3.fromRGB(25,25,32)local accent=v.inputOverlayAccent or Color3.fromRGB(160,106,255)
   entry.frame.BackgroundColor3=idle:Lerp(accent,entry.amount)
   entry.frame.BackgroundTransparency=.12*(1-entry.amount)
   entry.frame.TextColor3=v.inputOverlayText or Color3.new(1,1,1)
   entry.outline.Color=accent entry.outline.Transparency=.8-.65*entry.amount
  end
 end)
 update()
 return{Destroy=function()if dead then return end dead=true drag=nil held={}for _,link in ipairs(links)do link:Disconnect()end screen:Destroy()end}
end
