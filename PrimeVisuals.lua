-- Prime Visuals | Camera + Sky
local function startVisuals()
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
for _,name in ipairs({"PrimeVisuals","MengysVisual","FOVPanel"}) do
    local old=playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end
local connections,tweens={},{}
local cleanupExtra=function() end
local function listen(signal,fn)
    local c=signal:Connect(fn)
    table.insert(connections,c)
    return c
end
-- Live UI localization; internal feature identifiers always stay unchanged.
local uiLanguage="en"
local ru={
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
end

local function make(class,props,parent)
    local obj=Instance.new(class)
    for key,value in pairs(props) do obj[key]=value end
    obj.Parent=parent
    bindLocalization(obj)
    return obj
end
local function animate(obj,seconds,props)
    if tweens[obj] then tweens[obj]:Cancel() end
    local t=TweenService:Create(obj,TweenInfo.new(seconds,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props)
    tweens[obj]=t
    t:Play()
    return t
end
local purple=Color3.fromRGB(160,106,255)
local white=Color3.fromRGB(230,228,237)
local muted=Color3.fromRGB(132,128,145)
local border=Color3.fromRGB(38,36,44)
local black=Color3.fromRGB(9,9,11)
local surface=Color3.fromRGB(14,14,17)
local selectedSurface=Color3.fromRGB(31,23,44)
local gui=make("ScreenGui",{Name="PrimeVisuals",ResetOnSpawn=false,DisplayOrder=1000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
-- Resonance window defaults: 720x600 at 100%, clamped to viewport minus 64.
local viewport=Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
local maxWidth,maxHeight=math.max(1,viewport.X-64),math.max(1,viewport.Y-64)
local windowWidth=math.clamp(720,math.min(256,maxWidth),maxWidth)
local windowHeight=math.clamp(600,math.min(360,maxHeight),maxHeight)
local panel=make("CanvasGroup",{Size=UDim2.fromOffset(windowWidth,windowHeight),Position=UDim2.new(0.5,-windowWidth/2,0.5,-windowHeight/2),BackgroundColor3=black,BorderSizePixel=0,GroupTransparency=1},gui)
make("UIStroke",{Color=purple,Thickness=1,Transparency=0.45},panel)
local function label(parent,text,x,y,w,h,size,color)
    return make("TextLabel",{Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,TextColor3=color or white,Font=Enum.Font.BuilderSans,TextSize=size,TextXAlignment=Enum.TextXAlignment.Left},parent)
end
local function line(parent,x1,y1,x2,y2,color,width)
    local dx,dy=x2-x1,y2-y1
    return make("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset((x1+x2)/2,(y1+y2)/2),Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),width or 1.5),Rotation=math.deg(math.atan2(dy,dx)),BackgroundColor3=color,BorderSizePixel=0,Active=false},parent)
end
local function outline(object,color)
    return make("UIStroke",{Color=color or border,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},object)
end
local header=make("TextButton",{Size=UDim2.new(1,0,0,38),Text="",BackgroundTransparency=1,Modal=true,AutoButtonColor=false},panel)
local logo=make("Frame",{Position=UDim2.fromOffset(12,10),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1},header)
line(logo,9,0,17,7,purple)
line(logo,17,7,9,18,purple)
line(logo,9,18,1,7,purple)
line(logo,1,7,9,0,purple)
line(logo,1,7,17,7,purple,1)
line(logo,9,0,9,18,purple,1)
local brand=label(header,"View",54,1,235,22,15)
brand.Font=Enum.Font.BuilderSansBold
local subtitle=label(header,"Camera",54,22,235,12,10,muted)
local heading=label(header,"Prime Visuals",0,9,112,22,12,muted)
heading.AnchorPoint=Vector2.new(1,0)
heading.Position=UDim2.new(1,-14,0,10)
heading.TextXAlignment=Enum.TextXAlignment.Right
make("Frame",{Position=UDim2.fromOffset(0,38),Size=UDim2.new(1,0,0,1),BackgroundColor3=border,BorderSizePixel=0},panel)
local rail=make("ScrollingFrame",{Position=UDim2.fromOffset(0,39),Size=UDim2.new(0,46,1,-39),CanvasSize=UDim2.new(),ScrollBarThickness=0,BackgroundColor3=black,BorderSizePixel=0},panel)
make("Frame",{Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=border,BorderSizePixel=0},rail)
local cameraBadge=make("TextButton",{Text="",AutoButtonColor=false,Position=UDim2.fromOffset(3,5),Size=UDim2.fromOffset(35,34),BackgroundColor3=black,BorderSizePixel=0},rail)
local cameraEdge=outline(cameraBadge,purple)
local cameraShape=make("Frame",{Position=UDim2.fromOffset(9,12),Size=UDim2.fromOffset(18,12),BackgroundTransparency=1},cameraBadge)
outline(cameraShape,purple)
make("Frame",{Position=UDim2.fromOffset(12,9),Size=UDim2.fromOffset(8,2),BackgroundColor3=purple,BorderSizePixel=0},cameraBadge)
local lens=make("Frame",{Position=UDim2.fromOffset(6,3),Size=UDim2.fromOffset(6,6),BackgroundTransparency=1},cameraShape)
outline(lens,purple)
local columnWidth=math.floor((windowWidth-82)/2)
local contentWidth=columnWidth*2+12
local function section(parent,x,width,height)
    local frame=make("Frame",{Position=UDim2.fromOffset(x,0),Size=UDim2.fromOffset(width,height),BackgroundColor3=surface,BorderSizePixel=0},parent)
    outline(frame)
    make("Frame",{Position=UDim2.fromOffset(0,29),Size=UDim2.new(1,0,0,1),BackgroundColor3=border,BorderSizePixel=0},frame)
    return frame
end
local cameraPage=make("ScrollingFrame",{Position=UDim2.fromOffset(58,88),Size=UDim2.fromOffset(contentWidth,170),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=purple,BorderSizePixel=0,BackgroundTransparency=1},panel)
local lensSection=section(cameraPage,0,columnWidth,128)
local lensTitle=label(lensSection,"Field of view",10,3,columnWidth-20,23,14)
lensTitle.Font=Enum.Font.BuilderSansMedium
local input=make("TextBox",{Position=UDim2.fromOffset(columnWidth-76,39),Size=UDim2.fromOffset(64,26),Text="70",ClearTextOnFocus=false,Font=Enum.Font.Code,TextSize=14,TextColor3=white,BackgroundColor3=black,BorderSizePixel=0},lensSection)
label(lensSection,"FOV",10,42,columnWidth-100,20,14,muted)
local inputStroke=outline(input)
listen(input.Focused,function() input.CursorPosition=#input.Text+1 input.SelectionStart=1 end)
listen(input.Focused,function() animate(inputStroke,0.12,{Color=purple}) end)
listen(input.FocusLost,function() animate(inputStroke,0.12,{Color=border}) end)
local slider=make("TextButton",{Position=UDim2.fromOffset(14,72),Size=UDim2.fromOffset(columnWidth-28,22),Text="",BackgroundTransparency=1,AutoButtonColor=false},lensSection)
local track=make("Frame",{Position=UDim2.new(0,0,0.5,-4),Size=UDim2.new(1,0,0,8),BackgroundColor3=black,BorderSizePixel=0},slider)
outline(track)
local fill=make("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=purple,BorderSizePixel=0},track)
local dot=make("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(6,14),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=white,BorderSizePixel=0},track)
local knobStroke=outline(dot,purple)
listen(slider.MouseEnter,function() animate(knobStroke,0.12,{Color=white}) end)
listen(slider.MouseLeave,function() animate(knobStroke,0.12,{Color=purple}) end)
label(lensSection,"30",10,99,64,20,12,muted)
local maxLabel=label(lensSection,"120",columnWidth-74,99,64,20,12,muted)
maxLabel.TextXAlignment=Enum.TextXAlignment.Right
-- Sky changes are opt-in. Original Sky instances are retained for an exact reset.
local originalSkies={}
for _,o in ipairs(Lighting:GetChildren()) do
    if o:IsA("Sky") then table.insert(originalSkies,o) end
end
local sourceSky=originalSkies[1]
local skyProperties={"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}
local activeSky
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
end
local skyBadge=make("TextButton",{Position=UDim2.fromOffset(3,44),Size=UDim2.fromOffset(35,34),Text="",AutoButtonColor=false,BackgroundColor3=black,BorderSizePixel=0},rail)
local skyEdge=outline(skyBadge,purple)
skyEdge.Transparency=1
local sunIcon=make("Frame",{Position=UDim2.fromOffset(14,13),Size=UDim2.fromOffset(8,8),BackgroundTransparency=1,Rotation=45},skyBadge)
outline(sunIcon,purple)
for i=0,7 do
    local angle=math.rad(i*45)
    line(skyBadge,18+math.cos(angle)*8,17+math.sin(angle)*8,18+math.cos(angle)*10.5,17+math.sin(angle)*10.5,purple,1.5)
end
local skyPage=make("ScrollingFrame",{Position=UDim2.fromOffset(58,88),Size=UDim2.fromOffset(contentWidth,190),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=purple,BorderSizePixel=0,Visible=false,BackgroundTransparency=1},panel)
local pages={Camera=cameraPage,Sky=skyPage}
local navEdges={Camera=cameraEdge,Sky=skyEdge}
local navButtons={Camera=cameraBadge,Sky=skyBadge}
local activeTab="Camera"
local function chooseTab(name)
    if activeTab==name then return end
    activeTab=name
    local focused=UIS:GetFocusedTextBox()
    if focused then focused:ReleaseFocus() end
    for id,page in pairs(pages) do page.Visible=id==name end
    heading.Text=name
    for id,edge in pairs(navEdges) do animate(edge,0.12,{Transparency=id==name and 0 or 1}) end
    local page=pages[name]
    page.Position=UDim2.fromOffset(58,92)
    animate(page,0.14,{Position=UDim2.fromOffset(58,88)})
end
listen(cameraBadge.Activated,function() chooseTab("Camera") end)
listen(skyBadge.Activated,function() chooseTab("Sky") end)
local function button(parent,text,x,y,width,callback)
    local b=make("TextButton",{Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(width,28),BackgroundColor3=black,BorderSizePixel=0,Font=Enum.Font.BuilderSansMedium,TextSize=14,TextColor3=white,AutoButtonColor=false},parent)
    local stroke=outline(b)
    listen(b.MouseEnter,function() animate(stroke,0.12,{Color=purple}) end)
    listen(b.MouseLeave,function() animate(stroke,0.12,{Color=border}) end)
    listen(b.InputBegan,function(event)
        if event.UserInputType==Enum.UserInputType.MouseButton1 then animate(stroke,0.08,{Color=white}) end
    end)
    listen(b.InputEnded,function(event)
        if event.UserInputType==Enum.UserInputType.MouseButton1 then animate(stroke,0.12,{Color=purple}) end
    end)
    listen(b.Activated,callback)
    return b
end
local customCard=section(skyPage,0,columnWidth,166)
local configCard=section(skyPage,columnWidth+12,columnWidth,128)
local skyTitle=label(customCard,"Skybox",10,3,columnWidth-20,23,14)
skyTitle.Font=Enum.Font.BuilderSansMedium
local configTitle=label(configCard,"Environment",10,3,columnWidth-20,23,14)
configTitle.Font=Enum.Font.BuilderSansMedium
local skyInput=make("TextBox",{Position=UDim2.fromOffset(10,39),Size=UDim2.fromOffset(columnWidth-20,28),Text="",PlaceholderText="Skybox link or ID",ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.BuilderSans,TextSize=14,TextColor3=white,PlaceholderColor3=muted,BackgroundColor3=black,BorderSizePixel=0},customCard)
make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},skyInput)
local skyInputStroke=outline(skyInput)
listen(skyInput.MouseEnter,function() if not skyInput:IsFocused() then animate(skyInputStroke,0.12,{Color=purple}) end end)
listen(skyInput.MouseLeave,function() if not skyInput:IsFocused() then animate(skyInputStroke,0.12,{Color=border}) end end)
listen(skyInput.Focused,function() animate(skyInputStroke,0.12,{Color=purple}) end)
listen(skyInput.FocusLost,function() animate(skyInputStroke,0.12,{Color=border}) end)
local skyMessage=label(customCard,"",10,111,columnWidth-20,46,12,Color3.fromRGB(255,142,163))
skyMessage.Visible=false
skyMessage.TextWrapped=true
skyMessage.TextYAlignment=Enum.TextYAlignment.Top
listen(skyInput:GetPropertyChangedSignal("Text"),function()
    skyMessage.Visible=false
end)
local loadButton
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
        end)
        if not ok then skyFeedback("Could not apply skybox. Try another asset.",true) warn("Prime Visuals Sky: " .. tostring(err)) return end
        skyFeedback("Skybox loaded / six separate textures.",false)
    end)
end
loadButton=button(customCard,"Load",10,76,columnWidth-20,applyCustomSky)
listen(skyInput.FocusLost,function(enterPressed) if enterPressed then applyCustomSky() end end)
local hazeButton=make("TextButton",{Position=UDim2.fromOffset(10,39),Size=UDim2.fromOffset(columnWidth-20,28),Text="",BackgroundTransparency=1,AutoButtonColor=false},configCard)
local hazeCheck=make("Frame",{Position=UDim2.fromOffset(1,7),Size=UDim2.fromOffset(14,14),BackgroundColor3=black,BorderSizePixel=0},hazeButton)
local hazeStroke=outline(hazeCheck)
label(hazeButton,"Remove haze",25,2,columnWidth-55,24,14)
local function updateHazeText()
    animate(hazeCheck,0.12,{BackgroundColor3=hazeEnabled and purple or black})
    animate(hazeStroke,0.12,{Color=hazeEnabled and purple or border})
end
listen(hazeButton.Activated,function()
    clearHaze(not hazeEnabled)
    updateHazeText()
end)
button(configCard,"Reset sky",10,85,columnWidth-20,function()
    restoreSky()
    updateHazeText()
    skyInput.Text=""
    skyMessage.Text=""
    skyMessage.Visible=false
    loadButton.Text="Load"
end)
local initialFOV=Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70
local selected=math.clamp(math.round(initialFOV),30,120)
local fovChanged=false
local function apply()
    if fovChanged and Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=selected end
end
local function setValue(value,displayOnly)
    if not value or value~=value or math.abs(value)==math.huge then value=selected end
    selected=math.clamp(math.round(value),30,120)
    input.Text=tostring(selected)
    local a=(selected-30)/90
    fill.Size=UDim2.new(a,0,1,0)
    dot.Position=UDim2.new(a,0,0.5,0)
    if not displayOnly then fovChanged=true apply() end
end
listen(input.FocusLost,function() setValue(tonumber(input.Text)) end)
listen(Workspace:GetPropertyChangedSignal("CurrentCamera"),apply)

-- Standalone menu cursor: the same 11x11 cross layout used by Resonance.
-- No game GUI scanning or reparenting.
local cursorLayer=make("ScreenGui",{
    Name="PrimeVisualsMenuCursor",IgnoreGuiInset=true,ResetOnSpawn=false,
    DisplayOrder=1001,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Enabled=false
},playerGui)
local cursor=make("Frame",{
    AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(11,11),
    BackgroundTransparency=1,Active=false
},cursorLayer)
local function crossPart(width,height,color,z)
    make("Frame",{
        AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.fromOffset(width,height),BackgroundColor3=color,
        BorderSizePixel=0,ZIndex=z,Active=false
    },cursor)
end
crossPart(11,3,Color3.new(0,0,0),1)
crossPart(3,11,Color3.new(0,0,0),1)
crossPart(9,1,Color3.new(1,1,1),2)
crossPart(1,9,Color3.new(1,1,1),2)
local savedBehavior,savedIcon=UIS.MouseBehavior,UIS.MouseIconEnabled
local menuOpen=false
local generation=0
local dragging,sliding=false,false
local dragStart,startPosition,activeTouch
local function setMenu(open)
    generation=generation+1
    local currentGeneration=generation
    local focused=UIS:GetFocusedTextBox()
    if focused then focused:ReleaseFocus() end
    dragging,sliding,activeTouch=false,false,nil
    if open then
        if not menuOpen then savedBehavior,savedIcon=UIS.MouseBehavior,UIS.MouseIconEnabled end
        menuOpen=true
        panel.Visible=true
        header.Modal=true
        UIS.MouseBehavior=Enum.MouseBehavior.Default
        UIS.MouseIconEnabled=false
        cursorLayer.Enabled=true
        local mouse=UIS:GetMouseLocation()
        cursor.Position=UDim2.fromOffset(mouse.X,mouse.Y)
        animate(panel,0.23,{GroupTransparency=0})
    else
        menuOpen=false
        header.Modal=false
        cursorLayer.Enabled=false
        UIS.MouseBehavior,UIS.MouseIconEnabled=savedBehavior,savedIcon
        local t=animate(panel,0.16,{GroupTransparency=1})
        t.Completed:Once(function(state)
            if generation==currentGeneration and not menuOpen and state==Enum.PlaybackState.Completed then panel.Visible=false end
        end)
    end
end

local function pointerStart(event)
    return event.UserInputType==Enum.UserInputType.MouseButton1 or event.UserInputType==Enum.UserInputType.Touch
end
local function slide(x)
    setValue(30+math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)*90)
end
listen(slider.InputBegan,function(event)
    if pointerStart(event) then
        sliding=true
        activeTouch=event.UserInputType==Enum.UserInputType.Touch and event or nil
        slide(event.Position.X)
    end
end)
listen(header.InputBegan,function(event)
    if pointerStart(event) then
        dragging=true
        dragStart,startPosition=event.Position,panel.Position
        activeTouch=event.UserInputType==Enum.UserInputType.Touch and event or nil
    end
end)
listen(UIS.InputChanged,function(event)
    if event.UserInputType~=Enum.UserInputType.MouseMovement and event~=activeTouch then return end
    if sliding then slide(event.Position.X) end
    if dragging then
        local delta=event.Position-dragStart
        local bounds=gui.AbsoluteSize
        local x=startPosition.X.Scale*bounds.X+startPosition.X.Offset+delta.X
        local y=startPosition.Y.Scale*bounds.Y+startPosition.Y.Offset+delta.Y
        panel.Position=UDim2.fromOffset(math.clamp(x,0,math.max(0,bounds.X-panel.AbsoluteSize.X)),math.clamp(y,0,math.max(0,bounds.Y-panel.AbsoluteSize.Y)))
    end
end)
listen(UIS.WindowFocusReleased,function() dragging,sliding,activeTouch=false,false,nil end)
listen(UIS.InputEnded,function(event)
    if event.UserInputType==Enum.UserInputType.MouseButton1 or event==activeTouch then dragging,sliding,activeTouch=false,false,nil end
end)
listen(UIS.InputBegan,function(event)
    if event.KeyCode==Enum.KeyCode.RightShift then setMenu(not menuOpen) end
end)
RunService:BindToRenderStep("PrimeVisualsCursor",Enum.RenderPriority.Last.Value,function(dt)
    if not menuOpen then return end
    UIS.MouseBehavior=Enum.MouseBehavior.Default
    UIS.MouseIconEnabled=false
    local mouse=UIS:GetMouseLocation()
    cursor.Position=UDim2.fromOffset(mouse.X,mouse.Y)
end)
gui.Destroying:Connect(function()
    cleanupExtra()
    restoreSky()
    RunService:UnbindFromRenderStep("PrimeVisualsCursor")
    for _,c in ipairs(connections) do c:Disconnect() end
    for _,t in pairs(tweens) do t:Cancel() end
    cursorLayer:Destroy()
    UIS.MouseBehavior,UIS.MouseIconEnabled=savedBehavior,savedIcon
    if fovChanged and Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=initialFOV end
end)
-- Prime Visuals independent visual systems.
local function buildVisualSystems()
    local player=Players.LocalPlayer
    local Run=RunService
    local Terrain=Workspace.Terrain
    local SoundService=game:GetService("SoundService")
    local jobs,owned,patches={}, {}, {}
    local alive=true
    local setters={}
    local controls={}
    local function notify(text)
        local note=gui:FindFirstChild("VisualNotice")
        if note then note:Destroy() end
        note=make("TextLabel",{Name="VisualNotice",Text=tostring(text),TextWrapped=true,TextSize=13,Font=Enum.Font.BuilderSans,
            BackgroundColor3=black,TextColor3=white,BorderSizePixel=0,Position=UDim2.new(0.5,-220,1,-68),Size=UDim2.fromOffset(440,48),ZIndex=900},gui)
        outline(note,purple)
        task.delay(6,function() if note.Parent then note:Destroy() end end)
    end
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
    local registry={}
    local allGroups={}
    local function scrollPage(page)
        page.Size=UDim2.new(1,-70,1,-101)
    end
    scrollPage(cameraPage) scrollPage(skyPage)
    local glyphs={
        Lighting={{9,1,9,5},{9,13,9,17},{1,9,5,9},{13,9,17,9},{4,4,6,6},{12,12,14,14},{4,14,6,12},{12,6,14,4}},
        Particles={{9,0,9,18},{0,9,18,9},{3,3,15,15},{3,15,15,3}},
        World={{1,4,17,4},{1,9,17,9},{1,14,17,14},{4,1,4,17},{14,1,14,17}},
        Character={{7,1,11,1},{11,1,11,5},{11,5,7,5},{7,5,7,1},{9,6,9,12},{2,8,16,8},{9,12,4,18},{9,12,14,18}},
        ESP={{0,9,5,4},{5,4,13,4},{13,4,18,9},{18,9,13,14},{13,14,5,14},{5,14,0,9},{7,7,11,7},{11,7,11,11},{11,11,7,11},{7,11,7,7}},
        Tweaks={{1,4,17,4},{1,9,17,9},{1,14,17,14},{5,1,5,7},{13,6,13,12},{7,11,7,17}},
        Audio={{1,7,4,7},{4,7,9,2},{9,2,9,16},{9,16,4,11},{4,11,1,11},{1,11,1,7},{12,5,15,8},{15,8,15,10},{15,10,12,13}}
    }
    glyphs.Settings={{6,1,12,1},{12,1,12,4},{12,4,15,6},{15,6,18,6},{18,6,18,12},{18,12,15,12},{15,12,12,15},{12,15,12,18},{12,18,6,18},{6,18,6,15},{6,15,3,12},{3,12,0,12},{0,12,0,6},{0,6,3,6},{3,6,6,3},{6,3,6,1},{7,7,11,7},{11,7,11,11},{11,11,7,11},{7,11,7,7}}
    local order={"Camera","Sky","Lighting","Particles","World","Character","ESP","Tweaks","Audio","Settings"}
    for index,name in ipairs(order) do
        if not pages[name] then
            local page=make("ScrollingFrame",{Position=UDim2.fromOffset(58,88),Size=UDim2.new(1,-70,1,-101),BackgroundTransparency=1,BorderSizePixel=0,
                CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=purple,Visible=false},panel)
            pages[name]=page
            local b=make("TextButton",{Position=UDim2.fromOffset(3,5+(index-1)*39),Size=UDim2.fromOffset(35,34),Text="",BackgroundColor3=black,BorderSizePixel=0,AutoButtonColor=false},rail)
            local edge=outline(b,purple) edge.Transparency=1
            navEdges[name]=edge
            navButtons[name]=b
            local icon=make("Frame",{Position=UDim2.fromOffset(9,8),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1},b)
            for _,segment in ipairs(glyphs[name]) do line(icon,segment[1],segment[2],segment[3],segment[4],purple,1.3) end
            listen(b.Activated,function() chooseTab(name) end)
            listen(b.MouseEnter,function() if activeTab~=name then animate(edge,0.12,{Transparency=0.55}) end end)
            listen(b.MouseLeave,function() if activeTab~=name then animate(edge,0.12,{Transparency=1}) end end)
        end
        registry[name]={page=pages[name],left=name=="Camera" and 140 or name=="Sky" and 178 or 0,right=name=="Sky" and 140 or 0}
    end
    local function group(tab,title,side)
        local r=registry[tab]
        local sideKey=side==2 and "right" or "left"
        local frame=section(r.page,side==2 and columnWidth+12 or 0,columnWidth,38)
        frame.Position=UDim2.fromOffset(side==2 and columnWidth+12 or 0,r[sideKey])
        local titleLabel=label(frame,title,10,3,columnWidth-20,23,14)
        titleLabel.Font=Enum.Font.BuilderSansMedium
        local g={frame=frame,y=37,r=r,key=sideKey,origin=r[sideKey],tab=tab,title=title,side=side==2 and 2 or 1}
        table.insert(allGroups,g)
        r[sideKey]=r[sideKey]+50
        return g
    end
    local function row(g,height)
        local y=g.y g.y=y+height
        g.frame.Size=UDim2.fromOffset(columnWidth,g.y+7)
        g.r[g.key]=math.max(g.r[g.key],g.origin+g.y+19)
        return y
    end
    local function put(key,value) controls[key]=value end
    local function toggle(g,key,text,default,callback)
        local y=row(g,29)
        local b=make("TextButton",{Position=UDim2.fromOffset(9,y),Size=UDim2.fromOffset(columnWidth-18,24),Text="",BackgroundTransparency=1,AutoButtonColor=false},g.frame)
        local square=make("Frame",{Position=UDim2.fromOffset(1,5),Size=UDim2.fromOffset(13,13),BackgroundColor3=black,BorderSizePixel=0},b)
        make("UICorner",{CornerRadius=UDim.new(1,0)},square)
        local edge=outline(square)
        label(b,text,24,0,columnWidth-48,24,14)
        local current=default
        local function set(v,apply)
            local previous=current
            current=v==true put(key,current)
            animate(square,0.12,{BackgroundColor3=current and purple or black})
            animate(edge,0.12,{Color=current and purple or border})
            if apply and not safe(callback,current) then
                current=previous put(key,current)
                animate(square,0.12,{BackgroundColor3=current and purple or black})
                animate(edge,0.12,{Color=current and purple or border})
                pcall(callback,current)
            end
        end
        listen(b.Activated,function() set(not current,true) end)
        set(default,false) setters[key]=set
        return set
    end
    local draggingControl
    local draggingPage
    local function releaseControl()
        draggingControl=nil
        if draggingPage then draggingPage.ScrollingEnabled=true draggingPage=nil end
    end
    local function sliderControl(g,key,text,low,high,initial,step,callback)
        local y=row(g,52)
        label(g.frame,text,10,y,columnWidth-92,22,13)
        local f=make("TextBox",{Position=UDim2.fromOffset(columnWidth-74,y),Size=UDim2.fromOffset(64,22),Text="",Font=Enum.Font.Code,TextSize=13,
            ClearTextOnFocus=false,TextColor3=white,BackgroundColor3=black,BorderSizePixel=0},g.frame)
        local edge=outline(f)
        local hit=make("TextButton",{Position=UDim2.fromOffset(14,y+25),Size=UDim2.fromOffset(columnWidth-28,21),Text="",BackgroundTransparency=1,AutoButtonColor=false},g.frame)
        local bar=make("Frame",{Position=UDim2.new(0,0,0.5,-3),Size=UDim2.new(1,0,0,6),BackgroundColor3=border,BorderSizePixel=0},hit)
        outline(bar)
        local fill=make("Frame",{Size=UDim2.new(),BackgroundColor3=purple,BorderSizePixel=0},bar)
        local knob=make("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.fromOffset(3,8),BackgroundColor3=white,BorderSizePixel=0},bar)
        local value=initial
        local function set(v,apply)
            if not v or v~=v or math.abs(v)==math.huge then v=value end
            value=math.clamp(math.round(v/step)*step,low,high) value=math.round(value*1000)/1000
            put(key,value) f.Text=tostring(value)
            local alpha=(value-low)/(high-low)
            fill.Size=UDim2.new(alpha,0,1,0) knob.Position=UDim2.new(alpha,0,0.5,0)
            if apply then safe(callback,value) end
        end
        listen(f.Focused,function() animate(edge,0.12,{Color=purple}) end)
        listen(f.FocusLost,function() animate(edge,0.12,{Color=border}) set(tonumber(f.Text),true) end)
        listen(hit.InputBegan,function(event)
            if event.UserInputType==Enum.UserInputType.MouseButton1 or event.UserInputType==Enum.UserInputType.Touch then
                draggingPage=g.r.page draggingPage.ScrollingEnabled=false
                draggingControl=function(x) set(low+math.clamp((x-bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X),0,1)*(high-low),true) end
                draggingControl(event.Position.X)
            end
        end)
        set(initial,false) setters[key]=set return set
    end
    listen(UIS.InputChanged,function(event)
        if draggingControl and (event.UserInputType==Enum.UserInputType.MouseMovement or event.UserInputType==Enum.UserInputType.Touch) then draggingControl(event.Position.X) end
    end)
    listen(UIS.InputEnded,function(event) if event.UserInputType==Enum.UserInputType.MouseButton1 or event.UserInputType==Enum.UserInputType.Touch then releaseControl() end end)
    listen(UIS.WindowFocusReleased,releaseControl)
    listen(panel:GetPropertyChangedSignal("Visible"),function() if not panel.Visible then releaseControl() end end)
    local function field(g,key,text,initial,callback)
        local y=row(g,54)
        label(g.frame,text,10,y,columnWidth-20,21,13)
        local f=make("TextBox",{Position=UDim2.fromOffset(10,y+23),Size=UDim2.fromOffset(columnWidth-20,24),Text=tostring(initial or ""),PlaceholderText="ID or link",
            ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.BuilderSans,TextSize=13,TextColor3=white,PlaceholderColor3=muted,BackgroundColor3=black,BorderSizePixel=0},g.frame)
        make("UIPadding",{PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,5)},f)
        local edge=outline(f)
        local function set(v,apply) put(key,v) f.Text=tostring(v or "") if apply then safe(callback,v) end end
        listen(f.Focused,function() animate(edge,0.12,{Color=purple}) end)
        listen(f.FocusLost,function() animate(edge,0.12,{Color=border}) set(f.Text,true) end)
        set(initial,false) setters[key]=set return set
    end
    local function choice(g,key,text,values,initial,callback)
        local y=row(g,49)
        label(g.frame,text,10,y,columnWidth-20,21,13)
        local b=make("TextButton",{Position=UDim2.fromOffset(10,y+22),Size=UDim2.fromOffset(columnWidth-20,22),Text="",Font=Enum.Font.BuilderSans,TextSize=13,
            TextColor3=white,BackgroundColor3=black,BorderSizePixel=0,AutoButtonColor=false},g.frame)
        local edge=outline(b)
        local current=initial
        local function set(v,apply) current=v put(key,v) b.Text=tostring(v).."  >" if apply then safe(callback,v) end end
        listen(b.Activated,function()
            local index=table.find(values,current) or 0
            set(values[index%#values+1],true)
        end)
        listen(b.MouseEnter,function() animate(edge,0.12,{Color=purple}) end)
        listen(b.MouseLeave,function() animate(edge,0.12,{Color=border}) end)
        set(initial,false) setters[key]=set return set
    end
    local function action(g,text,fn)
        local y=row(g,33) return button(g.frame,text,10,y,columnWidth-20,function() safe(fn) end)
    end
    -- Shared RGB picker, opened only while editing a color.
    local picker=make("Frame",{Size=UDim2.fromOffset(225,146),BackgroundColor3=black,BorderSizePixel=0,Visible=false,ZIndex=800},gui)
    outline(picker,purple)
    local pickFields={}
    local pickSet,pickColor
    label(picker,"Color",10,3,180,22,14).ZIndex=801
    local closePicker=make("TextButton",{Text="x",Position=UDim2.fromOffset(197,3),Size=UDim2.fromOffset(22,22),BackgroundTransparency=1,TextColor3=white,TextSize=14,ZIndex=801},picker)
    listen(closePicker.Activated,function() picker.Visible=false end)
    for index,name in ipairs({"R","G","B"}) do
        label(picker,name,10,30+(index-1)*28,20,22,13).ZIndex=801
        local f=make("TextBox",{Position=UDim2.fromOffset(38,30+(index-1)*28),Size=UDim2.fromOffset(172,22),Text="",Font=Enum.Font.Code,TextSize=13,ClearTextOnFocus=false,
            BackgroundColor3=black,TextColor3=white,BorderSizePixel=0,ZIndex=801},picker)
        outline(f) pickFields[index]=f
        listen(f.FocusLost,function()
            local rgb={pickColor.R*255,pickColor.G*255,pickColor.B*255}
            rgb[index]=math.clamp(tonumber(f.Text) or rgb[index],0,255)
            pickColor=Color3.fromRGB(rgb[1],rgb[2],rgb[3])
            for i,input in ipairs(pickFields) do input.Text=tostring(math.round(rgb[i])) end
            if pickSet then pickSet(pickColor,true) end
        end)
    end
    local function color(g,key,text,initial,callback)
        local y=row(g,29)
        label(g.frame,text,10,y,columnWidth-92,24,13)
        local swatch=make("TextButton",{Position=UDim2.fromOffset(columnWidth-72,y+3),Size=UDim2.fromOffset(62,19),Text="",BackgroundColor3=initial,BorderSizePixel=0,AutoButtonColor=false},g.frame)
        outline(swatch)
        local current=initial
        local function set(v,apply) current=v put(key,v) swatch.BackgroundColor3=v if apply then safe(callback,v) end end
        listen(swatch.Activated,function()
            pickSet,pickColor=set,current
            local pos=swatch.AbsolutePosition-gui.AbsolutePosition
            local bounds=gui.AbsoluteSize
            picker.Position=UDim2.fromOffset(math.clamp(pos.X-160,0,math.max(0,bounds.X-225)),math.clamp(pos.Y+24,0,math.max(0,bounds.Y-146)))
            for i,v in ipairs({current.R,current.G,current.B}) do pickFields[i].Text=tostring(math.round(v*255)) end
            picker.Visible=true
        end)
        set(initial,false) setters[key]=set return set
    end
    local oldChoose=chooseTab
    chooseTab=function(name) releaseControl() picker.Visible=false oldChoose(name) end
    listen(UIS.InputBegan,function(event) if event.KeyCode==Enum.KeyCode.RightShift then picker.Visible=false releaseControl() end end)
    local function resetPrefix(prefix)
        for key,state in pairs(controls) do
            if key:sub(1,#prefix)==prefix and type(state)=="boolean" and state and setters[key] then setters[key](false,true) end
        end
    end
    -- CAMERA
    local cameraSettings={mode=player.CameraMode,min=player.CameraMinZoomDistance,max=player.CameraMaxZoomDistance,occlusion=player.DevCameraOcclusionMode}
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
        local noClipCamera
        toggle(g,"camNoclip","Camera noclip",false,function(on)
            noClipCamera=nil
            job("Camera noclip")
            if not on then return end
            local camera=Workspace.CurrentCamera
            noClipCamera=camera
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
        sliderControl(g,"skyTime","Time of day",0,24,originalClock,0.1,function(v) patch("skytime",Lighting,"ClockTime",v) end)
        sliderControl(g,"skySun","Sun size",0,60,sourceSky and sourceSky.SunAngularSize or 21,0.5,function(v) ensureSky().SunAngularSize=v end)
        action(g,"Reset time and sun",function()
            unpatch("skytime") setters.skyTime(originalClock,false)
            local value=sourceSky and sourceSky.SunAngularSize or 21
            setters.skySun(value,false) if activeSky then activeSky.SunAngularSize=value end
        end)
        local h=group("Sky","Clouds",2)
        local cloud
        local function updateClouds(on)
            if not on then unpatch("clouds") if cloud and owned[cloud] then dispose(cloud) end cloud=nil return end
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
    -- WORLD: terrain water and reversible scene simplification.
    local waterRegions={}
    local waterGeneration=0
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
    local function isWaterPart(o)
        if not o:IsA("BasePart") or o:IsA("Terrain") then return false end
        if string.find(string.lower(o.Name),"water",1,true) then return true end
        -- FTAP stores its visible ocean inside Map/AlwaysHereTweenedObjects/Ocean.
        local ancestor=o.Parent
        while ancestor and ancestor~=Workspace do
            if ancestor.Name=="Ocean" then return o.Transparency<1 end
            ancestor=ancestor.Parent
        end
        return false
    end
    local swimmingState
    local function updateSwimming()
        local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        local enabled=controls.waterEnabled and controls.waterSolid
        if swimmingState and (not enabled or swimmingState.humanoid~=humanoid) then
            local state=swimmingState swimmingState=nil
            if state.humanoid.Parent then state.humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,state.enabled) end
        end
        if enabled and humanoid then
            if not swimmingState then swimmingState={humanoid=humanoid,enabled=humanoid:GetStateEnabled(Enum.HumanoidStateType.Swimming)} end
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
            if humanoid:GetState()==Enum.HumanoidStateType.Swimming then humanoid:ChangeState(Enum.HumanoidStateType.Freefall) end
        end
    end
    local function restoreWater()
        waterGeneration=waterGeneration+1
        if swimmingState then
            local state=swimmingState swimmingState=nil
            if state.humanoid.Parent then pcall(function() state.humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,state.enabled) end) end
        end
        job("New water")
        unpatch("water") unpatch("noswim")
        for index=#waterRegions,1,-1 do
            local entry=waterRegions[index]
            pcall(function() Terrain:WriteVoxels(entry.region,4,entry.materials,entry.occupancy) end)
        end
        waterRegions={}
    end
    local function waterSettings()
        patch("water",Terrain,"WaterColor",controls.waterColor or Color3.fromRGB(35,135,190))
        patch("water",Terrain,"WaterWaveSize",controls.waterWaves or 0.15)
        patch("water",Terrain,"WaterWaveSpeed",controls.waterSpeed or 10)
        patch("water",Terrain,"WaterTransparency",controls.waterAlpha or 0.4)
        patch("water",Terrain,"WaterReflectance",controls.waterReflect or 0.5)
    end
    local function convertWater(o)
        if not controls.waterEnabled or not isWaterPart(o) or o:GetAttribute("PrimeVisualsWater") then return end
        for _,entry in ipairs(waterRegions) do if entry.part==o then return end end
        local half=o.Size/2
        local region=Region3.new(o.Position-half-Vector3.new(4,4,4),o.Position+half+Vector3.new(4,4,4)):ExpandToGrid(4)
        local cells=region.Size.X*region.Size.Y*region.Size.Z/64
        if cells>1500000 then notify("Water region is too large for safe conversion; terrain water settings still apply.") return end
        local generation=waterGeneration
        local materials,occupancy=Terrain:ReadVoxels(region,4)
        if not alive or not controls.waterEnabled or generation~=waterGeneration then return end
        table.insert(waterRegions,{region=region,materials=materials,occupancy=occupancy,part=o})
        Terrain:FillBlock(o.CFrame,o.Size,Enum.Material.Water)
        patch("water",o,"Transparency",1)
        patch("water",o,"CanCollide",controls.waterSolid==true)
    end
    do
        local g=group("World","Water",1)
        toggle(g,"waterEnabled","Terrain water",false,function(on)
            if not on then restoreWater() return end
            waterSettings()
            updateSwimming()
            scan(Workspace,convertWater)
            job("New water",Workspace.DescendantAdded,convertWater)
        end)
        local function update() if controls.waterEnabled then waterSettings() end end
        color(g,"waterColor","Color",Color3.fromRGB(35,135,190),update)
        sliderControl(g,"waterWaves","Wave size",0,1,0.15,0.05,update)
        sliderControl(g,"waterSpeed","Wave speed",0,100,10,1,update)
        sliderControl(g,"waterAlpha","Transparency",0,1,0.4,0.05,update)
        sliderControl(g,"waterReflect","Reflectance",0,1,0.5,0.05,update)
        toggle(g,"waterSolid","Non-swimmable surface",false,function(on)
            updateSwimming()
            for _,entry in ipairs(waterRegions) do if entry.part.Parent then patch("water",entry.part,"CanCollide",on) end end
        end)
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
            task.defer(startVisuals)
        end)
        action(g,"Unload script",function()
            if resetting then return end
            resetting=true
            gui:Destroy()
        end)
    end
    local categories={
        {id="View",label="View",tabs={"Camera","Sky"},icon={{1,5,17,5},{17,5,17,16},{17,16,1,16},{1,16,1,5},{5,5,6,2},{6,2,12,2},{12,2,13,5},{6,8,12,8},{12,8,12,13},{12,13,6,13},{6,13,6,8}}},
        {id="Graphics",label="Graphics",tabs={"Lighting","Particles","World"},icon=glyphs.Lighting},
        {id="Character",label="Character",tabs={"Character"},icon=glyphs.Character},
        {id="ESP",label="ESP",tabs={"ESP"},icon=glyphs.ESP},
        {id="FTAP",label="FTAP",tabs={"Tweaks","Audio"},icon=glyphs.Tweaks},
        {id="Settings",label="Settings",tabs={"Settings"},icon=glyphs.Settings}
    }
    for _,b in pairs(navButtons) do b.Visible=false end
    local subbar=make("Frame",{Position=UDim2.fromOffset(58,49),Size=UDim2.fromOffset(contentWidth,28),BackgroundTransparency=1},panel)
    local tabOwners,categoryButtons,subButtons={},{},{}
    local remembered={}
    local currentCategory="View"
    local underlyingChoose=chooseTab
    local selectCategory
    local tooltip=make("Frame",{Visible=false,Size=UDim2.fromOffset(114,29),BackgroundColor3=selectedSurface,BorderSizePixel=0,ZIndex=850},panel)
    outline(tooltip,purple)
    local tooltipText=label(tooltip,"",10,2,96,25,13)
    tooltipText.ZIndex=851
    local function hideTooltip() tooltip.Visible=false end
    listen(panel:GetPropertyChangedSignal("Visible"),hideTooltip)
    for index,category in ipairs(categories) do
        for _,tab in ipairs(category.tabs) do tabOwners[tab]=category end
        local y=category.id=="Settings" and windowHeight-39-47 or 7+(index-1)*43
        local b=make("TextButton",{Name="Nav"..category.id,Position=UDim2.fromOffset(5,y),Size=UDim2.fromOffset(35,36),Text="",AutoButtonColor=false,BackgroundColor3=black,BorderSizePixel=0},rail)
        local edge=outline(b,purple)
        edge.Transparency=1
        local indicator=make("Frame",{Position=UDim2.fromOffset(-5,9),Size=UDim2.fromOffset(2,18),BackgroundColor3=purple,BorderSizePixel=0,Visible=false},b)
        local icon=make("Frame",{Position=UDim2.fromOffset(8,9),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1},b)
        local strokes={}
        for _,segment in ipairs(category.icon) do
            table.insert(strokes,line(icon,segment[1],segment[2],segment[3],segment[4],muted,1.6))
        end
        categoryButtons[category.id]={button=b,edge=edge,indicator=indicator,strokes=strokes}
        listen(b.Activated,function() hideTooltip() selectCategory(category.id) end)
        listen(b.MouseEnter,function()
            tooltipText.Text=category.label
            tooltip.Position=UDim2.fromOffset(52,math.clamp(39+y+3,40,windowHeight-35))
            tooltip.Visible=true
            if currentCategory~=category.id then animate(b,0.12,{BackgroundColor3=surface}) end
            for _,stroke in ipairs(strokes) do animate(stroke,0.12,{BackgroundColor3=purple}) end
        end)
        listen(b.MouseLeave,function()
            hideTooltip()
            local selected=currentCategory==category.id
            animate(b,0.12,{BackgroundColor3=selected and selectedSurface or black})
            for _,stroke in ipairs(strokes) do animate(stroke,0.12,{BackgroundColor3=selected and purple or muted}) end
        end)
    end
    -- Reuse three subtab buttons rather than allocating a new UI on every switch.
    for index=1,3 do
        local entry={}
        local b=make("TextButton",{Size=UDim2.fromOffset(140,27),Text="",Font=Enum.Font.BuilderSansMedium,TextSize=14,BackgroundColor3=black,TextColor3=muted,BorderSizePixel=0,AutoButtonColor=false},subbar)
        entry.button=b entry.edge=outline(b,border)
        subButtons[index]=entry
        listen(b.Activated,function() if entry.name then chooseTab(entry.name) end end)
        listen(b.MouseEnter,function() animate(entry.edge,0.12,{Color=purple}) end)
        listen(b.MouseLeave,function() animate(entry.edge,0.12,{Color=entry.name==activeTab and purple or border}) end)
    end
    local function updateSubbar(category,selected)
        local width=math.min(155,math.floor((contentWidth-(#category.tabs-1)*8)/#category.tabs))
        for index,entry in ipairs(subButtons) do
            local name=category.tabs[index]
            entry.name=name
            entry.button.Visible=name~=nil
            if name then
                entry.button.Position=UDim2.fromOffset((index-1)*(width+8),0)
                entry.button.Size=UDim2.fromOffset(width,27)
                entry.button.Text=name
                entry.button.TextColor3=name==selected and white or muted
                entry.button.BackgroundColor3=name==selected and selectedSurface or surface
                entry.edge.Color=name==selected and purple or border
            end
        end
    end
    chooseTab=function(name)
        local category=tabOwners[name]
        if not category then return end
        remembered[category.id]=name
        currentCategory=category.id
        releaseControl() picker.Visible=false
        underlyingChoose(name)
        hideTooltip()
        for id,entry in pairs(categoryButtons) do
            local selected=id==category.id
            entry.indicator.Visible=selected
            entry.edge.Transparency=selected and 0.65 or 1
            animate(entry.button,0.12,{BackgroundColor3=selected and selectedSurface or black})
            for _,stroke in ipairs(entry.strokes) do animate(stroke,0.12,{BackgroundColor3=selected and purple or muted}) end
        end
        updateSubbar(category,name)
        brand.Text=category.label
        subtitle.Text=name
        heading.Text="Prime Visuals"
        local page=pages[name]
        page.Position=UDim2.fromOffset(58,88)
        page.Size=UDim2.new(1,-70,1,-101)
    end
    selectCategory=function(id)
        for _,category in ipairs(categories) do
            if category.id==id then chooseTab(remembered[id] or category.tabs[1]) return end
        end
    end
    rail.CanvasSize=UDim2.new()
    -- Fold advanced groups and reflow both columns, instead of stacking every control onscreen.
    local function reflowGroups()
        for tab,r in pairs(registry) do
            local left=tab=="Camera" and lensSection.Size.Y.Offset+12 or tab=="Sky" and customCard.Size.Y.Offset+12 or 0
            local right=tab=="Sky" and configCard.Size.Y.Offset+12 or 0
            for _,g in ipairs(allGroups) do
                if g.tab==tab then
                    local y=g.side==2 and right or left
                    g.frame.Position=UDim2.fromOffset(g.side==2 and columnWidth+12 or 0,y)
                    local height=g.collapsed and 29 or g.y+7
                    g.frame.Size=UDim2.fromOffset(columnWidth,height)
                    if g.side==2 then right=y+height+12 else left=y+height+12 end
                end
            end
        end
    end
    for _,g in ipairs(allGroups) do
        local title
        for _,child in ipairs(g.frame:GetChildren()) do
            if child:IsA("TextLabel") and child.Position.Y.Offset==3 then title=child break end
        end
        if title then title.Size=UDim2.fromOffset(columnWidth-42,23) end
        local arrow=label(g.frame,"-",columnWidth-26,2,18,24,16,purple)
        arrow.TextXAlignment=Enum.TextXAlignment.Center
        local fold=make("TextButton",{Size=UDim2.new(1,0,0,29),Text="",BackgroundTransparency=1,AutoButtonColor=false},g.frame)
        local visibility={}
        local function foldGroup(collapsed)
            g.collapsed=collapsed
            arrow.Text=collapsed and "+" or "-"
            for _,child in ipairs(g.frame:GetChildren()) do
                if child:IsA("GuiObject") and child~=fold and child~=arrow and child.Position.Y.Offset>=29 then
                    if collapsed then visibility[child]=child.Visible child.Visible=false
                    elseif visibility[child]~=nil then child.Visible=visibility[child] end
                end
            end
            reflowGroups()
        end
        listen(fold.Activated,function() foldGroup(not g.collapsed) end)
        if (g.tab=="ESP" and g.title~="Visibility") or g.title=="Emission" or g.title=="Post-processing" then foldGroup(true) end
    end
    reflowGroups()
    selectCategory("View")

    -- Lightweight lifecycle handling. No scans run every frame.
    local elapsed=0
    job("Crosshair visibility",Run.RenderStepped,function()
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
        releaseControl()
        for _,c in pairs(jobs) do c:Disconnect() end jobs={}
        for _,c in pairs(mutedSounds) do c:Disconnect() end mutedSounds={}
        restoreWater()
        for o,properties in pairs(patches) do
            for property,entry in pairs(properties) do pcall(function() o[property]=entry.original end) end
        end
        patches={}
        for o in pairs(owned) do pcall(function() o:Destroy() end) end owned={}
        picker:Destroy()
    end
end
buildVisualSystems()

setValue(selected,true)
setMenu(true)
end
startVisuals()
