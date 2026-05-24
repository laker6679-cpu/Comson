--// Repo
loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// Чат всегда видимый
pcall(function()
    game:GetService("CoreGui").ExperienceChat:WaitForChild("appLayout"):WaitForChild("chatInputBar").Visible = true
end)



if not table.find(AllowedUsers, LocalPlayer.UserId) then
    LocalPlayer:Kick("❌ HWID Lock: Access Denied")
    while true do task.wait(1) end
end

--// Load UI Library
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

--// Window
local Window = Library:CreateWindow({
    Title = "FrendlyHub",
    Footer = "Camson",
    NotifySide = "Right",
    CornerRadius = 30,
    Transparency = 0.95,
    Outline = true,
    AccentColor = Color3.fromRGB(255, 255, 255)
})

--// Tabs
local Tabs = {
    Main = Window:AddTab("Main", "run"),
    Defens = Window:AddTab("Defens", "shield"),
    Target = Window:AddTab("Target", "target"),
    Visual = Window:AddTab("Visual", "eye"),
    Fun = Window:AddTab("Fun", "smile"),
    Misc = Window:AddTab("Misc", "palette"),
    ["UI Settings"] = Window:AddTab("Settings", "settings")
}

--// UI SETTINGS
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = true,
    Text = "Open Keybind Menu",
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end
})

Library.KeybindFrame.Visible = true

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        if DPI then
            Library:SetDPIScale(DPI)
        end
    end
})

