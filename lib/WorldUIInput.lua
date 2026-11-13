-- Source-owned GUI callbacks: native in2D, explicit ray dispatch on world UI.
return function(lib)
 local records=setmetatable({}, {__mode="k"}) local pressed
 function lib:ConnectUI(object,event,callback)
  local list=records[object]
  if not list then
   list={}records[object]=list
   if object.Destroying then object.Destroying:Connect(function()
    records[object]=nil if pressed==object then pressed=nil end
   end)end
  end
  local entry={event=event,callback=callback}
  entry.connection=object[event]:Connect(function(...)
   if self.PhysicalGui and object:IsDescendantOf(self.PhysicalGui)then return end
   callback(...)
  end)
  list[#list+1]=entry
  return entry.connection
 end
 local function inside(o,p)
  local a,b=o.AbsolutePosition,o.AbsoluteSize
  return p.X>=a.X and p.Y>=a.Y and p.X<=a.X+b.X and p.Y<=a.Y+b.Y
 end
 local function path(o,surface,p)
  local result={}
  while o and o~=surface do
   if o:IsA("GuiObject")then
    if o.Visible==false or (o.ClipsDescendants and not inside(o,p))then return end
    table.insert(result,1,o)
   end
   o=o.Parent
  end
  if o==surface then return result end
 end
 local function higher(a,b)
  if not b then return true end
  for i=1,math.min(#a,#b)do
   if a[i]~=b[i]then
    if a[i].ZIndex~=b[i].ZIndex then return a[i].ZIndex>b[i].ZIndex end
    local siblings=a[i].Parent:GetChildren()
    return (table.find(siblings,a[i])or 0)>(table.find(siblings,b[i])or 0)
   end
  end
  return #a>#b
 end
 local function target(p)
  local surface=lib.PhysicalGui if not surface or not p then return end
  local best,bestPath
  for _,o in ipairs(surface:GetDescendants())do
   if o:IsA("GuiObject")and (records[o]or o:IsA("GuiButton")or o:IsA("TextBox"))and inside(o,p)then
    local candidate=path(o,surface,p)
    if candidate and higher(candidate,bestPath)then best,bestPath=o,candidate end
   end
  end
  return best
 end
 local function emit(o,event,...)
  if not o or o.Interactable==false then return false end
  local found=false
  for _,entry in ipairs(records[o]or{})do
   if entry.event==event and entry.connection.Connected then
    found=true task.spawn(entry.callback,...)
   end
  end
  return found
 end
 function lib:WorldPointerBegin(p,input)
  pressed=nil
  local o=target(p)if not o then return false end
  pressed=o
  if o:IsA("TextBox")then o:CaptureFocus()end
  local node=o
  while node and node~=self.PhysicalGui do emit(node,"InputBegan",input)node=node.Parent end
  return true
 end
 function lib:WorldPointerEnd(p,input,cancel)
  local o=pressed pressed=nil
  if cancel or not o or self.PhysicalDragging or target(p)~=o then return end
  if not o:IsDescendantOf(self.PhysicalGui)then return end
  local node=o
  while node and node~=self.PhysicalGui do
   if emit(node,"MouseButton1Click",p.X,p.Y)or emit(node,"Activated",input,1)then break end
   node=node.Parent
  end
 end
 function lib:WorldPointerCancel()pressed=nil end
end
