local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "L_Button_Mobile"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- BOTÓN
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 50, 0, 50)
button.Position = UDim2.new(0.8, 0, 0.5, 0)
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
button.Text = "L"
button.TextScaled = true
button.Font = Enum.Font.GothamBlack
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Parent = gui

-- REDONDO
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

-- 📌 ANIMACIÓN CLICK
local normalSize = button.Size
local pressedSize = UDim2.new(0, 44, 0, 44)

local function animatePress()
    local shrink = TweenService:Create(button, TweenInfo.new(0.08), {Size = pressedSize})
    local expand = TweenService:Create(button, TweenInfo.new(0.08), {Size = normalSize})

    shrink:Play()
    shrink.Completed:Wait()
    expand:Play()
end

-- 📌 DRAG (TOUCH FRIENDLY)
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    button.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- 📌 CLICK
button.MouseButton1Click:Connect(function()
    animatePress()
    
    -- 👇 TU FUNCIÓN AQUÍ
    -- Combo()
end)
local player = game.Players.LocalPlayer

-- =========================
-- 🔧 FUNCIONES DEL COMBO
-- =========================
local function waitms(ms)
    task.wait(ms / 1000)
end

local function press(key, hold)
    keyDown(key)
    task.wait(hold or 0.05)
    keyUp(key)
end

local function Combo()

    -- 1. PORTAL Z
    press(0x5A, 0.08)
    waitms(900)

    -- mirar abajo
    mousemoverel(0, 20)
    waitms(150)

    -- 2. TTK X
    press(0x58, 0.08)
    waitms(250)

    -- 3. SANGUINE X
    press(0x58, 0.08)
    waitms(300)

    -- 4. SANGUINE Z
    press(0x5A, 0.08)
    waitms(400)

    -- mirar arriba
    mousemoverel(0, -25)
    waitms(150)

    -- 5. SANGUINE C
    press(0x43, 0.08)
    waitms(850)

    -- 6. TTK Z
    press(0x5A, 0.08)
end