MenuGroup:AddSlider("UICornerSlider", {
    Text = "Corner Radius",
    Default = 30,
    Min = 0,
    Max = 30,
    Rounding = 0,
    Callback = function(Value)
        Window:SetCornerRadius(Value)
    end
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu Bind")
    :AddKeyPicker("MenuKeybind", {
        Default = "С",
        NoUI = true,
        Text = "Menu Keybind"
    })

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

--// Managers
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("FrendlyHub")
SaveManager:SetFolder("FrendlyHub")
SaveManager:SetSubFolder("specific-place")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

pcall(function()
    ThemeManager:SetTheme("Dark")
    ThemeManager:SetAccentColor(Color3.fromRGB(255, 255, 255))
end)

--// ============ ГЛОБАЛЬНЫЕ ФУНКЦИИ ============

local function FWC(obj, name)
    return obj:WaitForChild(name)
end

local function getClosestPlayer(pos)
    if not pos then return nil end
    local closestPlayer = nil
    local minDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local distance = (hrp.Position - pos).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function setWaterWalk(state)
    local workspaceMap = workspace:FindFirstChild("Map")
    if workspaceMap then
        local alwaysHere = workspaceMap:FindFirstChild("AlwaysHereTweenedObjects")
        if alwaysHere then
            local ocean = alwaysHere:FindFirstChild("Ocean")
            if ocean then
                local object = ocean:FindFirstChild("Object")
                if object then
                    local objectModel = object:FindFirstChild("ObjectModel")
                    if objectModel then
                        for _, child in pairs(objectModel:GetChildren()) do
                            if child:IsA("BasePart") then
                                child.CanCollide = state
                            end
                        end
                    end
                end
            end
        end
    end
end

--// ============ DEFENS TAB - ANTI FUNCTIONS ============
local AntiGroup = Tabs.Defens:AddLeftGroupbox("Anti Functions", "shield")

-- Anti Blobman (ИЗ POLAR HUB)
local antiBlobmanActive = false
local antiBlobmanConnection = nil

local function StartAntiBlobman()
    antiBlobmanConnection = workspace.DescendantAdded:Connect(function(obj)
        if not antiBlobmanActive then return end
        if obj.Name == "CreatureBlobman" and obj:IsA("Model") then
            task.wait(0.1)
            local plr = LocalPlayer
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distance = (hrp.Position - obj.PrimaryPart.Position).Magnitude
                    if distance < 30 then
                        pcall(function()
                            ReplicatedStorage.MenuToys.DestroyToy:FireServer(obj)
                        end)
                        Library:Notify({
                            Title = "FrendlyHub",
                            Description = "Anti Blobman: Removed nearby Blobman!",
                            Duration = 2
                        })
                    end
                end
            end
        end
    end)
end

AntiGroup:AddToggle("AntiBlobmanToggle", {
    Text = "Anti Blobman",
    Default = false,
    Callback = function(Value)
        antiBlobmanActive = Value
        if Value then
            StartAntiBlobman()
        else
            if antiBlobmanConnection then
                antiBlobmanConnection:Disconnect()
                antiBlobmanConnection = nil
            end
        end
    end
})

-- Anti Burn
local antiBurnActive = false
local antiBurnConnection = nil

local function StartAntiBurn()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    char.PrimaryPart = hrp
    
    antiBurnConnection = hum:GetAttributeChangedSignal("FireDebounce"):Connect(function()
        local isBurning = hum:GetAttribute("FireDebounce")
        if isBurning and antiBurnActive then
            local me = char
            local oldCF = hrp.CFrame
            local plots = workspace:FindFirstChild("Plots")
            
            if plots and plots:FindFirstChild("Plot2") then
                local plot2 = plots.Plot2
                local barrier = plot2:FindFirstChild("Barrier")
                local pb = barrier and barrier:FindFirstChild("PlotBarrier")
                
                if pb and pb:IsA("BasePart") then
                    local safeCF = pb.CFrame * CFrame.new(0, 6, 0)
                    me:SetPrimaryPartCFrame(safeCF)
                    task.wait(0.3)
                    
                    local firePart = me:FindFirstChild("FirePlayerPart", true)
                    if firePart then
                        for _, obj in ipairs(firePart:GetChildren()) do
                            if obj:IsA("Sound") then obj:Stop() end
                            if obj:IsA("Light") or obj:IsA("ParticleEmitter") then
                                obj.Enabled = false
                            end
                        end
                        
                        if firePart:FindFirstChild("CanBurn") then
                            firePart.CanBurn.Value = false
                        end
                        if hum:FindFirstChild("FireDebounce") then
                            hum.FireDebounce.Value = false
                        end
                    end
                    
                    task.wait(0.6)
                    if me and me.PrimaryPart and antiBurnActive then
                        me:SetPrimaryPartCFrame(oldCF)
                    end
                end
            end
        end
    end)
end

AntiGroup:AddToggle("AntiBurnToggle", {
    Text = "Anti Burn",
    Default = false,
    Callback = function(Value)
        antiBurnActive = Value
        if Value then
            StartAntiBurn()
        else
            if antiBurnConnection then
                antiBurnConnection:Disconnect()
                antiBurnConnection = nil
            end
        end
    end
})

-- Anti Explosion
local antiExplosionActive = false
local antiExplosionConnection = nil

local function StartAntiExplosion()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart")
    antiExplosionConnection = workspace.ChildAdded:Connect(function(model)
        if model.Name == "Part" and antiExplosionActive then
            local mag = (model.Position - hrp.Position).Magnitude
            if mag <= 20 then
                hrp.Anchored = true
                task.wait(0.01)
                local rightArm = char:FindFirstChild("Right Arm")
                if rightArm then
                    local ragdollPart = rightArm:FindFirstChild("RagdollLimbPart")
                    if ragdollPart then
                        while ragdollPart.CanCollide and antiExplosionActive do
                            task.wait(0.001)
                        end
                    end
                end
                if antiExplosionActive then
                    hrp.Anchored = false
                end
            end
        end
    end)
end

AntiGroup:AddToggle("AntiExplosionToggle", {
    Text = "Anti Explosion",
    Default = false,
    Callback = function(Value)
        antiExplosionActive = Value
        if Value then
            StartAntiExplosion()
        else
            if antiExplosionConnection then
                antiExplosionConnection:Disconnect()
                antiExplosionConnection = nil
            end
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Anchored = false
                end
            end
        end
    end
})

-- Anti Grab
local antiGrabProc = false
local AGWalk = false
local AGConnections = {}

local function Disc(name)
    if AGConnections[name] then
        AGConnections[name]:Disconnect()
        AGConnections[name] = nil
    end
end

AntiGroup:AddToggle("AntiGrabToggle", {
    Text = "Anti Grab",
    Default = false,
    Callback = function(Value)
        if Value then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp, hum, head = FWC(char, "HumanoidRootPart"), FWC(char, "Humanoid"), FWC(char, "Head")
            
            AGConnections["AGHead"] = head.ChildAdded:Connect(function(PartOwner)
                if PartOwner.Name == "PartOwner" then
                    if not antiGrabProc then
                        antiGrabProc = true
                        hum.Sit = false
                        ReplicatedStorage.CharacterEvents.Struggle:FireServer(LocalPlayer)
                        task.spawn(function() 
                            while (head and head:FindFirstChild("PartOwner")) or LocalPlayer.IsHeld.Value do
                                ReplicatedStorage.CharacterEvents.Struggle:FireServer(LocalPlayer)
                                ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                                task.wait()
                            end
                        end)
                        hrp.Anchored = true
                        if not AGWalk then
                            AGWalk = true
                            while LocalPlayer.IsHeld.Value and task.wait() do 
                                hrp.CFrame = hrp.CFrame + hum.MoveDirection * 0.43 
                            end
                        end
                        hrp.Anchored = false
                        antiGrabProc = false
                        AGWalk = false
                    end
                end
            end)
            
            AGConnections["AGRagdoll"] = FWC(hum, "Ragdolled").Changed:Connect(function()
                if hum.Ragdolled.Value then
                    for _, v in pairs(char:GetChildren()) do
                        if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name ~= "Head" then
                            v.BallSocketConstraint.Enabled = false
                            if v:FindFirstChild("RagdollLimbPart") then
                                v.RagdollLimbPart.WeldConstraint.Enabled = false
                            end
                        end
                    end
                end
            end)
            
            AGConnections["AGWeld"] = FWC(hrp, "WeldHRP").Changed:Connect(function()
                if hrp.WeldHRP.Enabled then
                    while not hum.Sit do task.wait() end
                    hum.Sit = false
                    hum.AutoRotate = true
                    hum.HipHeight = 1
                    while hrp.WeldHRP.Enabled and task.wait() do 
                        head.CFrame = hrp.CFrame + Vector3.new(0, 1.35, 0) 
                    end
                    hum.HipHeight = 0
                end
            end)
            
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name ~= "Head" then
                    v.BallSocketConstraint.Enabled = false
                    if v:FindFirstChild("RagdollLimbPart") then
                        v.RagdollLimbPart.WeldConstraint.Enabled = false
                    end
                end
            end
            
            AGConnections["AGChar"] = LocalPlayer.CharacterAdded:Connect(function(newChar)
                local newHrp, newHum, newHead = FWC(newChar, "HumanoidRootPart"), FWC(newChar, "Humanoid"), FWC(newChar, "Head")
                
                AGConnections["AGHeadNew"] = newHead.ChildAdded:Connect(function(PartOwner)
                    if PartOwner.Name == "PartOwner" then
                        if not antiGrabProc then
                            antiGrabProc = true
                            newHum.Sit = false
                            ReplicatedStorage.CharacterEvents.Struggle:FireServer(LocalPlayer)
                            task.spawn(function() 
                                while (newHead and newHead:FindFirstChild("PartOwner")) or LocalPlayer.IsHeld.Value do
                                    ReplicatedStorage.CharacterEvents.Struggle:FireServer(LocalPlayer)
                                    ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(newHrp, 0)
                                    task.wait()
                                end
                            end)
                            newHrp.Anchored = true
                            if not AGWalk then
                                AGWalk = true
                                while LocalPlayer.IsHeld.Value and task.wait() do 
                                    newHrp.CFrame = newHrp.CFrame + newHum.MoveDirection * 0.43 
                                end
                            end
                            newHrp.Anchored = false
                            antiGrabProc = false
                            AGWalk = false
                        end
                    end
                end)
                
                AGConnections["AGRagdollNew"] = FWC(newHum, "Ragdolled").Changed:Connect(function()
                    if newHum.Ragdolled.Value then
                        for _, v in pairs(newChar:GetChildren()) do
                            if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name ~= "Head" then
                                v.BallSocketConstraint.Enabled = false
                                if v:FindFirstChild("RagdollLimbPart") then
                                    v.RagdollLimbPart.WeldConstraint.Enabled = false
                                end
                            end
                        end
                    end
                end)
                
                AGConnections["AGWeldNew"] = FWC(newHrp, "WeldHRP").Changed:Connect(function()
                    if newHrp.WeldHRP.Enabled then
                        while not newHum.Sit do task.wait() end
                        newHum.Sit = false
                        newHum.AutoRotate = true
                        newHum.HipHeight = 1
                        while newHrp.WeldHRP.Enabled and task.wait() do 
                            newHead.CFrame = newHrp.CFrame + Vector3.new(0, 1.35, 0) 
                        end
                        newHum.HipHeight = 0
                    end
                end)
                
                for _, v in pairs(newChar:GetChildren()) do
                    if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name ~= "Head" then
                        v.BallSocketConstraint.Enabled = false
                        if v:FindFirstChild("RagdollLimbPart") then
                            v.RagdollLimbPart.WeldConstraint.Enabled = false
                        end
                    end
                end
            end)
        else
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") and v:FindFirstChild("BallSocketConstraint") and v.Name ~= "Head" then
                    v.BallSocketConstraint.Enabled = false
                    if v:FindFirstChild("RagdollLimbPart") then
                        v.RagdollLimbPart.WeldConstraint.Enabled = true
                    end
                end
            end
            Disc("AGHead"); Disc("AGRagdoll"); Disc("AGWeld"); Disc("AGChar")
            Disc("AGHeadNew"); Disc("AGRagdollNew"); Disc("AGWeldNew")
        end
    end
})

-- Anti Lag
AntiGroup:AddToggle("AntiLagToggle", {
    Text = "Anti Lag",
    Default = false,
    Callback = function(Value)
        pcall(function()
            LocalPlayer.PlayerScripts.CharacterAndBeamMove.Disabled = Value
        end)
    end
})

-- Anti Void
local antiVoidActive = false
local antiVoidConnection = nil

local function StartAntiVoid()
    local VOID_THRESHOLD = -50
    local SAFE_HEIGHT = 100
    antiVoidConnection = RunService.Heartbeat:Connect(function()
        if not antiVoidActive then return end
        local char = LocalPlayer.Character
        if char and char.PrimaryPart then
            local pos = char.PrimaryPart.Position
            if pos.Y < VOID_THRESHOLD then
                local safePos = Vector3.new(pos.X, pos.Y + SAFE_HEIGHT, pos.Z)
                char:SetPrimaryPartCFrame(CFrame.new(safePos))
                char.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end

AntiGroup:AddToggle("AntiVoidToggle", {
    Text = "Anti Void",
    Default = false,
    Callback = function(Value)
        antiVoidActive = Value
        if Value then
            StartAntiVoid()
        else
            if antiVoidConnection then
                antiVoidConnection:Disconnect()
                antiVoidConnection = nil
            end
        end
    end
})

-- Break PCLD
AntiGroup:AddButton({
    Text = "Break PCLD",
    Func = function()
        local serverPos = CFrame.new(-272.2197265625, -7.350403785705566, 475.0108947753906)
        workspace.FallenPartsDestroyHeight = 0/0

        local storedJoints = {}
        local root
        local conn
        local active = false

        local function breakPCLD()
            local char = LocalPlayer.Character
            if not char then return end
            root = char:WaitForChild("HumanoidRootPart")

            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("Motor6D") then
                    storedJoints[v] = v.Part0
                    v.Part0 = nil
                end
            end

            root.CFrame = serverPos

            conn = RunService.RenderStepped:Connect(function()
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
        end

        local function restore()
            if conn then conn:Disconnect() conn = nil end

            for m, p0 in pairs(storedJoints) do
                if m and m.Parent then
                    m.Part0 = p0
                end
            end
            storedJoints = {}
        end

        local function press6()
            active = not active
            if active then
                breakPCLD()
            else
                restore()
            end
        end

        press6()
        task.wait(0.12)
        press6()

        LocalPlayer.CharacterAdded:Once(function()
            task.wait(0.25)
            press6()
            task.wait(0.12)
            press6()
        end)
    end,
    DoubleClick = false
})

-- Delete Legs
AntiGroup:AddButton({
    Text = "Delete Legs",
    Func = function()
        local character = LocalPlayer.Character
        if not character then 
            character = LocalPlayer.CharacterAdded:Wait()
        end
        
        local leftLeg = character:FindFirstChild("Left Leg")
        local rightLeg = character:FindFirstChild("Right Leg")
        local torso = character:WaitForChild("Torso") or character:WaitForChild("UpperTorso")
        local hrp = character:WaitForChild("HumanoidRootPart")
        local RagdollRemote = ReplicatedStorage:FindFirstChild("CharacterEvents") and ReplicatedStorage.CharacterEvents:FindFirstChild("RagdollRemote")
        
        if leftLeg and rightLeg and torso and hrp and RagdollRemote then
            local originalFallHeight = workspace.FallenPartsDestroyHeight
            local originalCFrame = torso.CFrame
            
            workspace.FallenPartsDestroyHeight = -100
            RagdollRemote:FireServer(hrp, 2)
            
            task.wait(0.5)
            
            leftLeg.CFrame = CFrame.new(0, -10000, 0)
            rightLeg.CFrame = CFrame.new(0, -10000, 0)
            
            task.wait(0.3)
            
            torso.CFrame = CFrame.new(0, -9970, 0)
            
            task.wait(0.5)
            
            torso.CFrame = originalCFrame
            
            task.wait(0.5)
            workspace.FallenPartsDestroyHeight = originalFallHeight
        end
    end,
    DoubleClick = false
})

-- Shuriken Anti Kick
local shurikenAntiKickEnabled = false
local shurikenAntiKickTask = nil

local function ShurikenAntiKickFunction()
    local plr = LocalPlayer
    local setOwner = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
    local stickyEvent = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
    local spawnRemote = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction
    local destroyrem = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("DestroyToy")
    local canSpawn = plr:WaitForChild("CanSpawnToy")

    local function ClearKunai()
        local inv = workspace:FindFirstChild(plr.Name.."SpawnedInToys")
        if inv and destroyrem then
            for _, v in pairs(inv:GetChildren()) do
                if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                    pcall(function() destroyrem:FireServer(v) end)
                end
            end
        end
    end

    local function getHRP()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            return plr.Character.HumanoidRootPart
        else
            local character = plr.CharacterAdded:Wait()
            return character:WaitForChild("HumanoidRootPart")
        end
    end

    local function CheckForHome()
        if not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then return false end
        for _, v in pairs(workspace.Plots:GetChildren()) do
            local sign = v:FindFirstChild("PlotSign")
            local owners = sign and sign:FindFirstChild("ThisPlotsOwners")
            if owners then
                for _, b in pairs(owners:GetChildren()) do
                    if b.Value == plr.Name then
                        local folder = workspace.PlotItems:FindFirstChild(v.Name)
                        if folder then return true, folder end
                    end
                end
            end
        end
        return false
    end

    local function StickKunai(kunai)
        if not kunai or not kunai:FindFirstChild("StickyPart") then return end
        local currentHRP = getHRP()
        if not currentHRP then return end
        if kunai:FindFirstChild("SoundPart") then
            if not kunai.SoundPart:FindFirstChild("PartOwner") or kunai.SoundPart.PartOwner.Value ~= plr.Name then
                setOwner:FireServer(kunai.SoundPart, kunai.SoundPart.CFrame)
            end
        end
        local firePart = currentHRP:FindFirstChild("FirePlayerPart") or currentHRP:WaitForChild("FirePlayerPart", 5)
        if firePart then
            stickyEvent:FireServer(kunai.StickyPart, firePart, CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(90),math.rad(90)))
        end
        for _, obj in pairs(kunai:GetChildren()) do
            if obj.Name == "Pyramid" then
                obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 0
                if not obj:FindFirstChild("Highlight") then
                    local high = Instance.new("Highlight", obj)
                    high.FillColor = Color3.fromRGB(0, 0, 0)
                end
            elseif obj.Name == "Main" then
                obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 0
                if not obj:FindFirstChild("Highlight") then
                    local high = Instance.new("Highlight", obj)
                    high.FillColor = Color3.fromRGB(255, 255, 255)
                end
            elseif obj:IsA("BasePart") then
                obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false; obj.Transparency = 1
            end
        end
    end

    local function SpawnToy(name)
        local t = tick()
        while not canSpawn.Value do
            if not shurikenAntiKickEnabled or tick() - t > 5 then return nil end
            task.wait(0.1)
        end
        local currentHRP = getHRP()
        if currentHRP then
            task.spawn(function()
                pcall(function()
                    spawnRemote:InvokeServer(name, currentHRP.CFrame * CFrame.new(0, 12, 20), Vector3.new(0,0,0))
                end)
            end)
        end
        local boolik, house = CheckForHome()
        local inv = workspace:FindFirstChild(plr.Name.."SpawnedInToys")
        if boolik and house then 
            return house:WaitForChild(name, 2)
        elseif not workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) and inv then 
            return inv:WaitForChild(name, 2)
        end
        return nil
    end

    while shurikenAntiKickEnabled do
        task.wait(0.005)
        if not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then 
            continue 
        end
        local inv = workspace:FindFirstChild(plr.Name.."SpawnedInToys")
        local kunai = inv and inv:FindFirstChild("NinjaShuriken")
        if workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then 
            local boolik, house = CheckForHome()
            if boolik and house and workspace.Plots:FindFirstChild(house.Name) then
                local sign = workspace.Plots[house.Name]:FindFirstChild("PlotSign")
                if sign and sign.ThisPlotsOwners.Value.TimeRemainingNum.Value > 89 then 
                    kunai = SpawnToy("NinjaShuriken")
                    if kunai == nil then continue end
                    kunai.Name = "AntiKick" 
                    StickKunai(kunai)
                end
            end
        end
        if not kunai then
            if workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then continue end 
            kunai = SpawnToy("NinjaShuriken")
            if kunai == nil then continue end 
            kunai.Name = "AntiKick"
            if not kunai then continue end 
        end
        repeat
            if kunai and kunai:FindFirstChild("StickyPart") and kunai.StickyPart.CanTouch == true then
                StickKunai(kunai)
                kunai.Name = "AntiKick"
            end
            task.wait(0.3)
        until not kunai or not shurikenAntiKickEnabled or not kunai:FindFirstChild("StickyPart") or kunai.StickyPart.CanTouch == false 
            or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") 
            or not kunai:FindFirstChild("StickyPart") 
            or (plr.Character.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20
        if not kunai or not kunai:FindFirstChild("StickyPart") or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or (plr.Character.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20 then 
            ClearKunai()
        end 
        pcall(function()
            repeat
                task.wait(0.05)
            until not shurikenAntiKickEnabled or not plr.Character or not plr.Character:FindFirstChild("Humanoid") or not kunai or not kunai:FindFirstChild("StickyPart") or not kunai.StickyPart:FindFirstChild("StickyWeld") or not kunai.StickyPart.StickyWeld.Part1
            if not kunai or not kunai:FindFirstChild("StickyPart") or (plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health <= 0) or not kunai["StickyPart"]:FindFirstChild("StickyWeld").Part1 then 
                ClearKunai()
            end
        end)
    end
    ClearKunai()
end

AntiGroup:AddToggle("ShurikenAntiKickToggle", {
    Text = "Shuriken Anti Kick",
    Default = false,
    Callback = function(State)
        shurikenAntiKickEnabled = State
        if State then 
            shurikenAntiKickTask = task.spawn(ShurikenAntiKickFunction)
        else 
            if shurikenAntiKickTask then 
                task.cancel(shurikenAntiKickTask)
                shurikenAntiKickTask = nil 
            end
            local inv = workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
            local destroyrem = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy")
            if inv and destroyrem then
                for _, v in pairs(inv:GetChildren()) do
                    if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
                        pcall(function() destroyrem:FireServer(v) end)
                    end
                end
            end
        end
    end
})

-- Water Walk
AntiGroup:AddToggle("WaterWalkToggle", {
    Text = "Water Walk",
    Default = false,
    Callback = function(Value)
        setWaterWalk(Value)
    end
})

--// ============ DEFENS TAB - ANTI INPUT LAG ============
local AntiInputGroup = Tabs.Defens:AddRightGroupbox("Anti Input Lag", "palette")

-- Toy List
local ToyList = {
    ["Coconut"] = "FoodCoconut",
    ["Banana"] = "FoodBanana", 
    ["Fries"] = "FoodFrenchFries",
    ["MeatStick"] = "FoodMeatStick",
    ["Poop"] = "PoopPile",
    ["Donut"] = "FoodDonut",
    ["Cake"] = "FoodCakePink",
    ["Burger"] = "FoodHamburger",
    ["Pizza"] = "FoodPizzaCheese",
    ["Hotdog"] = "FoodHotdog",
    ["Mushroom"] = "FoodMushroomPoison",
    ["Banjo"] = "InstrumentGuitarBanjo",
    ["Violin"] = "InstrumentGuitarViolin",
    ["Ukulele"] = "InstrumentGuitarUkulele",
    ["Sax"] = "InstrumentWoodwindSaxophone",
    ["Vuvuzela"] = "InstrumentBrassVuvuzela",
    ["Bongos"] = "InstrumentDrumBongos",
    ["Mic"] = "InstrumentVoiceMicrophone",
    ["Pepperoni"] = "FoodPizzaPepperoni",
    ["Piano"] = "InstrumentPianoMelodica",
    ["Bread"] = "FoodBread",
    ["Egg"] = "FoodDippyEgg",
    ["Mayo"] = "FoodMayonnaise",
    ["WhiteMug"] = "CupMugWhite",
    ["Ocarina"] = "InstrumentWoodwindOcarina",
    ["SparklePoop"] = "PoopPileSparkle",
    ["BrownMug"] = "CupMugBrown",
    ["Trumpet"] = "InstrumentBrassTrumpet",
    ["Snare"] = "InstrumentDrumSnare",
}

local dropdownValues = {}
for shortName, _ in pairs(ToyList) do
    table.insert(dropdownValues, shortName)
end
table.sort(dropdownValues)

local SelectedToy = ToyList[dropdownValues[1]]

AntiInputGroup:AddDropdown("AntiInputLagToy", {
    Text = "Input Lag Item",
    Values = dropdownValues,
    Default = "Burger",
    Callback = function(Value)
        SelectedToy = ToyList[Value]
    end
})

-- Anti Input Lag
local antiInputLagActive = false
local antiInputLagTask = nil

AntiInputGroup:AddToggle("AntiInputLagToggle", {
    Text = "Anti Input Lag",
    Default = false,
    Callback = function(Value)
        antiInputLagActive = Value
        if Value then
            antiInputLagTask = task.spawn(function()
                local plr = LocalPlayer
                local SpawnRemote = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction
                
                while antiInputLagActive do
                    local char = plr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then
                        task.wait(0.1)
                        continue
                    end
                    
                    local toysFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                    if not toysFolder then
                        task.wait(0.1)
                        continue
                    end
                    
                    local toy = toysFolder:FindFirstChild(SelectedToy)
                    
                    if not toy then
                        pcall(function()
                            SpawnRemote:InvokeServer(SelectedToy, hrp.CFrame * CFrame.new(0, 5, 0), Vector3.zero)
                        end)
                        
                        local t0 = tick()
                        repeat
                            RunService.Heartbeat:Wait()
                            toysFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                            toy = toysFolder and toysFolder:FindFirstChild(SelectedToy)
                        until toy or tick() - t0 > 1 or not antiInputLagActive
                    end
                    
                    if toy and toy.Parent then
                        local holdPart = toy:FindFirstChild("HoldPart")
                        if holdPart then
                            local holdingPlayer = holdPart:FindFirstChild("HoldingPlayer")
                            holdingPlayer = holdingPlayer and holdingPlayer.Value
                            
                            if holdingPlayer and holdingPlayer ~= plr then
                                pcall(function()
                                    holdPart.DropItemRemoteFunction:InvokeServer(toy, hrp.CFrame * CFrame.new(0, 2000, 0), Vector3.zero)
                                end)
                                toy:Destroy()
                            else
                                pcall(function()
                                    holdPart.HoldItemRemoteFunction:InvokeServer(toy, char)
                                end)
                                task.wait(0.05)
                                
                                pcall(function()
                                    holdPart.DropItemRemoteFunction:InvokeServer(toy, hrp.CFrame * CFrame.new(0, 2000, 0), Vector3.zero)
                                end)
                                task.wait(0.01)
                            end
                        end
                    end
                    
                    RunService.Heartbeat:Wait()
                end
            end)
        else
            if antiInputLagTask then
                task.cancel(antiInputLagTask)
                antiInputLagTask = nil
            end
        end
    end
})

-- Remove All Anti Input
local removeAllAntiInputActive = false
local removeAllAntiInputTask = nil

local function RemoveAllAntiInputFunction()
    local AllowedItems = {
        FoodHamburger = true, FoodCoconut = true, FoodPizzaCheese = true,
        FoodPizzaPepperoni = true, FoodHotdog = true, FoodMushroomPoison = true,
        FoodBread = true, FoodDippyEgg = true, FoodMayonnaise = true,
        FoodFrenchFries = true, FoodMeatStick = true, FoodDonut = true,
        FoodCakePink = true, InstrumentGuitarBanjo = true, InstrumentGuitarViolin = true,
        InstrumentGuitarUkulele = true, InstrumentWoodwindSaxophone = true,
        InstrumentWoodwindOcarina = true, InstrumentBrassVuvuzelaQwizik = true,
        InstrumentBrassTrumpet = true, InstrumentDrumBongos = true, InstrumentDrumSnare = true,
        InstrumentPianoMelodica = true, InstrumentVoiceMicrophone = true,
        CupMugWhite = true, CupMugBrown = true, PoopPile = true, PoopPileSparkle = true,
    }
    
    local plr = LocalPlayer
    local burgers = {}
    local descConnection = workspace.DescendantAdded:Connect(function(obj)
        if AllowedItems[obj.Name] and obj:IsA("Model") then
            task.spawn(function()
                local hp = obj:WaitForChild("HoldPart", 3)
                if hp then
                    table.insert(burgers, obj)
                end
            end)
        end
    end)
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if AllowedItems[v.Name] and v:IsA("Model") and v:FindFirstChild("HoldPart") then
            table.insert(burgers, v)
        end
    end
    
    while removeAllAntiInputActive do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for i = #burgers, 1, -1 do
                local b = burgers[i]
                if not b or not b.Parent or not b:FindFirstChild("HoldPart") then
                    table.remove(burgers, i)
                else
                    local hp = b.HoldPart
                    pcall(function()
                        hp.HoldItemRemoteFunction:InvokeServer(b, char)
                    end)
                    task.wait()
                    pcall(function()
                        hp.DropItemRemoteFunction:InvokeServer(
                            b,
                            CFrame.new(hrp.Position + Vector3.new(0, -2000, 0)),
                            Vector3.new(0, 0, 0)
                        )
                    end)
                end
            end
        end
        task.wait()
    end
    
    descConnection:Disconnect()
end

AntiInputGroup:AddToggle("RemoveAllAntiInputToggle", {
    Text = "Remove All Anti Input",
    Default = false,
    Callback = function(Value)
        removeAllAntiInputActive = Value
        if Value then
            removeAllAntiInputTask = task.spawn(RemoveAllAntiInputFunction)
        else
            if removeAllAntiInputTask then
                task.cancel(removeAllAntiInputTask)
                removeAllAntiInputTask = nil
            end
        end
    end
})

--// ============ MAIN TAB ============
local MainGroup = Tabs.Main:AddLeftGroupbox("Movement", "run")

-- Speed Boost
local speedEnabled = false
local speedValue = 50
local speedConnection = nil

local function applySpeed()
    if not speedEnabled then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local moveDirection = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * speedValue
            root.AssemblyLinearVelocity = Vector3.new(moveDirection.X, root.AssemblyLinearVelocity.Y, moveDirection.Z)
        end
    end)
end

MainGroup:AddToggle("SpeedToggle", {
    Text = "Speed Boost",
    Default = false,
    Callback = function(State)
        speedEnabled = State
        if State then
            speedConnection = RunService.Heartbeat:Connect(applySpeed)
        else
            if speedConnection then
                speedConnection:Disconnect()
                speedConnection = nil
            end
        end
    end
})

MainGroup:AddSlider("SpeedSlider", {
    Text = "Speed Value",
    Default = 50,
    Min = 16,
    Max = 3000,
    Rounding = 0,
    Callback = function(Value)
        speedValue = Value
    end
})

-- Jump Power
local jumpEnabled = false
local jumpValue = 50
local jumpConnection = nil

MainGroup:AddToggle("JumpToggle", {
    Text = "Jump Power",
    Default = false,
    Callback = function(State)
        jumpEnabled = State
        if State then
            jumpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == Enum.KeyCode.Space then
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then
                                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, jumpValue, root.AssemblyLinearVelocity.Z)
                            end
                        end
                    end)
                end
            end)
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end
})

