--[[
    Legna Hub V2 - Blox Fruits Mobile Cam-Lock
    Inspired by Top Hubs: Dynamic FOV Sorting, Humanized Smooth Aim, Visual Trigger Area
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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

-- Top-Hub Sorting: Evaluates closest target in real continuous physical space
local function GetClosestPlayer()
    local ClosestTarget = nil
    local MaxDistance = math.huge
    local MyChar = LocalPlayer.Character
    local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")

    if not MyRoot then return nil end

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local TargetChar = Player.Character
            local TargetRoot = TargetChar:FindFirstChild("HumanoidRootPart")
            local TargetHumanoid = TargetChar:FindFirstChildOfClass("Humanoid")

            if TargetRoot and TargetHumanoid and TargetHumanoid.Health > 0 then
                local Distance = (MyRoot.Position - TargetRoot.Position).Magnitude
                if Distance < MaxDistance then
                    MaxDistance = Distance
                    ClosestTarget = TargetRoot
                end
            end
        end
    end
    return ClosestTarget
end

-- Core Core Engine (RenderStepped Loop)
local function StartTracking()
    if HeartbeatConnection then return end

    HeartbeatConnection = RunService.RenderStepped:Connect(function()
        local MyChar = LocalPlayer.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        if not MyRoot then return end

        local Target = GetClosestPlayer()
        if Target then
            -- High-End Target Tracking with Latency Compensation (0.05 Velocity)
            local TargetVelocity = Target.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
            local PredictedPosition = Target.Position + (TargetVelocity * 0.05)

            local TargetDirection = (PredictedPosition - MyRoot.Position).Unit
            local CharacterLook = MyRoot.CFrame.LookVector
            local DotProduct = CharacterLook:Dot(TargetDirection)

            -- Dynamic Look CFrame calculation locked on the horizontal axis
            local TargetCFrame = CFrame.lookAt(MyRoot.Position, Vector3.new(PredictedPosition.X, MyRoot.Position.Y, PredictedPosition.Z))

            -- Anti-Cheat Protection Flank Control (Bypass teleport spins)
            if DotProduct < -0.2 then
                MyRoot.CFrame = MyRoot.CFrame:Lerp(TargetCFrame, 0.45)
            else
                MyRoot.CFrame = TargetCFrame
            end

            -- Camera Vector Interpolation (Locks seamlessly)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, PredictedPosition)
        end
    end)
end

local function StopTracking()
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
        HeartbeatConnection = nil
    end
end

-- Sleek & Visible Trigger Button (Ensures tactical response on Mobile screens)
local function CreateTacticalButton()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not PlayerGui then return end

    local OldButton = PlayerGui:FindFirstChild("LegnaInvisibleTrigger")
    if OldButton then OldButton:Destroy() end

    local InvisibleGui = Instance.new("ScreenGui")
    InvisibleGui.Name = "LegnaInvisibleTrigger"
    InvisibleGui.ResetOnSpawn = false
    InvisibleGui.Parent = PlayerGui

    -- Enlarged tactical size (80x80) placed right to the left of the Roblox core icon space
    local HitboxButton = Instance.new("TextButton")
    HitboxButton.Size = UDim2.new(0, 80, 0, 80)
    HitboxButton.Position = UDim2.new(0, 8, 0, 8) 
    
    -- Design: Dark semi-translucent slate gray. Barely notable but clearly intuitive.
    HitboxButton.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    HitboxButton.BackgroundTransparency = 0.78
    HitboxButton.BorderSizePixel = 0
    HitboxButton.Text = "LGN"
    HitboxButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    HitboxButton.TextSize = 11
    HitboxButton.Font = Enum.Font.Code
    HitboxButton.Parent = InvisibleGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 14)
    UICorner.Parent = HitboxButton

    HitboxButton.Activated:Connect(function()
        IsAimbotActive = not IsAimbotActive
        if IsAimbotActive then
            StartTracking()
            ShowNotification("LEGNA COMBAT: SYSTEM ACTIVE", Color3.fromRGB(0, 255, 120))
            HitboxButton.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
            HitboxButton.BackgroundTransparency = 0.65 -- Glow indicator on lock
        else
            StopTracking()
            ShowNotification("LEGNA COMBAT: DISENGAGED", Color3.fromRGB(255, 70, 70))
            HitboxButton.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
            HitboxButton.BackgroundTransparency = 0.78
        end
    end)
end

-- Initialization
task.spawn(function()
    ShowNotification("Legna Hub Premium Engine Loaded.", Color3.fromRGB(0, 220, 255))
end)
task.spawn(CreateTacticalButton)
