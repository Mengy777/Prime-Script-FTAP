-- Presentation only: stable setting keys, callbacks and effect state stay in the main script.
return function(c)
    local lib,make,listen=c.Library,c.Make,c.Listen
    local pages={
        View={"Camera","Sky"},Graphics={"Lighting","Weather","Water & FPS"},
        Character={"Appearance","Movement","Mannequins"},ESP={"Players","Objects","Tools"},
        FTAP={"Grab line","Crosshair","Blackholes","Audio"},Settings={"General","Profiles"},
    }
    -- Input group -> short subpage, shared card, column. Adjacent single-toggle cards merge.
    local routes={
        Camera={Camera={"Camera","Camera",1},View={"Camera","Camera",1},["Cinematic camera"]={"Camera","Camera tools",2}},
        Sky={Skybox={"Sky","Custom skybox",1},Sun={"Sky","Sun and clouds",2},Clouds={"Sky","Sun and clouds",2},["Skybox collection"]={"Sky","Sky collection",1}},
        Lighting={["Color and light"]={"Lighting","Lighting",1},["Scene presets"]={"Lighting","Lighting",1}},
        Particles={Particles={"Weather","Particles",1},Snowfall={"Weather","Snowfall",2}},
        World={Water={"Water & FPS","Water",1},["Ocean appearance"]={"Water & FPS","Water",1},Performance={"Water & FPS","Performance",2}},
        Character={
            ["Character finish"]={"Appearance","Body style",1},["Body appearance"]={"Appearance","Body style",1},
            ["Self ESP"]={"Appearance","Accessories",2},["Cone hat"]={"Appearance","Accessories",2},
            ["Movement visuals"]={"Movement","Movement effects",1},["Death visuals"]={"Movement","Movement effects",1},
            Mannequins={"Mannequins","Local mannequins",1},
        },
        ESP={Visibility={"Players","Player highlight",1},["Player markers"]={"Players","Player highlight",1},
            Geometry={"Players","Player overlays",2},["World markers"]={"Objects","World markers",1},
            ["Object highlights"]={"Objects","Item highlights",2},["Target trace"]={"Tools","Player tracker",1},
            ["Local position history"]={"Tools","Position history",2}},
        Tweaks={["Grab line"]={"Grab line","Grab line",1},Crosshair={"Crosshair","Crosshair",1},
            Blackholes={"Blackholes","Blackholes",1},["Animated blackholes"]={"Blackholes","Blackhole animation",2}},
        Audio={["Mute categories"]={"Audio","Mute sounds",1},["Blackhole sound"]={"Audio","Blackhole audio",2}},
        Settings={Protection={"General","Protection",2},Interface={"General","Interface",1},Configurations={"Profiles","Saved profiles",1},["Import / export"]={"Profiles","Share profiles",2}},
    }
    local categoryFor={Camera="View",Sky="View",Lighting="Graphics",Particles="Graphics",World="Graphics",Character="Character",ESP="ESP",Tweaks="FTAP",Audio="FTAP",Settings="Settings"}
    local states={}
    local cache={}
    local searching=false
    local destroyed=false
    local function theme(object,properties)
        if type(lib.AddToRegistry)=="function" then lib:AddToRegistry(object,properties) end
    end
    local tweenService=game:GetService("TweenService")
    local tweens={}
    local function animate(object,goal)
        if tweens[object] then tweens[object]:Cancel() end
        local tween=tweenService:Create(object,TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal)
        tweens[object]=tween tween:Play()
    end
    local pageIcons={Camera="camera",Sky="cloud-sun",Lighting="sun",Weather="cloud-snow",["Water & FPS"]="waves",
        Appearance="user-round",Movement="footprints",Mannequins="users-round",Players="users",Objects="box",Tools="scan-eye",
        ["Grab line"]="link",Crosshair="crosshair",Blackholes="orbit",Audio="volume-2",General="settings",Profiles="folder"}
    local function refresh(state)
        state.empty.Visible=false
        for _,entry in ipairs(state.groups) do
            if not entry.group.Destroyed then entry.group.BoxHolder.Visible=searching or entry.page==state.selected end
        end
        state.indicator.Visible=not searching
        for index,name in ipairs(state.names) do
            local button=state.buttons[name]
            local selected=name==state.selected and not searching
            if tweens[button] then tweens[button]:Cancel() tweens[button]=nil end
            button.TextTransparency=selected and 0 or 0.35
            if state.icons[name] then
                state.icons[name].ImageColor3=selected and (lib.Scheme.AccentColor or Color3.fromRGB(160,106,255)) or (lib.Scheme.FontColor or Color3.new(1,1,1))
                state.icons[name].ImageTransparency=selected and 0 or 0.4
            end
            if selected and state.rendered~=name then
                local position=UDim2.new((index-1)/#state.names,4,0,4)
                if state.rendered then animate(state.indicator,{Position=position}) else state.indicator.Position=position end
                state.rendered=name
            end
        end
    end
    for category,names in pairs(pages) do
        local tab=c.Tabs[category]
        local bar=make("Frame",{Name="PV_SectionBar",BackgroundColor3=Color3.fromRGB(15,15,19),BorderSizePixel=0,Size=UDim2.new(1,0,0,40),Position=UDim2.fromOffset(0,0)},tab.Container)
        make("UICorner",{CornerRadius=UDim.new(0,7)},bar)
        local barStroke=make("UIStroke",{Color=Color3.fromRGB(42,40,49),Transparency=0.4,Thickness=1},bar)
        theme(bar,{BackgroundColor3="MainColor"}) theme(barStroke,{Color="OutlineColor"})
        local indicator=make("Frame",{Name="ActiveSection",BackgroundColor3=Color3.fromRGB(33,28,43),BorderSizePixel=0,
            Size=UDim2.new(1/#names,-8,1,-8),Position=UDim2.fromOffset(4,4),ZIndex=1},bar)
        make("UICorner",{CornerRadius=UDim.new(0,5)},indicator)
        local edge=make("UIStroke",{Color=lib.Scheme.AccentColor or Color3.fromRGB(160,106,255),Transparency=0.65,Thickness=1},indicator)
        theme(edge,{Color="AccentColor"})
        local empty=make("TextLabel",{Name="NoSearchResults",Text="Nothing found",Font=Enum.Font.BuilderSans,TextSize=14,
            TextColor3=Color3.fromRGB(150,150,160),BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,-32,0,28),Visible=false},tab.Container)
        local state={tab=tab,selected=names[1],buttons={},icons={},groups={},bar=bar,names=names,empty=empty,indicator=indicator}
        states[category]=state
        for i,name in ipairs(names) do
            local button=make("TextButton",{Name="Section_"..name,Text=name,Font=Enum.Font.BuilderSans,TextSize=13,TextColor3=Color3.new(1,1,1),AutoButtonColor=false,
                BackgroundTransparency=1,BackgroundColor3=Color3.fromRGB(160,106,255),BorderSizePixel=0,ZIndex=2,Size=UDim2.new(1/#names,-8,1,-8),Position=UDim2.new((i-1)/#names,4,0,4)},bar)
            make("UICorner",{CornerRadius=UDim.new(0,4)},button)
            theme(button,{TextColor3="FontColor"})
            if type(lib.GetCustomIcon)=="function" and type(lib.ApplyLucideIcon)=="function" then
                local data=lib:GetCustomIcon(pageIcons[name] or "circle")
                if data then
                    local icon=make("ImageLabel",{Name="SectionIcon_"..name,BackgroundTransparency=1,Size=UDim2.fromOffset(15,15),
                        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new((i-1)/#names,15,0.5,0),ZIndex=3},bar)
                    lib:ApplyLucideIcon(icon,data) state.icons[name]=icon
                    make("UIPadding",{PaddingLeft=UDim.new(0,25),PaddingRight=UDim.new(0,5)},button)
                end
            end
            listen(button.MouseEnter,function() if not destroyed then animate(button,{BackgroundTransparency=0.94,TextTransparency=0}) end end)
            listen(button.MouseLeave,function() if not destroyed then animate(button,{BackgroundTransparency=1,TextTransparency=name==state.selected and 0 or 0.35}) end end)
            state.buttons[name]=button
            listen(button.MouseButton1Click,function()
                if destroyed then return end
                if lib.Searching and type(lib.ClearSearch)=="function" then lib:ClearSearch() end
                state.selected=name
                refresh(state)
                for _,side in ipairs(tab.Sides) do if side:IsA("ScrollingFrame") then side.CanvasPosition=Vector2.new(0,0) end end
            end)
        end
        tab.NavigationOffset=50
        for i,side in ipairs(tab.Sides) do
            side.Position=i==2 and UDim2.new(1,0,0,50) or UDim2.fromOffset(0,50)
            side.Size=UDim2.new(0.5,-4,1,-50)
            side.ScrollBarThickness=2 side.ScrollBarImageTransparency=0.55
            side.ScrollBarImageColor3=lib.Scheme.AccentColor or Color3.fromRGB(145,85,255)
        end
        refresh(state)
    end
    local oldSearch=lib.UpdateSearch
    local inSearch=false
    if type(oldSearch)=="function" then
        lib.UpdateSearch=function(self,text)
            if destroyed then return oldSearch(self,text) end
            if inSearch then return oldSearch(self,text) end
            inSearch=true
            searching=type(text)=="string" and text:find("%S")~=nil
            -- Search the complete category, including currently unselected subpages.
            if searching then for _,state in pairs(states) do refresh(state) end end
            local ok,message=pcall(oldSearch,self,text)
            if not searching then for _,state in pairs(states) do refresh(state) end end
            if searching then
                for _,state in pairs(states) do
                    local found=false
                    for _,entry in ipairs(state.groups) do if entry.group.BoxHolder.Visible then found=true break end end
                    state.empty.Visible=not found
                end
            end
            inSearch=false
            if not ok then error(message,0) end
        end
    end
    local controller={States=states}
    function controller:Group(tab,title,side,icon)
        local category=categoryFor[tab]
        local state=states[category]
        local route=routes[tab] and routes[tab][title]
        if not route then route={state.names[1],title,side or 1} end
        local page,name,column=route[1],route[2],route[3]
        local key=category.."/"..page.."/"..name
        if cache[key] then return cache[key] end
        local g=state.tab:AddGroupbox({Name=name,Side=column,IconName=icon,Visible=true,Collapsed=false,DisableCollapsing=true,PopOut=false})
        g.NavigationPage=page g.NavigationCategory=category
        if c.Translate then g.SearchAliases=c.Translate(page).." "..c.Translate(name) end
        state.groups[#state.groups+1]={group=g,page=page}
        cache[key]=g
        refresh(state)
        return g
    end
    function controller:Destroy()
        if destroyed then return end destroyed=true
        for object,tween in pairs(tweens) do tween:Cancel() tweens[object]=nil end
        if oldSearch then lib.UpdateSearch=oldSearch end
    end
    return controller
end
