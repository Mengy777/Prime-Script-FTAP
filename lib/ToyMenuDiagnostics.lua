return function()
-- Read-only native toy-menu inspector. No game remotes or UI changes.
local players=game:GetService("Players")
local player=players.LocalPlayer
local gui=player:WaitForChild("PlayerGui")
local rows,roots={},{} local index={}
local function clean(s)return tostring(s or ""):lower():gsub("[^%w]","")end
local function vec(v)if v then return {v.X,v.Y}end end
local function dim(v)if v then return {v.X.Scale,v.X.Offset,v.Y.Scale,v.Y.Offset}end end
local function prop(o,key,convert)
 local ok,value=pcall(function()return o[key]end)
 if ok and value~=nil then if convert then return convert(value)end return value end
end
for _,root in ipairs(gui:GetChildren())do
 local name=clean(root.Name)
 local match=name:find("toy",1,true)~=nil
 if not name:find("prime",1,true)and not name:find("obsidian",1,true)then
  if not match then for _,o in ipairs(root:GetDescendants())do
   if(o:IsA("TextLabel")or o:IsA("TextButton"))and clean(o.Text)=="yourtoys"then match=true break end
  end end
  if match then roots[#roots+1]=root end
 end
end
local function add(o,parent)
 if #rows>=30000 then return end
 local row={name=o.Name,class=o.ClassName,parent=parent}
 rows[#rows+1]=row local myIndex=#rows index[o]=myIndex
 if o:IsA("GuiObject")then
  row.visible=o.Visible row.order=o.LayoutOrder row.position=dim(o.Position)row.size=dim(o.Size)row.anchor=vec(o.AnchorPoint)
  row.absolutePosition=vec(o.AbsolutePosition)row.absoluteSize=vec(o.AbsoluteSize)row.z=o.ZIndex
 end
 if o:IsA("ScreenGui")then row.enabled=o.Enabled end
 if o:IsA("TextLabel")or o:IsA("TextButton")then row.text=o.Text:sub(1,160)end
 if o:IsA("ImageLabel")or o:IsA("ImageButton")then row.image=o.Image row.imageRectOffset=vec(o.ImageRectOffset)row.imageRectSize=vec(o.ImageRectSize)end
 if o:IsA("UIGridLayout")or o:IsA("UIListLayout")then row.sort=tostring(o.SortOrder)row.fill=tostring(o.FillDirection)end
 if o:IsA("StringValue")or o:IsA("IntValue")or o:IsA("BoolValue")then row.value=o.Value end
 if o:IsA("ObjectValue")then row.target=o.Value and o.Value:GetFullName()end
 local attributes=o:GetAttributes()if next(attributes)then
  row.attributes={}for key,value in pairs(attributes)do if type(value)=="string"or type(value)=="number"or type(value)=="boolean"then row.attributes[key]=value end end
 end
 for _,child in ipairs(o:GetChildren())do add(child,myIndex)end
end
for _,root in ipairs(roots)do add(root,0)end
assert(type(writefile)=="function","Executor writefile is unavailable")
if makefolder then pcall(makefolder,"PrimeVisuals")end
local path="PrimeVisuals/ToyMenu-Diagnostics.json"
writefile(path,game:GetService("HttpService"):JSONEncode({version=1,roots=#roots,truncated=#rows>=30000,nodes=rows}))
return #roots
end
