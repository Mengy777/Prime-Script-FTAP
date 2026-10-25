-- Static full-resolution artwork and a small independent animated header mark.
return function(options)
    assert(options.Parent,"Emblem requires a GUI parent")
    local alive,links=true,{}
    local art={Ready=false,TextureReady=false,Destroyed=false}
    local function make(class,properties,parent)
        local object=Instance.new(class)
        for key,value in pairs(properties) do object[key]=value end
        object.Parent=parent
        return object
    end
    local root=make("Frame",{Name=options.Name or "Artwork",BackgroundTransparency=1,Active=false,
        AnchorPoint=Vector2.new(0.5,0.5),Position=options.Position or UDim2.fromScale(0.5,0.5),
        Size=options.Size or UDim2.fromScale(0.92,0.96)},options.Parent)
    make("UIAspectRatioConstraint",{AspectRatio=1,DominantAxis=Enum.DominantAxis.Height},root)
    make("UISizeConstraint",{MinSize=Vector2.new(96,96),MaxSize=Vector2.new(280,280)},root)
    local image=make("ImageLabel",{Name="Illustration",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),
        Image="",ImageColor3=Color3.new(1,1,1),ImageTransparency=0,ScaleType=Enum.ScaleType.Fit,
        ResampleMode=Enum.ResamplerMode.Default,Active=false},root)
    art.Root,art.Base=root,image
    local icon,strokes
    if options.Header then
        local header=options.Header
        header.Image="" header.ImageTransparency=1
        icon=make("Frame",{Name="CompactBrandIcon",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),
            AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Active=false},header)
        strokes={}
        local function line(a,b)
            local dx,dy=b[1]-a[1],b[2]-a[2]
            table.insert(strokes,make("Frame",{BorderSizePixel=0,BackgroundColor3=options.Accent,
                AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale((a[1]+b[1])/52,(a[2]+b[2])/52),
                Size=UDim2.new(math.sqrt(dx*dx+dy*dy)/26,0,0,1.5),Rotation=math.deg(math.atan2(dy,dx)),Active=false},icon))
        end
        if options.Style=="demon" then
            for blade=0,2 do
                local angle=blade*math.pi*2/3
                local function turn(x,y) return {13+(x-13)*math.cos(angle)-(y-13)*math.sin(angle),13+(x-13)*math.sin(angle)+(y-13)*math.cos(angle)} end
                line(turn(13,3),turn(21,9)) line(turn(21,9),turn(15,12))
            end
        else
            local points={{7,4},{19,4},{23,10},{13,23},{3,10}}
            for i=1,#points do line(points[i],points[i%#points+1]) end
            line({3,10},{23,10}) line({7,4},{13,23}) line({19,4},{13,23})
        end
    end
    art.Icon=icon
    local function isAlive() return alive and (not options.IsAlive or options.IsAlive()) end
    local function finish(removeRoot)
        if not alive then return end
        alive=false art.Destroyed=true
        for _,link in ipairs(links) do link:Disconnect() end
        if icon then icon:Destroy() end
        if removeRoot and root.Parent then root:Destroy() end
    end
    function art:Destroy() finish(true) end
    table.insert(links,root.Destroying:Connect(function() finish(false) end))
    table.insert(links,image:GetPropertyChangedSignal("IsLoaded"):Connect(function() art.Ready=isAlive() and image.IsLoaded end))
    local phase,elapsed=0,0
    function art:Step(dt)
        if not isAlive() or not icon or (options.IsVisible and not options.IsVisible()) then return end
        elapsed=elapsed+dt if elapsed<1/30 then return end
        phase=phase+math.min(elapsed,0.1) elapsed=elapsed%(1/30)
        if options.Style=="demon" then icon.Rotation=(phase*30)%360
        else
            local tint=Color3.fromHSV((phase/14+0.72)%1,0.75,1)
            for _,stroke in ipairs(strokes) do stroke.BackgroundColor3=tint end
        end
    end
    task.spawn(function()
        local ok,message=pcall(function()
            local getAsset=getcustomasset or getsynasset
            assert(type(getAsset)=="function","Executor does not support local image assets")
            assert(type(readfile)=="function" and type(writefile)=="function" and type(isfolder)=="function" and type(makefolder)=="function","Executor does not provide image cache file APIs")
            local function valid(data) return type(data)=="string" and #data==options.Bytes and data:sub(1,8)=="\137PNG\r\n\26\n" end
            local folder=options.CacheFolder or "PrimeVortex/Assets"
            local path=folder.."/"..options.CacheName
            local cached,data=pcall(readfile,path)
            if not cached or not valid(data) then
                local fetched,body=pcall(game.HttpGet,game,options.URL)
                if fetched and valid(body) then data=body
                else
                    local fetch=request or http_request or (type(syn)=="table" and syn.request)
                    assert(type(fetch)=="function","Image HTTP download failed")
                    local response=fetch({Url=options.URL,Method="GET"})
                    data=response and response.Body
                end
                assert(valid(data),"Downloaded image is not the expected PNG")
                if not isAlive() then return end
                for _,directory in ipairs(options.Folders or {"PrimeVortex","PrimeVortex/Assets"}) do if not isfolder(directory) then makefolder(directory) end end
                writefile(path,data) assert(valid(readfile(path)),"Image cache verification failed")
            end
            if not isAlive() then return end
            local uri=getAsset(path)
            assert(type(uri)=="string" and uri~="","Executor returned an invalid local image URI")
            if not isAlive() then return end
            -- Never hide an assigned PNG behind IsLoaded: some executors delay that flag.
            image.Image=uri image.ImageTransparency=0
            art.TextureReady=true art.Ready=image.IsLoaded==true
        end)
        if not ok and isAlive() then
            art.Error=tostring(message) warn("Prime artwork: "..art.Error)
            if options.Notify then pcall(options.Notify) end
        end
    end)
    return art
end
