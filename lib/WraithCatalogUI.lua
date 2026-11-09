-- Isolated catalog shell adapted to Wraith.dev's NeverLose-style layout/palette.
-- Not the complete third-party NeverLose runtime; no foreign loaders/config/input engine.
return function(c)
    local make,connect=c.Make,c.Connect
    local rgb=Color3.fromRGB
    local api={} local dead=false local opened=false local generation=0 local tweens={}
    local function tr(s)return c.Translate and c.Translate(s) or s end
    local screen=make("ScreenGui",{Name="PV_WraithCatalog",ResetOnSpawn=false,IgnoreGuiInset=true,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=(c.MenuGui.DisplayOrder or 100)+10,Enabled=false},c.MenuGui.Parent or c.PlayerGui)
    local shade=make("TextButton",{Name="CatalogBackdrop",Size=UDim2.fromScale(1,1),BackgroundColor3=rgb(0,0,0),
        BackgroundTransparency=.55,Text="",BorderSizePixel=0,AutoButtonColor=false,Modal=true},screen)
    local window=make("CanvasGroup",{Name="WraithWindow",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
        Size=UDim2.fromOffset(880,590),BackgroundColor3=rgb(10,13,21),BorderSizePixel=0,Active=true},screen)
    make("UICorner",{CornerRadius=UDim.new(0,9)},window)
    make("UIStroke",{Color=rgb(42,48,62),Thickness=1},window)
    local fit=make("UIScale",{Scale=1},window)
    local motion=make("UIScale",{Scale=1},make("Frame",{Name="MotionRoot",Size=UDim2.fromScale(1,1),BackgroundTransparency=1},window))
    local body=motion.Parent
    make("TextLabel",{Text="Prime Visuals",Position=UDim2.fromOffset(20,10),Size=UDim2.fromOffset(160,23),
        BackgroundTransparency=1,TextColor3=rgb(239,241,247),Font=Enum.Font.BuilderSansBold,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left},body)
    make("TextLabel",{Text=tr("Shader catalog"),Position=UDim2.fromOffset(20,35),Size=UDim2.fromOffset(180,18),
        BackgroundTransparency=1,TextColor3=rgb(140,149,169),Font=Enum.Font.BuilderSans,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},body)
    local function headerButton(name,text,x,width)
        local b=make("TextButton",{Name=name,Text=tr(text),Position=UDim2.new(1,x,0,17),Size=UDim2.fromOffset(width,30),
            BackgroundColor3=rgb(20,24,35),TextColor3=rgb(225,230,242),BorderSizePixel=0,Font=Enum.Font.BuilderSans,TextSize=13},body)
        make("UICorner",{CornerRadius=UDim.new(0,5)},b) return b
    end
    local edit=headerButton("EditShader","Edit selected preset",-214,164)
    local close=headerButton("CloseCatalog","×",-42,28)
    make("Frame",{Position=UDim2.fromOffset(0,65),Size=UDim2.new(1,0,0,1),BackgroundColor3=rgb(31,37,50),BorderSizePixel=0},body)
    local sidebar=make("Frame",{Name="Sidebar",Position=UDim2.fromOffset(14,80),Size=UDim2.new(0,148,1,-98),BackgroundTransparency=1},body)
    local content=make("Frame",{Name="CatalogContent",Position=UDim2.fromOffset(180,78),Size=UDim2.new(1,-198,1,-96),BackgroundTransparency=1},body)
    make("Frame",{Position=UDim2.fromOffset(170,66),Size=UDim2.new(0,1,1,-66),BackgroundColor3=rgb(31,37,50),BorderSizePixel=0},body)
    local function tween(object,props,time)
        if tweens[object] then tweens[object]:Cancel() end
        local t=c.TweenService:Create(object,TweenInfo.new(time,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),props)
        tweens[object]=t t:Play() return t
    end
    function api:Refresh()
        if dead then return end
        local camera=c.Workspace.CurrentCamera local view=camera and camera.ViewportSize
        if view then fit.Scale=math.min(1,math.max(.25,(view.X-24)/880),math.max(.25,(view.Y-24)/590)) end
        if opened and not c.MenuOpen() then self:Close(true) end
    end
    function api:Open()
        if dead or not c.MenuOpen() then return end
        generation=generation+1 opened=true screen.Enabled=true self:Refresh()
        c.Cursor(true)
        window.GroupTransparency=1 motion.Scale=.97
        tween(window,{GroupTransparency=0},.18) tween(motion,{Scale=1},.2)
        if self.OnOpen then self.OnOpen() end
    end
    function api:Close(immediate)
        if dead then return end
        generation=generation+1 local token=generation opened=false
        if immediate then screen.Enabled=false c.Cursor(false) return end
        tween(window,{GroupTransparency=1},.12) tween(motion,{Scale=.98},.12)
        task.delay(.13,function() if not dead and generation==token then screen.Enabled=false c.Cursor(false) end end)
    end
    function api:IsOpen()return opened end
    function api:Destroy()
        dead=true opened=false generation=generation+1 screen.Enabled=false
        c.Cursor(false)
        for _,t in pairs(tweens) do t:Cancel() end tweens={}
    end
    connect(close.Activated,function()api:Close()end)
    connect(shade.Activated,function()api:Close()end)
    connect(edit.Activated,function()api:Close(true) c.Edit()end)
    api.Host=content api.Sidebar=sidebar
    return api
end
