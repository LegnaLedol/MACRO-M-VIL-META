local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURACIÓN DE APUNTADO Y PERFIL TOKYO GHOUL
local GHOUL_ASSET_ID = "rbxassetid://9073144883" -- ID Replicado de la Máscara de Kaneki
local aimPlayers = true
local aimNPCs = false
local camLockActive = false

local objetivoActual = nil
local camera = workspace.CurrentCamera
local camConnection = nil

-- FILTRO DE RASTREO CORPORAL NATIVO (Inspirado en Hermanos Hub)
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
--      DISEÑO RÉPLICA HERMANOS HUB (EDICIÓN GRIS GHOUL)
-- =========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "HermanosHub_GrayGhoul"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Contenedor General del Menú Flotante
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 165, 0, 210)
mainFrame.Position = UDim2.new(0.78, 0, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20) -- Gris Oscuro Táctico
mainFrame.BackgroundTransparency = 0.05
mainFrame.Active = true
mainFrame.Draggable = true -- Movible libremente en pantallas móviles
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.8
mainStroke.Color = Color3.fromRGB(55, 55, 60) -- Contorno Gris Cenizo
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = mainFrame

-- SECCIÓN SUPERIOR DE BIENVENIDA (PERFIL GHOUL)
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(0, 145, 0, 42)
profileFrame.Position = UDim2.new(0.06, 0, 0.05, 0)
profileFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
profileFrame.BackgroundTransparency = 0.3
profileFrame.Parent = mainFrame

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0, 6)
profileCorner.Parent = profileFrame

-- Miniatura de la Máscara Ghoul
local ghoulImage = Instance.new("ImageLabel")
ghoulImage.Size = UDim2.new(0, 32, 0, 32)
ghoulImage.Position = UDim2.new(0.06, 0, 0.12, 0)
ghoulImage.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
ghoulImage.Image = GHOUL_ASSET_ID
ghoulImage.Parent = profileFrame

local imgCorner = Instance.new("UICorner")
imgCorner.CornerRadius = UDim.new(1, 0) -- Redondeado perfecto estilo avatar
imgCorner.Parent = ghoulImage

-- Etiquetas de Texto del Hub
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
subLabel.Text = "Ghoul Edition v2"
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 8
subLabel.TextColor3 = Color3.fromRGB(130, 130, 135)
subLabel.TextXAlignment = Enum.TextXAlignment.Left
subLabel.Parent = profileFrame

-- Línea Divisoria Estética
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 145, 0, 1)
divider.Position = UDim2.new(0.06, 0, 0.28, 0)
divider.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
divider.BorderSizePixel = 0
divider.Parent = mainFrame
-- =========================================================
--             CONMUTADORES DE INTERRUPCIÓN (IU)
-- =========================================================

-- INTERRUPTOR 1: PVP AIM
local buttonPVP = Instance.new("TextButton")
buttonPVP.Size = UDim2.new(0, 145, 0, 32)
buttonPVP.Position = UDim2.new(0.06, 0, 0.34, 0)
buttonPVP.BackgroundColor3 = Color3.fromRGB(35, 35, 38) -- Gris Activo Base
buttonPVP.Text = "AIM JUGADOR: ON"
buttonPVP.Font = Enum.Font.GothamBold
buttonPVP.TextSize = 10
buttonPVP.TextColor3 = Color3.fromRGB(240, 240, 245)
buttonPVP.Parent = mainFrame

local pvpCorner = Instance.new("UICorner")
pvpCorner.CornerRadius = UDim.new(0, 5)
pvpCorner.Parent = buttonPVP

-- INTERRUPTOR 2: NPC AIM
local buttonNPC = Instance.new("TextButton")
buttonNPC.Size = UDim2.new(0, 145, 0, 32)
buttonNPC.Position = UDim2.new(0.06, 0, 0.53, 0)
buttonNPC.BackgroundColor3 = Color3.fromRGB(24, 24, 26) -- Gris Apagado
buttonNPC.Text = "AIM NPC: OFF"
buttonNPC.Font = Enum.Font.GothamBold
buttonNPC.TextSize = 10
buttonNPC.TextColor3 = Color3.fromRGB(135, 135, 140)
buttonNPC.Parent = mainFrame

local npcCorner = Instance.new("UICorner")
npcCorner.CornerRadius = UDim.new(0, 5)
npcCorner.Parent = buttonNPC

-- INTERRUPTOR 3: LOCK CÁMARA REAL (AIMBOT SEPARADO)
local buttonCAM = Instance.new("TextButton")
buttonCAM.Size = UDim2.new(0, 145, 0, 32)
buttonCAM.Position = UDim2.new(0.06, 0, 0.72, 0)
buttonCAM.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
buttonCAM.Text = "LOCK CAMERA: OFF"
buttonCAM.Font = Enum.Font.GothamBold
buttonCAM.TextSize = 10
buttonCAM.TextColor3 = Color3.fromRGB(135, 135, 140)
buttonCAM.Parent = mainFrame

local camCorner = Instance.new("UICorner")
camCorner.CornerRadius = UDim.new(0, 5)
camCorner.Parent = buttonCAM

-- SISTEMA DINÁMICO DE INTERRUPTORES MONOCROMÁTICOS GRISES
local function actualizarBotonPVP()
    buttonPVP.BackgroundColor3 = aimPlayers and Color3.fromRGB(35, 35, 38) or Color3.fromRGB(24, 24, 26)
    buttonPVP.TextColor3 = aimPlayers and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(135, 135, 140)
    buttonPVP.Text = aimPlayers and "AIM JUGADOR: ON" or "AIM JUGADOR: OFF"
end

local function actualizarBotonNPC()
    buttonNPC.BackgroundColor3 = aimNPCs and Color3.fromRGB(35, 35, 38) or Color3.fromRGB(24, 24, 26)
    buttonNPC.TextColor3 = aimNPCs and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(135, 135, 140)
    buttonNPC.Text = aimNPCs and "AIM NPC: ON" or "AIM NPC: OFF"
end

-- SISTEMA LOCK CAM INTERPOLADO (Aimbot nativo de rastreo sutil)
local function alternarLockCam()
    camLockActive = not camLockActive
    if camLockActive then
        buttonCAM.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
        buttonCAM.TextColor3 = Color3.fromRGB(255, 255, 255)
        buttonCAM.Text = "LOCK CAMERA: ON"
        
        -- Ejecución fluida de fijación a la mirada del rival
        camConnection = RunService.RenderStepped:Connect(function()
            objetivoActual = obtenerObjetivoHermanos()
            if objetivoActual and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- El suavizado Lerp (0.22) acompaña los dashes del enemigo quirúrgicamente
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, objetivoActual.Position), 0.22)
            end
        end)
    else
        buttonCAM.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
        buttonCAM.TextColor3 = Color3.fromRGB(135, 135, 140)
        buttonCAM.Text = "LOCK CAMERA: OFF"
        if camConnection then camConnection:Disconnect() camConnection = nil end
    end
end

-- Eventos de clicks para los Toggles
buttonPVP.TouchTap:Connect(function() aimPlayers = not aimPlayers; actualizarBotonPVP() end)
buttonNPC.TouchTap:Connect(function() aimNPCs = not aimNPCs; actualizarBotonNPC() end)
buttonCAM.TouchTap:Connect(alternarLockCam)

-- Retroalimentación táctil de pulsación en botones del Hub original
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
