-- Experimental LOCAL world-space UI. No server remotes or replicated objects.
return function(c)
    local v=c.Controls local api={} local dead=false local shown=false
    local part,gui,line,origin,endpoint,sourcePart,targetPart
    local rows={} local entries={} local page=1 local tab="Controls"
    local drag,captured,lastHit,hovered local elapsed=0 local signature
    local connections={} local action="PrimePhysicalMenu" local actions=c.Actions
    local function tr(s)return c.Translate and c.Translate(s) or s end
    local function make(class,props,parent)return c.Make(class,props,parent)end
    local function remove(o)if o then o:Destroy()end end
    local function stopLine()if line then line.Enabled=false end end
    local function cleanup()
        actions:UnbindAction(action) c.Unpatch("physicalMenuCursor")
        drag=nil captured=false lastHit=nil hovered=nil stopLine()
        remove(part) remove(sourcePart) remove(targetPart)
        part=nil gui=nil line=nil sourcePart=nil targetPart=nil origin=nil endpoint=nil rows={}
    end
    local function label(text,x,y,w,h,size,parent)
        return make("TextLabel",{Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,
            TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextSize=size or 21,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},parent or gui)
    end
    local function button(text,x,y,w,h,fn)
        local b=make("TextLabel",{Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
            BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=v.worldMenuTransparency or .75,BorderSizePixel=0,TextColor3=Color3.new(1,1,1),
            Font=Enum.Font.Gotham,TextSize=20,TextWrapped=true},gui)
        make("UICorner",{CornerRadius=UDim.new(0,6)},b)
        rows[#rows+1]={x=x,y=y,w=w,h=h,fn=fn,node=b}
    end
    local function collect()
        entries={}
        if tab=="Shaders" then
            local values=c.Specs.visualPreset and c.Specs.visualPreset.Values or {}
            for _,name in ipairs(values) do entries[#entries+1]={key="visualPreset",name=name,kind="Shader"} end
        else
            for key,spec in pairs(c.Specs) do
                if key~="worldMenuEnabled" and key:sub(1,5)~="bind_" and (spec.Kind=="Toggle" or spec.Kind=="Slider" or
                    (spec.Kind=="Dropdown" and type(v[key])~="table")) then
                    local widget=c.Widgets[key]
                    local name=widget and (widget.Text or (widget.Info and widget.Info.Text)) or key
                    entries[#entries+1]={key=key,name=tostring(name or key),kind=spec.Kind,spec=spec}
                end
            end
            table.sort(entries,function(a,b)return a.name==b.name and a.key<b.key or a.name<b.name end)
        end
    end
    local function rebuild()
        if not gui then return end
        for _,child in ipairs(gui:GetChildren()) do child:Destroy() end rows={}
        collect() page=math.clamp(page,1,math.max(1,math.ceil(#entries/8)))
        label("Prime Visuals  ·  "..tr("Physical menu"),25,7,785,55,27)
        button("×",920,12,55,45,function()api:SetVisible(false)end)
        button(tr("Functions"),25,77,220,45,function()tab="Controls" page=1 rebuild()end)
        button(tr("Shaders"),255,77,220,45,function()tab="Shaders" page=1 rebuild()end)
        button(tr("2D menu"),755,77,220,45,function()c.Setters.worldMenuEnabled(false,true)end)
        local state={tab,tostring(page)}
        for i=1,8 do
            local entry=entries[(page-1)*8+i] if not entry then break end
            local key=entry.key local value=v[key] local y=134+(i-1)*61
            state[#state+1]=key..":"..tostring(value)
            if entry.kind=="Toggle" then
                button((value and "[ON]  " or "[OFF]  ")..tr(entry.name),25,y,950,53,function()c.Setters[key](not v[key],true) rebuild()end)
            elseif entry.kind=="Shader" then
                button((v.visualPreset==entry.name and "●  " or "")..entry.name,25,y,950,53,function()
                    c.Setters.visualPreset(entry.name,true) c.Setters.visualPresetEnabled(true,true) rebuild()
                end)
            else
                label(tr(entry.name).."  :  "..tostring(value),32,y,760,53,19)
                local function change(direction)
                    local spec=entry.spec
                    if entry.kind=="Slider" then
                        local step=(spec.Max-spec.Min)/20
                        c.Setters[key](math.clamp((tonumber(v[key]) or spec.Min)+step*direction,spec.Min,spec.Max),true)
                    else
                        local values=spec.Values or {} if #values==0 then return end
                        local current=table.find(values,v[key]) or 1
                        c.Setters[key](values[((current-1+direction)%#values)+1],true)
                    end rebuild()
                end
                button("−",805,y,78,53,function()change(-1)end) button("+",895,y,78,53,function()change(1)end)
            end
        end
        button("←",25,641,120,49,function()page=page-1 rebuild()end)
        label(tostring(page).." / "..tostring(math.max(1,math.ceil(#entries/8))),170,641,180,49,20)
        label(tr("Aim + LMB · drag the header"),350,641,470,49,17)
        button("→",855,641,120,49,function()page=page+1 rebuild()end)
        signature=table.concat(state,"|")
    end
    local function ray()
        local camera=c.Workspace.CurrentCamera if not camera then return end
        return camera.CFrame.Position,camera.CFrame.LookVector
    end
    local function hit()
        if not part or not part.Parent then return end
        local from,direction=ray() if not from then return end
        local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
        local character=c.Players.LocalPlayer.Character
        local ignored={}
        if character then ignored[#ignored+1]=character end
        if sourcePart then ignored[#ignored+1]=sourcePart end
        if targetPart then ignored[#ignored+1]=targetPart end
        params.FilterDescendantsInstances=ignored
        local result=c.Workspace:Raycast(from,direction*70,params)
        if not result or result.Instance~=part then return end
        local point=part.CFrame:PointToObjectSpace(result.Position)
        if point.Z>0 then return end
        -- Front face: world-space right is negative local X when facing the viewer.
        return (.5-point.X/part.Size.X)*1000,(.5-point.Y/part.Size.Y)*720,result.Position
    end
    local function ensureLine()
        if line then return end
        local props={Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Transparency=1,Size=Vector3.new(.05,.05,.05)}
        sourcePart=make("Part",props,c.Workspace) targetPart=make("Part",props,c.Workspace)
        origin=make("Attachment",{},sourcePart) endpoint=make("Attachment",{},targetPart)
        line=make("Beam",{Name="PV_PhysicalMenuLine",Attachment0=origin,Attachment1=endpoint,Width0=.025,Width1=.025,
            FaceCamera=true,Color=ColorSequence.new(Color3.new(1,1,1)),Transparency=NumberSequence.new(.05),Enabled=false},sourcePart)
        local template=c.BeamTemplate and c.BeamTemplate()
        if template then for _,property in ipairs({"Color","Transparency","Width0","Width1","Texture","TextureLength","TextureSpeed","LightEmission","Segments"}) do
            pcall(function()line[property]=template[property]end)
        end end
    end
    local function bind()
        actions:BindActionAtPriority(action,function(_,state)
            if not shown or dead then return Enum.ContextActionResult.Pass end
            if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then
                local sink=captured captured=false drag=nil stopLine()
                return sink and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
            end
            if state~=Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
            local x,y,position=hit() if not x or x<0 or x>1000 or y<0 or y>720 then return Enum.ContextActionResult.Pass end
            captured=true lastHit=position
            if y<70 and x<900 then
                local from=ray()
                drag={depth=(position-from).Magnitude,offset=position-part.CFrame.Position,rotation=part.CFrame-part.CFrame.Position}
            else
                for _,row in ipairs(rows) do if x>=row.x and x<=row.x+row.w and y>=row.y and y<=row.y+row.h then
                    c.Safe(row.fn) break
                end end
            end
            return Enum.ContextActionResult.Sink
        end,false,6000,Enum.UserInputType.MouseButton1)
    end
    function api:IsVisible()return shown end
    function api:SetVisible(on)
        if dead then return end shown=on==true cleanup()
        if not shown then return end
        local camera=c.Workspace.CurrentCamera if not camera then shown=false return end
        local scale=v.worldMenuScale or 1
        part=make("Part",{Name="PV_PhysicalMenu",Size=Vector3.new(12*scale,8.64*scale,.08),Anchored=true,
            CanCollide=false,CanTouch=false,CanQuery=true,Transparency=v.worldMenuTransparency or .75,
            Color=Color3.new(0,0,0),Material=Enum.Material.SmoothPlastic,
            CFrame=camera.CFrame*CFrame.new(0,0,-(v.worldMenuDistance or 9))*CFrame.Angles(0,math.pi,0)},c.Workspace)
        gui=make("SurfaceGui",{Name="PV_PhysicalMenuSurface",Face=Enum.NormalId.Front,SizingMode=Enum.SurfaceGuiSizingMode.FixedSize,
            CanvasSize=Vector2.new(1000,720),AlwaysOnTop=false,LightInfluence=0,Active=false},part)
        c.Patch("physicalMenuCursor",c.Input,"MouseIconEnabled",false)
        rebuild() bind()
    end
    function api:Configure()
        if part then
            local scale=v.worldMenuScale or 1 part.Size=Vector3.new(12*scale,8.64*scale,.08)
            part.Transparency=v.worldMenuTransparency or .75
        end
    end
    connections[#connections+1]=c.Run.RenderStepped:Connect(function(dt)
        if dead or not shown then return end
        if not part or not part.Parent then api:SetVisible(false) return end
        if drag then
            local from,direction=ray()
            if from then part.CFrame=CFrame.new(from+direction*drag.depth-drag.offset)*drag.rotation end
        end
        local x,y,position=hit() local target
        if x then for _,row in ipairs(rows) do if x>=row.x and x<=row.x+row.w and y>=row.y and y<=row.y+row.h then target=row break end end end
        if hovered~=target then
            if hovered and hovered.node.Parent then hovered.node.BackgroundTransparency=v.worldMenuTransparency or .75 end
            hovered=target if hovered then hovered.node.BackgroundTransparency=math.max(0,(v.worldMenuTransparency or .75)-.2) end
        end
        if position or captured then
            ensureLine() local from=ray()
            if from then sourcePart.Position=from+Vector3.new(.35,-.3,0) targetPart.Position=position or lastHit or part.CFrame.Position line.Enabled=true end
        else stopLine()end
        elapsed=elapsed+(dt or 0)
        if elapsed>=.25 then elapsed=0
            local state={tab,tostring(page)}
            for i=1,8 do local e=entries[(page-1)*8+i] if e then state[#state+1]=e.key..":"..tostring(v[e.key])end end
            if table.concat(state,"|")~=signature then rebuild()end
        end
    end)
    if c.Input.WindowFocusReleased then connections[#connections+1]=c.Input.WindowFocusReleased:Connect(function()
        drag=nil captured=false stopLine()
    end)end
    function api:Destroy()
        if dead then return end dead=true shown=false cleanup()
        for _,link in ipairs(connections)do link:Disconnect()end connections={}
    end
    return api
end
