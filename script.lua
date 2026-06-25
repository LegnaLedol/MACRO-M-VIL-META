--// LEGNA HUB v2.0 - PARTE 1 (ADONIS ANTI-CHEAT BYPASS ORIGINAL)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

loadstring(game:HttpGet("https://raw.githubusercontent.com/shakar60/scripts/refs/heads/main/ac%20bypass", true))()

--[[
loadstring(game:HttpGet("https://githubusercontent.com", true))()
loadstring(game:HttpGet("https://githubusercontent.com"))()
]]

local plr = game:GetService("Players").LocalPlayer
local cclosure = syn_newcclosure or newcclosure or nil

if not cclosure or not hookmetamethod then
    plr:Kick("\n\nYour exploit doesn't support hookmetamethod\n")
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", cclosure(function(self, ...)
    local NamecallMethod = getnamecallmethod()
    local args = { ... }
    if (NamecallMethod == "Kick" or NamecallMethod == "kick") and not checkcaller() then
        if self ~= plr then
            return oldNamecall(self, ...)
        end
        return
    end
    return oldNamecall(self, ...)
end))

for wendigo, iscool in pairs(getgc(true)) do
    if pcall(function() return rawget(iscool, "indexInstance") end)
    and type(rawget(iscool, "indexInstance")) == "table"
    and rawget(iscool, "indexInstance") == "Kick" then
        iscool.tvk = {"kick", function()
            return game.Workspace:WaitForChild("")
        end}
    end
end

local getinfo = getinfo or debug.getinfo
local DEBUG = false
local Hooked = {}

local Detected, Kill

setthreadidentity(2)

for i, v in pairs(getgc(true)) do
    if typeof(v) == "table" then
        local DetectFunc = rawget(v, "Detected")
        local KillFunc = rawget(v, "Kill")
        
        if typeof(DetectFunc) == "function" and not Detected then
            Detected = DetectFunc
            
            local old; old = hookfunction(Detected, function(Action, Info, NoCrash)
                if Action ~= "_" then
                    return old("_", Info, NoCrash)
                end
                return old(Action, Info, NoCrash)
            end)
        end
    end
end
--// LEGNA HUB v2.0 - PARTE 2 (INTERFAZ Y AIMBOT ORIGINAL)
if player.PlayerGui:FindFirstChild("LEGNA_HUB_V2") then
    player.PlayerGui.LEGNA_HUB_V2:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "LEGNA_HUB_V2"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 480)
main.Position = UDim2.new(0.5, -160, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
title.Text = "LEGNA HUB v2.0"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- Draggable + Minimize
local dragging, dragStart, startPos
title.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local minBtn = Instance.new("TextButton", title)
minBtn.Size = UDim2.new(0, 40, 0, 40)
minBtn.Position = UDim2.new(1, -45, 0, 5)
minBtn.Text = "–"
minBtn.BackgroundColor3 = Color3.fromRGB(0,180,0)
minBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1,0)
minBtn.MouseButton1Click:Connect(function() main.Visible = false end)

-- Variables
local aimbotEnabled = false
local autoClosest = true
local selectedTarget = nil
local fovRadius = 150

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 100, 0)
fovCircle.Transparency = 0.7
fovCircle.Filled = false
fovCircle.Radius = fovRadius
fovCircle.Visible = true

-- UI Buttons
local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.9,0,0,55)
toggleBtn.Position = UDim2.new(0.05,0,0,60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
toggleBtn.Text = "AIMBOT [OFF]"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 20
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,10)

local closestBtn = Instance.new("TextButton", main)
closestBtn.Size = UDim2.new(0.9,0,0,50)
closestBtn.Position = UDim2.new(0.05,0,0,125)
closestBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
closestBtn.Text = "Auto Closest [ON]"
closestBtn.TextColor3 = Color3.new(1,1,1)
closestBtn.Font = Enum.Font.Gotham
closestBtn.TextSize = 18
Instance.new("UICorner", closestBtn).CornerRadius = UDim.new(0,10)

local selectBtn = Instance.new("TextButton", main)
selectBtn.Size = UDim2.new(0.9,0,0,50)
selectBtn.Position = UDim2.new(0.05,0,0,185)
selectBtn.BackgroundColor3 = Color3.fromRGB(45,45,55)
selectBtn.Text = "Select Player"
selectBtn.TextColor3 = Color3.new(1,1,1)
selectBtn.Font = Enum.Font.Gotham
selectBtn.TextSize = 18
Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0,10)

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(0.9,0,0,40)
status.Position = UDim2.new(0.05,0,0,245)
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(0,255,120)
status.Font = Enum.Font.Gotham
status.TextSize = 16
status.BackgroundTransparency = 1

