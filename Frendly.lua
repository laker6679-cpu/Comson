--// Repo
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--// HWID Lock
local AllowedUsers = {
    10795177721, -- Твой UserId
    7508375923,
}

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
    Main = Window:AddTab("Main"),
    Defens = Window:AddTab("Defens"),
    Target = Window:AddTab("Target"),
    Visual = Window:AddTab("Visual"),
    ["UI Settings"] = Window:AddTab("Settings")
}

--// UI SETTINGS
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end
})

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
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub")
SaveManager:SetSubFolder("specific-place")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

pcall(function()
    ThemeManager:SetTheme("Dark")
    ThemeManager:SetAccentColor(Color3.fromRGB(255, 255, 255))
end)

--// DEFENS TAB
local DefensGroup = Tabs.Defens:AddLeftGroupbox("Defense", "shield")

local antiGrabEnabled = false
local antiGrabConnection = nil
local beingHeldConnection = nil

local function setupBlobmanDefense()
    pcall(function()
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local CE = ReplicatedStorage:FindFirstChild("CharacterEvents")
        
        if CE then
            local StruggleEvent = CE:FindFirstChild("Struggle")
            local BeingHeld = LocalPlayer:FindFirstChild("IsHeld")
            
            if BeingHeld and StruggleEvent then
                beingHeldConnection = BeingHeld.Changed:Connect(function(C)
                    if C == true then
                        local char = LocalPlayer.Character
                        if char and BeingHeld.Value == true then
                            local Event
                            Event = RunService.RenderStepped:Connect(function()
                                if BeingHeld.Value == true then
                                    local Root = char:FindFirstChild("HumanoidRootPart")
                                    if Root then
                                        Root.AssemblyLinearVelocity = Vector3.new()
                                    end
                                    StruggleEvent:FireServer(LocalPlayer)
                                elseif BeingHeld.Value == false then
                                    Event:Disconnect()
                                end
                            end)
                        end
                    end
                end)
            end
        end
    end)
end

workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Explosion") then
        pcall(function()
            v.BlastPressure = 0
        end)
    end
end)

local function setupSitDefense(character)
    local Humanoid = character:FindFirstChildWhichIsA("Humanoid") or character:WaitForChild("Humanoid")
    local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    pcall(function()
        local firePart = HumanoidRootPart:FindFirstChild("FirePlayerPart")
        if firePart then
            firePart:Remove()
        end
    end)
    
    Humanoid.Changed:Connect(function(C)
        if C == "Sit" and Humanoid.Sit == true then
            if Humanoid.SeatPart ~= nil and tostring(Humanoid.SeatPart.Parent) == "CreatureBlobman" then
            elseif Humanoid.SeatPart == nil then
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                Humanoid.Sit = false
            end
        end
    end)
end

local function enableAntiGrab()
    setupBlobmanDefense()
    
    if LocalPlayer.Character then
        setupSitDefense(LocalPlayer.Character)
    end
    
    antiGrabConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        setupSitDefense(character)
        if beingHeldConnection then
            beingHeldConnection:Disconnect()
            beingHeldConnection = nil
        end
        setupBlobmanDefense()
    end)
end

local function disableAntiGrab()
    if antiGrabConnection then
        antiGrabConnection:Disconnect()
        antiGrabConnection = nil
    end
    if beingHeldConnection then
        beingHeldConnection:Disconnect()
        beingHeldConnection = nil
    end
end

DefensGroup:AddToggle("AntiGrabToggle", {
    Text = "Anti Grab",
    Default = false,
    Callback = function(State)
        antiGrabEnabled = State
        if State then
            enableAntiGrab()
            task.spawn(function()
                local notif = Library:Notify("Anti Grab: ON", "Success")
                task.wait(3)
                pcall(function()
                    notif:Destroy()
                end)
            end)
        else
            disableAntiGrab()
            task.spawn(function()
                local notif = Library:Notify("Anti Grab: OFF", "Info")
                task.wait(3)
                pcall(function()
                    notif:Destroy()
                end)
            end)
        end
    end
})

--// TARGET TAB
local TargetGroup = Tabs.Target:AddLeftGroupbox("Target Interaction")

local selectedPlayer = nil
local kickLoop = false

local function getPlayerList()
    local List = {}
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            table.insert(List, Player.Name)
        end
    end
    return List
end

TargetGroup:AddDropdown("KickPlayerDropdown", {
    Values = getPlayerList(),
    Default = nil,
    Multi = false,
    Text = "Select Player",
    Callback = function(Value)
        selectedPlayer = Players:FindFirstChild(Value)
    end
})

TargetGroup:AddButton({
    Text = "Refresh Player List",
    Func = function()
        Options.KickPlayerDropdown:SetValues(getPlayerList())
    end
})

