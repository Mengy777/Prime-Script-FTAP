-- Prime Visuals | FTAP visual customization
local VERSION="1.2.1"
local sessionStarted=os.clock()
local sourceCache={}
local function loadUIModule(name)
    local filename=name=="Library" and "Obsidian" or name
    if not sourceCache[name] then
        sourceCache[name]=game:HttpGet("https://raw.githubusercontent.com/Mengy777/Prime-Script-FTAP/main/lib/"..filename..".lua")
    end
    local chunk,message=loadstring(sourceCache[name],"PrimeVisuals/"..filename)
    assert(chunk,message)
    return chunk(loadUIModule)
end
local function startVisuals(skipIntro)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
for _,name in ipairs({"PrimeVisuals","MengysVisual","FOVPanel"}) do
    local old=playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end
local connections={}
local cleanupExtra=function() end
local function listen(signal,fn)
    local c=signal:Connect(fn)
    table.insert(connections,c)
    return c
end
-- Live UI localization; internal feature identifiers always stay unchanged.
local uiLanguage="en"
local refreshHome=function() end
local ru={
    ["Home"]="Главная",
    ["Profile"]="Профиль",
    ["About Prime Visuals"]="О Prime Visuals",
    ["Session statistics"]="Статистика сессии",
    ["Camera"]="Камера",
    ["Sky"]="Небо",
    ["Lighting"]="Освещение",
    ["Particles"]="Частицы",
    ["World"]="Мир",
    ["Character"]="Персонаж",
    ["ESP"]="ESP",
    ["Tweaks"]="Эффекты FTAP",
    ["Audio"]="Звуки",
    ["Settings"]="Настройки",
    ["Reset all settings"]="Сбросить все настройки",
    ["Unload script"]="Полностью закрыть",
    ["View"]="Обзор",
    ["Graphics"]="Графика",
    ["Interface"]="Интерфейс",
    ["Language"]="Язык",
    ["English"]="English",
    ["Русский"]="Русский",
    ["Field of view"]="Угол обзора",
    ["FOV"]="FOV",
    ["Skybox"]="Скайбокс",
    ["Skybox link or ID"]="Ссылка или ID скайбокса",
    ["Load"]="Загрузить",
    ["Loading..."]="Загрузка...",
    ["Environment"]="Окружение",
    ["Remove haze"]="Убрать дымку",
    ["Reset sky"]="Сбросить небо",
    ["Color and light"]="Цвет и свет",
    ["Post-processing"]="Постобработка",
    ["Sun"]="Солнце",
    ["Clouds"]="Облака",
    ["Emission"]="Параметры частиц",
    ["Water"]="Вода",
    ["Performance"]="Производительность",
    ["Character finish"]="Материал персонажа",
    ["Cone hat"]="Коническая шляпа",
    ["Visibility"]="Отображение",
    ["Grab line"]="Линия захвата",
    ["Crosshair"]="Прицел",
    ["Blackholes"]="Чёрные дыры",
    ["Mute categories"]="Отключение звуков",
    ["Blackhole sound"]="Звук чёрной дыры",
    ["Third person [3]"]="Третье лицо [3]",
    ["Distance"]="Расстояние",
    ["Camera noclip"]="Камера сквозь стены",
    ["Disable ragdoll blur"]="Убрать размытие при падении",
    ["Show body in first person"]="Тело от первого лица",
    ["Limb transparency"]="Прозрачность конечностей",
    ["Shaders"]="Фильтры изображения",
    ["Brightness"]="Яркость",
    ["Exposure"]="Экспозиция",
    ["Saturation"]="Насыщенность",
    ["Contrast"]="Контраст",
    ["Tint"]="Оттенок",
    ["Bloom"]="Свечение",
    ["Sun rays"]="Солнечные лучи",
    ["Blur"]="Размытие",
    ["Time of day"]="Время суток",
    ["Sun size"]="Размер солнца",
    ["Show sun"]="Показывать солнце",
    ["Density"]="Плотность",
    ["Cover"]="Покрытие",
    ["Color"]="Цвет",
    ["Texture"]="Текстура",
    ["Custom image"]="Своя картинка",
    ["Count per second"]="Частиц в секунду",
    ["Performance cap"]="Лимит нагрузки",
    ["Size"]="Размер",
    ["Max speed"]="Максимальная скорость",
    ["Area"]="Область",
    ["Terrain water"]="Реалистичная вода",
    ["Realistic Water"]="Реалистичная вода",
    ["Non-swimmable water"]="Не плавать в воде",
    ["Wave size"]="Размер волн",
    ["Wave speed"]="Скорость волн",
    ["Transparency"]="Прозрачность",
    ["Reflectance"]="Отражение",
    ["Non-swimmable surface"]="Без плавания",
    ["Boost FPS"]="Оптимизация FPS",
    ["Simplify materials"]="Упростить материалы",
    ["Hide textures"]="Скрыть текстуры",
    ["Remove reflections"]="Убрать отражения",
    ["Remove shadows"]="Убрать тени",
    ["Forcefield highlight"]="Материал ForceField",
    ["Rainbow"]="Радужный цвет",
    ["Affect character"]="Применить к персонажу",
    ["Affect coconut forms"]="Применить к кокосам",
    ["Affect hat"]="Применить к шляпе",
    ["Affect anti-kick objects"]="Применить к анти-кику",
    ["Width"]="Ширина",
    ["Height offset"]="Смещение по высоте",
    ["Smooth movement"]="Плавное движение",
    ["Show owner when apart"]="Дистанция показа владельца",
    ["Custom line"]="Своя линия",
    ["Texture speed"]="Скорость текстуры",
    ["Grabbed object info"]="Информация об объекте",
    ["Custom crosshair"]="Свой прицел",
    ["Image"]="Картинка",
    ["Custom color"]="Свой цвет",
    ["Keep visual blackholes"]="Сохранять видимые дыры",
    ["Custom sound"]="Свой звук",
    ["Audio ID / MP3 link"]="ID звука / ссылка MP3",
    ["Reset filters"]="Сбросить фильтры",
    ["Reset time and sun"]="Сбросить время и солнце",
    ["Players"]="Игроки",
    ["Server"]="Сервер",
    ["Sticky"]="Липкие предметы",
    ["Server detectors"]="Серверные маркеры",
    ["Stickies"]="Липкие предметы",
    ["Highlight"]="Подсветка",
    ["Fill"]="Заливка",
    ["Rainbow fill"]="Радужная заливка",
    ["Outline"]="Контур",
    ["Fill transparency"]="Прозрачность заливки",
    ["Outline transparency"]="Прозрачность контура",
    ["Outline thickness"]="Толщина контура",
    ["Name"]="Имя",
    ["Font"]="Шрифт",
    ["Bold"]="Жирный шрифт",
    ["Name icon"]="Значок у имени",
    ["Text color"]="Цвет текста",
    ["Text outline"]="Контур текста",
    ["Text outline transparency"]="Прозрачность контура текста",
    ["Text size"]="Размер текста",
    ["Vertical offset"]="Смещение по высоте",
    ["Ambience"]="Окружение",
    ["Boomboxes / jukeboxes"]="Бумбоксы и проигрыватели",
    ["Screams"]="Крики",
    ["Explosions"]="Взрывы",
    ["Soundwaves"]="Звуковые волны",
    ["Rhythm makers"]="Ритм-машины",
    ["Instruments"]="Инструменты",
    ["Circles"]="Круги",
    ["Snowflakes"]="Снежинки",
    ["Prime"]="Prime",
    ["Custom"]="Своя",
    ["Laser"]="Лазер",
    ["Chain"]="Цепь",
    ["Chain 2"]="Цепь 2",
    ["Chain 3"]="Цепь 3",
    ["Chain 4"]="Цепь 4",
    ["Pulse"]="Импульс",
    ["Rope"]="Верёвка",
    ["Dots"]="Точки",
    ["Bubbles"]="Пузыри",
    ["Spring"]="Пружина",
    ["Gamepass"]="Геймпасс",
    ["Default"]="Стандартная",
    ["ID or link"]="ID или ссылка",
    ["Enter a valid skybox ID or Creator Store link."]="Введите ID скайбокса или ссылку Creator Store.",
    ["Loading timed out. Check the asset and try again."]="Загрузка не завершилась. Проверьте ID и повторите.",
    ["Could not apply skybox. Try another asset."]="Не удалось применить небо. Попробуйте другой скайбокс.",
    ["No Sky object in this asset. Use a skybox model ID."]="Объект Sky не найден. Нужен ID модели скайбокса.",
    ["Client model loading unavailable or asset inaccessible."]="Загрузка модели недоступна либо ассет закрыт.",
    ["Use a Roblox image or audio asset ID"]="Нужен Roblox ID картинки или звука.",
    ["This executor cannot load MP3 links; use a Roblox audio ID."]="Этот executor не загружает MP3. Используйте Roblox ID звука.",
    ["Audio download failed"]="Не удалось загрузить звук.",
    ["Audio file is larger than 15 MB"]="Звуковой файл больше 15 МБ.",
    ["Water region is too large for safe conversion; terrain water settings still apply."]="Область воды слишком большая для преобразования. Настройки существующей воды применены.",
}
local localized=setmetatable({}, {__mode="k"})
local function translateText(text)
    if uiLanguage~="ru" or type(text)~="string" then return text end
    if ru[text] then return ru[text] end
    local body,suffix=text:match("^(.-)(%s+>)$")
    if body and ru[body] then return ru[body]..suffix end
    return text
end
local function bindLocalization(o)
    if localized[o] then return end
    local class=o.ClassName
    if class~="TextLabel" and class~="TextButton" and class~="TextBox" then return end
    local record={base={},writing=false}
    localized[o]=record
    local properties=class=="TextBox" and {"PlaceholderText"} or {"Text"}
    for _,property in ipairs(properties) do
        record.base[property]=o[property]
        listen(o:GetPropertyChangedSignal(property),function()
            if record.writing then return end
            record.base[property]=o[property]
            record.writing=true
            o[property]=translateText(record.base[property])
            record.writing=false
        end)
    end
end
local function setLanguage(language)
    uiLanguage=language
    for o,record in pairs(localized) do
        if o.Parent then
            record.writing=true
            for property,text in pairs(record.base) do o[property]=translateText(text) end
            record.writing=false
        end
    end
    refreshHome()
end

local function make(class,props,parent)
    local obj=Instance.new(class)
    for key,value in pairs(props) do obj[key]=value end
    obj.Parent=parent
    bindLocalization(obj)
    return obj
end
local purple=Color3.fromRGB(160,106,255)
local white=Color3.fromRGB(230,228,237)
local black=Color3.fromRGB(9,9,11)

