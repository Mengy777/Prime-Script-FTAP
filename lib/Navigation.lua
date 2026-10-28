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
            Animations={"Movement","Animations",2},Mannequins={"Mannequins","Local mannequins",1},
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
    local function refresh(state)
        state.empty.Visible=false
        for _,entry in ipairs(state.groups) do
            if not entry.group.Destroyed then
                entry.group.BoxHolder.Visible=searching or entry.page==state.selected
            end
        end
        for name,button in pairs(state.buttons) do
            local selected=name==state.selected and not searching
            button.BackgroundColor3=selected and (lib.Scheme.AccentColor or Color3.fromRGB(145,85,255)) or Color3.fromRGB(20,20,24)
            button.BackgroundTransparency=selected and 0.82 or 0
            button.TextTransparency=selected and 0 or 0.35
            theme(button,{BackgroundColor3=selected and "AccentColor" or "MainColor",TextColor3="FontColor"})
        end
    end
    for category,names in pairs(pages) do
        local tab=c.Tabs[category]
        local bar=make("Frame",{Name="PV_SectionBar",BackgroundTransparency=1,Size=UDim2.new(1,0,0,32),Position=UDim2.fromOffset(0,0)},tab.Container)
        local empty=make("TextLabel",{Name="NoSearchResults",Text="Nothing found",Font=Enum.Font.BuilderSans,TextSize=14,
            TextColor3=Color3.fromRGB(150,150,160),BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,-32,0,28),Visible=false},tab.Container)
        local state={tab=tab,selected=names[1],buttons={},groups={},bar=bar,names=names,empty=empty}
        states[category]=state
        for i,name in ipairs(names) do
            local button=make("TextButton",{Name="Section_"..name,Text=name,Font=Enum.Font.BuilderSans,TextSize=13,TextColor3=Color3.new(1,1,1),AutoButtonColor=false,
                BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0,Size=UDim2.new(1/#names,-5,1,0),Position=UDim2.new((i-1)/#names,2,0,0)},bar)
            make("UICorner",{CornerRadius=UDim.new(0,4)},button)
            state.buttons[name]=button
            listen(button.MouseButton1Click,function()
                if destroyed then return end
                if lib.Searching and type(lib.ClearSearch)=="function" then lib:ClearSearch() end
                state.selected=name
                refresh(state)
                for _,side in ipairs(tab.Sides) do if side:IsA("ScrollingFrame") then side.CanvasPosition=Vector2.new(0,0) end end
            end)
        end
        tab.NavigationOffset=42
        for i,side in ipairs(tab.Sides) do
            side.Position=i==2 and UDim2.new(1,0,0,42) or UDim2.fromOffset(0,42)
            side.Size=UDim2.new(0.5,-4,1,-42)
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
        if oldSearch then lib.UpdateSearch=oldSearch end
    end
    return controller
end