--// Main Loop - УСКОРЕННЫЙ РАГДОЛЛ
local function runBlobmanKick()
    if kickLoop then return end
    kickLoop = true

    task.spawn(function()
        local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
        local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
        local CreateGrabLine = GrabEvents:WaitForChild("CreateGrabLine")
        local DestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine")

        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Root = Character:WaitForChild("HumanoidRootPart")

        local dragging = false
        local grabStartTime = 0
        local savedPosition = nil
        local frameCounter = 0

        while kickLoop do
            local Target = selectedPlayer
            if not Target then task.wait() continue end

            local TargetCharacter = Target.Character
            if not TargetCharacter then
                dragging = false; grabStartTime = 0; task.wait(); continue
            end

            local TargetRoot = TargetCharacter:FindFirstChild("HumanoidRootPart")
            local TargetHumanoid = TargetCharacter:FindFirstChild("Humanoid")
            if not TargetRoot or not TargetHumanoid then
                dragging = false; grabStartTime = 0; task.wait(); continue
            end
            if TargetHumanoid.Health <= 0 then
                dragging = false; grabStartTime = 0; task.wait(); continue
            end

            if not dragging then
                if not savedPosition then savedPosition = Root.CFrame end
                
                Root.CFrame = TargetRoot.CFrame
                Root.AssemblyLinearVelocity = Vector3.zero
                Root.AssemblyAngularVelocity = Vector3.zero

                TargetRoot.AssemblyLinearVelocity = Vector3.zero
                TargetRoot.AssemblyAngularVelocity = Vector3.zero
                TargetRoot.Velocity = Vector3.zero
                TargetRoot.RotVelocity = Vector3.zero

                pcall(function()
                    TargetHumanoid.PlatformStand = true
                    TargetHumanoid.Sit = true
                    SetNetworkOwner:FireServer(TargetRoot, Root.CFrame)
                    CreateGrabLine:FireServer(TargetRoot, Vector3.zero, TargetRoot.Position, false)
                end)

                if grabStartTime == 0 then grabStartTime = tick() end
                if tick() - grabStartTime > 0.35 then
                    dragging = true
                    grabStartTime = 0
                    frameCounter = 0
                    if savedPosition then
                        Root.CFrame = savedPosition
                        Root.AssemblyLinearVelocity = Vector3.zero
                        Root.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            else
                local LockPos = Root.CFrame * CFrame.new(0, 17, 0)
                local LockPosVector = LockPos.Position

                TargetRoot.CFrame = LockPos
                TargetRoot.Velocity = Vector3.zero
                TargetRoot.RotVelocity = Vector3.zero
                TargetRoot.AssemblyLinearVelocity = Vector3.zero
                TargetRoot.AssemblyAngularVelocity = Vector3.zero

                pcall(function()
                    TargetHumanoid.PlatformStand = true
                    TargetHumanoid.Sit = true
                    TargetHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    TargetHumanoid.AutoRotate = false
                end)

                frameCounter = frameCounter + 1

                local PCLD = TargetCharacter:FindFirstChild("PCLD")
                    or TargetCharacter:FindFirstChild("PlayerCharacterDetectLocation")
                if PCLD and PCLD:IsA("BasePart") then
                    pcall(function()
                        PCLD.CFrame = LockPos
                        PCLD.Velocity = Vector3.zero
                        PCLD.RotVelocity = Vector3.zero
                        PCLD.AssemblyLinearVelocity = Vector3.zero
                        PCLD.AssemblyAngularVelocity = Vector3.zero
                        SetNetworkOwner:FireServer(PCLD, LockPosVector)
                    end)
                end

                local PCLDInWorkspace = workspace:FindFirstChild("PCLD_" .. Target.Name)
                    or workspace:FindFirstChild(Target.Name .. "_PCLD")
                if PCLDInWorkspace and PCLDInWorkspace:IsA("BasePart") then
                    pcall(function()
                        PCLDInWorkspace.CFrame = LockPos
                        PCLDInWorkspace.Velocity = Vector3.zero
                        PCLDInWorkspace.RotVelocity = Vector3.zero
                        PCLDInWorkspace.AssemblyLinearVelocity = Vector3.zero
                        PCLDInWorkspace.AssemblyAngularVelocity = Vector3.zero
                        SetNetworkOwner:FireServer(PCLDInWorkspace, LockPosVector)
                    end)
                end

                for _, part in ipairs(TargetCharacter:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            part.AssemblyLinearVelocity = Vector3.zero
                            part.AssemblyAngularVelocity = Vector3.zero
                            part.Velocity = Vector3.zero
                            part.RotVelocity = Vector3.zero
                        end)
                    end
                end

                pcall(function()
                    SetNetworkOwner:FireServer(TargetRoot, LockPosVector)
                    DestroyGrabLine:FireServer(TargetRoot)
                    CreateGrabLine:FireServer(TargetRoot, Vector3.zero, TargetRoot.Position, false)
                end)
            end
            RunService.Heartbeat:Wait()
        end

        if selectedPlayer and selectedPlayer.Character then
            if selectedPlayer.Character:FindFirstChild("Humanoid") then
                local hum = selectedPlayer.Character.Humanoid
                pcall(function()
                    hum.PlatformStand = false
                    hum.Sit = false
                    hum.AutoRotate = true
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end
        end

        pcall(function()
            if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                DestroyGrabLine:FireServer(selectedPlayer.Character.HumanoidRootPart)
            end
        end)

        savedPosition = nil
        Toggles.BlobmanKickToggle:SetValue(false)
    end)
end

TargetGroup:AddToggle("BlobmanKickToggle", {
    Text = "Loop Kick",
    Default = false,
    Callback = function(State)
        if State then runBlobmanKick() else kickLoop = false end
    end
})

Players.PlayerAdded:Connect(function()
    Options.KickPlayerDropdown:SetValues(getPlayerList())
end)
Players.PlayerRemoving:Connect(function()
    Options.KickPlayerDropdown:SetValues(getPlayerList())
end)

--// VISUAL TAB
local VisualGroup = Tabs.Visual:AddLeftGroupbox("Visual Effects", "eye")

local HEADLESS_MESH_ID = "rbxassetid://1095708"
local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_COLOR = Color3.fromRGB(50, 50, 50)

local originalData = {}

local function saveHeadData(character, head)
    if not originalData[character] then originalData[character] = {} end
    originalData[character].headTransparency = head.Transparency
    originalData[character].headCanCollide = head.CanCollide
    local face = head:FindFirstChild("face")
    if face then originalData[character].faceClone = face:Clone() end
end

local function saveLegData(character, leg)
    if not originalData[character] then originalData[character] = {} end
    originalData[character].legColor = leg.Color
end

local function applyHeadless(character)
    local head = character:FindFirstChild("Head")
    if not head then return end
    saveHeadData(character, head)
    head.Transparency = 1
    head.CanCollide = false
    local face = head:FindFirstChild("face")
    if face then face:Destroy() end
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = HEADLESS_MESH_ID
    mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
    mesh.Name = "HeadlessMesh"
    mesh.Parent = head
    local conn1 = head:GetPropertyChangedSignal("Transparency"):Connect(function()
        if head.Transparency ~= 1 then head.Transparency = 1 end
    end)
    local conn2 = head.ChildAdded:Connect(function(child)
        if child.Name == "face" and child:IsA("Decal") then child:Destroy() end
    end)
    if not originalData[character] then originalData[character] = {} end
    originalData[character].connections = originalData[character].connections or {}
    table.insert(originalData[character].connections, conn1)
    table.insert(originalData[character].connections, conn2)
end

local function applyKorbloxLeg(character)
    local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
    if not rightLeg then return end
    saveLegData(character, rightLeg)
    for _, child in ipairs(rightLeg:GetChildren()) do
        if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then child:Destroy() end
    end
    rightLeg.Color = KORBLOX_COLOR
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = KORBLOX_MESH_ID
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Name = "KorbloxMesh"
    mesh.Parent = rightLeg
    local conn = rightLeg:GetPropertyChangedSignal("Color"):Connect(function()
        if rightLeg.Color ~= KORBLOX_COLOR then rightLeg.Color = KORBLOX_COLOR end
    end)
    if not originalData[character] then originalData[character] = {} end
    originalData[character].connections = originalData[character].connections or {}
    table.insert(originalData[character].connections, conn)
end

local function restoreHead(character)
    local head = character:FindFirstChild("Head")
    if not head then return end
    local data = originalData[character]
    if not data then return end
    for _, child in ipairs(head:GetChildren()) do
        if child.Name == "HeadlessMesh" or (child:IsA("SpecialMesh") and child.MeshId == HEADLESS_MESH_ID) then child:Destroy() end
    end
    head.Transparency = data.headTransparency or 0
    head.CanCollide = data.headCanCollide ~= false
    if data.faceClone then
        local existingFace = head:FindFirstChild("face")
        if not existingFace then data.faceClone:Clone().Parent = head end
    end
end

local function restoreLeg(character)
    local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
    if not rightLeg then return end
    local data = originalData[character]
    if not data then return end
    for _, child in ipairs(rightLeg:GetChildren()) do
        if child.Name == "KorbloxMesh" or (child:IsA("SpecialMesh") and child.MeshId == KORBLOX_MESH_ID) then child:Destroy() end
    end
    rightLeg.Color = data.legColor or Color3.fromRGB(255, 255, 255)
end

local function applykxH(character)
    applyHeadless(character)
    applyKorbloxLeg(character)
end

local function restoreCharacter(character)
    local data = originalData[character]
    if data and data.connections then
        for _, conn in ipairs(data.connections) do conn:Disconnect() end
    end
    restoreHead(character)
    restoreLeg(character)
    originalData[character] = nil
end

local function restoreAllCharacters()
    if LocalPlayer.Character then restoreCharacter(LocalPlayer.Character) end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then restoreCharacter(player.Character) end
    end
    originalData = {}
end

local kxHEnabled = false
local kxHConnections = {}

VisualGroup:AddToggle("kxHToggle", {
    Text = "kxH",
    Default = false,
    Callback = function(State)
        kxHEnabled = State
        if State then
            if LocalPlayer.Character then applykxH(LocalPlayer.Character) end
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then applykxH(player.Character) end
            end
            local localConn = LocalPlayer.CharacterAdded:Connect(function(char)
                if kxHEnabled then applykxH(char) end
            end)
            table.insert(kxHConnections, localConn)
            for _, player in ipairs(Players:GetPlayers()) do
                local conn = player.CharacterAdded:Connect(function(char)
                    if kxHEnabled then applykxH(char) end
                end)
                table.insert(kxHConnections, conn)
            end
            local playerAddedConn = Players.PlayerAdded:Connect(function(player)
                local charConn = player.CharacterAdded:Connect(function(char)
                    if kxHEnabled then applykxH(char) end
                end)
                table.insert(kxHConnections, charConn)
                if player.Character then applykxH(player.Character) end
            end)
            table.insert(kxHConnections, playerAddedConn)
        else
            for _, conn in ipairs(kxHConnections) do conn:Disconnect() end
            kxHConnections = {}
            restoreAllCharacters()
        end
    end
})

--// PCLD Visualizer
local pclVisualizerEnabled = false
local pclVisualizerConnection = nil
local pclTransparency = 0.6
local pclColor = Color3.fromRGB(255, 0, 0)

local function updatePCLDAppearance()
    pcall(function()
        for i, v in pairs(workspace:GetChildren()) do
            if v.Name == "PlayerCharacterLocationDetector" or v.Name == "PlayerCharacterDetectLocation" or v.Name:find("PCLD") then
                if v:IsA("BasePart") then
                    v.Transparency = pclTransparency
                    v.Color = pclColor
                end
            end
        end
    end)
end

local function enablePCLDVisualizer()
    if pclVisualizerConnection then return end
    updatePCLDAppearance()
    pclVisualizerConnection = RunService.Heartbeat:Connect(function()
        updatePCLDAppearance()
    end)
end

local function disablePCLDVisualizer()
    if pclVisualizerConnection then
        pclVisualizerConnection:Disconnect()
        pclVisualizerConnection = nil
    end
    pcall(function()
        for i, v in pairs(workspace:GetChildren()) do
            if v.Name == "PlayerCharacterLocationDetector" or v.Name == "PlayerCharacterDetectLocation" or v.Name:find("PCLD") then
                if v:IsA("BasePart") then
                    v.Transparency = 1
                end
            end
        end
    end)
end

VisualGroup:AddToggle("PCLDVisualizerToggle", {
    Text = "Show PCLD",
    Default = false,
    Callback = function(State)
        pclVisualizerEnabled = State
        if State then
            enablePCLDVisualizer()
        else
            disablePCLDVisualizer()
        end
    end
})

VisualGroup:AddSlider("PCLDTransparency", {
    Text = "PCLD Transparency",
    Default = 0.6,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(Value)
        pclTransparency = Value
        if pclVisualizerEnabled then
            updatePCLDAppearance()
        end
    end
})

VisualGroup:AddDropdown("PCLDColorDropdown", {
    Values = { "Red", "Green", "Blue", "Yellow", "Purple", "Cyan", "White", "Orange", "Pink" },
    Default = "Red",
    Text = "PCLD Color",
    Callback = function(Value)
        local colors = {
            ["Red"] = Color3.fromRGB(255, 0, 0),
            ["Green"] = Color3.fromRGB(0, 255, 0),
            ["Blue"] = Color3.fromRGB(0, 0, 255),
            ["Yellow"] = Color3.fromRGB(255, 255, 0),
            ["Purple"] = Color3.fromRGB(138, 43, 226),
            ["Cyan"] = Color3.fromRGB(0, 255, 255),
            ["White"] = Color3.fromRGB(255, 255, 255),
            ["Orange"] = Color3.fromRGB(255, 165, 0),
            ["Pink"] = Color3.fromRGB(255, 105, 180),
        }
        pclColor = colors[Value] or Color3.fromRGB(255, 0, 0)
        if pclVisualizerEnabled then
            updatePCLDAppearance()
        end
    end
})

--// Startup Sound
local function playStartupSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://452267918"
        sound.Volume = 5
        sound.Parent = workspace
        sound:Play()
        
        sound.Ended:Connect(function()
            sound:Destroy()
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