MainGroup:AddSlider("JumpSlider", {
    Text = "Jump Value",
    Default = 50,
    Min = 50,
    Max = 3000,
    Rounding = 0,
    Callback = function(Value)
        jumpValue = Value
    end
})

-- Spin Bot
local spinEnabled = false
local spinSpeed = 10
local spinConnection = nil

MainGroup:AddToggle("SpinBotToggle", {
    Text = "Spin Bot",
    Default = false,
    Callback = function(State)
        spinEnabled = State
        if State then
            spinConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
                        end
                    end
                end)
            end)
        else
            if spinConnection then
                spinConnection:Disconnect()
                spinConnection = nil
            end
        end
    end
})

MainGroup:AddSlider("SpinSpeed", {
    Text = "Spin Speed",
    Default = 10,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        spinSpeed = Value
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    if speedEnabled and speedConnection then
        speedConnection:Disconnect()
        speedConnection = RunService.Heartbeat:Connect(applySpeed)
    end
end)

--// ============ TARGET TAB ============
local TargetSelectGroup = Tabs.Target:AddLeftGroupbox("Target Selection", "target")
local BlobmanGroup = Tabs.Target:AddLeftGroupbox("Blobman Features", "target")
local KickMethodsGroup = Tabs.Target:AddRightGroupbox("Kick Methods", "target")
local FunctionsGroup = Tabs.Target:AddRightGroupbox("Functions", "gear")
local MovePlayerGroup = Tabs.Target:AddRightGroupbox("Move Player", "target")

local selectedPlayer = nil
local kickLoop = false

local function getPlayerList()
    local List = {}
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local displayText = Player.DisplayName .. " (@" .. Player.Name .. ")"
            table.insert(List, displayText)
        end
    end
    return List
end

TargetSelectGroup:AddDropdown("KickPlayerDropdown", {
    Values = getPlayerList(),
    Default = nil,
    Multi = false,
    Text = "Select Player",
    Callback = function(Value)
        local username = Value:match("%(@(.+)%)")
        if username then selectedPlayer = Players:FindFirstChild(username) end
    end
})

TargetSelectGroup:AddButton({
    Text = "Refresh Player List",
    Func = function() Options.KickPlayerDropdown:SetValues(getPlayerList()) end
})

TargetSelectGroup:AddLabel("Aim Select Key"):AddKeyPicker("AimSelectKey", {
    Default = "Q", Mode = "Press", Text = "Aim Select Key", NoUI = false,
    Callback = function()
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        if target then
            local foundPlayer = nil
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and target:IsDescendantOf(plr.Character) then foundPlayer = plr; break end
            end
            if foundPlayer then
                selectedPlayer = foundPlayer
                Options.KickPlayerDropdown:SetValue(foundPlayer.DisplayName .. " (@" .. foundPlayer.Name .. ")")
            end
        end
    end
})

--// ============ BLOBMAN FEATURES ============

-- Auto Sit Blobman
local autoSitBlobman = false
local autoSitBlobmanTask = nil

local function AutoSitBlobmanLoop()
    while autoSitBlobman do
        local plr = LocalPlayer
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if not hrp or not hum then 
            task.wait(1)
            continue 
        end
        if hum.SeatPart then
            task.wait(0.5)
            continue
        end
        local folderName = plr.Name .. "SpawnedInToys"
        local folder = workspace:FindFirstChild(folderName)
        local blob = folder and folder:FindFirstChild("CreatureBlobman")
        if not blob then
            task.spawn(function()
                pcall(function()
                    ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", hrp.CFrame, Vector3.zero)
                end)
            end)
            if not folder then
                folder = workspace:WaitForChild(folderName, 5)
            end
            if folder then
                blob = folder:WaitForChild("CreatureBlobman", 5)
            end
        end
        if blob then
            local seat = blob:WaitForChild("VehicleSeat", 5)
            if seat then
                local t = tick()
                repeat
                    if not hum.SeatPart then
                        hrp.CFrame = seat.CFrame + Vector3.new(0, 1, 0)
                        hrp.Velocity = Vector3.zero
                        seat:Sit(hum)
                    end
                    RunService.Heartbeat:Wait()
                until hum.SeatPart == seat or tick() - t > 1.5 or not autoSitBlobman
            end
        end
        task.wait(0.5)
    end
end

BlobmanGroup:AddToggle("AutoSitBlobmanToggle", {
    Text = "Auto Sit Blobman",
    Default = false,
    Callback = function(Value)
        autoSitBlobman = Value
        if Value then
            autoSitBlobmanTask = task.spawn(AutoSitBlobmanLoop)
        else
            if autoSitBlobmanTask then
                task.cancel(autoSitBlobmanTask)
                autoSitBlobmanTask = nil
            end
        end
    end
})

BlobmanGroup:AddDivider()
BlobmanGroup:AddLabel("=== BLOB METHODS ===")

-- Selected Method Dropdown
local blobMethods = {"Bring", "Loop Kick", "Bypass", "Kick", "Loop Kick (Grab+Blob)", "Blob Kill", "Lock"}
local selectedBlobMethod = blobMethods[1]

BlobmanGroup:AddDropdown("BlobMethodSelect", {
    Text = "Selected Method",
    Values = blobMethods,
    Default = "Bring",
    Callback = function(Value)
        selectedBlobMethod = Value
    end
})

-- BLOB KILL FUNCTION
local function BlobKill(targetPlayerName)
    local Players = game:GetService("Players")
    local me = Players.LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local FWC = function(Parent, Name, Time) 
        return Parent:FindFirstChild(Name) or Parent:WaitForChild(Name, Time or 3) 
    end
    local grab = function(prt) 
        rs.GrabEvents.SetNetworkOwner:FireServer(prt, prt.CFrame) 
    end
    local blob_kick = function(blob, hrp, rl, v)
        local detec = blob:FindFirstChild(rl .. "Detector")
        if not detec then return end
        local script = blob.BlobmanSeatAndOwnerScript
        if v == "Default" then
            script.CreatureGrab:FireServer(detec, hrp, detec[rl .. "Weld"])
        elseif v == "DDrop" then
            script.CreatureDrop:FireServer(detec[rl .. "Weld"])
        elseif v == "Release" then
            script.CreatureRelease:FireServer(detec[rl .. "Weld"], hrp)
        end
    end
    
    local kfmb = true
    local MyBlob
    
    while true do
        local mychar = me.Character or me.CharacterAdded:Wait()
        local myhum = FWC(mychar, "Humanoid")
        if myhum.SeatPart then
            MyBlob = myhum.SeatPart.Parent
            break
        end
        task.wait()
    end
    
    while kfmb and task.wait() do
        local mychar = me.Character or me.CharacterAdded:Wait()
        local myHRP = FWC(mychar, "HumanoidRootPart")
        local myhum = FWC(mychar, "Humanoid")
        
        if not myhum.SeatPart then 
            kfmb = false
            break
        end
        
        if myhum.SeatPart.Parent ~= MyBlob then
            kfmb = false
            break
        end
        
        local plr = Players:FindFirstChild(targetPlayerName)
        if not plr then continue end
        
        local char = plr.Character
        if not char then continue end
        
        local hum = FWC(char, "Humanoid", 2)
        local HRP = FWC(char, "HumanoidRootPart", 2)
        
        if not (hum and HRP) then continue end
        
        if hum.Health == 0 then
            char = plr.CharacterAdded:Wait()
            hum = FWC(char, "Humanoid", 2)
            HRP = FWC(char, "HumanoidRootPart", 2)
            task.wait(0.15)
            if not (hum and HRP) then continue end
        end
        
        if not (kfmb and MyBlob and MyBlob.Parent) then continue end
        
        local LD = MyBlob:FindFirstChild("LeftDetector")
        local LW = LD and LD:FindFirstChild("LeftWeld")
        
        if LD and LW then
            while LW.Attachment0 ~= HRP.RootAttachment and kfmb do
                local SavedPosition = myHRP.CFrame
                
                while hum.SeatPart do
                    task.spawn(grab, HRP)
                    task.wait()
                end
                
                for i = 1, 4 do
                    if not myhum.SeatPart then 
                        kfmb = false
                        break
                    end
                    
                    myHRP.CFrame = HRP.CFrame - Vector3.new(0, 10, 0)
                    blob_kick(MyBlob, HRP, "Left", "Default")
                    task.wait(0.05)
                    blob_kick(MyBlob, HRP, "Left", "Release")
                    hum.Health = 0
                    task.wait()
                end
                
                if not kfmb then break end
                myHRP.CFrame = SavedPosition
            end
        end
    end
end

-- BLOB HEAL FUNCTION
local function BlobHeal(targetPlayerName)
    local Players = game:GetService("Players")
    local me = Players.LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local FWC = function(Parent, Name, Time) 
        return Parent:FindFirstChild(Name) or Parent:WaitForChild(Name, Time or 3) 
    end
    local grab = function(prt) 
        rs.GrabEvents.SetNetworkOwner:FireServer(prt, prt.CFrame) 
    end
    local blob_kick = function(blob, hrp, rl, v)
        local detec = blob:FindFirstChild(rl .. "Detector")
        if not detec then return end
        local script = blob.BlobmanSeatAndOwnerScript
        if v == "Default" then
            script.CreatureGrab:FireServer(detec, hrp, detec[rl .. "Weld"])
        elseif v == "DDrop" then
            script.CreatureDrop:FireServer(detec[rl .. "Weld"])
        elseif v == "Release" then
            script.CreatureRelease:FireServer(detec[rl .. "Weld"], hrp)
        end
    end
    
    local MyBlob
    while true do
        local mychar = me.Character or me.CharacterAdded:Wait()
        local myhum = FWC(mychar, "Humanoid")
        if myhum.SeatPart then
            MyBlob = myhum.SeatPart.Parent
            break
        end
        task.wait()
    end
    
    local function DoHeal()
        local mychar = me.Character or me.CharacterAdded:Wait()
        local myHRP = FWC(mychar, "HumanoidRootPart")
        local myhum = FWC(mychar, "Humanoid")
        
        if not myhum.SeatPart then 
            return false 
        end
        
        if myhum.SeatPart.Parent ~= MyBlob then
            return false 
        end
        
        local plr = Players:FindFirstChild(targetPlayerName)
        if not plr then return false end
        
        local char = plr.Character
        if not char then return false end
        
        local hum = char:FindFirstChild("Humanoid")
        local HRP = char:FindFirstChild("HumanoidRootPart")
        
        if not (hum and HRP) then return false end
        if not (MyBlob and MyBlob.Parent) then return false end
        
        local LD = MyBlob:FindFirstChild("LeftDetector")
        local LW = LD and LD:FindFirstChild("LeftWeld")
        
        if not (LD and LW) then return false end
        
        local SavedPosition = myHRP.CFrame
        
        task.spawn(grab, HRP)
        task.wait(0.1)
        
        for i = 1, 3 do
            if not myhum.SeatPart then return false end
            
            myHRP.CFrame = HRP.CFrame * CFrame.new(0, 0, -2.5)
            blob_kick(MyBlob, HRP, "Left", "Default")
            task.wait(0.08)
            blob_kick(MyBlob, HRP, "Left", "Release")
            hum.Health = hum.MaxHealth
            task.wait(0.08)
        end
        
        myHRP.CFrame = SavedPosition
        return true
    end
    
    local success1 = DoHeal()
    if not success1 then
        task.wait(0.5)
        DoHeal()
    end
end

-- Target functions for Blob
local function Bring(targetPlayerName)
    local NetworkRemote = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
    local TargetPlayer = Players:FindFirstChild(targetPlayerName)
    if not TargetPlayer then return end
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local RootPart = Character:WaitForChild("HumanoidRootPart")
    local Seat = Humanoid.SeatPart
    if not Seat or not TargetPlayer or TargetPlayer == LocalPlayer then return end
    local SeatObject = Seat.Parent
    local TargetCharacter = TargetPlayer.Character or TargetPlayer.CharacterAdded:Wait()
    local TargetRoot = TargetCharacter:WaitForChild("HumanoidRootPart")
    local Detector = SeatObject:WaitForChild("LeftDetector")
    local Weld = Detector:WaitForChild("LeftWeld")
    local GrabRemote = SeatObject.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab")
    local OriginalPosition = RootPart.CFrame
    local OriginalTransparency = {}
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            OriginalTransparency[part] = part.Transparency
            part.Transparency = 1
        end
    end
    local Camera = workspace.CurrentCamera
    local OriginalCameraCFrame = Camera.CFrame
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = OriginalCameraCFrame
    RootPart.CFrame = TargetRoot.CFrame * CFrame.new(0, 0, 2.5)
    task.wait()
    GrabRemote:FireServer(Detector, TargetRoot, Weld)
    task.delay(0.1, function()
        GrabRemote:FireServer(Detector, TargetRoot, Weld)
    end)
    task.delay(0.2, function()
        RootPart.CFrame = OriginalPosition
        for part, transparency in pairs(OriginalTransparency) do
            if part and part.Parent then
                part.Transparency = transparency
            end
        end
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = Humanoid
    end)
end

local function Kick(targetPlayerName)
    local target = Players:FindFirstChild(targetPlayerName)
    if not target then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local seat = humanoid.SeatPart
    if seat and target and target ~= LocalPlayer then
        local seatParent, targetChar = seat.Parent, target.Character or target.CharacterAdded:Wait()
        local targetHRP = targetChar:WaitForChild("HumanoidRootPart")
        local det = seatParent:WaitForChild("LeftDetector")
        local weld = det:WaitForChild("LeftWeld")
        local grab = seatParent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab")
        local drop = seatParent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureDrop")
        local originalCFrame = hrp.CFrame
        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
        task.wait(0.5)
        grab:FireServer(det, targetHRP, weld)
        task.wait(0.7)
        drop:FireServer(weld, targetHRP)
        task.wait(0.3)
        grab:FireServer(det, targetHRP, weld)
        local bp = Instance.new("BodyPosition")
        bp.Position = Vector3.new(0, 999e5000, 0)
        bp.MaxForce = Vector3.new(0, 99999e990, 0)
        bp.Parent = targetHRP
        task.wait(0.6)
        grab:FireServer(det, targetHRP, weld)
        bp:Destroy()
        hrp.CFrame = originalCFrame
    end
end

local function LoopKickMethod(targetPlayerName)
    local target = Players:FindFirstChild(targetPlayerName)
    if not target then return end
    if target == LocalPlayer then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local seat = humanoid.SeatPart
    if not seat then return end
    local seatParent = seat.Parent
    local targetChar = target.Character or target.CharacterAdded:Wait()
    local targetHumanoid = targetChar:WaitForChild("Humanoid")
    local targetHRP = targetChar:WaitForChild("HumanoidRootPart")
    local leftDet = seatParent:WaitForChild("LeftDetector")
    local leftWeld = leftDet:WaitForChild("LeftWeld")
    local rightDet = seatParent:WaitForChild("RightDetector")
    local rightWeld = rightDet:WaitForChild("RightWeld")
    local grab = seatParent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab")
    local drop = seatParent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureDrop")
    local function grabWithHand(det, weld, targetPart)
        grab:FireServer(det, targetPart, weld)
    end
    local function dropWithHand(weld, targetPart)
        drop:FireServer(weld, targetPart)
    end
    local originalCFrame = hrp.CFrame
    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, -5, 0)
    task.wait(0.1)
    grabWithHand(leftDet, leftWeld, targetHRP)
    task.wait(0.5)
    dropWithHand(leftWeld, targetHRP)
    task.wait(0.2)
    local bp = Instance.new("BodyPosition")
    bp.Position = Vector3.new(0, 999e6, 0)
    bp.MaxForce = Vector3.new(999e6, 999e6, 999e6)
    bp.Parent = targetHRP
    grabWithHand(leftDet, leftWeld, targetHRP)
    task.wait(0.5)
    dropWithHand(leftWeld, targetHRP)
    task.wait(0.5)
    while target and target.Parent and targetHumanoid.Health > 0 do
        if targetHumanoid.Health > 0 then
            grabWithHand(leftDet, leftWeld, targetHRP)
            task.wait()
            dropWithHand(leftWeld, targetHRP)
            task.wait()
            grabWithHand(rightDet, rightWeld, targetHRP)
            task.wait()
            dropWithHand(rightWeld, targetHRP)
            task.wait()
            grabWithHand(leftDet, leftWeld, targetHRP)
            grabWithHand(rightDet, rightWeld, targetHRP)
            task.wait()
            dropWithHand(leftWeld, targetHRP)
            dropWithHand(rightWeld, targetHRP)
            task.wait()
        else
            break
        end
    end
    if bp then bp:Destroy() end
    hrp.CFrame = originalCFrame
