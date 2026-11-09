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
    local white=Color3.fromRGB(235,235,240)
    local function tr(text) return c.Translate and c.Translate(text) or text end
    local upper,lower="АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ","абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
    local letters={} for i=1,#upper,2 do letters[upper:sub(i,i+1)]=lower:sub(i,i+1) end
    local function fold(text)
        local ascii=text:gsub("[A-Z]",function(letter) return string.char(letter:byte()+32) end)
        return ascii:gsub("\208[\128-\191]",function(letter) return letters[letter] or letter end)
    end
    local root=make("Frame",{Name="PV_ShaderBrowser",Size=UDim2.new(1,0,0,442),BackgroundTransparency=1})
    local holder=c.Group:AddUIPassthrough("shaderBrowserPanel",{Instance=root,Height=442})
    holder.SearchAliases="Shaders shader catalog presets Шейдеры каталог пресеты "..table.concat(c.Names," ")
    local categories=make("Frame",{Name="Collections",BackgroundTransparency=1,Size=UDim2.new(1,0,0,67)},root)
    make("UIGridLayout",{CellSize=UDim2.new(.25,-4.5,0,30),CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder},categories)
    local search=make("TextBox",{Name="ShaderSearch",Position=UDim2.fromOffset(0,76),Size=UDim2.new(1,0,0,32),
        BorderSizePixel=0,ClearTextOnFocus=false,Text="",PlaceholderText=tr("Search shaders..."),Font=Enum.Font.BuilderSans,
        TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},root)
    make("UICorner",{CornerRadius=UDim.new(0,5)},search)
    make("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,30)},search)
    local clear=make("TextButton",{Name="ClearSearch",Text="×",BackgroundTransparency=1,Position=UDim2.new(1,-29,0,77),Size=UDim2.fromOffset(28,30),Font=Enum.Font.BuilderSans,TextSize=20,Visible=false},root)
    local searchStroke=make("UIStroke",{Thickness=1},search)
    local status=make("TextLabel",{Name="ShaderCount",BackgroundTransparency=1,Position=UDim2.fromOffset(0,115),
        Size=UDim2.new(1,0,0,18),Font=Enum.Font.BuilderSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},root)
    local scroll=make("ScrollingFrame",{Name="ShaderCards",BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromOffset(0,140),Size=UDim2.new(1,0,1,-206),CanvasSize=UDim2.new(),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=4,Active=true},root)
    local content=make("Frame",{Name="Cards",BackgroundTransparency=1,Size=UDim2.new(1,-7,0,0),AutomaticSize=Enum.AutomaticSize.Y},scroll)
    local grid=make("UIGridLayout",{CellSize=UDim2.new(1,0,0,60),CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder},content)
    local function resize() grid.CellSize=root.AbsoluteSize.X>=360 and UDim2.new(.5,-4,0,68) or UDim2.new(1,0,0,60) end
    connect(root:GetPropertyChangedSignal("AbsoluteSize"),resize) resize()
    local empty=make("TextLabel",{Name="EmptyResults",BackgroundTransparency=1,Position=UDim2.fromOffset(0,164),
        Size=UDim2.new(1,0,0,55),Font=Enum.Font.BuilderSans,TextSize=13,TextWrapped=true,Text=tr("No shaders found"),Visible=false},root)
    local selected=make("TextLabel",{Name="ShaderSelection",Position=UDim2.new(0,0,1,-60),Size=UDim2.new(1,0,0,20),
        BackgroundTransparency=1,Font=Enum.Font.BuilderSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},root)
    local api={} local chips,cards={},{} local lastKey local hovered
    local previous=make("TextButton",{Name="PreviousShader",Text="‹",Position=UDim2.new(0,0,1,-32),Size=UDim2.new(.25,-4,0,30),BorderSizePixel=0,Font=Enum.Font.BuilderSans,TextSize=21},root)
    local power=make("TextButton",{Name="ShaderPower",Text="",Position=UDim2.new(.25,2,1,-32),Size=UDim2.new(.5,-4,0,30),BorderSizePixel=0,Font=Enum.Font.BuilderSans,TextSize=12},root)
    local nextButton=make("TextButton",{Name="NextShader",Text="›",Position=UDim2.new(.75,4,1,-32),Size=UDim2.new(.25,-4,0,30),BorderSizePixel=0,Font=Enum.Font.BuilderSans,TextSize=21},root)
    for _,button in ipairs({previous,power,nextButton}) do make("UICorner",{CornerRadius=UDim.new(0,5)},button) end
    local function select(name)
        c.Setters.visualPreset(name,true)
        if not c.Controls.visualPresetEnabled then c.Setters.visualPresetEnabled(true,true) end
        local columns=root.AbsoluteSize.X>=360 and 2 or 1
        local height=columns==2 and 68 or 60
        local index=0
        for _,card in ipairs(cards) do if card.button.Visible then
            index=index+1
            if card.name==name then
                local y=math.floor((index-1)/columns)*(height+8)
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
    local collections={"All collections","Prime Visuals","Mercury","SAVITAR","Fosfor","Eris","Silent Target"}
    for i,name in ipairs(collections) do
        local b=make("TextButton",{Name="Collection_"..i,Size=UDim2.fromOffset(name=="All collections" and 106 or name=="Prime Visuals" and 102 or name=="Silent Target" and 102 or 85,28),
            LayoutOrder=i,BorderSizePixel=0,AutoButtonColor=false,Text=tr(name),TextSize=11,TextWrapped=true,Font=Enum.Font.BuilderSans},categories)
        make("UICorner",{CornerRadius=UDim.new(0,5)},b)
        local stroke=make("UIStroke",{Thickness=1},b)
        chips[#chips+1]={name=name,button=b,stroke=stroke}
        connect(b.Activated,function() c.Setters.shaderCollection(name,true) end)
    end
    for i,name in ipairs(c.Names) do
        local data=c.Presets[name]
        local source=data.source or "Prime Visuals"
        local title=name:sub(1,#source+3)==source.." / " and name:sub(#source+4) or name
        local b=make("TextButton",{Name="Shader_"..i,Size=UDim2.new(.5,-4,0,64),LayoutOrder=i,Text="",BorderSizePixel=0,AutoButtonColor=false},content)
        make("UICorner",{CornerRadius=UDim.new(0,6)},b)
        local stroke=make("UIStroke",{Thickness=1},b)
        local tint=data.light.OutdoorAmbient or data.light.Ambient or white
        for _,effect in ipairs(data.effects or {}) do if effect[1]=="ColorCorrectionEffect" then tint=effect[2].TintColor or tint end end
        make("Frame",{Name="Palette",BackgroundColor3=tint,BorderSizePixel=0,Position=UDim2.fromOffset(8,12),Size=UDim2.fromOffset(3,40)},b)
        local label=make("TextLabel",{Name="Title",BackgroundTransparency=1,Position=UDim2.fromOffset(18,9),Size=UDim2.new(1,-40,0,30),
            Text=title,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,Font=Enum.Font.BuilderSans,TextSize=12},b)
        local origin=make("TextLabel",{Name="Source",BackgroundTransparency=1,Position=UDim2.fromOffset(18,42),Size=UDim2.new(1,-24,0,14),
            Text=source,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.BuilderSans,TextSize=10},b)
        local check=make("TextLabel",{Name="Selected",BackgroundTransparency=1,Position=UDim2.new(1,-22,0,8),Size=UDim2.fromOffset(16,20),
            Text="✓",Font=Enum.Font.BuilderSansBold,TextSize=14,Visible=false},b)
        local scale=make("UIScale",{Scale=1},b)
        cards[#cards+1]={name=name,source=source,title=title,button=b,stroke=stroke,label=label,origin=origin,check=check,scale=scale}
        connect(b.Activated,function()
            select(name) scale.Scale=.97 animate(scale,{Scale=1},.22)
        end)
        connect(b.MouseEnter,function() hovered=b api:Refresh(true) end)
        connect(b.MouseLeave,function() if hovered==b then hovered=nil api:Refresh(true) end end)
    end
    function api:Refresh(force)
        local scheme=c.GetScheme and c.GetScheme() or {}
        local accent=scheme.AccentColor or Color3.fromRGB(160,106,255)
        local bg=scheme.MainColor or Color3.fromRGB(20,20,24)
        local outline=scheme.OutlineColor or Color3.fromRGB(48,48,54)
        local font=scheme.FontColor or white
        local collection=c.Controls.shaderCollection or "All collections"
        local query=fold(search.Text):match("^%s*(.-)%s*$")
        local key=table.concat({collection,query,tostring(c.Controls.visualPreset),tostring(c.Controls.visualPresetEnabled),tostring(accent),tostring(bg),tostring(font),tostring(outline),tr("Search shaders...")},"|")
        if not force and key==lastKey then return end
        local filterChanged=api.Collection~=collection or api.Query~=query
        lastKey=key api.Collection=collection api.Query=query
        search.BackgroundColor3=bg search.TextColor3=font search.PlaceholderColor3=font:Lerp(bg,.45) searchStroke.Color=outline
        search.PlaceholderText=tr("Search shaders...")
        local count=0
        for _,card in ipairs(cards) do
            local visible=(collection=="All collections" or collection==card.source) and (query=="" or fold(card.title.." "..card.source):find(query,1,true)~=nil)
            card.button.Visible=visible if visible then count=count+1 end
            local active=card.name==c.Controls.visualPreset
            animate(card.button,{BackgroundColor3=active and bg:Lerp(accent,.2) or hovered==card.button and bg:Lerp(accent,.09) or bg})
            animate(card.stroke,{Color=active and accent or outline,Thickness=active and 1.5 or 1})
            card.label.TextColor3=font card.origin.TextColor3=font:Lerp(bg,.4)
            card.check.Visible=active card.check.TextColor3=accent
        end
        for _,chip in ipairs(chips) do
            local active=chip.name==collection
            chip.button.Text=tr(chip.name)
            animate(chip.button,{BackgroundColor3=active and bg:Lerp(accent,.22) or bg,TextColor3=active and accent or font})
            animate(chip.stroke,{Color=active and accent or outline})
        end
        if filterChanged then
            scroll.CanvasPosition=Vector2.new(0,0)
            scroll.Position=UDim2.fromOffset(0,146) animate(scroll,{Position=UDim2.fromOffset(0,140)},.2)
        end
        clear.Visible=query~="" clear.TextColor3=font
        for _,button in ipairs({previous,power,nextButton}) do animate(button,{BackgroundColor3=bg,TextColor3=font}) end
        power.Text=tr(c.Controls.visualPresetEnabled and "Disable" or "Enable")
        status.Text=tostring(count).." / "..tostring(#cards).."  ·  "..tr(collection) status.TextColor3=font:Lerp(bg,.35)
        empty.Text=tr("No shaders found") empty.Visible=count==0 empty.TextColor3=font
        selected.Text=(c.Controls.visualPresetEnabled and "●  " or "○  ")..tostring(c.Controls.visualPreset or "") selected.TextColor3=c.Controls.visualPresetEnabled and accent or font
        scroll.ScrollBarImageColor3=accent
    end
    connect(search:GetPropertyChangedSignal("Text"),function() api:Refresh() end)
    api:Refresh(true)
    function api:Destroy() dead=true for _,tween in pairs(animations) do tween:Cancel() end animations={} end
    return api
end