-- Real Obsidian window and controls, vendored from the current Resonance UI modules.
local Library=loadUIModule("Library")
Library.ForceCheckbox=true
Library.Scheme.AccentColor=purple
local savedBehavior,savedIcon=UIS.MouseBehavior,UIS.MouseIconEnabled
local viewport=Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
local windowWidth=math.min(720,math.max(256,viewport.X-64))
local windowHeight=math.min(600,math.max(360,viewport.Y-64))
local nativeWindow=Library:CreateWindow({
    Title="Prime Visuals",Footer="",Icon="diamond",IconSize=UDim2.fromOffset(26,26),
    Size=UDim2.fromOffset(windowWidth,windowHeight),Center=true,AutoShow=false,Resizable=false,
    ToggleKeybind=Enum.KeyCode.RightShift,EnableSidebarResize=false,Compact=true,
    ShowCustomCursor=true,UnlockMouseWhileOpen=true,Font=Enum.Font.Code,CornerRadius=6,
    Animations={ToggleWindow=false,TabSwitch=true,Dropdown=true,Groupbox=true,KeyPicker=true},
    TabSwipeFrom="Auto",TabButtonsStyle={Gap=3,Padding=8,CornerRadius=6,Indicator=true,IndicatorWidth=2,IndicatorHeight=20}
})
local gui=make("ScreenGui",{Name="PrimeVisuals",ResetOnSpawn=false,Enabled=false},playerGui)
local menuOpen=false
local closing=false
local initialFOV=Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70
local selected=math.clamp(math.round(initialFOV),30,120)
local fovChanged=false
local function applyFOV()
    if fovChanged and Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=selected end
end
listen(Workspace:GetPropertyChangedSignal("CurrentCamera"),applyFOV)
local skyInput={Text=""}
local skyMessage={Text="",Visible=false}
local loadButton={Text="Load"}
-- Sky changes are opt-in. Original Sky instances are retained for an exact reset.
local originalSkies={}
for _,o in ipairs(Lighting:GetChildren()) do
    if o:IsA("Sky") then table.insert(originalSkies,o) end
