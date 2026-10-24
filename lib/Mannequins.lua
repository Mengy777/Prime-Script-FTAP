-- Prime Visuals: client-only mannequins. No game remotes or player character edits.
return function(context)
    local Players, Workspace = context.Players, context.Workspace
    local UIS, Run = context.Input, context.Run
    local self={Enabled=false,Interactive=true,PhysicsEnabled=true,SoundsEnabled=true,Destroyed=false,Models={},Actors={},Connections={},Serial=0,Busy=false}
    local folder,held,rotating
    local function message(en,ru) context.Notify(en,ru) end
    local function validRequest(id) return not self.Destroyed and self.Enabled and self.Serial==id end
    local function prune()
        for i=#self.Models,1,-1 do
            local model=self.Models[i]
            if not model.Parent or not model:FindFirstChild("HumanoidRootPart") then
                if self.Actors[model] then self.Actors[model]:Destroy() self.Actors[model]=nil end
                model:Destroy() table.remove(self.Models,i)
            end
        end
    end
    local function release(throw)
        if not held then return end
        local old=held held=nil rotating=false
        for _,object in ipairs(old.Constraints) do object:Destroy() end
        if old.Root.Parent then
            if throw and Workspace.CurrentCamera then
                local velocity=Workspace.CurrentCamera.CFrame.LookVector*80+Vector3.new(0,12,0)
                for _,part in ipairs(old.Model:GetChildren()) do if part:IsA("BasePart") then part.AssemblyLinearVelocity=velocity end end
            end
            local humanoid=old.Humanoid
            local actor=self.Actors[old.Model]
            if actor and self.PhysicsEnabled then actor:Released(throw)
            elseif humanoid.Parent then
                humanoid.PlatformStand=old.PlatformStand
                if throw then humanoid:ChangeState(Enum.HumanoidStateType.Freefall) end
            end
        end
    end
    local function raycast(origin,direction,excluded)
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances=excluded
        return Workspace:Raycast(origin,direction,params)
    end
    local function spawnPosition(model)
        local camera=Workspace.CurrentCamera
        local player=Players.LocalPlayer
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        assert(camera and root,"Character is not ready")
        local look=Vector3.new(camera.CFrame.LookVector.X,0,camera.CFrame.LookVector.Z)
        if look.Magnitude<0.01 then look=Vector3.new(0,0,-1) else look=look.Unit end
        local point=root.Position+look*7
        local ignore={model,folder}
        if player.Character then table.insert(ignore,player.Character) end
        local ground=raycast(point+Vector3.new(0,20,0),Vector3.new(0,-100,0),ignore)
        local box,size=model:GetBoundingBox()
        local footOffset=model:GetPivot().Position.Y-(box.Position.Y-size.Y/2)
        local y=ground and ground.Position.Y+footOffset+0.2 or point.Y+2
        local position=Vector3.new(point.X,y,point.Z)
        return CFrame.lookAt(position,position-look)
    end
    local function configure(model,grey)
        local humanoid=model:FindFirstChildOfClass("Humanoid")
        local root=model:FindFirstChild("HumanoidRootPart")
        assert(humanoid and root,"Avatar has no humanoid/root")
        model.PrimaryPart=root
        humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
        humanoid.WalkSpeed=0 humanoid.JumpPower=0 humanoid.AutoRotate=false
        humanoid.BreakJointsOnDeath=false
        for _,object in ipairs(model:GetDescendants()) do
            if object:IsA("BaseScript") then object:Destroy()
            elseif object:IsA("BasePart") then
                object.Anchored=false object.CanTouch=false
                object.CanCollide=object~=root and not object:FindFirstAncestorOfClass("Accessory")
                if grey then object.Color=Color3.fromRGB(163,162,165) object.Material=Enum.Material.SmoothPlastic end
            elseif grey and (object:IsA("Decal") or object:IsA("Texture")) then object:Destroy() end
        end
        root.CanCollide=false
    end
    local function requestModel(username,replacement)
        if not self.Enabled or self.Destroyed then return end
        if self.Busy then message("An avatar is already loading.","Аватар уже загружается.") return end
        prune()
        if not replacement and #self.Models>=10 then
            message("Limit: 10 local mannequins. Delete one first.","Лимит: 10 локальных манекенов. Удали одного.") return
        end
        local name=tostring(username or ""):gsub("^%s*",""):gsub("%s*$",""):gsub("^@","")
        if name~="" and (#name>20 or name:find("[^%w_]")) then
            message("Enter a Roblox username, not a display name.","Введи Roblox-ник, а не отображаемое имя.") return
        end
        self.Serial=self.Serial+1
        local id=self.Serial
        self.Busy=true
        task.spawn(function()
            local candidate,candidateActor
            local ok,err=pcall(function()
                local description
                if name=="" then
                    description=Instance.new("HumanoidDescription")
                    local grey=Color3.fromRGB(163,162,165)
                    for _,property in ipairs({"HeadColor","TorsoColor","LeftArmColor","RightArmColor","LeftLegColor","RightLegColor"}) do description[property]=grey end
                else
                    local userId=Players:GetUserIdFromNameAsync(name)
                    if not validRequest(id) then return end
                    description=Players:GetHumanoidDescriptionFromUserIdAsync(userId)
                end
                if not validRequest(id) then description:Destroy() return end
                local created,result=pcall(function() return Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R6) end)
                description:Destroy()
                assert(created,result) candidate=result
                if not validRequest(id) then return end
                if replacement and not replacement.Parent then return end
                configure(candidate,name=="")
                local position=replacement and replacement:GetPivot() or spawnPosition(candidate)
                if replacement and self.Actors[replacement] and self.Actors[replacement].Active then
                    local ground=raycast(position.Position+Vector3.new(0,20,0),Vector3.new(0,-100,0),{folder,candidate})
                    if ground then
                        local box,size=candidate:GetBoundingBox()
                        local height=candidate:GetPivot().Position.Y-box.Position.Y+size.Y/2
                        position=CFrame.new(position.Position.X,ground.Position.Y+height+0.2,position.Position.Z)*position.Rotation
                    end
                end
                candidate.Name="PV_Mannequin_"..(name~="" and name or "Grey")
                candidate:PivotTo(position)
                candidateActor=context.RagdollFactory(candidate,{Workspace=Workspace,Template=Players.LocalPlayer.Character,SoundsEnabled=self.SoundsEnabled})
                candidate.Parent=folder
                self.Actors[candidate]=candidateActor
                if replacement then
                    if held and held.Model==replacement then release(false) end
                    for i,model in ipairs(self.Models) do if model==replacement then self.Models[i]=candidate break end end
                    if self.Actors[replacement] then self.Actors[replacement]:Destroy() self.Actors[replacement]=nil end
                    replacement:Destroy()
                else table.insert(self.Models,candidate) end
                candidate=nil candidateActor=nil
            end)
            if candidateActor then candidateActor:Destroy() end
            if candidate then self.Actors[candidate]=nil candidate:Destroy() end
            if self.Serial==id then self.Busy=false end
            if not ok and validRequest(id) then
                warn("Prime Visuals mannequins: "..tostring(err))
                message("Could not create avatar. Check the username and try again.","Не удалось создать аватар. Проверь ник и попробуй ещё раз.")
            end
        end)
    end
    function self:Spawn(username) requestModel(username) end
    function self:ApplyToLast(username)
        prune()
        if #self.Models==0 then message("Spawn a mannequin first.","Сначала создай манекена.") return end
        requestModel(username,self.Models[#self.Models])
    end
    function self:Clear()
        self.Serial=self.Serial+1 self.Busy=false release(false)
        for _,actor in pairs(self.Actors) do actor:Destroy() end self.Actors={}
        for _,model in ipairs(self.Models) do model:Destroy() end
        self.Models={}
    end
    function self:DeleteLast()
        self.Serial=self.Serial+1 self.Busy=false prune()
        local model=table.remove(self.Models)
        if model then
            if held and held.Model==model then release(false) end
            if self.Actors[model] then self.Actors[model]:Destroy() self.Actors[model]=nil end
            model:Destroy()
        end
    end
    function self:SetPhysics(on)
        self.PhysicsEnabled=on
        if not on then for _,actor in pairs(self.Actors) do actor:SetActive(false) end end
    end
    function self:SetSounds(on)
        self.SoundsEnabled=on
        for _,actor in pairs(self.Actors) do actor:SetSounds(on) end
    end
    function self:SetInteractive(on) self.Interactive=on if not on then release(false) end end
    function self:SetEnabled(on)
        if self.Destroyed then return end
        if on==self.Enabled then return end
        self.Enabled=on
        if not on then
            self:Clear()
            for _,connection in ipairs(self.Connections) do connection:Disconnect() end
            self.Connections={}
            if folder then folder:Destroy() folder=nil end
            return
        end
        folder=Instance.new("Folder") folder.Name="PV_LocalMannequins" folder.Parent=Workspace
        local function connect(signal,fn) table.insert(self.Connections,signal:Connect(fn)) end
        connect(UIS.InputBegan,function(input,processed)
            if processed or context.MenuOpen() or UIS:GetFocusedTextBox() or not self.Interactive then return end
            if input.UserInputType==Enum.UserInputType.MouseButton1 then
                if held then release(false) return end
                local camera=Workspace.CurrentCamera
                if not camera then return end
                local mouse=UIS:GetMouseLocation()
                local ray=camera:ScreenPointToRay(mouse.X,mouse.Y)
                local ignore={}
                if Players.LocalPlayer.Character then table.insert(ignore,Players.LocalPlayer.Character) end
                local hit=raycast(ray.Origin,ray.Direction*60,ignore)
                if not hit then return end
                local model
                for _,candidate in ipairs(self.Models) do if hit.Instance:IsDescendantOf(candidate) then model=candidate break end end
                if not model then return end
                local root=model:FindFirstChild("HumanoidRootPart")
                local humanoid=model:FindFirstChildOfClass("Humanoid")
                if not root or not humanoid then return end
                local actor=self.Actors[model]
                if actor and self.PhysicsEnabled then actor:SetActive(true) end
                local part=hit.Instance:IsA("BasePart") and hit.Instance or root
                local attachment=Instance.new("Attachment") attachment.Position=part.CFrame:PointToObjectSpace(hit.Position) attachment.Parent=part
                local position=Instance.new("AlignPosition")
                position.Mode=Enum.PositionAlignmentMode.OneAttachment position.Attachment0=attachment
                position.MaxForce=math.max(10000,root.AssemblyMass*5000) position.MaxVelocity=100
                position.Responsiveness=30 position.ApplyAtCenterOfMass=false position.Position=hit.Position position.Parent=part
                local orientation=Instance.new("AlignOrientation")
                orientation.Mode=Enum.OrientationAlignmentMode.OneAttachment orientation.Attachment0=attachment
                orientation.MaxTorque=math.max(10000,root.AssemblyMass*5000) orientation.Responsiveness=25
                orientation.CFrame=part.CFrame.Rotation orientation.Parent=part
                held={Model=model,Root=root,Part=part,Humanoid=humanoid,PlatformStand=humanoid.PlatformStand,
                    Distance=math.clamp((hit.Position-camera.CFrame.Position).Magnitude,4,50),
                    Position=position,Orientation=orientation,Rotation=part.CFrame.Rotation,
                    Constraints={position,orientation,attachment}}
                humanoid.PlatformStand=true
            elseif input.UserInputType==Enum.UserInputType.MouseButton2 then release(true)
            elseif input.KeyCode==Enum.KeyCode.R and held then rotating=true end
        end)
        connect(UIS.InputEnded,function(input) if input.KeyCode==Enum.KeyCode.R then rotating=false end end)
        connect(UIS.InputChanged,function(input)
            if held and not context.MenuOpen() and input.UserInputType==Enum.UserInputType.MouseWheel then
                held.Distance=math.clamp(held.Distance+input.Position.Z*2,4,50)
            end
        end)
        connect(UIS.WindowFocusReleased,function() release(false) end)
        connect(Players.LocalPlayer.CharacterRemoving,function() release(false) end)
        local physicsElapsed=0
        connect(Run.Heartbeat,function(dt)
            physicsElapsed=physicsElapsed+dt
            if physicsElapsed<0.1 then return end
            local elapsed=physicsElapsed physicsElapsed=0
            if self.PhysicsEnabled then
                for model,actor in pairs(self.Actors) do
                    if model.Parent then actor:Step(elapsed,held and held.Model==model) end
                end
            end
        end)
        connect(Run.RenderStepped,function()
            if not held then return end
            local camera=Workspace.CurrentCamera
            if context.MenuOpen() or not camera or not held.Root.Parent or not held.Part.Parent then release(false) return end
            if rotating then
                local delta=UIS:GetMouseDelta()
                held.Rotation=CFrame.fromAxisAngle(camera.CFrame.UpVector,delta.X*0.01)
                    *CFrame.fromAxisAngle(camera.CFrame.RightVector,delta.Y*0.01)*held.Rotation
            end
            held.Position.Position=camera.CFrame.Position+camera.CFrame.LookVector*held.Distance
            held.Orientation.CFrame=held.Rotation
        end)
    end
    function self:Destroy()
        if self.Destroyed then return end
        self:SetEnabled(false) self.Destroyed=true
    end
    return self
end
