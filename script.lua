local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURACIÓN DEL SET META ULTRA-SPEED
local MI_SET = {
    Fruit = "Portal",
    Melee = "Sanguine Art",
    Sword = "True Triple Katana",
    Gun = "Soul Guitar"
}

local aimPlayers = true
local aimNPCs = false
local camLockActive = false
local objetivoActual = nil
local camera = workspace.CurrentCamera
local camConnection = nil

-- MACRO PC METHOD: Equipado forzado por bypass de memoria
local function equiparHerramientaPC(nombreReal)
    local character = player.Character
    local backpack = player:WaitForChild("Backpack")
    if not character then return end
    
    local armaActual = character:FindFirstChildOfClass("Tool")
    if armaActual and armaActual.Name ~= nombreReal then
        armaActual.Parent = backpack
    end
    
    local nuevaArma = backpack:FindFirstChild(nombreReal)
    if nuevaArma then
        nuevaArma.Parent = character
        if nuevaArma:FindFirstChild("Activate") then nuevaArma.Activate:Fire() end
    end
end

-- PC AIMBOT METHOD: Escaneo de Hitbox Directo
local function obtenerObjetivoPC()
    local personajeLocal = player.Character
    if not personajeLocal or not personajeLocal:FindFirstChild("HumanoidRootPart") then return nil end
    local menorDistancia = math.huge
    local mejorObjetivo = nil
    local maxRango = 140

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
--              NUEVA INTERFAZ GRÁFICA ESTÉTICA (IU)
-- =========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "L_CyberMeta_Menu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Contenedor Principal (Panel Completo)
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(0, 100, 0, 195)
mainPanel.Position = UDim2.new(0.82, 0, 0.35, 0)
mainPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainPanel.BackgroundTransparency = 0.15
mainPanel.Active = true
mainPanel.Draggable = true -- Arrastra desde el fondo para mover todo el menú junto
mainPanel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = mainPanel

-- Borde con Efecto Neón Arcoíris RGB para todo el panel
local panelStroke = Instance.new("UIStroke")
panelStroke.Thickness = 1.5
panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
panelStroke.Parent = mainPanel

-- 1. BOTÓN PRINCIPAL DEL COMBO "L" (Estilo Neon Central)
local buttonCombo = Instance.new("TextButton")
buttonCombo.Size = UDim2.new(0, 80, 0, 40)
buttonCombo.Position = UDim2.new(0.1, 0, 0.08, 0)
buttonCombo.BackgroundColor3 = Color3.fromRGB(40, 20, 70)
buttonCombo.Text = "LAUNCH"
buttonCombo.Font = Enum.Font.GothamBold
buttonCombo.TextSize = 12
buttonCombo.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonCombo.Parent = mainPanel

local cornerCombo = Instance.new("UICorner")
cornerCombo.CornerRadius = UDim.new(0, 6)
cornerCombo.Parent = buttonCombo

-- Separador Visual Elegante
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 80, 0, 1)
divider.Position = UDim2.new(0.1, 0, 0.33, 0)
divider.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
divider.BorderSizePixel = 0
divider.Parent = mainPanel

-- 2. INTERRUPTOR ESTÉTICO: JUGADORES (PVP)
local buttonPVP = Instance.new("TextButton")
buttonPVP.Size = UDim2.new(0, 80, 0, 28)
buttonPVP.Position = UDim2.new(0.1, 0, 0.38, 0)
buttonPVP.BackgroundColor3 = Color3.fromRGB(25, 60, 35)
buttonPVP.Text = "PVP: ON"
buttonPVP.Font = Enum.Font.GothamBold
buttonPVP.TextSize = 11
buttonPVP.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonPVP.Parent = mainPanel

local cornerPVP = Instance.new("UICorner")
cornerPVP.CornerRadius = UDim.new(0, 6)
cornerPVP.Parent = buttonPVP

-- 3. INTERRUPTOR ESTÉTICO: NPCs (FARM)
local buttonNPC = Instance.new("TextButton")
buttonNPC.Size = UDim2.new(0, 80, 0, 28)
buttonNPC.Position = UDim2.new(0.1, 0, 0.56, 0)
buttonNPC.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
buttonNPC.Text = "NPC: OFF"
buttonNPC.Font = Enum.Font.GothamBold
buttonNPC.TextSize = 11
buttonNPC.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonNPC.Parent = mainPanel

local cornerNPC = Instance.new("UICorner")
cornerNPC.CornerRadius = UDim.new(0, 6)
cornerNPC.Parent = buttonNPC

-- 4. INTERRUPTOR ESTÉTICO: LOCK CÁMARA
local buttonCAM = Instance.new("TextButton")
buttonCAM.Size = UDim2.new(0, 80, 0, 28)
buttonCAM.Position = UDim2.new(0.1, 0, 0.74, 0)
buttonCAM.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
buttonCAM.Text = "LOCK: OFF"
buttonCAM.Font = Enum.Font.GothamBold
buttonCAM.TextSize = 11
buttonCAM.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonCAM.Parent = mainPanel

local cornerCAM = Instance.new("UICorner")
cornerCAM.CornerRadius = UDim.new(0, 6)
cornerCAM.Parent = buttonCAM

-- Hilo cíclico para iluminar el neón del contorno con degradado cromático
coroutine.wrap(function()
    while true do
        for hue = 0, 1, 0.01 do
            panelStroke.Color = Color3.fromHSV(hue, 0.8, 0.9)
            task.wait(0.02)
        end
    end
end)()
-- Actualización visual adaptativa de la nueva IU
local function actualizarBotonPVP()
    if aimPlayers then
        buttonPVP.BackgroundColor3 = Color3.fromRGB(25, 60, 35) -- Verde bosque sutil
        buttonPVP.Text = "PVP: ON"
    else
        buttonPVP.BackgroundColor3 = Color3.fromRGB(70, 30, 30) -- Carmesí oscuro
        buttonPVP.Text = "PVP: OFF"
    end
