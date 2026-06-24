local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- CONFIGURACIÓN ESTRICTA DE TUS SLOTS (1: Sanguíneo | 2: Portal | 3: TTK)
local SLOTS = { Sanguine = 1, Portal = 2, TTK = 3 }

-- ESTADOS DEL MENÚ
local aimPlayers = true
local aimNPCs = false
local skillAimActive = true -- Silent Aim Inteligente

local objetivoActual = nil
local camera = workspace.CurrentCamera

-- Función para equipar herramientas de manera forzada y rápida en móvil
local function equiparSlot(slotNumber)
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character
    if not character then return end
    
    local currentTool = character:FindFirstChildOfClass("Tool")
    if currentTool then currentTool.Parent = backpack end
    
    local tools = backpack:GetChildren()
    if tools[slotNumber] then 
        tools[slotNumber].Parent = character 
    end
end

-- FUNCIÓN DE BÚSQUEDA ADAPTATIVA: Detecta según el modo encendido
local function obtenerObjetivo()
    local personajeLocal = player.Character
    if not personajeLocal or not personajeLocal:FindFirstChild("HumanoidRootPart") then return nil end
    local menorDistancia = math.huge
    local objetivo = nil
    
    -- Si PVP está ON, busca jugadores primero
    if aimPlayers then
        for _, otroPlayer in ipairs(game.Players:GetPlayers()) do
            if otroPlayer ~= player and otroPlayer.Character and otroPlayer.Character:FindFirstChild("HumanoidRootPart") and otroPlayer.Character:FindFirstChildOfClass("Humanoid") then
                if otroPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local distancia = (personajeLocal.HumanoidRootPart.Position - otroPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distancia < menorDistancia and distancia < 130 then
                        menorDistancia = distancia
                        objetivo = otroPlayer.Character.HumanoidRootPart
                    end
                end
            end
        end
    end
    
    -- Si NPC está ON (y no encontró jugador prioritario), busca el NPC más cercano
    if aimNPCs and not objetivo then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent and v.Parent:FindFirstChild("HumanoidRootPart") and v.Parent ~= personajeLocal then
                if not game.Players:GetPlayerFromCharacter(v.Parent) and v.Health > 0 then
                    local distancia = (personajeLocal.HumanoidRootPart.Position - v.Parent.HumanoidRootPart.Position).Magnitude
                    if distancia < menorDistancia and distancia < 130 then
                        menorDistancia = distancia
                        objetivo = v.Parent.HumanoidRootPart
                    end
                end
            end
        end
    end
    return objetivo
end

-- CREACIÓN DE LA INTERFAZ GRÁFICA (GUI)
local gui = Instance.new("ScreenGui")
gui.Name = "L_Combo_SilentAim_Hub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local buttonCombo = Instance.new("TextButton")
buttonCombo.Size = UDim2.new(0, 55, 0, 55)
buttonCombo.Position = UDim2.new(0.75, 0, 0.5, 0)
buttonCombo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
buttonCombo.Text = "L"
buttonCombo.TextScaled = true
buttonCombo.Font = Enum.Font.GothamBlack
buttonCombo.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonCombo.Active = true
buttonCombo.Draggable = true
buttonCombo.Parent = gui

local cornerCombo = Instance.new("UICorner")
cornerCombo.CornerRadius = UDim.new(1, 0)
cornerCombo.Parent = buttonCombo

local buttonPVP = Instance.new("TextButton")
buttonPVP.Size = UDim2.new(0, 65, 0, 28)
buttonPVP.Position = UDim2.new(0.75, 65, 0, 48)
buttonPVP.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
buttonPVP.Text = "PVP: ON"
buttonPVP.TextSize = 11
buttonPVP.Font = Enum.Font.GothamBold
buttonPVP.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonPVP.Active = true
buttonPVP.Draggable = true
buttonPVP.Parent = gui

local cornerPVP = Instance.new("UICorner")
cornerPVP.CornerRadius = UDim.new(0, 6)
cornerPVP.Parent = buttonPVP

local buttonNPC = Instance.new("TextButton")
buttonNPC.Size = UDim2.new(0, 65, 0, 28)
buttonNPC.Position = UDim2.new(0.75, 65, 0, 82)
buttonNPC.BackgroundColor3 = Color3.fromRGB(178, 34, 34)
buttonNPC.Text = "NPC: OFF"
buttonNPC.TextSize = 11
buttonNPC.Font = Enum.Font.GothamBold
buttonNPC.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonNPC.Active = true
buttonNPC.Draggable = true
buttonNPC.Parent = gui

local cornerNPC = Instance.new("UICorner")
cornerNPC.CornerRadius = UDim.new(0, 6)
cornerNPC.Parent = buttonNPC

local buttonAIM = Instance.new("TextButton")
buttonAIM.Size = UDim2.new(0, 65, 0, 28)
buttonAIM.Position = UDim2.new(0.75, 65, 0, 116)
buttonAIM.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
buttonAIM.Text = "SAIM: ON"
buttonAIM.TextSize = 11
buttonAIM.Font = Enum.Font.GothamBold
buttonAIM.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonAIM.Active = true
buttonAIM.Draggable = true
buttonAIM.Parent = gui

local cornerAIM = Instance.new("UICorner")
cornerAIM.CornerRadius = UDim.new(0, 6)
cornerAIM.Parent = buttonAIM

local rgbStroke = Instance.new("UIStroke")
rgbStroke.Thickness = 2
rgbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rgbStroke.Parent = buttonAIM

coroutine.wrap(function()
    while true do
        for hue = 0, 1, 0.01 do
            rgbStroke.Color = Color3.fromHSV(hue, 1, 1)
            task.wait(0.03)
        end
    end
end)()
local function actualizarBotonPVP()
    buttonPVP.BackgroundColor3 = aimPlayers and Color3.fromRGB(34, 139, 34) or Color3.fromRGB(178, 34, 34)
    buttonPVP.Text = aimPlayers and "PVP: ON" or "PVP: OFF"
end

local function actualizarBotonNPC()
    buttonNPC.BackgroundColor3 = aimNPCs and Color3.fromRGB(34, 139, 34) or Color3.fromRGB(178, 34, 34)
    buttonNPC.Text = aimNPCs and "NPC: ON" or "NPC: OFF"
end

local function actualizarBotonAIM()
    buttonAIM.BackgroundColor3 = skillAimActive and Color3.fromRGB(34, 139, 34) or Color3.fromRGB(178, 34, 34)
    buttonAIM.Text = skillAimActive and "SAIM: ON" or "SAIM: OFF"
end

buttonPVP.TouchTap:Connect(function() aimPlayers = not aimPlayers; actualizarBotonPVP() end)
buttonNPC.TouchTap:Connect(function() aimNPCs = not aimNPCs; actualizarBotonNPC() end)
buttonAIM.TouchTap:Connect(function() skillAimActive = not skillAimActive; actualizarBotonAIM() end)

-- Simulador virtual de pulsaciones
local function pressKey(keyName, holdTime)
    holdTime = holdTime or 0.05
    local success, VIM = pcall(function() return game:GetService("VirtualInputManager") end)
    if success and VIM then
        local keyCode = Enum.KeyCode[keyName]
        VIM:SendKeyEvent(true, keyCode, false, game)
        task.wait(holdTime)
        VIM:SendKeyEvent(false, keyCode, false, game)
    end
end

local function waitms(ms) task.wait(ms / 1000) end

-- Redirección Silent Aim en milisegundos para conectar Skills perfectamente
local function dirigirAtaque(objetivo)
    if objetivo and skillAimActive then
        camera.CFrame = CFrame.new(camera.CFrame.Position, objetivo.Position)
        task.wait(0.02) -- Breve retraso interno para registrar la dirección del ataque
    end
end

-- TU COMBO ORIGINAL (Portal Z -> TTK X -> Sanguine Z -> Sanguine C -> TTK Z -> Sanguine X)
local comboEjecutandose = false
local function Combo()
    if comboEjecutandose then return end
    comboEjecutandose = true

    -- Detecta dinámicamente si el Silent Aim va a NPC o a Jugador según tus botones
    objetivoActual = obtenerObjetivo()

    -- 1. Equipa Portal (Slot 2) y usa Z
    equiparSlot(SLOTS.Portal)
    dirigirAtaque(objetivoActual)
    waitms(50)
    pressKey("Z", 0.08) 
    waitms(900)

    -- Ángulo hacia abajo por defecto si no hay objetivo cerca
    if not objetivoActual then
        camera.CameraType = Enum.CameraType.Scriptable
        local x, y, z = camera.CFrame:ToEulerAnglesYXZ()
        camera.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.fromEulerAnglesYXZ(x + math.rad(-40), y, z)
        task.wait(0.02)
        camera.CameraType = Enum.CameraType.Custom
    end
    waitms(150)

    -- 2. Equipa TTK (Slot 3) y usa X
    equiparSlot(SLOTS.TTK)
    dirigirAtaque(objetivoActual)
    waitms(50)
    pressKey("X", 0.08)
    waitms(250)

    -- 3. Equipa Sanguíneo (Slot 1) y usa Z (Levanta al enemigo)
    equiparSlot(SLOTS.Sanguine)
    dirigirAtaque(objetivoActual)
    waitms(50)
    pressKey("Z", 0.08)
    waitms(300)

    -- Ángulo hacia arriba por defecto si no hay objetivo cerca
    if not objetivoActual then
        camera.CameraType = Enum.CameraType.Scriptable
        local x, y, z = camera.CFrame:ToEulerAnglesYXZ()
        camera.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.fromEulerAnglesYXZ(x + math.rad(45), y, z)
        task.wait(0.02)
        camera.CameraType = Enum.CameraType.Custom
    end
    waitms(150)

    -- 4. Usa C de Sanguíneo (Ya está equipado)
    dirigirAtaque(objetivoActual)
    pressKey("C", 0.08)
    waitms(850)

    -- 5. Equipa TTK (Slot 3) y usa Z
    equiparSlot(SLOTS.TTK)
    dirigirAtaque(objetivoActual)
    waitms(50)
    pressKey("Z", 0.08)
    waitms(400) 

    -- 6. Regresa a Sanguíneo (Slot 1) y usa X para finalizar
    equiparSlot(SLOTS.Sanguine)
    dirigirAtaque(objetivoActual)
    waitms(50)
    pressKey("X", 0.08)
    
    comboEjecutandose = false
end

-- Ejecutor táctil con animación para el botón de combo "L"
buttonCombo.TouchTap:Connect(function()
    local normalSize = buttonCombo.Size
    local pressedSize = UDim2.new(0, 47, 0, 47)
    local shrink = TweenService:Create(buttonCombo, TweenInfo.new(0.08), {Size = pressedSize})
    local expand = TweenService:Create(buttonCombo, TweenInfo.new(0.08), {Size = normalSize})
    shrink:Play()
    shrink.Completed:Wait()
    expand:Play()
    Combo()
end)
