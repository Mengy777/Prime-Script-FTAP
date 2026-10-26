-- Prime Visuals | FTAP visual customization
local VERSION="2.1.8"
local vortexLaunching=false
local lastProfileBeforeLoad
local sessionStarted=os.clock()
local sourceCache={}
local function loadUIModule(name,state)
    local filename=name=="Library" and "Obsidian" or name
    local chunk,source,message
    for attempt=1,3 do
        if state and not state.Alive then error("Prime Visuals module load cancelled",0) end
        source=sourceCache[name]
        if not source then
            local url="https://raw.githubusercontent.com/Mengy777/Prime-Script-FTAP/refs/tags/v"..VERSION.."/lib/"..filename..".lua"
            if attempt>1 then url=url.."?retry="..attempt end
            local ok,result=pcall(game.HttpGet,game,url)
            if ok and type(result)=="string" and result:find("%S") then source=result else message=tostring(result) end
        end
        if source then
            local compiled,result,detail=pcall(loadstring,source,"PrimeVisuals/"..filename)
            if compiled then chunk,message=result,detail else chunk,message=nil,result end
        end
        if chunk then break end
        sourceCache[name]=nil
        if attempt<3 then task.wait(0.35*attempt) end
    end
    if not chunk then error("Prime Visuals module "..filename.." unavailable after 3 attempts: "..tostring(message),0) end
    if state and not state.Alive then error("Prime Visuals module load cancelled",0) end
    local ok,result=pcall(chunk,function(child) return loadUIModule(child,state) end,
        function(library) if state then state.Library=library end end)
    if not ok then sourceCache[name]=nil error("Prime Visuals module "..filename.." failed: "..tostring(result),0) end
    sourceCache[name]=source
    return result
end
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
local function startVisuals(profileOverride)
local startup={Alive=true}
local requireModule=loadUIModule
local function run()
local function loadUIModule(name) return requireModule(name,startup) end
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
local profileChanged=function() end
local flushProfile=function() end
local discardAutosave=false
startup.Connections=connections
startup.CleanupEffects=function() cleanupExtra() end
startup.SuppressSave=function() discardAutosave=true end
startup.Input=UIS startup.MouseBehavior=UIS.MouseBehavior startup.MouseIconEnabled=UIS.MouseIconEnabled
startup.Environment=(getgenv and getgenv()) or shared or _G
local function listen(signal,fn)
    local c=signal:Connect(fn)
    table.insert(connections,c)
    return c
end
-- Live UI localization; internal feature identifiers always stay unchanged.
local uiLanguage="en"
local refreshHome=function() end
local ru={
    ["Nothing found"]="Ничего не найдено",
    ["Weather"]="Погода",
    ["Water & FPS"]="Вода и FPS",
    ["Appearance"]="Оформление",
    ["Movement"]="Движение",
    ["General"]="Основное",
    ["Profiles"]="Конфиги",
    ["Camera tools"]="Инструменты камеры",
    ["Custom skybox"]="Своё небо",
    ["Sun and clouds"]="Солнце и облака",
    ["Sky collection"]="Коллекция неба",
    ["Body style"]="Оформление тела",
    ["Accessories"]="Аксессуары",
    ["Movement effects"]="Эффекты движения",
    ["Player highlight"]="Подсветка игроков",
    ["Player overlays"]="Рамки и скелеты",
    ["World markers"]="Метки объектов",
    ["Item highlights"]="Подсветка предметов",
    ["Player tracker"]="Поиск игрока",
    ["Position history"]="История позиции",
    ["Blackhole animation"]="Анимация чёрной дыры",
    ["Mute sounds"]="Отключение звуков",
    ["Blackhole audio"]="Звук чёрной дыры",
    ["Saved profiles"]="Сохранённые конфиги",
    ["Share profiles"]="Обмен конфигами",
    ["Session details"]="Подробнее о сессии",
    ["Third-person camera"]="Камера от третьего лица",
    ["Camera through walls"]="Камера сквозь стены",
    ["Clear ragdoll blur"]="Убрать размытие при рагдолле",
    ["First-person body"]="Тело от первого лица",
    ["Manual lighting"]="Свои настройки света",
    ["Lighting preset"]="Готовое освещение",
    ["Forcefield material"]="Материал ForceField",
    ["Own outline"]="Своя подсветка",
    ["Body colors"]="Цвета тела",
    ["Server markers"]="Метки позиций",
    ["My delayed position"]="Моя позиция с задержкой",
    ["Grab line style"]="Оформление линии",
    ["Line to player"]="Линия к игроку",
    ["Floating particles"]="Частицы вокруг камеры",
    ["Reveal hidden players"]="Показать скрытых игроков",
    ["Anti-kick items"]="Анти-кик предметы",
    ["Combat items"]="Боевые предметы",
    ["Enable this effect to edit its settings"]="Включи функцию, чтобы открыть её настройки",
    ["Follow your character from a distance. Rotate with RMB; change distance in settings."]="Камера следует за персонажем. ПКМ — поворот; дистанция меняется в настройках.",
    ["Let the camera pass through walls."]="Камера проходит сквозь стены.",
    ["Remove the game's ragdoll blur."]="Убирает игровое размытие при рагдолле.",
    ["Show your own body while playing in first person."]="Показывает своё тело при игре от первого лица.",
    ["Apply a ForceField material to your character and selected objects."]="Меняет материал тела и выбранных объектов на ForceField.",
    ["Draw an outline around your own character."]="Подсвечивает контур собственного персонажа.",
    ["Choose Pale Frost, Dreamy Night or Tokyowami in settings."]="Выбери Pale Frost, Dreamy Night или Tokyowami в настройках.",
    ["Adjust brightness, colors, bloom and blur yourself."]="Настрой яркость, цвет, свечение и размытие вручную.",
    ["Move only the camera. Your character stays in place. RMB looks around; WASD moves."]="Персонаж остаётся на месте, летает только камера. ПКМ — обзор, WASD — движение.",
    ["Watch another player's camera subject. Enter their username in settings."]="Наблюдение за другим игроком. Укажи его юзернейм в настройках.",
    ["Smooth camera movement without slowing down mouse rotation."]="Сглаживает перемещение камеры, сохраняя обычный поворот мышью.",
    ["An estimated delayed position from your own movement history and ping; not server telemetry."]="Оценка позиции по собственной истории движения с задержкой по пингу.",
    ["Draw a line to a player. Enter their username in settings."]="Рисует линию к игроку. Укажи его юзернейм в настройках.",
    ["Leave a colored trail behind your character."]="Оставляет цветной след за персонажем.",
    ["Show an expanding ring on the ground when you jump."]="При прыжке на земле расходится кольцо.",
    ["Make dead characters dissolve into a local particle effect."]="Локальный эффект рассыпания персонажей в пыль при смерти.",
    ["Three layers of falling snow with adjustable wind."]="Три слоя падающего снега с настройкой ветра.",
    ["Surround the camera with decorative particles."]="Декоративные частицы вокруг камеры.",
    ["Highlight all players or choose specific players in settings."]="Подсвечивает всех или выбранных в настройках игроков.",
    ["Show the game's character location detectors."]="Показывает игровые детекторы позиции персонажей.",
    ["Highlight Shuriken, Kunai, Plate, Pickaxe and Pallet objects. This is not anti-kick protection."]="Подсвечивает Shuriken, Kunai, Plate, Pickaxe и Pallet.",
    ["Highlight selected toy types and show their item icons."]="Подсвечивает выбранные виды игрушек и показывает их иконки.",
    ["Choose an emote, dance or FTAP pose in settings. Asset availability depends on the game and rig."]="Выбери эмоцию, танец или позу FTAP. Доступность зависит от игры и типа тела.",
    ["Show a rotating, pulsing picture at a blackhole."]="Вращающаяся пульсирующая картинка на месте чёрной дыры.",

    ["Local position history"]="Локальная история позиции",
    ["Estimated server position"]="Оценка серверной позиции",
    ["Client history delayed by ping; an estimate, not server telemetry."]="История клиента с задержкой по пингу; оценка, не данные сервера.",
    ["Animations"]="Анимации",
    ["Custom animation"]="Своя анимация",
    ["Animation"]="Анимация",
    ["Animation speed"]="Скорость анимации",
    ["Stop animation"]="Остановить анимацию",

    ["Hide accessories"]="Скрывать аксессуары",
    ["Hide face"]="Скрывать лицо",
    ["Ocean appearance"]="Внешний вид океана",
    ["Ocean material and color"]="Материал и цвет океана",
    ["Body appearance"]="Внешний вид тела",
    ["Body colors and transparency"]="Цвета и прозрачность тела",
    ["Animated blackholes"]="Анимированные чёрные дыры",
    ["Animated blackhole image"]="Анимированное изображение дыры",
    ["Hide original visual"]="Скрывать исходный эффект",
    ["Hide at map origin"]="Скрывать у центра карты",
    ["Toggle key"]="Клавиша переключения",
    ["None"]="Нет",
    ["Shuriken"]="Сюрикен",
    ["Kunai"]="Кунай",
    ["Pickaxe"]="Кирка",
    ["Banana"]="Банан",
    ["Snowball"]="Снежок",
    ["WASD / Q E · RMB look · Shift / Ctrl · wheel speed"]="WASD / Q E · ПКМ: обзор · Shift / Ctrl · колесо: скорость",
    ["Head color"]="Голова: цвет",
    ["Head transparency"]="Голова: прозрачность",
    ["Torso color"]="Тело: цвет",
    ["Torso transparency"]="Тело: прозрачность",
    ["LeftArm color"]="Левая рука: цвет",
    ["LeftArm transparency"]="Левая рука: прозрачность",
    ["RightArm color"]="Правая рука: цвет",
    ["RightArm transparency"]="Правая рука: прозрачность",
    ["LeftLeg color"]="Левая нога: цвет",
    ["LeftLeg transparency"]="Левая нога: прозрачность",
    ["RightLeg color"]="Правая нога: цвет",
    ["RightLeg transparency"]="Правая нога: прозрачность",

    ["Movement visuals"]="Эффекты движения",
    ["Jump circle"]="Круг прыжка",
    ["Diameter"]="Диаметр",
    ["Lifetime"]="Время жизни",
    ["Character trail"]="След персонажа",
    ["Initial transparency"]="Начальная прозрачность",
    ["Gradient"]="Градиент",
    ["Gradient start"]="Начало градиента",
    ["Gradient end"]="Конец градиента",
    ["Death visuals"]="Эффекты смерти",
    ["Disintegration dust"]="Рассыпание в пыль",
    ["Snowfall"]="Снегопад",
    ["Layered snowfall"]="Многослойный снегопад",
    ["Wind"]="Ветер",
    ["Geometry"]="Геометрия",
    ["Box ESP"]="Рамки игроков",
    ["Skeleton ESP"]="Скелеты игроков",
    ["Maximum distance"]="Максимальная дистанция",
    ["Target trace"]="Трассировка игрока",
    ["Trace to player"]="Линия к игроку",
    ["Player username"]="Юзернейм игрока",
    ["Target marker"]="Метка игрока",
    ["Marker size"]="Размер метки",
    ["Marker image"]="Изображение метки",
    ["Self ESP"]="Своя подсветка",
    ["Self highlight"]="Подсветка себя",
    ["Object highlights"]="Подсветка предметов",
    ["Blobman / Gucci ESP"]="Подсветка Blobman / Gucci",
    ["Anti-kick objects ESP"]="Подсветка анти-кик предметов",
    ["Other players only"]="Только чужие предметы",
    ["Combat items ESP"]="Подсветка боевых предметов",
    ["Item names"]="Названия предметов",
    ["Icon size"]="Размер иконки",
    ["Reveal invisible characters"]="Показывать невидимых персонажей",
    ["Scene presets"]="Готовые сцены",
    ["Atmosphere preset"]="Готовая атмосфера",
    ["Preset"]="Вариант",
    ["Fullbright"]="Полное освещение",
    ["Skybox collection"]="Коллекция неба",
    ["Apply selected skybox"]="Применить выбранное небо",
    ["Cinematic camera"]="Кинематографичная камера",
    ["Smooth camera"]="Плавная камера",
    ["Smoothness"]="Плавность",
    ["Free camera"]="Свободная камера",
    ["Spectate player"]="Наблюдать за игроком",
    ["Show health"]="Показывать здоровье",
    ["Show distance"]="Показывать дистанцию",
    ["Name background"]="Фон имени",

    ["Enter a name of 1–160 bytes"]="Укажи короткое непустое название конфига.",
    ["This slot is empty or unreadable"]="Слот пуст или файл повреждён.",
    ["Unsupported config format"]="Этот формат конфигурации не поддерживается.",
    ["Config file is too large"]="Файл конфигурации больше 512 КиБ.",
    ["Invalid profile settings"]="В файле некорректные настройки.",
    ["Slider outside supported range"]="Значение параметра вне допустимого диапазона.",
    ["Unknown dropdown value"]="В конфиге есть недопустимый вариант настройки.",
    ["Use a JSON filename inside PrimeVisuals/Imports"]="Укажи только имя JSON-файла из PrimeVisuals/Imports.",
    ["Config write verification failed"]="Не удалось проверить запись конфигурации.",
    ["A write to this config is already in progress; try again"]="Конфиг ещё записывается. Повтори попытку.",
    ["Invalid color channel"]="В конфиге некорректный цвет.",
    ["Invalid toggle"]="В конфиге некорректное состояние переключателя.",
    ["Invalid sky texture"]="В конфиге некорректная текстура неба.",
    ["Window position outside supported range"]="В конфиге недопустимое положение меню.",
    ["Invalid profile flag"]="В конфиге некорректный служебный параметр.",

    ["Empty slot"]="Пустой слот",
    ["Undo last config load"]="Отменить загрузку конфига",
    ["Configurations"]="Конфиги",
    ["Slot"]="Слот",
    ["Config name"]="Название конфига",
    ["Save to slot"]="Сохранить в слот",
    ["Load slot"]="Загрузить слот",
    ["Delete slot"]="Удалить слот",
    ["Import / export"]="Импорт / экспорт",
    ["Copy folder path"]="Скопировать путь к папке",
    ["Export selected slot"]="Экспорт выбранного слота",
    ["Import filename"]="Имя файла для импорта",
    ["Import into selected slot"]="Импорт в выбранный слот",
    ["Put shared JSON files in PrimeVisuals/Imports"]="Файлы друга положи в PrimeVisuals/Imports",
    ["Autosave: ready"]="Автосохранение: готово",
    ["Autosave: saved"]="Автосохранение: сохранено",
    ["Autosave: error"]="Автосохранение: ошибка",
    ["Autosave: unavailable"]="Автосохранение: недоступно",

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
    ["Open Prime Vortex"]="Открыть Prime Vortex",
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
    ["Mannequins"]="Манекены",
    ["Local mannequins"]="Локальные манекены",
    ["Roblox username"]="Ник Roblox",
    ["Spawn mannequin"]="Создать манекена",
    ["Apply avatar to last"]="Применить скин к последнему",
    ["Reset last to grey"]="Сделать последнего серым",
    ["Delete last mannequin"]="Удалить последнего",
    ["Delete all mannequins"]="Удалить всех манекенов",
    ["Local grab"]="Локальный захват",
    ["Ragdoll physics"]="Физика ragdoll",
    ["Ragdoll sounds"]="Крики и звуки ударов",
    ["Empty username = grey mannequin"]="Пустой ник — серый манекен",
    ["LMB: grab/drop | RMB: throw"]="ЛКМ: взять/отпустить | ПКМ: бросить",
    ["Wheel: distance | Hold R: rotate"]="Колесо: дистанция | Удерживать R: вращение",
    ["Visibility"]="Отображение",
    ["All players"]="Все игроки",
    ["Selected players"]="Выбранные игроки",
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
if type(Library)=="table" then startup.Library=Library end
assert(type(Library)=="table" and type(Library.CreateWindow)=="function","Obsidian returned an invalid library")
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
    ShowCustomCursor=true,UnlockMouseWhileOpen=true,Font=Enum.Font.BuilderSans,CornerRadius=6,
    Animations={ToggleWindow=false,TabSwitch=true,Dropdown=true,Groupbox=true,KeyPicker=true},
    TabSwipeFrom="Auto",TabButtonsStyle={Gap=3,Padding=8,CornerRadius=6,Indicator=true,IndicatorWidth=2,IndicatorHeight=20}
})
local gui=make("ScreenGui",{Name="PrimeVisuals",ResetOnSpawn=false,Enabled=false},playerGui)
startup.Gui=gui
startup.Close=function() gui:Destroy() end
local menuOpen=false
local closing=false
local initialFOV=Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70
local selected=math.clamp(math.round(initialFOV),30,120)
local fovChanged=false
local originalCameraFOVs=setmetatable({},{__mode="k"})
startup.CameraFOVs=originalCameraFOVs
local function applyFOV()
    local camera=Workspace.CurrentCamera
    if fovChanged and camera then
        if originalCameraFOVs[camera]==nil then originalCameraFOVs[camera]=camera.FieldOfView end
        camera.FieldOfView=selected
    end
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
local skyRecoveryData
local customSkyLoaded=false
local beforeSkyChange=function() end
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
    beforeSkyChange()
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
    if not closing then beforeSkyChange() end
    skyLoadGeneration=skyLoadGeneration+1
    skyLoadBusy=false
    if hazeEnabled then clearHaze(false) end
    if activeSky then activeSky:Destroy() activeSky=nil end
    for _,o in ipairs(originalSkies) do
        if o.Parent==nil then o.Parent=Lighting end
    end
    customSkyLoaded=false
    skyRecoveryData=nil
    onSkyRestored()
    profileChanged()
