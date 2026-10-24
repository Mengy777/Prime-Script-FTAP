-- Snapshot of a real FTAP R6 NPC on 2026-10-24; live template values take priority.
local fallback={
    ["Head"]={Part0="Head",Part1="Torso",A0=CFrame.new(-6.10351562e-05,-0.5,6.10351562e-05,2.05039978e-05,1.18613243e-05,-0.99999994,0.866060615,-0.499938965,1.18277676e-05,-0.499938965,-0.866060615,-2.05233737e-05),A1=CFrame.new(0,1,-6.10351562e-05,-3.23057211e-05,-1.33812446e-05,-1.00000012,0.707153261,-0.707060397,-1.33837475e-05,-0.707060397,-0.707153261,3.23046879e-05),Upper=45,Twist=true,Lower=-70,UpperTwist=70},
    ["Left Arm"]={Part0="Left Arm",Part1="Torso",A0=CFrame.new(0.500183105,0.500152588,0,-0.707134247,0,0.707079291,0,1,0,-0.707079291,0,-0.707134247),A1=CFrame.new(-1.00006104,0.5,-7.62939453e-06,-1,0,0,0,1,0,0,0,-1),Upper=70,Twist=false,Lower=-30,UpperTwist=30},
    ["Right Arm"]={Part0="Right Arm",Part1="Torso",A0=CFrame.new(-0.500244141,0.500366211,3.05175781e-05,0.707134247,0,0.707079291,0,1,0,-0.707079291,0,0.707134247),A1=CFrame.new(0.99987793,0.500030518,-9.15527344e-05,1,0,0,0,1,0,0,0,1),Upper=70,Twist=false,Lower=-30,UpperTwist=30},
    ["Left Leg"]={Part0="Torso",Part1="Left Leg",A0=CFrame.new(-0.50012207,-1.00012207,0.000152587891,-0.172267437,-0.0889421925,0.981026649,-0.860576391,0.498179466,-0.10595037,-0.479303837,-0.862500191,-0.162361652),A1=CFrame.new(6.10351562e-05,1.00021362,6.10351562e-05,0,0,1,-1,0,0,0,-1,0),Upper=80,Twist=true,Lower=-15,UpperTwist=15},
    ["Right Leg"]={Part0="Torso",Part1="Right Leg",A0=CFrame.new(0.500061035,-0.999969482,2.28881836e-05,0.224196196,0.129431441,0.965910912,-0.851237178,0.508569539,0.129431471,-0.474480271,-0.851237178,0.224196211),A1=CFrame.new(0.000183105469,1.00009155,0,0,0,1,-1,0,0,0,-1,0),Upper=80,Twist=true,Lower=-15,UpperTwist=15},
}

