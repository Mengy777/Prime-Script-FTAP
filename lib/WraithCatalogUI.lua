-- Full-page shader presentation inside the existing Obsidian tab.
return function(c)
    local make=c.Make local dead=false
    local page=c.Page
    for _,side in ipairs(page.Sides) do side.Visible=false end
    local root=make("Frame",{Name="PV_ShaderPage",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(14,15,18),BorderSizePixel=0,ZIndex=2},page.Container)
    make("TextLabel",{Name="CatalogTitle",Text="Shader catalog",Position=UDim2.fromOffset(18,12),Size=UDim2.new(1,-36,0,30),
        BackgroundTransparency=1,TextColor3=Color3.fromRGB(239,240,244),Font=Enum.Font.GothamMedium,TextSize=21,TextXAlignment=Enum.TextXAlignment.Left},root)
    make("Frame",{Position=UDim2.fromOffset(16,53),Size=UDim2.new(1,-32,0,1),BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(34,36,42)},root)
    local sidebar=make("ScrollingFrame",{Name="Sidebar",Position=UDim2.fromOffset(16,66),Size=UDim2.new(0,132,1,-82),
        BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=2,Active=true},root)
    local content=make("Frame",{Name="CatalogContent",Position=UDim2.fromOffset(166,66),Size=UDim2.new(1,-184,1,-82),BackgroundTransparency=1},root)
    local api={Host=content,Sidebar=sidebar}
    function api:Refresh() end
    function api:IsOpen() return not dead and c.MenuOpen() and c.IsPageActive() end
    function api:Destroy() dead=true end
    return api
end
