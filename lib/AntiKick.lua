-- FTAP self-protection adapter, reviewed against Resonance and Wraith source.
-- Keeps the source's self-attached NinjaShuriken mechanism; never intercepts Kick.
return function(c)
    local player,world,storage,run=c.Player,c.Workspace,c.Storage,c.Run
    local enabled,dead,busy=false,false,false
    local toy,pending,operation,phase,deadline,nextAttempt=nil,nil,0,"idle",0,0
    local lastOwnerRequest=-math.huge
    local links={}
    local lastStatus
    local function status(text)
        if text~=lastStatus then lastStatus=text if c.Status then c.Status(text) end end
    end
    local function remote(folder,name)
        local f=storage:FindFirstChild(folder)
        return f and f:FindFirstChild(name)
    end
    local function destroy(model)
        if model and model.Parent then
            local event=remote("MenuToys","DestroyToy")
            if event then pcall(function() event:FireServer(model) end) end
        end
    end
    local function detachLinks()
        for _,link in ipairs(links) do link:Disconnect() end links={}
    end
    local function clear()
        operation=operation+1 detachLinks()
        local old=toy toy=nil pending=nil phase="idle"
        destroy(old)
    end
    local function character()
        local char=player.Character
        local root=char and char:FindFirstChild("HumanoidRootPart")
        local humanoid=char and char:FindFirstChildWhichIsA("Humanoid")
        return root and root:FindFirstChild("RagdollTouchedHitbox"),root,humanoid
    end
    local function folders()
        local result={}
        local normal=world:FindFirstChild(player.Name.."SpawnedInToys")
        if normal then table.insert(result,normal) end
        local items=world:FindFirstChild("PlotItems")
        local inPlots=items and items:FindFirstChild("PlayersInPlots")
        local plots=world:FindFirstChild("Plots")
        if inPlots and inPlots:FindFirstChild(player.Name) and plots then
            for _,plot in ipairs(plots:GetChildren()) do
                local sign=plot:FindFirstChild("PlotSign")
                local owners=sign and sign:FindFirstChild("ThisPlotsOwners")
                if owners then for _,owner in ipairs(owners:GetChildren()) do
                    if owner.Value==player.Name then
                        local folder=items:FindFirstChild(plot.Name)
                        if folder and folder~=normal then table.insert(result,folder) end
                        break
                    end
                end end
            end
        end
        return result
    end
    local function retry(now,text)
        clear() nextAttempt=now+3 status(text)
    end
    local function beginSpawn(now,root)
        local spawn=remote("MenuToys","SpawnToyRemoteFunction")
        local owner=remote("GrabEvents","SetNetworkOwner")
        local attach=remote("PlayerEvents","StickyPartEvent")
        if not spawn or not owner or not attach then status("Unavailable: FTAP remotes missing") nextAttempt=now+5 return end
        local targets=folders()
        if #targets==0 then status("Waiting for toy folder") nextAttempt=now+3 return end
        local canSpawn=player:FindFirstChild("CanSpawnToy")
        if canSpawn and not canSpawn.Value then status("Waiting for toy cooldown") return end
        local token=operation
        phase="spawn" deadline=now+4 pending=nil
        local function capture(model)
            if model.Name~="NinjaShuriken" then return end
            if dead or not enabled or token~=operation then destroy(model) return end
            if not pending then pending=model toy=model end
        end
        for _,folder in ipairs(targets) do
            local link=folder.ChildAdded:Connect(capture) table.insert(links,link)
        end
        busy=true status("Preparing protection")
        task.spawn(function()
            if dead or not enabled or token~=operation then busy=false return end
            local ok,message=pcall(function() spawn:InvokeServer("NinjaShuriken",root.CFrame+Vector3.new(0,15,0),Vector3.zero) end)
            busy=false
            if token~=operation or dead or not enabled then
                if pending then destroy(pending) end
                return
            end
            if not ok then
                warn("Prime Visuals Anti-Kick: "..tostring(message))
                retry(os.clock(),"Waiting: toy spawn failed")
            end
        end)
    end
    local function hideToy()
        -- Client-only rendering change: do not change assembly, welds, mass or touch behavior.
        for _,part in ipairs(toy:GetDescendants()) do
            if part:IsA("BasePart") then part.LocalTransparencyModifier=1
            elseif part:IsA("Decal") or part:IsA("Texture") then part.Transparency=1 end
        end
    end
    local function step()
        if dead or not enabled then return end
        local now=os.clock()
        local hitbox,root,humanoid=character()
        if not hitbox or not humanoid or humanoid.Health<=0 then
            if toy or phase~="idle" then clear() end status("Waiting for character") return
        end
        local inPlot=player:FindFirstChild("InPlot") local ownPlot=player:FindFirstChild("InOwnedPlot")
        if inPlot and inPlot.Value and (not ownPlot or not ownPlot.Value) then
            if toy then clear() end status("Paused in another player's plot") return
        end
        if phase=="idle" then
            if not busy and now>=nextAttempt then beginSpawn(now,root) end
            return
        end
        if phase=="spawn" then
            if pending and pending.Parent then
                toy=pending detachLinks() phase="owner" deadline=now+2 lastOwnerRequest=-math.huge
            elseif now>=deadline and not busy then retry(now,"Waiting: toy did not appear") end
            return
        end
        if not toy or not toy.Parent then retry(now,"Restoring protection") return end
        local sticky=toy:FindFirstChild("StickyPart")
        local weld=sticky and sticky:FindFirstChild("StickyWeld")
        if not sticky or not weld then
            if now>=deadline then retry(now,"Waiting: toy incomplete") end return
        end
        if phase=="owner" then
            local owner=sticky:FindFirstChild("PartOwner")
            if owner and tostring(owner.Value)==player.Name then
                local touch=sticky:FindFirstChild("TouchInterest") if touch then touch:Destroy() end
                for _,part in ipairs(toy:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide=false part.CanQuery=false
                    end
                end
                hideToy()
                local event=remote("PlayerEvents","StickyPartEvent")
                if not event then retry(now,"Unavailable: attachment remote missing") return end
                event:FireServer(sticky,hitbox,CFrame.new(0,-.3,0)*CFrame.Angles(math.pi/2,0,0))
                phase="attach" deadline=now+.75
            elseif now>=deadline then retry(now,"Waiting: toy ownership denied")
            elseif now-lastOwnerRequest>=.15 then
                lastOwnerRequest=now local event=remote("GrabEvents","SetNetworkOwner")
                if event then event:FireServer(sticky,sticky.CFrame) end
            end
        elseif phase=="attach" then
            if weld.Part1==hitbox then phase="active" status("Attached")
            elseif now>=deadline then retry(now,"Waiting: attachment not confirmed") end
        elseif phase=="active" then
            if weld.Part1~=hitbox then retry(now,"Restoring protection") else hideToy() end
        end
    end
    local elapsed=0
    local connection=run.Heartbeat:Connect(function(dt)
        elapsed=elapsed+dt if elapsed<.1 then return end elapsed=0
        local ok,message=pcall(step)
        if not ok then retry(os.clock(),"Waiting: protection error") warn("Prime Visuals Anti-Kick: "..tostring(message)) end
    end)
    local api={}
    function api:SetEnabled(on)
        enabled=on==true if not enabled then clear() status("Off") else nextAttempt=0 status("Waiting for character") end
    end
    function api:Destroy()
        if dead then return end dead=true enabled=false connection:Disconnect() clear()
    end
    return api
end
