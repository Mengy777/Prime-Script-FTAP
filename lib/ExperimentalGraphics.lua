-- Original bounded client implementation informed by docs/Graphics-Research.md.
-- Native light probes and beam shafts: approximations, not a replacement GPU renderer.
return function(c)
    local W,L,R,P=c.Workspace,c.Lighting,c.Run,c.Players
    local v=c.Controls
    local dead=false
    local folder,probes,shafts,lights=nil,{},{},{}
    local cells={} local lightCount=0 local sampleIndex=0 local cursor=0
    local elapsed,shaftElapsed,clock=0,0,0
    local profiles={Low={Count=12,Samples=2,Interval=.16},Balanced={Count=24,Samples=4,Interval=.12},High={Count=40,Samples=6,Interval=.1},Ultra={Count=64,Samples=8,Interval=.09}}
    local offsets={{.5,.5},{.25,.55},{.75,.55},{.5,.8},{.15,.8},{.85,.8},{.35,.3},{.65,.3},{.1,.4},{.9,.4},{.35,.7},{.65,.7}}
    local function job(name,signal,fn)c.Job("Experimental / "..name,signal,fn)end
    local function root()
        if not folder or folder.Parent~=W then
            if folder then c.Dispose(folder) end
            folder=c.Create("Folder",{Name="PV_ExperimentalGraphics"},W)
        end
        return folder
    end
    local function carrier(name)
        return c.Create("Part",{Name=name,Size=Vector3.new(.1,.1,.1),Transparency=1,Anchored=true,
            CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false},root())
    end
    local function params()
        local p=RaycastParams.new()p.FilterType=Enum.RaycastFilterType.Exclude
        local exclude={}local character=P.LocalPlayer.Character
        if character then exclude[#exclude+1]=character end
        if folder then exclude[#exclude+1]=folder end
        p.FilterDescendantsInstances=exclude
        return p
    end
    local function clearProbes()
        for _,entry in ipairs(probes)do c.Dispose(entry.part)end
        probes={}cells={}cursor=0
    end
    local function clearShafts()
        for _,entry in ipairs(shafts)do c.Dispose(entry.part)end shafts={}
    end
    local function observeLight(o)
        if lightCount>=128 or lights[o] or o.Name:match("^PV_")then return end
        if folder and o:IsDescendantOf(folder)then return end
        if o:IsA("PointLight")or o:IsA("SpotLight")or o:IsA("SurfaceLight")then lights[o]=true lightCount=lightCount+1 end
    end
    local function stopLights()
        job("light added")job("light removed")lights={}lightCount=0
    end
    local function startLights()
        stopLights()
        if not v.giEnabled or not v.giLocalLights then return end
        for _,o in ipairs(W:GetDescendants())do observeLight(o)end
        job("light added",W.DescendantAdded,observeLight)
        job("light removed",W.DescendantRemoving,function(o)
            if lights[o]then lights[o]=nil lightCount=lightCount-1 end
        end)
    end
    local function directionForFace(frame,face)
        if face==Enum.NormalId.Back then return frame.LookVector*-1
        elseif face==Enum.NormalId.Left then return frame.RightVector*-1
        elseif face==Enum.NormalId.Right then return frame.RightVector
        elseif face==Enum.NormalId.Top then return frame.UpVector
        elseif face==Enum.NormalId.Bottom then return frame.UpVector*-1 end
        return frame.LookVector
    end
    local function localEnergy(hit,p,nearby)
        local total=0 local red,green,blue=0,0,0 local checked,shadowRays=0,0
        for _,candidate in ipairs(nearby)do
            local light=candidate.light
            checked=checked+1 if checked>16 then break end
            local parent=light.Parent
            if parent and light.Enabled then
                local isAttachment=parent:IsA("Attachment")
                if isAttachment or parent:IsA("BasePart")then
                    local position=isAttachment and parent.WorldPosition or parent.Position
                    local delta=hit.Position-position local distance=delta.Magnitude
                    local range=math.min(light.Range,120)
                    if distance>.1 and range>0 and distance<range then
                        local admitted=true
                        if light:IsA("SpotLight")or light:IsA("SurfaceLight")then
                            local frame=isAttachment and parent.WorldCFrame or parent.CFrame
                            admitted=directionForFace(frame,light.Face):Dot(delta.Unit)>=math.cos(math.rad(light.Angle*.5))
                        end
                        if admitted and light.Shadows then
                            if shadowRays>=2 then admitted=false else
                                shadowRays=shadowRays+1
                                local start=hit.Position+hit.Normal*.2 local toLight=position-start
                                local obstruction=W:Raycast(start,toLight.Unit*math.max(0,toLight.Magnitude-.3),p)
                                local owner=isAttachment and parent.Parent or parent
                                admitted=not obstruction or obstruction.Instance==owner
                            end
                        end
                        if admitted then
                            local incidence=math.max(0,hit.Normal:Dot(delta.Unit*-1))
                            local energy=math.min(light.Brightness,8)*(1-distance/range)^2*incidence
                            total=total+energy red=red+light.Color.R*energy green=green+light.Color.G*energy blue=blue+light.Color.B*energy
                        end
                    end
                end
            end
        end
        if total>0 then return total,Color3.new(red/total,green/total,blue/total)end
        return 0,Color3.new(1,1,1)
    end
    local function surfaceColor(hit)
        if hit.Instance:IsA("Terrain")then return W.Terrain:GetMaterialColor(hit.Material)end
        return hit.Instance.Color
    end
    local function putProbe(hit,energy,tint,limit)
        local cell=string.format("%d:%d:%d",math.floor(hit.Position.X/6),math.floor(hit.Position.Y/6),math.floor(hit.Position.Z/6))
        local entry=cells[cell]
        if not entry then
            if #probes<limit then
                local part=carrier("PV_BounceProbe")
                local light=c.Make("PointLight",{Name="PV_BounceLight",Shadows=false,Brightness=0,Enabled=true},part)
                entry={part=part,light=light}probes[#probes+1]=entry
            else
                cursor=cursor%#probes+1 entry=probes[cursor]
                if entry.cell then cells[entry.cell]=nil end
            end
            entry.cell=cell cells[cell]=entry
        end
        local color=surfaceColor(hit)
        entry.part.Position=hit.Position+hit.Normal*1.2
        entry.light.Color=Color3.new(color.R*tint.R,color.G*tint.G,color.B*tint.B)
        entry.light.Range=v.giRange
        entry.energy=energy entry.updated=clock
        entry.source=hit.Instance entry.sourcePosition=hit.Instance:IsA("BasePart")and hit.Instance.Position or nil
    end
    local function sample(camera,quality)
        local p=params()local sun=L:GetSunDirection()local began=os.clock()
        local nearby={}
        for light in pairs(lights)do
            local parent=light.Parent
            if parent and (parent:IsA("Attachment")or parent:IsA("BasePart"))then
                local position=parent:IsA("Attachment")and parent.WorldPosition or parent.Position
                nearby[#nearby+1]={light=light,distance=(position-camera.CFrame.Position).Magnitude}
            end
        end
        table.sort(nearby,function(a,b)return a.distance<b.distance end)
        for _=1,quality.Samples do
            if os.clock()-began>.003 then break end
            sampleIndex=sampleIndex%#offsets+1 local uv=offsets[sampleIndex]
            local jitter=(sampleIndex%3-1)*.035
            local ray=camera:ViewportPointToRay(camera.ViewportSize.X*math.clamp(uv[1]+jitter,.02,.98),camera.ViewportSize.Y*uv[2])
            local hit=W:Raycast(ray.Origin,ray.Direction*v.giDistance,p)
            if hit and (hit.Instance:IsA("BasePart")or hit.Instance:IsA("Terrain"))then
                if not hit.Instance:IsA("BasePart")or hit.Instance.Transparency<.8 then
                    local daylight=0
                    if sun.Y>0 then
                        local incidence=math.max(0,hit.Normal:Dot(sun))
                        if incidence>0 and not W:Raycast(hit.Position+hit.Normal*.2,sun*600,p)then daylight=incidence*math.clamp(L.Brightness/2,0,2)end
                    end
                    local extra,tint=localEnergy(hit,p,nearby)
                    local energy=daylight+extra*.45
                    if hit.Material==Enum.Material.Neon then energy=math.max(energy,.5)end
                    if energy>.025 then
                        if daylight>0 then tint=Color3.new((tint.R*extra+daylight)/(extra+daylight),(tint.G*extra+daylight)/(extra+daylight),(tint.B*extra+daylight)/(extra+daylight))end
                        putProbe(hit,energy,tint,quality.Count)
                    end
                end
            end
        end
    end
    local function updateProbes(camera,dt)
        local alpha=1-math.exp(-7*math.min(dt,.1))
        for i=#probes,1,-1 do
            local e=probes[i]local valid=e.part.Parent and e.light.Parent and e.source and e.source:IsDescendantOf(W)
            local age=clock-(e.updated or 0)
            if valid and e.sourcePosition and (e.source.Position-e.sourcePosition).Magnitude>2 then valid=false end
            if not valid or age>4 or (camera.CFrame.Position-e.part.Position).Magnitude>v.giDistance*1.5 then
                if e.cell then cells[e.cell]=nil end c.Dispose(e.part)table.remove(probes,i)
            else
                local target=math.clamp(e.energy*v.giStrength,0,4)*(age>2 and math.max(0,(4-age)/2)or 1)
                e.light.Brightness=e.light.Brightness+(target-e.light.Brightness)*alpha
                e.light.Range=v.giRange
            end
        end
    end
    local function updateShafts(camera)
        local sun=L:GetSunDirection()
        if sun.Y<=.08 then clearShafts()return end
        local p=params()local count=math.floor(v.shaftCount)
        for i=#shafts,count+1,-1 do c.Dispose(shafts[i].part)table.remove(shafts,i)end
        for i=1,count do
            local e=shafts[i]
            if not e or not e.part.Parent or not e.beam.Parent then
                if e then c.Dispose(e.part)end
                local part=carrier("PV_SunShaft")
                local a=c.Make("Attachment",{Position=Vector3.zero},part)
                local b=c.Make("Attachment",{Position=Vector3.zero},part)
                local beam=c.Make("Beam",{Name="PV_SunShaftBeam",Attachment0=a,Attachment1=b,FaceCamera=true,
                    LightEmission=1,LightInfluence=0,Segments=1,Enabled=false},part)
                e={part=part,a=a,b=b,beam=beam}shafts[i]=e
            end
            local angle=i*2.399963229728653 local radius=math.sqrt(i/count)*v.shaftRadius
            local start=camera.CFrame.Position+Vector3.new(math.cos(angle)*radius,18+v.shaftLength*.3,math.sin(angle)*radius)
            local direction=sun*-v.shaftLength
            local hit=W:Raycast(start,direction,p)
            local finish=hit and hit.Position or start+direction
            local length=(finish-start).Magnitude
            e.part.Position=start e.b.Position=finish-start
            e.beam.Width0=v.shaftWidth*.45 e.beam.Width1=v.shaftWidth
            e.beam.Color=ColorSequence.new(v.shaftColor)
            local opacity=v.shaftOpacity
            e.beam.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.18,1-opacity),NumberSequenceKeypoint.new(.78,1-opacity*.6),NumberSequenceKeypoint.new(1,1)})
            e.beam.Enabled=length>4
        end
    end
    local function refreshGI()
        clearProbes()elapsed=0
        startLights()
    end
    local function refreshShafts()if not v.shaftEnabled then clearShafts()end shaftElapsed=1 end
    local translations={
        ["Experimental"]="Экспериментальное",["Bounce lighting"]="Отражённый свет",["Sunlight shafts"]="Объёмные солнечные лучи",
        ["Quality"]="Качество",["Strength"]="Сила",["Light radius"]="Радиус света",["Sample distance"]="Дальность расчёта",
        ["Sample local lights"]="Учитывать источники света",["Shaft count"]="Количество лучей",["Shaft length"]="Длина лучей",
        ["Shaft radius"]="Область лучей",["Shaft width"]="Ширина лучей",["Shaft opacity"]="Видимость лучей",
    }
    for en,ru in pairs(translations)do c.Translations[en]=ru end
    local giTip="Approximate colored bounce light from sunlit surfaces and nearby lights. Start with Balanced quality."
    local shaftTip="Experimental beam sunlight. Visible outdoors when the sun is above the horizon; not physical volumetric scattering."
    c.Translations[giTip]="Имитация отражённого света от освещённых поверхностей и ламп. Начни с Balanced."
    c.Translations[shaftTip]="Экспериментальные солнечные лучи. Проверяй снаружи днём; это имитация через Beam."
    c.FeatureTips.giEnabled=giTip c.FeatureTips.shaftEnabled=shaftTip
    c.ColorOwners.shaftColor="shaftEnabled"
    local g=c.Group("Lighting","Experimental light",1)
    c.Toggle(g,"giEnabled","Bounce lighting",false,refreshGI)
    local panel=c.Panel("giEnabled")
    c.Choice(panel,"giQuality","Quality",{"Low","Balanced","High","Ultra"},"Balanced",refreshGI)
    c.Slider(panel,"giStrength","Strength",0,4,.85,.05,function()end)
    c.Slider(panel,"giRange","Light radius",4,40,16,1,function()end)
    c.Slider(panel,"giDistance","Sample distance",20,250,100,1,refreshGI)
    c.Toggle(panel,"giLocalLights","Sample local lights",true,refreshGI)
    g=c.Group("Lighting","Experimental shafts",2)
    c.Toggle(g,"shaftEnabled","Sunlight shafts",false,refreshShafts)
    panel=c.Panel("shaftEnabled")
    c.Slider(panel,"shaftCount","Shaft count",4,24,12,1,refreshShafts)
    c.Slider(panel,"shaftLength","Shaft length",30,180,90,1,refreshShafts)
    c.Slider(panel,"shaftRadius","Shaft radius",8,70,30,1,refreshShafts)
    c.Slider(panel,"shaftWidth","Shaft width",.5,12,4,.1,refreshShafts)
    c.Slider(panel,"shaftOpacity","Shaft opacity",.01,.35,.09,.01,refreshShafts)
    c.Color(panel,"shaftColor","Color",Color3.fromRGB(255,235,200),refreshShafts,function(value)
        for _,e in ipairs(shafts)do if e.beam.Parent then e.beam.Color=ColorSequence.new(value)end end
    end)
    job("update",R.Heartbeat,function(dt)
        if dead then return end
        if not v.giEnabled and not v.shaftEnabled then return end
        clock=clock+math.min(dt,.25)
        local camera=W.CurrentCamera if not camera then return end
        if v.giEnabled then
            elapsed=elapsed+dt local quality=profiles[v.giQuality]or profiles.Balanced
            updateProbes(camera,dt)
            if elapsed>=quality.Interval then elapsed=0 sample(camera,quality)end
        end
        if v.shaftEnabled then
            shaftElapsed=shaftElapsed+dt
            if shaftElapsed>=.12 then shaftElapsed=0 updateShafts(camera)end
        end
    end)
    return {Destroy=function()
        dead=true job("update")stopLights()clearProbes()clearShafts()
        if folder then c.Dispose(folder)folder=nil end
    end}
end
