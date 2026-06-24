local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURACIÓN RÉPLICA HERMANOS HUB (MANUAL - GRIS GHOUL)
local GHOUL_ASSET_ID = "rbxassetid://9073144883" -- Foto de la máscara de Kaneki
local aimPlayers = true
local aimNPCs = false
local camLockActive = false

local objetivoActual = nil
local camera = workspace.CurrentCamera
local camConnection = nil
local characterConnection = nil

-- SISTEMA DE FILTRADO DE HITBOX (Método Hermanos Dev)
local function obtenerObjetivoHermanos()
    local personajeLocal = player.Character
    if not personajeLocal or not personajeLocal:FindFirstChild("HumanoidRootPart") then return nil end
    local menorDistancia = math.huge
    local mejorObjetivo = nil
    local maxRango = 150

    local function verificar(modelo)
        if modelo and modelo:FindFirstChild("HumanoidRootPart") and modelo:FindFirstChildOfClass("Humanoid") then
            if modelo:FindFirstChildOfClass("Humanoid").Health > 0 and modelo ~= personajeLocal then
                local hrp = modelo.HumanoidRootPart
                local distancia = (personajeLocal.HumanoidRootPart.Position - hrp.Position).Magnitude
                if distancia < menorDistancia and distancia <= maxRango then
                    menorDistancia = distancia
                    mejorObjetivo = hrp
                end
            end
        end
    end

    if aimPlayers then
        for _, otroPlayer in ipairs(game.Players:GetPlayers()) do
            if otroPlayer ~= player and otroPlayer.Character then verificar(otroPlayer.Character) end
        end
    end
    if aimNPCs and not mejorObjetivo then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent and not game.Players:GetPlayerFromCharacter(v.Parent) then
                verificar(v.Parent)
            end
        end
    end
    return mejorObjetivo
end

-- =========================================================
--      DISEÑO INTERFAZ RÉPLICA HERMANOS HUB (GRIS TÁCTICO)
-- =========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "HermanosHub_ManualEdition"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Contenedor Principal Flotante
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 165, 0, 165)
mainFrame.Position = UDim2.new(0.78, 0, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20) -- Gris Oscuro
mainFrame.BackgroundTransparency = 0.05
mainFrame.Active = true
mainFrame.Draggable = true -- Arrastrable libremente en móviles
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.8
mainStroke.Color = Color3.fromRGB(55, 55, 60) -- Borde Gris Cenizo
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = mainFrame

-- SECCIÓN SUPERIOR (AVATAR GHOUL)
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(0, 145, 0, 42)
profileFrame.Position = UDim2.new(0.06, 0, 0.06, 0)
profileFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
profileFrame.BackgroundTransparency = 0.3
profileFrame.Parent = mainFrame

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0, 6)
profileCorner.Parent = profileFrame

-- Imagen de Kaneki
local ghoulImage = Instance.new("ImageLabel")
ghoulImage.Size = UDim2.new(0, 32, 0, 32)
ghoulImage.Position = UDim2.new(0.06, 0, 0.12, 0)
ghoulImage.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
ghoulImage.Image = GHOUL_ASSET_ID
ghoulImage.Parent = profileFrame

local imgCorner = Instance.new("UICorner")
imgCorner.CornerRadius = UDim.new(1, 0)
imgCorner.Parent = ghoulImage

-- Textos del Header
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 95, 0, 18)
titleLabel.Position = UDim2.new(0.34, 0, 0.12, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "HERMANOS HUB"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 10
titleLabel.TextColor3 = Color3.fromRGB(225, 225, 230)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = profileFrame

local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(0, 95, 0, 12)
subLabel.Position = UDim2.new(0.34, 0, 0.52, 0)
subLabel.BackgroundTransparency = 1
subLabel.Text = "Manual Aim v1"
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 8
subLabel.TextColor3 = Color3.fromRGB(130, 130, 135)
subLabel.TextXAlignment = Enum.TextXAlignment.Left
subLabel.Parent = profileFrame

-- Línea Divisoria Táctica
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 145, 0, 1)
divider.Position = UDim2.new(0.06, 0, 0.36, 0)
divider.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
divider.BorderSizePixel = 0
divider.Parent = mainFrame
-- =========================================================
--            BOTONES INTERRUPTORES MANUALES
-- =========================================================

-- 1. BOTÓN PVP AIM TOGGLE
local buttonPVP = Instance.new("TextButton")
buttonPVP.Size = UDim2.new(0, 145, 0, 30)
buttonPVP.Position = UDim2.new(0.06, 0, 0.42, 0)
buttonPVP.BackgroundColor3 = Color3.fromRGB(35, 35, 38) -- Gris Claro Activo
buttonPVP.Text = "AIM PLAYER: ON"
buttonPVP.Font = Enum.Font.GothamBold
buttonPVP.TextSize = 10
buttonPVP.TextColor3 = Color3.fromRGB(240, 240, 245)
buttonPVP.Parent = mainFrame