-- Player List (for manual select)
local listFrame = Instance.new("ScrollingFrame", main)
listFrame.Size = UDim2.new(0.9,0,0,160)
listFrame.Position = UDim2.new(0.05,0,0,295)
listFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
listFrame.ScrollBarThickness = 6
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,10)
listFrame.Visible = false

local function refreshList()
    for _,v in ipairs(listFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, plrItem in ipairs(Players:GetPlayers()) do
        if plrItem ~= player and plrItem.Character and plrItem.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - plrItem.Character.HumanoidRootPart.Position).Magnitude
            if dist <= 500 then
                local btn = Instance.new("TextButton", listFrame)
                btn.Size = UDim2.new(1,-10,0,38)
                btn.BackgroundColor3 = Color3.fromRGB(50,50,60)
                btn.Text = plrItem.Name .. " ("..math.floor(dist).."m)"
                btn.TextColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
                btn.MouseButton1Click:Connect(function()
                    selectedTarget = plrItem
                    status.Text = "Locked: "..plrItem.Name
                    listFrame.Visible = false
                end)
            end
        end
    end
end

-- Button Logic
toggleBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    toggleBtn.Text = "AIMBOT ["..(aimbotEnabled and "ON ✅" or "OFF").."]"
    toggleBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0,200,80) or Color3.fromRGB(45,45,55)
end)

closestBtn.MouseButton1Click:Connect(function()
    autoClosest = not autoClosest
    closestBtn.Text = "Auto Closest ["..(autoClosest and "ON" or "OFF").."]"
    closestBtn.BackgroundColor3 = autoClosest and Color3.fromRGB(0,200,80) or Color3.fromRGB(45,45,55)
end)

selectBtn.MouseButton1Click:Connect(function()
    listFrame.Visible = not listFrame.Visible
    if listFrame.Visible then refreshList() end
end)

-- Main Aimbot Loop with Prediction + Silent Skills
local aimConn
local function startAimbot()
    if aimConn then aimConn:Disconnect() end
    aimConn = RunService.RenderStepped:Connect(function(dt)
        if not aimbotEnabled then return end

        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Auto Closest
        if autoClosest then
            local closest, minDist = nil, math.huge
            for _, plrItem in ipairs(Players:GetPlayers()) do
                if plrItem ~= player and plrItem.Character and plrItem.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (root.Position - plrItem.Character.HumanoidRootPart.Position).Magnitude
                    if dist < minDist and dist <= 500 then
                        minDist = dist
                        closest = plrItem
                    end
                end
            end
            selectedTarget = closest
        end

        if not selectedTarget or not selectedTarget.Character then
            status.Text = "No Target"
            return
        end

        local targetRoot = selectedTarget.Character:FindFirstChild("HumanoidRootPart")
        local targetHead = selectedTarget.Character:FindFirstChild("Head")
        if not targetRoot or not targetHead then return end

        local dist = (root.Position - targetRoot.Position).Magnitude
        if dist > 500 then
            status.Text = "Target too far"
            return
        end

        -- Prediction (lead target)
        local velocity = targetRoot.Velocity
        local predictedPos = targetHead.Position + (velocity * 0.12)  -- prediction strength

        -- Smooth Camera Lock
        local lookAt = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.35)

        -- Silent Skill Activation
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool and dist < 120 then
            tool:Activate()
        end
        -- Auto press skills when locked
        if dist < 80 then
            game:service("VirtualInputManager"):SendKeyEvent(true, "Z", false, game)
            task.wait(0.1)
            game:service("VirtualInputManager"):SendKeyEvent(false, "Z", false, game)
        end

        status.Text = "Aiming: " .. selectedTarget.Name .. " (" .. math.floor(dist) .. "m)"
    end)
end

toggleBtn.MouseButton1Click:Connect(function()
    if aimbotEnabled then startAimbot() else if aimConn then aimConn:Disconnect() end end
end)

-- Update FOV Circle
RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius = fovRadius
    fovCircle.Visible = true
end)

print("✅ LEGNA HUB v2.0 Loaded Successfully")