end

local function Bypass(targetPlayerName)
    local target = Players:FindFirstChild(targetPlayerName)
    if not target or target == LocalPlayer then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    local seat = humanoid.SeatPart
    if not seat then return end
    local seatParent = seat.Parent
    local targetChar = target.Character or target.CharacterAdded:Wait()
    local targetHumanoid = targetChar:WaitForChild("Humanoid")
    local targetHRP = targetChar:WaitForChild("HumanoidRootPart")
    local leftDet = seatParent:WaitForChild("LeftDetector")
    local leftWeld = leftDet:WaitForChild("LeftWeld")
    local rightDet = seatParent:WaitForChild("RightDetector")
    local rightWeld = rightDet:WaitForChild("RightWeld")
    local grab = seatParent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab")
    local drop = seatParent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureDrop")
    local function grabWithHand(det, weld, targetPart)
        grab:FireServer(det, targetPart, weld)
    end
    local function dropWithHand(weld, targetPart)
        drop:FireServer(weld, targetPart)
    end
    task.wait(0.05)
    while target and target.Parent and targetHumanoid.Health > 0 and loopAppleMethodActive do
        for i = 1, 20 do
            grabWithHand(leftDet, leftWeld, targetHRP)
        end
        dropWithHand(leftWeld, targetHRP)
        dropWithHand(leftWeld, targetHRP)
        task.wait(0.01)
        if not loopAppleMethodActive then
            break
        end
    end
