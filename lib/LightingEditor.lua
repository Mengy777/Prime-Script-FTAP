-- Manual lighting editor. Every parameter uses the shared profile/property lifecycle.
return function(c)
    local L,v,S=c.Lighting,c.Controls,c.Setters
    local patch,unpatch=c.Patch,c.Unpatch
    local effects,defaults,colors,ranges={},{},{},{}
    local white=Color3.new(1,1,1)
    local editing=false
    -- Preserve this client's native SunRays spread rather than guessing its default.
    local rayPrototype=c.Create("SunRaysEffect",{Enabled=false})
    local defaultSpread=rayPrototype.Spread or .1
    c.Dispose(rayPrototype)
    local translations={
        ["Basic"]="Цвет",["Light"]="Свет",["Air"]="Воздух",["Effects"]="Эффекты",["Focus"]="Фокус",
        ["Environment controls"]="Свет и туман",["Atmosphere controls"]="Атмосфера",["Depth of field"]="Глубина резкости",
        ["Replace game effects"]="Заменить игровые фильтры",["Color brightness"]="Яркость цветокоррекции",
        ["Ambient light"]="Свет в тени",["Outdoor light"]="Наружный свет",["Upper light color"]="Верхний оттенок",
        ["Lower light color"]="Нижний оттенок",["Fog color"]="Цвет тумана",["Fog start"]="Начало тумана",["Fog end"]="Конец тумана",
        ["Sun latitude"]="Наклон солнца",["Shadows"]="Тени",["Shadow softness"]="Мягкость теней",
        ["Diffuse light"]="Рассеянный свет",["Reflections"]="Отражения",["Air density"]="Плотность атмосферы",
        ["Air offset"]="Смещение атмосферы",["Air color"]="Цвет атмосферы",["Air decay"]="Цвет рассеивания",
        ["Air glare"]="Свечение атмосферы",["Air haze"]="Дымка атмосферы",["Bloom size"]="Размер свечения",
        ["Bloom threshold"]="Порог свечения",["Ray spread"]="Ширина лучей",["Focus distance"]="Расстояние фокуса",
        ["Focus radius"]="Область резкости",["Near blur"]="Размытие вблизи",["Far blur"]="Размытие вдали",
        ["Edit selected preset"]="Редактировать выбранный пресет",
    }
    for en,ru in pairs(translations) do c.Translations[en]=ru end
    local env={
        lightClock="ClockTime",lightLatitude="GeographicLatitude",lightAmbient="Ambient",lightOutdoor="OutdoorAmbient",
        lightUpper="ColorShift_Top",lightLower="ColorShift_Bottom",lightFogColor="FogColor",lightFogStart="FogStart",lightFogEnd="FogEnd",
        lightShadows="GlobalShadows",lightSoftness="ShadowSoftness",lightDiffuse="EnvironmentDiffuseScale",lightSpecular="EnvironmentSpecularScale",
    }
    local air={lightAirDensity="Density",lightAirOffset="Offset",lightAirColor="Color",lightAirDecay="Decay",lightAirGlare="Glare",lightAirHaze="Haze"}
    local effectFields={
        Color={Class="ColorCorrectionEffect",Fields={lightColorBrightness="Brightness",lightSaturation="Saturation",lightContrast="Contrast",lightTint="TintColor"}},
        Bloom={Class="BloomEffect",Fields={lightBloom="Intensity",lightBloomSize="Size",lightBloomThreshold="Threshold"}},
        Rays={Class="SunRaysEffect",Fields={lightRays="Intensity",lightRaySpread="Spread"}},
        SoftBlur={Class="BlurEffect",Fields={lightBlur="Size"}},
        Depth={Class="DepthOfFieldEffect",Fields={lightFocusDistance="FocusDistance",lightFocusRadius="InFocusRadius",lightNearBlur="NearIntensity",lightFarBlur="FarIntensity"}},
    }
    local function effect(name,class)
        local o=effects[name]
        if o and o.Parent~=L then c.Dispose(o) effects[name]=nil o=nil end
        if not o then o=c.Create(class,{Name="PV_"..name,Enabled=false},L) effects[name]=o end
        return o
    end
    local function releaseAir()
        unpatch("shaderAir")
        if effects.Air then c.Dispose(effects.Air) effects.Air=nil end
    end
    local function apply(on)
        if not on then
            unpatch("shader") unpatch("shaderEnvironment") unpatch("shaderReplace") releaseAir()
            for name,o in pairs(effects) do if name~="Air" then o.Enabled=false end end
            if c.EnforceHaze then c.EnforceHaze() end
            return
        end
        patch("shader",L,"Brightness",v.lightBrightness or 2)
        patch("shader",L,"ExposureCompensation",v.lightExposure or 0)
        if v.lightEnvironment then
            for key,property in pairs(env) do
                local value=v[key]
                if property=="FogEnd" then value=math.max(value,v.lightFogStart) end
                if not (c.HazeActive() and (property=="FogStart" or property=="FogEnd")) then patch("shaderEnvironment",L,property,value) end
            end
        else unpatch("shaderEnvironment") end
        if v.lightReplaceEffects then
            for _,o in ipairs(L:GetChildren()) do
                if o:IsA("PostEffect") and not o.Name:match("^PV_") then patch("shaderReplace",o,"Enabled",false) end
            end
        else unpatch("shaderReplace") end
        for name,definition in pairs(effectFields) do
            local enabled=name~="Depth" or v.lightDepth
            local o=effects[name]
            if enabled then
                o=effect(name,definition.Class)
                for key,property in pairs(definition.Fields) do o[property]=v[key] end
                o.Enabled=name~="SoftBlur" or v.lightBlur>0
            elseif o then o.Enabled=false end
        end
        if v.lightAtmosphere and not c.HazeActive() then
            if effects.Air and effects.Air.Parent~=L then c.Dispose(effects.Air) effects.Air=nil end
            for _,o in ipairs(L:GetChildren()) do
                if o:IsA("Atmosphere") and o~=effects.Air then
                    patch("shaderAir",o,"Density",0) patch("shaderAir",o,"Haze",0) patch("shaderAir",o,"Glare",0)
                end
            end
            if not effects.Air then effects.Air=c.Create("Atmosphere",{Name="PV_ManualAtmosphere"},L) end
            for key,property in pairs(air) do effects.Air[property]=v[key] end
        else releaseAir() end
        if c.EnforceHaze then c.EnforceHaze() end
    end
    local function update() if not editing and v.lightEnabled then apply(true) end end
    local function slider(g,key,text,low,high,initial,step)
        defaults[key]=initial ranges[key]={low,high} c.Slider(g,key,text,low,high,initial,step,update)
    end
    local function toggle(g,key,text,initial)
        defaults[key]=initial c.Toggle(g,key,text,initial,update)
    end
    local function color(g,key,text,initial,target)
        defaults[key]=initial colors[key]=true c.ColorOwners[key]="lightEnabled"
        c.Color(g,key,text,initial,update,function(value)
            if not v.lightEnabled then return end
            if env[key] then if v.lightEnvironment then patch("shaderEnvironment",L,env[key],value) end
            elseif air[key] then if effects.Air and v.lightAtmosphere then effects.Air[air[key]]=value end
            elseif effects[target] then effects[target][effectFields[target].Fields[key]]=value end
        end)
    end
    local g=c.Group("Lighting","Color and light",1)
    c.Toggle(g,"lightEnabled","Shaders",false,apply)
    local panel=c.Panel("lightEnabled")
    local basic=panel:AddPage("Basic") local light=panel:AddPage("Light") local atmosphere=panel:AddPage("Air")
    local fx=panel:AddPage("Effects") local focus=panel:AddPage("Focus")
    slider(basic,"lightBrightness","Brightness",0,10,2,.05)
    slider(basic,"lightExposure","Exposure",-5,5,0,.05)
    slider(basic,"lightColorBrightness","Color brightness",-1,1,0,.01)
    slider(basic,"lightSaturation","Saturation",-1,1,.15,.05)
    slider(basic,"lightContrast","Contrast",-1,1,.05,.05)
    color(basic,"lightTint","Tint",white,"Color")
    toggle(basic,"lightReplaceEffects","Replace game effects",false)
    toggle(light,"lightEnvironment","Environment controls",false)
    slider(light,"lightClock","Time of day",0,24,L.ClockTime or 12,.1)
    slider(light,"lightLatitude","Sun latitude",-90,90,L.GeographicLatitude or 41.7,.1)
    color(light,"lightAmbient","Ambient light",L.Ambient or Color3.fromRGB(70,70,70))
    color(light,"lightOutdoor","Outdoor light",L.OutdoorAmbient or Color3.fromRGB(70,70,70))
    color(light,"lightUpper","Upper light color",L.ColorShift_Top or Color3.new())
    color(light,"lightLower","Lower light color",L.ColorShift_Bottom or Color3.new())
    toggle(light,"lightShadows","Shadows",L.GlobalShadows~=false)
    slider(light,"lightSoftness","Shadow softness",0,1,L.ShadowSoftness or .5,.01)
    slider(light,"lightDiffuse","Diffuse light",0,1,L.EnvironmentDiffuseScale or 0,.01)
    slider(light,"lightSpecular","Reflections",0,1,L.EnvironmentSpecularScale or 0,.01)
    color(light,"lightFogColor","Fog color",L.FogColor or white)
    slider(light,"lightFogStart","Fog start",0,100000,math.clamp(L.FogStart or 0,0,100000),1)
    slider(light,"lightFogEnd","Fog end",0,100000,math.clamp(L.FogEnd or 100000,0,100000),1)
    toggle(atmosphere,"lightAtmosphere","Atmosphere controls",false)
    slider(atmosphere,"lightAirDensity","Air density",0,1,.3,.01)
    slider(atmosphere,"lightAirOffset","Air offset",-1,1,.25,.01)
    color(atmosphere,"lightAirColor","Air color",Color3.fromRGB(199,199,199))
    color(atmosphere,"lightAirDecay","Air decay",Color3.fromRGB(106,112,125))
    slider(atmosphere,"lightAirGlare","Air glare",0,10,0,.05)
    slider(atmosphere,"lightAirHaze","Air haze",0,10,0,.05)
    slider(fx,"lightBloom","Bloom",0,5,.25,.05)
    slider(fx,"lightBloomSize","Bloom size",0,56,24,.5)
    slider(fx,"lightBloomThreshold","Bloom threshold",0,5,1,.05)
    slider(fx,"lightRays","Sun rays",0,1,.03,.01)
    slider(fx,"lightRaySpread","Ray spread",0,1,defaultSpread,.01)
    slider(fx,"lightBlur","Blur",0,56,0,.5)
    toggle(focus,"lightDepth","Depth of field",false)
    slider(focus,"lightFocusDistance","Focus distance",0,1000,50,1)
    slider(focus,"lightFocusRadius","Focus radius",0,1000,30,1)
    slider(focus,"lightNearBlur","Near blur",0,1,0,.01)
    slider(focus,"lightFarBlur","Far blur",0,1,.5,.01)
    local function stage(values)
        editing=true
        local ok,message=pcall(function()
            for key in pairs(colors) do if S[key.."Rainbow"] then S[key.."Rainbow"](false,false) end end
            for key,initial in pairs(defaults) do
                local value=initial if values and values[key]~=nil then value=values[key] end
                if ranges[key] then value=math.clamp(value,ranges[key][1],ranges[key][2]) end
                S[key](value,false)
            end
        end)
        editing=false if not ok then error(message,0) end
    end
    c.Action(basic,"Reset filters",function() S.lightEnabled(false,true) stage() end)
    local editor={Apply=apply}
    function editor:Import(data,name)
        assert(type(data)=="table","Preset is unavailable")
        S.visualPresetEnabled(false,true) S.lightEnabled(false,true)
        if v.fullbrightEnabled then S.fullbrightEnabled(false,true) end
        local values={lightEnvironment=true,lightReplaceEffects=name=="Pale Frost",lightAtmosphere=false,lightDepth=false}
        for key,property in pairs(env) do
            local value=data.light and data.light[property]
            if value==nil then value=L[property] end
            if value~=nil then values[key]=value end
        end
        values.lightBrightness=(data.light or {}).Brightness or L.Brightness
        values.lightExposure=(data.light or {}).ExposureCompensation or L.ExposureCompensation
        -- Absent effects must not pick up the old editor's values.
        values.lightSaturation=0 values.lightContrast=0 values.lightBloom=0 values.lightRays=0
        local byClass={}
        for _,definition in ipairs(data.effects or {}) do byClass[definition[1]]=definition[2] end
        for name,definition in pairs(effectFields) do
            local props=byClass[definition.Class]
            if props then
                for key,property in pairs(definition.Fields) do if props[property]~=nil then values[key]=props[property] end end
                if name=="Depth" then values.lightDepth=true end
            end
        end
        values.lightBloomSize=math.clamp(values.lightBloomSize or 24,0,56)
        local props=byClass.Atmosphere
        if props then values.lightAtmosphere=true for key,property in pairs(air) do if props[property]~=nil then values[key]=props[property] end end end
        stage(values)
        if data.sky then
            c.ApplySky(data.sky)
            S.skySun(math.clamp(data.sky.SunAngularSize or 21,0,60),false)
            S.skySunVisible(data.sky.CelestialBodiesShown~=false and (data.sky.SunAngularSize or 21)>0,true)
        end
        S.lightEnabled(true,true)
        if type(panel.Open)=="function" then panel:Open() end
    end
    return editor
end
