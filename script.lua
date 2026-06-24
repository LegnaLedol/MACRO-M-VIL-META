local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- CONFIGURACIÓN DE SLOTS FIJOS (1: Sanguíneo | 2: Portal | 3: TTK)
local SLOTS = { Sanguine = 1, Portal = 2, TTK = 3 }

-- ESTADOS DE LOS MODOS DE APUNTADO
local aimPlayers = true
local aimNPCs = false
local camLockActive = true

-- Función para equipar herramientas de manera forzada en móvil
local function equiparSlot(slotNumber)
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character
    if not character then return end
    local currentTool = character:FindFirstChildOfClass("Tool")
    if currentTool then currentTool.Parent = backpack end
    local tools = backpack:GetChildren()
    if tools[slotNumber] then tools[slotNumber].Parent = character end
end

-- FUNCIÓN DE BÚSQUEDA AVANZADA CON LOCK SEGURO PARA NPCS Y JUGADORES
local function obtenerObjetivo()
    local personajeLocal = player.Character
    if not personajeLocal or not personajeLocal:FindFirstChild("HumanoidRootPart") then return nil end
    local menorDistancia = math.huge
    local objetivo = nil
    
    if aimPlayers then
        for _, otroPlayer in ipairs(game.Players:GetPlayers()) do
            if otroPlayer ~= player and otroPlayer.Character and otroPlayer.Character:FindFirstChild("HumanoidRootPart") and otroPlayer.Character:FindFirstChildOfClass("Humanoid") then
                if otroPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local distancia = (personajeLocal.HumanoidRootPart.Position - otroPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distancia < menorDistancia and distancia < 150 then
                        menorDistancia = distancia
                        objetivo = otroPlayer.Character.HumanoidRootPart
                    end
                end
            end
        end
    end
    
    if aimNPCs and not objetivo then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent and v.Parent:FindFirstChild("HumanoidRootPart") and v.Parent ~= personajeLocal then
                if not game.Players:GetPlayerFromCharacter(v.Parent) and v.Health > 0 then
                    local distancia = (personajeLocal.HumanoidRootPart.Position - v.Parent.HumanoidRootPart.Position).Magnitude
                    if distancia < menorDistancia and distancia < 150 then
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
gui.Name = "L_Combo_TikTok_Hub"
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

local buttonCAM = Instance.new("TextButton")
buttonCAM.Size = UDim2.new(0, 65, 0, 28)
buttonCAM.Position = UDim2.new(0.75, 65, 0, 116)
buttonCAM.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
buttonCAM.Text = "CAM: ON"
buttonCAM.TextSize = 11
buttonCAM.Font = Enum.Font.GothamBold
buttonCAM.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonCAM.Active = true
buttonCAM.Draggable = true
buttonCAM.Parent = gui

local cornerCAM = Instance.new("UICorner")
cornerCAM.CornerRadius = UDim.new(0, 6)
cornerCAM.Parent = buttonCAM

local rgbStroke = Instance.new("UIStroke")
rgbStroke.Thickness = 2
rgbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rgbStroke.Parent = buttonCAM

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

local function actualizarBotonCAM()
    buttonCAM.BackgroundColor3 = camLockActive and Color3.fromRGB(34, 139, 34) or Color3.fromRGB(178, 34, 34)
    buttonCAM.Text = camLockActive and "CAM: ON" or "CAM: OFF"
end

buttonPVP.TouchTap:Connect(function() aimPlayers = not aimPlayers; actualizarBotonPVP() end)
buttonNPC.TouchTap:Connect(function() aimNPCs = not aimNPCs; actualizarBotonNPC() end)
buttonCAM.TouchTap:Connect(function() camLockActive = not camLockActive; actualizarBotonCAM() end)

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

local camera = workspace.CurrentCamera
local function waitms(ms) task.wait(ms / 1000) end

local comboEjecutandose = false
local function Combo()
    if comboEjecutandose then return end
    comboEjecutandose = true
    local objetivo = obtenerObjetivo()
    local camConnection = nil

    -- BLOQUEO CONTINUO (Aplica tanto a Jugadores como a NPCs si están activos)
    if objetivo and camLockActive then
        camera.CameraType = Enum.CameraType.Scriptable
        camConnection = RunService.RenderStepped:Connect(function()
            if objetivo and objetivo.Parent and objetivo.Parent:FindFirstChild("Humanoid") and objetivo.Parent.Humanoid.Health > 0 then
                camera.CFrame = CFrame.new(camera.CFrame.Position, objetivo.Position)
            else
                if camConnection then camConnection:Disconnect(); camConnection = nil end
                camera.CameraType = Enum.CameraType.Custom
            end
        end)
    end

    -- SECUENCIA EXACTA DEL VIDEO DE TIKTOK (1 SHOT PORTAL COMBO)
    -- 1. Iniciar con Portal (Slot 2) - Habilidad Z (Teletransporte al rival)
    equiparSlot(SLOTS.Portal)
    waitms(80)
    pressKey("Z", 0.1) 
    waitms(950) -- Espera el impacto y el stun inicial

    -- 2. Cambiar inmediatamente a TTK (Slot 3) - Habilidad X
    equiparSlot(SLOTS.TTK)
    waitms(80)
    pressKey("X", 0.1)
    waitms(320) -- Delay de ejecución de la espada

    -- 3. Cambiar a Sanguíneo (Slot 1) - Habilidad Z (Levanta y rompe ken)
    equiparSlot(SLOTS.Sanguine)
    waitms(80)
    pressKey("Z", 0.1)
    waitms(350)

    -- 4. Lanzar Sanguíneo C (Mientras están suspendidos)
    pressKey("C", 0.1)
    waitms(900) -- Frame delay de ráfaga

    -- 5. Cambiar rápido a TTK (Slot 3) - Habilidad Z (Remate direccional en el aire)
    equiparSlot(SLOTS.TTK)
    waitms(80)
    pressKey("Z", 0.1)
    waitms(450) 

    -- 6. Finalizar volviendo a Sanguíneo (Slot 1) - Habilidad X
    equiparSlot(SLOTS.Sanguine)
    waitms(80)
    pressKey("X", 0.1)
    
    -- Liberación y limpieza segura de la cámara
    if camConnection then camConnection:Disconnect(); camConnection = nil end
    camera.CameraType = Enum.CameraType.Custom
    comboEjecutandose = false
end

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