end

-- BLOB LOCK FUNCTION
local BlobLock = {
    MyBlob = nil,
    Running = false,
    Time = 0,
    StartPos = nil,
    LastTP = 0
}

local function isnetworkowner(part)
    return part and part:IsDescendantOf(workspace) and part:GetNetworkOwner() == LocalPlayer
end

local function FindTargetByName(partialName)
    partialName = string.lower(partialName)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if string.find(string.lower(plr.Name), partialName) or 
               string.find(string.lower(plr.DisplayName), partialName) then
                return plr.Name
            end
        end
    end
    return nil
end

function BlobLock:TPToTargetAndBack(targetHRP)
    local mychar = LocalPlayer.Character
    if not mychar then return end
    local myHRP = FWC(mychar, "HumanoidRootPart", 2)
    if not myHRP then return end
    
    self.StartPos = myHRP.CFrame
    
    myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 5, 0)
    task.wait(0.05)
    
    for i = 1, 3 do
        ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(targetHRP, targetHRP.CFrame)
        task.wait()
    end
    
    task.wait(0.1)
    myHRP.CFrame = self.StartPos
    self.LastTP = tick()
end

function BlobLock:Start(targetPlayerName)
    if self.Running then return end
    self.Running = true
    
    if targetPlayerName == "" or targetPlayerName == nil then
        self.Running = false
        return
    end
    
    if not Players:FindFirstChild(targetPlayerName) then
        local found = FindTargetByName(targetPlayerName)
        if found then
            targetPlayerName = found
        else
            self.Running = false
            return
        end
    end
    
    task.spawn(function()
        local targetPlr = Players:FindFirstChild(targetPlayerName)
        if not targetPlr then 
            self:Stop()
            return
        end
        
        local char = targetPlr.Character
        if not char then
            targetPlr.CharacterAdded:Wait()
            task.wait(0.5)
            char = targetPlr.Character
        end
        
        local HRP = char and FWC(char, "HumanoidRootPart", 2)
        if HRP then
            self:TPToTargetAndBack(HRP)
        end
        
        while self.Running do
            task.wait()
            
            local mychar = LocalPlayer.Character
            if not mychar then continue end
            
            local myHRP = FWC(mychar, "HumanoidRootPart", 2)
            local myhum = FWC(mychar, "Humanoid", 2)
            if not myHRP or not myhum then continue end
            
            if not myhum.SeatPart then
                self:Stop()
                break
            end
            
            if myhum.SeatPart then 
                self.MyBlob = myhum.SeatPart.Parent 
            end
            
            targetPlr = Players:FindFirstChild(targetPlayerName)
            if not targetPlr then 
                self:Stop()
                break
            end
            
            char = targetPlr.Character
            if not char then continue end
            
            local hum = FWC(char, "Humanoid", 2)
            local HRP = FWC(char, "HumanoidRootPart", 2)
            if not hum or not HRP then continue end
            
            if hum.Health == 0 then continue end
            
            local dist = (myHRP.Position - HRP.Position).Magnitude
            if dist > 15 and tick() - self.LastTP > 0.5 then
                self:TPToTargetAndBack(HRP)
            end
            
            if self.MyBlob and self.MyBlob.Parent then
                task.defer(function()
                    if isnetworkowner(HRP) then
                        if tick() - self.Time > 0.5 then
                            hum.Sit = true
                            task.wait(0.16)
                            hum.Sit = false
                            self.Time = tick()
                        end  
                        
                        local LD = self.MyBlob:FindFirstChild("LeftDetector")
                        if LD then 
                            HRP.CFrame = LD.CFrame 
                        end
                        
                        for _, v in pairs(char:GetChildren()) do
                            if v:IsA("BasePart") then 
                                v.Velocity = Vector3.new() 
                            end
                        end
                        
                        if dist < 40 and hum.SeatPart then
                            ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(HRP, HRP.CFrame)
                        end
                    end
                end)
                
                local blob = self.MyBlob
                local LD = blob:FindFirstChild("LeftDetector")
                if LD then
                    local grab = blob.BlobmanSeatAndOwnerScript.CreatureGrab
                    local rel = blob.BlobmanSeatAndOwnerScript.CreatureRelease
                    grab:FireServer(LD, HRP, LD.LeftWeld)
                    task.wait(0.005)
                    rel:FireServer(LD.LeftWeld, HRP)
                end
            end
        end
    end)
