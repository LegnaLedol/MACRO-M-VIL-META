local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local gui = Instance.new("ScreenGui")
gui.Name = "L_Button_Mobile"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 50, 0, 50)
button.Position = UDim2.new(0.8, 0, 0.5, 0)
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
button.Text = "L"
button.TextScaled = true
button.Font = Enum.Font.GothamBlack
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

local normalSize = button.Size
local pressedSize = UDim2.new(0, 44, 0, 44)

local function animatePress()
    local shrink = TweenService:Create(button, TweenInfo.new(0.08), {Size = pressedSize})
    local expand = TweenService:Create(button, TweenInfo.new(0.08), {Size = normalSize})
    shrink:Play()
    shrink.Completed:Wait()
    expand:Play()
end

-- Sistema de arrastre (Drag) para móvil
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

-- AUTOMATIZACIÓN
local function waitms(ms)
    task.wait(ms / 1000)
end

local function press(keyName, hold)
    local keyCode = Enum.KeyCode[keyName]
    VIM:SendKeyEvent(true, keyCode, false, game)
    task.wait(hold or 0.05)
    VIM:SendKeyEvent(false, keyCode, false, game)
end

local camera = workspace.CurrentCamera
local function moverCamara(gradosVerticales)
    local x, y, z = camera.CFrame:ToEulerAnglesYXZ()
    camera.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.fromEulerAnglesYXZ(x + math.rad(gradosVerticales), y, z)
end

-- COMBO CONFIGURADO CON TUS SLOTS (1: Sanguíneo | 2: Portal | 3: TTK)
local function Combo()
    -- 1. Equipa Portal (Slot 2) y usa Z (Haz los 2 saltos antes de presionar el botón)
    press("Two", 0.05) 
    waitms(50)
    press("Z", 0.08) 
    waitms(900)

    -- 2. Mirar hacia abajo 
    moverCamara(-40) 
    waitms(150)

    -- 3. Equipa TTK (Slot 3) y usa X
    press("Three", 0.05)
    waitms(50)
    press("X", 0.08)
    waitms(250)

    -- 4. Equipa Sanguíneo (Slot 1) y usa Z (Levanta al enemigo)
    press("One", 0.05)
    waitms(50)
    press("Z", 0.08)
    waitms(300)

    -- 5. Mirar hacia arriba
    moverCamara(45)
    waitms(150)

    -- 6. Usa C de Sanguíneo (Ya está equipado)
    press("C", 0.08)
    waitms(850)

    -- 7. Equipa TTK (Slot 3) y usa Z
    press("Three", 0.05)
    waitms(50)
    press("Z", 0.08)
    waitms(400) 

    -- 8. Regresa a Sanguíneo (Slot 1) y usa X para finalizar el combo
    press("One", 0.05)
    waitms(50)
    press("X", 0.08)
end

button.MouseButton1Click:Connect(function()
    animatePress()
    Combo()
end)
