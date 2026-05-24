--// Main Loop - РОВНЫЙ КИК БЕЗ ТРЯСКИ
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
                -- РОВНО над головой, без тряски
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