end

function BlobLock:Stop()
    self.Running = false
    self.MyBlob = nil
end

-- Apply Method Once Button
BlobmanGroup:AddButton({
    Text = "Apply Method Once",
    Func = function()
        local targetName = Options.KickPlayerDropdown and Options.KickPlayerDropdown.Value
        local method = selectedBlobMethod
        if targetName and targetName ~= "" then
            local username = targetName:match("%(@(.+)%)")
            if method == "Bring" then
                Bring(username)
            elseif method == "Kick" then
                Kick(username)
            elseif method == "Loop Kick" then
                LoopKickMethod(username)
            elseif method == "Bypass" then
                Bypass(username)
            elseif method == "Loop Kick (Grab+Blob)" then
                -- loopKickBlobActive = true
                -- LoopKickBlobFunction(username)
            elseif method == "Blob Kill" then
                BlobKill(username)
            elseif method == "Lock" then
                BlobLock:Start(username)
            end
        end
    end,
    DoubleClick = false
})

-- Destroy Visual Button
BlobmanGroup:AddButton({
    Text = "Destroy Visual (Try 2 Times)",
    Func = function()
        local targetName = Options.KickPlayerDropdown and Options.KickPlayerDropdown.Value
        if targetName and targetName ~= "" then
            local username = targetName:match("%(@(.+)%)")
            BlobHeal(username)
        end
    end,
    DoubleClick = false
})

-- Loop Apple Method
local loopAppleMethodActive = false
local loopAppleMethodTask = nil

BlobmanGroup:AddToggle("LoopAppleMethod", {
    Text = "Loop Apple Method",
    Default = false,
    Callback = function(Value)
        loopAppleMethodActive = Value
        if Value then
            local targetName = Options.KickPlayerDropdown and Options.KickPlayerDropdown.Value
            local method = selectedBlobMethod
            if targetName and targetName ~= "" then
                local username = targetName:match("%(@(.+)%)")
                loopAppleMethodTask = task.spawn(function()
                    if method == "Loop Kick (Grab+Blob)" then
                        -- loopKickBlobActive = true
                        -- LoopKickBlobFunction(username)
                        while loopAppleMethodActive do
                            task.wait(0.1)
                        end
                        -- loopKickBlobActive = false
                    elseif method == "Lock" then
                        BlobLock:Start(username)
                        while loopAppleMethodActive and BlobLock.Running do
                            task.wait(0.1)
                        end
                        BlobLock:Stop()
                    else
                        while loopAppleMethodActive do
                            if method == "Bring" then Bring(username)
                            elseif method == "Kick" then Kick(username)
                            elseif method == "Loop Kick" then LoopKickMethod(username)
                            elseif method == "Bypass" then Bypass(username)
                            elseif method == "Blob Kill" then BlobKill(username) end
                            task.wait(1)
                        end
                    end
                end)
            else
                Toggles.LoopAppleMethod:SetValue(false)
            end
        else
            if loopAppleMethodTask then
                task.cancel(loopAppleMethodTask)
                loopAppleMethodTask = nil
            end
            BlobLock:Stop()
        end
    end
})

--// ============ KICK METHODS (TARGET TAB) ============

-- LOOP KICK
local function runBlobmanKick()
    if kickLoop then return end; kickLoop = true
    task.spawn(function()
        local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
        local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
        local DestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine")
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Root = Character:WaitForChild("HumanoidRootPart")
        local savedPos = Root.CFrame; local dragging = false; local grabStartTime = 0; local checkStartTime = 0
        local bodyPos = nil; local bodyGyro = nil
        local function cleanupBodies() pcall(function() if bodyPos then bodyPos:Destroy(); bodyPos = nil end; if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end end) end
        local function createBodies(targetRoot, pos)
            cleanupBodies()
            for _, v in pairs(targetRoot:GetChildren()) do if v:IsA("BodyPosition") or v:IsA("BodyGyro") then v:Destroy() end end
            bodyPos = Instance.new("BodyPosition"); bodyPos.MaxForce = Vector3.new(9e9, 9e9, 9e9); bodyPos.D = 100; bodyPos.Position = pos; bodyPos.Parent = targetRoot
            bodyGyro = Instance.new("BodyGyro"); bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bodyGyro.D = 100; bodyGyro.CFrame = CFrame.new(pos); bodyGyro.Parent = targetRoot
        end
        while kickLoop do
            local Target = selectedPlayer; if not Target or not Target.Parent then cleanupBodies(); break end
            Character = LocalPlayer.Character; Root = Character and Character:FindFirstChild("HumanoidRootPart")
            local tChar = Target.Character; local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart"); local tHum = tChar and tChar:FindFirstChild("Humanoid")
            if tRoot and tHum and tHum.Health > 0 and Root then
                if not dragging then
                    Root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3); cleanupBodies(); checkStartTime = 0
                    pcall(function() tHum.PlatformStand = true; tHum.Sit = true; SetNetworkOwner:FireServer(tRoot, tRoot.CFrame); SetNetworkOwner:FireServer(tRoot, tRoot.CFrame); DestroyGrabLine:FireServer(tRoot) end)
                    Root.AssemblyLinearVelocity = Vector3.zero; Root.AssemblyAngularVelocity = Vector3.zero
                    if grabStartTime == 0 then grabStartTime = tick() end
                    if tick() - grabStartTime > 0.35 then dragging = true; grabStartTime = 0; checkStartTime = tick(); local lockPos = savedPos * CFrame.new(0, 17, 0); createBodies(tRoot, lockPos.Position) end
                else
                    Root.CFrame = savedPos; local lockPos = savedPos * CFrame.new(0, 17, 0)
                    Root.AssemblyLinearVelocity = Vector3.zero; Root.AssemblyAngularVelocity = Vector3.zero
                    if bodyPos and bodyPos.Parent then bodyPos.Position = lockPos.Position; if bodyGyro then bodyGyro.CFrame = lockPos end else createBodies(tRoot, lockPos.Position) end
                    tHum.PlatformStand = true
                    pcall(function() SetNetworkOwner:FireServer(tRoot, lockPos); SetNetworkOwner:FireServer(tRoot, lockPos); DestroyGrabLine:FireServer(tRoot) end)
                    if checkStartTime > 0 and tick() - checkStartTime > 0.30 then
                        local currentDist = (tRoot.Position - lockPos.Position).Magnitude
                        if currentDist > 10 then dragging = false; grabStartTime = 0; checkStartTime = 0; cleanupBodies(); Root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3) else checkStartTime = tick() end
                    end
                end
            else dragging = false; grabStartTime = 0; checkStartTime = 0; cleanupBodies() end
            RunService.Heartbeat:Wait()
        end
        cleanupBodies(); if Root then Root.CFrame = savedPos end
        if selectedPlayer and selectedPlayer.Character then if selectedPlayer.Character:FindFirstChild("Humanoid") then local hum = selectedPlayer.Character.Humanoid; pcall(function() hum.PlatformStand = false; hum.Sit = false; hum.AutoRotate = true; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end end
        Toggles.BlobmanKickToggle:SetValue(false)
    end)
end

-- PALLET RAGDOLL
local palletRagdollActive = false; local palletRagdollTask = nil
local function PalletRagdollFunction(targetName)
    local target = Players:FindFirstChild(targetName); if not target or not target.Character then return end
    local RS = ReplicatedStorage; local GE = RS:WaitForChild("GrabEvents"); local skyPos = CFrame.new(0, 800000, 0)
    RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("PalletLightBrown", skyPos, Vector3.zero)
    local pallet
    repeat pallet = workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys") and workspace[LocalPlayer.Name.."SpawnedInToys"]:FindFirstChild("PalletLightBrown"); RunService.Heartbeat:Wait() until pallet or not palletRagdollActive
    if not pallet then return end
    local mainPart = pallet:FindFirstChild("SoundPart"); if not mainPart then return end
    mainPart.CanCollide = false; mainPart.Anchored = false
    local function claim(part) GE.SetNetworkOwner:FireServer(part, part.CFrame); GE.CreateGrabLine:FireServer(part, Vector3.zero, part.Position, false); GE.DestroyGrabLine:FireServer(part) end
    claim(mainPart)
    while palletRagdollActive do
        for i = 1, 20 do RunService.Heartbeat:Wait() end
        if not target or not target.Parent or not target.Character then break end
        local head = target.Character:FindFirstChild("Head"); if not head then continue end
        local targetPos = head.Position; mainPart.CFrame = CFrame.new(targetPos.X, targetPos.Y + 0.2, targetPos.Z); mainPart.AssemblyLinearVelocity = Vector3.zero; mainPart.AssemblyAngularVelocity = Vector3.new(1000, 1000, 1000)
        claim(mainPart); mainPart.CanCollide = true
        for i = 1, 3 do RunService.Heartbeat:Wait() end
        mainPart.CanCollide = false; mainPart.CFrame = skyPos; mainPart.AssemblyAngularVelocity = Vector3.zero
    end
    if pallet then pcall(function() RS.MenuToys.DestroyToy:FireServer(pallet) end); if pallet.Parent then pallet:Destroy() end end
end

-- REMOVE ANTI KICK
local removeAntiKickActive = false; local removeAntiKickTask = nil
local function RemoveAntiKickFunction(targetName)
    local SetNetOwner = ReplicatedStorage.GrabEvents.SetNetworkOwner
    while removeAntiKickActive do
        local target = Players:FindFirstChild(targetName)
        if target then
            local spawned = workspace:FindFirstChild(target.Name .. "SpawnedInToys")
            if spawned then
                for _, toyName in ipairs({"NinjaKunai", "NinjaShuriken", "AntiKick"}) do
                    local toy = spawned:FindFirstChild(toyName)
                    if toy then
                        local part = toy:FindFirstChild("SoundPart")
                        if part then
                            pcall(function() SetNetOwner:FireServer(part, part.CFrame) end)
                            if part:FindFirstChild("PartOwner") and part.PartOwner.Value == LocalPlayer.Name then part.CFrame = CFrame.new(0, 1000, 0) end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

-- LOOP KILL
local loopKillActive = false
local loopKillTask = nil