end
local sourceSky=originalSkies[1]
local skyProperties={"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}
local activeSky
local customSkyLoaded=false
local onCustomSkyApplied=function() end
local onSkyRestored=function() end
local skyLoadGeneration=0
local skyLoadBusy=false
local hazeEnabled=false
local hiddenAtmospheres={}
local originalFogStart,originalFogEnd=Lighting.FogStart,Lighting.FogEnd
local function clearHaze(enabled)
    if hazeEnabled==enabled then return end
    hazeEnabled=enabled
    if enabled then
        hiddenAtmospheres={}
        for _,o in ipairs(Lighting:GetChildren()) do
            if o:IsA("Atmosphere") then table.insert(hiddenAtmospheres,o) o.Parent=nil end
        end
        Lighting.FogStart=1000000
        Lighting.FogEnd=1000000
    else
        for _,o in ipairs(hiddenAtmospheres) do if o.Parent==nil then o.Parent=Lighting end end
        hiddenAtmospheres={}
        Lighting.FogStart=originalFogStart
        Lighting.FogEnd=originalFogEnd
    end
end
local function ensureSky()
    if activeSky and activeSky.Parent==Lighting then return activeSky end
    if activeSky then activeSky:Destroy() end
    activeSky=sourceSky and sourceSky:Clone() or Instance.new("Sky")
    activeSky.Name="PrimeVisualsSky"
    for _,o in ipairs(originalSkies) do
        if o.Parent==Lighting then o.Parent=nil end
    end
    activeSky.Parent=Lighting
    return activeSky
end
local function restoreSky()
    skyLoadGeneration=skyLoadGeneration+1
    skyLoadBusy=false
    if hazeEnabled then clearHaze(false) end
    if activeSky then activeSky:Destroy() activeSky=nil end
    for _,o in ipairs(originalSkies) do
        if o.Parent==nil then o.Parent=Lighting end
    end
    customSkyLoaded=false
    onSkyRestored()
end
local function assetUrl(text)
    text=text:match("^%s*(.-)%s*$")
    local id=text:match("^(%d+)$") or text:match("^rbxassetid://(%d+)$") or text:match("[?&]id=(%d+)") or text:match("roblox.com/library/(%d+)") or text:match("roblox.com/store/asset/(%d+)")
    if not id or not id:match("[1-9]") then return nil end
    return "rbxassetid://" .. id
end
-- Verified from the published Purple Sky model; also works if client model loading is unavailable.
local knownSkyboxes={
    ["570559352"]={SkyboxBk="rbxassetid://570557514",SkyboxDn="rbxassetid://570557775",
        SkyboxFt="rbxassetid://570557559",SkyboxLf="rbxassetid://570557620",
        SkyboxRt="rbxassetid://570557672",SkyboxUp="rbxassetid://570557727",CelestialBodiesShown=false}
}
local importedProperties={"CelestialBodiesShown","SunAngularSize","MoonAngularSize","StarCount","SunTextureId","MoonTextureId"}
local function readSkyModel(url)
    local ok,objects=pcall(function() return game:GetObjects(url) end)
    if not ok or type(objects)~="table" then
        return nil,"Client model loading unavailable or asset inaccessible."
    end
    local data
    local success,message=pcall(function()
        local found
        for _,root in ipairs(objects) do
            if root:IsA("Sky") then found=root break end
            found=root:FindFirstChildWhichIsA("Sky",true)
            if found then break end
        end
        if not found then return end
        local result={}
        for _,property in ipairs(skyProperties) do
            local texture=found[property]
            if texture=="" then error("Missing skybox texture: " .. property) end
            result[property]=texture
        end
        for _,property in ipairs(importedProperties) do result[property]=found[property] end
        data=result
    end)
    -- Loaded instances stay unparented. Copy only Sky properties; destroy the entire package.
    for _,root in ipairs(objects) do pcall(function() root:Destroy() end) end
    if not success then return nil,tostring(message) end
    if not data then return nil,"No Sky object in this asset. Use a skybox model ID." end
    return data
end
local function skyFeedback(text,isError)
    skyMessage.Text=isError and text or ""
    skyMessage.Visible=isError==true
    if isError then Library:Notify(tostring(text),5) end
    if loadButton then loadButton.Text=text=="Loading skybox..." and "Loading..." or "Load" end
end
local function applyCustomSky()
    if skyLoadBusy then return end
    local url=assetUrl(skyInput.Text)
    if not url then skyFeedback("Enter a valid skybox ID or Creator Store link.",true) return end
    local id=url:match("(%d+)$")
    skyLoadGeneration=skyLoadGeneration+1
    local requestGeneration=skyLoadGeneration
    skyLoadBusy=true
    skyFeedback("Loading skybox...",false)
    task.delay(15,function()
        if requestGeneration==skyLoadGeneration and skyLoadBusy and gui.Parent then
            skyLoadGeneration=skyLoadGeneration+1
            skyLoadBusy=false
            skyFeedback("Loading timed out. Check the asset and try again.",true)
        end
    end)
    task.spawn(function()
        local data,message=knownSkyboxes[id]
        if not data then data,message=readSkyModel(url) end
        if requestGeneration~=skyLoadGeneration or not gui.Parent then return end
        skyLoadBusy=false
        if not data then skyFeedback(message,true) return end
        local ok,err=pcall(function()
            local sky=ensureSky()
            for property,value in pairs(data) do sky[property]=value end
            customSkyLoaded=true
            onCustomSkyApplied(data)
        end)
        if not ok then skyFeedback("Could not apply skybox. Try another asset.",true) warn("Prime Visuals Sky: " .. tostring(err)) return end
        skyFeedback("Skybox loaded / six separate textures.",false)
    end)
end
local function buildVisualSystems()
    local player=Players.LocalPlayer
    local Run=RunService
    local Terrain=Workspace.Terrain
    local SoundService=game:GetService("SoundService")
    local jobs,owned,patches={}, {}, {}
    local alive=true
    local setters={}
    local controls={}
    local function notify(text) Library:Notify(tostring(text),5) end
    local function job(name,signal,fn)
        if jobs[name] then jobs[name]:Disconnect() jobs[name]=nil end
        if signal and fn then jobs[name]=signal:Connect(function(...)
            if not alive then return end
            local ok,err=pcall(fn,...)
            if not ok then
                if jobs[name] then jobs[name]:Disconnect() jobs[name]=nil end
                warn("Prime Visuals / " .. name .. ": " .. tostring(err))
                notify(name .. ": stopped after an error. Toggle it off and report this feature.")
            end
        end) end
    end
    local function own(o) owned[o]=true return o end
    local function dispose(o) if o then owned[o]=nil o:Destroy() end end
    -- Layered property changes: disabling one effect preserves the other active effects.
    local sequence=0
    local function patch(feature,o,property,value)
        patches[o]=patches[o] or {}
        local entry=patches[o][property]
        if not entry then entry={original=o[property],layers={}} patches[o][property]=entry end
        local old=entry.layers[feature]
        if not old or old.value~=value then
            sequence=sequence+1
            entry.layers[feature]={value=value,order=sequence}
        end
        local top
        for _,layer in pairs(entry.layers) do if not top or layer.order>top.order then top=layer end end
        if o[property]~=top.value then o[property]=top.value end
    end
    local function unpatch(feature)
        for o,properties in pairs(patches) do
            for property,entry in pairs(properties) do
                if entry.layers[feature] then
                    entry.layers[feature]=nil
                    local top
                    for _,layer in pairs(entry.layers) do if not top or layer.order>top.order then top=layer end end
                    pcall(function() if top then o[property]=top.value else o[property]=entry.original end end)
                    if not top then properties[property]=nil end
                end
            end
            if next(properties)==nil then patches[o]=nil end
        end
    end
    local function imageId(text)
        local value=assetUrl(tostring(text or ""))
        if not value then error("Use a Roblox image or audio asset ID") end
        return value
    end
    local function safe(fn,...)
        local ok,err=pcall(fn,...)
        if not ok then notify(err) end
        return ok
    end

    local building=true
    local suppressed=false
    local widgets={}
    local tabs={}
    local categoryTabs={}
    local categories={
        {"Home","house",{"Home"}},
        {"View","camera",{"Camera","Sky"}},
        {"Graphics","sparkles",{"Lighting","Particles","World"}},
        {"Character","user-round",{"Character"}},
        {"ESP","scan-eye",{"ESP"}},
        {"FTAP","orbit",{"Tweaks","Audio"}},
        {"Settings","settings",{"Settings"}}
    }
    for _,category in ipairs(categories) do
        local tab=nativeWindow:AddTab({Name=category[1],Icon=category[2],Tooltip=category[1]})
        categoryTabs[category[1]]=tab
        for _,name in ipairs(category[3]) do tabs[name]=tab end
    end
    local function put(key,value) controls[key]=value end
    local function register(key,widget,initial,callback,isColor)
        put(key,initial) widgets[key]=widget
        local function set(value,apply)
            local wasSuppressed=suppressed
            suppressed=true
            if isColor then widget:SetValueRGB(value) else widget:SetValue(value) end
            suppressed=wasSuppressed
            put(key,widget.Value)
            if apply then safe(callback,widget.Value) end
        end
        setters[key]=set
        return set
    end
    local function changed(key,callback)
        return function(value)
            if building or suppressed or not alive then return end
            local previous=controls[key]
            put(key,value)
            if not safe(callback,value) then
                local widget=widgets[key]
                if widget then
                    suppressed=true
                    if widget.Type=="ColorPicker" then widget:SetValueRGB(previous) else widget:SetValue(previous) end
                    suppressed=false
                end
                put(key,previous)
                pcall(callback,previous)
            end
        end
    end
    local groupIcons={Home="house",Camera="camera",Sky="cloud-moon",Lighting="sun",Particles="sparkles",World="globe",Character="user-round",ESP="scan-eye",Tweaks="orbit",Audio="volume-2",Settings="settings"}
    local function group(tab,title,side)
        local collapsed=title=="Emission" or title=="Post-processing" or (tab=="ESP" and title~="Visibility")
        local parent=tabs[tab]
        if side==2 then return parent:AddRightGroupbox(title,groupIcons[tab],true,collapsed) end
        return parent:AddLeftGroupbox(title,groupIcons[tab],true,collapsed)
    end
    local function toggle(g,key,text,initial,callback)
        local widget=g:AddToggle(key,{Text=text,Default=initial,Callback=changed(key,callback)})
        return register(key,widget,initial,callback)
    end
    local function sliderControl(g,key,text,low,high,initial,step,callback)
        local rounding=step>=1 and 0 or step>=0.1 and 1 or step>=0.01 and 2 or 3
        local widget=g:AddSlider(key,{Text=text,Min=low,Max=high,Default=initial,Rounding=rounding,AllowRightClickInput=true,Callback=changed(key,callback)})
        return register(key,widget,initial,callback)
    end
    local function field(g,key,text,initial,callback,live)
        local widget=g:AddInput(key,{Text=text,Default=tostring(initial or ""),Finished=not live,Callback=changed(key,callback)})
        return register(key,widget,initial,callback)
    end
    local function choice(g,key,text,values,initial,callback)
        local widget=g:AddDropdown(key,{Text=text,Values=values,Default=table.find(values,initial) or 1,Callback=changed(key,callback)})
        return register(key,widget,initial,callback)
    end
    local function color(g,key,text,initial,callback)
        g:AddLabel(text):AddColorPicker(key,{Default=initial,Title=text,Callback=changed(key,callback)})
        local widget=Library.Options[key]
        assert(widget and type(widget.SetValueRGB)=="function","Color picker was not registered: "..key)
        return register(key,widget,initial,callback,true)
    end
    local function action(g,text,fn)
        return g:AddButton({Text=text,Func=function() if alive then safe(fn) end end})
    end
    local cameraGroup=group("Camera","Camera",1)
    sliderControl(cameraGroup,"cameraFOV","FOV",30,120,selected,1,function(value)
        selected=value fovChanged=true applyFOV()
    end)
    local skyGroup=group("Sky","Skybox",1)
    field(skyGroup,"skyAsset","Skybox ID or link","",function(value) skyInput.Text=value end,true)
    action(skyGroup,"Load",applyCustomSky)
    toggle(skyGroup,"skyHaze","Remove haze",false,clearHaze)
    action(skyGroup,"Reset sky",function()
        restoreSky() setters.skyAsset("",false) skyInput.Text="" setters.skyHaze(false,false)
    end)
    -- CAMERA
    local function updateThirdPerson(on)
        if on then
            local distance=controls.camDistance or 12
            patch("third",player,"CameraMode",Enum.CameraMode.Classic)
            -- Keep both zoom limits at the selected distance so moving either way applies immediately.
            if player.CameraMaxZoomDistance<distance then
                patch("third",player,"CameraMaxZoomDistance",distance)
            end
            patch("third",player,"CameraMinZoomDistance",distance)
            patch("third",player,"CameraMaxZoomDistance",distance)
        else unpatch("third") end
    end
    do
        local g=group("Camera","View",2)
        toggle(g,"camThird","Third person [3]",false,updateThirdPerson)
        sliderControl(g,"camDistance","Distance",2,80,12,1,function() if controls.camThird then updateThirdPerson(true) end end)
        toggle(g,"camNoclip","Camera noclip",false,function(on)
            job("Camera noclip")
            if not on then return end
            local camera=Workspace.CurrentCamera
            local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local look=camera.CFrame.LookVector
            local pitch=math.asin(math.clamp(look.Y,-1,1))
            local yaw=math.atan2(-look.X,-look.Z)
            job("Camera noclip",Run.RenderStepped,function(dt)
                camera=Workspace.CurrentCamera
                hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not camera or not hrp then return end
                if not menuOpen then
                    local d=UIS:GetMouseDelta()
                    yaw=yaw-d.X*0.003
                    pitch=math.clamp(pitch-d.Y*0.003,-1.5,1.5)
                end
                local rotation=CFrame.fromOrientation(pitch,yaw,0)
                local focus=hrp.Position+Vector3.new(0,1.5,0)
                local distance=controls.camThird and controls.camDistance or 0.5
                camera.CFrame=CFrame.new(focus-rotation.LookVector*distance)*rotation
                camera.Focus=CFrame.new(focus)
            end)
        end)
        toggle(g,"camBlur","Disable ragdoll blur",false,function(on)
            job("Blur added") job("Lighting blur added")
            if not on then unpatch("blur") return end
            local function disable(o) if o:IsA("BlurEffect") then patch("blur",o,"Enabled",false) end end
            for _,root in ipairs({Lighting,Workspace.CurrentCamera}) do if root then for _,o in ipairs(root:GetDescendants()) do disable(o) end end end
            job("Blur added",Workspace.CurrentCamera.DescendantAdded,disable)
            job("Lighting blur added",Lighting.DescendantAdded,disable)
        end)
        toggle(g,"camBody","Show body in first person",false,function(on)
            job("First person body")
            if not on then unpatch("body") return end
            job("First person body",Run.RenderStepped,function()
                local character=player.Character
                if not character then return end
                for _,part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name~="Head" and part.Name~="HumanoidRootPart" then patch("body",part,"LocalTransparencyModifier",controls.camBodyAlpha or 0.3) end
                end
            end)
        end)
        sliderControl(g,"camBodyAlpha","Limb transparency",0,1,0.3,0.05,function() end)
        listen(UIS.InputBegan,function(event,processed)
            if not processed and not UIS:GetFocusedTextBox() and event.KeyCode==Enum.KeyCode.Three then setters.camThird(not controls.camThird,true) end
        end)
    end
    -- LIGHTING: independently adjustable post-processing, without replacing game effects.
    local effects={}
    local function effect(name,class)
        if not effects[name] then effects[name]=own(make(class,{Name="PV_"..name,Enabled=false},Lighting)) end
        return effects[name]
    end
    local function shaders(on)
        if not on then
            unpatch("shader")
            for _,name in ipairs({"Color","Bloom","Rays","SoftBlur"}) do if effects[name] then effects[name].Enabled=false end end
            return
        end
        patch("shader",Lighting,"Brightness",controls.lightBrightness or 2)
        patch("shader",Lighting,"ExposureCompensation",controls.lightExposure or 0)
        local c=effect("Color","ColorCorrectionEffect")
        c.Enabled=true c.Saturation=controls.lightSaturation or 0.15 c.Contrast=controls.lightContrast or 0.05 c.TintColor=controls.lightTint or Color3.new(1,1,1)
        local bloom=effect("Bloom","BloomEffect")
        bloom.Enabled=true bloom.Intensity=controls.lightBloom or 0.25 bloom.Size=24 bloom.Threshold=1
        local rays=effect("Rays","SunRaysEffect") rays.Enabled=true rays.Intensity=controls.lightRays or 0.03
        local blur=effect("SoftBlur","BlurEffect") blur.Enabled=(controls.lightBlur or 0)>0 blur.Size=controls.lightBlur or 0
    end
    do
        local g=group("Lighting","Color and light",1)
        toggle(g,"lightEnabled","Shaders",false,shaders)
        local function update() if controls.lightEnabled then shaders(true) end end
        sliderControl(g,"lightBrightness","Brightness",0,5,2,0.05,update)
        sliderControl(g,"lightExposure","Exposure",-3,3,0,0.05,update)
        sliderControl(g,"lightSaturation","Saturation",-1,1,0.15,0.05,update)
        sliderControl(g,"lightContrast","Contrast",-1,1,0.05,0.05,update)
        color(g,"lightTint","Tint",Color3.new(1,1,1),update)
        local h=group("Lighting","Post-processing",2)
        sliderControl(h,"lightBloom","Bloom",0,3,0.25,0.05,update)
        sliderControl(h,"lightRays","Sun rays",0,1,0.03,0.01,update)
        sliderControl(h,"lightBlur","Blur",0,24,0,0.5,update)
        action(h,"Reset filters",function()
            setters.lightEnabled(false,true)
            for key,v in pairs({lightBrightness=2,lightExposure=0,lightSaturation=0.15,lightContrast=0.05,lightBloom=0.25,lightRays=0.03,lightBlur=0}) do setters[key](v,false) end
            setters.lightTint(Color3.new(1,1,1),false)
        end)
    end
    -- Sky additions. Time and sun return here as compact optional controls.
    do
        local g=group("Sky","Sun",1)
        local originalClock=Lighting.ClockTime
        local originalSunVisible=not sourceSky or (sourceSky.CelestialBodiesShown and sourceSky.SunAngularSize>0)
        toggle(g,"skySunVisible","Show sun",originalSunVisible,function(on)
            local sky=ensureSky()
            if on then
                sky.CelestialBodiesShown=true
                if (controls.skySun or 21)<=0 then setters.skySun(21,false) end
                sky.SunAngularSize=controls.skySun or 21
            else sky.SunAngularSize=0 end
        end)
        sliderControl(g,"skyTime","Time of day",0,24,originalClock,0.1,function(v) patch("skytime",Lighting,"ClockTime",v) end)
        sliderControl(g,"skySun","Sun size",0,60,sourceSky and sourceSky.SunAngularSize or 21,0.5,function(v)
            if controls.skySunVisible then ensureSky().SunAngularSize=v end
        end)
        action(g,"Reset time and sun",function()
            unpatch("skytime") setters.skyTime(originalClock,false)
            local value=sourceSky and sourceSky.SunAngularSize or 21
            setters.skySun(value,false)
            setters.skySunVisible(originalSunVisible,true)
        end)
        local h=group("Sky","Clouds",2)
        local cloud
        local function hideGameCloud(o)
            if alive and customSkyLoaded and not controls.skyClouds and o:IsA("Clouds") then
                patch("skyweather",o,"Enabled",false)
            end
        end
        local function updateClouds(on)
            job("Sky background clouds")
            unpatch("skyweather")
            if not on then
                unpatch("clouds")
                if cloud and owned[cloud] then dispose(cloud) end
                cloud=nil
                if customSkyLoaded then
                    for _,o in ipairs(Terrain:GetDescendants()) do hideGameCloud(o) end
                    job("Sky background clouds",Terrain.DescendantAdded,hideGameCloud)
                end
                return
            end
            cloud=cloud and cloud.Parent and cloud or Terrain:FindFirstChildOfClass("Clouds")
            if not cloud then cloud=own(make("Clouds",{Enabled=false},Terrain)) end
            patch("clouds",cloud,"Enabled",true)
            patch("clouds",cloud,"Density",controls.skyCloudDensity or 0.5)
            patch("clouds",cloud,"Cover",controls.skyCloudCover or 0.5)
            patch("clouds",cloud,"Color",controls.skyCloudColor or Color3.new(1,1,1))
        end
        toggle(h,"skyClouds","Clouds",false,updateClouds)
        local function update() if controls.skyClouds then updateClouds(true) end end
        sliderControl(h,"skyCloudDensity","Density",0,1,0.5,0.05,update)
        sliderControl(h,"skyCloudCover","Cover",0,1,0.5,0.05,update)
        color(h,"skyCloudColor","Color",Color3.new(1,1,1),update)
        onCustomSkyApplied=function(data)
            setters.skySun(math.clamp(tonumber(data.SunAngularSize) or 21,0,60),false)
            setters.skySunVisible(false,true)
            setters.skyClouds(false,true)
        end
        onSkyRestored=function()
            if not alive then return end
            setters.skyClouds(false,true)
            setters.skySun(sourceSky and sourceSky.SunAngularSize or 21,false)
            setters.skySunVisible(originalSunVisible,false)
        end
    end
    -- PARTICLES
    local particlePart,emitter
    local function updateParticles(on)
        if not on then job("Particles") dispose(particlePart) particlePart,emitter=nil,nil return end
        if not particlePart then
            particlePart=own(make("Part",{Name="PV_Particles",Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Transparency=1,Size=Vector3.new(60,60,60)},Workspace))
            emitter=make("ParticleEmitter",{Enabled=true,LightEmission=0.7,Speed=NumberRange.new(0,2),Lifetime=NumberRange.new(4,7),SpreadAngle=Vector2.new(180,180),Rotation=NumberRange.new(0,360)},particlePart)
            job("Particles",Run.RenderStepped,function()
                if Workspace.CurrentCamera and particlePart then particlePart.CFrame=CFrame.new(Workspace.CurrentCamera.CFrame.Position) end
            end)
        end
        local texture=controls.particleTexture or "Circles"
        local urls={Circles="rbxassetid://242109931",Snowflakes="rbxassetid://14443362047",Prime="rbxassetid://79685990879972"}
        emitter.Texture=urls[texture] or imageId(controls.particleImage)
        emitter.Color=ColorSequence.new(controls.particleColor or purple)
        emitter.Rate=math.min(controls.particleCount or 150,controls.particleLimit or 1000)
        emitter.Size=NumberSequence.new(controls.particleSize or 0.15)
        emitter.Speed=NumberRange.new(0,controls.particleSpeed or 2)
        local size=controls.particleArea or 60 particlePart.Size=Vector3.new(size,size,size)
    end
    do
        local g=group("Particles","Particles",1)
        toggle(g,"particleEnabled","Particles",false,updateParticles)
        local function update() if controls.particleEnabled then updateParticles(true) end end
        choice(g,"particleTexture","Texture",{"Circles","Snowflakes","Prime","Custom"},"Circles",update)
        field(g,"particleImage","Custom image","242109931",update)
        color(g,"particleColor","Color",purple,update)
        local h=group("Particles","Emission",2)
        sliderControl(h,"particleCount","Count per second",10,5000,150,10,update)
        sliderControl(h,"particleLimit","Performance cap",100,5000,1000,100,update)
        sliderControl(h,"particleSize","Size",0.05,5,0.15,0.05,update)
        sliderControl(h,"particleSpeed","Max speed",0,20,2,0.5,update)
        sliderControl(h,"particleArea","Area",10,300,60,5,update)
    end
    -- WORLD: FTAP ocean replacement in bounded chunks, with original terrain preserved.
    local waterRegions={}
    local waterGeneration=0
    local waterParts={}
    local waterQueue={}
    local waterQueueHead=1
    local waterWorker=false
    local waterBatch=false
    local function scan(root,callback)
        local list=root:GetDescendants()
        task.spawn(function()
            for index,o in ipairs(list) do
                if not alive then break end
                if o.Parent and not safe(callback,o) then break end
                if index%150==0 then task.wait() end
            end
        end)
    end
    local function oceanRoot()
        local map=Workspace:FindFirstChild("Map")
        local objects=map and map:FindFirstChild("AlwaysHereTweenedObjects")
        local ocean=objects and objects:FindFirstChild("Ocean")
        local object=ocean and ocean:FindFirstChild("Object")
        return object and object:FindFirstChild("ObjectModel") or ocean
    end
    local function isWaterPart(o)
        local root=oceanRoot()
        return root and o:IsA("BasePart") and o:IsDescendantOf(root) and o.Transparency<1
    end
    local swimmingState
    local function updateSwimming()
        local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        local enabled=controls.waterEnabled and controls.waterSolid
        if swimmingState and (not enabled or swimmingState.humanoid~=humanoid) then
            local state=swimmingState swimmingState=nil
            job("Water swimming")
            if state.humanoid.Parent then state.humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,state.enabled) end
        end
        if enabled and humanoid then
            if not swimmingState then
                swimmingState={humanoid=humanoid,enabled=humanoid:GetStateEnabled(Enum.HumanoidStateType.Swimming)}
                job("Water swimming",humanoid.StateChanged,function(_,newState)
                    if controls.waterEnabled and controls.waterSolid and newState==Enum.HumanoidStateType.Swimming then
                        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                    end
                end)
            end
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
            if humanoid:GetState()==Enum.HumanoidStateType.Swimming then humanoid:ChangeState(Enum.HumanoidStateType.Freefall) end
        end
    end
    local function restoreChunk(entry)
        -- Native snapshots preserve terrain that existed before conversion, including empty cells.
        Terrain:PasteRegion(entry.snapshot,entry.corner,true)
        entry.snapshot:Destroy()
    end
    local function restoreWater()
        waterGeneration=waterGeneration+1
        waterQueue={} waterQueueHead=1 waterWorker=false waterParts={}
        job("New water")
        job("Water swimming")
        if swimmingState then
            local state=swimmingState swimmingState=nil
            if state.humanoid.Parent then pcall(function() state.humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,state.enabled) end) end
        end
        -- Undo in reverse order so overlapping ocean tiles restore their original terrain.
        local failures=0
        for index=#waterRegions,1,-1 do
            if not pcall(restoreChunk,waterRegions[index]) then failures=failures+1 end
        end
        waterRegions={}
        unpatch("waterparts") unpatch("water") unpatch("noswim")
        if failures>0 then warn("Prime Visuals: could not restore "..failures.." water chunks") end
    end
    local function waterSettings()
        patch("water",Terrain,"WaterColor",controls.waterColor or Color3.fromRGB(35,135,190))
        patch("water",Terrain,"WaterWaveSize",controls.waterWaves or 0.15)
        patch("water",Terrain,"WaterWaveSpeed",controls.waterSpeed or 10)
        patch("water",Terrain,"WaterTransparency",controls.waterAlpha or 0.4)
        patch("water",Terrain,"WaterReflectance",controls.waterReflect or 0.5)
    end
    local function fillChunk(region,generation)
        if not alive or not controls.waterEnabled or generation~=waterGeneration then return false end
        local low=region.CFrame.Position-region.Size/2
        local high=region.CFrame.Position+region.Size/2
        local corner=Vector3int16.new(low.X/4,low.Y/4,low.Z/4)
        local last=Vector3int16.new(high.X/4-1,high.Y/4-1,high.Z/4-1)
        local snapshot=Terrain:CopyRegion(Region3int16.new(corner,last))
        table.insert(waterRegions,{snapshot=snapshot,corner=corner})
        Terrain:FillRegion(region,4,Enum.Material.Water)
        return true
    end
    local function convertWater(part,generation)
        if not part.Parent then return end
        -- Resonance geometry: the entire original volume, shifted down four studs.
        local offset=Vector3.new(0,-4,0)
        local bounds=Region3.new(part.Position-part.Size/2+offset,part.Position+part.Size/2+offset):ExpandToGrid(4)
        local low=bounds.CFrame.Position-bounds.Size/2
        local high=bounds.CFrame.Position+bounds.Size/2
        local sliceStarted=os.clock()
        for x=low.X,high.X-4,128 do
            for y=low.Y,high.Y-4,128 do
                for z=low.Z,high.Z-4,128 do
                    if not alive or generation~=waterGeneration or not controls.waterEnabled then return end
                    local region=Region3.new(Vector3.new(x,y,z),Vector3.new(math.min(x+128,high.X),math.min(y+128,high.Y),math.min(z+128,high.Z)))
                    if not fillChunk(region,generation) then return end
                    if os.clock()-sliceStarted>=0.004 then Run.Heartbeat:Wait() sliceStarted=os.clock() end
                end
            end
        end
    end
    local function startWaterWorker()
        if waterWorker or waterBatch or #waterQueue==0 then return end
        waterWorker=true
        local generation=waterGeneration
        task.spawn(function()
            while alive and generation==waterGeneration and controls.waterEnabled and waterQueueHead<=#waterQueue do
                local part=waterQueue[waterQueueHead]
                waterQueueHead=waterQueueHead+1
                local ok,message=pcall(convertWater,part,generation)
                if not ok then
                    if generation==waterGeneration and alive then
                        setters.waterEnabled(false,true)
                        notify("Realistic Water stopped: "..tostring(message))
                    end
                    return
                end
            end
            if generation==waterGeneration then waterWorker=false waterQueue={} waterQueueHead=1 end
        end)
    end
    local function queueWater(part)
        if not alive or not controls.waterEnabled or not isWaterPart(part) or waterParts[part] then return end
        waterParts[part]=true table.insert(waterQueue,part)
        patch("waterparts",part,"Transparency",1)
        startWaterWorker()
    end
    do
        local g=group("World","Water",1)
        toggle(g,"waterEnabled","Realistic Water",false,function(on)
            if not on then restoreWater() return end
            local root=oceanRoot()
            if not root then error("FTAP ocean is not loaded yet. Try again when the map is ready.") end
            waterSettings() updateSwimming()
            job("New water",Workspace.DescendantAdded,queueWater)
            waterBatch=true
            for _,part in ipairs(root:GetDescendants()) do queueWater(part) end
            waterBatch=false
            startWaterWorker()
        end)
        local function update() if controls.waterEnabled then waterSettings() end end
        color(g,"waterColor","Color",Color3.fromRGB(35,135,190),update)
        sliderControl(g,"waterWaves","Wave size",0,1,0.15,0.05,update)
        sliderControl(g,"waterSpeed","Wave speed",0,100,10,1,update)
        sliderControl(g,"waterAlpha","Transparency",0,1,0.4,0.05,update)
        sliderControl(g,"waterReflect","Reflectance",0,1,0.5,0.05,update)
        toggle(g,"waterSolid","Non-swimmable water",false,updateSwimming)
    end
    local function fpsObject(o)
        if not controls.fpsEnabled then return end
        if o:IsA("BasePart") then
            if controls.fpsMaterials then patch("fps",o,"Material",Enum.Material.SmoothPlastic) end
            if controls.fpsReflections then patch("fps",o,"Reflectance",0) end
            if controls.fpsShadows then patch("fps",o,"CastShadow",false) end
        elseif controls.fpsTextures and (o:IsA("Decal") or o:IsA("Texture")) then patch("fps",o,"Transparency",1)
        elseif controls.fpsTextures and o:IsA("SurfaceAppearance") then
            -- SurfaceAppearance maps are content properties and may be protected by the engine.
            pcall(function() patch("fps",o,"ColorMap","") patch("fps",o,"NormalMap","") patch("fps",o,"MetalnessMap","") patch("fps",o,"RoughnessMap","") end)
        end
    end
    local function refreshFPS(on)
        job("New FPS objects") unpatch("fps")
        if not on then return end
        if controls.fpsShadows then patch("fps",Lighting,"GlobalShadows",false) end
        scan(Workspace,fpsObject)
        job("New FPS objects",Workspace.DescendantAdded,fpsObject)
    end
    do
        local g=group("World","Performance",2)
        toggle(g,"fpsEnabled","Boost FPS",false,refreshFPS)
        local function update() if controls.fpsEnabled then refreshFPS(true) end end
        toggle(g,"fpsMaterials","Simplify materials",true,update)
        toggle(g,"fpsTextures","Hide textures",true,update)
        toggle(g,"fpsReflections","Remove reflections",true,update)
        toggle(g,"fpsShadows","Remove shadows",true,update)
    end
    -- CHARACTER
    local hat,hatMesh
    local function characterTargets()
        local result={}
        if controls.characterBody and player.Character then table.insert(result,player.Character) end
        if controls.characterHat and hat then table.insert(result,hat) end
        for _,o in ipairs(Workspace:GetChildren()) do
            local name=string.lower(o.Name)
            if (controls.characterCoconuts and name:find("coconut",1,true)) or (controls.characterAntiKick and (name:find("antikick",1,true) or name:find("anti%-kick"))) then table.insert(result,o) end
        end
        return result
    end
    local function paintCharacter()
        unpatch("character")
        if not controls.characterEnabled then return end
        local tint=controls.characterRainbow and Color3.fromHSV((os.clock()*0.12)%1,0.8,1) or controls.characterColor or purple
        for _,root in ipairs(characterTargets()) do
            local parts=root:IsA("BasePart") and {root} or root:GetDescendants()
            for _,part in ipairs(parts) do if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
                patch("character",part,"Material",Enum.Material.ForceField) patch("character",part,"Color",tint)
            end end
        end
    end
    do
        local g=group("Character","Character finish",1)
        toggle(g,"characterEnabled","Forcefield highlight",false,function(on)
            paintCharacter() job("Character finish")
            if on then
                local elapsed=0
                job("Character finish",Run.Heartbeat,function(dt) elapsed=elapsed+dt if elapsed>0.15 then elapsed=0 paintCharacter() end end)
            end
        end)
        color(g,"characterColor","Color",purple,paintCharacter)
        toggle(g,"characterRainbow","Rainbow",false,paintCharacter)
        toggle(g,"characterBody","Affect character",true,paintCharacter)
        toggle(g,"characterCoconuts","Affect coconut forms",true,paintCharacter)
        toggle(g,"characterHat","Affect hat",true,paintCharacter)
        toggle(g,"characterAntiKick","Affect anti-kick objects",true,paintCharacter)
        local h=group("Character","Cone hat",2)
        local function updateHat(on)
            job("Cone hat")
            if not on then dispose(hat) hat=nil hatMesh=nil return end
            if not hat then
                hat=own(make("Part",{Name="PV_ConeHat",Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Massless=true,Size=Vector3.new(1,1,1),Material=Enum.Material.Neon,Color=purple,Transparency=0.15},Workspace))
                hatMesh=make("SpecialMesh",{MeshType=Enum.MeshType.FileMesh,MeshId="rbxassetid://1033714",Scale=Vector3.new(3,1.2,3)},hat)
            end
            job("Cone hat",Run.RenderStepped,function()
                local head=player.Character and player.Character:FindFirstChild("Head")
                if not head then hat.Transparency=1 return end
                hat.Transparency=controls.hatAlpha or 0.2
                hat.CFrame=CFrame.new(head.Position+Vector3.new(0,controls.hatHeight or 1.1,0))
                hat.Color=controls.hatRainbow and Color3.fromHSV((os.clock()*0.12)%1,0.8,1) or controls.hatColor or purple
                local size=controls.hatSize or 3 hatMesh.Scale=Vector3.new(size,1.2,size)
            end)
        end
        toggle(h,"hatEnabled","Cone hat",false,updateHat)
        color(h,"hatColor","Color",purple,function() end)
        toggle(h,"hatRainbow","Rainbow",false,function() end)
        sliderControl(h,"hatSize","Width",1,8,3,0.1,function() end)
        sliderControl(h,"hatHeight","Height offset",0,4,1.1,0.1,function() end)
        sliderControl(h,"hatAlpha","Transparency",0,1,0.2,0.05,function() end)
    end
    -- ESP: four independent categories, with event-based discovery and capped updates.
    local espRoot=own(make("Folder",{Name="PV_ESP"},Workspace))
    local categories={Players={},Server={},Sticky={},Blackholes={}}
    local espEntries={}
    local function defaultESP() return {rainbow=false,smooth=true,fill=purple,outline=white,fillAlpha=0.75,outlineAlpha=0.1,names=true,text=white,textOutline=black,textStroke=0,size=14,offset=3,font="Builder Sans",bold=false,thickness=0.03,nameDistance=0,highlight=true,icon=false} end
    for name in pairs(categories) do categories[name]=defaultESP() end
    local function nearestOwner(part)
        local best,distance,second=nil,math.huge,math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local d=(root.Position-part.Position).Magnitude
                if d<distance then second=distance best,distance=p,d elseif d<second then second=d end
            end
        end
        if distance<15 and second-distance>2 then return best end
    end
    local function removeESP(target)
        local entry=espEntries[target]
        if not entry then return end
        for _,o in pairs(entry.objects) do dispose(o) end
        espEntries[target]=nil
    end
    local function addESP(target,category,owner)
        if espEntries[target] or not target.Parent then return end
        local part=target:IsA("BasePart") and target or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart",true)
        if not part then return end
        local hi=own(make("Highlight",{Name="PV_Highlight",Adornee=target,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},espRoot))
        local bill=own(make("BillboardGui",{Name="PV_Name",Adornee=part,AlwaysOnTop=true,Size=UDim2.fromOffset(240,38),StudsOffsetWorldSpace=Vector3.new(0,3,0)},espRoot))
        local text=make("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,TextColor3=white,TextStrokeTransparency=0,Font=Enum.Font.BuilderSans,TextSize=14},bill)
        local entry={target=target,category=category,owner=owner,part=part,hi=hi,bill=bill,text=text,objects={hi,bill}}
        if category=="Server" or category=="Sticky" then
            local selection=own(make("SelectionBox",{Adornee=part,Color3=white,SurfaceTransparency=1,LineThickness=0.03},espRoot))
            entry.selection=selection table.insert(entry.objects,selection)
        end
        if category=="Server" then
            local proxy=own(make("Part",{Name="PV_ServerMarker",Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Transparency=1,Size=part.Size,CFrame=part.CFrame},espRoot))
            local fill=own(make("BoxHandleAdornment",{Adornee=proxy,Size=part.Size,Color3=purple,Transparency=0.75,AlwaysOnTop=true,ZIndex=4},espRoot))
            entry.proxy=proxy entry.boxFill=fill
            entry.bill.Adornee=proxy
            if entry.selection then entry.selection.Adornee=proxy end
            table.insert(entry.objects,proxy) table.insert(entry.objects,fill)
        end
        espEntries[target]=entry
    end
    local function espCandidate(o)
        if o:IsDescendantOf(espRoot) then return end
        if controls.espServer and o:IsA("BasePart") and o.Name=="PlayerCharacterLocationDetector" and o.Parent==Workspace then addESP(o,"Server",nearestOwner(o)) end
        if controls.espSticky and o:IsA("BasePart") and o.Name=="StickyPart" then addESP(o.Parent,"Sticky") end
        if controls.espBlackholes then
            if o.Name=="BlackHoleKick" or o.Name=="StayedBH" then addESP(o,"Blackholes")
            elseif o:IsA("BasePart") then
                local ancestor=o.Parent
                while ancestor and ancestor~=Workspace do
                    if ancestor.Name=="BlackHoleKick" or ancestor.Name=="StayedBH" then addESP(ancestor,"Blackholes") break end
                    ancestor=ancestor.Parent
                end
            end
        end
    end
    local function refreshESP()
        local enabled=controls.espPlayers or controls.espServer or controls.espSticky or controls.espBlackholes
        job("ESP world") job("ESP render") job("ESP smooth")
        local active={Players=controls.espPlayers,Server=controls.espServer,Sticky=controls.espSticky,Blackholes=controls.espBlackholes}
        for target,entry in pairs(espEntries) do if not active[entry.category] then removeESP(target) end end
        if not enabled then return end
        if controls.espPlayers then for _,p in ipairs(Players:GetPlayers()) do if p~=player and p.Character then addESP(p.Character,"Players",p) end end end
        scan(Workspace,espCandidate)
        job("ESP world",Workspace.DescendantAdded,espCandidate)
        job("ESP smooth",Run.RenderStepped,function(dt)
            for _,entry in pairs(espEntries) do
                if entry.proxy and entry.part.Parent then
                    local target=entry.part.CFrame
                    entry.proxy.CFrame=categories.Server.smooth and entry.proxy.CFrame:Lerp(target,1-math.exp(-18*dt)) or target
                    entry.proxy.Size=entry.part.Size
                end
            end
        end)
        local elapsed=0
        job("ESP render",Run.Heartbeat,function(dt)
            elapsed=elapsed+dt if elapsed<0.1 then return end elapsed=0
            for target,e in pairs(espEntries) do
                if not target.Parent or not e.part.Parent then removeESP(target)
                else
                    local cfg=categories[e.category]
                    local fillColor=cfg.rainbow and Color3.fromHSV((os.clock()*0.12)%1,0.8,1) or cfg.fill
                    local hi=e.hi hi.Enabled=cfg.highlight and not e.proxy hi.FillColor=fillColor hi.OutlineColor=cfg.outline hi.FillTransparency=cfg.fillAlpha hi.OutlineTransparency=cfg.outlineAlpha
                    e.bill.Enabled=cfg.names e.bill.StudsOffsetWorldSpace=Vector3.new(0,cfg.offset,0)
                    if e.category=="Server" then e.owner=nearestOwner(e.part) end
                    local title=e.owner and e.owner.DisplayName or e.category=="Sticky" and "Sticky" or e.category=="Blackholes" and "Blackhole" or "Server detector"
                    if cfg.icon then title="[+] "..title end
                    e.text.Text=title e.text.TextSize=cfg.size e.text.TextColor3=cfg.text e.text.TextStrokeColor3=cfg.textOutline e.text.TextStrokeTransparency=cfg.textStroke
                    local font=cfg.font=="Code" and Enum.Font.Code or cfg.font=="Roboto" and Enum.Font.Roboto or cfg.bold and Enum.Font.BuilderSansBold or Enum.Font.BuilderSans
                    e.text.Font=font
                    if e.owner and e.category=="Server" and e.owner.Character then
                        local root=e.owner.Character:FindFirstChild("HumanoidRootPart")
                        if root then e.bill.Enabled=cfg.names and (root.Position-e.part.Position).Magnitude>=cfg.nameDistance end
                    end
                    if e.boxFill then e.boxFill.Visible=cfg.highlight e.boxFill.Color3=fillColor e.boxFill.Transparency=cfg.fillAlpha e.boxFill.Size=e.part.Size end
                    if e.selection then e.selection.Visible=cfg.highlight e.selection.Color3=cfg.outline e.selection.Transparency=cfg.outlineAlpha e.selection.LineThickness=cfg.thickness end
                end
            end
        end)
    end
    local function watchPlayer(p)
        listen(p.CharacterAdded,function(character)
            task.delay(0.7,function() if alive and controls.espPlayers and p~=player and character.Parent then addESP(character,"Players",p) end end)
        end)
    end
    for _,p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
    listen(Players.PlayerAdded,watchPlayer)
    do
        local g=group("ESP","Visibility",1)
        for _,entry in ipairs({{"espPlayers","Players"},{"espServer","Server detectors"},{"espSticky","Stickies"},{"espBlackholes","Blackholes"}}) do toggle(g,entry[1],entry[2],false,refreshESP) end
        local function config(category,side)
            local cfg=categories[category]
            local g=group("ESP",category,side)
            if category=="Server" then toggle(g,"espServerSmooth","Smooth movement",true,function(v) cfg.smooth=v end) end
            toggle(g,"esp"..category.."Highlight","Highlight",true,function(v) cfg.highlight=v end)
            color(g,"esp"..category.."Fill","Fill",cfg.fill,function(v) cfg.fill=v end)
            toggle(g,"esp"..category.."Rainbow","Rainbow fill",false,function(v) cfg.rainbow=v end)
            color(g,"esp"..category.."Outline","Outline",cfg.outline,function(v) cfg.outline=v end)
            sliderControl(g,"esp"..category.."FillAlpha","Fill transparency",0,1,cfg.fillAlpha,0.05,function(v) cfg.fillAlpha=v end)
            sliderControl(g,"esp"..category.."OutlineAlpha","Outline transparency",0,1,cfg.outlineAlpha,0.05,function(v) cfg.outlineAlpha=v end)
            if category=="Server" or category=="Sticky" then sliderControl(g,"esp"..category.."Thickness","Outline thickness",0.01,0.2,0.03,0.01,function(v) cfg.thickness=v end) end
            toggle(g,"esp"..category.."Names","Name",true,function(v) cfg.names=v end)
            choice(g,"esp"..category.."Font","Font",{"Builder Sans","Code","Roboto"},"Builder Sans",function(v) cfg.font=v end)
            toggle(g,"esp"..category.."Bold","Bold",false,function(v) cfg.bold=v end)
            toggle(g,"esp"..category.."Icon","Name icon",false,function(v) cfg.icon=v end)
            color(g,"esp"..category.."Text","Text color",white,function(v) cfg.text=v end)
            color(g,"esp"..category.."TextOutline","Text outline",black,function(v) cfg.textOutline=v end)
            sliderControl(g,"esp"..category.."TextAlpha","Text outline transparency",0,1,0,0.05,function(v) cfg.textStroke=v end)
            sliderControl(g,"esp"..category.."Size","Text size",8,30,14,1,function(v) cfg.size=v end)
            sliderControl(g,"esp"..category.."Offset","Vertical offset",0,15,3,0.25,function(v) cfg.offset=v end)
            if category=="Server" then sliderControl(g,"espServerDistance","Show owner when apart",0,50,0,1,function(v) cfg.nameDistance=v end) end
        end
        config("Players",1) config("Server",2) config("Sticky",1) config("Blackholes",2)
    end
    -- TWEAKS: game-owned instances are edited locally and restored on disable.
    local crossGui=own(make("ScreenGui",{Name="PrimeVisualsCrosshair",IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=900,Enabled=false},playerGui))
    local crossImage=make("ImageLabel",{Name="Crosshair",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(28,28),Image="rbxassetid://9943168532",BackgroundTransparency=1},crossGui)
    local function crosshair(on)
        crossGui.Enabled=on and not menuOpen
        job("Crosshair screen") job("Crosshair enabled")
        if not on then unpatch("crosshair") return end
        crossImage.Image=imageId(controls.crossImage or "9943168532")
        crossImage.Size=UDim2.fromOffset(controls.crossSize or 28,controls.crossSize or 28)
        crossImage.ImageColor3=controls.crossColor or white
        local gameCross=playerGui:FindFirstChild("Crosshairs")
        if gameCross and gameCross:IsA("ScreenGui") then
            patch("crosshair",gameCross,"Enabled",false)
            job("Crosshair enabled",gameCross:GetPropertyChangedSignal("Enabled"),function()
                if controls.crossEnabled and gameCross.Enabled then patch("crosshair",gameCross,"Enabled",false) end
            end)
        end
        job("Crosshair screen",playerGui.ChildAdded,function(o)
            if controls.crossEnabled and o.Name=="Crosshairs" and o:IsA("ScreenGui") then patch("crosshair",o,"Enabled",false) end
        end)
    end
    local lineTextures={Laser="rbxassetid://8922958725",Chain="rbxassetid://81358145120405",["Chain 2"]="rbxassetid://132910145874066",
        ["Chain 3"]="rbxassetid://128466395060514",["Chain 4"]="rbxassetid://73368670987191",Pulse="rbxassetid://82163767314193",Rope="rbxassetid://78999022056924",
        Dots="rbxassetid://9169659357",Bubbles="rbxassetid://1249690853",Spring="rbxassetid://18837732116",Gamepass="rbxassetid://8933355899",Default="rbxassetid://8933346550"}
    local function applyLine()
        unpatch("line")
        if not controls.lineEnabled then return end
        local grab=Workspace:FindFirstChild("GrabParts")
        if not grab then return end
        for _,beam in ipairs(grab:GetDescendants()) do
            if beam:IsA("Beam") then
                patch("line",beam,"Texture",lineTextures[controls.lineTexture] or imageId(controls.lineImage))
                patch("line",beam,"Color",ColorSequence.new(controls.lineColor or white))
                patch("line",beam,"TextureSpeed",controls.lineSpeed or 1)
            end
        end
    end
    local grabbedInfo=own(make("ScreenGui",{Name="PrimeVisualsGrabInfo",ResetOnSpawn=false,Enabled=false,DisplayOrder=800},playerGui))
    local infoText=make("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,50),Size=UDim2.fromOffset(480,58),BackgroundTransparency=1,
        Text="",TextSize=14,Font=Enum.Font.BuilderSans,TextColor3=white,TextStrokeTransparency=0.25,TextWrapped=true},grabbedInfo)
    local function updateGrabInfo()
        if not controls.grabInfo then return end
        local grab=Workspace:FindFirstChild("GrabParts")
        if not grab then infoText.Text="" return end
        local part
        for _,beam in ipairs(grab:GetDescendants()) do if beam:IsA("Beam") and beam.Attachment1 then part=beam.Attachment1.Parent break end end
        if not part or not part:IsA("BasePart") then infoText.Text="" return end
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local distance=root and (root.Position-part.Position).Magnitude or 0
        infoText.Text=string.format("%s  |  %.1f studs  |  %.1f mass\n%s",part.Name,distance,part.AssemblyMass,part.Material.Name)
    end
    local bhClones={}
    local blackholes={}
    local function addBlackhole(o)
        if o.Name=="BlackHoleKick" or o.Name=="StayedBH" then blackholes[o]=true end
    end
    for _,o in ipairs(Workspace:GetChildren()) do addBlackhole(o) end
    job("Blackhole discovery",Workspace.ChildAdded,addBlackhole)
    local function updateBlackholes()
        for model in pairs(blackholes) do
            if not model.Parent then blackholes[model]=nil
            else
                local hole=model:FindFirstChild("Hole")
                if hole then
                    for _,o in ipairs(hole:GetDescendants()) do
                        if (o:IsA("ImageLabel") or o:IsA("ImageButton")) then
                            if controls.bhImageEnabled then
                                patch("blackhole",o,"Image",imageId(controls.bhImage or "9920612764"))
                                if o.Name=="Small" then patch("blackhole",o,"Visible",false) end
                            end
                            if controls.bhTintEnabled then patch("blackhole",o,"ImageColor3",controls.bhColor or white) end
                        elseif o:IsA("Sound") and controls.bhSoundEnabled then patch("bhsound",o,"SoundId",controls.bhSoundResolved or imageId(controls.bhSound or "1843529634")) end
                    end
                    if controls.bhImageEnabled and hole:IsA("BasePart") then patch("blackhole",hole,"Transparency",1) end
                    if controls.bhStay and model.Name=="BlackHoleKick" and not bhClones[model] then
                        local old=model.Archivable model.Archivable=true
                        local clone=model:Clone() model.Archivable=old
                        if clone then
                            clone.Name="PV_StayedBlackhole"
                            for _,o in ipairs(clone:GetDescendants()) do
                                if o:IsA("LuaSourceContainer") or o:IsA("Sound") then o:Destroy()
                                elseif o:IsA("BasePart") then o.Anchored=true o.CanCollide=false o.CanTouch=false o.CanQuery=false end
                            end
                            own(clone) bhClones[model]=clone
                            -- Visual-only clone; never replace or delete the game's original blackhole.
                            task.delay(4.5,function()
                                if alive and controls.bhStay and not clone.Parent then clone.Parent=Workspace blackholes[clone]=true end
                            end)
                        end
                    end
                end
            end
        end
    end
    local function blackholeLoop()
        job("Blackhole edits")
        unpatch("blackhole")
        unpatch("bhsound")
        if not controls.bhStay then for model,clone in pairs(bhClones) do dispose(clone) blackholes[clone]=nil bhClones[model]=nil end end
        if controls.bhImageEnabled or controls.bhTintEnabled or controls.bhSoundEnabled or controls.bhStay then
            local elapsed=0
            job("Blackhole edits",Run.Heartbeat,function(dt) elapsed=elapsed+dt if elapsed>=0.2 then elapsed=0 updateBlackholes() end end)
            updateBlackholes()
        end
    end
    do
        local g=group("Tweaks","Grab line",1)
        toggle(g,"lineEnabled","Custom line",false,function(on)
            job("Grab line") applyLine()
            if on then job("Grab line",Workspace.DescendantAdded,function(o) if o:IsA("Beam") and o.Name=="GrabBeam" then task.defer(function() if alive then applyLine() end end) end end) end
        end)
        choice(g,"lineTexture","Texture",{"Laser","Chain","Chain 2","Chain 3","Chain 4","Pulse","Rope","Dots","Bubbles","Spring","Gamepass","Default","Custom"},"Chain",applyLine)
        field(g,"lineImage","Custom image","8922958725",applyLine)
        color(g,"lineColor","Color",white,applyLine)
        sliderControl(g,"lineSpeed","Texture speed",-10,10,1,0.25,applyLine)
        toggle(g,"grabInfo","Grabbed object info",false,function(on)
            grabbedInfo.Enabled=on job("Grab info")
            if on then
                local elapsed=0
                job("Grab info",Run.Heartbeat,function(dt) elapsed=elapsed+dt if elapsed>0.15 then elapsed=0 updateGrabInfo() end end)
            end
        end)
        local h=group("Tweaks","Crosshair",2)
        toggle(h,"crossEnabled","Custom crosshair",false,crosshair)
        local function update() if controls.crossEnabled then crosshair(true) end end
        field(h,"crossImage","Image","9943168532",update)
        color(h,"crossColor","Color",white,update)
        sliderControl(h,"crossSize","Size",8,128,28,1,update)
        local b=group("Tweaks","Blackholes",1)
        toggle(b,"bhImageEnabled","Custom image",false,blackholeLoop)
        field(b,"bhImage","Image","9920612764",function() unpatch("blackhole") blackholeLoop() end)
        toggle(b,"bhTintEnabled","Custom color",false,blackholeLoop)
        color(b,"bhColor","Color",white,function() unpatch("blackhole") blackholeLoop() end)
        toggle(b,"bhStay","Keep visual blackholes",false,blackholeLoop)
    end
    -- AUDIO: category mutes and custom blackhole audio.
    local mutePredicates={
        Ambience=function(o)
            local map=Workspace:FindFirstChild("Map")
            local noises=map and map:FindFirstChild("MapNoises")
            return noises and o:IsDescendantOf(noises)
        end,
        Boomboxes=function(o) return o.Name~="SineWave" and o.Parent and o.Parent.Name=="Speaker" end,
        Screams=function(o) return o.Name=="Scream" and o.Parent and o.Parent.Name=="HumanoidRootPart" end,
        Explosions=function(o) return o.Parent and o.Parent:IsA("BasePart") and o.Parent.Name=="Part" and o.Parent.Parent==Workspace end,
        Soundwaves=function(o) return o.Name=="SineWave" end,
        Rhythm=function(o) return string.lower(o.Name):match("^sound[1-8]$")~=nil end,
        Instruments=function(o) return o.Parent and o.Parent.Name=="MusicPart" end
    }
    local mutedSounds={}
    local function muteSound(o)
        if not o:IsA("Sound") then return end
        local should=false
        for name,predicate in pairs(mutePredicates) do if controls["mute"..name] and predicate(o) then should=true break end end
        if should then
            patch("mutes",o,"Volume",0)
            if not mutedSounds[o] then
                mutedSounds[o]=o:GetPropertyChangedSignal("Volume"):Connect(function()
                    if alive and mutedSounds[o] and o.Volume~=0 then o.Volume=0 end
                end)
            end
        elseif mutedSounds[o] then mutedSounds[o]:Disconnect() mutedSounds[o]=nil end
    end
    local function refreshMutes()
        job("New audio")
        for o,c in pairs(mutedSounds) do c:Disconnect() mutedSounds[o]=nil end
        unpatch("mutes")
        local active=false for name in pairs(mutePredicates) do if controls["mute"..name] then active=true break end end
        if not active then return end
        scan(Workspace,muteSound)
        job("New audio",Workspace.DescendantAdded,muteSound)
    end
    local function resolveSound(value)
        if not tostring(value):match("^https?://") or tostring(value):find("roblox.com",1,true) then return imageId(value) end
        if type(request)~="function" or type(writefile)~="function" or type(getcustomasset)~="function" then error("This executor cannot load MP3 links; use a Roblox audio ID.") end
        local response=request({Url=value,Method="GET"})
        if not response or response.StatusCode~=200 or type(response.Body)~="string" then error("Audio download failed") end
        if #response.Body>15*1024*1024 then error("Audio file is larger than 15 MB") end
        local filename="PrimeVisuals_Blackhole.mp3"
        writefile(filename,response.Body)
        return getcustomasset(filename)
    end
    do
        local g=group("Audio","Mute categories",1)
        for _,entry in ipairs({{"Ambience","Ambience"},{"Boomboxes","Boomboxes / jukeboxes"},{"Screams","Screams"},{"Explosions","Explosions"},{"Soundwaves","Soundwaves"},{"Rhythm","Rhythm makers"},{"Instruments","Instruments"}}) do toggle(g,"mute"..entry[1],entry[2],false,refreshMutes) end
        local h=group("Audio","Blackhole sound",2)
        toggle(h,"bhSoundEnabled","Custom sound",false,function(on)
            if on then controls.bhSoundResolved=resolveSound(controls.bhSound or "1843529634") end
            blackholeLoop()
        end)
        field(h,"bhSound","Audio ID / MP3 link","1843529634",function(v)
            if controls.bhSoundEnabled then
                task.spawn(function()
                    local resolved
                    if safe(function() resolved=resolveSound(v) end) and alive and controls.bhSoundEnabled and controls.bhSound==v then
                        controls.bhSoundResolved=resolved unpatch("bhsound") blackholeLoop()
                    end
                end)
            end
        end)
    end
    -- Final category architecture: six clear sections with remembered subtabs.
    do
        local g=group("Settings","Interface",1)
        choice(g,"uiLanguage","Language",{"English","Русский"},"English",function(value)
            setLanguage(value=="Русский" and "ru" or "en")
        end)
        local resetting=false
        action(g,"Reset all settings",function()
            if resetting then return end
            resetting=true
            -- Reuse full teardown, then rebuild clean controls and effect state.
            gui:Destroy()
            task.defer(function() startVisuals(true) end)
        end)
        action(g,"Unload script",function()
            if resetting then return end
            resetting=true
            gui:Destroy()
        end)
    end

    -- HOME: profile, build information and live session statistics in native Obsidian cards.
    do
        local homeTab=categoryTabs.Home
        local profile=homeTab:AddLeftGroupbox("Profile","user-round")
        local avatar=profile:AddImage("homeAvatar",{
            Image=string.format("rbxthumb://type=AvatarBust&id=%d&w=180&h=180",player.UserId),
            Height=164,Color=Color3.new(1,1,1),Transparency=0,BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit
        })
        local greeting=profile:AddLabel({Text="",DoesWrap=true,Size=16})
        local identity=profile:AddLabel({Text="",DoesWrap=true})
        local about=homeTab:AddLeftGroupbox("About Prime Visuals","diamond")
        local statistics=homeTab:AddRightGroupbox("Session statistics","chart-no-axes-combined")
        local function richEscape(value)
            return tostring(value):gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"):gsub('"',"&quot;")
        end
        local function text(en,russian) return uiLanguage=="ru" and russian or en end
        local function setText(widget,value)
            if widget.Text~=value then widget:SetText(value) end
        end
        local staticText={}
        local function localizedLabel(g,en,russian,size)
            local widget=g:AddLabel({Text=en,DoesWrap=true,Size=size or 14})
            table.insert(staticText,{widget=widget,en=en,ru=russian})
            return widget
        end
        localizedLabel(about,"<b>Prime Visuals</b>  ·  v"..VERSION,"<b>Prime Visuals</b>  ·  v"..VERSION,15)
        localizedLabel(about,"Author: <b>@876osamuha</b>","Автор: <b>@876osamuha</b>")
        localizedLabel(about,"Visual customization for Fling Things and People.","Визуальная настройка Fling Things and People.")
        localizedLabel(about,"License status: no license-key system.","Статус лицензии: система ключей не используется.")
        localizedLabel(about,"View: confirmed by the user. Other sections: testing in progress.","Обзор: подтверждён пользователем. Остальные разделы: тестирование.")
        local rows={}
        for _,name in ipairs({"fps","frame","ping","memory","players","server","fov","effects","uptime","clock"}) do
            rows[name]=statistics:AddLabel({Text="—",DoesWrap=true})
        end
        local scroll=make("ScrollingFrame",{Name="PrimeHomeScroll",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
            BorderSizePixel=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollBarThickness=3,
            ScrollBarImageColor3=purple,ScrollingDirection=Enum.ScrollingDirection.Y},homeTab.Container)
        make("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
        make("UIPadding",{PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,7),PaddingBottom=UDim.new(0,8)},scroll)
        local top=make("Frame",{Name="HomeSummary",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1,LayoutOrder=0},scroll)
        local left=make("Frame",{Size=UDim2.new(0.5,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},top)
        local right=make("Frame",{Position=UDim2.new(0.5,5,0,0),Size=UDim2.new(0.5,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},top)
        for _,column in ipairs({left,right}) do make("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},column) end
        profile.BoxHolder.Parent=left profile.BoxHolder.LayoutOrder=0
        about.BoxHolder.Parent=left about.BoxHolder.LayoutOrder=1
        statistics.BoxHolder.Parent=right
        for _,side in ipairs(homeTab.Sides) do side.Visible=false end
        local statsService
        pcall(function() statsService=game:GetService("Stats") end)
        local masterEffects={"camThird","camNoclip","camBlur","camBody","lightEnabled","skyClouds","particleEnabled",
            "waterEnabled","fpsEnabled","characterEnabled","hatEnabled","espPlayers","espServer","espSticky","espBlackholes",
            "lineEnabled","grabInfo","crossEnabled","bhImageEnabled","bhTintEnabled","bhStay","bhSoundEnabled",
            "muteAmbience","muteBoomboxes","muteScreams","muteExplosions","muteSoundwaves","muteRhythm","muteInstruments"}
        local lastLanguage
        local averageFPS,averageFrame
        refreshHome=function()
            if not alive then return end
            if lastLanguage~=uiLanguage then
                for _,entry in ipairs(staticText) do setText(entry.widget,uiLanguage=="ru" and entry.ru or entry.en) end
                lastLanguage=uiLanguage
            end
            local hour=tonumber(os.date("%H")) or 12
            local greet=hour>=5 and hour<12 and text("Good morning","Доброе утро")
                or hour>=12 and hour<17 and text("Good afternoon","Добрый день")
                or hour>=17 and hour<22 and text("Good evening","Добрый вечер") or text("Good night","Доброй ночи")
            setText(greeting,greet..", <b>"..richEscape(player.DisplayName).."</b>")
            setText(identity,"@"..richEscape(player.Name))
            local function stat(key,en,russian,value) setText(rows[key],text(en,russian)..": <b>"..tostring(value).."</b>") end
            stat("fps","Average FPS","Средний FPS",averageFPS and string.format("%.0f",averageFPS) or "—")
            stat("frame","Frame time","Время кадра",averageFrame and string.format("%.1f ms",averageFrame) or "—")
            local ping,memory
            pcall(function()
                local value=statsService.Network.ServerStatsItem["Data Ping"]:GetValue()
                if type(value)=="number" and value==value then ping=value end
            end)
            pcall(function() memory=statsService:GetTotalMemoryUsageMb() end)
            stat("ping","Server ping","Пинг сервера",ping and string.format("%.0f ms",ping) or "—")
            stat("memory","Client memory","Память клиента",type(memory)=="number" and string.format("%.0f MB",memory) or "—")
            stat("players","Players","Игроки",string.format("%d / %s",#Players:GetPlayers(),tostring(Players.MaxPlayers or "—")))
            local private=type(game.PrivateServerId)=="string" and game.PrivateServerId~=""
            local server=private and ((game.PrivateServerOwnerId or 0)>0 and text("Private","Приватный") or text("Reserved","Выделенный")) or text("Public","Публичный")
            stat("server","Server","Сервер",server)
            local camera=Workspace.CurrentCamera
            stat("fov","Current FOV","Текущий FOV",camera and string.format("%.1f",camera.FieldOfView) or "—")
            local enabled=(customSkyLoaded and 1 or 0)+(fovChanged and 1 or 0)
            for _,key in ipairs(masterEffects) do if controls[key] then enabled=enabled+1 end end
            stat("effects","Enabled effects","Включено эффектов",enabled)
            local seconds=math.max(0,math.floor(os.clock()-sessionStarted))
            stat("uptime","Script uptime","Время работы",string.format("%02d:%02d:%02d",math.floor(seconds/3600),math.floor(seconds/60)%60,seconds%60))
            stat("clock","Local time","Местное время",os.date("%H:%M:%S"))
        end
        refreshHome()
        local frames,elapsed=0,0
        job("Home statistics",Run.RenderStepped,function(dt)
            if dt<=0 or dt~=dt or dt==math.huge then return end
            frames=frames+1 elapsed=elapsed+dt
            if elapsed>=1 then
                averageFPS=frames/elapsed averageFrame=1000*elapsed/frames
                frames,elapsed=0,0
                if Library.ActiveTab==homeTab then refreshHome() end
            end
        end)
        if type(Players.GetUserThumbnailAsync)=="function" then
            task.spawn(function()
                for attempt=1,4 do
                    if not alive or avatar.Destroyed then return end
                    local ok,url,ready=pcall(function()
                        return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.AvatarBust,Enum.ThumbnailSize.Size180x180)
                    end)
                    if not alive or avatar.Destroyed then return end
                    if ok and ready and type(url)=="string" and url~="" then avatar:SetImage(url) return end
                    task.wait(attempt*0.5)
                end
            end)
        end
    end

    -- One uniform halo color at a time, smoothly cycling through the full rainbow.
    do
        local main=nativeWindow.MainFrame
        local glow=own(make("Frame",{Name="PrimeRainbowGlow",BackgroundTransparency=1,BorderSizePixel=0,
            Active=false,Visible=false,ZIndex=math.max(0,main.ZIndex-1)},main.Parent))
        local nativeScale=main:FindFirstChildOfClass("UIScale")
        local glowScale=make("UIScale",{Scale=nativeScale and nativeScale.Scale or 1},glow)
        local glowStrokes={}
        local initialColor=Color3.fromHSV(0,0.78,1)
        local function ring(spread,thickness,transparency)
            local frame=make("Frame",{Name="GlowRing",Position=UDim2.fromOffset(-spread,-spread),
                Size=UDim2.new(1,spread*2,1,spread*2),BackgroundTransparency=1,BorderSizePixel=0,Active=false,ZIndex=glow.ZIndex},glow)
            make("UICorner",{CornerRadius=UDim.new(0,6+spread)},frame)
            local stroke=make("UIStroke",{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=initialColor,
                Thickness=thickness,Transparency=transparency},frame)
            table.insert(glowStrokes,stroke)
        end
        for index=14,1,-1 do
            local distance=index/14
            ring(1+index*1.15,2.3,0.56+0.425*distance^0.7)
        end
        ring(0.7,1.25,0.22)
        local function sync()
            if not alive or not glow.Parent then return end
            glow.Visible=Library.Toggled and main.Visible and main.Parent~=nil
            glow.Position=main.Position
            glow.Size=main.Size
            glow.AnchorPoint=main.AnchorPoint
            glow.Rotation=main.Rotation
            if nativeScale then glowScale.Scale=nativeScale.Scale end
        end
        for _,property in ipairs({"Position","Size","AnchorPoint","Rotation","Visible"}) do listen(main:GetPropertyChangedSignal(property),sync) end
        if nativeScale then listen(nativeScale:GetPropertyChangedSignal("Scale"),sync) end
        sync()
        local phase=0
        job("Rainbow window glow",Run.RenderStepped,function(dt)
            if not glow.Visible then return end
            phase=(phase+math.clamp(dt,0,0.1)/18)%1
            local color=Color3.fromHSV(phase,0.78,1)
            for _,stroke in ipairs(glowStrokes) do stroke.Color=color end
        end)
    end

    building=false
    -- Bind localization to the actual library UI; no duplicate custom control layer.
    for _,object in ipairs(Library.ScreenGui:GetDescendants()) do bindLocalization(object) end
    listen(Library.ScreenGui.DescendantAdded,bindLocalization)
    categoryTabs.Home:Show()
    -- Lightweight lifecycle handling. No scans run every frame.
    job("Crosshair visibility",Run.RenderStepped,function()
        menuOpen=Library.Toggled
        if controls.crossEnabled then crossGui.Enabled=not menuOpen end
        grabbedInfo.Enabled=controls.grabInfo and not menuOpen
    end)
    listen(player.CharacterAdded,function()
        task.delay(0.6,function()
            if not alive then return end
            if controls.camThird then updateThirdPerson(true) end
            if controls.characterEnabled then paintCharacter() end
            if controls.waterEnabled and controls.waterSolid then updateSwimming() end
        end)
    end)
    cleanupExtra=function()
        alive=false
        for _,c in pairs(jobs) do c:Disconnect() end jobs={}
        for _,c in pairs(mutedSounds) do c:Disconnect() end mutedSounds={}
        restoreWater()
        for o,properties in pairs(patches) do
            for property,entry in pairs(properties) do pcall(function() o[property]=entry.original end) end
        end
        patches={}
        for o in pairs(owned) do pcall(function() o:Destroy() end) end owned={}
    end
end
local function shutdown()
    if closing then return end
    closing=true
    cleanupExtra()
    restoreSky()
    pcall(function() RunService:UnbindFromRenderStep(Library.ShowCursorBinding) end)
    if not Library.Unloaded then
        Library:Toggle(false)
        Library:Unload()
    end
    for _,connection in ipairs(connections) do connection:Disconnect() end
    UIS.MouseBehavior,UIS.MouseIconEnabled=savedBehavior,savedIcon
    if fovChanged and Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=initialFOV end
end
gui.Destroying:Connect(shutdown)
Library:OnUnload(function() if not closing and gui.Parent then gui:Destroy() end end)
local startupLoading
local startupStarted=os.clock()
local startupDuration=math.random(3000,5000)/1000
if not skipIntro then
    startupLoading=Library:CreateLoading({
        Title="Prime Visuals",Icon="diamond",IconSize=UDim2.fromOffset(26,26),LoadingIcon="loader-circle",
        CurrentStep=0,TotalSteps=100,WindowWidth=420,ContentWidth=420,WindowHeight=240,
        ShowSidebar=false,AutoResizeHeight=false,AlwaysOnTop=true
    })
    startupLoading:SetMessage("Preparing Prime Visuals")
    startupLoading:SetDescription("by @876osamuha  ·  v"..VERSION)
end
local prepared,prepareError=xpcall(buildVisualSystems,debug.traceback)
if not prepared then
    gui:Destroy()
    error(prepareError,0)
end
if startupLoading then
    task.spawn(function()
        local lastStep=-1
        while not closing and gui.Parent and not startupLoading.Destroyed do
            local progress=math.clamp((os.clock()-startupStarted)/startupDuration,0,1)
            local step=math.floor(progress*progress*(3-2*progress)*100)
            if step~=lastStep then startupLoading:SetCurrentStep(step) lastStep=step end
            if progress>=1 then
                startupLoading:SetMessage("Ready")
                startupLoading:Destroy()
                menuOpen=true
                return
            end
            task.wait(0.04)
        end
    end)
else
    Library:Toggle(true)
    menuOpen=true
end
end
startVisuals()