end

local function actualizarBotonNPC()
    if aimNPCs then
        buttonNPC.BackgroundColor3 = Color3.fromRGB(25, 60, 35)
        buttonNPC.Text = "NPC: ON"
    else
        buttonNPC.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
        buttonNPC.Text = "NPC: OFF"
    end
end

local function alternarLockCam()
    camLockActive = not camLockActive
    if camLockActive then
        buttonCAM.BackgroundColor3 = Color3.fromRGB(25, 60, 35)
        buttonCAM.Text = "LOCK: ON"
        camConnection = RunService.RenderStepped:Connect(function()
            objetivoActual = obtenerObjetivoPC()
            if objetivoActual and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, objetivoActual.Position)
            end
        end)
    else
        buttonCAM.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
        buttonCAM.Text = "LOCK: OFF"
        if camConnection then camConnection:Disconnect() camConnection = nil end
    end
end

buttonPVP.TouchTap:Connect(function() aimPlayers = not aimPlayers; actualizarBotonPVP() end)
buttonNPC.TouchTap:Connect(function() aimNPCs = not aimNPCs; actualizarBotonNPC() end)
buttonCAM.TouchTap:Connect(alternarLockCam)

local function ejecutarKeyInstant(keyName)
    local success, VIM = pcall(function() return game:GetService("VirtualInputManager") end)
    if success and VIM then
        local keyCode = Enum.KeyCode[keyName]
        VIM:SendKeyEvent(true, keyCode, false, game)
        RunService.Heartbeat:Wait()
        VIM:SendKeyEvent(false, keyCode, false, game)
    end
end

-- PC AIMBOT METHOD: Ajuste de rotación total
local function alinearVectoresPC(objetivo)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") and objetivo then
        local hrp = character.HumanoidRootPart
        local vel = objetivo.Velocity or Vector3.new(0, 0, 0)
        local posicionObjetivo = objetivo.Position + (vel * 0.06)
        
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(posicionObjetivo.X, hrp.Position.Y, posicionObjetivo.Z))
        
        if not camLockActive then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, objetivo.Position)
        end
        RunService.Heartbeat:Wait()
    end
end

-- CANCELACIÓN DE ANIMACIONES
local function esperarTickAnimacion(keyName)
    local character = player.Character
    if not character or not character:FindFirstChildOfClass("Humanoid") then return end
    
    local animator = character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
    local ejecutado = false
    local tickSeguridad = 0
    
    while not ejecutado and tickSeguridad < 6 do
        ejecutarKeyInstant(keyName)
        RunService.Heartbeat:Wait()
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local n = track.Animation.Name:lower()
                if n:find("attack") or n:find("slash") or n:find("skill") or n:find("z") or n:find("x") or n:find("c") then
                    track:GetMarkerReachedSignal("hit"):Connect(function() ejecutado = true end)
                    RunService.Heartbeat:Wait()
                    ejecutado = true
                    break
                end
            end
        end
        tickSeguridad = tickSeguridad + 1
    end
end

-- EJECUCIÓN DEL COMBO COMPLEMENTARIO PORTAL META
local comboEjecutandose = false
local function Combo()
    if comboEjecutandose then return end
    comboEjecutandose = true

    objetivoActual = obtenerObjetivoPC()
    if not objetivoActual then comboEjecutandose = false return end

    -- 1. Portal [Z]
    equiparHerramientaPC(MI_SET.Fruit)
    alinearVectoresPC(objetivoActual)
    esperarTickAnimacion("Z")
    RunService.Heartbeat:Wait() task.wait(0.85)

    -- 2. Soul Guitar [X]
    equiparHerramientaPC(MI_SET.Gun)
    alinearVectoresPC(objetivoActual)
    esperarTickAnimacion("X")
    task.wait(0.4)

    -- 3. Sanguine Art [Z]
    equiparHerramientaPC(MI_SET.Melee)
    alinearVectoresPC(objetivoActual)
    esperarTickAnimacion("Z")
    task.wait(0.3)

    -- 4. Sanguine Art [C]
    alinearVectoresPC(objetivoActual)
    esperarTickAnimacion("C")
    task.wait(0.8)

    -- 5. TTK [Z]
    equiparHerramientaPC(MI_SET.Sword)
    alinearVectoresPC(objetivoActual)
    esperarTickAnimacion("Z")
    task.wait(0.35)

    -- 6. Sanguine Art [X]
    equiparHerramientaPC(MI_SET.Melee)
    alinearVectoresPC(objetivoActual)
    esperarTickAnimacion("X")

    comboEjecutandose = false
end

-- Animación premium interactiva en el botón "LAUNCH" al pulsarlo
buttonCombo.TouchTap:Connect(function()
    local oldColor = buttonCombo.BackgroundColor3
    local tweenShrink = TweenService:Create(buttonCombo, TweenInfo.new(0.06), {
        Size = UDim2.new(0, 74, 0, 36),
        BackgroundColor3 = Color3.fromRGB(60, 30, 100)
    })
    local tweenExpand = TweenService:Create(buttonCombo, TweenInfo.new(0.06), {
        Size = UDim2.new(0, 80, 0, 40),
        BackgroundColor3 = oldColor
    })
    
    tweenShrink:Play()
    tweenShrink.Completed:Wait()
    tweenExpand:Play()
    Combo()
end)