local function LoopKillFunction(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target then return end
    local RS = ReplicatedStorage
    local GE = RS:WaitForChild("GrabEvents")

    while loopKillActive and target and target.Parent do
        if not target.Character then
            task.wait(0.5)
            continue
        end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local tChar = target.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local tHum = tChar and tChar:FindFirstChild("Humanoid")
        if tRoot and tHum and tHum.Health > 0 and myRoot then
            local currentPos = myRoot.CFrame
            local attackStart = tick()
            while tick() - attackStart < 0.35 and loopKillActive do
                if not tRoot.Parent then break end
                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
                myRoot.Velocity = Vector3.zero
                pcall(function()
                    GE.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
                    tHum:ChangeState(Enum.HumanoidStateType.Dead)
                    tHum.Health = 0
                    GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                    GE.DestroyGrabLine:FireServer(tRoot)
                end)
                RunService.Heartbeat:Wait()
            end
            if myRoot then
                myRoot.CFrame = currentPos
                myRoot.Velocity = Vector3.zero
            end
            task.wait(1.2)
        else
            task.wait(0.5)
        end
    end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.Velocity = Vector3.zero end
end

KickMethodsGroup:AddToggle("BlobmanKickToggle", { Text = "Loop Kick", Default = false, Callback = function(State) if State then runBlobmanKick() else kickLoop = false end end })
KickMethodsGroup:AddToggle("LoopKillToggle", { Text = "Loop Kill", Default = false, Callback = function(State) 
    loopKillActive = State
    local targetName = selectedPlayer and selectedPlayer.Name
    if State then
        if targetName then
            loopKillTask = task.spawn(function() LoopKillFunction(targetName) end)
        else
            loopKillActive = false
            Toggles.LoopKillToggle:SetValue(false)
            Library:Notify({Title = "FrendlyHub", Description = "Select a player first!", Duration = 2})
        end
    else
        if loopKillTask then
            task.cancel(loopKillTask)
            loopKillTask = nil
        end
    end
end })
KickMethodsGroup:AddToggle("PalletRagdollToggle", { Text = "Pallet Ragdoll", Default = false, Callback = function(Value) palletRagdollActive = Value; if Value then local n = selectedPlayer and selectedPlayer.Name; if n then palletRagdollTask = task.spawn(function() PalletRagdollFunction(n) end) end else if palletRagdollTask then task.cancel(palletRagdollTask); palletRagdollTask = nil end end end })
FunctionsGroup:AddToggle("RemoveAntiKickToggle", { Text = "Remove Anti Kick", Default = false, Callback = function(Value) removeAntiKickActive = Value; if Value then local n = selectedPlayer and selectedPlayer.Name; if n then removeAntiKickTask = task.spawn(function() RemoveAntiKickFunction(n) end) end else if removeAntiKickTask then task.cancel(removeAntiKickTask); removeAntiKickTask = nil end end end })

-- MOVE PLAYER
local moveX = 0
local moveY = 0
local moveZ = 0

MovePlayerGroup:AddSlider("MoveX", {
    Text = "X Position",
    Default = 0,
    Min = -1000,
    Max = 1000,
    Rounding = 1,
    Callback = function(Value)
        moveX = Value
    end
})

MovePlayerGroup:AddSlider("MoveY", {
    Text = "Y Position (Height)",
    Default = 0,
    Min = -100,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        moveY = Value
    end
})

MovePlayerGroup:AddSlider("MoveZ", {
    Text = "Z Position",
    Default = 0,
    Min = -1000,
    Max = 1000,
    Rounding = 1,
    Callback = function(Value)
        moveZ = Value
    end
})

MovePlayerGroup:AddButton({
    Text = "Teleport Player to Position",
    Func = function()
        if selectedPlayer and selectedPlayer.Character then
            local hrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local newPos = CFrame.new(moveX, moveY, moveZ)
                hrp.CFrame = newPos
                Library:Notify({
                    Title = "FrendlyHub",
                    Description = selectedPlayer.Name .. " teleported to X:" .. moveX .. " Y:" .. moveY .. " Z:" .. moveZ,
                    Duration = 3
                })
            else
                Library:Notify({Title = "FrendlyHub", Description = "Player has no character!", Duration = 2})
            end
        else
            Library:Notify({Title = "FrendlyHub", Description = "Select a player first!", Duration = 2})
        end
    end
})

MovePlayerGroup:AddButton({
    Text = "Bring Player to Me",
    Func = function()
        if selectedPlayer and selectedPlayer.Character then
            local myChar = LocalPlayer.Character
            local targetChar = selectedPlayer.Character
            if myChar and targetChar then
                local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                if myHrp and targetHrp then
                    targetHrp.CFrame = myHrp.CFrame + Vector3.new(0, 3, 0)
                    Library:Notify({
                        Title = "FrendlyHub",
                        Description = selectedPlayer.Name .. " brought to you!",
                        Duration = 3
                    })
                end
            end
        else
            Library:Notify({Title = "FrendlyHub", Description = "Select a player first!", Duration = 2})
        end
    end
})

MovePlayerGroup:AddButton({
    Text = "Teleport Me to Player",
    Func = function()
        if selectedPlayer and selectedPlayer.Character then
            local myChar = LocalPlayer.Character
            local targetChar = selectedPlayer.Character
            if myChar and targetChar then
                local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                if myHrp and targetHrp then
                    myHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
                    Library:Notify({
                        Title = "FrendlyHub",
                        Description = "You teleported to " .. selectedPlayer.Name,
                        Duration = 3
                    })
                end
            end
        else
            Library:Notify({Title = "FrendlyHub", Description = "Select a player first!", Duration = 2})
        end
    end
})

Players.PlayerAdded:Connect(function() Options.KickPlayerDropdown:SetValues(getPlayerList()) end)
Players.PlayerRemoving:Connect(function() Options.KickPlayerDropdown:SetValues(getPlayerList()) end)

--// ============ VISUAL TAB ============
local VisualGroup = Tabs.Visual:AddLeftGroupbox("Visual Effects", "eye")

-- kxH
local HEADLESS_MESH_ID = "rbxassetid://1095708"
local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_COLOR = Color3.fromRGB(50, 50, 50)
local kxHEnabled = false

local function applyHeadless(c) 
    local h = c:FindFirstChild("Head")
    if not h then return end
    for _, ch in ipairs(h:GetChildren()) do 
        if ch.Name == "HeadlessMesh" or (ch:IsA("SpecialMesh") and ch.MeshId == HEADLESS_MESH_ID) then 
            ch:Destroy() 
        end 
    end
    h.Transparency = 1
    h.CanCollide = false
    local f = h:FindFirstChild("face")
    if f then f:Destroy() end
    local m = Instance.new("SpecialMesh")
    m.MeshType = Enum.MeshType.FileMesh
    m.MeshId = HEADLESS_MESH_ID
    m.Scale = Vector3.new(0.001, 0.001, 0.001)
    m.Name = "HeadlessMesh"
    m.Parent = h 
end

local function applyKorbloxLeg(c) 
    local rl = c:FindFirstChild("Right Leg") or c:FindFirstChild("RightUpperLeg")
    if not rl then return end
    for _, ch in ipairs(rl:GetChildren()) do 
        if ch.Name == "KorbloxMesh" or (ch:IsA("SpecialMesh") and ch.MeshId == KORBLOX_MESH_ID) or ch:IsA("SpecialMesh") or ch:IsA("CharacterMesh") then 
            ch:Destroy() 
        end 
    end
    rl.Color = KORBLOX_COLOR
    local m = Instance.new("SpecialMesh")
    m.MeshType = Enum.MeshType.FileMesh
    m.MeshId = KORBLOX_MESH_ID
    m.Scale = Vector3.new(1, 1, 1)
    m.Name = "KorbloxMesh"
    m.Parent = rl 
end

local function restoreHead(c) 
    local h = c:FindFirstChild("Head")
    if not h then return end
    for _, ch in ipairs(h:GetChildren()) do 
        if ch.Name == "HeadlessMesh" or (ch:IsA("SpecialMesh") and ch.MeshId == HEADLESS_MESH_ID) then 
            ch:Destroy() 
        end 
    end
    h.Transparency = 0
    h.CanCollide = true 
end

local function restoreLeg(c) 
    local rl = c:FindFirstChild("Right Leg") or c:FindFirstChild("RightUpperLeg")
    if not rl then return end
    for _, ch in ipairs(rl:GetChildren()) do 
        if ch.Name == "KorbloxMesh" or (ch:IsA("SpecialMesh") and ch.MeshId == KORBLOX_MESH_ID) then 
            ch:Destroy() 
        end 
    end
    rl.Color = Color3.fromRGB(255, 255, 255) 
end

local function applykxH(c) 
    applyHeadless(c)
    applyKorbloxLeg(c) 
end

local function restorekxH(c) 
    restoreHead(c)
    restoreLeg(c) 
end

VisualGroup:AddToggle("kxHToggle", { 
    Text = "kxH", 
    Default = false, 
    Callback = function(S) 
        kxHEnabled = S
        if S then 
            if LocalPlayer.Character then applykxH(LocalPlayer.Character) end
            for _, p in ipairs(Players:GetPlayers()) do 
                if p.Character then applykxH(p.Character) end 
            end
        else 
            if LocalPlayer.Character then restorekxH(LocalPlayer.Character) end
            for _, p in ipairs(Players:GetPlayers()) do 
                if p.Character then restorekxH(p.Character) end 
            end
        end 
    end 
})

-- FOV
VisualGroup:AddSlider("FOVSlider", { 
    Text = "Field of View", 
    Default = workspace.CurrentCamera.FieldOfView, 
    Min = 1, 
    Max = 120, 
    Rounding = 1, 
    Callback = function(V) 
        workspace.CurrentCamera.FieldOfView = V 
    end 
})

-- Third Person
local thirdPersonEnabled = false
VisualGroup:AddToggle("ThirdPersonToggle", { 
    Text = "Third Person", 
    Default = false, 
    Callback = function(V) 
        thirdPersonEnabled = V
        if V then 
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = 1000
        else 
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            LocalPlayer.CameraMaxZoomDistance = 0.5
        end 
    end 
})

-- PCLD Outline ESP
local espEnabled = false
local espBoxes = {}
local espColor = Color3.fromRGB(255, 255, 255)
local espTargetNames = {"partesp", "playercharacterlocationdetector"}

local function IsTargetESP(o)
    if not o:IsA("BasePart") then return false end
    for _, n in ipairs(espTargetNames) do
        if string.lower(o.Name) == string.lower(n) then return true end
    end
    return false
end

local function AddOutlineESP(o)
    if espBoxes[o] then 
        espBoxes[o].Color3 = espColor
        return 
    end
    
    local outline = Instance.new("SelectionBox")
    outline.Adornee = o
    outline.Color3 = espColor
    outline.LineThickness = 0.05
    outline.Transparency = 0.5
    outline.SurfaceTransparency = 1
    outline.SurfaceColor3 = espColor
    outline.Parent = game.CoreGui
    
    espBoxes[o] = outline
    
    o.AncestryChanged:Connect(function(_, parent)
        if not parent and espBoxes[o] then
            espBoxes[o]:Destroy()
            espBoxes[o] = nil
        end
    end)
end

local function RemoveAllESP()
    for obj, box in pairs(espBoxes) do
        if box then 
            pcall(function() box:Destroy() end)
        end
    end
    espBoxes = {}
end

local function ScanForTargets()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if espEnabled and IsTargetESP(obj) then
            AddOutlineESP(obj)
        end
    end
end

VisualGroup:AddToggle("PCLDToggle", { 
    Text = "PCLD Outline ESP", 
    Default = false, 
    Callback = function(V) 
        espEnabled = V
        if V then 
            ScanForTargets()
            workspace.DescendantAdded:Connect(function(obj)
                if espEnabled and IsTargetESP(obj) then
                    AddOutlineESP(obj)
                end
            end)
        else 
            RemoveAllESP()
        end 
    end 
}):AddColorPicker("PCLDColor", { 
    Default = Color3.fromRGB(255, 255, 255), 
    Title = "Outline Color", 
    Callback = function(V) 
        espColor = V
        for obj, box in pairs(espBoxes) do
            if box then 
                box.Color3 = espColor
            end
        end 
    end 
})

-- Kick Notify
local kickNotifyConnection = nil
VisualGroup:AddToggle("KickNotifyToggle", { 
    Text = "Kick Notify", 
    Default = false, 
    Callback = function(V) 
        if V then 
            kickNotifyConnection = workspace.ChildAdded:Connect(function(o) 
                local kickObjectNames = {
                    ["blackholekick"] = true,
                    ["blackholekicktweens(old)"] = true,
                    ["blackholekicktweens"] = true,
                    ["jhole"] = true,
                    ["blackhole"] = true,
                    ["black_hole"] = true,
                    ["voidhole"] = true,
                    ["singularity"] = true,
                }
                if not o.Name or not kickObjectNames[o.Name:lower()] then return end
                task.wait(0.1)
                local pos
                if o:IsA("BasePart") then 
                    pos = o.Position 
                else 
                    local pt = o:FindFirstChildWhichIsA("BasePart", true)
                    if pt then pos = pt.Position end 
                end
                if not pos then return end
                local cp = getClosestPlayer(pos)
                if cp then 
                    Library:Notify({Title="FrendlyHub", Description=cp.DisplayName.." (@"..cp.Name..") Got Kicked!", Duration=3})
                else 
                    Library:Notify({Title="FrendlyHub", Description="Someone Got Kicked!", Duration=3})
                end
            end)
        else 
            if kickNotifyConnection then 
                kickNotifyConnection:Disconnect()
                kickNotifyConnection = nil 
            end 
        end 
    end 
})

-- Packet Lag Notify
local packetLagNotifyEnabled = false
local lastLagSource = false

local function GetSizeMB(sl) 
    return sl / (1024 * 1024) 
end

local function StartPacketLagDetector() 
    local RS = game:GetService("ReplicatedStorage")
    RS.GrabEvents.ExtendGrabLine.OnClientEvent:Connect(function(a1, d) 
        if typeof(d) == "string" and not lastLagSource and packetLagNotifyEnabled then 
            lastLagSource = true
            local sl = string.len(d)
            if sl > 300 then 
                local sr = math.round(GetSizeMB(sl) * 1000) / 1000
                Library:Notify({Title="FrendlyHub", Description="PACKET LAG DETECTED\nSource: "..tostring(a1):sub(1,20).."\nSize: "..tostring(sr).." MB", Duration=5})
            end
            task.delay(5, function() 
                lastLagSource = false 
            end)
        end 
    end)
end

VisualGroup:AddToggle("PacketLagNotifyToggle", { 
    Text = "Packet Lag Notify", 
    Default = false, 
    Callback = function(V) 
        packetLagNotifyEnabled = V
        if V and not lastLagSource then 
            StartPacketLagDetector()
        end 
    end 
})

-- LEAVE/JOIN TARGET NOTIFY
local targetNotifyConnections = {}
local targetNotifyActive = false

local function updateTargetNotifyList()
    local targetName = Options.KickPlayerDropdown and Options.KickPlayerDropdown.Value
    if not targetName or targetName == "" then return end
    
    local username = targetName:match("%(@(.+)%)")
    if username then
        local target = Players:FindFirstChild(username)
        if target then
            Library:Notify({
                Title = "FrendlyHub",
                Description = target.DisplayName .. " (" .. target.Name .. ") is currently in game",
                Duration = 3
            })
        end
    end
end

local function startTargetNotify()
    if targetNotifyActive then return end
    targetNotifyActive = true
    
    local targetName = Options.KickPlayerDropdown and Options.KickPlayerDropdown.Value
    if not targetName or targetName == "" then
        Library:Notify({Title = "FrendlyHub", Description = "Select a target player first!", Duration = 2})
        targetNotifyActive = false
        if Toggles.TargetNotifyToggle then Toggles.TargetNotifyToggle:SetValue(false) end
        return
    end
    
    updateTargetNotifyList()
    
    targetNotifyConnections["Added"] = Players.PlayerAdded:Connect(function(player)
        if targetNotifyActive and Options.KickPlayerDropdown then
            local targetName = Options.KickPlayerDropdown.Value
            local username = targetName and targetName:match("%(@(.+)%)")
            if username and username == player.Name then
                Library:Notify({
                    Title = "FrendlyHub",
                    Description = player.DisplayName .. " (" .. player.Name .. ") Joined",
                    Duration = 3
                })
            end
        end
    end)
    
    targetNotifyConnections["Removing"] = Players.PlayerRemoving:Connect(function(player)
        if targetNotifyActive and Options.KickPlayerDropdown then
            local targetName = Options.KickPlayerDropdown.Value
            local username = targetName and targetName:match("%(@(.+)%)")
            if username and username == player.Name then
                Library:Notify({
                    Title = "FrendlyHub",
                    Description = player.DisplayName .. " (" .. player.Name .. ") Left",
                    Duration = 3
                })
            end
        end
    end)
end

local function stopTargetNotify()
    targetNotifyActive = false
    for _, conn in pairs(targetNotifyConnections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    targetNotifyConnections = {}
end

VisualGroup:AddToggle("TargetNotifyToggle", {
    Text = "Leave/Join Target Notify",
    Default = false,
    Callback = function(Value)
        if Value then
            startTargetNotify()
        else
            stopTargetNotify()
        end
    end
})

--// ============ FUN TAB ============
local FunGroup = Tabs.Fun:AddLeftGroupbox("Fun", "smile")

local spawnSpinEnabled = false
local spawnSpinSpeed = 1
local spawnSpinConnection = nil

local function startSpawnSpin() 
    if spawnSpinConnection then return end
    spawnSpinConnection = RunService.Heartbeat:Connect(function() 
        pcall(function() 
            local sp = workspace:FindFirstChild("SpawnLocation")
            if sp then 
                sp.CFrame = sp.CFrame * CFrame.Angles(0, math.rad(spawnSpinSpeed), 0)
            end 
        end) 
    end) 
end

local function stopSpawnSpin() 
    if spawnSpinConnection then 
        spawnSpinConnection:Disconnect()
        spawnSpinConnection = nil 
    end 
end

FunGroup:AddToggle("SpawnSpinToggle", { 
    Text = "Spawn Spin", 
    Default = false, 
    Callback = function(S) 
        spawnSpinEnabled = S
        if S then 
            startSpawnSpin()
        else 
            stopSpawnSpin()
        end 
    end 
})

FunGroup:AddSlider("SpawnSpinSpeed", { 
    Text = "Spin Speed", 
    Default = 1, 
    Min = 1, 
    Max = 100, 
    Rounding = 0, 
    Callback = function(V) 
        spawnSpinSpeed = V 
    end 
})

-- Jerk Off
local jerkOffActive = false
local jerkOffAnimTrack = nil
local jerkOffKey = Enum.KeyCode.Q

local function StartJerkOff()
    local plr = LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if jerkOffAnimTrack then
        pcall(function() jerkOffAnimTrack:Stop() end)
    end
    
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://168268306"
    
    jerkOffAnimTrack = animator:LoadAnimation(anim)
    jerkOffAnimTrack.Priority = Enum.AnimationPriority.Action
    jerkOffAnimTrack.Looped = true
    jerkOffAnimTrack:Play()
    
    jerkOffActive = true
    
    task.spawn(function()
        while jerkOffActive do
            task.wait(0.5)
            if jerkOffAnimTrack and not jerkOffAnimTrack.IsPlaying and jerkOffActive then
                jerkOffAnimTrack:Play()
            end
        end
    end)
end

local function StopJerkOff()
    jerkOffActive = false
    if jerkOffAnimTrack then
        pcall(function() 
            jerkOffAnimTrack:Stop() 
        end)
        jerkOffAnimTrack = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Running)
                hum.Jump = true
                task.wait(0.1)
                hum.Jump = false
            end)
        end
    end
