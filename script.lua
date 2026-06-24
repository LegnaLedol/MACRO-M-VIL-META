--[[
    Legna Hub - Blox Fruits Mobile Cam-Lock Aimbot
    Features: 100% Invisible Top-Left Button Touch Activation, Predictive Targeting
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

-- UI Notification (Legna Hub Alert)
local function ShowNotification(message, color)
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not PlayerGui then return end

    -- Remove previous notifications if they exist to avoid stacking
    local OldGui = PlayerGui:FindFirstChild("LegnaNotification")
    if OldGui then OldGui:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LegnaNotification"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 250, 0, 50)
    Frame.Position = UDim2.new(0.5, -125, -0.1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Frame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Text = message
    TextLabel.TextColor3 = color or Color3.fromRGB(0, 255, 150)
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = Frame

    Frame:TweenPosition(UDim2.new(0.5, -125, 0.05, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
    
    task.spawn(function()
        task.wait(3)
        Frame:TweenPosition(UDim2.new(0.5, -125, -0.1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.5, true)
        task.wait(0.5)
        ScreenGui:Destroy()
    end)
end

-- Helper: Get Closest Player
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

-- Main Tracking Logic
local function StartTracking()
    if HeartbeatConnection then return end

    HeartbeatConnection = RunService.RenderStepped:Connect(function()
        local MyChar = LocalPlayer.Character
        local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
        if not MyRoot then return end

        local Target = GetClosestPlayer()
        if Target then
            -- 1. Velocity Prediction (0.05)
            local TargetVelocity = Target.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
            local PredictedPosition = Target.Position + (TargetVelocity * 0.05)

            -- 2. Calculate Direction and Dot Product
            local TargetDirection = (PredictedPosition - MyRoot.Position).Unit
            local CharacterLook = MyRoot.CFrame.LookVector
            local DotProduct = CharacterLook:Dot(TargetDirection)

            -- 3. Calculate Target Look CFrame
            local TargetCFrame = CFrame.lookAt(MyRoot.Position, Vector3.new(PredictedPosition.X, MyRoot.Position.Y, PredictedPosition.Z))

            -- 4. Apply Humanized Smoothness (Lerp 0.45) if target is behind
            if DotProduct < -0.2 then
                MyRoot.CFrame = MyRoot.CFrame:Lerp(TargetCFrame, 0.45)
            else
                MyRoot.CFrame = TargetCFrame
            end

            -- 5. Force Camera Lock
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

-- Create 100% Invisible Trigger Button
local function CreateInvisibleButton()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not PlayerGui then return end

    local InvisibleGui = Instance.new("ScreenGui")
    InvisibleGui.Name = "LegnaInvisibleTrigger"
    InvisibleGui.ResetOnSpawn = false
    InvisibleGui.Parent = PlayerGui

    local HitboxButton = Instance.new("TextButton")
    -- Placed at the top left, right to the left of the Roblox logo space
    HitboxButton.Size = UDim2.new(0, 60, 0, 60)
    HitboxButton.Position = UDim2.new(0, 5, 0, 5) 
    HitboxButton.BackgroundTransparency = 1 -- 100% Invisible
    HitboxButton.Text = "" -- No text
    HitboxButton.Parent = InvisibleGui

    HitboxButton.Activated:Connect(function()
        IsAimbotActive = not IsAimbotActive
        if IsAimbotActive then
            StartTracking()
            ShowNotification("Cam-Lock: ON", Color3.fromRGB(0, 255, 100))
        else
            StopTracking()
            ShowNotification("Cam-Lock: OFF", Color3.fromRGB(255, 50, 50))
        end
    end)
end

-- Initialization
task.spawn(function()
    ShowNotification("Legna Hub Loaded Successfully!", Color3.fromRGB(0, 255, 150))
end)
task.spawn(CreateInvisibleButton)
