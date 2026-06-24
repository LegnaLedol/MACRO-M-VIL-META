--[[
    Legna Hub V9 - Multi-Game Intelligent Silent Aim (Duelos & Blox Fruits)
    Features: PlaceId Match Check, Auto Ally Bypass for Duelos, Silent Bullet Magnet
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local HeartbeatConnection = nil
local IsAimbotActive = false
local CurrentPlaceId = game.PlaceId

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

-- Universal Mortal Target Scan with Game Detection
local function IsValidTarget(player)
    if player == LocalPlayer then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or humanoid.Health <= 0 then 
        return false 
    end
    
    if character:FindFirstChildOfClass("ForceField") then 
        return false 
    end

    -- [CRITICAL FIX] If playing "Duelos" (or any match base game), strictly ignore same team members
    -- Uses a loose check if PlaceId matches common shooter IDs or if team exists and matches
    if player.Team and player.Team == LocalPlayer.Team then
        -- Only filter teams if we are NOT in Blox Fruits (Blox Fruits PlaceId starts with 275 or 444)
        local strId = tostring(CurrentPlaceId)
        if not (string.sub(strId, 1, 3) == "275" or string.sub(strId, 1, 3) == "444") then
            return false -- It's a real teammate in Duelos, IGNORE HIM!
        end
    end

    return true
end

local function GetClosestTarget()
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

-- Hooking Engine: Intercepts Mouse.Hit and Mouse.Target
local function HookMouseData()
    local RawMetatable = getrawmetatable(game)
    setreadonly(RawMetatable, false)
    local OldIndex = RawMetatable.__index

    RawMetatable.__index = newcclosure(function(self, index)
        if IsAimbotActive and self == Mouse then
            local Target = GetClosestTarget()
            if Target then
                local TargetPart = Target.Parent:FindFirstChild("Head") or Target
                if index == "Hit" then
                    return TargetPart.CFrame
                elseif index == "Target" then
                    return TargetPart
                end
            end
        end
        return OldIndex(self, index)
    end)
    setreadonly(RawMetatable, true)
end

-- Camera Rotation Step Engine
local function StartTracking()
    if HeartbeatConnection then return end

    HeartbeatConnection = RunService.RenderStepped:Connect(function()
        local MyChar = LocalPlayer.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        if not MyRoot then return end

        local Target = GetClosestTarget()
        if Target then
            local TargetVelocity = Target.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
            local PredictedPosition = Target.Position + (TargetVelocity * 0.05)

            -- Rotate character base cleanly towards target axis
            MyRoot.CFrame = CFrame.lookAt(MyRoot.Position, Vector3.new(PredictedPosition.X, MyRoot.Position.Y, PredictedPosition.Z))

            -- Head Anchor Matrix
            local CameraDistance = 11
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
            ShowNotification("LEGNA: SMART LOCK SYSTEM ON", Color3.fromRGB(0, 255, 120))
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
HookMouseData()
task.spawn(function()
    ShowNotification("Legna Hub Smart V9 Loaded.", Color3.fromRGB(0, 220, 255))
end)
task.spawn(CreateTacticalButton)
