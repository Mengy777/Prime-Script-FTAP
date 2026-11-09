-- Major 3 presentation/input coordinator. Gameplay stays behind existing setters.
return function(c)
 local v,lib=c.Controls,c.Library
 local wordmark=c.Wordmark({Make=c.Make,Library=lib})
 local input=c.Keybinds({Input=c.Input,MenuOpen=function()return lib.Toggled end,Safe=c.Safe,
  Blocked=function(key)return key=="camThird" and v.minecraftEnabled==true end})
 local roots,connections={},{} local dead=false
 local physical local nativeToggle=lib.Toggle
 local api={}
 function api:Destroy()if dead then return end dead=true if physical then physical:Destroy()end lib.Toggle=nativeToggle input:Destroy()for _,link in ipairs(connections)do if link then link:Disconnect()end end for _,root in ipairs(roots)do root:Destroy()end end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 physical=c.PhysicalMenu(c)
 local function menuVisible()return v.worldMenuEnabled and physical:IsVisible() or lib.Toggled end
 function lib:Toggle(value)
  if v.worldMenuEnabled then
   nativeToggle(self,false)
   physical:SetVisible(value==nil and not physical:IsVisible() or value==true)
  else
   if physical:IsVisible()then physical:SetVisible(false)end
   nativeToggle(self,value)
  end
 end
 local physicalSettings=c.Group("Favorites","Physical menu",1)
 c.Toggle(physicalSettings,"worldMenuEnabled","Physical menu",false,function(on)
  if on then if lib.Toggled then nativeToggle(lib,false)physical:SetVisible(true)end
  else local was=physical:IsVisible()physical:SetVisible(false)if was then nativeToggle(lib,true)end end
 end)
 c.Slider(physicalSettings,"worldMenuTransparency","Panel transparency",0,.95,.75,.05,function()physical:Configure()end)
 c.Slider(physicalSettings,"worldMenuScale","Panel size",.5,2,1,.1,function()physical:Configure()end)
 c.Slider(physicalSettings,"worldMenuDistance","Panel distance",5,20,9,1,function()end)
 local function own(o)roots[#roots+1]=o return o end
 if c.HeaderTitle then wordmark:Apply(c.HeaderTitle,18,172)end
 if c.Header then connections[#connections+1]=c.Icon(c.Header,c.Main,c.Run)end
 local function binding(key,fn,panel)
  input:Register(key,fn)
  local initial=key=="menu" and "RightControl" or ""
  input:Set(key,initial)
  c.Field(panel,"bind_"..key,"Key",initial,function(value)input:Set(key,value)end)
  c.Action(panel,"Assign key",function()
   c.Notify("Press a key; Escape cancels, Backspace clears")
   input:Capture(key,function(value)c.Safe(function()c.Setters["bind_"..key](value,true)end)end)
  end)
 end
 local keys={}for key,spec in pairs(c.Specs)do if spec.Kind=="Toggle"then keys[#keys+1]=key end end table.sort(keys)
 for _,key in ipairs(keys)do
  local widget=c.Widgets[key]widget.SettingsWhenDisabled=true
  local panel=c.Panel(key)
  if panel.Pages and #panel.Pages>0 then panel=panel:AddPage("Keybind")end
  binding(key,function()c.Setters[key](not v[key],true)end,panel)
 end
 local general=c.Group("Settings","Keybinds",1)
 binding("menu",function()lib:Toggle(not menuVisible())end,general)
 c.Action(general,"Clear all keybinds",function()for key in pairs(c.Specs)do if key:sub(1,5)=="bind_"then c.Setters[key]("",true)end end end)
 local settings=c.Group("Settings","Menu appearance",1)
 local alphaOriginal=setmetatable({}, {__mode="k"})
 local themes={Obsidian={15,15,19,160,106,255},Midnight={9,16,27,70,170,255},Crimson={21,10,15,235,65,90},Emerald={9,20,18,60,210,155}}
 local themePending,themeElapsed=false,0
 local function theme()themePending=true end
 local function applyTheme()
  local t=themes[v.menuTheme]or themes.Obsidian
  lib.Scheme.MainColor=v.menuCustomBackground and v.menuBackground or Color3.fromRGB(t[1],t[2],t[3])
  lib.Scheme.BackgroundColor=lib.Scheme.MainColor
  lib.Scheme.FontColor=v.menuTextColor or Color3.fromRGB(235,235,240)
  lib.Scheme.AccentColor=v.menuCustomAccent and v.menuAccent or Color3.fromRGB(t[4],t[5],t[6])
  if lib.UpdateColorsUsingRegistry then lib:UpdateColorsUsingRegistry()end
  if c.Main then
   local nodes=c.Main:GetDescendants()nodes[#nodes+1]=c.Main
   for _,node in ipairs(nodes)do if node:IsA("GuiObject")then
    if alphaOriginal[node]==nil then alphaOriginal[node]=node.BackgroundTransparency end
    node.BackgroundTransparency=math.max(alphaOriginal[node]or 1,v.menuTransparency or 0)
   end end
  end
 end
 c.Choice(settings,"menuTheme","Theme",{"Obsidian","Midnight","Crimson","Emerald"},"Obsidian",theme)
 c.Toggle(settings,"menuCustomAccent","Custom accent",false,theme)
 c.Toggle(settings,"menuCustomBackground","Custom background",false,theme)
 c.Color(settings,"menuBackground","Menu background",Color3.fromRGB(15,15,19),theme)
 c.Color(settings,"menuTextColor","Menu text",Color3.fromRGB(235,235,240),theme)
 c.Color(settings,"menuAccent","Menu accent",Color3.fromRGB(160,106,255),theme)
 c.Slider(settings,"menuTransparency","Menu transparency",0,.8,0,.01,theme)
 c.Choice(settings,"menuFont","Menu font",{"Builder Sans","Gotham","Roboto","Code"},"Builder Sans",function(value)
  if lib.SetFont then lib:SetFont(({Gotham=Enum.Font.Gotham,Roboto=Enum.Font.Roboto,Code=Enum.Font.Code})[value]or Enum.Font.BuilderSans)end
 end)
 local screen=own(c.Make("ScreenGui",{Name="PrimeStatus",ResetOnSpawn=false,DisplayOrder=100},c.PlayerGui))
 local panel=c.Make("TextButton",{Name="Watermark",Text="",Position=UDim2.fromOffset(14,78),Size=UDim2.fromOffset(224,30),BackgroundColor3=Color3.fromRGB(12,12,17),BorderSizePixel=0,AutoButtonColor=false},screen)
 c.Make("UICorner",{CornerRadius=UDim.new(0,9)},panel)
 c.Make("UIStroke",{Color=Color3.fromRGB(160,106,255),Thickness=1,Transparency=.4},panel)
 local icon=c.Make("ImageLabel",{Name="Omega",Image="",BackgroundTransparency=1,Position=UDim2.fromOffset(4,2),Size=UDim2.fromOffset(26,26)},panel)
 connections[#connections+1]=c.Icon(icon,panel,c.Run)
 local title=c.Make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(36,0),Size=UDim2.fromOffset(124,30),Text="PRIME VISUALS",Font=Enum.Font.BuilderSansBold,TextSize=14,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left},panel)
 local brandWidth=wordmark:Apply(title,13,150)
 local metrics=c.Make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(36+brandWidth+7,0),Size=UDim2.fromOffset(48,30),Text="",Font=Enum.Font.BuilderSans,TextSize=11,TextColor3=Color3.fromRGB(195,180,220)},panel)
 panel.Size=UDim2.fromOffset(36+brandWidth+7+48+8,30)
 local launcher=c.Make("TextButton",{Name="OpenPrime",Text="Ω",Position=UDim2.fromOffset(14,78),Size=UDim2.fromOffset(36,36),Font=Enum.Font.BuilderSansBold,TextSize=25,BackgroundColor3=Color3.fromRGB(15,15,21),TextColor3=Color3.fromRGB(180,130,255)},screen)
 connections[#connections+1]=launcher.MouseButton1Click:Connect(function()lib:Toggle(true)end)
 local drag,suppressClickUntil=nil,0
 local function position(x,y)
  local camera=workspace.CurrentCamera local view=camera and camera.ViewportSize
  if view then x=math.clamp(x,0,math.max(0,view.X-panel.Size.X.Offset)) y=math.clamp(y,0,math.max(0,view.Y-70))end
  panel.Position=UDim2.fromOffset(x,y)
 end
 local function restorePosition()if not drag then position(v.hudOffsetX or 14,v.hudOffsetY or 78)end end
 local function finishDrag()
  local current=drag drag=nil
  if current and current.moved then
   suppressClickUntil=os.clock()+.25
   local x,y=panel.Position.X.Offset,panel.Position.Y.Offset
   c.Setters.hudOffsetX(x,true)
   c.Setters.hudOffsetY(y,true)
  end
 end
 connections[#connections+1]=panel.InputBegan:Connect(function(event)
  if event.UserInputType==Enum.UserInputType.MouseButton1 or event.UserInputType==Enum.UserInputType.Touch then
   drag={input=event,start=Vector2.new(event.Position.X,event.Position.Y),origin=Vector2.new(panel.Position.X.Offset,panel.Position.Y.Offset)}
  end
 end)
 connections[#connections+1]=c.Input.InputChanged:Connect(function(event)
  if not drag then return end
  if event.UserInputType~=Enum.UserInputType.MouseMovement and event~=drag.input then return end
  local delta=Vector2.new(event.Position.X,event.Position.Y)-drag.start
  if delta.Magnitude>=3 then drag.moved=true end
  if drag.moved then position(drag.origin.X+delta.X,drag.origin.Y+delta.Y)end
 end)
 connections[#connections+1]=c.Input.InputEnded:Connect(function(event)
  if drag and (event==drag.input or event.UserInputType==Enum.UserInputType.MouseButton1)then finishDrag()end
 end)
 if c.Input.WindowFocusReleased then connections[#connections+1]=c.Input.WindowFocusReleased:Connect(finishDrag)end
 connections[#connections+1]=panel.MouseButton1Click:Connect(function()
  if (drag and drag.moved)or os.clock()<suppressClickUntil then return end lib:Toggle(not menuVisible())
 end)
 settings=c.Group("Settings","Status panel",2)
 local function update()panel.Visible=v.hudEnabled~=false launcher.Visible=not panel.Visible and not lib.Toggled end
 c.Toggle(settings,"hudEnabled","Status panel",true,update)
 c.Toggle(settings,"hudFPS","Show FPS",true,function()end)
 c.Toggle(settings,"hudClock","Show time",false,function()end)
 c.Toggle(settings,"hudPlayers","Show player count",false,function()end)
 c.Slider(settings,"hudOpacity","Panel transparency",0,.9,0,.01,function(value)panel.BackgroundTransparency=value end)
 c.Slider(settings,"hudOffsetX","Panel horizontal position",0,8192,14,1,restorePosition)
 c.Slider(settings,"hudOffsetY","Panel vertical position",0,8192,78,1,restorePosition)
 restorePosition()
 local elapsed,frames=0,0
 connections[#connections+1]=c.Run.RenderStepped:Connect(function(dt)
  if dead or dt<=0 or dt~=dt or dt==math.huge then return end
  update()elapsed=elapsed+dt frames=frames+1 themeElapsed=themeElapsed+dt
  if themePending and themeElapsed>=.12 then local ok,message=pcall(applyTheme)themePending=false themeElapsed=0 if not ok then c.Notify(message)end end
  if elapsed<1 then return end
  local items={}
  if v.hudFPS then items[#items+1]=tostring(math.floor(frames/elapsed+.5)).." FPS"end
  if v.hudClock then items[#items+1]=os.date("%H:%M")end
  if v.hudPlayers then items[#items+1]=tostring(#c.Players:GetPlayers()).." players"end
  metrics.Text=table.concat(items," · ")
  local width=metrics.Text~="" and wordmark:Measure(metrics.Text,11,Enum.Font.BuilderSans)+2 or 0
  panel.Size=UDim2.fromOffset(36+brandWidth+(width>0 and 7 or 0)+width+8,30)metrics.Size=UDim2.fromOffset(width,30)
  restorePosition()
  elapsed=0 frames=0
 end)
 function api:ValidateProfile(values)
  local seen={}
  for key,value in pairs(values)do if key:sub(1,5)=="bind_"then
   assert(input:Valid(value),"Invalid saved key binding")
   assert(value==""or not seen[value],"Conflicting saved key bindings")
   if value~=""then seen[value]=true end
  end end
 end
 function api:PrepareProfile(values)self:ValidateProfile(values)input:Clear()end
 return api
end
