-- High-resolution transparent emblems with a native UI sheen; no per-frame asset downloads.
return function(options)
    assert(options.Parent,"Emblem requires a GUI parent")
    local alive=true
    local links={}
    local function make(class,properties,parent)
        local object=Instance.new(class)
        for key,value in pairs(properties) do object[key]=value end
        object.Parent=parent
        return object
    end
    local function connect(signal,callback)
        local connection=signal:Connect(callback)
        table.insert(links,connection)
        return connection
    end
    local white=Color3.new(1,1,1)
    local accent=options.Accent
    local art={Ready=false,TextureReady=false,Destroyed=false,Error=nil}
    local root=make("Frame",{Name=options.Name or "AnimatedEmblem",BackgroundTransparency=1,
        AnchorPoint=Vector2.new(0.5,0.5),Position=options.Position or UDim2.fromScale(0.5,0.5),
        Size=options.Size or UDim2.fromScale(0.92,0.96),Active=false},options.Parent)
    make("UIAspectRatioConstraint",{AspectRatio=1,DominantAxis=Enum.DominantAxis.Height},root)
    make("UISizeConstraint",{MinSize=Vector2.new(96,96),MaxSize=Vector2.new(260,260)},root)
    art.Root=root
    local function image(name,parent,size,z)
        return make("ImageLabel",{Name=name,BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(size,size),
            ScaleType=Enum.ScaleType.Fit,ResampleMode=Enum.ResamplerMode.Default,
            Image="",ImageColor3=white,ImageTransparency=1,ZIndex=z,Active=false},parent)
    end
    local aura=image("OuterAura",root,1.045,1)
    local rim=image("InnerAura",root,1.018,2)
    local base=image("Illustration",root,1,3)
    local sheen=image("IridescentSheen",root,1,4)
    art.Base,art.Sheen=base,sheen
    local band=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.35,1),
        NumberSequenceKeypoint.new(0.5,0.05),NumberSequenceKeypoint.new(0.65,1),NumberSequenceKeypoint.new(1,1)})
    local gradient=make("UIGradient",{Rotation=-28,Color=ColorSequence.new(accent),Transparency=band},sheen)
    local strokes={}
    local function fallback(parent,mini)
        local mark=make("Frame",{Name="NativeEmblemFallback",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Active=false,ZIndex=5},parent)
        local function line(a,b,width)
            local dx,dy=b[1]-a[1],b[2]-a[2]
            local item=make("Frame",{BorderSizePixel=0,BackgroundColor3=accent,BackgroundTransparency=0.12,
                AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale((a[1]+b[1])/400,(a[2]+b[2])/400),
                Size=UDim2.new(math.sqrt(dx*dx+dy*dy)/200,0,0,mini and 1 or width or 1.6),
                Rotation=math.deg(math.atan2(dy,dx)),Active=false,ZIndex=5},mark)
            table.insert(strokes,item)
        end
        local outline=options.Style=="demon"
            and {{100,188},{70,160},{49,123},{43,91},{23,37},{49,53},{54,18},{74,48},{77,82},{100,99}}
            or {{100,184},{75,159},{39,140},{17,101},{9,54},{38,77},{27,30},{70,67},{86,85},{100,43}}
        for side=-1,1,2 do
            local function point(value) return {100+side*(value[1]-100),value[2]} end
            for i=1,#outline-1 do line(point(outline[i]),point(outline[i+1])) end
            if options.Style=="demon" then
                line(point({55,106}),point({85,123}),2.5) line(point({85,123}),{100,143},1.2)
                line(point({62,140}),{100,172},1.2)
            else
                line(point({24,85}),point({78,118}),1.4) line(point({39,125}),point({85,137}),1.2)
                line(point({78,102}),{100,123},1.8) line({100,123},point({88,146}),1.2)
                line(point({88,146}),{100,164},1.2)
            end
        end
        return mark
    end
    local pending=fallback(root,false)
    local header=options.Header
    local headerMark,headerSheen,headerGradient,oldHeaderMark
    if header then
        header.Image=""
        header.ImageRectOffset=Vector2.new(0,0) header.ImageRectSize=Vector2.new(0,0)
        oldHeaderMark=header:FindFirstChild("PrimePrism")
        if oldHeaderMark then oldHeaderMark.Visible=false end
        headerMark=fallback(header,true)
        headerSheen=image("HeaderSheen",header,1,header.ZIndex+2)
        headerGradient=make("UIGradient",{Rotation=-28,Color=ColorSequence.new(accent),Transparency=band},headerSheen)
    end
    local function isAlive() return alive and (not options.IsAlive or options.IsAlive()) end
    local function finish(removeRoot)
        if not alive then return end
        alive=false art.Destroyed=true
        for _,connection in ipairs(links) do connection:Disconnect() end links={}
        if headerMark then headerMark:Destroy() end
        if headerSheen then headerSheen:Destroy() end
        if removeRoot and root.Parent then root:Destroy() end
    end
    function art:Destroy() finish(true) end
    connect(root.Destroying,function() finish(false) end)
    local function reveal()
        if not isAlive() or not art.TextureReady or not base.IsLoaded then return end
        art.Ready=true pending.Visible=false
        base.ImageTransparency=0 sheen.ImageTransparency=0.22
        aura.ImageTransparency=0.94 rim.ImageTransparency=0.91
        if headerMark then headerMark.Visible=false end
        if headerSheen then headerSheen.ImageTransparency=0.3 end
    end
    connect(base:GetPropertyChangedSignal("IsLoaded"),reveal)
    local phase,elapsed=0,0
    function art:Step(dt)
        if not isAlive() or (options.IsVisible and not options.IsVisible()) then return end
        elapsed=elapsed+dt
        if elapsed<1/30 then return end
        phase=phase+math.min(elapsed,0.15) elapsed=elapsed%(1/30)
        local tint=Color3.fromHSV((phase/20+(options.HueOffset or 0))%1,0.7,1)
        local pulse=(math.sin(phase*1.3)+1)/2
        if not options.HeroVisible or options.HeroVisible() then
            gradient.Color=ColorSequence.new(tint)
            gradient.Offset=Vector2.new(-1.3+(phase*0.12%1)*2.6,0)
            aura.ImageColor3=tint rim.ImageColor3=tint
            if art.Ready then aura.ImageTransparency=0.94+pulse*0.025 rim.ImageTransparency=0.91+pulse*0.025 end
        end
        if headerGradient then
            headerGradient.Color=ColorSequence.new(tint)
            headerGradient.Offset=Vector2.new(-1.3+(phase*0.12%1)*2.6,0)
        end
        if not art.Ready then for _,stroke in ipairs(strokes) do stroke.BackgroundColor3=tint end end
    end
    task.spawn(function()
        local ok,message=pcall(function()
            local getAsset=getcustomasset or getsynasset
            assert(type(getAsset)=="function","Executor does not support local image assets")
            assert(type(readfile)=="function" and type(writefile)=="function" and type(isfolder)=="function" and type(makefolder)=="function","Executor does not provide image cache file APIs")
            local function valid(data)
                return type(data)=="string" and #data==options.Bytes and data:sub(1,8)=="\137PNG\r\n\26\n"
            end
            local path="PrimeVortex/Assets/"..options.CacheName
            if options.CacheFolder then path=options.CacheFolder.."/"..options.CacheName end
            local cached,data=pcall(readfile,path)
            if not cached or not valid(data) then
                data=game:HttpGet(options.URL)
                assert(valid(data),"Downloaded emblem PNG failed validation")
                if not isAlive() then return end
                for _,folder in ipairs(options.Folders or {"PrimeVortex","PrimeVortex/Assets"}) do
                    if not isfolder(folder) then makefolder(folder) end
                end
                writefile(path,data)
                assert(valid(readfile(path)),"Emblem cache write failed verification")
            end
            if not isAlive() then return end
            local uri=getAsset(path)
            assert(type(uri)=="string" and uri~="","Executor returned an invalid local image URI")
            if not isAlive() then return end
            for _,layer in ipairs({aura,rim,base,sheen}) do layer.Image=uri end
            if header then header.Image=uri header.ImageColor3=white end
            if headerSheen then headerSheen.Image=uri end
            art.TextureReady=true
            reveal()
        end)
        if not ok and isAlive() then art.Error=tostring(message) warn("Prime emblem: "..art.Error) end
    end)
    return art
end