local pvpCorner = Instance.new("UICorner")
pvpCorner.CornerRadius = UDim.new(0, 5)
pvpCorner.Parent = buttonPVP

-- 2. BOTÓN NPC AIM TOGGLE
local buttonNPC = Instance.new("TextButton")
buttonNPC.Size = UDim2.new(0, 145, 0, 30)
buttonNPC.Position = UDim2.new(0.06, 0, 0.62, 0)
buttonNPC.BackgroundColor3 = Color3.fromRGB(24, 24, 26) -- Gris Oscuro Apagado
buttonNPC.Text = "AIM NPC: OFF"
buttonNPC.Font = Enum.Font.GothamBold
buttonNPC.TextSize = 10
buttonNPC.TextColor3 = Color3.fromRGB(135, 135, 140)
buttonNPC.Parent = mainFrame

local npcCorner = Instance.new("UICorner")
npcCorner.CornerRadius = UDim.new(0, 5)
npcCorner.Parent = buttonNPC

-- 3. BOTÓN LOCK CAMERA REAL (Sujeción de enfoque manual)
local buttonCAM = Instance.new("TextButton")
buttonCAM.Size = UDim2.new(0, 145, 0, 30)
buttonCAM.Position = UDim2.new(0.06, 0, 0.82, 0)
buttonCAM.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
buttonCAM.Text = "LOCK CAMERA: OFF"
buttonCAM.Font = Enum.Font.GothamBold
buttonCAM.TextSize = 10
buttonCAM.TextColor3 = Color3.fromRGB(135, 135, 140)
buttonCAM.Parent = mainFrame

local camCorner = Instance.new("UICorner")
camCorner.CornerRadius = UDim.new(0, 5)
camCorner.Parent = buttonCAM

-- ACTUALIZADORES DE ESTADO VISUAL MONOCROMÁTICO
local function actualizarBotonPVP()
    buttonPVP.BackgroundColor3 = aimPlayers and Color3.fromRGB(35, 35, 38) or Color3.fromRGB(24, 24, 26)
    buttonPVP.TextColor3 = aimPlayers and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(135, 135, 140)
    buttonPVP.Text = aimPlayers and "AIM PLAYER: ON" or "AIM PLAYER: OFF"
end

local function actualizarBotonNPC()
    buttonNPC.BackgroundColor3 = aimNPCs and Color3.fromRGB(35, 35, 38) or Color3.fromRGB(24, 24, 26)
    buttonNPC.TextColor3 = aimNPCs and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(135, 135, 140)
    buttonNPC.Text = aimNPCs and "AIM NPC: ON" or "AIM NPC: OFF"
end

-- LOCK CAM / AIMBOT MANUAL PROFESIONAL (Guía cuerpo y mira al oponente en tiempo real)
local function alternarLockCam()
    camLockActive = not camLockActive
    if camLockActive then
        buttonCAM.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
        buttonCAM.TextColor3 = Color3.fromRGB(255, 255, 255)
        buttonCAM.Text = "LOCK CAMERA: ON"
        
        -- Fijación suave de la cámara al rival
        camConnection = RunService.RenderStepped:Connect(function()
            objetivoActual = obtenerObjetivoHermanos()
            if objetivoActual and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, objetivoActual.Position), 0.22)
            end
        end)
        
        -- AIMBOT PROFESIONAL: Sincroniza la rotación del cuerpo para tus habilidades manuales
        characterConnection = RunService.Heartbeat:Connect(function()
            if objetivoActual and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local vel = objetivoActual.Velocity or Vector3.new(0,0,0)
                -- Predicción fina para que lances tus ataques a mano y vayan directo al rival
                local destinoLook = Vector3.new(objetivoActual.Position.X + (vel.X * 0.05), hrp.Position.Y, objetivoActual.Position.Z + (vel.Z * 0.05))
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, destinoLook), 0.8)
            end
        end)
    else
        buttonCAM.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
        buttonCAM.TextColor3 = Color3.fromRGB(135, 135, 140)
        buttonCAM.Text = "LOCK CAMERA: OFF"
        if camConnection then camConnection:Disconnect() camConnection = nil end
        if characterConnection then characterConnection:Disconnect() characterConnection = nil end
    end
end

-- Conexión de Toggles de la interfaz
buttonPVP.TouchTap:Connect(function() aimPlayers = not aimPlayers; actualizarBotonPVP() end)
buttonNPC.TouchTap:Connect(function() aimNPCs = not aimNPCs; actualizarBotonNPC() end)
buttonCAM.TouchTap:Connect(alternarLockCam)

-- Efecto visual interactivo de pulsación táctil
local function agregarEfectoPresionado(boton)
    boton.TouchTap:Connect(function()
        local originalColor = boton.BackgroundColor3
        boton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        task.wait(0.06)
        boton.BackgroundColor3 = originalColor
    end)
end

agregarEfectoPresionado(buttonPVP)
agregarEfectoPresionado(buttonNPC)
agregarEfectoPresionado(buttonCAM)
