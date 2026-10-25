-- Prime Vortex 0.2.2 | UI shell only. No gameplay hooks or features.
local VERSION="0.2.2"
local UI_TAG="vortex-v0.2.2"
local BASE="https://raw.githubusercontent.com/Mengy777/Prime-Script-FTAP/refs/tags/"..UI_TAG.."/lib/"
local function cleanupFailedStartup(state)
    state.Alive=false
    for _,key in ipairs({"SuppressSave","Close","CleanupEffects","RestoreSky"}) do
        if type(state[key])=="function" then pcall(state[key]) end
    end
    for _,connection in ipairs(type(state.Connections)=="table" and state.Connections or {}) do pcall(function() connection:Disconnect() end) end
    local library=state.Library
    if type(library)=="table" then
        if type(library.Unload)=="function" and not library.Unloaded then pcall(library.Unload,library) end
        for _,connection in pairs(type(library.Signals)=="table" and library.Signals or {}) do pcall(function() connection:Disconnect() end) end
        if library.ScreenGui then pcall(function() library.ScreenGui:Destroy() end) end
        if state.Input and library.ShowCursorBinding then
            pcall(function() game:GetService("RunService"):UnbindFromRenderStep(library.ShowCursorBinding) end)
        end
    end
    if state.Gui then pcall(function() state.Gui:Destroy() end) end
    if state.Input then pcall(function() state.Input.MouseBehavior=state.MouseBehavior state.Input.MouseIconEnabled=state.MouseIconEnabled end) end
    for camera,value in pairs(type(state.CameraFOVs)=="table" and state.CameraFOVs or {}) do pcall(function() camera.FieldOfView=value end) end
    if type(state.Environment)=="table" and state.Environment.Library==library then state.Environment.Library=nil end
end
local function reportStartupFailure(title,message)
    warn(title.." startup: "..tostring(message))
    return pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title=title,
            Text="Не удалось загрузить обязательные компоненты. Повтори запуск. Подробности в консоли.",Duration=8})
    end)
end
local startup={Alive=true}
local function startVortex()
local env=(getgenv and getgenv()) or shared
local previous=env.PrimeVortexUI
if type(previous)=="table" and type(previous.Unload)=="function" then previous:Unload() end

-- Keep Obsidian's global Library slot private to Vortex.
local privateEnv={}
local moduleCache={}
local function loadModule(name)
    local file=name=="Library" and "Obsidian" or name
    local chunk,source,message
    for attempt=1,3 do
        if not startup.Alive then error("Prime Vortex module load cancelled",0) end
        source=moduleCache[name]
        if not source then
            local url=BASE..file..".lua"..(attempt>1 and "?retry="..attempt or "")
            local ok,result=pcall(game.HttpGet,game,url)
            if ok and type(result)=="string" and result:find("%S") then source=result else message=tostring(result) end
        end
        if source then
            local compiled,result,detail=pcall(loadstring,"return function(getgenv, ...)\n"..source.."\nend","PrimeVortex/"..file)
            if compiled then chunk,message=result,detail else chunk,message=nil,result end
        end
        if chunk then break end
        moduleCache[name]=nil
        if attempt<3 then task.wait(0.35*attempt) end
    end
    if not chunk then error("Prime Vortex module "..file.." unavailable after 3 attempts: "..tostring(message),0) end
    if not startup.Alive then error("Prime Vortex module load cancelled",0) end
    local ok,result=pcall(function() return chunk()(function() return privateEnv end,loadModule,
        function(library) startup.Library=library end) end)
    if not ok then moduleCache[name]=nil error("Prime Vortex module "..file.." failed: "..tostring(result),0) end
    moduleCache[name]=source
    return result
end
startup.Environment=privateEnv
startup.Input=game:GetService("UserInputService")
startup.MouseBehavior=startup.Input.MouseBehavior startup.MouseIconEnabled=startup.Input.MouseIconEnabled
local Library=loadModule("Library")
if type(Library)=="table" then startup.Library=Library end
assert(type(Library)=="table" and type(Library.CreateWindow)=="function","Obsidian returned an invalid library")
local Run=game:GetService("RunService")
local Workspace=game:GetService("Workspace")
local red=Color3.fromRGB(235,39,54)
Library.ForceCheckbox=true
Library.Scheme.BackgroundColor=Color3.fromRGB(9,7,9)
Library.Scheme.MainColor=Color3.fromRGB(19,10,13)
Library.Scheme.OutlineColor=Color3.fromRGB(66,22,29)
Library.Scheme.AccentColor=red
Library.Scheme.FontColor=Color3.fromRGB(237,224,226)
Library.Scheme.DarkColor=Color3.fromRGB(5,4,6)

