-- Major 3 presentation/input coordinator. Gameplay stays behind existing setters.
return function(c)
 local v,lib=c.Controls,c.Library
 local input=c.Keybinds({Input=c.Input,MenuOpen=function()return lib.Toggled end,Safe=c.Safe})
 local roots,connections={},{} local dead=false
 local api={}
 function api:Destroy()if dead then return end dead=true input:Destroy()for _,link in ipairs(connections)do if link then link:Disconnect()end end for _,root in ipairs(roots)do root:Destroy()end end
 if c.TrackCleanup then c.TrackCleanup(function()api:Destroy()end)end
 local function own(o)roots[#roots+1]=o return o end
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
 binding("menu",function()lib:Toggle(not lib.Toggled)end,general)
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
 local panel=c.Make("TextButton",{Name="Watermark",Text="",Position=UDim2.fromOffset(14,78),Size=UDim2.fromOffset(278,36),BackgroundColor3=Color3.fromRGB(12,12,17),BorderSizePixel=0,AutoButtonColor=false},screen)
 c.Make("UIStroke",{Color=Color3.fromRGB(160,106,255),Thickness=1,Transparency=.4},panel)
 local icon=c.Make("ImageLabel",{Name="Omega",Image="",BackgroundTransparency=1,Position=UDim2.fromOffset(7,5),Size=UDim2.fromOffset(26,26)},panel)
 connections[#connections+1]=c.Icon(icon,panel,c.Run)
 local title=c.Make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(42,0),Size=UDim2.fromOffset(142,36),Text="PRIME VISUALS",Font=Enum.Font.BuilderSansBold,TextSize=16,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left},panel)
 local metrics=c.Make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(184,0),Size=UDim2.fromOffset(86,36),Text="",Font=Enum.Font.BuilderSans,TextSize=12,TextColor3=Color3.fromRGB(195,180,220)},panel)
 local launcher=c.Make("TextButton",{Name="OpenPrime",Text="Ω",Position=UDim2.fromOffset(14,78),Size=UDim2.fromOffset(36,36),Font=Enum.Font.BuilderSansBold,TextSize=25,BackgroundColor3=Color3.fromRGB(15,15,21),TextColor3=Color3.fromRGB(180,130,255)},screen)
 connections[#connections+1]=launcher.MouseButton1Click:Connect(function()lib:Toggle(true)end)
 connections[#connections+1]=panel.MouseButton1Click:Connect(function()lib:Toggle(not lib.Toggled)end)
 settings=c.Group("Settings","Status panel",2)
 local function update()panel.Visible=v.hudEnabled~=false launcher.Visible=not panel.Visible and not lib.Toggled end
 c.Toggle(settings,"hudEnabled","Status panel",true,update)
 c.Toggle(settings,"hudFPS","Show FPS",true,function()end)
 c.Toggle(settings,"hudClock","Show time",false,function()end)
 c.Toggle(settings,"hudPlayers","Show player count",false,function()end)
 c.Slider(settings,"hudOpacity","Panel transparency",0,.9,0,.01,function(value)panel.BackgroundTransparency=value end)
 c.Slider(settings,"hudOffsetY","Panel vertical position",50,400,78,1,function(value)panel.Position=UDim2.fromOffset(14,value)end)
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
  local width=math.max(86,#metrics.Text*6+10)panel.Size=UDim2.fromOffset(192+width,36)metrics.Size=UDim2.fromOffset(width,36)
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
