-- Shared static-colour pixel wordmark. Only Omega animates.
return function(c)
 local text="Prime Visuals"
 local api={}
 function api:Measure(value,size,font)
  local ok,bounds=pcall(function()return game:GetService("TextService"):GetTextSize(value,size,font,Vector2.new(1000,100))end)
  return ok and bounds and type(bounds.X)=="number" and math.ceil(bounds.X)or math.ceil(#value*size*.63)
 end
 function api:Apply(label,size,maximum)
  local width=math.min(maximum or 180,self:Measure(text,size,Enum.Font.Arcade)+2)
  label.Font=Enum.Font.Arcade label.TextSize=size label.RichText=true label.TextWrapped=false
  label.TextXAlignment=Enum.TextXAlignment.Left label.TextYAlignment=Enum.TextYAlignment.Center
  label.Size=UDim2.new(0,width,label.Size.Y.Scale,label.Size.Y.Offset)
  local letters={}
  for i=1,#text do
   local color=Color3.fromHSV((i-1)/math.max(1,#text-1)*.82,.63,1)
   letters[#letters+1]=string.format('<font color="rgb(%d,%d,%d)">%s</font>',math.floor(color.R*255),math.floor(color.G*255),math.floor(color.B*255),text:sub(i,i))
  end
  label.Text=table.concat(letters)
  local underline=c.Make("Frame",{Name="RainbowUnderline",BorderSizePixel=0,BackgroundColor3=Color3.new(1,1,1),
   Position=UDim2.new(0,0,.5,size/2+3),Size=UDim2.new(1,0,0,1)},label)
  local points={}
  for i=0,6 do points[#points+1]=ColorSequenceKeypoint.new(i/6,Color3.fromHSV(i/6,.75,1))end
  c.Make("UIGradient",{Color=ColorSequence.new(points)},underline)
  local registry=c.Library and c.Library.Registry and c.Library.Registry[label]
  if registry and Font and Font.fromEnum then
   local face=Font.fromEnum(Enum.Font.Arcade)
   registry.FontFace=function()return face end registry.TextSize=function()return size end
  end
  return width
 end
 return api
end