local controller={Version=VERSION,Library=Library,Unloaded=false}
env.PrimeVortexUI=controller
local connections={}
local function connect(signal,fn) local c=signal:Connect(fn) table.insert(connections,c) return c end
local function cleanup()
    if controller.Unloaded then return end
    controller.Unloaded=true
    startup.Alive=false
    if controller.Artwork then pcall(function() controller.Artwork:Destroy() end) end
    for _,c in ipairs(connections) do c:Disconnect() end connections={}
    if env.PrimeVortexUI==controller then env.PrimeVortexUI=nil end
end
function controller:Unload()
    if self.Unloaded then return end
    cleanup()
    if not Library.Unloaded then Library:Unload() end
end
startup.Close=function() controller:Unload() end
startup.Connections=connections
Library:OnUnload(cleanup)
local function make(class,properties,parent)
    local object=Instance.new(class)
    for key,value in pairs(properties) do object[key]=value end
    object.Parent=parent
    return object
end
    local function optionalArtwork(options)
        local before={}
        for _,parent in ipairs({options.Parent,options.Header}) do
            before[parent]={}
            for _,child in ipairs(parent:GetChildren()) do before[parent][child]=true end
        end
        local saved={}
        if options.Header then
            for _,property in ipairs({"Image","ImageTransparency","ImageColor3","ImageRectOffset","ImageRectSize"}) do saved[property]=options.Header[property] end
        end
        local ok,result=pcall(function()
            local factory=loadModule("AnimatedEmblem")
            assert(type(factory)=="function","Invalid artwork module")
            local artwork=factory(options)
            assert(type(artwork)=="table" and artwork.Root and type(artwork.Step)=="function" and type(artwork.Destroy)=="function","Invalid artwork controller")
            return artwork
        end)
        if ok then return result end
        for parent,existing in pairs(before) do
            for _,child in ipairs(parent:GetChildren()) do if not existing[child] then pcall(function() child:Destroy() end) end end
        end
        if options.Header then for property,value in pairs(saved) do pcall(function() options.Header[property]=value end) end end
        warn("Optional artwork disabled: "..tostring(result))
        if options.IsAlive and not options.IsAlive() then error("Artwork load cancelled",0) end
        Library:Notify("Artwork is unavailable. The rest of the menu still works.",5)
        local root=make("Frame",{Name="ArtworkUnavailable",BackgroundTransparency=1,
            AnchorPoint=Vector2.new(0.5,0.5),Position=options.Position or UDim2.fromScale(0.5,0.5),
            Size=options.Size or UDim2.fromScale(0.92,0.96)},options.Parent)
        return {Root=root,Unavailable=true,Step=function() end,Destroy=function() root:Destroy() end}
    end
