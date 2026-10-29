-- Source-reviewed visual systems. Provenance and integration differences:
-- docs/Visual-Source-Audit.md. No source loader, telemetry or server remotes.
return function(c)
    local W,P,R,I,L=c.Workspace,c.Players,c.Run,c.Input,c.Lighting
    local me=P.LocalPlayer
    local v=c.Controls
    local group,toggle,slider,color,field,choice,panel=c.Group,c.Toggle,c.Slider,c.Color,c.Field,c.Choice,c.Panel
    local make,patch,unpatch=c.Make,c.Patch,c.Unpatch
    for key,owner in pairs({jumpCircleColor="jumpCircleEnabled",bodyTrailColor="bodyTrailEnabled",bodyTrailStart="bodyTrailEnabled",bodyTrailEnd="bodyTrailEnabled",
        snowColor="snowEnabled",boxColor="boxEnabled",skeletonColor="skeletonEnabled",traceColor="traceEnabled",selfESPColor="selfESP",blobESPColor="blobESP",
        antiKickColor="antiKickESP",oceanColor="oceanAppearance",holeColor="holeSprite"}) do c.ColorOwners[key]=owner end
    for _,part in ipairs({"Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg"}) do c.ColorOwners["body"..part.."Color"]="bodyAppearance" end
    local dead=false
    local objects,links={},{}
    local teardown=function()
        dead=true
        for con in pairs(links) do pcall(function() con:Disconnect() end) end
        for o in pairs(objects) do pcall(function() o:Destroy() end) end
        pcall(function() R:UnbindFromRenderStep("PrimeVisualsCinematicCamera") end)
    end
    c.TrackCleanup(function() teardown() end)
    local function create(class,props,parent)
        local o=make(class,props,parent) objects[o]=true return o
    end
    local function destroy(o) if o then objects[o]=nil o:Destroy() end end
    local function connect(signal,fn)
        local con=signal:Connect(function(...) if not dead then fn(...) end end) links[con]=true return con
    end
    local function disconnect(con) if con then links[con]=nil con:Disconnect() end end
    local function job(name,signal,fn) c.Job("Expansion / "..name,signal,fn) end
    local function root(p) return p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
    local function humanoid(p) return p and p.Character and p.Character:FindFirstChildOfClass("Humanoid") end
    local function selected(p) return p~=me and c.Selected(p) end
    local function target(key)
        local name=tostring(v[key or "visualTarget"] or ""):lower():gsub("^@","")
        for _,p in ipairs(P:GetPlayers()) do if p~=me and p.Name:lower()==name then return p end end
    end
    local function seq(points)
        local out={} for _,p in ipairs(points) do out[#out+1]=NumberSequenceKeypoint.new(p[1],p[2]) end
        return NumberSequence.new(out)
    end
    local function id(value,default)
        if value=="" or value==nil then return default end
        return c.ImageId(value)
    end
    -- Each optional effect owns its instances. Root removal is repaired on demand.
    local world,screen
    local function worldRoot()
        if not world or world.Parent~=W then destroy(world) world=create("Folder",{Name="PV_VisualExpansion"},W) end
        return world
    end
    local function screenRoot()
        if not screen or screen.Parent~=c.PlayerGui then
            destroy(screen) screen=create("ScreenGui",{Name="PV_VisualOverlay",IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=850},c.PlayerGui)
        end
        return screen
    end
    local function segment(frame,a,b,tint,width,alpha)
        local dx,dy=b.X-a.X,b.Y-a.Y
        frame.Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),width)
        frame.Position=UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2)
        frame.Rotation=math.deg(math.atan2(dy,dx)) frame.BackgroundColor3=tint
        frame.BackgroundTransparency=alpha or 0 frame.Visible=true
    end
    local function line(parent)
        return create("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BorderSizePixel=0,Visible=false},parent)
    end
    local function project(camera,position)
        local p,on=camera:WorldToViewportPoint(position)
        if on and p.Z>0 then return Vector2.new(p.X,p.Y) end
    end
    -- Jump Circle: source ground ray, original texture, 3 -> 15 studs, 2 s Quad.Out.
    local rings={}
    local jumpHum,jumpCon,lastJump=nil,nil,-math.huge
    local function circle(character)
        if os.clock()-lastJump<0.15 or not character then return end
        local r=character:FindFirstChild("HumanoidRootPart") if not r then return end
        local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances={character,worldRoot()}
        local hit=W:Raycast(r.Position,Vector3.new(0,-20,0),rp) if not hit then return end
        lastJump=os.clock()
        local part=create("Part",{Name="PV_JumpCircle",Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,Transparency=1,
            Size=Vector3.new(v.jumpCircleSize,0.05,v.jumpCircleSize),CFrame=CFrame.new(hit.Position+Vector3.new(0,0.04,0))},worldRoot())
        local surface=make("SurfaceGui",{Face=Enum.NormalId.Top,AlwaysOnTop=true,LightInfluence=0,PixelsPerStud=50},part)
        local image=make("ImageLabel",{Name="Ring",BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
            Image=id(v.jumpCircleImage,"rbxassetid://71544661109805"),ImageColor3=v.jumpCircleColor,ScaleType=Enum.ScaleType.Stretch},surface)
        rings[part]={image=image,started=os.clock(),duration=v.jumpCircleLife}
        -- Bound simultaneous bursts, including repeated Jumping events.
        local count=0 local oldest,stamp
        for p,e in pairs(rings) do count=count+1 if not stamp or e.started<stamp then oldest,stamp=p,e.started end end
        if count>16 then rings[oldest]=nil destroy(oldest) end
    end
    local function updateJump()
        local h=v.jumpCircleEnabled and humanoid(me) or nil
        if h~=jumpHum then
            disconnect(jumpCon) jumpCon=nil jumpHum=h
            if h then jumpCon=connect(h.StateChanged,function(_,new)
                if v.jumpCircleEnabled and new==Enum.HumanoidStateType.Jumping then circle(h.Parent) end
            end) end
        end
        if not v.jumpCircleEnabled then for p in pairs(rings) do destroy(p) rings[p]=nil end end
    end
    local movementGroup=group("Character","Movement visuals",2)
    do
        local g=movementGroup
        toggle(g,"jumpCircleEnabled","Jump circle",false,updateJump)
        local h=panel("jumpCircleEnabled")
        color(h,"jumpCircleColor","Color",Color3.new(1,1,1),function() end)
        field(h,"jumpCircleImage","Image","71544661109805",function(value) id(value,"") end)
        slider(h,"jumpCircleSize","Diameter",3,30,15,0.5,function() end)
        slider(h,"jumpCircleLife","Lifetime",0.2,5,2,0.1,function() end)
    end
    -- Native Trail with original vertical attachments (+2/-2), gradient priority and fading.
    local trail,a0,a1,trailRoot
    local function updateTrail()
        local r=v.bodyTrailEnabled and root(me) or nil
        if not r or r~=trailRoot or not trail or not trail.Parent or not a0 or not a0.Parent or not a1 or not a1.Parent then
            destroy(trail) destroy(a0) destroy(a1) trail,a0,a1,trailRoot=nil,nil,nil,nil
            if not r then return end
            a0=create("Attachment",{Name="PV_TrailTop",Position=Vector3.new(0,2,0)},r)
            a1=create("Attachment",{Name="PV_TrailBottom",Position=Vector3.new(0,-2,0)},r)
            trail=create("Trail",{Name="PV_BodyTrail",Attachment0=a0,Attachment1=a1,LightEmission=0.2,Enabled=true},r)
            trailRoot=r
        end
        trail.Enabled=true trail.Lifetime=v.bodyTrailLife
        trail.Transparency=seq({{0,v.bodyTrailFade},{1,1}})
        trail.Color=v.bodyTrailGradient and ColorSequence.new(v.bodyTrailStart,v.bodyTrailEnd) or ColorSequence.new(v.bodyTrailColor)
    end
    do
        local g=movementGroup
        toggle(g,"bodyTrailEnabled","Character trail",false,updateTrail)
        g=panel("bodyTrailEnabled")
        slider(g,"bodyTrailLife","Lifetime",0.1,3,0.5,0.1,updateTrail)
        slider(g,"bodyTrailFade","Initial transparency",0,1,0,0.01,updateTrail)
        color(g,"bodyTrailColor","Color",Color3.fromRGB(0,255,255),updateTrail)
        toggle(g,"bodyTrailGradient","Gradient",false,updateTrail)
        color(g,"bodyTrailStart","Gradient start",Color3.fromRGB(0,86,255),updateTrail)
        color(g,"bodyTrailEnd","Gradient end",Color3.fromRGB(255,0,0),updateTrail)
    end
    -- Original four disintegration layers; counts/lifetimes/curves are source values.
    local dustLayers={
        {count=55,life={3.8,6.5},speed={0.35,1.8},drag=4.5,wind=3,fall=-1.5,
            size={{0,0.035},{0.1,0.13},{0.3,0.19},{0.65,0.11},{0.9,0.045},{1,0}},alpha={{0,0.05},{0.4,0.08},{0.72,0.25},{1,1}}},
        {count=35,life={4.5,7},speed={0.2,1.1},drag=6,wind=2.25,fall=-0.9,
            size={{0,0.08},{0.2,0.25},{0.5,0.21},{0.8,0.1},{1,0}},alpha={{0,0.55},{0.2,0.72},{0.55,0.8},{1,1}}},
        {count=12,life={2.5,4.5},speed={0.4,2.4},drag=5,wind=3.75,fall=-1.1,
            size={{0,0.12},{0.12,0.34},{0.3,0.26},{0.7,0.12},{1,0}},alpha={{0,0.05},{0.25,0.2},{0.65,0.55},{1,1}}},
        {count=28,life={2.8,5.5},speed={0.15,1},drag=7,wind=4.5,fall=-0.7,
            size={{0,0.018},{0.25,0.045},{0.7,0.025},{1,0}},alpha={{0,0.1},{0.7,0.45},{1,1}}},
    }
    local dustPalette={{255,253,255},{244,239,255},{232,222,249},{217,201,239},{199,178,229},{181,157,216}}
    local dustHum,dusted,dustBursts={},{},{}
    local function dustCharacter(character)
        if dead or not v.deathDustEnabled or not character or dusted[character] then return end
        dusted[character]={}
        local points={}
        for _,part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" and part.Transparency<1 and part.Size.Magnitude>0.15 then
                for _=1,6 do
                    if #points>=70 then break end
                    local s=part.Size*0.45
                    points[#points+1]=part.CFrame:PointToWorldSpace(Vector3.new((math.random()-0.5)*s.X*2,(math.random()-0.5)*s.Y*2,(math.random()-0.5)*s.Z*2))
                end
            end
        end
        local burst=create("Folder",{Name="PV_DeathDust"},worldRoot()) dustBursts[burst]=os.clock()
        local count=0 local oldest,stamp
        for b,t in pairs(dustBursts) do count=count+1 if not stamp or t<stamp then oldest,stamp=b,t end end
        if count>8 then dustBursts[oldest]=nil destroy(oldest) end
        for _,position in ipairs(points) do
            local p=make("Part",{Size=Vector3.new(0.05,0.05,0.05),Position=position,Anchored=true,Transparency=1,CanCollide=false,CanQuery=false,CanTouch=false,CastShadow=false},burst)
            for _,layer in ipairs(dustLayers) do
                local rgb=dustPalette[math.random(1,#dustPalette)]
                local attachment=make("Attachment",{},p)
                local e=make("ParticleEmitter",{Texture="rbxasset://textures/particles/sparkles_main.dds",Rate=0,Enabled=false,LightEmission=1,LightInfluence=0,
                    Color=ColorSequence.new(Color3.fromRGB(rgb[1],rgb[2],rgb[3])),SpreadAngle=Vector2.new(180,180),Rotation=NumberRange.new(0,360),RotSpeed=NumberRange.new(-25,25),
                    Lifetime=NumberRange.new(layer.life[1],layer.life[2]),Speed=NumberRange.new(layer.speed[1],layer.speed[2]),Drag=layer.drag,
                    Acceleration=Vector3.new((math.random()-0.5)*layer.wind,layer.fall,(math.random()-0.5)*layer.wind),Size=seq(layer.size),Transparency=seq(layer.alpha)},attachment)
                e.Shape=Enum.ParticleEmitterShape.Sphere e.ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume e:Emit(layer.count)
            end
        end
        for _,part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                dusted[character][#dusted[character]+1]=part patch("deathDust",part,"LocalTransparencyModifier",1)
            elseif part:IsA("Decal") or part:IsA("Texture") then
                dusted[character][#dusted[character]+1]=part patch("deathDust",part,"Transparency",1)
            end
        end
    end
    local function watchDust(h)
        if not h:IsA("Humanoid") or dustHum[h] then return end
        local list={}
        list[1]=connect(h.Died,function() dustCharacter(h.Parent) end)
        list[2]=connect(h.HealthChanged,function(health) if health<=0 then dustCharacter(h.Parent) end end)
        dustHum[h]=list
    end
    local function updateDust(on)
        job("New death actors")
        if not on then
            for h,list in pairs(dustHum) do for _,con in ipairs(list) do disconnect(con) end dustHum[h]=nil end
            for b in pairs(dustBursts) do destroy(b) dustBursts[b]=nil end dusted={}
            unpatch("deathDust") return
        end
        for _,o in ipairs(W:GetDescendants()) do watchDust(o) end
        job("New death actors",W.DescendantAdded,watchDust)
    end
    do
        local g=group("Character","Death visuals",1)
        toggle(g,"deathDustEnabled","Disintegration dust",false,updateDust)
        connect(P.PlayerRemoving,function(p) if v.deathDustEnabled then dustCharacter(p.Character) end end)
    end
    -- Three source snow layers, not a replacement for the existing generic particles.
    local snow={}
    local function updateSnow()
        if not v.snowEnabled then for _,e in ipairs(snow) do destroy(e.part) end snow={} return end
        for i=1,3 do
            local e=snow[i]
            if not e or not e.part.Parent or not e.emitter.Parent then
                if e then destroy(e.part) end
                local p=create("Part",{Name="PV_SnowLayer"..i,Anchored=true,Transparency=1,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false},worldRoot())
                local emitter=make("ParticleEmitter",{EmissionDirection=Enum.NormalId.Bottom,SpreadAngle=Vector2.new(180,180),Lifetime=NumberRange.new(7+i,12+i),
                    Drag=2.1,Rotation=NumberRange.new(-180,180),RotSpeed=NumberRange.new(-55,55),LightEmission=0.55,LightInfluence=0.06,LockedToPart=false},p)
                e={part=p,emitter=emitter,phase=math.random()*10} snow[i]=e
            end
            local em=e.emitter local size=v.snowSize*({1,0.72,0.48})[i]
            e.part.Size=Vector3.new(v.snowArea,2,v.snowArea) em.Enabled=true
            em.Texture=v.snowTexture=="Classic" and "rbxasset://textures/particles/sparkles_main.dds" or "rbxasset://textures/particles/smoke_main.dds"
            em.Rate=math.max(2,v.snowDensity/3)*({1,0.65,0.38})[i] em.Color=ColorSequence.new(v.snowColor)
            em.Speed=NumberRange.new(v.snowSpeed*0.45,v.snowSpeed*(1.05+i*0.08)) em.Acceleration=Vector3.new(v.snowWind*(0.7+i*0.15),-v.snowSpeed*0.92,0)
            em.Size=seq({{0,0},{0.13,size},{0.86,size*0.86},{1,0}}) em.Transparency=seq({{0,1},{0.16,0.08},{0.86,0.22},{1,1}})
        end
    end
    do
        local g=group("Particles","Snowfall",2)
        toggle(g,"snowEnabled","Layered snowfall",false,updateSnow) g=panel("snowEnabled")
        choice(g,"snowTexture","Particle",{"Classic","Snowflake 1"},"Classic",updateSnow)
        color(g,"snowColor","Color",Color3.fromRGB(250,252,255),updateSnow)
        slider(g,"snowDensity","Density",20,1200,180,1,updateSnow)
        slider(g,"snowSize","Size",0.05,2.2,0.7,0.01,updateSnow)
        slider(g,"snowSpeed","Speed",1,30,7,1,updateSnow)
        slider(g,"snowWind","Wind",-25,25,0,1,updateSnow)
        slider(g,"snowArea","Area",120,650,320,1,updateSnow)
        slider(g,"snowHeight","Height",25,140,70,1,updateSnow)
    end
    -- Frame-based source Box/Skeleton geometry, independent from Drawing API.
    local r6={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
    local r15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
        {"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
    local geometry={}
    local function updateGeometry()
        local camera=W.CurrentCamera local seen={}
        if camera and (v.boxEnabled or v.skeletonEnabled) then
            for _,p in ipairs(P:GetPlayers()) do
                local h=humanoid(p) local r=root(p)
                if selected(p) and h and h.Health>0 and r and (r.Position-camera.CFrame.Position).Magnitude<=v.geometryDistance then
                    seen[p]=true
                    local entry=geometry[p]
                    if not entry or not entry.folder.Parent or entry.folder.Parent~=screenRoot() then
                        if entry then destroy(entry.folder) end
                        entry={folder=create("Frame",{Name="PV_Geometry_"..p.Name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1},screenRoot()),lines={}} geometry[p]=entry
                        for i=1,24 do entry.lines[i]=make("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BorderSizePixel=0,Visible=false},entry.folder) end
                    end
                    for _,l in ipairs(entry.lines) do l.Visible=false end
                    local n=1 local char=p.Character
                    if v.boxEnabled then
                        local cf,size=char:GetBoundingBox() local xmin,xmax,ymin,ymax
                        -- Require every corner in front; partial near-plane boxes otherwise explode.
                        local complete=true
                        for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
                            local q=camera:WorldToViewportPoint((cf*CFrame.new(x*size.X/2,y*size.Y/2,z*size.Z/2)).Position)
                            if q.Z<=0 then complete=false else
                                xmin=xmin and math.min(xmin,q.X) or q.X xmax=xmax and math.max(xmax,q.X) or q.X
                                ymin=ymin and math.min(ymin,q.Y) or q.Y ymax=ymax and math.max(ymax,q.Y) or q.Y
                            end
                        end end end
                        if complete and xmin and xmax>=0 and ymax>=0 and xmin<=camera.ViewportSize.X and ymin<=camera.ViewportSize.Y then
                            local corners={Vector2.new(xmin,ymin),Vector2.new(xmax,ymin),Vector2.new(xmax,ymax),Vector2.new(xmin,ymax)}
                            for i=1,4 do segment(entry.lines[n],corners[i],corners[i%4+1],v.boxColor,v.boxThickness) n=n+1 end
                        end
                    end
                    if v.skeletonEnabled then
                        for _,pair in ipairs(char:FindFirstChild("UpperTorso") and r15 or r6) do
                            local a,b=char:FindFirstChild(pair[1]),char:FindFirstChild(pair[2])
                            if a and b then
                                local qa,qb=project(camera,a.Position),project(camera,b.Position)
                                if qa and qb then segment(entry.lines[n],qa,qb,v.skeletonColor,v.skeletonThickness) n=n+1 end
                            end
                        end
                    end
                end
            end
        end
        for p,e in pairs(geometry) do if not seen[p] then destroy(e.folder) geometry[p]=nil end end
    end
    do
        local g=group("ESP","Geometry",1)
        toggle(g,"boxEnabled","Box ESP",false,updateGeometry)
        local h=panel("boxEnabled") color(h,"boxColor","Color",Color3.new(1,1,1),function() end)
        slider(h,"boxThickness","Thickness",1,4,1,1,function() end)
        slider(h,"geometryDistance","Maximum distance",50,5000,1000,1,function() end)
        toggle(g,"skeletonEnabled","Skeleton ESP",false,updateGeometry)
        h=panel("skeletonEnabled") color(h,"skeletonColor","Color",Color3.new(1,1,1),function() end)
        slider(h,"skeletonThickness","Thickness",1,4,1,1,function() end)
    end
    -- The source trace reads a combat target; our isolated target is a Roblox username.
    local traceLine,traceGlow,traceBill,traceImage
    local function clearTrace()
        destroy(traceLine) destroy(traceGlow) destroy(traceBill) traceLine,traceGlow,traceBill,traceImage=nil,nil,nil,nil
    end
    local function updateTrace(dt)
        if not v.traceEnabled then clearTrace() return end
        if not traceLine or traceLine.Parent~=screenRoot() then
            clearTrace() traceLine=line(screenRoot()) traceGlow=line(screenRoot()) traceLine.ZIndex=2 traceGlow.ZIndex=1
            traceBill=create("BillboardGui",{Name="PV_TraceMarker",AlwaysOnTop=true,Enabled=false},c.PlayerGui)
            traceImage=make("ImageLabel",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Rotation=0},traceBill)
        end
        traceLine.Visible=false traceGlow.Visible=false traceBill.Enabled=false
        local a,b=root(me),root(target()) local camera=W.CurrentCamera
        if not a or not b or not camera then return end
        local qa,qb=project(camera,a.Position),project(camera,b.Position) if not qa or not qb then return end
        local width=2+math.sin(os.clock()*8)
        segment(traceLine,qa,qb,v.traceColor,width) segment(traceGlow,qa,qb,v.traceColor,width+4,0.45)
        traceBill.Enabled=v.traceMarker traceBill.Adornee=b traceBill.Size=UDim2.fromOffset(v.traceMarkerSize,v.traceMarkerSize)
        traceImage.Image=id(v.traceMarkerImage,"rbxassetid://124302285576089") traceImage.ImageColor3=v.traceColor
        traceImage.Rotation=(traceImage.Rotation+60*dt)%360
    end
    do
        local g=group("ESP","Target trace",2)
        toggle(g,"traceEnabled","Trace to player",false,function(on) if not on then clearTrace() end end)
        g=panel("traceEnabled")
        field(g,"visualTarget","Player username","",function() end)
        color(g,"traceColor","Color",Color3.fromRGB(168,85,247),function() end)
        toggle(g,"traceMarker","Target marker",false,function() end)
        slider(g,"traceMarkerSize","Marker size",10,200,42,1,function() end)
        field(g,"traceMarkerImage","Marker image","124302285576089",function(value) id(value,"") end)
    end
    -- Cosmetic object ESP: actual source name rules and item icon IDs.
    local itemDefs={
        {"Banana",18383839594,{255,221,51},"banana","peel"},{"Snowball",13681767492,{255,255,255},"snowball"},
        {"Shuriken",106219288648232,{205,210,215},"shuriken"},{"Kunai",13626208096,{125,130,135},"kunai"},{"Pickaxe",4503278233,{140,95,55},"pickaxe"},
    }
    local markers={}
    local function marker(o,key,tint,alpha,icon,name)
        local part=o:IsA("BasePart") and o or o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart",true) if not part then return end
        local entry=markers[key] and markers[key][o]
        markers[key]=markers[key] or {}
        if not entry or not entry.folder.Parent or not entry.hi.Parent or (entry.bill and not entry.bill.Parent) then
            if entry then destroy(entry.folder) end
            local f=create("Folder",{Name="PV_"..key},worldRoot())
            entry={folder=f,hi=make("Highlight",{Adornee=o,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,OutlineTransparency=0},f)} markers[key][o]=entry
            if icon then
                entry.bill=make("BillboardGui",{Adornee=part,AlwaysOnTop=true,StudsOffset=Vector3.new(0,2.2,0)},f)
                entry.image=make("ImageLabel",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},entry.bill)
                entry.nameBill=make("BillboardGui",{Adornee=part,AlwaysOnTop=true,Size=UDim2.fromOffset(130,20),StudsOffset=Vector3.new(0,3.6,0)},f)
                entry.text=make("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Font=Enum.Font.GothamBold,TextSize=14,TextStrokeTransparency=0.4},entry.nameBill)
            end
        end
        entry.seen=true entry.hi.FillColor=tint entry.hi.OutlineColor=tint entry.hi.FillTransparency=alpha
        if entry.bill then
            entry.bill.Size=UDim2.fromOffset(v.combatIconSize,v.combatIconSize) entry.image.Image="rbxassetid://"..icon
            entry.nameBill.Enabled=v.combatNames entry.text.Text=name entry.text.TextColor3=tint
        end
    end
    local function updateMarkers()
        for _,set in pairs(markers) do for _,e in pairs(set) do e.seen=false end end
        if v.selfESP and me.Character then marker(me.Character,"SelfESP",v.selfESPColor,0.45) end
        if v.blobESP or v.antiKickESP or v.combatESP then
            for _,container in ipairs(W:GetChildren()) do
                local toys=container.Name:find("SpawnedInToys",1,true)
                local own=container.Name==me.Name.."SpawnedInToys"
                if toys then for _,o in ipairs(container:GetChildren()) do
                    if v.blobESP and (o.Name=="CreatureBlobman" or o.Name=="Gucci") then marker(o,"BlobESP",v.blobESPColor,0.4) end
                    if v.antiKickESP and not (v.antiKickOthers and own) then
                        for _,needle in ipairs({"Shuriken","Kunai","Plate","Pickaxe","Pallet"}) do
                            if o.Name:find(needle,1,true) then marker(o,"AntiKickESP",v.antiKickColor,v.antiKickFill) break end
                        end
                    end
                end end
                if v.combatESP then
                    local candidates=(toys or container.Name=="PlotItems" or container.Name=="Debris") and container:GetDescendants() or {container}
                    for _,o in ipairs(candidates) do if o:IsA("Model") or o:IsA("BasePart") then
                        local name=o.Name:lower():gsub("%s+","")
                        for _,d in ipairs(itemDefs) do
                            if v["combat"..d[1]] and name:find(d[4],1,true) and not (d[5] and name:find(d[5],1,true)) then
                                -- Prefer the enclosing matched Model to avoid duplicate icons on its parts.
                                local ancestor=o.Parent local nested=false
                                while ancestor and ancestor~=container do if ancestor:IsA("Model") and ancestor.Name:lower():gsub("%s+",""):find(d[4],1,true) then nested=true break end ancestor=ancestor.Parent end
                                if not nested then marker(o,"CombatESP",Color3.fromRGB(d[3][1],d[3][2],d[3][3]),v.combatFill,d[2],d[1]) end
                                break
                            end
                        end
                    end end
                end
            end
        end
        if v.revealInvisible then
            for _,p in ipairs(P:GetPlayers()) do if p~=me and p.Character then
                local invisible=false
                for _,part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") and part.Name~="HumanoidRootPart" and part.Transparency>=0.9 then invisible=true break end end
                if invisible or (markers.Invisible and markers.Invisible[p.Character]) then
                    for _,part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then patch("revealInvisible",part,"Transparency",math.min(part.Transparency,0.55)) end end
                    marker(p.Character,"Invisible",Color3.fromRGB(255,80,80),0.5)
                end
            end end
        else unpatch("revealInvisible") end
        for _,set in pairs(markers) do for o,e in pairs(set) do if not e.seen or not o.Parent then destroy(e.folder) set[o]=nil end end end
    end
    local function markerColor(key)
        return function(value)
            for _,e in pairs(markers[key] or {}) do e.hi.FillColor=value e.hi.OutlineColor=value end
        end
    end
    do
        local g=group("Character","Self ESP",1)
        toggle(g,"selfESP","Self highlight",false,updateMarkers) g=panel("selfESP")
        color(g,"selfESPColor","Color",Color3.fromRGB(96,76,214),updateMarkers,markerColor("SelfESP"))
        g=group("ESP","Object highlights",2)
        toggle(g,"blobESP","Blobman / Gucci ESP",false,updateMarkers)
        color(panel("blobESP"),"blobESPColor","Color",Color3.fromRGB(96,76,214),updateMarkers,markerColor("BlobESP"))
        toggle(g,"antiKickESP","Anti-kick objects ESP",false,updateMarkers)
        local h=panel("antiKickESP") color(h,"antiKickColor","Color",Color3.fromRGB(255,80,80),updateMarkers,markerColor("AntiKickESP"))
        slider(h,"antiKickFill","Fill transparency",0,1,0.55,0.01,updateMarkers)
        toggle(h,"antiKickOthers","Other players only",true,updateMarkers)
        toggle(g,"combatESP","Combat items ESP",false,updateMarkers) h=panel("combatESP")
        for _,d in ipairs(itemDefs) do toggle(h,"combat"..d[1],d[1],d[1]=="Shuriken" or d[1]=="Kunai",updateMarkers) end
        toggle(h,"combatNames","Item names",false,updateMarkers)
        slider(h,"combatFill","Fill transparency",0,1,0.55,0.01,updateMarkers)
        slider(h,"combatIconSize","Icon size",16,80,36,1,updateMarkers)
        toggle(g,"revealInvisible","Reveal invisible characters",false,updateMarkers)
    end
    -- Ocean appearance is separate from terrain conversion and preserves the native path.
    local oceanParts={}
    local function updateOcean()
        if not v.oceanAppearance then unpatch("oceanAppearance") oceanParts={} return end
        local o=W:FindFirstChild("Map")
        for _,name in ipairs({"AlwaysHereTweenedObjects","Ocean","Object","ObjectModel"}) do o=o and o:FindFirstChild(name) end
        local seen={}
        if o then
            local parts=o:IsA("BasePart") and {o} or o:GetDescendants()
            for _,part in ipairs(parts) do if part:IsA("BasePart") then
                seen[part]=true patch("oceanAppearance",part,"Material",Enum.Material[v.oceanMaterial])
                if v.oceanTint then patch("oceanColor",part,"Color",v.oceanColor) else unpatch("oceanColor",part) end
            end end
        end
        for part in pairs(oceanParts) do if not seen[part] then unpatch("oceanAppearance",part) unpatch("oceanColor",part) end end
        oceanParts=seen
    end
    do
        local g=group("World","Ocean appearance",2)
        toggle(g,"oceanAppearance","Ocean material and color",false,function(on)
            if not on then unpatch("oceanColor") end updateOcean()
        end)
        g=panel("oceanAppearance")
        choice(g,"oceanMaterial","Material",{"Water","Ice","Neon","Glass","Slate","Basalt"},"Water",updateOcean)
        toggle(g,"oceanTint","Custom color",false,updateOcean)
        color(g,"oceanColor","Color",Color3.fromRGB(0,170,255),updateOcean)
    end
    -- Six source body-color/transparency controls, extended to R15 without severing joints.
    local bodyGroups={
        {"Head",{"Head"},"HeadColor3"},{"Torso",{"Torso","UpperTorso","LowerTorso"},"TorsoColor3"},
        {"LeftArm",{"Left Arm","LeftUpperArm","LeftLowerArm","LeftHand"},"LeftArmColor3"},
        {"RightArm",{"Right Arm","RightUpperArm","RightLowerArm","RightHand"},"RightArmColor3"},
        {"LeftLeg",{"Left Leg","LeftUpperLeg","LeftLowerLeg","LeftFoot"},"LeftLegColor3"},
        {"RightLeg",{"Right Leg","RightUpperLeg","RightLowerLeg","RightFoot"},"RightLegColor3"},
    }
    local appearanceCharacter
    local function updateAppearance()
        if not v.bodyAppearance then unpatch("bodyAppearance") appearanceCharacter=nil return end
        local char=me.Character if not char then return end
        if appearanceCharacter~=char then unpatch("bodyAppearance") unpatch("bodyAccessories") unpatch("bodyFace") appearanceCharacter=char end
        local bodyColors=char:FindFirstChildOfClass("BodyColors")
        for _,d in ipairs(bodyGroups) do
            if bodyColors then patch("bodyAppearance",bodyColors,d[3],v["body"..d[1].."Color"]) end
            for _,name in ipairs(d[2]) do
                local p=char:FindFirstChild(name)
                if p and p:IsA("BasePart") then
                    patch("bodyAppearance",p,"Color",v["body"..d[1].."Color"])
                    patch("bodyAppearance",p,"Transparency",v["body"..d[1].."Alpha"])
                end
            end
        end
        for _,o in ipairs(char:GetDescendants()) do
            local ancestor=o.Parent local accessory=false
            while ancestor and ancestor~=char do
                if ancestor:IsA("Accessory") or ancestor:IsA("Hat") then accessory=true break end ancestor=ancestor.Parent
            end
            if o:IsA("BasePart") and accessory then
                if v.bodyHideAccessories then patch("bodyAccessories",o,"Transparency",1) else unpatch("bodyAccessories",o) end
            elseif (o:IsA("Decal") or o:IsA("Texture")) and o.Parent and o.Parent.Name=="Head" then
                if v.bodyHideFace then patch("bodyFace",o,"Transparency",1) else unpatch("bodyFace",o) end
            end
        end
    end
    do
        local g=group("Character","Body appearance",1)
        toggle(g,"bodyAppearance","Body colors and transparency",false,function(on)
            if not on then unpatch("bodyAccessories") unpatch("bodyFace") end updateAppearance()
        end) g=panel("bodyAppearance")
        toggle(g,"bodyHideAccessories","Hide accessories",false,updateAppearance)
        toggle(g,"bodyHideFace","Hide face",false,updateAppearance)
        for _,d in ipairs(bodyGroups) do
            color(g,"body"..d[1].."Color",d[1].." color",Color3.new(1,1,1),updateAppearance)
            slider(g,"body"..d[1].."Alpha",d[1].." transparency",0,1,0,0.1,updateAppearance)
        end
    end
    -- Source blackhole image: camera-facing sprite, pulse, rotation and ten-second fade.
    local holes={}
    local function clearHoles()
        for model,e in pairs(holes) do destroy(e.part) holes[model]=nil end unpatch("blackholeSprite")
    end
    local function discoverHole(model)
        if holes[model] or (not model.Name:lower():find("blackhole",1,true) and model.Name~="StayedBH") then return end
        if model==world or (world and model:IsDescendantOf(world)) then return end
        if not (model:IsA("BasePart") or model:IsA("Model") or model:IsA("Folder")) then return end
        local part=model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart",true)
        if not part or (v.holeHideOrigin and part.Position.Magnitude<25) then return end
        local anchor=create("Part",{Name="PV_BlackholeSprite",Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,Transparency=1,Size=Vector3.new(1,1,1)},worldRoot())
        local bill=make("BillboardGui",{Adornee=anchor,AlwaysOnTop=true},anchor)
        local image=make("ImageLabel",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Rotation=math.random(0,359)},bill)
        holes[model]={part=anchor,source=part,bill=bill,image=image,started=os.clock(),hidden={}}
    end
    local function updateHoles(dt)
        if not v.holeSprite then clearHoles() return end
        for model,e in pairs(holes) do
            if not model.Parent or not e.source.Parent then
                destroy(e.part) for _,o in ipairs(e.hidden) do unpatch("blackholeSprite",o) end holes[model]=nil
            else
                if not v.holeHideOriginal and #e.hidden>0 then for _,o in ipairs(e.hidden) do unpatch("blackholeSprite",o) end e.hidden={} end
                if not e.part.Parent and not e.expired then
                    for _,o in ipairs(e.hidden) do unpatch("blackholeSprite",o) end
                    destroy(e.part) holes[model]=nil discoverHole(model)
                elseif not e.expired then
                    local t=os.clock()-e.started
                    e.part.CFrame=e.source.CFrame
                    local scale=t<=4 and (1+0.28*math.sin(t/4*math.pi*2)) or math.clamp(1-(t-4)/6,0,1)
                    if t>4 then scale=scale*scale*(3-2*scale) end
                    local size=math.max(2,v.holeSize*scale) e.bill.Size=UDim2.fromOffset(size,size) e.bill.Enabled=t<10
                    e.image.Image=id(v.holeImage,"rbxassetid://8656483322") e.image.ImageColor3=v.holeColor
                    e.image.ImageTransparency=v.holeAlpha e.image.Rotation=(e.image.Rotation+54*dt)%360
                    if t>=10 then e.expired=true destroy(e.part) end
                    if v.holeHideOriginal then
                        local nodes=model:GetDescendants() if model:IsA("BasePart") then nodes[#nodes+1]=model end
                        for _,o in ipairs(nodes) do
                            if not e.hidden[o] then e.hidden[o]=true e.hidden[#e.hidden+1]=o end
                            if o:IsA("BasePart") then patch("blackholeSprite",o,"LocalTransparencyModifier",1)
                            elseif o:IsA("BillboardGui") or o:IsA("SurfaceGui") or o:IsA("ParticleEmitter") or o:IsA("Beam") or o:IsA("Trail") then patch("blackholeSprite",o,"Enabled",false)
                            elseif o:IsA("Decal") or o:IsA("Texture") then patch("blackholeSprite",o,"Transparency",1) end
                        end
                    elseif #e.hidden>0 then for _,o in ipairs(e.hidden) do unpatch("blackholeSprite",o) end e.hidden={} end
                end
            end
        end
    end
    local function toggleHoles(on)
        job("Blackhole sprites")
        clearHoles() if not on then return end
        for _,o in ipairs(W:GetDescendants()) do discoverHole(o) end
        job("Blackhole sprites",W.DescendantAdded,function(o)
            discoverHole(o)
            local parent=o.Parent
            while parent and parent~=W do discoverHole(parent) parent=parent.Parent end
        end)
    end
    do
        local g=group("Tweaks","Animated blackholes",2)
        toggle(g,"holeSprite","Animated blackhole image",false,toggleHoles) g=panel("holeSprite")
        field(g,"holeImage","Image","8656483322",function(value) id(value,"") end)
        color(g,"holeColor","Color",Color3.new(1,1,1),function() end)
        slider(g,"holeSize","Size",80,600,240,1,function() end)
        slider(g,"holeAlpha","Transparency",0,1,0,0.01,function() end)
        toggle(g,"holeHideOriginal","Hide original visual",true,function() end)
        toggle(g,"holeHideOrigin","Hide at map origin",true,function() toggleHoles(v.holeSprite) end)
    end
    -- Source "Server Position ESP" is a ping-delayed local history, not a server read.
    c.ColorOwners.serverGhostColor="serverGhostEnabled"
    local ghost={parts={},offsets={},history={},idle=0,vis=0}
    local function clearGhost()
        for _,p in ipairs(ghost.parts) do destroy(p) end
        ghost={parts={},offsets={},history={},idle=0,vis=0}
    end
    local function updateGhost(dt)
        if not v.serverGhostEnabled then if #ghost.parts>0 then clearGhost() end return end
        local r,h=root(me),humanoid(me) if not r or not h then clearGhost() return end
        if ghost.root~=r or not ghost.parts[1] or not ghost.parts[1].Parent then
            clearGhost() ghost.root=r
            local height=h.RigType==Enum.HumanoidRigType.R6 and 5.4 or math.max(h.HipHeight or 2,2)+3
            local half=Vector3.new(1.9,height,1.3)*0.5
            local length=math.max(0.26,0.22*math.min(1.9,height,1.3))
            local function add(shape,size,cf)
                ghost.parts[#ghost.parts+1]=create("Part",{Name="PV_EstimatedServerPosition",Shape=shape,Size=size,Anchored=true,CanCollide=false,
                    CanTouch=false,CanQuery=false,CastShadow=false,Massless=true,Material=Enum.Material.Neon,Transparency=1},worldRoot())
                ghost.offsets[#ghost.offsets+1]=cf
            end
            for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
                local corner=Vector3.new(x*half.X,y*half.Y-0.35,z*half.Z-0.05)
                add(Enum.PartType.Cylinder,Vector3.new(length,0.09,0.09),CFrame.new(x*(half.X-length/2),corner.Y,corner.Z))
                add(Enum.PartType.Cylinder,Vector3.new(length,0.09,0.09),CFrame.new(corner.X,y*(half.Y-length/2)-0.35,corner.Z)*CFrame.Angles(0,0,math.pi/2))
                add(Enum.PartType.Cylinder,Vector3.new(length,0.09,0.09),CFrame.new(corner.X,corner.Y,z*(half.Z-length/2)-0.05)*CFrame.Angles(0,math.pi/2,0))
                add(Enum.PartType.Ball,Vector3.new(0.171,0.171,0.171),CFrame.new(corner))
            end end end
        end
        local now=os.clock() local history=ghost.history
        history[#history+1]={time=now,cf=r.CFrame}
        while #history>1 and (history[1].time<now-2.5 or #history>300) do table.remove(history,1) end
        local ok,ping=pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
        ping=ok and type(ping)=="number" and ping==ping and math.clamp(ping,0,500) or 0
        local wanted=now-ping/1000 local cf=history[1].cf
        if wanted>=history[#history].time then cf=history[#history].cf else
            for i=#history,2,-1 do
                local a,b=history[i-1],history[i]
                if wanted>=a.time then cf=a.cf:Lerp(b.cf,math.clamp((wanted-a.time)/math.max(1e-6,b.time-a.time),0,1)) break end
            end
        end
        local velocity=r.AssemblyLinearVelocity or Vector3.zero
        ghost.idle=velocity.Magnitude>1.5 and 0 or ghost.idle+dt
        local desired=ghost.idle<0.55 and 1 or 0
        ghost.vis=math.clamp(ghost.vis+(desired-ghost.vis)*math.min(1,(desired>ghost.vis and 4.5 or 2.2)*dt),0,1)
        ghost.smooth=ghost.smooth and ghost.smooth:Lerp(cf,math.clamp(dt*12,0,1)) or cf
        for i,p in ipairs(ghost.parts) do
            p.CFrame=ghost.smooth*ghost.offsets[i] p.Color=v.serverGhostColor p.Transparency=1-0.88*ghost.vis^3
        end
    end
    do
        local g=group("ESP","Local position history",2)
        toggle(g,"serverGhostEnabled","Estimated server position",false,function(on) if not on then clearGhost() end end)
        g=panel("serverGhostEnabled")
        color(g,"serverGhostColor","Color",Color3.fromRGB(160,150,255),function() end)
        g:AddLabel("Client history delayed by ping; an estimate, not server telemetry.")
    end
    -- Named shader presets keep exact source parameter values; switching is exclusive.
    local rgb=Color3.fromRGB
    local presets={
        ["Pale Frost"]={light={ClockTime=0,GeographicLatitude=85,Brightness=1.1,Ambient=rgb(150,170,200),OutdoorAmbient=rgb(190,210,235),FogColor=rgb(240,245,255),
            FogStart=120,FogEnd=800,EnvironmentDiffuseScale=1,EnvironmentSpecularScale=1,GlobalShadows=true,ExposureCompensation=0.6},
            effects={{"Atmosphere",{Density=0.8,Offset=0.9,Color=rgb(235,242,255),Decay=rgb(190,205,225),Glare=0.05,Haze=10}},
                {"ColorCorrectionEffect",{Brightness=0.02,Contrast=0.15,Saturation=-0.65,TintColor=rgb(235,242,255)}},{"BloomEffect",{Intensity=0.85,Size=56,Threshold=0.7}},
                {"DepthOfFieldEffect",{FarIntensity=0.5,FocusDistance=50,InFocusRadius=30,NearIntensity=0}},{"SunRaysEffect",{Intensity=0.12,Spread=0.85}}}},
        ["Dreamy Night"]={light={ClockTime=0,Brightness=0.5},effects={{"BlurEffect",{Size=6}},{"BloomEffect",{Intensity=1.6,Size=90,Threshold=1.4}},
            {"ColorCorrectionEffect",{Brightness=0.15,Contrast=-0.1,Saturation=0.25,TintColor=rgb(210,220,255)}},{"SunRaysEffect",{Intensity=0.05,Spread=0.6}},
            {"Atmosphere",{Density=0.45,Offset=0.1,Color=rgb(180,190,255),Decay=rgb(120,130,180),Glare=0.2,Haze=2}}}},
        Tokyowami={light={Brightness=2.14,ColorShift_Bottom=rgb(11,0,20),ColorShift_Top=rgb(240,127,14),OutdoorAmbient=rgb(34,0,49),ClockTime=6.7,
            FogColor=rgb(94,76,106),FogEnd=1000,FogStart=0,ExposureCompensation=0.24,ShadowSoftness=0,Ambient=rgb(59,33,27)},
            effects={{"BloomEffect",{Intensity=0.1,Threshold=0,Size=100}},{"ColorCorrectionEffect",{Saturation=0.05,TintColor=rgb(255,224,219)}},
                {"SunRaysEffect",{Intensity=0.05}},{"BlurEffect",{Size=1}}},
            sky={SkyboxUp="rbxassetid://323493360",SkyboxLf="rbxassetid://323494252",SkyboxBk="rbxassetid://323494035",SkyboxFt="rbxassetid://323494130",
                SkyboxDn="rbxassetid://323494368",SkyboxRt="rbxassetid://323494067",SunAngularSize=14}},
    }
    local presetObjects={} local appliedPreset
    local function updatePreset()
        for _,o in ipairs(presetObjects) do destroy(o) end presetObjects={} appliedPreset=nil unpatch("visualPreset")
        if not v.visualPresetEnabled then return end
        local data=presets[v.visualPreset] if not data then return end
        for property,value in pairs(data.light) do patch("visualPreset",L,property,value) end
        if v.visualPreset=="Pale Frost" then
            for _,o in ipairs(L:GetChildren()) do
                if o:IsA("PostEffect") then patch("visualPreset",o,"Enabled",false)
                elseif o:IsA("Atmosphere") then patch("visualPreset",o,"Density",0) patch("visualPreset",o,"Haze",0) patch("visualPreset",o,"Glare",0) end
            end
        end
        for i,e in ipairs(data.effects) do
            local props={} for k,value in pairs(e[2]) do props[k]=value end props.Name="PV_Preset_"..i
            presetObjects[#presetObjects+1]=create(e[1],props,L)
        end
        if data.sky then
            local s=create("Sky",{Name="PV_PresetSky"},L) for k,value in pairs(data.sky) do s[k]=value end presetObjects[#presetObjects+1]=s
            -- Never parent two competing Sky instances. Restore exact original parents on exit.
            for _,o in ipairs(L:GetChildren()) do if o:IsA("Sky") and o~=s then patch("visualPreset",o,"Parent",nil) end end
        end
        appliedPreset=v.visualPreset
    end
    local function fullbright(on)
        unpatch("fullbright") if not on then return end
        for k,value in pairs({Brightness=2,ClockTime=14,FogEnd=100000,GlobalShadows=false,Ambient=rgb(178,178,178),OutdoorAmbient=rgb(178,178,178)}) do patch("fullbright",L,k,value) end
    end
    do
        local g=group("Lighting","Scene presets",2)
        toggle(g,"visualPresetEnabled","Atmosphere preset",false,updatePreset) local h=panel("visualPresetEnabled")
        choice(h,"visualPreset","Preset",{"Pale Frost","Dreamy Night","Tokyowami"},"Pale Frost",updatePreset)
        c.Action(h,"Edit selected preset",function() c.EditLighting(presets[v.visualPreset],v.visualPreset) end)
        toggle(g,"fullbrightEnabled","Fullbright",false,fullbright)
        g=group("Sky","Skybox collection",2)
        local names={} for name in pairs(c.Data.Skies) do names[#names+1]=name end table.sort(names)
        choice(g,"collectionSky","Skybox",names,"Nebula",function() end,c.Data.SkyAliases)
        c.Action(g,"Apply selected skybox",function() c.ApplySky(c.Data.Skies[v.collectionSky]) end)
    end
    -- Camera features use native transforms/input. Mouse sensitivity is never changed.
    local free={active=false,cameras={},humanoids={},parts={},menus={}}
    local hud,hudSpeed,hudHint,hudControls
    local function translated(text) return c.Translate and c.Translate(text) or text end
    local function updateHUD(speed,paused)
        if not hud or not hud.Parent or not screen or screen.Parent~=c.PlayerGui then
            disconnect(free.hudIcon) disconnect(free.hudClose) free.hudIcon=nil free.hudClose=nil destroy(hud)
            hud=create("Frame",{Name="PV_FreecamHUD",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-18,.55,0),
                Size=UDim2.fromOffset(222,98),BackgroundColor3=Color3.fromRGB(10,10,14),BackgroundTransparency=.08,BorderSizePixel=0},screenRoot())
            make("UICorner",{CornerRadius=UDim.new(0,5)},hud)
            make("UIStroke",{Color=Color3.fromRGB(160,106,255),Thickness=1,Transparency=.3},hud)
            local icon=make("ImageLabel",{Name="Brand",BackgroundTransparency=1,Position=UDim2.fromOffset(10,8),Size=UDim2.fromOffset(24,24),Image="",Visible=true,ZIndex=2},hud)
            if c.FreecamIcon then
                local ok,connection=pcall(c.FreecamIcon,icon,hud)
                if ok and connection then free.hudIcon=connection links[connection]=true end
            end
            make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(42,8),Size=UDim2.fromOffset(170,20),
                Text="Prime Visuals",TextColor3=Color3.fromRGB(235,232,245),Font=Enum.Font.BuilderSansBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},hud)
            local close=make("TextButton",{Name="CloseFreecam",Text="×",AutoButtonColor=true,BackgroundTransparency=1,
                Position=UDim2.new(1,-28,0,7),Size=UDim2.fromOffset(20,22),Font=Enum.Font.BuilderSansBold,
                TextSize=18,TextColor3=Color3.fromRGB(185,145,255)},hud)
            free.hudClose=connect(close.MouseButton1Click,function()
                if free.active then c.Setters.freeCameraEnabled(false,true) end
            end)
            hudSpeed=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,33),Size=UDim2.fromOffset(200,22),
                TextColor3=Color3.fromRGB(185,145,255),Font=Enum.Font.BuilderSansBold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left},hud)
            hudHint=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,59),Size=UDim2.fromOffset(200,16),
                TextColor3=Color3.fromRGB(190,185,205),Font=Enum.Font.BuilderSans,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},hud)
            hudControls=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,77),Size=UDim2.fromOffset(200,15),
                TextColor3=Color3.fromRGB(145,140,160),Font=Enum.Font.BuilderSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},hud)
        end
        hud.Visible=not paused
        hudSpeed.Text=translated("Speed").."  ·  "..tostring(math.floor(speed))
        hudHint.Text=translated(free.approach and "RMB: throw / return" or (free.interacting and "E: toy menu" or "RMB: approach · wheel: speed"))
        hudControls.Text=translated(free.interacting and "E: flight · F4: exit" or "E: objects · F4: exit")
    end
    local function visibleFreeBody()
        local char=me.Character
        if free.character~=char then
            job("Freecam parts") unpatch("freeBody") free.parts={} free.character=char
            local function add(part) if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then free.parts[part]=true end end
            if char then
                for _,part in ipairs(char:GetDescendants()) do add(part) end
                job("Freecam parts",char.DescendantAdded,add)
            end
        end
        for part in pairs(free.parts) do
            if not part.Parent or not char or not part:IsDescendantOf(char) then free.parts[part]=nil unpatch("freeBody",part)
            else patch("freeBody",part,"LocalTransparencyModifier",0) end
        end
    end
    -- Space ascent avoids E (FTAP toy-menu shortcut). Menu guards also cover activation itself.
    -- Also suppress recognized toy-menu containers for game listeners that ignore processed input.
    local toyMenus={toymenu=true,toysmenu=true,toymenugui=true,toysmenugui=true,spawntoymenu=true,
        spawnmenu=true,toyselection=true,toyselect=true,toyspawner=true,toyinventory=true,spawntoygui=true,spawnmenugui=true}
    local function hideToyMenu(object)
        if c.IsOwnUI and c.IsOwnUI(object) then return end
        if screen and (object==screen or object:IsDescendantOf(screen)) then return end
        local name=object.Name:lower():gsub("[%s_%-]","")
        local isScreen=object:IsA("ScreenGui")
        local isPanel=object:IsA("Frame") or object:IsA("ScrollingFrame")
        local known=toyMenus[name] or (name:find("toy",1,true) and (name:find("menu",1,true) or name:find("spawn",1,true)))
        local property=isScreen and "Enabled" or object:IsA("GuiObject") and "Visible"
        if not property then return end
        -- Snapshot closed game panels before switching CameraType. This catches
        -- unnamed game menus opened by the camera-mode change itself, not just E.
        local size=isPanel and object.AbsoluteSize
        local closed=object[property]==false and (isScreen or (size and size.X>=180 and size.Y>=100))
        if known or closed then
            if not free.menus[object] then
                free.menus[object]={property=property,connection=connect(object:GetPropertyChangedSignal(property),function()
                    if free.active and not free.menuReleased and object[property] then patch("freeToyMenu",object,property,false) end
                end)}
            end
            if not free.menuReleased then patch("freeToyMenu",object,property,false) end
        end
    end
    local function suppressToyMenus()
        for _,object in ipairs(c.PlayerGui:GetDescendants()) do hideToyMenu(object) end
    end
    local returnApproach
    local function releaseToyMenus()
        free.menuRequested=not free.interacting
        if not free.menuRequested then free.interacting=false free.look=Vector2.zero free.velocity=Vector3.zero end
        if free.menuReleased then return end
        free.menuReleased=true
        unpatch("freeToyMenu")
    end
    local function syncToyMenu()
        local opened=false
        if free.menuReleased and free.menuRequested then
            for object,entry in pairs(free.menus) do
                -- Enabled ScreenGui shells often remain on after their panel closes.
                -- They are activation guards, never proof that a menu is still open.
                if object.Parent and object:IsA("GuiObject") and object[entry.property] then
                    local visible=true local ancestor=object.Parent
                    while ancestor and ancestor~=c.PlayerGui do
                        if (ancestor:IsA("GuiObject") and not ancestor.Visible) or (ancestor:IsA("ScreenGui") and not ancestor.Enabled) then visible=false break end
                        ancestor=ancestor.Parent
                    end
                    local size=object.AbsoluteSize local position=object.AbsolutePosition
                    local camera=W.CurrentCamera local viewport=camera and camera.ViewportSize
                    if size and (size.X<=0 or size.Y<=0) then visible=false end
                    if position and size and viewport and (position.X+size.X<=0 or position.Y+size.Y<=0 or position.X>=viewport.X or position.Y>=viewport.Y) then visible=false end
                    if visible then opened=true break end
                end
            end
        end
        if opened~=free.interacting then
            free.interacting=opened free.look=Vector2.zero free.velocity=Vector3.zero
            if not opened then free.menuRequested=false end
        end
    end
    returnApproach=function()
        local saved=free.approach
        if not saved then return end
        free.approach=nil
        local h=humanoid(me)
        if me.Character==saved.character and root(me)==saved.root and saved.root.Parent and not saved.root.Anchored and h and h.Health>0 and not h.SeatPart then
            saved.root.CFrame=saved.cframe
            saved.root.AssemblyLinearVelocity=Vector3.zero saved.root.AssemblyAngularVelocity=Vector3.zero
        end
    end
    local function beginApproach()
        if not free.active then return end
        if free.approach then returnApproach() return end
        local character=me.Character local r=root(me) local h=humanoid(me)
        assert(character and r and h and h.Health>0,translated("Character is not ready"))
        assert(not r.Anchored and not h.SeatPart and not h.Sit,translated("Leave the seat before this test"))
        local ragdoll=h:FindFirstChild("Ragdolled") or character:FindFirstChild("Ragdolled")
        assert(not ragdoll or not ragdoll.Value,translated("Wait until the character stands up"))
        local camera=W.CurrentCamera assert(camera,translated("Camera is not ready"))
        local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances=world and {character,world} or {character}
        local hit=W:Raycast(camera.CFrame.Position,camera.CFrame.LookVector*5000,params)
        if not hit or not hit.Instance or not (hit.Instance:IsA("BasePart") or hit.Instance:IsA("Terrain")) then return end
        local height=math.max(3,(h.HipHeight or 0)+(r.Size and r.Size.Y or 2)/2+1)
        local normal=hit.Normal or Vector3.new(0,1,0)
        -- Step sideways relative to the viewing ray, rather than onto that ray.
        -- A face normal alone can put the whole avatar between camera and target.
        local look=camera.CFrame.LookVector
        local side=Vector3.new(-look.Z,0,look.X)
        side=side.Magnitude>.001 and side.Unit or Vector3.new(1,0,0)
        local clearance=math.max(6,(r.Size and r.Size.X or 2)/2+4)
        local position=hit.Position+side*clearance+normal*height
        for _,n in ipairs({position.X,position.Y,position.Z}) do
            assert(n==n and math.abs(n)<1000000,translated("Invalid test position"))
        end
        assert((position-r.Position).Magnitude<=5000,translated("Test position is too far away"))
        local rotation=r.CFrame-r.CFrame.Position
        free.approach={character=character,root=r,cframe=r.CFrame}
        local ok,message=pcall(function()
            r.CFrame=CFrame.new(position)*rotation
            r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero
        end)
        if not ok then returnApproach(false) error(message,0) end
    end
    local function tryApproach()
        local ok,message=pcall(beginApproach)
        if not ok then
            c.WarnOnce("Experimental approach",message)
            if c.Notify then c.Notify(tostring(message):gsub("^.-:%d+: ","")) end
        end
    end
    local function holdingObject()
        -- FTAP's local grab scope: GrabParts/GrabPart/WeldConstraint.Part1.
        -- A visible line or another player's held mouse button is not a grab.
        for _,scope in ipairs(W:GetChildren()) do
            if scope.Name=="GrabParts" then
                local part=scope:FindFirstChild("GrabPart")
                local weld=part and part:FindFirstChild("WeldConstraint")
                local targetPart=weld and weld.Part1
                if targetPart and targetPart:IsA("BasePart") and targetPart:IsDescendantOf(W) then return true end
            end
        end
        return false
    end
    local function updateFreeNames()
        local current={}
        for _,player in ipairs(P:GetPlayers()) do
            if player~=me then
                local h=humanoid(player)
                if h then
                    current[h]=true
                    patch("freeNames",h,"DisplayDistanceType",Enum.HumanoidDisplayDistanceType.Subject)
                    patch("freeNames",h,"NameDisplayDistance",1000000)
                end
            end
        end
        for h in pairs(free.names or {}) do if not current[h] then unpatch("freeNames",h) end end
        free.names=current
    end
    local function endFree()
        if not free.active then return end
        returnApproach(false)
        free.active=false job("Freecam input") job("Freecam parts") job("Freecam toy UI")
        job("Freecam focus lost") job("Freecam focus gained") job("Freecam interaction")
        free.interacting=false free.rmbNative=nil
        unpatch("freeNames") free.names={}
        unpatch("freeBody") unpatch("freeToyMenu") free.parts={} free.character=nil
        for _,entry in pairs(free.menus) do disconnect(entry.connection) end free.menus={}
        if hud then hud.Visible=false end
        pcall(function() game:GetService("ContextActionService"):UnbindAction("PrimeVisualsFreecam") end)
        unpatch("freeCamera")
        I.MouseBehavior=free.mouseBehavior I.MouseIconEnabled=free.mouseIcon
        for camera,data in pairs(free.cameras) do
            pcall(function()
                camera.CameraType=data.type camera.CameraSubject=(humanoid(me) or data.subject)
                camera.CFrame=data.cf camera.Focus=data.focus
            end)
        end
        free.cameras={} free.humanoids={} free.camera=nil free.position=nil
    end
    local function startFree()
        if not v.freeCameraEnabled then endFree() return end
        if free.active then return end
        local camera=W.CurrentCamera if not camera then return end
        free.active=true free.focused=true free.interacting=false free.menuReleased=false free.menuRequested=false free.mouseBehavior=I.MouseBehavior free.mouseIcon=I.MouseIconEnabled
        free.position=camera.CFrame.Position free.velocity=Vector3.zero free.look=Vector2.new(0,0)
        free.pitch,free.yaw=camera.CFrame:ToEulerAnglesYXZ()
        unpatch("body") visibleFreeBody() suppressToyMenus() updateFreeNames() free.nameElapsed=0
        job("Freecam toy UI",c.PlayerGui.DescendantAdded,hideToyMenu)
        game:GetService("ContextActionService"):BindActionAtPriority("PrimeVisualsFreecam",function(_,state,input)
            if input and input.KeyCode==Enum.KeyCode.E then
                if state==Enum.UserInputState.Begin and not c.MenuOpen() and not I:GetFocusedTextBox() then releaseToyMenus() end
                return Enum.ContextActionResult.Pass
            end
            if input and input.UserInputType==Enum.UserInputType.MouseButton2 then
                if state==Enum.UserInputState.Begin then
                    free.rmbNative=holdingObject() or not free.focused or free.interacting or c.MenuOpen() or I:GetFocusedTextBox()~=nil
                    if not free.rmbNative then tryApproach() end
                end
                -- Keep the whole press/release native even if the throw removes its weld.
                local native=free.rmbNative
                if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then free.rmbNative=nil end
                return native and Enum.ContextActionResult.Pass or Enum.ContextActionResult.Sink
            end
            if free.interacting or c.MenuOpen() or I:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
            return Enum.ContextActionResult.Sink
        end,false,3000,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Q,Enum.KeyCode.E,Enum.KeyCode.Space,Enum.UserInputType.MouseButton2)
        job("Freecam interaction",I.InputBegan,function(input,processed)
            if processed or I:GetFocusedTextBox() then return end
            if input.KeyCode==Enum.KeyCode.F4 then c.Setters.freeCameraEnabled(false,true) return end
        end)
        job("Freecam focus lost",I.WindowFocusReleased,function() returnApproach(false) free.focused=false free.look=Vector2.zero free.velocity=Vector3.zero end)
        job("Freecam focus gained",I.WindowFocused,function() free.focused=true end)
        job("Freecam input",I.InputChanged,function(input)
            if free.interacting or not free.focused or c.MenuOpen() or I:GetFocusedTextBox() then return end
            if input.UserInputType==Enum.UserInputType.MouseMovement then
                free.look=free.look+Vector2.new(input.Delta.X,input.Delta.Y)
            elseif input.UserInputType==Enum.UserInputType.MouseWheel then
                local delta=math.clamp(input.Position.Z,-10,10)
                if delta~=0 then
                    local speed=math.clamp(v.freeCameraSpeed*1.25^delta,10,600)
                    if speed~=v.freeCameraSpeed then c.Setters.freeCameraSpeed(speed,false) end
                end
            end
        end)
    end
    local spectated={}
    local function stopSpectate()
        for camera,data in pairs(spectated) do pcall(function() camera.CameraType=data.type camera.CameraSubject=humanoid(me) or data.subject end) end spectated={}
    end
    local function updateCamera(dt)
        local camera=W.CurrentCamera
        if not camera then return end
        if v.freeCameraEnabled then
            startFree() if not free.active then return end
            if not free.cameras[camera] then free.cameras[camera]={type=camera.CameraType,subject=camera.CameraSubject,cf=camera.CFrame,focus=camera.Focus} end
            local h=humanoid(me)
            if free.approach and (me.Character~=free.approach.character or not h or h.Health<=0) then returnApproach(true) end
            if h then
                patch("freeCamera",h,"WalkSpeed",0) patch("freeCamera",h,"JumpPower",0) patch("freeCamera",h,"JumpHeight",0) patch("freeCamera",h,"AutoRotate",false)
                free.humanoids[h]=true
            end
            for old in pairs(free.humanoids) do if old~=h then unpatch("freeCamera",old) free.humanoids[old]=nil end end
            visibleFreeBody() syncToyMenu()
            free.nameElapsed=(free.nameElapsed or 0)+dt
            if free.nameElapsed>=.5 then free.nameElapsed=0 updateFreeNames() end
            local menuPaused=not free.focused or c.MenuOpen() or I:GetFocusedTextBox()~=nil
            local paused=free.interacting or menuPaused
            if not paused then
                I.MouseBehavior=Enum.MouseBehavior.LockCenter
                free.yaw=free.yaw-free.look.X*0.0045 free.pitch=math.clamp(free.pitch-free.look.Y*0.0045,-1.55,1.55)
            else I.MouseBehavior=Enum.MouseBehavior.Default end
            free.look=Vector2.new(0,0)
            local rotation=CFrame.fromEulerAnglesYXZ(free.pitch,free.yaw,0) local velocity=Vector3.zero
            local speed=v.freeCameraSpeed
            if not paused then
                local function key(k) return I:IsKeyDown(Enum.KeyCode[k]) and 1 or 0 end
                local horizontal=rotation:VectorToWorldSpace(Vector3.new(key("D")-key("A"),0,key("S")-key("W")))
                local direction=horizontal+Vector3.new(0,key("Space")-key("Q"),0)
                speed=math.clamp(v.freeCameraSpeed*(key("LeftShift")==1 and 4 or key("LeftControl")==1 and .25 or 1),10,600)
                if direction.Magnitude>0 then velocity=direction.Unit*speed end
            end
            if paused then free.velocity=Vector3.zero end
            updateHUD(speed,menuPaused)
            free.velocity=free.velocity:Lerp(velocity,1-math.exp(-12*math.min(dt,0.1))) free.position=free.position+free.velocity*math.min(dt,0.1)
            if camera.CameraType~=Enum.CameraType.Scriptable then camera.CameraType=Enum.CameraType.Scriptable end
            camera.CFrame=CFrame.new(free.position)*rotation camera.Focus=camera.CFrame*CFrame.new(0,0,-16)
            return
        end
        if free.active then endFree() end
        if v.spectateEnabled then
            local subject=humanoid(target("spectateTarget"))
            if subject then
                if not spectated[camera] then spectated[camera]={type=camera.CameraType,subject=camera.CameraSubject} end
                camera.CameraType=Enum.CameraType.Custom camera.CameraSubject=subject
            else stopSpectate() end
        elseif next(spectated) then stopSpectate() end

    end
    do
        local g=group("Camera","Cinematic camera",2)
        toggle(g,"freeCameraEnabled","Free camera",false,function(on)
            if on then if v.spectateEnabled then c.Setters.spectateEnabled(false,true) end startFree() else endFree() end
        end)
        slider(panel("freeCameraEnabled"),"freeCameraSpeed","Speed",10,600,80,1,function() end)
        panel("freeCameraEnabled"):AddLabel("WASD · Space / Q · mouse look · wheel 10–600")
        panel("freeCameraEnabled"):AddLabel("RMB: approach / return · E: objects · F4: exit")
        toggle(g,"spectateEnabled","Spectate player",false,function(on)
            if on then if v.freeCameraEnabled then c.Setters.freeCameraEnabled(false,true) end else stopSpectate() end
        end)
        c.PlayerPicker(panel("spectateEnabled"),"spectateTarget","Player","",function() stopSpectate() end)
    end
    -- Single bounded render/maintenance loop; no per-player coroutine or permanent scans.
    local function run(name,fn,...)
        local ok,message=pcall(fn,...)
        if not ok then c.WarnOnce(name,message) end
    end
    local elapsed,frameElapsed=0,0
    job("Visuals",R.Heartbeat,function(dt)
        elapsed=elapsed+dt frameElapsed=frameElapsed+dt
        if frameElapsed>=1/30 then
            local step=frameElapsed frameElapsed=frameElapsed%(1/30)
            for p,e in pairs(rings) do
                local t=math.clamp((os.clock()-e.started)/e.duration,0,1)
                if t>=1 or not p.Parent then destroy(p) rings[p]=nil else
                    local k=1-(1-t)*(1-t) local size=0.2+0.8*k e.image.Size=UDim2.fromScale(size,size)
                    e.image.ImageTransparency=k e.image.ImageColor3=v.jumpCircleColor
                end
            end
            if v.bodyTrailEnabled then run("Character trail",updateTrail) end
            if v.boxEnabled or v.skeletonEnabled or next(geometry) then run("Geometry",updateGeometry) end
            if v.traceEnabled or traceLine then run("Trace",updateTrace,step) end
            if v.holeSprite or next(holes) then run("Blackholes",updateHoles,step) end
            if v.serverGhostEnabled or #ghost.parts>0 then run("Position history",updateGhost,step) end
            if v.snowEnabled then
                local r=root(me) local camera=W.CurrentCamera local position=r and r.Position or camera and camera.CFrame.Position
                if position then for i,e in ipairs(snow) do
                    local area=v.snowArea local t=os.clock()
                    e.part.Position=position+Vector3.new((i-2)*area*0.18,v.snowHeight+(i-1)*6,(i%2==0 and 1 or -1)*area*0.12)
                        +Vector3.new(math.sin(t*0.22+e.phase)*area*0.08,0,math.cos(t*0.2+e.phase)*area*0.08)
                end end
            end
        end
        if elapsed>=0.5 then
            elapsed=elapsed%0.5 run("Jump circle",updateJump) run("Object highlights",updateMarkers)
            if v.oceanAppearance then run("Ocean appearance",updateOcean) end
            if v.bodyAppearance then run("Body appearance",updateAppearance) end
            if v.snowEnabled then run("Snowfall",updateSnow) end
            for b,t in pairs(dustBursts) do if os.clock()-t>=8 or not b.Parent then destroy(b) dustBursts[b]=nil end end
            for h,list in pairs(dustHum) do if not h:IsDescendantOf(W) then for _,con in ipairs(list) do disconnect(con) end dustHum[h]=nil end end
            for char,parts in pairs(dusted) do if not char.Parent then
                for _,o in ipairs(parts) do unpatch("deathDust",o) end dusted[char]=nil
            end end
            if appliedPreset then
                for _,o in ipairs(presetObjects) do if not o.Parent then updatePreset() break end end
            end
        end
    end)
    -- Camera-only transform runs after the native controller; no second mouse-rotation path.
    local bound=false
    if R.BindToRenderStep then
        R:BindToRenderStep("PrimeVisualsCinematicCamera",Enum.RenderPriority.Camera.Value+1,function(dt)
            if not dead and (v.freeCameraEnabled or v.spectateEnabled or free.active or next(spectated)) then
                local ok,message=pcall(updateCamera,dt) if not ok then c.WarnOnce("Cinematic camera",message) end
            end
        end) bound=true
    else job("Camera",R.RenderStepped,updateCamera) end
    teardown=function()
        if dead then return end dead=true
        endFree() stopSpectate()
        if bound then R:UnbindFromRenderStep("PrimeVisualsCinematicCamera") end
        for con in pairs(links) do con:Disconnect() end links={}
        for o in pairs(objects) do pcall(function() o:Destroy() end) end objects={}
        for _,name in ipairs({"visualPreset","fullbright","revealInvisible","deathDust","freeCamera","freeBody","freeToyMenu","oceanAppearance","oceanColor","bodyAppearance","bodyAccessories","bodyFace","blackholeSprite"}) do unpatch(name) end
    end
    return {Destroy=function() teardown() end}
end
