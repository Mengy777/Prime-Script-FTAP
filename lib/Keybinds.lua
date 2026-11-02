-- Input routing with explicit ownership, conflict checks and atomic restore.
return function(c)
 local routes,bindings,links={}, {}, {} local capture,dead=nil,false
 local api={}
 local function token(input)
  if not input then return end
  local name=input.UserInputType and input.UserInputType.Name or "Keyboard"
  if name=="Keyboard" then return input.KeyCode and input.KeyCode.Name end
  if name=="MouseButton1" or name=="MouseButton2" or name=="MouseButton3" then return name end
 end
 function api:Valid(value)
  if value=="" then return true end
  if type(value)~="string" or #value>32 then return false end
  if value:match("^MouseButton[123]$") then return true end
  local ok,item=pcall(function() return Enum.KeyCode[value] end)
  return ok and item~=nil and item.Name==value and value~="Unknown"
 end
 function api:Set(key,value)
  assert(self:Valid(value),"Invalid key binding")
  for other,current in pairs(bindings)do assert(value=="" or other==key or current~=value,"Key already assigned: "..tostring(other))end
  bindings[key]=value
 end
 function api:Register(key,fn)routes[key]=fn bindings[key]="" end
 function api:Clear()for key in pairs(bindings)do bindings[key]=""end end
 function api:Capture(key,done)
  assert(routes[key],"Unknown binding target")capture={key=key,done=done}
 end
 links[#links+1]=c.Input.InputBegan:Connect(function(input,processed)
  if dead then return end
  local value=token(input)
  if capture then
   if not value then return end
   local request=capture capture=nil
   if value=="Escape"then return end
   if value=="Backspace" or value=="Delete"then value=""end
   request.done(value) return
  end
  if processed or c.Input:GetFocusedTextBox() or not value then return end
  for key,binding in pairs(bindings)do if binding==value and routes[key] and (key=="menu" or not c.MenuOpen())then c.Safe(routes[key])break end end
 end)
 if c.Input.WindowFocusReleased then links[#links+1]=c.Input.WindowFocusReleased:Connect(function()capture=nil end)end
 function api:Destroy()if dead then return end dead=true capture=nil for _,link in ipairs(links)do link:Disconnect()end routes={}bindings={}end
 return api
end