local ok,err=xpcall(function()
    local viewport=Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    local window=Library:CreateWindow({
        Title="Prime Vortex",Footer="",Icon="flame",IconSize=UDim2.fromOffset(26,26),
        Size=UDim2.fromOffset(math.min(720,math.max(256,viewport.X-64)),math.min(600,math.max(360,viewport.Y-64))),
        Center=true,AutoShow=false,Resizable=false,Compact=true,EnableSidebarResize=false,
        DisableSearch=true,ToggleKeybind=Enum.KeyCode.RightControl,
        Font=Enum.Font.Code,CornerRadius=4,UnlockMouseWhileOpen=true,ShowCustomCursor=true,
        Animations={ToggleWindow=true,TabSwitch=true,Dropdown=true,Groupbox=true,KeyPicker=true},
        TabButtonsStyle={Gap=3,Padding=8,CornerRadius=4,Indicator=true,IndicatorWidth=2,IndicatorHeight=20},
    })
    Library.ScreenGui.Name="PrimeVortex"
    controller.Window=window
    local tab=window:AddTab({Name="Vortex",Icon="flame",Tooltip="Prime Vortex"})
    for _,side in ipairs(tab.Sides) do side.Visible=false end
    local canvas=make("Frame",{Name="VortexCanvas",BackgroundColor3=Color3.fromRGB(9,6,8),BorderSizePixel=0,
        Size=UDim2.new(1,-16,1,-12),Position=UDim2.fromOffset(8,6),ClipsDescendants=true},tab.Container)
    make("Frame",{BackgroundColor3=red,BackgroundTransparency=0.3,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,1)},canvas)
    local artwork=optionalArtwork({Parent=canvas,Header=window.IconHolder,
        Name="VortexDemon",Style="demon",Accent=red,
        Position=UDim2.fromScale(0.5,0.42),Size=UDim2.new(0.74,0,0.6,0),
        URL="https://raw.githubusercontent.com/Mengy777/Prime-Script-FTAP/refs/tags/"..UI_TAG.."/assets/vortex-demon-v1.png",
        CacheName="demon-422b782bef8e-hq.png",Bytes=1421042,
        IsAlive=function() return not controller.Unloaded end,
        IsVisible=function() return Library.Toggled end,
        Notify=function() Library:Notify("Preview PNG could not load. Details are in the executor console.",5) end,
    })
    controller.Artwork=artwork
    make("TextLabel",{Name="VortexWordmark",BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,1,14),Size=UDim2.new(1,140,0,36),Text="PRIME VORTEX",
        Font=Enum.Font.Code,TextSize=26,TextColor3=Color3.fromRGB(230,205,209)},artwork.Root)
    local close=make("TextButton",{Name="VortexClose",BackgroundTransparency=1,
        Position=UDim2.new(1,-32,0,8),Size=UDim2.fromOffset(24,24),Text="×",Font=Enum.Font.Code,
        TextSize=23,TextColor3=Color3.fromRGB(148,75,84),AutoButtonColor=false},canvas)
    connect(close.MouseButton1Click,function() controller:Unload() end)
    connect(close.MouseEnter,function() close.TextColor3=red end)
    connect(close.MouseLeave,function() close.TextColor3=Color3.fromRGB(148,75,84) end)

    local main=window.MainFrame
    local halo=make("Frame",{Name="VortexEmberGlow",BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,ZIndex=math.max(0,main.ZIndex-1)},main.Parent)
    local scale=main:FindFirstChildOfClass("UIScale")
    local haloScale=make("UIScale",{Scale=scale and scale.Scale or 1},halo)
    local edge=make("UIStroke",{Color=red,Thickness=1.3,Transparency=0.08},halo)
    local soft=make("Frame",{Size=UDim2.new(1,8,1,8),Position=UDim2.fromOffset(-4,-4),BackgroundTransparency=1,
        BorderSizePixel=0,Active=false},halo)
    local glow=make("UIStroke",{Color=red,Thickness=9,Transparency=0.9},soft)
    local function syncHalo()
        halo.Position=main.Position halo.Size=main.Size halo.AnchorPoint=main.AnchorPoint halo.Rotation=main.Rotation
        halo.Visible=main.Visible
        if scale then haloScale.Scale=scale.Scale end
    end
    for _,property in ipairs({"Position","Size","AnchorPoint","Rotation","Visible"}) do connect(main:GetPropertyChangedSignal(property),syncHalo) end
    if scale then connect(scale:GetPropertyChangedSignal("Scale"),syncHalo) end
    syncHalo()
    local embers={}
    for i=1,10 do embers[i]=make("Frame",{Name="Ember",BorderSizePixel=0,BackgroundColor3=red,
        BackgroundTransparency=0.85,Size=UDim2.fromOffset(i%3==0 and 2 or 1,2),Active=false},canvas) end
    local phase,elapsed=0,0
    connect(Run.RenderStepped,function(dt)
        if controller.Unloaded or not Library.Toggled then return end
        artwork:Step(dt)
        elapsed=elapsed+dt if elapsed<1/24 then return end
        phase=phase+math.min(elapsed,0.15) elapsed=0
        local pulse=(math.sin(phase*1.4)+1)/2
        local tint=Color3.fromRGB(224+math.floor(pulse*26),25+math.floor(pulse*35),40-math.floor(pulse*20))
        edge.Color=tint glow.Color=tint glow.Transparency=0.87+pulse*0.05
        for i,ember in ipairs(embers) do
            local life=(phase*0.055+i/10)%1
            ember.Position=UDim2.fromScale((i*0.137+math.sin(phase*0.3+i)*0.018)%1,1-life*0.72)
            ember.BackgroundTransparency=0.72+life*0.28 ember.BackgroundColor3=tint
        end
    end)
    connect(Library.ScreenGui.Destroying,function() controller:Unload() end)
    tab:Show()
    Library:Toggle(true)
end,debug.traceback)
if not ok then
    if startup.Alive then startup.Failed=true end
    controller:Unload() error(err,0)
end
return controller
end
local ok,result=xpcall(startVortex,debug.traceback)
if not ok then
    local cancelled=not startup.Alive and not startup.Failed
    cleanupFailedStartup(startup)
    local reported=true
    if not cancelled then reported=reportStartupFailure("Prime Vortex",result) end
    return nil,result,reported
end
return result
