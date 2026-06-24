--[[
    Legna Hub V7 - Multi-Game Rage Cam-Lock (Blox Fruits & Duelos MM2)
    Features: Multi-Game Target Scan, Non-Floating Head Anchor, Aggressive Target Lock
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HeartbeatConnection = nil
local IsAimbotActive = false

-- UI Notification System
local function ShowNotification(message, color)
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not PlayerGui then return end

    local OldGui = PlayerGui:FindFirstChild("LegnaNotification")
    if OldGui then OldGui:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LegnaNotification"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 240, 0, 45)
    Frame.Position = UDim2.new(0.5, -120, -0.1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Frame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Text = message
    TextLabel.TextColor3 = color or Color3.fromRGB(0, 255, 150)
    TextLabel.TextSize = 13
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = Frame

    Frame:TweenPosition(UDim2.new(0.5, -120, 0.05, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.4, true)
    
    task.spawn(function()
        task.wait(2.5)
        Frame:TweenPosition(UDim2.new(0.5, -120, -0.1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.4, true)
        task.wait(0.4)
        ScreenGui:Destroy()
    end)
end

-- Validates that the target is a valid mortal opponent across different modes
local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    -- 1. Must be physically alive and accessible
    if not humanoid or not rootPart or humanoid.Health <= 0 then 
        return false 
    end
    
    -- 2. Bypass standard global safe spawn forcefields
    if character:FindFirstChildOfClass("ForceField") then 
        return false 
    end
    
    -- 3. Dynamic Multi-Game Team Filter Override
    -- In MM2/Duelos everyone can be targeted or teams change constantly; filters only active if teams are structural
    if player.Team and player.Team == LocalPlayer.Team and #player.Team:GetPlayers() > 1 and game.PlaceId ~= 2753915549 then
        -- Optional: Keeps teams active ONLY if not on standard FFA maps
        return true
    end

    return true
end

-- Universal Absolute Proximity Engine
local function GetClosestVulnerableTarget()
    local ClosestTarget = nil
    local MaxDistance = math.huge
    local MyChar = LocalPlayer.Character
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")

    if not MyRoot then return nil end

    for _, Player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(Player) then
            local TargetRoot = Player.Character.HumanoidRootPart
            local Distance = (MyRoot.Position - TargetRoot.Position).Magnitude
            if Distance < MaxDistance then
                MaxDistance = Distance
                ClosestTarget = TargetRoot
            end
        end
    end
    return ClosestTarget
end

-- Extreme Force Vector Locking Engine
local function StartTracking()
    if HeartbeatConnection then return end

    HeartbeatConnection = RunService.RenderStepped:Connect(function()
        local MyChar = LocalPlayer.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        if not MyRoot then return end

        local Target = GetClosestVulnerableTarget()
        if Target then
            -- High Velocity Prediction Vector (Locks jumpers flawlessly)
            local TargetVelocity = Target.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
            local PredictedPosition = Target.Position + (TargetVelocity * 0.05)

            -- Absolute instant body alignment facing the hit position
            MyRoot.CFrame = CFrame.lookAt(MyRoot.Position, Vector3.new(PredictedPosition.X, MyRoot.Position.Y, PredictedPosition.Z))

            -- Anti-Float Camera Matrix: Constantly realigns directly to your physical head position
            local CameraDistance = 11 -- Ideal field of view length for aiming guns or swords
            local CameraHeight = 3.5
            local DirectionVector = (PredictedPosition - MyRoot.Position).Unit
            
            local TargetCameraCFrame = MyRoot.Position - (DirectionVector * CameraDistance) + Vector3.new(0, CameraHeight, 0)
            Camera.CFrame = CFrame.lookAt(TargetCameraCFrame, PredictedPosition)
        end
    end)
end

local function StopTracking()
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
        HeartbeatConnection = nil
    end
end

-- Micro Position Tactical Button
local function CreateTacticalButton()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not PlayerGui then return end

    local OldButton = PlayerGui:FindFirstChild("LegnaInvisibleTrigger")
    if OldButton then OldButton:Destroy() end

    local InvisibleGui = Instance.new("ScreenGui")
    InvisibleGui.Name = "LegnaInvisibleTrigger"
    InvisibleGui.ResetOnSpawn = false
    InvisibleGui.Parent = PlayerGui

    local HitboxButton = Instance.new("TextButton")
    HitboxButton.Size = UDim2.new(0, 40, 0, 40)
    HitboxButton.Position = UDim2.new(0, 8, 0, 0) 
    
    HitboxButton.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    HitboxButton.BackgroundTransparency = 0.8
    HitboxButton.BorderSizePixel = 0
    HitboxButton.Text = "L"
    HitboxButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    HitboxButton.TextSize = 10
    HitboxButton.Font = Enum.Font.Code
    HitboxButton.Parent = InvisibleGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = HitboxButton

    HitboxButton.Activated:Connect(function()
        IsAimbotActive = not IsAimbotActive
        if IsAimbotActive then
            StartTracking()
            ShowNotification("LEGNA: MULTI-GAME ACTIVE", Color3.fromRGB(0, 255, 120))
            HitboxButton.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
            HitboxButton.BackgroundTransparency = 0.6
        else
            StopTracking()
            ShowNotification("LEGNA: DISENGAGED", Color3.fromRGB(255, 70, 70))
            HitboxButton.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
            HitboxButton.BackgroundTransparency = 0.8
        end
    end)
end

-- Initialization
task.spawn(function()
    ShowNotification("Legna Hub Rage V7 Multi-Game Loaded.", Color3.fromRGB(0, 220, 255))
end)
task.spawn(CreateTacticalButton)
