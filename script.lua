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
local player = game.Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RGB_L_Button"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- BOTÓN
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 55, 0, 55)
button.Position = UDim2.new(0.85, 0, 0.5, 0)
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button.Text = "L"
button.TextScaled = true
button.Font = Enum.Font.GothamBlack
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = gui

-- redondo estilo HUD
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

-- borde glow decorativo
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Parent = button

-- 🌈 RGB ANIMACIÓN
task.spawn(function()
    while true do
        for i = 0, 1, 0.01 do
            button.BackgroundColor3 = Color3.fromHSV(i, 1, 1)
            stroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- 📌 CLICK (SIN COOLDOWN, SIN BLOQUEOS)
button.MouseButton1Click:Connect(function()
    Combo() -- tu función aquí
end)
