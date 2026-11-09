-- Presentation only. Selection flows through the existing persisted setters.
return function(c)
    local make,connect=c.Make,c.Connect
    local animations={} local dead=false
    local function animate(object,properties,duration)
        if dead then return end
        local changed=false for key,value in pairs(properties) do if object[key]~=value then changed=true break end end
        if not changed then return end
        if animations[object] then animations[object]:Cancel() animations[object]=nil end
        if c.TweenService and (not c.AnimationsEnabled or c.AnimationsEnabled()) then
            local tween=c.TweenService:Create(object,TweenInfo.new(duration or .16,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),properties)
            animations[object]=tween tween:Play()
        else for key,value in pairs(properties) do object[key]=value end end
    end
    local white=Color3.new(1,1,1)
    local function tr(text) return c.Translate and c.Translate(text) or text end
    local upper,lower="АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ","абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
    local letters={} for i=1,#upper,2 do letters[upper:sub(i,i+1)]=lower:sub(i,i+1) end
    local function fold(text)
        local ascii=text:gsub("[A-Z]",function(letter) return string.char(letter:byte()+32) end)
        return ascii:gsub("\208[\128-\191]",function(letter) return letters[letter] or letter end)
    end
    local root=make("Frame",{Name="PV_ShaderBrowser",Size=c.Host and UDim2.fromScale(1,1) or UDim2.new(1,0,0,442),BackgroundTransparency=1},c.Host)
    if not c.Host then
        local holder=c.Group:AddUIPassthrough("shaderBrowserPanel",{Instance=root,Height=442})
        holder.SearchAliases="Shaders shader catalog presets Шейдеры каталог пресеты "..table.concat(c.Names," ")
    end
    local listTop=c.Host and 44 or 140
    local categories=make("Frame",{Name="Collections",BackgroundTransparency=1,Size=c.Sidebar and UDim2.new(1,0,0,310) or UDim2.new(1,0,0,67)},c.Sidebar or root)
    make("UIGridLayout",{CellSize=c.Sidebar and UDim2.new(1,0,0,c.Thematic and 32 or 38) or UDim2.new(.25,-4.5,0,30),CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder},categories)
    local search=make("TextBox",{Name="ShaderSearch",Position=UDim2.fromOffset(0,c.Host and 0 or 76),Size=UDim2.new(1,0,0,32),
        BorderSizePixel=0,ClearTextOnFocus=false,Text="",PlaceholderText=tr("Search shaders..."),Font=Enum.Font.Gotham,
        TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},root)
    make("UICorner",{CornerRadius=UDim.new(0,5)},search)
    make("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,30)},search)
    local clear=make("TextButton",{Name="ClearSearch",Text="×",BackgroundTransparency=1,Position=UDim2.new(1,-29,0,c.Host and 1 or 77),Size=UDim2.fromOffset(28,30),Font=Enum.Font.Gotham,TextSize=20,Visible=false},root)
    local searchStroke=make("UIStroke",{Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},search)
    local status=make("TextLabel",{Name="ShaderCount",BackgroundTransparency=1,Position=UDim2.fromOffset(0,listTop-25),
        Size=UDim2.new(1,0,0,18),Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},root)
    local scroll=make("ScrollingFrame",{Name="ShaderCards",BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromOffset(0,listTop),Size=UDim2.new(1,0,1,-listTop-40),CanvasSize=UDim2.new(),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=4,Active=true},root)
    local content=make("Frame",{Name="Cards",BackgroundTransparency=1,Size=UDim2.new(1,-7,0,0),AutomaticSize=Enum.AutomaticSize.Y},scroll)
    local grid=make("UIGridLayout",{CellSize=UDim2.new(1,0,0,60),CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder},content)
    local function columns() return 5 end
    local function resize() local n=columns() grid.CellSize=UDim2.new(1/n,-6*(n-1)/n,0,52) grid.FillDirectionMaxCells=5 end
    connect(root:GetPropertyChangedSignal("AbsoluteSize"),resize) resize()
    local empty=make("TextLabel",{Name="EmptyResults",BackgroundTransparency=1,Position=UDim2.fromOffset(0,listTop+24),
        Size=UDim2.new(1,0,0,55),Font=Enum.Font.Gotham,TextSize=13,TextWrapped=true,Text=tr("No shaders found"),Visible=false},root)
    local selected=make("TextLabel",{Name="ShaderSelection",Position=UDim2.new(0,0,1,-60),Size=UDim2.new(1,0,0,20),
        BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},root)
    local api={Category="All shaders",Sort="Name",Descending=false} local chips,cards,sortButtons={},{},{} local lastKey local hovered
    local previous=make("TextButton",{Name="PreviousShader",Text="←",Position=UDim2.new(0,0,1,-32),Size=UDim2.new(.25,-4,0,30),BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=21},root)
    local power=make("TextButton",{Name="ShaderPower",Text="",Position=UDim2.new(.25,2,1,-32),Size=UDim2.new(.5,-4,0,30),BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=12},root)
    local nextButton=make("TextButton",{Name="NextShader",Text="→",Position=UDim2.new(.75,4,1,-32),Size=UDim2.new(.25,-4,0,30),BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=21},root)
    for _,button in ipairs({previous,power,nextButton}) do make("UICorner",{CornerRadius=UDim.new(0,5)},button) end
    local function select(name)
        c.Setters.visualPreset(name,true)
        if not c.Controls.visualPresetEnabled then c.Setters.visualPresetEnabled(true,true) end
        local countColumns=columns()
        local height=52
        local index=0
        for _,card in ipairs(cards) do if card.button.Visible then
            index=index+1
            if card.name==name then
                local y=math.floor((index-1)/countColumns)*(height+6)
                local top=scroll.CanvasPosition.Y
                if y<top then top=y elseif y+height>top+scroll.AbsoluteSize.Y then top=y+height-scroll.AbsoluteSize.Y end
                scroll.CanvasPosition=Vector2.new(0,math.max(0,top)) break
            end
        end end
    end
    local function step(direction)
        local visible={} for _,card in ipairs(cards) do if card.button.Visible then visible[#visible+1]=card.name end end
        if #visible==0 then return end
        local index=table.find(visible,c.Controls.visualPreset)
        select(visible[index and ((index-1+direction)%#visible)+1 or (direction>0 and 1 or #visible)])
    end
    connect(previous.Activated,function() step(-1) end) connect(nextButton.Activated,function() step(1) end)
    connect(power.Activated,function() c.Setters.visualPresetEnabled(not c.Controls.visualPresetEnabled,true) end)
    connect(clear.Activated,function() search.Text="" end)
    local collections=c.Thematic and {"All shaders","Daylight","Night","Warm","Cool","Foggy","Monochrome","Vivid"} or {"All collections","Prime Visuals","Mercury","SAVITAR","Fosfor","Eris","Silent Target"}
    for i,name in ipairs(collections) do
        local b=make("TextButton",{Name="Collection_"..i,Size=UDim2.fromOffset(name=="All collections" and 106 or name=="Prime Visuals" and 102 or name=="Silent Target" and 102 or 85,28),
            LayoutOrder=i,BorderSizePixel=0,AutoButtonColor=false,Text=tr(name),TextSize=12,TextWrapped=true,Font=Enum.Font.Gotham},categories)
        make("UICorner",{CornerRadius=UDim.new(0,5)},b)
        local stroke=make("UIStroke",{Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},b)
        chips[#chips+1]={name=name,button=b,stroke=stroke}
        connect(b.Activated,function()
            if c.Thematic then api.Category=name api:Refresh(true) else c.Setters.shaderCollection(name,true) end
        end)
    end
    if c.Thematic then
        local sortRoot=make("Frame",{Name="SortControls",BackgroundTransparency=1,Position=UDim2.fromOffset(0,328),Size=UDim2.new(1,0,0,204)},c.Sidebar)
        make("TextLabel",{Text=tr("Sort by"),BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),TextColor3=white,
            Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},sortRoot)
        for i,name in ipairs({"Name","Time","Brightness","Saturation"}) do
            local button=make("TextButton",{Name="Sort_"..name,Text=tr(name),Position=UDim2.new(0,0,0,26+(i-1)*34),
                Size=UDim2.new(1,-5,0,29),BorderSizePixel=0,TextSize=12,Font=Enum.Font.Gotham,TextWrapped=true},sortRoot)
            make("UICorner",{CornerRadius=UDim.new(0,4)},button)
            sortButtons[#sortButtons+1]={name=name,button=button}
            connect(button.Activated,function()api.Sort=name api:Refresh(true)end)
        end
        local direction=make("TextButton",{Name="SortDirection",Position=UDim2.fromOffset(0,166),Size=UDim2.new(1,0,0,28),
            Text=tr("Ascending"),TextColor3=white,BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,TextSize=11,Font=Enum.Font.Gotham},sortRoot)
        make("UICorner",{CornerRadius=UDim.new(0,4)},direction)
        connect(direction.Activated,function() api.Descending=not api.Descending direction.Text=tr(api.Descending and "Descending" or "Ascending") api:Refresh(true) end)
    end
    for i,name in ipairs(c.Names) do
        local data=c.Presets[name]
        local source=data.source or "Prime Visuals"
        local title=name:sub(1,#source+3)==source.." / " and name:sub(#source+4) or name
        local b=make("TextButton",{Name="Shader_"..i,Size=UDim2.new(.5,-4,0,64),LayoutOrder=i,Text="",BorderSizePixel=0,AutoButtonColor=false},content)
        b:SetAttribute("ShaderId",name)
        make("UICorner",{CornerRadius=UDim.new(0,6)},b)
        local stroke=make("UIStroke",{Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},b)
        local tint=data.light.OutdoorAmbient or data.light.Ambient or white
        local saturation,density=0,0
        for _,effect in ipairs(data.effects or {}) do
            if effect[1]=="ColorCorrectionEffect" then tint=effect[2].TintColor or tint saturation=effect[2].Saturation or 0 end
            if effect[1]=="Atmosphere" then density=effect[2].Density or 0 end
        end
        local label=make("TextLabel",{Name="Title",BackgroundTransparency=1,Position=UDim2.fromOffset(5,4),Size=UDim2.new(1,-10,1,-8),
            Text=title,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,Font=Enum.Font.Gotham,TextSize=11},b)
        local check=make("TextLabel",{Name="Selected",BackgroundTransparency=1,Position=UDim2.new(1,-22,0,8),Size=UDim2.fromOffset(16,20),
            Text="",Font=Enum.Font.Gotham,TextSize=14,Visible=false},b)
        local scale=make("UIScale",{Scale=1},b)
        cards[#cards+1]={name=name,source=source,title=title,button=b,stroke=stroke,label=label,check=check,scale=scale,
            time=data.light.ClockTime,brightness=data.light.Brightness,saturation=saturation,
            tags={Daylight=data.light.ClockTime and data.light.ClockTime>=6 and data.light.ClockTime<18,
                Night=data.light.ClockTime and (data.light.ClockTime<6 or data.light.ClockTime>=18),
                Warm=tint.R-tint.B>.08,Cool=tint.B-tint.R>.08,Foggy=density>=.35 or (data.light.FogEnd and data.light.FogEnd<=2000),
                Monochrome=saturation<=-.5,Vivid=saturation>=.25}}
        connect(b.Activated,function()
            select(name) scale.Scale=.97 animate(scale,{Scale=1},.22)
        end)
        connect(b.MouseEnter,function() hovered=b api:Refresh(true) end)
        connect(b.MouseLeave,function() if hovered==b then hovered=nil api:Refresh(true) end end)
    end
    function api:Refresh(force)
        local accent=white
        local bg=Color3.new(0,0,0)
        local outline=white
        local font=white
        local collection=c.Thematic and api.Category or c.Controls.shaderCollection or "All collections"
        local query=fold(search.Text):match("^%s*(.-)%s*$")
        local key=table.concat({collection,query,tostring(c.Controls.visualPreset),tostring(c.Controls.visualPresetEnabled),tostring(accent),tostring(bg),tostring(font),tostring(outline),tr("Search shaders..."),api.Sort,tostring(api.Descending)},"|")
        if not force and key==lastKey then return end
        local filterChanged=api.Collection~=collection or api.Query~=query or api.LastSort~=api.Sort or api.LastDescending~=api.Descending
        lastKey=key api.Collection=collection api.Query=query api.LastSort=api.Sort api.LastDescending=api.Descending
        search.BackgroundColor3=bg search.TextColor3=font search.PlaceholderColor3=font searchStroke.Color=outline
        search.PlaceholderText=tr("Search shaders...")
        local count=0
        if c.Thematic then
            table.sort(cards,function(a,b)
                local x,y
                if api.Sort=="Time" then x,y=a.time,b.time elseif api.Sort=="Brightness" then x,y=a.brightness,b.brightness
                elseif api.Sort=="Saturation" then x,y=a.saturation,b.saturation else x,y=fold(a.title),fold(b.title) end
                if x==nil or y==nil then if x~=y then return x~=nil end
                elseif x~=y then if api.Descending then return x>y else return x<y end end
                return a.name<b.name
            end)
        end
        local activeTitle=c.Controls.visualPreset
        for order,card in ipairs(cards) do
            card.button.LayoutOrder=order
            local matches=c.Thematic and (collection=="All shaders" or card.tags[collection]) or (not c.Thematic and (collection=="All collections" or collection==card.source))
            local visible=matches and (query=="" or fold(card.title..(c.Thematic and "" or " "..card.source)):find(query,1,true)~=nil) or false
            card.button.Visible=visible if visible then count=count+1 end
            local active=card.name==c.Controls.visualPreset
            if active and c.Thematic then activeTitle=card.title end
            animate(card.button,{BackgroundColor3=active and white or bg})
            animate(card.stroke,{Color=white,Thickness=1,Transparency=active and 0 or hovered==card.button and .25 or .8})
            card.label.TextColor3=active and bg or white
            card.check.Visible=active card.check.TextColor3=bg
        end
        for _,entry in ipairs(sortButtons) do animate(entry.button,{BackgroundColor3=entry.name==api.Sort and white or bg,TextColor3=entry.name==api.Sort and bg or white}) end
        for _,chip in ipairs(chips) do
            local active=chip.name==collection
            chip.button.Text=tr(chip.name)
            animate(chip.button,{BackgroundColor3=active and white or bg,TextColor3=active and bg or white})
            animate(chip.stroke,{Color=white,Transparency=active and 0 or .85})
        end
        if filterChanged then
            scroll.CanvasPosition=Vector2.new(0,0)
            scroll.Position=UDim2.fromOffset(0,listTop+6) animate(scroll,{Position=UDim2.fromOffset(0,listTop)},.2)
        end
        clear.Visible=query~="" clear.TextColor3=font
        for _,button in ipairs({previous,power,nextButton}) do animate(button,{BackgroundColor3=bg,TextColor3=font}) end
        power.Text=tr(c.Controls.visualPresetEnabled and "Disable" or "Enable")
        status.Text=tostring(count).." / "..tostring(#cards).."  ·  "..tr(collection) status.TextColor3=font status.Visible=false
        empty.Text=tr("No shaders found") empty.Visible=count==0 empty.TextColor3=font
        selected.Text=(c.Controls.visualPresetEnabled and "●  " or "○  ")..tostring(activeTitle or "") selected.TextColor3=font selected.Visible=false
        scroll.ScrollBarImageColor3=accent
    end
    connect(search:GetPropertyChangedSignal("Text"),function() api:Refresh() end)
    api:Refresh(true)
    function api:Destroy() dead=true for _,tween in pairs(animations) do tween:Cancel() end animations={} end
    return api
end
