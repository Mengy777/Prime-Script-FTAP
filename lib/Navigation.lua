-- Presentation only: stable setting keys, callbacks and effect state stay in the main script.
return function(c)
    local lib,make,listen=c.Library,c.Make,c.Listen
    local pages={
        View={"Camera","Sky"},Graphics={"Lighting","Weather","Water & FPS"},
        Character={"Appearance","Movement","Mannequins"},ESP={"Players","Tools"},
        FTAP={"Grab line","Crosshair","Blackholes"},Personalization={"Interface","Audio"},["Prime Vortex"]={},Settings={"General","Profiles"},
    }
    -- Input group -> short subpage, shared card, column. Adjacent single-toggle cards merge.
    local routes={
        Camera={Camera={"Camera","Camera",1},View={"Camera","Camera",1},Freecam={"Camera","Camera tools",2},["Cinematic camera"]={"Camera","Camera tools",2}},
        Vortex={},
        Sky={Skybox={"Sky","Custom skybox",1},Sun={"Sky","Sun and clouds",2},Clouds={"Sky","Sun and clouds",2},["Skybox collection"]={"Sky","Sky collection",1}},
        Lighting={["Color and light"]={"Lighting","Lighting",1},["Scene presets"]={"Lighting","Lighting",1}},
        Particles={Particles={"Weather","Particles",1},Snowfall={"Weather","Snowfall",2}},
        World={["Map surfaces"]={"Surfaces","Map surfaces",1},Water={"Water & FPS","Water",1},["Ocean appearance"]={"Water & FPS","Water",1},Performance={"Water & FPS","Performance",2}},
        Character={
            ["Character finish"]={"Appearance","Body style",1},["Body appearance"]={"Appearance","Body style",1},
            ["Self ESP"]={"Appearance","Accessories",2},["Cone hat"]={"Appearance","Accessories",2},
            ["Movement visuals"]={"Movement","Movement effects",1},["Death visuals"]={"Movement","Movement effects",1},
            Mannequins={"Mannequins","Local mannequins",1},
        },
        ESP={Visibility={"Players","Player highlight",1},["Player markers"]={"Players","Player highlight",1},
            Geometry={"Players","Player overlays",2},
            ["Player visibility"]={"Tools","Player visibility",1},["Target trace"]={"Tools","Player tracker",1},
            ["Local position history"]={"Tools","Position history",2}},
        Personalization={["Game interface"]={"Interface","Game interface",2},["Toy collection"]={"Interface","Toy collection",1}},
        Tweaks={["Grab line"]={"Grab line","Grab line",1},Crosshair={"Crosshair","Crosshair",1},
            Blackholes={"Blackholes","Blackholes",1},["Animated blackholes"]={"Blackholes","Blackhole animation",2}},
        Audio={["Sound replacements"]={"Audio","Sound replacements",1},["Mute categories"]={"Audio","Mute sounds",1},["Blackhole sound"]={"Audio","Blackhole audio",2}},
        Settings={Protection={"General","Protection",2},Interface={"General","Interface",1},Configurations={"Profiles","Saved profiles",1},["Import / export"]={"Profiles","Share profiles",2}},
    }
    local categoryFor={Vortex="Prime Vortex",Camera="View",Sky="View",Lighting="Graphics",Particles="Graphics",World="Graphics",Character="Character",ESP="ESP",Tweaks="FTAP",Audio="Personalization",Personalization="Personalization",Settings="Settings"}
    local states,cache={},{} local destroyed=false
    for category in pairs(pages)do
        local tab=c.Tabs[category]
        states[category]={tab=tab,groups={}}
        tab.NavigationOffset=0
        for i,side in ipairs(tab.Sides)do
            side.Position=i==2 and UDim2.new(1,0,0,0)or UDim2.fromOffset(0,0)
            side.Size=UDim2.new(.5,-4,1,0)
            side.ScrollBarThickness=2
        end
    end
    local controller={States=states,Routes=routes}
    function controller:Group(tab,title,side,icon)
        local category=categoryFor[tab]local state=states[category]
        local route=routes[tab]and routes[tab][title]
        local page,name,column=route and route[1]or title,route and route[2]or title,route and route[3]or side or 1
        local key=category.."/"..name
        if cache[key]then return cache[key]end
        local g=state.tab:AddGroupbox({Name=name,Side=column,IconName=icon,Visible=true,Collapsed=false,DisableCollapsing=false,PopOut=false})
        g.NavigationPage=page g.NavigationCategory=category
        if c.Translate then g.SearchAliases=c.Translate(page).." "..c.Translate(name)end
        state.groups[#state.groups+1]={group=g,page=page}cache[key]=g
        return g
    end
    function controller:Destroy()destroyed=true cache={}end
    return controller
end
