-- Source-reviewed configuration values. See docs/Shader-Catalog-Sources.json.
local catalog={}
local classes={Bloom="BloomEffect",Blur="BlurEffect",CC="ColorCorrectionEffect",ColorCorrection="ColorCorrectionEffect",SunRays="SunRaysEffect",Atmosphere="Atmosphere",DepthOfField="DepthOfFieldEffect"}
local function add(source,name,raw,flat)
    local data={source=source,light=raw.Lighting or {},effects={},sky=raw.Sky,clouds=raw.Clouds}
    if flat then for k,value in pairs(raw) do if not classes[k] then data.light[k]=value end end end
    for _,key in ipairs({"Bloom","Blur","CC","ColorCorrection","SunRays","Atmosphere","DepthOfField"}) do
        local props=raw[key]
        if props then
            if props.Tint then props.TintColor=props.Tint props.Tint=nil end
            data.effects[#data.effects+1]={classes[key],props}
        end
    end
    catalog[source.." / "..name]=data
end
do local item={
name = "Morning",
data = {
Lighting = {
ClockTime = 7,
Brightness = 1.8,
Ambient = Color3.fromRGB(180, 190, 220),
OutdoorAmbient = Color3.fromRGB(180, 190, 220),
ColorShift_Top = Color3.fromRGB(255, 200, 150),
},
Bloom = { Intensity = 0.5, Size = 20, Threshold = 1 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Midday",
data = {
Lighting = {
ClockTime = 14,
Brightness = 2.5,
Ambient = Color3.fromRGB(200, 210, 240),
OutdoorAmbient = Color3.fromRGB(200, 210, 240),
ColorShift_Top = Color3.fromRGB(255, 255, 255),
},
Bloom = { Intensity = 0.3, Size = 18, Threshold = 1.2 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Afternoon",
data = {
Lighting = {
ClockTime = 16,
Brightness = 2,
Ambient = Color3.fromRGB(200, 170, 150),
OutdoorAmbient = Color3.fromRGB(200, 170, 150),
ColorShift_Top = Color3.fromRGB(255, 200, 150),
},
Bloom = { Intensity = 0.4, Size = 22, Threshold = 1 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Evening",
data = {
Lighting = {
ClockTime = 18.5,
Brightness = 1.5,
Ambient = Color3.fromRGB(150, 100, 80),
OutdoorAmbient = Color3.fromRGB(150, 100, 80),
ColorShift_Top = Color3.fromRGB(255, 150, 100),
ColorShift_Bottom = Color3.fromRGB(200, 100, 50),
},
Bloom = { Intensity = 0.6, Size = 25, Threshold = 0.8 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Night",
data = {
Lighting = {
ClockTime = 22,
Brightness = 0.3,
Ambient = Color3.fromRGB(30, 30, 50),
OutdoorAmbient = Color3.fromRGB(30, 30, 50),
ColorShift_Top = Color3.fromRGB(20, 30, 50),
},
Bloom = { Intensity = 0.1, Size = 15, Threshold = 2 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Midnight",
data = {
Lighting = {
ClockTime = 0,
Brightness = 0.1,
Ambient = Color3.fromRGB(10, 10, 30),
OutdoorAmbient = Color3.fromRGB(10, 10, 30),
ColorShift_Top = Color3.fromRGB(10, 10, 30),
},
Bloom = { Intensity = 0.05, Size = 10, Threshold = 3 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Rain",
data = {
Lighting = {
ClockTime = 12,
Brightness = 0.6,
Ambient = Color3.fromRGB(80, 80, 100),
OutdoorAmbient = Color3.fromRGB(80, 80, 100),
},
Atmosphere = {
Density = 0.8,
Offset = 0.5,
Color = Color3.fromRGB(150, 150, 180),
Decay = Color3.fromRGB(100, 100, 150),
Glare = 0.1,
Haze = 5,
},
Clouds = { Cover = 0.9, Density = 0.9 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Snow",
data = {
Lighting = {
ClockTime = 12,
Brightness = 0.8,
Ambient = Color3.fromRGB(180, 190, 210),
OutdoorAmbient = Color3.fromRGB(180, 190, 210),
},
Clouds = { Cover = 0.8, Density = 0.7 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Fog",
data = {
Lighting = {
ClockTime = 12,
Brightness = 1,
Ambient = Color3.fromRGB(180, 180, 190),
OutdoorAmbient = Color3.fromRGB(180, 180, 190),
FogEnd = 100,
FogColor = Color3.fromRGB(180, 180, 190),
FogStart = 20,
},
Atmosphere = { Density = 0.6, Haze = 8, Color = Color3.fromRGB(180, 180, 200) },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Sunny",
data = {
Lighting = {
ClockTime = 13,
Brightness = 3,
Ambient = Color3.fromRGB(220, 230, 255),
OutdoorAmbient = Color3.fromRGB(220, 230, 255),
GlobalShadows = true,
FogEnd = 100000,
FogStart = 0,
FogColor = Color3.fromRGB(255, 255, 255),
},
SunRays = { Intensity = 0.3, Spread = 0.6 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Cloudy",
data = {
Lighting = {
ClockTime = 13,
Brightness = 0.8,
Ambient = Color3.fromRGB(150, 160, 180),
OutdoorAmbient = Color3.fromRGB(150, 160, 180),
},
Clouds = { Cover = 0.7, Density = 0.5 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Storm",
data = {
Lighting = {
ClockTime = 14,
Brightness = 0.3,
Ambient = Color3.fromRGB(50, 50, 70),
OutdoorAmbient = Color3.fromRGB(50, 50, 70),
},
Clouds = { Cover = 1, Density = 0.9 },
Atmosphere = { Density = 0.9, Haze = 6 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Autumn",
data = {
Lighting = {
ClockTime = 16,
Brightness = 1.3,
Ambient = Color3.fromRGB(200, 160, 120),
OutdoorAmbient = Color3.fromRGB(200, 160, 120),
ColorShift_Top = Color3.fromRGB(255, 180, 100),
ColorShift_Bottom = Color3.fromRGB(180, 100, 50),
},
Bloom = { Intensity = 0.3, Size = 20 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Spring",
data = {
Lighting = {
ClockTime = 13,
Brightness = 2,
Ambient = Color3.fromRGB(200, 220, 200),
OutdoorAmbient = Color3.fromRGB(200, 220, 200),
ColorShift_Top = Color3.fromRGB(200, 255, 200),
},
Bloom = { Intensity = 0.2, Size = 15 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Summer",
data = {
Lighting = {
ClockTime = 14,
Brightness = 2.8,
Ambient = Color3.fromRGB(220, 230, 250),
OutdoorAmbient = Color3.fromRGB(220, 230, 250),
ColorShift_Top = Color3.fromRGB(255, 255, 255),
},
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Winter",
data = {
Lighting = {
ClockTime = 12,
Brightness = 1.2,
Ambient = Color3.fromRGB(200, 210, 230),
OutdoorAmbient = Color3.fromRGB(200, 210, 230),
ColorShift_Top = Color3.fromRGB(220, 230, 250),
},
Bloom = { Intensity = 0.1, Size = 12 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Red Theme",
data = {
Lighting = {
Ambient = Color3.fromRGB(80, 20, 20),
OutdoorAmbient = Color3.fromRGB(80, 20, 20),
ColorShift_Top = Color3.fromRGB(255, 50, 50),
FogEnd = 100000,
FogStart = 0,
},
ColorCorrection = { Saturation = 0.5, Brightness = 0.2 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Green Theme",
data = {
Lighting = {
Ambient = Color3.fromRGB(20, 80, 20),
OutdoorAmbient = Color3.fromRGB(20, 80, 20),
ColorShift_Top = Color3.fromRGB(50, 255, 50),
FogEnd = 100000,
FogStart = 0,
},
ColorCorrection = { Saturation = 0.5, Brightness = 0.2 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Blue Theme",
data = {
Lighting = {
Ambient = Color3.fromRGB(20, 40, 80),
OutdoorAmbient = Color3.fromRGB(20, 40, 80),
ColorShift_Top = Color3.fromRGB(50, 100, 255),
FogEnd = 100000,
FogStart = 0,
},
ColorCorrection = { Saturation = 0.5, Brightness = 0.2 },
},
} add("Mercury",item.name,item.data) end
do local item={
name = "Black & White",
data = {
Lighting = { FogEnd = 100000, FogStart = 0 },
ColorCorrection = { Saturation = -1 },
},
} add("Mercury",item.name,item.data) end
add("SAVITAR","Scarlet Atmosphere",{
Lighting = {
Brightness = 2.14,
ColorShift_Bottom = Color3.fromRGB(11, 0, 20),
ColorShift_Top = Color3.fromRGB(240, 127, 14),
OutdoorAmbient = Color3.fromRGB(34, 0, 49),
ClockTime = 6.7,
FogColor = Color3.fromRGB(94, 76, 106),
FogEnd = 1000,
FogStart = 0,
ExposureCompensation = 0.24,
ShadowSoftness = 0,
Ambient = Color3.fromRGB(59, 33, 27),
},
Bloom = {
Intensity = 0.1,
Threshold = 0,
Size = 100,
},
Blur = {
Size = 2,
},
ColorCorrection = {
Saturation = 0.05,
TintColor = Color3.fromRGB(255, 224, 219),
},
SunRays = {
Intensity = 0.05,
},
})
for name,raw in pairs({
["Golden Hour"] = {
Lighting = {
Brightness = 1.8,
ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
ColorShift_Top = Color3.fromRGB(255, 210, 160),
OutdoorAmbient = Color3.fromRGB(155, 155, 170),
ClockTime = 17.8,
FogColor = Color3.fromRGB(190, 205, 230),
FogEnd = 100000,
FogStart = 0,
ExposureCompensation = -0.03,
ShadowSoftness = 0.6,
Ambient = Color3.fromRGB(38, 38, 42),
},
Bloom = {
Intensity = 0.55,
Threshold = 0.95,
Size = 42,
},
Blur = {
Size = 0,
},
CC = {
Brightness = 0.03,
Saturation = 0.16,
Contrast = 0.44,
TintColor = Color3.fromRGB(255, 230, 200),
},
SunRays = {
Intensity = 0.18,
Spread = 0.9,
},
Atmosphere = {
Density = 0.32,
Offset = 0.15,
Haze = 1.4,
Glare = 0.35,
Color = Color3.fromRGB(200, 210, 255),
Decay = Color3.fromRGB(100, 110, 130),
},
},
Night = {
Lighting = {
Brightness = 0.8,
ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
ColorShift_Top = Color3.fromRGB(255, 245, 230),
OutdoorAmbient = Color3.fromRGB(155, 155, 170),
ClockTime = 0,
FogColor = Color3.fromRGB(190, 205, 230),
FogEnd = 100000,
FogStart = 0,
ExposureCompensation = -0.22,
ShadowSoftness = 0.7,
Ambient = Color3.fromRGB(29, 29, 33),
},
Bloom = {
Intensity = 0.8,
Threshold = 0.78,
Size = 38,
},
Blur = {
Size = 0,
},
CC = {
Brightness = -0.08,
Saturation = -0.15,
Contrast = 0.37,
TintColor = Color3.fromRGB(185, 205, 255),
},
SunRays = {
Intensity = 0,
Spread = 0.65,
},
Atmosphere = {
Density = 0.5,
Offset = 0.15,
Haze = 2.25,
Glare = 0.15,
Color = Color3.fromRGB(200, 210, 255),
Decay = Color3.fromRGB(100, 110, 130),
},
},
["Neon Night"] = {
Lighting = {
Brightness = 1,
ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
ColorShift_Top = Color3.fromRGB(255, 245, 230),
OutdoorAmbient = Color3.fromRGB(155, 155, 170),
ClockTime = 0.4,
FogColor = Color3.fromRGB(190, 205, 230),
FogEnd = 100000,
FogStart = 0,
ExposureCompensation = -0.12,
ShadowSoftness = 0.5,
Ambient = Color3.fromRGB(27, 27, 30),
},
Bloom = {
Intensity = 1.15,
Threshold = 0.65,
Size = 52,
},
Blur = {
Size = 0,
},
CC = {
Brightness = -0.04,
Saturation = 0.3,
Contrast = 0.65,
TintColor = Color3.fromRGB(205, 215, 255),
},
SunRays = {
Intensity = 0,
Spread = 0.65,
},
Atmosphere = {
Density = 0.38,
Offset = 0.15,
Haze = 1.8,
Glare = 0.15,
Color = Color3.fromRGB(200, 210, 255),
Decay = Color3.fromRGB(100, 110, 130),
},
},
["Lost Ocean"] = {
Lighting = {
Brightness = 0.65,
ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
ColorShift_Top = Color3.fromRGB(255, 245, 230),
OutdoorAmbient = Color3.fromRGB(155, 155, 170),
ClockTime = 23.5,
FogColor = Color3.fromRGB(190, 205, 230),
FogEnd = 100000,
FogStart = 0,
ExposureCompensation = -0.28,
ShadowSoftness = 0.85,
Ambient = Color3.fromRGB(21, 21, 23),
},
Bloom = {
Intensity = 0.2,
Threshold = 1.1,
Size = 28,
},
Blur = {
Size = 0.7,
},
CC = {
Brightness = -0.13,
Saturation = -0.4,
Contrast = 0.78,
TintColor = Color3.fromRGB(210, 225, 255),
},
SunRays = {
Intensity = 0.08,
Spread = 0.65,
},
Atmosphere = {
Density = 0.65,
Offset = 0.15,
Haze = 3.2,
Glare = 0.15,
Color = Color3.fromRGB(200, 210, 255),
Decay = Color3.fromRGB(100, 110, 130),
},
},
Dreamy = {
Lighting = {
Brightness = 2,
ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
ColorShift_Top = Color3.fromRGB(255, 245, 230),
OutdoorAmbient = Color3.fromRGB(155, 155, 170),
ClockTime = 16.8,
FogColor = Color3.fromRGB(190, 205, 230),
FogEnd = 100000,
FogStart = 0,
ExposureCompensation = 0.08,
ShadowSoftness = 0.9,
Ambient = Color3.fromRGB(61, 61, 68),
},
Bloom = {
Intensity = 0.9,
Threshold = 0.75,
Size = 70,
},
Blur = {
Size = 0.35,
},
CC = {
Brightness = 0.06,
Saturation = 0.18,
Contrast = 0.17,
TintColor = Color3.fromRGB(255, 230, 255),
},
SunRays = {
Intensity = 0.08,
Spread = 0.65,
},
Atmosphere = {
Density = 0.28,
Offset = 0.15,
Haze = 1.4,
Glare = 0.15,
Color = Color3.fromRGB(200, 210, 255),
Decay = Color3.fromRGB(100, 110, 130),
},
},
Colorful = {
Lighting = {
Brightness = 2.25,
ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
ColorShift_Top = Color3.fromRGB(255, 245, 230),
OutdoorAmbient = Color3.fromRGB(155, 155, 170),
ClockTime = 13.5,
FogColor = Color3.fromRGB(190, 205, 230),
FogEnd = 100000,
FogStart = 0,
ExposureCompensation = 0.04,
ShadowSoftness = 0.35,
Ambient = Color3.fromRGB(51, 51, 57),
},
Bloom = {
Intensity = 0.5,
Threshold = 1.1,
Size = 34,
},
Blur = {
Size = 0,
},
CC = {
Brightness = 0.04,
Saturation = 0.45,
Contrast = 0.27,
TintColor = Color3.fromRGB(255, 255, 255),
},
SunRays = {
Intensity = 0.08,
Spread = 0.65,
},
Atmosphere = {
Density = 0.18,
Offset = 0.15,
Haze = 0.6,
Glare = 0.15,
Color = Color3.fromRGB(200, 210, 255),
Decay = Color3.fromRGB(100, 110, 130),
},
},
}) do add("SAVITAR",name,raw) end
do local metadata={Lighting={},Sky={SkyboxUp="rbxassetid://323493360",SkyboxLf="rbxassetid://323494252",SkyboxBk="rbxassetid://323494035",SkyboxFt="rbxassetid://323494130",SkyboxDn="rbxassetid://323494368",SunAngularSize=14,SkyboxRt="rbxassetid://323494067"}} for name,data in pairs(catalog) do if name=="SAVITAR / Scarlet Atmosphere" then data.sky=metadata.Sky end end end
do local metadata={Lighting={},Sky={SunAngularSize=11,MoonAngularSize=11,StarCount=1200},Atmosphere={}} for name,data in pairs(catalog) do if data.source=="SAVITAR" and name~="SAVITAR / Scarlet Atmosphere" then data.sky=metadata.Sky end end end
for name,raw in pairs({
["Ночь"] = {
Brightness = 2,
Ambient = Color3.fromRGB(60, 70, 130),
OutdoorAmbient = Color3.fromRGB(70, 80, 150),
ClockTime = 12,
FogEnd = 100000,
FogStart = 90000,
ExposureCompensation = 0.3,
CC = {
Brightness = 0,
Contrast = 0.1,
Saturation = -0.1,
Tint = Color3.fromRGB(120, 140, 220),
},
Bloom = { Intensity = 0.6, Size = 32, Threshold = 0.7 },
},
["Вечер"] = {
Brightness = 2.5,
Ambient = Color3.fromRGB(170, 110, 75),
OutdoorAmbient = Color3.fromRGB(190, 120, 85),
ClockTime = 12,
FogEnd = 100000,
FogStart = 90000,
ExposureCompensation = 0.4,
CC = {
Brightness = 0,
Contrast = 0.1,
Saturation = 0.2,
Tint = Color3.fromRGB(255, 200, 160),
},
Bloom = { Intensity = 0.6, Size = 32, Threshold = 0.7 },
},
["Неон"] = {
Brightness = 2.5,
Ambient = Color3.fromRGB(80, 40, 120),
OutdoorAmbient = Color3.fromRGB(90, 50, 140),
ClockTime = 22,
FogEnd = 1500,
FogStart = 200,
ExposureCompensation = 0.3,
CC = {
Brightness = 0,
Contrast = 0.4,
Saturation = 0.8,
Tint = Color3.fromRGB(180, 100, 255),
},
Bloom = { Intensity = 1.3, Size = 44, Threshold = 0.35 },
},
["Холодный"] = {
Brightness = 2.5,
Ambient = Color3.fromRGB(120, 140, 180),
OutdoorAmbient = Color3.fromRGB(140, 160, 200),
ClockTime = 12,
FogEnd = 100000,
FogStart = 90000,
ExposureCompensation = 0.1,
CC = {
Brightness = 0,
Contrast = 0.1,
Saturation = 0.1,
Tint = Color3.fromRGB(150, 180, 255),
},
Bloom = { Intensity = 0.4, Size = 24, Threshold = 0.8 },
},
["Тёплый"] = {
Brightness = 2.5,
Ambient = Color3.fromRGB(180, 140, 100),
OutdoorAmbient = Color3.fromRGB(200, 160, 120),
ClockTime = 12,
FogEnd = 100000,
FogStart = 90000,
ExposureCompensation = 0.2,
CC = {
Brightness = 0.02,
Contrast = 0.1,
Saturation = 0.3,
Tint = Color3.fromRGB(255, 200, 150),
},
Bloom = { Intensity = 0.5, Size = 28, Threshold = 0.6 },
},
}) do add("Eris",name,raw,true) end
for _,data in pairs(catalog) do if data.source=="Eris" then data.light.GlobalShadows=false end end
add("Fosfor","Rainy Shader",{Lighting={ClockTime=10,ColorShift_Bottom=Color3.new(0, 0, 0),FogColor=Color3.new(1, 1, 1),FogEnd=100000,EnvironmentDiffuseScale=0.403,GlobalShadows=true,EnvironmentSpecularScale=0.25,FogStart=0,GeographicLatitude=-45,Ambient=Color3.new(0.949, 0.953, 0.953),OutdoorAmbient=Color3.new(0, 0, 0),ExposureCompensation=0.2,Brightness=-0.1,ColorShift_Top=Color3.new(0, 0, 0),ShadowSoftness=0.2},Sky={StarCount=3000,SkyboxUp="rbxassetid://8995814929",MoonTextureId="rbxasset://sky/moon.jpg",SkyboxDn="rbxassetid://8995686153",SkyboxBk="rbxassetid://8995816670",SkyboxFt="rbxassetid://8995816670",SunTextureId="rbxassetid://8923082571",SunAngularSize=30,SkyboxLf="rbxassetid://8995816670",SkyboxRt="rbxassetid://8995816670",MoonAngularSize=0},CC={Enabled=true,Saturation=-0.3,Contrast=0.2,TintColor=Color3.new(0.784314, 0.784314, 1),Brightness=-0.1},Atmosphere={Density=0.564,Haze=1.72,Color=Color3.new(0.631373, 0.647059, 0.635294),Decay=Color3.new(0.949, 0.953, 0.953),Glare=0.36,Offset=0.556},Bloom={Enabled=true,Threshold=0.8,Intensity=0.3,Size=10},DepthOfField={Enabled=true,FarIntensity=0.217,FocusDistance=11.54,InFocusRadius=16.77,NearIntensity=0.277}})
add("Fosfor","Sunset Shader",{Lighting={ClockTime=6.7,ColorShift_Bottom=Color3.new(0.043137, 0, 0.078431),FogColor=Color3.new(0.368627, 0.298039, 0.415686),FogEnd=1000,EnvironmentDiffuseScale=0,GlobalShadows=true,EnvironmentSpecularScale=0.25,FogStart=0,GeographicLatitude=41.735,Ambient=Color3.new(0.231373, 0.129412, 0.105882),OutdoorAmbient=Color3.new(0.133333, 0, 0.192157),ExposureCompensation=0.24,Brightness=3.5,ColorShift_Top=Color3.new(0.941176, 0.498039, 0.054902),ShadowSoftness=0},Bloom={Enabled=true,Threshold=0,Intensity=0.1,Size=100},Blur={Enabled=true,Size=2},CC={Enabled=true,Saturation=0.05,Contrast=0,TintColor=Color3.new(1, 0.878431, 0.858824),Brightness=0},SunRays={Enabled=true,Intensity=0.05,Spread=1},Sky={StarCount=3000,SkyboxUp="rbxassetid://323493360",MoonTextureId="rbxasset://sky/moon.jpg",SkyboxDn="rbxassetid://323494368",SkyboxBk="rbxassetid://323494035",SkyboxFt="rbxassetid://323494130",SunTextureId="rbxasset://sky/sun.jpg",SunAngularSize=14,SkyboxLf="rbxassetid://323494252",SkyboxRt="rbxassetid://323494067",MoonAngularSize=11}})
add("Fosfor","Dreamy Shader",{Lighting={ClockTime=14,ColorShift_Bottom=Color3.new(0, 0, 0),FogColor=Color3.new(0.752941, 0.752941, 0.752941),FogEnd=100000,EnvironmentDiffuseScale=0,GlobalShadows=true,EnvironmentSpecularScale=0.25,FogStart=0,GeographicLatitude=41.735,Ambient=Color3.new(0.470588, 0.470588, 0.470588),OutdoorAmbient=Color3.new(0.784314, 0.784314, 0.784314),ExposureCompensation=0,Brightness=2,ColorShift_Top=Color3.new(0, 0, 0),ShadowSoftness=0.2},Sky={StarCount=3000,SkyboxUp="rbxassetid://8995814929",MoonTextureId="rbxasset://sky/moon.jpg",SkyboxDn="rbxassetid://8995686153",SkyboxBk="rbxassetid://8995816670",SkyboxFt="rbxassetid://8995816670",SunTextureId="rbxassetid://8923082571",SunAngularSize=30,SkyboxLf="rbxassetid://8995816670",SkyboxRt="rbxassetid://8995816670",MoonAngularSize=0},CC={Enabled=true,Saturation=0.5,Contrast=0.3,TintColor=Color3.new(0.941176, 0.862745, 1),Brightness=0},Atmosphere={Density=0.3,Haze=0,Color=Color3.new(0.678, 0.847, 0.902),Decay=Color3.new(0.678, 0.847, 0.902),Glare=0,Offset=0}})
add("Fosfor","Purple Map",{Lighting={ClockTime=18.5,Brightness=2.8,FogColor=Color3.fromRGB(138, 43, 226),Ambient=Color3.fromRGB(138, 43, 226),OutdoorAmbient=Color3.fromRGB(100, 90, 110),FogStart=50,FogEnd=500},CC={Enabled=true,TintColor=Color3.fromRGB(230, 210, 255),Saturation=0.2,Contrast=0.05,Brightness=0}})
add("Fosfor","Adaptive Map",{Lighting={ClockTime=18,Brightness=2.5,FogStart=50,FogEnd=500},CC={Saturation=.15,Contrast=.05,Brightness=0}})
catalog["Fosfor / Adaptive Map"].adaptiveAccent=true
add("Silent Target","Classic",{Lighting={Brightness=2.25,ExposureCompensation=0.1,ClockTime=17.55,ColorShift_Bottom=Color3.fromRGB(0, 0, 0),ColorShift_Top=Color3.fromRGB(0, 0, 0),OutdoorAmbient=Color3.fromRGB(200, 200, 200),FogColor=Color3.fromRGB(192, 192, 192),FogEnd=100000,FogStart=0,ShadowSoftness=0,Ambient=Color3.fromRGB(120, 120, 120)},Sky={StarCount=5000,SunAngularSize=5},Bloom={Intensity=0.3,Size=10,Threshold=0.8},Blur={Size=5},CC={Brightness=0,Contrast=0.1,Saturation=0.25,TintColor=Color3.fromRGB(255, 255, 255)},SunRays={Intensity=0.1,Spread=0.8}})
add("Silent Target","Twilight",{Lighting={Brightness=3.5,ExposureCompensation=0.24,ClockTime=6.7,ColorShift_Bottom=Color3.fromRGB(11, 0, 20),ColorShift_Top=Color3.fromRGB(240, 127, 14),OutdoorAmbient=Color3.fromRGB(34, 0, 49),FogColor=Color3.fromRGB(94, 76, 106),FogEnd=1000,FogStart=0,ShadowSoftness=0,Ambient=Color3.fromRGB(59, 33, 27)},Bloom={Intensity=0.1,Threshold=0,Size=100},Sky={SkyboxUp="rbxassetid://323493360",SkyboxLf="rbxassetid://323494252",SkyboxBk="rbxassetid://323494035",SkyboxFt="rbxassetid://323494130",SkyboxDn="rbxassetid://323494368",SunAngularSize=14,SkyboxRt="rbxassetid://323494067"},CC={Saturation=0.05,TintColor=Color3.fromRGB(255, 224, 219)},SunRays={Intensity=0.05}})
add("Silent Target","Luminous",{Lighting={Brightness=2,ExposureCompensation=0.5,ClockTime=10,ColorShift_Bottom=Color3.fromRGB(250, 250, 250),ColorShift_Top=Color3.fromRGB(250, 250, 250),OutdoorAmbient=Color3.fromRGB(150, 150, 150),FogColor=Color3.fromRGB(20, 20, 20),FogEnd=10000,FogStart=0,ShadowSoftness=0,Ambient=Color3.fromRGB(50, 50, 50)},Bloom={Intensity=0.1,Threshold=0,Size=100},Sky={SkyboxUp="rbxassetid://323493360",SkyboxLf="rbxassetid://323494252",SkyboxBk="rbxassetid://323494035",SkyboxFt="rbxassetid://323494130",SkyboxDn="rbxassetid://323494368",SunAngularSize=14,SkyboxRt="rbxassetid://323494067"}})
add("Silent Target","Sandstorm",{Lighting={Brightness=2.5,ExposureCompensation=0.5,ClockTime=7,ColorShift_Bottom=Color3.fromRGB(240, 120, 20),ColorShift_Top=Color3.fromRGB(240, 127, 14),OutdoorAmbient=Color3.fromRGB(100, 50, 10),FogColor=Color3.fromRGB(100, 55, 20),FogEnd=1000,FogStart=0,ShadowSoftness=0,Ambient=Color3.fromRGB(80, 40, 10)},Bloom={Intensity=0.1,Threshold=0,Size=100},Sky={SkyboxUp="rbxassetid://323493360",SkyboxLf="rbxassetid://323494252",SkyboxBk="rbxassetid://323494035",SkyboxFt="rbxassetid://323494130",SkyboxDn="rbxassetid://323494368",SunAngularSize=14,SkyboxRt="rbxassetid://323494067"}})
add("Silent Target","Arctic",{Lighting={Brightness=2,ExposureCompensation=0,ClockTime=14,ColorShift_Bottom=Color3.fromRGB(0, 0, 0),ColorShift_Top=Color3.fromRGB(0, 0, 0),OutdoorAmbient=Color3.fromRGB(150, 170, 200),FogColor=Color3.fromRGB(192, 192, 192),FogEnd=100000,FogStart=0,ShadowSoftness=0,Ambient=Color3.fromRGB(0, 50, 100),GlobalShadows=true},CC={Saturation=-0.3,Contrast=0.2,TintColor=Color3.fromRGB(220, 240, 255)},Bloom={Intensity=0.8,Size=24,Threshold=0.6},Atmosphere={Density=0.45,Color=Color3.fromRGB(180, 200, 255),Decay=Color3.fromRGB(255, 255, 255),Glare=0.6}})
return catalog