end
startup.RestoreSky=restoreSky
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
local function rememberSky()
    if not activeSky or activeSky.Parent~=Lighting then return end
    if customSkyLoaded and skyRecoveryData then
        skyRecoveryData.SunAngularSize=activeSky.SunAngularSize
        skyRecoveryData.CelestialBodiesShown=activeSky.CelestialBodiesShown
    else
        skyRecoveryData={}
        for _,properties in ipairs({skyProperties,importedProperties}) do
            for _,key in ipairs(properties) do skyRecoveryData[key]=activeSky[key] end
        end
    end
end
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
            skyRecoveryData=nil
            for property,value in pairs(data) do sky[property]=value end
            customSkyLoaded=true
            onCustomSkyApplied(data)
            rememberSky()
        end)
        if not ok then skyFeedback("Could not apply skybox. Try another asset.",true) warn("Prime Visuals Sky: " .. tostring(err)) return end
        skyFeedback("Skybox loaded / six separate textures.",false)
        profileChanged()
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
    local settingSpecs,settingOrder,appliedSettings={},{},{}
    local restoringProfile=false
    local transientColorUpdate=false
    local profileStore,captureProfile,validateProfile
    local profileDirty,profileSaveScheduled=false,false
    local profileGeneration=0
    local featurePanels={}
    local maintenance={}
    local rememberedPlayers={}
    -- Install teardown before the first UI/effect is built, including partial startup failures.
    local clearLineSignals,restoreWater,mannequins,visualExpansion,navigation,clearThirdVisibility,antiKick
    local mutedSounds={}
    cleanupExtra=function()
        if not alive then return end
        alive=false
        local function attempt(label,fn)
            local ok,message=pcall(fn)
            if not ok then warn("Prime Visuals cleanup / "..label..": "..tostring(message)) end
        end
        for _,c in pairs(jobs) do attempt("job",function() c:Disconnect() end) end jobs={}
        if clearLineSignals then attempt("line",clearLineSignals) end
        if clearThirdVisibility then attempt("third-person visibility",clearThirdVisibility) end
        for _,c in pairs(mutedSounds) do attempt("audio",function() c:Disconnect() end) end mutedSounds={}
        if antiKick then attempt("anti-kick",function() antiKick:Destroy() end) end
        if mannequins then attempt("mannequins",function() mannequins:Destroy() end) end
        if visualExpansion then attempt("visual expansion",function() visualExpansion:Destroy() end) end
        if navigation then attempt("navigation",function() navigation:Destroy() end) end
        if restoreWater then attempt("water",restoreWater) end
        for o,properties in pairs(patches) do
            for property,entry in pairs(properties) do attempt("property",function() o[property]=entry.original end) end
        end
        patches={}
        for o in pairs(owned) do attempt("instance",function() o:Destroy() end) end owned={}
    end
    local function notify(text) if alive and not Library.Unloaded then Library:Notify(tostring(text),5) end end
    local function job(name,signal,fn)
        if jobs[name] then jobs[name]:Disconnect() jobs[name]=nil end
        if not signal or not fn then return end
        local blockedUntil,failures,lastNotice=0,0,-math.huge
        local connection
        local running=false
        connection=signal:Connect(function(...)
            if running or not alive or jobs[name]~=connection then return end
            local now=os.clock()
            if now<blockedUntil then return end
            running=true
            local ok,err=pcall(fn,...)
            running=false
            if ok then failures=0 blockedUntil=0 return end
            if not alive or jobs[name]~=connection then return end
            failures=failures+1
            blockedUntil=now+math.min(0.5*2^math.min(failures-1,4),8)
            if now-lastNotice>=30 then
                lastNotice=now
                warn("Prime Visuals / "..name..": "..tostring(err))
                notify(name..(uiLanguage=="ru" and ": временный сбой, будет повторная попытка." or ": temporary error; retrying automatically."))
            end
        end)
        jobs[name]=connection
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
    local function unpatch(feature,target)
        local function restore(o,properties)
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
        if target then
            if patches[target] then restore(target,patches[target]) end
        else for o,properties in pairs(patches) do restore(o,properties) end end
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
    profileChanged=function(key)
        if not alive or building or restoringProfile or transientColorUpdate then return end
        if discardAutosave and not key then return end
        if key then appliedSettings[key]=true discardAutosave=false end
        profileDirty=true
        profileGeneration=profileGeneration+1
        if not profileSaveScheduled then
            profileSaveScheduled=true
            task.delay(0.4,function()
                profileSaveScheduled=false
                if alive then flushProfile() end
            end)
        end
    end
    local function put(key,value) controls[key]=value end
    local function register(key,widget,initial,callback,isColor,spec)
        if not settingSpecs[key] then
            table.insert(settingOrder,key)
            settingSpecs[key]=spec or {Kind=isColor and "ColorPicker" or widget.Type}
            settingSpecs[key].Default=initial
        end
        local searchText=widget.Text or (widget.Info and widget.Info.Text) or ""
        widget.SearchAliases=widget.SearchAliases or key.." "..(ru[searchText] or "")
        put(key,initial) widgets[key]=widget
        local function set(value,apply)
            local previous=controls[key]
            local wasSuppressed=suppressed
            suppressed=true
            local updated,message=pcall(function()
                if isColor then widget:SetValueRGB(value) else widget:SetValue(value) end
            end)
            suppressed=wasSuppressed
            if not updated then error(message,0) end
            put(key,widget.Value)
            local applied=not apply or safe(callback,widget.Value)
            if not applied then
                suppressed=true
                pcall(function()
                    if isColor then widget:SetValueRGB(previous) else widget:SetValue(previous) end
                end)
                suppressed=wasSuppressed
                put(key,previous)
                pcall(callback,previous)
            end
            profileChanged(key)
            return applied
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
                local wasSuppressed=suppressed
                suppressed=true
                if setters[key] then pcall(setters[key],previous,false) end
                suppressed=wasSuppressed
                put(key,previous)
                pcall(callback,previous)
            end
            profileChanged(key)
        end
    end
    local groupIcons={Home="house",Camera="camera",Sky="cloud-moon",Lighting="sun",Particles="sparkles",World="globe",Character="user-round",ESP="scan-eye",Tweaks="orbit",Audio="volume-2",Settings="settings"}
    navigation=loadUIModule("Navigation")({Library=Library,Make=make,Listen=listen,Tabs=categoryTabs,Translate=function(text) return ru[text] or text end})
    local function group(tab,title,side)
        return navigation:Group(tab,title,side,groupIcons[tab])
    end
    local featureLabels={
        camThird="Third-person camera",camNoclip="Camera through walls",camBlur="Clear ragdoll blur",camBody="First-person body",
        lightEnabled="Manual lighting",visualPresetEnabled="Lighting preset",characterEnabled="Forcefield material",selfESP="Own outline",
        bodyAppearance="Body colors",holeSprite="Blackhole animation",espServer="Server markers",serverGhostEnabled="My delayed position",
        lineEnabled="Grab line style",traceEnabled="Line to player",particleEnabled="Floating particles",snowEnabled="Snowfall",
        animationEnabled="Animations",revealInvisible="Reveal hidden players",antiKickESP="Anti-kick items",combatESP="Combat items",
    }
    local featureTips={
        camThird="Follow your character from a distance. Rotate with RMB; change distance in settings.",
        camNoclip="Let the camera pass through walls.",camBlur="Remove the game's ragdoll blur.",camBody="Show your own body while playing in first person.",
        characterEnabled="Apply a ForceField material to your character and selected objects.",selfESP="Draw an outline around your own character.",
        visualPresetEnabled="Choose Pale Frost, Dreamy Night or Tokyowami in settings.",lightEnabled="Adjust brightness, colors, bloom and blur yourself.",
        freeCameraEnabled="Move only the camera. Your character stays in place. RMB looks around; WASD moves.",
        spectateEnabled="Watch another player's camera subject. Enter their username in settings.",
        smoothCameraEnabled="Smooth camera movement without slowing down mouse rotation.",
        serverGhostEnabled="An estimated delayed position from your own movement history and ping; not server telemetry.",
        traceEnabled="Draw a line to a player. Enter their username in settings.",
        bodyTrailEnabled="Leave a colored trail behind your character.",jumpCircleEnabled="Show an expanding ring on the ground when you jump.",
        deathDustEnabled="Make dead characters dissolve into a local particle effect.",
        snowEnabled="Three layers of falling snow with adjustable wind.",particleEnabled="Surround the camera with decorative particles.",
        espPlayers="Highlight all players or choose specific players in settings.",espServer="Show the game's character location detectors.",
        antiKickESP="Highlight Shuriken, Kunai, Plate, Pickaxe and Pallet objects. This is not anti-kick protection.",
        combatESP="Highlight selected toy types and show their item icons.",
        animationEnabled="Choose an emote, dance or FTAP pose in settings. Asset availability depends on the game and rig.",
        holeSprite="Show a rotating, pulsing picture at a blackhole.",
    }
    local function toggle(g,key,text,initial,callback)
        local widget=g:AddToggle(key,{Text=featureLabels[key] or text,Tooltip=featureTips[key],Default=initial,RowHeight=(g.Type=="FeatureSettings" or g.Type=="FeaturePage") and 20 or 24,Callback=changed(key,callback)})
        widget.SearchAliases=key.." "..(ru[featureLabels[key] or text] or "").." "..(ru[featureTips[key] or ""] or "")
        return register(key,widget,initial,callback,false,{Kind="Toggle"})
    end
    local function featureSettings(key)
        local panel=Library:AddFeatureSettings(widgets[key],{Docked=true,Window=nativeWindow.MainFrame})
        featurePanels[key]=panel
        return panel
    end
    local function sliderControl(g,key,text,low,high,initial,step,callback)
        local rounding=step>=1 and 0 or step>=0.1 and 1 or step>=0.01 and 2 or 3
        local widget=g:AddSlider(key,{Text=text,Min=low,Max=high,Default=initial,Rounding=rounding,AllowRightClickInput=true,Callback=changed(key,callback)})
        return register(key,widget,initial,callback,false,{Kind="Slider",Min=low,Max=high})
    end
    local function field(g,key,text,initial,callback,live)
        local widget=g:AddInput(key,{Text=text,Default=tostring(initial or ""),Finished=not live,CommitOnBlur=true,Callback=changed(key,callback)})
        return register(key,widget,tostring(initial or ""),callback,false,{Kind="Input"})
    end
    local function choice(g,key,text,values,initial,callback)
        local widget=g:AddDropdown(key,{Text=text,Values=values,Default=table.find(values,initial) or 1,Callback=changed(key,callback)})
        return register(key,widget,initial,callback,false,{Kind="Dropdown",Values=values})
    end
    -- Existing rainbow implementations keep their own controls and efficient render paths.
    local legacyRainbowColors={lineColor=true,characterColor=true,hatColor=true}
    local rainbowColors={}
    local colorOwners={lightTint="lightEnabled",skyCloudColor="skyClouds",particleColor="particleEnabled",
        waterColor="waterEnabled",crossColor="crossEnabled",bhColor="bhTintEnabled",lineGradientStart="lineEnabled",lineGradientEnd="lineEnabled"}
    local colorWarningShown=false
    local function color(g,key,text,initial,callback,rainbowApply)
        put(key,initial)
        local label,picker,activeSetter
        local pickerReady=false
        local fallbackActive=false
        local rainbowState
        local handleChanged=changed(key,callback)
        local function onChanged(value)
            if rainbowState and not suppressed and not building then
                rainbowState.manual=value
                if controls[rainbowState.key] then setters[rainbowState.key](false,false) end
            end
            handleChanged(value)
        end
        local function useFallback(reason)
            pickerReady=false
            if not fallbackActive then
                fallbackActive=true
                -- Dispose partial/native UI if available; it must not keep applying callbacks.
                local partial=picker
                if not partial then
                    pcall(function() partial=Library.Options and Library.Options[key] end)
                end
                -- Inline rainbow belongs to the independent setting registry: preserve it if the swatch fails.
                local rainbowWidget=widgets[key.."Rainbow"]
                if rainbowWidget and rainbowWidget.Holder and label and label.TextLabel and g.Container then
                    pcall(function()
                        if rainbowWidget.Holder:IsDescendantOf(label.TextLabel) then
                            rainbowWidget.Holder.Parent=g.Container
                            rainbowWidget.Holder.Size=UDim2.new(1,0,0,20)
                            if rainbowWidget.TextLabel then rainbowWidget.TextLabel.Text=rainbowWidget.Text end
                        end
                    end)
                end
                if type(partial)=="table" and type(partial.Destroy)=="function" then pcall(partial.Destroy,partial) end
                if type(label)=="table" and type(label.Destroy)=="function" then pcall(label.Destroy,label) end
                local diagnostic="Prime Visuals: color control "..key.." unavailable: "..tostring(reason)
                pcall(warn,diagnostic)
                if not colorWarningShown then
                    colorWarningShown=true
                    pcall(notify,uiLanguage=="ru"
                        and "Часть настроек цвета недоступна. Меню продолжит работу; сброс цветов сохранён."
                        or "Some color controls are unavailable. The menu and color resets will still work.")
                end
            end
            local fallback={Type="ColorPicker",Value=controls[key] or initial}
            function fallback:SetValueRGB(value) self.Value=value end
            return register(key,fallback,fallback.Value,callback,true)
        end
        local created,result=pcall(function()
            label=g:AddLabel(text)
            label:AddColorPicker(key,{Default=initial,Title=text,Callback=function(value)
                if pickerReady then onChanged(value) end
            end})
            return Library.Options and Library.Options[key]
        end)
        if created and type(result)=="table" and type(result.SetValueRGB)=="function" and result.Value~=nil then
            picker=result pickerReady=true
            activeSetter=register(key,picker,initial,callback,true)
        else
            activeSetter=useFallback(created and "missing or invalid ColorPicker registration" or result)
        end
        local function set(value,apply)
            if rainbowState and not rainbowState.animating then
                rainbowState.manual=value
                if controls[rainbowState.key] then setters[rainbowState.key](false,false) end
            end
            local previousSuppressed=suppressed
            local ok,err=pcall(activeSetter,value,apply)
            suppressed=previousSuppressed
            if not ok then
                activeSetter=useFallback(err)
                activeSetter(value,apply)
                setters[key]=set
            end
        end
        setters[key]=set
        -- ESP fill already has Rainbow fill; all other color fields get a dedicated switch.
        if not legacyRainbowColors[key] and not key:match("^esp.+Fill$") then
            local owner=colorOwners[key]
            for _,category in ipairs({"Players","Server","Sticky","Blackholes"}) do
                if key:sub(1,#category+3)=="esp"..category then
                    owner=({Players="espPlayers",Server="espServer",Sticky="espSticky",Blackholes="espBlackholes"})[category]
                    break
                end
            end
            local rainbowKey=key.."Rainbow"
            local labelText="Rainbow: "..text
            ru[labelText]="Радуга: "..(ru[text] or text)
            rainbowState={key=rainbowKey,manual=initial,owner=owner,set=set,apply=rainbowApply or callback}
            rainbowColors[key]=rainbowState
            toggle(g,rainbowKey,labelText,false,function(on)
                if on then rainbowState.manual=controls[key]
                else set(rainbowState.manual,true) end
            end)
            if pickerReady and type(Library.CompactColorRainbow)=="function" then pcall(Library.CompactColorRainbow,Library,label,widgets[rainbowKey]) end
        end
        return set
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
            local factory=loadUIModule("AnimatedEmblem")
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
        notify(uiLanguage=="ru" and "Оформление недоступно. Остальное меню работает." or "Artwork is unavailable. The rest of the menu still works.")
        local root=make("Frame",{Name="ArtworkUnavailable",BackgroundTransparency=1,
            AnchorPoint=Vector2.new(0.5,0.5),Position=options.Position or UDim2.fromScale(0.5,0.5),
            Size=options.Size or UDim2.fromScale(0.92,0.96)},options.Parent)
        return {Root=root,Unavailable=true,Step=function() end,Destroy=function() root:Destroy() end}
    end
    local function action(g,text,fn)
        local button=g:AddButton({Text=text,Func=function() if alive then safe(fn) end end})
        button.SearchAliases=ru[text] or text
        return button
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
        for _,key in ipairs({"skySunVisible","skySun","skyClouds"}) do appliedSettings[key]=nil end
    end)
    -- CAMERA
    -- First-person transparency can survive Roblox's switch to Classic camera.
    -- Correct only the local multiplier, after the camera; preserve actual Transparency and effect layers.
    local thirdParts,thirdCharacter={},nil
    local thirdVisibilityBound=false
    local thirdPan,thirdPanOriginal,thirdPanOwned,thirdPanBound,thirdPanAttempted
    local function releaseThirdPan()
        if thirdPanOwned then
            pcall(thirdPan.setTogglePan,thirdPanOriginal)
            thirdPanOwned=false
        end
        unpatch("thirdMouse")
    end
    local function updateThirdPan()
        local camera=Workspace.CurrentCamera
        local active=alive and controls.camThird and not Library.Toggled and not UIS:GetFocusedTextBox()
            and not controls.freeCameraEnabled and not controls.spectateEnabled and not controls.camNoclip
            and camera and camera.CameraType~=Enum.CameraType.Scriptable
        if not active or not thirdPan then releaseThirdPan() return end
        if not thirdPanOwned then thirdPanOriginal=thirdPan.getTogglePan() thirdPanOwned=true end
        thirdPan.setTogglePan(true)
        patch("thirdMouse",UIS,"MouseBehavior",Enum.MouseBehavior.LockCenter)
    end
    local function startThirdPan()
        if thirdPanBound then return end
        if thirdPanAttempted and not thirdPan then return end
        thirdPanAttempted=true
        local ok,result=pcall(function()
            local scripts=player:FindFirstChild("PlayerScripts")
            local module=scripts and scripts:FindFirstChild("PlayerModule")
            local cameras=module and module:FindFirstChild("CameraModule")
            local input=cameras and cameras:FindFirstChild("CameraInput")
            if not input then return nil end
            return require(input)
        end)
        if not ok or type(result)~="table" or type(result.setTogglePan)~="function" or type(result.getTogglePan)~="function" then
            warn("Prime Visuals: native CameraInput unavailable; third person keeps RMB rotation")
            return
        end
        thirdPan=result
        Run:BindToRenderStep("PrimeVisualsThirdPan",Enum.RenderPriority.Camera.Value-1,updateThirdPan)
        Run:BindToRenderStep("PrimeVisualsThirdPanMouse",Enum.RenderPriority.Camera.Value+3,updateThirdPan)
        thirdPanBound=true
    end
    local function thirdPart(part)
        if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then thirdParts[part]=true end
    end
    local function thirdVisibility()
        if not alive or not controls.camThird then return end
        local character=player.Character
        if thirdCharacter~=character then
            job("Third-person parts") unpatch("thirdBody") thirdParts={} thirdCharacter=character
            if character then
                for _,part in ipairs(character:GetDescendants()) do thirdPart(part) end
                job("Third-person parts",character.DescendantAdded,thirdPart)
            end
        end
        for part in pairs(thirdParts) do
            if not part.Parent or not character or not part:IsDescendantOf(character) then
                thirdParts[part]=nil unpatch("thirdBody",part)
            else patch("thirdBody",part,"LocalTransparencyModifier",0) end
        end
    end
    clearThirdVisibility=function()
        if thirdPanBound then
            Run:UnbindFromRenderStep("PrimeVisualsThirdPan")
            Run:UnbindFromRenderStep("PrimeVisualsThirdPanMouse") thirdPanBound=false
        end
        releaseThirdPan()
        job("Third-person parts") job("Third-person visibility")
        if thirdVisibilityBound then Run:UnbindFromRenderStep("PrimeVisualsThirdBody") thirdVisibilityBound=false end
        unpatch("thirdBody") thirdParts={} thirdCharacter=nil
    end
    local function startThirdVisibility()
        unpatch("body") -- The first-person body alpha must not compete with third-person visibility.
        thirdVisibility()
        if thirdVisibilityBound then return end
        if type(Run.BindToRenderStep)=="function" then
            Run:BindToRenderStep("PrimeVisualsThirdBody",Enum.RenderPriority.Camera.Value+2,function()
                if alive and controls.camThird then thirdVisibility() end
            end)
            thirdVisibilityBound=true
        else job("Third-person visibility",Run.RenderStepped,thirdVisibility) end
    end
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
            startThirdVisibility()
            startThirdPan()
        else clearThirdVisibility() unpatch("third") end
    end
    maintenance.Camera=function()
        if fovChanged then applyFOV() end
        if controls.camThird then updateThirdPerson(true) end
    end
    do
        local g=group("Camera","View",2)
        toggle(g,"camThird","Third person [3]",false,updateThirdPerson)
        sliderControl(featureSettings("camThird"),"camDistance","Distance",2,80,12,1,function() if controls.camThird then updateThirdPerson(true) end end)
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
                if controls.camThird then return end
                local character=player.Character
                if not character then return end
                for _,part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name~="Head" and part.Name~="HumanoidRootPart" then patch("body",part,"LocalTransparencyModifier",controls.camBodyAlpha or 0.3) end
                end
            end)
        end)
        sliderControl(featureSettings("camBody"),"camBodyAlpha","Limb transparency",0,1,0.3,0.05,function() end)
        listen(UIS.InputBegan,function(event,processed)
            if not processed and not UIS:GetFocusedTextBox() and event.KeyCode==Enum.KeyCode.Three then setters.camThird(not controls.camThird,true) end
        end)
    end
    -- LIGHTING: independently adjustable post-processing, without replacing game effects.
    local effects={}
    local function effect(name,class)
        if effects[name] and effects[name].Parent~=Lighting then dispose(effects[name]) effects[name]=nil end
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
        g=featureSettings("lightEnabled")
        local function update() if controls.lightEnabled then shaders(true) end end
        sliderControl(g,"lightBrightness","Brightness",0,5,2,0.05,update)
        sliderControl(g,"lightExposure","Exposure",-3,3,0,0.05,update)
        sliderControl(g,"lightSaturation","Saturation",-1,1,0.15,0.05,update)
        sliderControl(g,"lightContrast","Contrast",-1,1,0.05,0.05,update)
        color(g,"lightTint","Tint",Color3.new(1,1,1),update,function(value)
            if effects.Color then effects.Color.TintColor=value end
        end)
        local h=g
        sliderControl(h,"lightBloom","Bloom",0,3,0.25,0.05,update)
        sliderControl(h,"lightRays","Sun rays",0,1,0.03,0.01,update)
        sliderControl(h,"lightBlur","Blur",0,24,0,0.5,update)
        action(h,"Reset filters",function()
            setters.lightEnabled(false,true)
            for key,v in pairs({lightBrightness=2,lightExposure=0,lightSaturation=0.15,lightContrast=0.05,lightBloom=0.25,lightRays=0.03,lightBlur=0}) do setters[key](v,false) end
            setters.lightTint(Color3.new(1,1,1),false)
        end)
    end
    maintenance.Sky=function()
        if activeSky and skyRecoveryData and not (controls.visualPresetEnabled and controls.visualPreset=="Tokyowami") then
            local sky=ensureSky()
            for key,value in pairs(skyRecoveryData) do if sky[key]~=value then sky[key]=value end end
        end
    end
    maintenance.Shaders=function() if controls.lightEnabled and not (controls.visualPresetEnabled and controls.visualPreset=="Pale Frost") then shaders(true) end end
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
            rememberSky()
        end)
        sliderControl(g,"skyTime","Time of day",0,24,originalClock,0.1,function(v) patch("skytime",Lighting,"ClockTime",v) end)
        sliderControl(featureSettings("skySunVisible"),"skySun","Sun size",0,60,sourceSky and sourceSky.SunAngularSize or 21,0.5,function(v)
            if controls.skySunVisible then ensureSky().SunAngularSize=v rememberSky() end
        end)
        action(g,"Reset time and sun",function()
            unpatch("skytime") setters.skyTime(originalClock,false)
            local value=sourceSky and sourceSky.SunAngularSize or 21
            setters.skySun(value,false)
            setters.skySunVisible(originalSunVisible,true)
            for _,key in ipairs({"skyTime","skySun","skySunVisible"}) do appliedSettings[key]=nil end
            if not customSkyLoaded then skyRecoveryData=nil end
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
            if cloud and not cloud.Parent and owned[cloud] then dispose(cloud) cloud=nil end
            cloud=cloud and cloud.Parent and cloud or Terrain:FindFirstChildOfClass("Clouds")
            if not cloud then cloud=own(make("Clouds",{Enabled=false},Terrain)) end
            patch("clouds",cloud,"Enabled",true)
            patch("clouds",cloud,"Density",controls.skyCloudDensity or 0.5)
            patch("clouds",cloud,"Cover",controls.skyCloudCover or 0.5)
            patch("clouds",cloud,"Color",controls.skyCloudColor or Color3.new(1,1,1))
        end
        toggle(h,"skyClouds","Clouds",false,updateClouds)
        h=featureSettings("skyClouds")
        local function update() if controls.skyClouds then updateClouds(true) end end
        sliderControl(h,"skyCloudDensity","Density",0,1,0.5,0.05,update)
        sliderControl(h,"skyCloudCover","Cover",0,1,0.5,0.05,update)
        color(h,"skyCloudColor","Color",Color3.new(1,1,1),update,function(value)
            if cloud and cloud.Parent then patch("clouds",cloud,"Color",value) end
        end)
        maintenance.Clouds=function() if controls.skyClouds then updateClouds(true) end end
        beforeSkyChange=function()
            if controls.visualPresetEnabled and controls.visualPreset=="Tokyowami" then setters.visualPresetEnabled(false,true) end
        end
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
        if particlePart and (not particlePart.Parent or not emitter or not emitter.Parent) then
            job("Particles") dispose(particlePart) particlePart,emitter=nil,nil
        end
        if not particlePart then
            particlePart=own(make("Part",{Name="PV_Particles",Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Transparency=1,Size=Vector3.new(60,60,60)},Workspace))
            emitter=make("ParticleEmitter",{Enabled=true,LightEmission=0.7,Speed=NumberRange.new(0,2),Lifetime=NumberRange.new(4,7),SpreadAngle=Vector2.new(180,180),Rotation=NumberRange.new(0,360)},particlePart)
            job("Particles",Run.RenderStepped,function()
                if Workspace.CurrentCamera and particlePart then particlePart.CFrame=CFrame.new(Workspace.CurrentCamera.CFrame.Position) end
            end)
        end
        local texture=controls.particleTexture or "Circles"
        local urls={Circles="rbxassetid://242109931",Snowflakes="rbxassetid://14443362047",Prime="rbxassetid://79685990879972"}
        emitter.Enabled=true
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
        g=featureSettings("particleEnabled")
        local function update() if controls.particleEnabled then updateParticles(true) end end
        choice(g,"particleTexture","Texture",{"Circles","Snowflakes","Prime","Custom"},"Circles",update)
        field(g,"particleImage","Custom image","242109931",update)
        color(g,"particleColor","Color",purple,update,function(value)
            if emitter then emitter.Color=ColorSequence.new(value) end
        end)
        local h=g
        sliderControl(h,"particleCount","Count per second",10,5000,150,10,update)
        sliderControl(h,"particleLimit","Performance cap",100,5000,1000,100,update)
        sliderControl(h,"particleSize","Size",0.05,5,0.15,0.05,update)
        sliderControl(h,"particleSpeed","Max speed",0,20,2,0.5,update)
        sliderControl(h,"particleArea","Area",10,300,60,5,update)
    end
    -- WORLD: FTAP ocean replacement in bounded chunks, with original terrain preserved.
    maintenance.Particles=function()
        if controls.particleEnabled and (not particlePart or not particlePart.Parent or not emitter or not emitter.Parent or not emitter.Enabled) then updateParticles(true) end
    end
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
    maintenance.Swimming=function() if controls.waterEnabled and controls.waterSolid then updateSwimming() end end
    local function restoreChunk(entry)
        -- Native snapshots preserve terrain that existed before conversion, including empty cells.
        Terrain:PasteRegion(entry.snapshot,entry.corner,true)
        entry.snapshot:Destroy()
    end
    restoreWater=function()
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
        g=featureSettings("waterEnabled")
        color(g,"waterColor","Color",Color3.fromRGB(35,135,190),update,function(value)
            patch("water",Terrain,"WaterColor",value)
        end)
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
        g=featureSettings("fpsEnabled")
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
        g=featureSettings("characterEnabled")
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
            if hat and (not hat.Parent or not hatMesh or not hatMesh.Parent) then dispose(hat) hat=nil hatMesh=nil end
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
        maintenance.Hat=function()
            if controls.hatEnabled and (not hat or not hat.Parent or not hatMesh or not hatMesh.Parent) then updateHat(true) end
        end
        toggle(h,"hatEnabled","Cone hat",false,updateHat)
        h=featureSettings("hatEnabled")
        color(h,"hatColor","Color",purple,function() end)
        toggle(h,"hatRainbow","Rainbow",false,function() end)
        sliderControl(h,"hatSize","Width",1,8,3,0.1,function() end)
        sliderControl(h,"hatHeight","Height offset",0,4,1.1,0.1,function() end)
        sliderControl(h,"hatAlpha","Transparency",0,1,0.2,0.05,function() end)
    end
    -- Lazy-loaded local actors and physics, isolated from FTAP's server grab events.
    do
        local g=group("Character","Mannequins",1)
        toggle(g,"mannequinEnabled","Local mannequins",false,function(on)
            if on and not mannequins then
                mannequins=loadUIModule("Mannequins")({
                    Players=Players,Workspace=Workspace,Input=UIS,Run=Run,
                    RagdollFactory=loadUIModule("MannequinRagdoll"),
                    MenuOpen=function() return Library.Toggled end,
                    Notify=function(en,russian) notify(uiLanguage=="ru" and russian or en) end,
                })
            end
            if mannequins then mannequins:SetEnabled(on) end
        end)
        g=featureSettings("mannequinEnabled")
        field(g,"mannequinName","Roblox username","",function() end,true)
        g:AddLabel("Empty username = grey mannequin")
        action(g,"Spawn mannequin",function() if mannequins and controls.mannequinEnabled then mannequins:Spawn(controls.mannequinName) end end)
        action(g,"Apply avatar to last",function() if mannequins and controls.mannequinEnabled then mannequins:ApplyToLast(controls.mannequinName) end end)
        action(g,"Reset last to grey",function() if mannequins and controls.mannequinEnabled then mannequins:ApplyToLast("") end end)
        action(g,"Delete last mannequin",function() if mannequins then mannequins:DeleteLast() end end)
        action(g,"Delete all mannequins",function() if mannequins then mannequins:Clear() end end)
        toggle(g,"mannequinGrab","Local grab",true,function(on) if mannequins then mannequins:SetInteractive(on) end end)
        toggle(g,"mannequinPhysics","Ragdoll physics",true,function(on) if mannequins then mannequins:SetPhysics(on) end end)
        toggle(g,"mannequinSounds","Ragdoll sounds",true,function(on) if mannequins then mannequins:SetSounds(on) end end)
        g:AddLabel("LMB: grab/drop | RMB: throw")
        g:AddLabel("Wheel: distance | Hold R: rotate")
    end
    -- ESP: four independent categories, with event-based discovery and capped updates.
    local espRoot=own(make("Folder",{Name="PV_ESP"},Workspace))
    local categories={Players={},Server={},Sticky={},Blackholes={}}
    local espEntries={}
    local playerSelector
    local playerLabels,playerImages={},{}
    local function playerLabel(p) return (p.DisplayName or p.Name).." (@"..p.Name..")" end
    local function playerHeadshot(p)
        return p and p.UserId and string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=48&h=48",tostring(p.UserId)) or ""
    end
    local function playerSelected(p)
        return p~=player and (controls.espAllPlayers~=false or rememberedPlayers[p.Name]==true)
    end
    local function playerNames(excluded)
        local names={}
        for name in pairs(playerLabels) do playerLabels[name]=nil end
        for name in pairs(playerImages) do playerImages[name]=nil end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=player and p~=excluded then
                table.insert(names,p.Name)
                playerLabels[p.Name]=playerLabel(p)
                playerImages[p.Name]=playerHeadshot(p)
            end
        end
        table.sort(names,function(a,b) return a:lower()<b:lower() end)
        return names
    end
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
    local espNeedsRefresh=false
    local function addESP(target,category,owner)
        if espRoot.Parent~=Workspace then espNeedsRefresh=true return end
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
        if controls.espServer and o:IsA("BasePart") and (o.Name=="PlayerCharacterLocationDetector" or o.Name:lower()=="partesp") then addESP(o,"Server",nearestOwner(o)) end
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
        if espRoot.Parent~=Workspace then
            for target in pairs(espEntries) do removeESP(target) end
            dispose(espRoot)
            espRoot=own(make("Folder",{Name="PV_ESP"},Workspace))
        end
        espNeedsRefresh=false
        local enabled=controls.espPlayers or controls.espServer or controls.espSticky or controls.espBlackholes
        job("ESP world") job("ESP render") job("ESP smooth")
        local active={Players=controls.espPlayers,Server=controls.espServer,Sticky=controls.espSticky,Blackholes=controls.espBlackholes}
        for target,entry in pairs(espEntries) do if not active[entry.category] or (entry.category=="Players" and not playerSelected(entry.owner)) then removeESP(target) end end
        if not enabled then return end
        if controls.espPlayers then for _,p in ipairs(Players:GetPlayers()) do if playerSelected(p) and p.Character then addESP(p.Character,"Players",p) end end end
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
                    local inRange=true
                    if e.category=="Players" then
                        local camera=Workspace.CurrentCamera
                        local distance=camera and (e.part.Position-camera.CFrame.Position).Magnitude or 0
                        inRange=distance<=(controls.espPlayersMaxDistance or 5000)
                        local details={}
                        if controls.espPlayersHealth then
                            local humanoid=target:FindFirstChildOfClass("Humanoid")
                            if humanoid then details[#details+1]=string.format("%d HP",math.floor(math.max(0,humanoid.Health))) end
                        end
                        if controls.espPlayersShowDistance then details[#details+1]=string.format("%d st",math.floor(distance)) end
                        if #details>0 then title=title.."  |  "..table.concat(details,"  |  ") end
                        e.bill.Enabled=cfg.names and inRange
                        hi.Enabled=cfg.highlight and inRange
                        e.text.BackgroundTransparency=controls.espPlayersBackground and 0.35 or 1
                        e.text.BackgroundColor3=Color3.fromRGB(10,10,14)
                    end
                    if cfg.icon then title="[+] "..title end
                    e.text.Text=title e.text.TextSize=cfg.size e.text.TextColor3=cfg.text e.text.TextStrokeColor3=cfg.textOutline e.text.TextStrokeTransparency=cfg.textStroke
                    local font=cfg.font=="Code" and Enum.Font.Code or cfg.font=="Roboto" and Enum.Font.Roboto or cfg.font=="Rounded" and Enum.Font.FredokaOne or cfg.font=="Arcade" and Enum.Font.Arcade or cfg.font=="Source" and Enum.Font.SourceSansBold or cfg.font=="Gotham" and Enum.Font.GothamBold or cfg.bold and Enum.Font.BuilderSansBold or Enum.Font.BuilderSans
                    e.text.Font=font
                    if e.owner and e.category=="Server" and e.owner.Character then
                        local root=e.owner.Character:FindFirstChild("HumanoidRootPart")
                        if root then e.bill.Enabled=cfg.names and (root.Position-e.part.Position).Magnitude>=cfg.nameDistance end
                    end
                    if e.boxFill then e.boxFill.Visible=cfg.highlight and (e.part.Position-(Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position or e.part.Position)).Magnitude<=(controls.espServerMaxDistance or 5000) e.boxFill.Color3=fillColor e.boxFill.Transparency=cfg.fillAlpha e.boxFill.Size=e.part.Size end
                    if e.selection then e.selection.Visible=cfg.highlight and (e.category~="Server" or (e.part.Position-(Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position or e.part.Position)).Magnitude<=(controls.espServerMaxDistance or 5000)) e.selection.Color3=cfg.outline e.selection.Transparency=cfg.outlineAlpha e.selection.LineThickness=cfg.thickness end
                end
            end
        end)
    end
    maintenance.ESP=function()
        if not (controls.espPlayers or controls.espServer or controls.espSticky or controls.espBlackholes) then return end
        local refresh=espNeedsRefresh or espRoot.Parent~=Workspace
        for target,entry in pairs(espEntries) do
            if not entry.hi.Parent or not entry.bill.Parent or (entry.proxy and not entry.proxy.Parent) then removeESP(target) refresh=true end
        end
        if refresh then refreshESP() end
    end
    local function watchPlayer(p)
        listen(p.CharacterAdded,function(character)
            task.delay(0.7,function() if alive and controls.espPlayers and playerSelected(p) and character.Parent then addESP(character,"Players",p) end end)
        end)
    end
    for _,p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
    listen(Players.PlayerAdded,function(p)
        watchPlayer(p)
        if playerSelector then
            local saved={} for name,value in pairs(rememberedPlayers) do saved[name]=value end
            playerSelector:SetValues(playerNames())
            rememberedPlayers=saved
            local visible={} for name,value in pairs(saved) do visible[name]=value end
            setters.espSelectedPlayers(visible,false)
            if controls.espPlayers then refreshESP() end
        end
    end)
    listen(Players.PlayerRemoving,function(p)
        for target,entry in pairs(espEntries) do
            if entry.owner==p then removeESP(target) end
        end
        if playerSelector then
            local saved={} for name,value in pairs(rememberedPlayers) do saved[name]=value end
            playerSelector:SetValues(playerNames(p))
            rememberedPlayers=saved
        end
    end)
    do
        local playersGroup=group("ESP","Player markers",1)
        local objectsGroup=group("ESP","World markers",1)
        for _,entry in ipairs({{"espPlayers","Players"},{"espServer","Server detectors"},{"espSticky","Stickies"},{"espBlackholes","Blackholes"}}) do
            toggle(entry[1]=="espPlayers" and playersGroup or objectsGroup,entry[1],entry[2],false,refreshESP)
        end
        local function config(category,side)
            local cfg=categories[category]
            local masterKeys={Players="espPlayers",Server="espServer",Sticky="espSticky",Blackholes="espBlackholes"}
            local settings=featureSettings(masterKeys[category])
            local general=settings:AddPage("General")
            local appearance=settings:AddPage("Appearance")
            local g=general
            if category=="Players" then
                toggle(g,"espAllPlayers","All players",true,refreshESP)
                local function rememberPlayerSelection(values)
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p~=player then rememberedPlayers[p.Name]=values[p.Name] and true or nil end
                    end
                    refreshESP()
                end
                playerSelector=g:AddDropdown("espSelectedPlayers",{
                    Text="Selected players",Values=playerNames(),Multi=true,AllowNull=true,
                    ValueImages=playerImages,
                    FormatListValue=function(name) return playerLabels[name] or name end,
                    FormatDisplayValue=function(name) return playerLabels[name] or name end,
                    Callback=changed("espSelectedPlayers",rememberPlayerSelection),
                })
                register("espSelectedPlayers",playerSelector,{},rememberPlayerSelection,false,{Kind="Dropdown",Multi=true})
            end
            if category=="Server" then toggle(g,"espServerSmooth","Smooth movement",true,function(v) cfg.smooth=v end) end
            toggle(g,"esp"..category.."Highlight","Highlight",true,function(v) cfg.highlight=v end)
            g=appearance
            color(g,"esp"..category.."Fill","Fill",cfg.fill,function(v) cfg.fill=v end)
            toggle(g,"esp"..category.."Rainbow","Rainbow fill",false,function(v) cfg.rainbow=v end)
            color(g,"esp"..category.."Outline","Outline",cfg.outline,function(v) cfg.outline=v end)
            sliderControl(g,"esp"..category.."FillAlpha","Fill transparency",0,1,cfg.fillAlpha,0.05,function(v) cfg.fillAlpha=v end)
            sliderControl(g,"esp"..category.."OutlineAlpha","Outline transparency",0,1,cfg.outlineAlpha,0.05,function(v) cfg.outlineAlpha=v end)
            if category=="Server" or category=="Sticky" then sliderControl(g,"esp"..category.."Thickness","Outline thickness",0.01,0.2,0.03,0.01,function(v) cfg.thickness=v end) end
            toggle(general,"esp"..category.."Names","Name",true,function(v) cfg.names=v end)
            choice(g,"esp"..category.."Font","Font",{"Builder Sans","Code","Roboto","Rounded","Gotham","Arcade","Source"},"Builder Sans",function(v) cfg.font=v end)
            toggle(g,"esp"..category.."Bold","Bold",false,function(v) cfg.bold=v end)
            toggle(g,"esp"..category.."Icon","Name icon",false,function(v) cfg.icon=v end)
            color(g,"esp"..category.."Text","Text color",white,function(v) cfg.text=v end)
            color(g,"esp"..category.."TextOutline","Text outline",black,function(v) cfg.textOutline=v end)
            sliderControl(g,"esp"..category.."TextAlpha","Text outline transparency",0,1,0,0.05,function(v) cfg.textStroke=v end)
            sliderControl(g,"esp"..category.."Size","Text size",8,30,14,1,function(v) cfg.size=v end)
            sliderControl(g,"esp"..category.."Offset","Vertical offset",0,15,3,0.25,function(v) cfg.offset=v end)
            if category=="Server" then
                sliderControl(general,"espServerDistance","Show owner when apart",0,50,0,1,function(v) cfg.nameDistance=v end)
                sliderControl(general,"espServerMaxDistance","Maximum distance",50,5000,5000,1,function() end)
            end
            if category=="Players" then
                toggle(general,"espPlayersHealth","Show health",false,function() end)
                toggle(general,"espPlayersShowDistance","Show distance",false,function() end)
                toggle(g,"espPlayersBackground","Name background",false,function() end)
                sliderControl(general,"espPlayersMaxDistance","Maximum distance",50,5000,5000,1,function() end)
            end
        end
        config("Players",1) config("Server",2) config("Sticky",1) config("Blackholes",2)
    end
    -- TWEAKS: game-owned instances are edited locally and restored on disable.
    local crossGui,crossImage
    local function ensureCrosshair()
        if crossGui and crossGui.Parent==playerGui and crossImage and crossImage.Parent==crossGui then return end
        if crossGui then dispose(crossGui) end
        crossGui=own(make("ScreenGui",{Name="PrimeVisualsCrosshair",IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=900,Enabled=false},playerGui))
        crossImage=make("ImageLabel",{Name="Crosshair",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(28,28),Image="rbxassetid://9943168532",BackgroundTransparency=1},crossGui)
    end
    ensureCrosshair()
    local function crosshair(on)
        ensureCrosshair()
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
    maintenance.Crosshair=function()
        if controls.crossEnabled and (not crossGui or crossGui.Parent~=playerGui or not crossImage or crossImage.Parent~=crossGui) then crosshair(true) end
    end
    local lineTextures={Laser="rbxassetid://8922958725",Chain="rbxassetid://81358145120405",["Chain 2"]="rbxassetid://132910145874066",
        ["Chain 3"]="rbxassetid://128466395060514",["Chain 4"]="rbxassetid://73368670987191",Pulse="rbxassetid://82163767314193",Rope="rbxassetid://78999022056924",
        Dots="rbxassetid://9169659357",Bubbles="rbxassetid://1249690853",Spring="rbxassetid://18837732116",Gamepass="rbxassetid://8933355899",Default="rbxassetid://8933346550"}
    local lineBeams,lineSignals,lineRoots,pendingBeams={},{},{},{}
    local lineRunning=false
    local lineDesired
    clearLineSignals=function()
        for _,signals in pairs(lineSignals) do for _,connection in ipairs(signals) do connection:Disconnect() end end
        lineSignals={} lineBeams={} lineRoots={} pendingBeams={} lineRunning=false
    end
    local function sameLineValue(property,current,wanted)
        if current==wanted then return true end
        if property~="Color" then return false end
        local a,b=current.Keypoints,wanted.Keypoints
        if not a or not b or #a~=#b then return false end
        for i,point in ipairs(a) do if point.Time~=b[i].Time or point.Value~=b[i].Value then return false end end
        return true
    end
    local function lineRainbowColor() return ColorSequence.new(Color3.fromHSV((os.clock()*0.12)%1,1,1)) end
    local function grabRoot(beam)
        local node=beam.Parent
        while node and node~=Workspace do
            if node.Name=="GrabParts" and node:IsDescendantOf(Workspace) then return node end
            node=node.Parent
        end
    end
    local function releaseBeam(beam)
        for _,connection in ipairs(lineSignals[beam] or {}) do connection:Disconnect() end
        lineSignals[beam]=nil lineBeams[beam]=nil
        if alive and controls.lineEnabled and beam:IsDescendantOf(Workspace) then pendingBeams[beam]=true end
        unpatch("line",beam)
    end
    local function enforceBeam(beam,entry)
        if not alive or not controls.lineEnabled then return true end
        local root=grabRoot(beam)
        if not root then return false end
        lineRoots[root]=true
        if beam.Enabled==false then return true end
        if entry.applying then return true end
        entry.applying=true
        local ok,message=pcall(function()
            for property,value in pairs(lineDesired) do
                if not sameLineValue(property,beam[property],value) then patch("line",beam,property,value) end
            end
        end)
        entry.applying=false
        if not ok then error(message,0) end
        return true
    end
    local function observeBeam(beam)
        if not grabRoot(beam) then pendingBeams[beam]=true return end
        pendingBeams[beam]=nil
        local entry=lineBeams[beam]
        if not entry then
            entry={applying=false} lineBeams[beam]=entry
            local signals={} lineSignals[beam]=signals
            for _,property in ipairs({"Texture","Color","TextureSpeed"}) do
                table.insert(signals,beam:GetPropertyChangedSignal(property):Connect(function()
                    if entry.applying or not alive or not controls.lineEnabled then return end
                    -- One failed or destroyed beam must not disable the whole line manager.
                    pcall(enforceBeam,beam,entry)
                end))
            end
        end
        pcall(enforceBeam,beam,entry)
    end
    local function discoverLines(full)
        for _,node in ipairs(full and Workspace:GetDescendants() or Workspace:GetChildren()) do
            if node.Name=="GrabParts" then lineRoots[node]=true
            elseif full and node:IsA("Beam") then pendingBeams[node]=true end
        end
        for root in pairs(lineRoots) do
            if not root:IsDescendantOf(Workspace) or root.Name~="GrabParts" then lineRoots[root]=nil
            else
                for _,node in ipairs(root:GetDescendants()) do if node:IsA("Beam") then observeBeam(node) end end
            end
        end
        for beam in pairs(pendingBeams) do
            if not beam:IsDescendantOf(Workspace) then pendingBeams[beam]=nil
            elseif grabRoot(beam) then observeBeam(beam) end
        end
    end
    local function applyLine()
        if not controls.lineEnabled then
            job("Grab line") job("Grab line lifecycle")
            clearLineSignals() unpatch("line")
            return
        end
        lineDesired={Texture=lineTextures[controls.lineTexture] or imageId(controls.lineImage),
            Color=controls.lineRainbow and lineRainbowColor() or (controls.lineGradient and ColorSequence.new(controls.lineGradientStart or white,controls.lineGradientEnd or purple) or ColorSequence.new(controls.lineColor or white)),TextureSpeed=controls.lineSpeed or 1}
        if not lineRunning then
            lineRunning=true
            -- Full discovery only on enable/reload; ongoing recovery scans known grab scopes.
            discoverLines(true)
            job("Grab line",Workspace.DescendantAdded,function(node)
                if node:IsA("Beam") then observeBeam(node)
                elseif node.Name=="GrabParts" then
                    lineRoots[node]=true
                    for _,child in ipairs(node:GetDescendants()) do if child:IsA("Beam") then observeBeam(child) end end
                end
            end)
            local recoveryElapsed,enforceElapsed=0,0
            job("Grab line lifecycle",Run.Heartbeat,function(dt)
                recoveryElapsed=recoveryElapsed+dt enforceElapsed=enforceElapsed+dt
                if recoveryElapsed>=1 then recoveryElapsed=recoveryElapsed%1 discoverLines(false) end
                local interval=controls.lineRainbow and 1/30 or 0.1
                if enforceElapsed<interval then return end
                enforceElapsed=enforceElapsed%interval
                if controls.lineRainbow then lineDesired.Color=lineRainbowColor() end
                for beam,entry in pairs(lineBeams) do
                    local ok,valid=pcall(enforceBeam,beam,entry)
                    if ok and not valid then releaseBeam(beam) end
                end
            end)
        else
            for beam,entry in pairs(lineBeams) do
                local ok,valid=pcall(enforceBeam,beam,entry)
                if ok and not valid then releaseBeam(beam) end
            end
        end
    end
    local grabbedInfo,infoText
    local function ensureGrabInfo()
        if grabbedInfo and grabbedInfo.Parent==playerGui and infoText and infoText.Parent==grabbedInfo then return end
        if grabbedInfo then dispose(grabbedInfo) end
        grabbedInfo=own(make("ScreenGui",{Name="PrimeVisualsGrabInfo",ResetOnSpawn=false,Enabled=false,DisplayOrder=800},playerGui))
        infoText=make("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,50),Size=UDim2.fromOffset(480,58),BackgroundTransparency=1,
        Text="",TextSize=14,Font=Enum.Font.BuilderSans,TextColor3=white,TextStrokeTransparency=0.25,TextWrapped=true},grabbedInfo)
    end
    ensureGrabInfo()
    local function updateGrabInfo()
        if not controls.grabInfo then return end
        ensureGrabInfo()
        local roots={}
        for root in pairs(lineRoots) do if root:IsDescendantOf(Workspace) then roots[root]=true end end
        for _,node in ipairs(Workspace:GetChildren()) do if node.Name=="GrabParts" then roots[node]=true end end
        local part
        for root in pairs(roots) do
            for _,beam in ipairs(root:GetDescendants()) do
                if beam:IsA("Beam") and beam.Enabled~=false and beam.Attachment1 then
                    local candidate=beam.Attachment1.Parent
                    if candidate and candidate:IsA("BasePart") and candidate:IsDescendantOf(Workspace) then part=candidate break end
                end
            end
            if part then break end
        end
        if not part or not part:IsA("BasePart") then infoText.Text="" return end
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local distance=root and (root.Position-part.Position).Magnitude or 0
        infoText.Text=string.format("%s  |  %.1f studs  |  %.1f mass\n%s",part.Name,distance,part.AssemblyMass,part.Material.Name)
    end
    local bhClones={}
    maintenance.GrabInfo=function()
        if controls.grabInfo and (not grabbedInfo.Parent or not infoText.Parent) then ensureGrabInfo() updateGrabInfo() end
    end
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
        toggle(g,"lineEnabled","Custom line",false,applyLine)
        local lineSettings=featureSettings("lineEnabled")
        choice(lineSettings,"lineTexture","Texture",{"Laser","Chain","Chain 2","Chain 3","Chain 4","Pulse","Rope","Dots","Bubbles","Spring","Gamepass","Default","Custom"},"Chain",applyLine)
        field(lineSettings,"lineImage","Custom image","8922958725",applyLine)
        color(lineSettings,"lineColor","Color",white,applyLine)
        toggle(lineSettings,"lineRainbow","Rainbow",false,applyLine)
        toggle(lineSettings,"lineGradient","Gradient",false,applyLine)
        color(lineSettings,"lineGradientStart","Gradient start",white,applyLine)
        color(lineSettings,"lineGradientEnd","Gradient end",purple,applyLine)
        sliderControl(lineSettings,"lineSpeed","Texture speed",-10,10,1,0.25,applyLine)
        toggle(g,"grabInfo","Grabbed object info",false,function(on)
            grabbedInfo.Enabled=on job("Grab info")
            if on then
                local elapsed=0
                job("Grab info",Run.Heartbeat,function(dt) elapsed=elapsed+dt if elapsed>0.15 then elapsed=0 updateGrabInfo() end end)
            end
        end)
        local h=group("Tweaks","Crosshair",2)
        toggle(h,"crossEnabled","Custom crosshair",false,crosshair)
        h=featureSettings("crossEnabled")
        local function update() if controls.crossEnabled then crosshair(true) end end
        field(h,"crossImage","Image","9943168532",update)
        color(h,"crossColor","Color",white,update,function(value) crossImage.ImageColor3=value end)
        sliderControl(h,"crossSize","Size",8,128,28,1,update)
        local b=group("Tweaks","Blackholes",1)
        toggle(b,"bhImageEnabled","Custom image",false,blackholeLoop)
        field(featureSettings("bhImageEnabled"),"bhImage","Image","9920612764",function() unpatch("blackhole") blackholeLoop() end)
        toggle(b,"bhTintEnabled","Custom color",false,blackholeLoop)
        color(featureSettings("bhTintEnabled"),"bhColor","Color",white,function() unpatch("blackhole") blackholeLoop() end,updateBlackholes)
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
        h=featureSettings("bhSoundEnabled")
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
            -- Reset the autosave as well; named slots remain intact.
            lastProfileBeforeLoad=nil
            discardAutosave=true
            gui:Destroy()
            task.defer(function() startVisuals(false) end)
        end)
        action(g,"Unload script",function()
            if resetting then return end
            resetting=true
            gui:Destroy()
        end)
        action(g,"Open Prime Vortex",function()
            if vortexLaunching or resetting then return end
            vortexLaunching=true
            local wasOpen=Library.Toggled
            local ok,message=pcall(function()
                local env=(getgenv and getgenv()) or shared
                local current=env.PrimeVortexUI
                Library:Toggle(false)
                -- Replace the original flame-only shell instead of reopening its stale preview.
                if type(current)=="table" and (current.Version=="0.1.0" or current.Version=="0.2.0" or current.Version=="0.2.1") and type(current.Unload)=="function" then
                    current:Unload()
                    current=nil
                end
                if type(current)=="table" and not current.Unloaded
                    and type(current.Library)=="table" and not current.Library.Unloaded then
                    current.Library:Toggle(true)
                    return
                end
                local source=game:HttpGet("https://raw.githubusercontent.com/Mengy777/Prime-Script-FTAP/refs/heads/main/PrimeVortex.lua")
                if not alive then return end
                local chunk,compileError=loadstring(source,"PrimeVisuals/PrimeVortex")
                assert(chunk,compileError)
                local opened,launchError,reported=chunk()
                if (type(opened)~="table" or opened.Unloaded) and reported then
                    if alive then Library:Toggle(wasOpen) end
                    return
                end
                assert(type(opened)=="table" and not opened.Unloaded,launchError or "Prime Vortex did not start")
            end)
            vortexLaunching=false
            if not ok then
                warn("Prime Visuals: Prime Vortex launch failed: "..tostring(message))
                if alive then
                    Library:Toggle(wasOpen)
                    notify(uiLanguage=="ru" and "Не удалось открыть Prime Vortex. Попробуй ещё раз."
                        or "Could not open Prime Vortex. Please try again.")
                end
            end
        end)
    end

    do
        local g=group("Settings","Protection",2)
        local protectionStatus=g:AddLabel("Anti-Kick: waiting")
        antiKick=loadUIModule("AntiKick")({Player=player,Workspace=Workspace,Run=Run,
            Storage=game:GetService("ReplicatedStorage"),Status=function(text) protectionStatus:SetText("Anti-Kick: "..text) end})
        toggle(g,"antiKickEnabled","Anti-Kick",true,function(on) antiKick:SetEnabled(on) end)
        g:AddLabel("Self-attached toy protection; cannot cancel server kicks or bans.",true)
        antiKick:SetEnabled(true)
    end

    -- Source-reviewed pack uses the same control registry, profiles, panels and cleanup.
    do
        local lastWarning={}
        visualExpansion=loadUIModule("VisualExpansion")({
            Workspace=Workspace,Players=Players,Run=Run,Input=UIS,Lighting=Lighting,PlayerGui=playerGui,
            Controls=controls,Setters=setters,ColorOwners=colorOwners,Data=loadUIModule("VisualPresets"),
            Group=group,Toggle=toggle,Slider=sliderControl,Color=color,Field=field,Choice=choice,Panel=featureSettings,
            Make=make,Patch=patch,Unpatch=unpatch,Job=job,Action=action,ImageId=imageId,Selected=playerSelected,
            TrackCleanup=function(fn) visualExpansion={Destroy=fn} end,
            MenuOpen=function() return Library.Toggled end,
            WarnOnce=function(name,message)
                if os.clock()-(lastWarning[name] or -math.huge)>=30 then
                    lastWarning[name]=os.clock() warn("Prime Visuals / "..name..": "..tostring(message))
                end
            end,
            GetSky=ensureSky,
            ApplySky=function(data)
                skyLoadGeneration=skyLoadGeneration+1 skyLoadBusy=false
                local sky=ensureSky() skyRecoveryData=nil
                for property,value in pairs(data) do sky[property]=value end
                customSkyLoaded=true onCustomSkyApplied(data) rememberSky() profileChanged()
            end,
        })
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
        local hero=homeTab:AddRightGroupbox("Prime Visuals","sparkles")
        local emblemRow=hero:AddImage("homeEmblem",{Image="rbxassetid://0",Height=240,Transparency=1,
            BackgroundTransparency=1,Color=Color3.new(1,1,1),ScaleType=Enum.ScaleType.Fit})
        local artwork=optionalArtwork({Parent=emblemRow.Holder,Header=nativeWindow.IconHolder,
            Name="VisualsPhoenix",Style="phoenix",Accent=purple,
            URL="https://raw.githubusercontent.com/Mengy777/Prime-Script-FTAP/refs/tags/v"..VERSION.."/assets/visuals-phoenix-v1.png",
            CacheFolder="PrimeVisuals/Assets",Folders={"PrimeVisuals","PrimeVisuals/Assets"},
            CacheName="phoenix-d8d557849ed3-hq.png",Bytes=2068952,
            IsAlive=function() return alive end,IsVisible=function() return Library.Toggled end,
            Notify=function() notify(uiLanguage=="ru" and "Не удалось загрузить PNG превью. Подробности в консоли executor." or "Preview PNG could not load. Details are in the executor console.") end,
        })
        own(artwork.Root)
        if artwork.Unavailable then hero.BoxHolder.Visible=false
        else job("Home emblem",Run.RenderStepped,function(dt) artwork:Step(dt) end) end
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
        local rows={}
        for _,name in ipairs({"fps","frame","ping","memory","players","server","fov","effects","uptime","clock"}) do
            rows[name]=statistics:AddLabel({Text="—",DoesWrap=true})
        end
        local showDetails=false
        for _,name in ipairs({"frame","memory","server","clock"}) do rows[name]:SetVisible(false) end
        action(statistics,"Session details",function()
            showDetails=not showDetails
            for _,name in ipairs({"frame","memory","server","clock"}) do rows[name]:SetVisible(showDetails) end
        end)
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
        hero.BoxHolder.Parent=right hero.BoxHolder.LayoutOrder=0
        statistics.BoxHolder.Parent=right statistics.BoxHolder.LayoutOrder=1
        for _,side in ipairs(homeTab.Sides) do side.Visible=false end
        local statsService
        pcall(function() statsService=game:GetService("Stats") end)
        local masterEffects={"camThird","camNoclip","camBlur","camBody","lightEnabled","skyClouds","particleEnabled",
            "waterEnabled","fpsEnabled","characterEnabled","hatEnabled","mannequinEnabled","espPlayers","espServer","espSticky","espBlackholes",
            "jumpCircleEnabled","bodyTrailEnabled","deathDustEnabled","snowEnabled","boxEnabled","skeletonEnabled","traceEnabled","selfESP","blobESP","antiKickESP","combatESP","revealInvisible","visualPresetEnabled","fullbrightEnabled","smoothCameraEnabled","freeCameraEnabled","spectateEnabled","oceanAppearance","bodyAppearance","holeSprite","serverGhostEnabled","animationEnabled",
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

    local rainbowElapsed=0
    job("Rainbow colors",Run.Heartbeat,function(dt)
        rainbowElapsed=rainbowElapsed+dt
        if rainbowElapsed<1/30 then return end
        rainbowElapsed=rainbowElapsed%(1/30)
        local tint
        for _,state in pairs(rainbowColors) do
            if controls[state.key] and (not state.owner or controls[state.owner]) then
                tint=tint or Color3.fromHSV((os.clock()*0.12)%1,1,1)
                state.animating=true
                transientColorUpdate=true
                local ok,message=pcall(function() state.set(tint,false) state.apply(tint) end)
                state.animating=false
                transientColorUpdate=false
                if not ok then
                    setters[state.key](false,true)
                    warn("Prime Visuals rainbow / "..state.key..": "..tostring(message))
                    notify(uiLanguage=="ru" and "Радужный цвет отключён после ошибки." or "Rainbow color stopped after an error.")
                end
            end
        end
    end)
    building=false
    -- Bind localization to the actual library UI; no duplicate custom control layer.
    for _,object in ipairs(Library.ScreenGui:GetDescendants()) do bindLocalization(object) end
    listen(Library.ScreenGui.DescendantAdded,bindLocalization)
    categoryTabs.Home:Show()
-- PROFILE_BLOCK_START
    do
        local function finite(value) return type(value)=="number" and value==value and math.abs(value)<math.huge end
        local function encode(value,spec)
            if spec.Kind=="ColorPicker" then return {kind="color",r=value.R,g=value.G,b=value.B} end
            if spec.Multi then
                local names={} for name,on in pairs(value) do if on then table.insert(names,name) end end
                table.sort(names)
                return {kind="players",names=names}
            end
            return value
        end
        local function decode(value,spec)
            if spec.Kind=="ColorPicker" then
                assert(type(value)=="table" and value.kind=="color","Invalid color")
                for _,key in ipairs({"r","g","b"}) do assert(finite(value[key]) and value[key]>=0 and value[key]<=1,"Invalid color channel") end
                return Color3.new(value.r,value.g,value.b)
            elseif spec.Multi then
                assert(type(value)=="table" and value.kind=="players" and type(value.names)=="table","Invalid player selection")
                for index in pairs(value.names) do
                    assert(finite(index) and index>=1 and index%1==0 and index<=#value.names,"Invalid player list index")
                end
                local names={}
                for _,name in ipairs(value.names) do
                    assert(type(name)=="string" and #name<=20 and name:match("^[%w_]+$"),"Invalid player name") names[name]=true
                end
                return names
            elseif spec.Kind=="Toggle" then assert(type(value)=="boolean","Invalid toggle")
            elseif spec.Kind=="Slider" then assert(finite(value) and value>=spec.Min and value<=spec.Max,"Slider outside supported range")
            elseif spec.Kind=="Input" then assert(type(value)=="string" and #value<=8192,"Invalid text")
            elseif spec.Kind=="Dropdown" then assert(type(value)=="string" and table.find(spec.Values,value),"Unknown dropdown value")
            else error("Unsupported setting type: "..tostring(spec.Kind)) end
            return value
        end
        local function positionData(position)
            return {xs=position.X.Scale,x=position.X.Offset,ys=position.Y.Scale,y=position.Y.Offset}
        end
        local function readPosition(value)
            assert(type(value)=="table","Invalid window position")
            for _,key in ipairs({"xs","x","ys","y"}) do assert(finite(value[key]),"Invalid window coordinate") end
            assert(math.abs(value.xs)<=2 and math.abs(value.ys)<=2 and math.abs(value.x)<=20000 and math.abs(value.y)<=20000,"Window position outside supported range")
            return UDim2.new(value.xs,value.x,value.ys,value.y)
        end
        validateProfile=function(payload)
            assert(type(payload)=="table" and type(payload.values)=="table" and type(payload.applied)=="table","Invalid profile settings")
            for _,flag in ipairs({"customSky","fovApplied"}) do
                assert(payload[flag]==nil or type(payload[flag])=="boolean","Invalid profile flag")
            end
            local normalized={values={},applied={},sky=payload.sky,customSky=payload.customSky==true,fovApplied=payload.fovApplied==true,ui=payload.ui}
            for key,value in pairs(payload.values) do
                if settingSpecs[key] then normalized.values[key]=decode(value,settingSpecs[key]) end
            end
            for key,value in pairs(payload.applied) do
                if settingSpecs[key] then assert(type(value)=="boolean","Invalid applied setting") normalized.applied[key]=value end
            end
            if payload.sky~=nil then
                assert(type(payload.sky)=="table","Invalid sky data")
                for _,key in ipairs(skyProperties) do assert(type(payload.sky[key])=="string" and #payload.sky[key]<=256,"Invalid sky texture") end
                for _,key in ipairs(importedProperties) do
                    local value=payload.sky[key]
                    if value~=nil then
                        if key=="CelestialBodiesShown" then assert(type(value)=="boolean","Invalid sun state")
                        elseif key=="SunTextureId" or key=="MoonTextureId" then assert(type(value)=="string" and #value<=256,"Invalid celestial texture")
                        else assert(finite(value) and value>=0 and value<=(key=="StarCount" and 100000 or 60),"Invalid sky parameter") end
                    end
                end
            end
            if payload.ui~=nil then
                assert(type(payload.ui)=="table","Invalid UI state")
                if payload.ui.position then readPosition(payload.ui.position) end
                assert(payload.ui.tab==nil or type(payload.ui.tab)=="string","Invalid selected tab")
                if payload.ui.panels then
                    assert(type(payload.ui.panels)=="table","Invalid panel positions")
                    for _,position in pairs(payload.ui.panels) do readPosition(position) end
                end
            end
            return normalized
        end
        captureProfile=function()
            local values,applied,panels={},{},{}
            for _,key in ipairs(settingOrder) do
                local value=controls[key]
                local rainbow=rainbowColors[key]
                if rainbow and controls[rainbow.key] then value=rainbow.manual end
                if key=="espSelectedPlayers" then value=rememberedPlayers end
                values[key]=encode(value,settingSpecs[key])
                if appliedSettings[key] then applied[key]=true end
            end
            local sky
            if activeSky and (customSkyLoaded or appliedSettings.skySun or appliedSettings.skySunVisible) then
                sky={}
                for _,keys in ipairs({skyProperties,importedProperties}) do
                    for _,key in ipairs(keys) do sky[key]=activeSky[key] end
                end
            end
            for key,panel in pairs(featurePanels) do
                local position=(not panel.Docked and panel.Holder and panel.Holder.Visible and panel.Holder.Position) or panel.LastPosition
                if position then panels[key]=positionData(position) end
            end
            local tabName="Home"
            return {values=values,applied=applied,sky=sky,customSky=customSkyLoaded,fovApplied=fovChanged,
                ui={position=positionData(nativeWindow.MainFrame.Position),tab=tabName,panels=panels}}
        end
        profileStore=loadUIModule("ConfigStore")({HttpService=game:GetService("HttpService"),UserId=player.UserId,Version=VERSION,
            Validate=function(payload) validateProfile(payload) end})
        local configs=group("Settings","Configurations",2)
        local status=configs:AddLabel("Autosave: ready")
        local selectedSlot=1
        local labels={}
        local slotWidget,nameWidget,previewLabel
        local overwriteConfirmation
        local function sameData(a,b)
            if type(a)~=type(b) then return false end
            if type(a)~="table" then return a==b end
            for key,value in pairs(a) do if not sameData(value,b[key]) then return false end end
            for key in pairs(b) do if a[key]==nil then return false end end
            return true
        end
        local function refreshPreview()
            if not previewLabel then return end
            local payload,name=profileStore:ReadSlot(selectedSlot)
            if not payload then previewLabel:SetText("Empty slot") return end
            local current=captureProfile()
            local differences=0
            for key in pairs(settingSpecs) do
                if not sameData(payload.values[key],current.values[key]) then differences=differences+1 end
            end
            if not sameData(payload.sky,current.sky) then differences=differences+1 end
            previewLabel:SetText(tostring(name).." · "..tostring(differences)..(uiLanguage=="ru" and " отличий" or " changes"))
        end
        local function report(message)
            local text=tostring(message):gsub("^.-:%d+:%s*","")
            if uiLanguage=="ru" then
                for _,key in ipairs({"Enter a name of 1–160 bytes","This slot is empty or unreadable","Unsupported config format","Config file is too large","Invalid profile settings","Slider outside supported range","Unknown dropdown value","Use a JSON filename inside PrimeVisuals/Imports","Config write verification failed","A write to this config is already in progress; try again","Invalid color channel","Invalid toggle","Invalid sky texture","Window position outside supported range","Invalid profile flag"}) do
                    if text:find(key,1,true) then text=ru[key] break end
                end
            end
            notify((uiLanguage=="ru" and "Конфиги: " or "Configs: ")..text)
        end
        local function refreshSlots()
            local names=profileStore:SlotNames()
            for i=1,5 do labels[i]=tostring(i).." — "..(names[i]~="" and names[i] or "—") end
            if slotWidget then slotWidget:SetValues(labels) slotWidget:SetValue(labels[selectedSlot]) end
            if nameWidget then nameWidget:SetValue(names[selectedSlot] or "") end
            overwriteConfirmation=nil
            refreshPreview()
        end
        refreshSlots()
        slotWidget=configs:AddDropdown("profileSlot",{Text="Slot",Values=labels,Default=1,AllowNull=false,
            Callback=function(value)
                if type(value)~="string" then return end
                selectedSlot=tonumber(value:match("^(%d+)")) or 1
                if nameWidget then nameWidget:SetValue(profileStore:SlotNames()[selectedSlot] or "") end
                overwriteConfirmation=nil
                refreshPreview()
            end})
        nameWidget=configs:AddInput("profileName",{Text="Config name",Default=profileStore:SlotNames()[1] or "",Finished=false,Callback=function() end})
        previewLabel=configs:AddLabel({Text="Empty slot",DoesWrap=true})
        refreshPreview()
        local function confirmSlotWrite(operation)
            local name=profileStore:SlotNames()[selectedSlot]
            if name=="" then overwriteConfirmation=nil return true end
            if overwriteConfirmation and overwriteConfirmation.slot==selectedSlot
                and overwriteConfirmation.operation==operation and overwriteConfirmation.name==name
                and os.clock()<=overwriteConfirmation.expires then
                overwriteConfirmation=nil return true
            end
            overwriteConfirmation={slot=selectedSlot,operation=operation,name=name,expires=os.clock()+6}
            local verb=operation=="delete" and (uiLanguage=="ru" and "удалить" or "delete")
                or (uiLanguage=="ru" and "перезаписать" or "overwrite")
            report(uiLanguage=="ru" and ("Нажми кнопку ещё раз в течение 6 секунд, чтобы "..verb.." «"..name.."».")
                or ("Click the same button again within 6 seconds to "..verb.." '"..name.."'."))
            return false
        end
        local function requireFiles()
            if profileStore.Available then return true end
            report(uiLanguage=="ru" and "Executor не предоставляет доступ к локальным файлам." or "Executor does not provide local file access.")
            return false
        end
        action(configs,"Save to slot",function()
            if not requireFiles() then return end
            if not confirmSlotWrite("save") then return end
            local ok,message=profileStore:SaveSlot(selectedSlot,nameWidget.Value,captureProfile())
            if not ok then report(message) return end
            refreshSlots() report(uiLanguage=="ru" and "Конфиг сохранён." or "Config saved.")
        end)
        action(configs,"Load slot",function()
            if not requireFiles() then return end
            local payload,message=profileStore:ReadSlot(selectedSlot)
            if not payload then report(message) return end
            local valid,validationError=pcall(validateProfile,payload)
            if not valid then report(validationError) return end
            lastProfileBeforeLoad=captureProfile()
            discardAutosave=true
            gui:Destroy()
            task.defer(function() startVisuals(payload) end)
        end)
        action(configs,"Undo last config load",function()
            if not lastProfileBeforeLoad then
                report(uiLanguage=="ru" and "В этой сессии ещё нечего отменять." or "No config load to undo in this session.")
                return
            end
            local previous=lastProfileBeforeLoad
            validateProfile(previous)
            lastProfileBeforeLoad=nil
            discardAutosave=true
            gui:Destroy()
            task.defer(function() startVisuals(previous) end)
        end)
        action(configs,"Delete slot",function()
            if not requireFiles() then return end
            if not confirmSlotWrite("delete") then return end
            local ok,message=profileStore:DeleteSlot(selectedSlot)
            if not ok then report(message) return end
            refreshSlots() report(uiLanguage=="ru" and "Слот очищен." or "Slot cleared.")
        end)
        local transfer=group("Settings","Import / export",2)
        action(transfer,"Copy folder path",function()
            if type(setclipboard)=="function" then setclipboard(profileStore.Root)
            else report(profileStore.Root) end
        end)
        action(transfer,"Export selected slot",function()
            if not requireFiles() then return end
            local path,message=profileStore:Export(selectedSlot)
            if not path then report(message) return end
            if type(setclipboard)=="function" then pcall(setclipboard,path) end
            report(path)
        end)
        transfer:AddLabel({Text="Put shared JSON files in PrimeVisuals/Imports",DoesWrap=true})
        local importFile=transfer:AddInput("profileImportFile",{Text="Import filename",Default="friend.json",Finished=false,Callback=function() end})
        action(transfer,"Import into selected slot",function()
            if not requireFiles() then return end
            if not confirmSlotWrite("import") then return end
            local ok,message=profileStore:Import(selectedSlot,importFile.Value)
            if not ok then report(message) return end
            refreshSlots() report(uiLanguage=="ru" and "Конфиг импортирован. Нажми «Загрузить слот»." or "Config imported. Select Load slot to apply it.")
        end)
        local warned=false
        local savingProfile=false
        local saveRetryDelay=1
        local finalQueuedProfile
        flushProfile=function(force)
            if not profileStore.Available or restoringProfile or building or discardAutosave or (not profileDirty and not force) then return end
            if savingProfile then
                if force then finalQueuedProfile={data=captureProfile(),generation=profileGeneration} end
                return
            end
            savingProfile=true
            local payload,generation=captureProfile(),profileGeneration
            local ok,message
            repeat
                ok,message=profileStore:WriteAuto(payload)
                profileDirty=not ok or profileGeneration~=generation
                if finalQueuedProfile then
                    payload,generation=finalQueuedProfile.data,finalQueuedProfile.generation
                    finalQueuedProfile=nil
                else break end
            until false
            savingProfile=false
            if alive and not Library.Unloaded then
                if ok then warned=false saveRetryDelay=1 status:SetText("Autosave: saved") refreshPreview()
                else
                    status:SetText("Autosave: error")
                    if not warned then warned=true report(message) end
                    if not profileSaveScheduled then
                        profileSaveScheduled=true
                        local retryAfter=saveRetryDelay
                        saveRetryDelay=math.min(saveRetryDelay*2,30)
                        task.delay(retryAfter,function()
                            profileSaveScheduled=false
                            if alive and profileDirty then flushProfile() end
                        end)
                    end
                end
                -- An edit during a yielding file write must not be cleared with the older snapshot.
                if ok and profileDirty and not profileSaveScheduled then profileChanged() end
            elseif not ok then warn("Prime Visuals final save: "..tostring(message)) end
        end
        if not profileStore.Available then status:SetText("Autosave: unavailable") end
        local function applyProfile(payload)
            local profile=validateProfile(payload)
            -- Untouched/reset defaults follow the new session's actual game state.
            if not profile.fovApplied then profile.values.cameraFOV=settingSpecs.cameraFOV.Default end
            if not profile.applied.skyTime then profile.values.skyTime=settingSpecs.skyTime.Default end
            if not profile.sky then
                for _,key in ipairs({"skySunVisible","skySun"}) do
                    if not profile.applied[key] then profile.values[key]=settingSpecs[key].Default end
                end
            end
            restoringProfile=true
            -- Restore resolved sky before applying saved sun/cloud choices, without a network fetch.
            if profile.sky then
                local sky=ensureSky()
                skyRecoveryData=nil
                for _,keys in ipairs({skyProperties,importedProperties}) do
                    for _,key in ipairs(keys) do if profile.sky[key]~=nil then sky[key]=profile.sky[key] end end
                end
                customSkyLoaded=profile.customSky
                if customSkyLoaded then onCustomSkyApplied(profile.sky) end
            end
            -- Stage all non-toggle values before enabling effects. Never re-run action buttons.
            for _,key in ipairs(settingOrder) do
                local value=profile.values[key]
                if value~=nil then
                    if settingSpecs[key].Kind=="Toggle" then setters[key](false,false)
                    else setters[key](value,false) end
                end
            end
            rememberedPlayers=profile.values.espSelectedPlayers or {}
            for _,key in ipairs(settingOrder) do
                local value=profile.values[key]
                if value~=nil and settingSpecs[key].Kind~="Toggle" and key~="espSelectedPlayers"
                    and (profile.applied[key] or key=="uiLanguage" or (key=="cameraFOV" and profile.fovApplied)) then
                    if key~="cameraFOV" or profile.fovApplied then setters[key](value,true) end
                end
            end
            for _,key in ipairs(settingOrder) do
                local value=profile.values[key]
                if value~=nil and settingSpecs[key].Kind=="Toggle" then
                    local spec=settingSpecs[key]
                    local apply=value or profile.applied[key] or value~=spec.Default
                    -- An untouched default sun must not create a custom sky on a clean game.
                    if key=="skySunVisible" then apply=profile.sky~=nil or profile.applied[key] end
                    setters[key](value,apply)
                end
            end
            if profile.ui then
                if profile.ui.position then
                    local main=nativeWindow.MainFrame
                    local position=readPosition(profile.ui.position)
                    local camera=Workspace.CurrentCamera
                    local reachable=true
                    if camera and main.AbsoluteSize and main.AnchorPoint then
                        local viewport=camera.ViewportSize
                        local x=viewport.X*position.X.Scale+position.X.Offset-main.AbsoluteSize.X*main.AnchorPoint.X
                        local y=viewport.Y*position.Y.Scale+position.Y.Offset-main.AbsoluteSize.Y*main.AnchorPoint.Y
                        reachable=x+main.AbsoluteSize.X>=40 and x<=viewport.X-40 and y>=0 and y<=viewport.Y-30
                    end
                    if reachable then main.Position=position end
                end
                for key,position in pairs(profile.ui.panels or {}) do
                    if featurePanels[key] then featurePanels[key].LastPosition=readPosition(position) end
                end
                -- Startup always remains on Home, including autosave, slots and undo.
            end
            appliedSettings=profile.applied
            rememberSky()
            restoringProfile=false
        end
        local payload,readError
        if profileOverride~=false then
            if type(profileOverride)=="table" then payload=profileOverride
            else payload,readError=profileStore:ReadAuto() end
        end
        -- Home stays the launch page; profiles restore settings and panel positions.
        building=false
        if payload then
            local ok,message=pcall(applyProfile,payload)
            restoringProfile=false
            if not ok then
                -- Preserve the stored file for recovery; do not overwrite rejected data on startup.
                profileDirty=false
                discardAutosave=true
                status:SetText("Autosave: error")
                report(message)
            else profileDirty=true end
        elseif readError then
            discardAutosave=true status:SetText("Autosave: error") report(readError)
        elseif profileStore.Available then profileDirty=true end
        if profileDirty then flushProfile() end
        listen(nativeWindow.MainFrame:GetPropertyChangedSignal("Position"),function() profileChanged() end)
        for _,panel in pairs(featurePanels) do
            if panel.Holder and not panel.Docked then listen(panel.Holder:GetPropertyChangedSignal("Position"),function() profileChanged() end) end
        end
        -- Saving on game shutdown is best-effort; normal changes are already written after 0.4s.
        listen(Players.PlayerRemoving,function(leaving) if leaving==player then flushProfile(true) end end)
    end
-- PROFILE_BLOCK_END

    -- Recreate only enabled effects whose game-owned containers were cleared/replaced.
    local maintenanceElapsed=0
    local maintenanceWarnings={}
    job("Visual maintenance",Run.Heartbeat,function(dt)
        maintenanceElapsed=maintenanceElapsed+dt
        if maintenanceElapsed<1 then return end
        maintenanceElapsed=maintenanceElapsed%1
        for name,recover in pairs(maintenance) do
            local ok,message=pcall(recover)
            if not ok and os.clock()-(maintenanceWarnings[name] or -math.huge)>=30 then
                maintenanceWarnings[name]=os.clock()
                warn("Prime Visuals recovery / "..name..": "..tostring(message))
            end
        end
    end)
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
            if controls.lineEnabled then applyLine() end
            if controls.waterEnabled and controls.waterSolid then updateSwimming() end
        end)
    end)

end
local function shutdown()
    if closing then return end
    closing=true
    startup.Alive=false
    if not discardAutosave then flushProfile(true) end
    cleanupExtra()
    restoreSky()
    pcall(function() RunService:UnbindFromRenderStep(Library.ShowCursorBinding) end)
    if not Library.Unloaded then
        Library:Toggle(false)
        Library:Unload()
    end
    for _,connection in ipairs(connections) do connection:Disconnect() end
    UIS.MouseBehavior,UIS.MouseIconEnabled=savedBehavior,savedIcon
    for camera,value in pairs(originalCameraFOVs) do
        pcall(function() camera.FieldOfView=value end)
    end
end
gui.Destroying:Connect(shutdown)
Library:OnUnload(function() if not closing and gui.Parent then gui:Destroy() end end)
local prepared,prepareError=xpcall(buildVisualSystems,debug.traceback)
if not prepared then
    if startup.Alive then startup.Failed=true end
    discardAutosave=true
    gui:Destroy()
    error(prepareError,0)
end
if not closing and gui.Parent then
    Library:Toggle(true)
    menuOpen=true
end
end
local ok,message=xpcall(run,debug.traceback)
if not ok then
    local cancelled=not startup.Alive and not startup.Failed
    cleanupFailedStartup(startup)
    if not cancelled then reportStartupFailure("Prime Visuals",message) end
    return nil,message
end
return true
end
startVisuals()