return function(model,context)
    local Workspace=context.Workspace
    local humanoid=model:FindFirstChildOfClass("Humanoid")
    local root=model:FindFirstChild("HumanoidRootPart")
    assert(humanoid and root and model:FindFirstChild("Torso"),"Mannequin ragdoll requires an R6 model")
    local actor={Model=model,Active=false,Destroyed=false,SoundsEnabled=context.SoundsEnabled~=false,
        Motors={},Sockets={},Colliders={},Connections={},Bodies={},Age=0,Settled=0,Speed=0,Clock=0,LastHit=-10,LastScream=-10}
    local template=context.Template
    local original={PlatformStand=humanoid.PlatformStand,AutoRotate=humanoid.AutoRotate,
        RequiresNeck=humanoid.RequiresNeck,GettingUp=humanoid:GetStateEnabled(Enum.HumanoidStateType.GettingUp)}
    local function scaleFrame(cf,source,target)
        if source.Size==target.Size then return cf end
        local p=cf.Position
        return CFrame.new(p.X*target.Size.X/source.Size.X,p.Y*target.Size.Y/source.Size.Y,p.Z*target.Size.Z/source.Size.Z)*cf.Rotation
    end
    local flag=Instance.new("BoolValue") flag.Name="Ragdolled" flag.Parent=humanoid
    for _,part in ipairs(model:GetChildren()) do
        if part:IsA("BasePart") then
            table.insert(actor.Bodies,part)
            part.CanCollide=part.Name=="Torso" or part.Name=="Head"
            part.CanTouch=part.Name=="Torso" or part.Name=="Head"
            local source=template and template:FindFirstChild(part.Name)
            if source and source:IsA("BasePart") then
                part.CollisionGroup=source.CollisionGroup
                part.CustomPhysicalProperties=source.CustomPhysicalProperties
            end
        end
    end
    local rootJoint
    for _,motor in ipairs(model:GetDescendants()) do
        if motor:IsA("Motor6D") and motor.Part0 and motor.Part1 and fallback[motor.Part1.Name] then
            local cfg=fallback[motor.Part1.Name]
            local sourcePart=template and template:FindFirstChild(motor.Part1.Name)
            local sourceSocket=sourcePart and sourcePart:FindFirstChildOfClass("BallSocketConstraint")
            local socket=sourceSocket and sourceSocket:Clone() or Instance.new("BallSocketConstraint")
            socket.Enabled=false socket.Name="BallSocketConstraint"
            local function attachment(which,partName,frame)
                local src=sourceSocket and sourceSocket[which]
                local part=src and model:FindFirstChild(src.Parent.Name) or model:FindFirstChild(partName)
                local att=Instance.new("Attachment") att.Name="PV_"..motor.Name..which
                att.CFrame=src and scaleFrame(src.CFrame,src.Parent,part) or frame att.Parent=part
                return att
            end
            socket.Attachment0=attachment("Attachment0",cfg.Part0,cfg.A0)
            socket.Attachment1=attachment("Attachment1",cfg.Part1,cfg.A1)
            if not sourceSocket then
                socket.LimitsEnabled=true socket.UpperAngle=cfg.Upper
                socket.TwistLimitsEnabled=cfg.Twist socket.TwistLowerAngle=cfg.Lower socket.TwistUpperAngle=cfg.UpperTwist
                socket.MaxFrictionTorque=20 socket.Restitution=0 socket.Radius=0.15
            end
            socket.Parent=motor.Part1
            table.insert(actor.Sockets,socket)
            table.insert(actor.Motors,{Motor=motor,Enabled=motor.Enabled})
        elseif motor:IsA("Motor6D") and motor.Part0==root then rootJoint=motor end
    end
    assert(#actor.Sockets==5 and rootJoint,"Incomplete R6 joints")
    table.insert(actor.Motors,1,{Motor=rootJoint,Enabled=rootJoint.Enabled})
    local weld=Instance.new("WeldConstraint") weld.Name="WeldHRP" weld.Enabled=false
    weld.Part0=root weld.Part1=model:FindFirstChild("Torso") weld.Parent=root
    for _,name in ipairs({"Left Arm","Right Arm","Left Leg","Right Leg"}) do
        local part=model:FindFirstChild(name)
        local sourcePart=template and template:FindFirstChild(name)
        local source=sourcePart and sourcePart:FindFirstChild("RagdollLimbPart")
        local collider=Instance.new("Part") collider.Name="RagdollLimbPart"
        collider.Size=source and source.Size or Vector3.new(name:find("Leg",1,true) and 1.125 or 0.75,0.75,0.75)
        collider.CFrame=part.CFrame*(source and sourcePart.CFrame:ToObjectSpace(source.CFrame) or CFrame.new(0,-0.5,0))
        collider.Transparency=1 collider.Massless=true collider.CanCollide=false collider.CanQuery=false collider.CanTouch=true
        collider.CollisionGroup=part.CollisionGroup
        collider.CustomPhysicalProperties=source and source.CustomPhysicalProperties or PhysicalProperties.new(0.01,0.3,0.5,1,1)
        collider.Parent=part
        local joint=Instance.new("WeldConstraint") joint.Part0=collider joint.Part1=part joint.Parent=collider
        table.insert(actor.Colliders,collider)
    end
    -- No self-collisions, independent of the map's collision-group matrix.
    local collisionParts={}
    for _,p in ipairs(actor.Bodies) do if p.CanCollide then table.insert(collisionParts,p) end end
    for _,p in ipairs(actor.Colliders) do table.insert(collisionParts,p) end
    for i=1,#collisionParts-1 do for j=i+1,#collisionParts do
        local nc=Instance.new("NoCollisionConstraint") nc.Part0=collisionParts[i] nc.Part1=collisionParts[j] nc.Parent=root
    end end
    local function sound(name,id,rate,minimum)
        local sourceRoot=template and template:FindFirstChild("HumanoidRootPart")
        local source=sourceRoot and sourceRoot:FindFirstChild(name)
        local s=Instance.new("Sound") s.Name=name s.Parent=root
        s.SoundId=source and source.SoundId or id s.Volume=source and source.Volume or 0.25
        s.PlaybackSpeed=source and source.PlaybackSpeed or rate s.Looped=false
        s.RollOffMinDistance=source and source.RollOffMinDistance or minimum
        s.RollOffMaxDistance=source and source.RollOffMaxDistance or 200
        return s
    end
    actor.Scream=sound("Scream","rbxassetid://89342465",1,15)
    actor.Hit=sound("RagdollHit","rbxassetid://96626016",2,5)
    local function scream()
        if actor.SoundsEnabled and actor.Clock-actor.LastScream>=3 and not actor.Scream.IsPlaying then
            actor.LastScream=actor.Clock actor.Scream:Play()
        end
    end
    function actor:SetSounds(on)
        self.SoundsEnabled=on
        if not on then self.Scream:Stop() self.Hit:Stop() end
    end
    function actor:SetActive(on)
        if self.Destroyed or self.Active==on then return end
        self.Active=on flag.Value=on self.Settled=0 self.Age=0
        if on then
            humanoid.RequiresNeck=false humanoid.AutoRotate=false humanoid.PlatformStand=true
            humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
            for _,entry in ipairs(self.Motors) do entry.Motor.Enabled=false end
            weld.Enabled=true
            for _,socket in ipairs(self.Sockets) do socket.Enabled=true end
            for _,collider in ipairs(self.Colliders) do collider.CanCollide=true end
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        else
            weld.Enabled=false
            for _,socket in ipairs(self.Sockets) do socket.Enabled=false end
            for _,collider in ipairs(self.Colliders) do collider.CanCollide=false end
            local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={model}
            local ground=Workspace:Raycast(root.Position,Vector3.new(0,-5,0),params)
            local leg=model:FindFirstChild("Left Leg")
            local y=ground and ground.Position.Y+root.Size.Y/2+(leg and leg.Size.Y or 2)+humanoid.HipHeight+0.1 or root.Position.Y
            local look=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z)
            if look.Magnitude<0.01 then look=Vector3.new(0,0,-1) else look=look.Unit end
            local pos=Vector3.new(root.Position.X,y,root.Position.Z)
            root.CFrame=CFrame.lookAt(pos,pos+look)
            for _,entry in ipairs(self.Motors) do
                local m=entry.Motor m.Part1.CFrame=m.Part0.CFrame*m.C0*m.C1:Inverse()
                m.Enabled=entry.Enabled
            end
            for _,part in ipairs(self.Bodies) do part.AssemblyLinearVelocity=Vector3.zero part.AssemblyAngularVelocity=Vector3.zero end
            humanoid.RequiresNeck=original.RequiresNeck humanoid.AutoRotate=original.AutoRotate
            humanoid.PlatformStand=original.PlatformStand humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,original.GettingUp)
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            self.Scream:Stop()
        end
    end
    function actor:Released(thrown)
        self.Settled=0 self.Age=0
        if thrown then scream() end
    end
    local function impact(other)
        if actor.Destroyed or not actor.Active or other:IsDescendantOf(model) then return end
        if actor.SoundsEnabled and actor.Clock-actor.LastHit>=0.25 and actor.Speed>10 then
            actor.LastHit=actor.Clock actor.Hit:Play()
        end
    end
    for _,part in ipairs(collisionParts) do
        if part.CanTouch then table.insert(actor.Connections,part.Touched:Connect(impact)) end
    end
    function actor:Step(dt,isHeld)
        if self.Destroyed or not root.Parent then return end
        self.Clock=self.Clock+dt self.Age=self.Age+dt
        local speed=0
        for _,part in ipairs(self.Bodies) do if part.Parent then speed=math.max(speed,part.AssemblyLinearVelocity.Magnitude) end end
        self.Speed=speed
        if not self.Active and speed>30 then self:SetActive(true) end
        if not self.Active then return end
        if speed>35 then scream() end
        if isHeld or speed>4 then self.Settled=0 return end
        local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={model}
        local ground=Workspace:Raycast(root.Position,Vector3.new(0,-5,0),params)
        self.Settled=ground and self.Settled+dt or 0
        if self.Age>=1.2 and self.Settled>=1 then self:SetActive(false) end
    end
    function actor:Destroy()
        if self.Destroyed then return end
        self.Destroyed=true
        for _,c in ipairs(self.Connections) do c:Disconnect() end self.Connections={}
        if self.Scream.Parent then self.Scream:Stop() end
        if self.Hit.Parent then self.Hit:Stop() end
    end
    return actor
end
