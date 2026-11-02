-- Original geometric Omega, no external image dependency.
return function(holder, main, run)
 holder.Image="" holder.BackgroundTransparency=1
 local root=Instance.new("Frame")root.Name="PrimeOmega"root.BackgroundTransparency=1 root.Size=UDim2.fromScale(1,1)root.Parent=holder
 local lines={}
 local function segment(x,y,a,b)
  local dx,dy=a-x,b-y local f=Instance.new("Frame")
  f.BorderSizePixel=0 f.AnchorPoint=Vector2.new(.5,.5)f.Position=UDim2.fromScale((x+a)/2,(y+b)/2)
  f.Size=UDim2.new(math.sqrt(dx*dx+dy*dy),0,0,2.4)f.Rotation=math.deg(math.atan2(dy,dx))f.Parent=root
  lines[#lines+1]=f
 end
 local x,y
 for i=0,28 do
  local angle=math.rad(215-i*250/28)local a,b=.5+.31*math.cos(angle),.42-.31*math.sin(angle)
  if x then segment(x,y,a,b)end x,y=a,b
 end
 segment(.246,.598,.31,.78)segment(.31,.78,.13,.78)
 segment(.754,.598,.69,.78)segment(.69,.78,.87,.78)
 local elapsed=0 local connection
 connection=run.RenderStepped:Connect(function(dt)
  if not root.Parent then connection:Disconnect()return end
  if main and not main.Visible then return end
  elapsed=elapsed+math.min(dt,.1)root.Rotation=(elapsed*35)%360
  local color=Color3.fromHSV((elapsed/12)%1,.78,1)
  for _,line in ipairs(lines)do line.BackgroundColor3=color end
 end)
 return connection
end