end

FunGroup:AddToggle("JerkOffToggle", {
    Text = "Jerk Off",
    Default = false,
    Callback = function(Value)
        if Value then
            StartJerkOff()
        else
            StopJerkOff()
        end
    end
})

FunGroup:AddLabel("Jerk Off Key"):AddKeyPicker("JerkOffKeyPicker", {
    Default = "Q",
    Mode = "Press",
    Text = "Jerk Off Key",
    NoUI = false,
    Callback = function() end,
    ChangedCallback = function(NewKey)
        jerkOffKey = NewKey
    end
})

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == jerkOffKey then
        if Toggles.JerkOffToggle then
            Toggles.JerkOffToggle:SetValue(not Toggles.JerkOffToggle.Value)
        end
    end
end)

--// ============ MISC TAB ============
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc", "gear")

local tpEnabled = false

MiscGroup:AddLabel("Teleport"):AddKeyPicker("TeleportKey", {
    Default = "T",
    Mode = "Press",
    Text = "Teleport Key",
    NoUI = false,
    Callback = function()
        if tpEnabled then
            pcall(function()
                local mp = LocalPlayer:GetMouse().Hit
                local c = LocalPlayer.Character
                if c then
                    local r = c:FindFirstChild("HumanoidRootPart")
                    if r then
                        r.CFrame = CFrame.new(mp.Position)
                    end
                end
            end)
        end
    end
})

MiscGroup:AddToggle("TeleportToggle", {
    Text = "Teleport Binder",
    Default = false,
    Callback = function(Value)
        tpEnabled = Value
    end
})

-- PSHADE ULTIMATE (КОПКА)
MiscGroup:AddButton({
    Text = "PShade Ultimate",
    Func = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua'))()
            Library:Notify({
                Title = "FrendlyHub",
                Description = "PShade Ultimate loaded!",
                Duration = 3
            })
        end)
    end,
    DoubleClick = false
})

--// Startup Sound
local function playStartupSound() 
    pcall(function() 
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://452267918"
        s.Volume = 5
        s.Parent = workspace
        s:Play()
        s.Ended:Connect(function() 
            s:Destroy() 
        end)
    end) 
end
playStartupSound()

--// Load Config & Theme
local function LoadAll() 
    local Success, Error = pcall(function() 
        SaveManager:Load() 
    end)
    if Success then 
        print("Config loaded successfully!") 
    else 
        warn("Config Load Error: " .. tostring(Error)) 
    end
    
    local ThemeSuccess, ThemeError = pcall(function() 
        ThemeManager:Load() 
    end)
    if ThemeSuccess then 
        print("Theme loaded successfully!") 
    else 
        warn("Theme Load Error: " .. tostring(ThemeError)) 
    end 
end

LoadAll()

game:BindToClose(function() 
    pcall(function() 
        SaveManager:Save() 
    end)
    pcall(function() 
        ThemeManager:Save() 
    end)
    print("Config and Theme saved!") 
end)

Library:Notify({
    Title = "FrendlyHub",
    Description = "Script loaded successfully!",
    Duration = 5
})
