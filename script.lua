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

-- MACRO PC METHOD: Equipado forzado por bypass de memoria (elimina el delay táctil)
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

-- PRO AIMBOT METHOD: Filtro de objetivos óptimos en base a distancia real
local function obtenerObjetivoPro()
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
--        NUEVA IU PREMIUM: BOTONES SEPARADOS Y MÓVILES
-- =========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "L_Pro_Separated_Hub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- 1. BOTÓN PRINCIPAL DEL COMBO "LAUNCH" (Diseño Ejecutivo Oscuro)
local buttonCombo = Instance.new("TextButton")
buttonCombo.Size = UDim2.new(0, 75, 0, 42)
buttonCombo.Position = UDim2.new(0.75, 0, 0.45, 0)
buttonCombo.BackgroundColor3 = Color3.fromRGB(24, 18, 36)
buttonCombo.BackgroundTransparency = 0.15
buttonCombo.Text = "LAUNCH"
buttonCombo.Font = Enum.Font.GothamBold
buttonCombo.TextSize = 11
buttonCombo.TextColor3 = Color3.fromRGB(235, 235, 255)
buttonCombo.Active = true
buttonCombo.Draggable = true
buttonCombo.Parent = gui

local cornerCombo = Instance.new("UICorner")
cornerCombo.CornerRadius = UDim.new(0, 8)
cornerCombo.Parent = buttonCombo

local strokeCombo = Instance.new("UIStroke")
strokeCombo.Thickness = 1.5
strokeCombo.Color = Color3.fromRGB(115, 60, 195) -- Contorno morado neón fijo elegante
strokeCombo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
strokeCombo.Parent = buttonCombo

-- 2. BOTÓN INTERRUPTOR: PVP
local buttonPVP = Instance.new("TextButton")
buttonPVP.Size = UDim2.new(0, 65, 0, 30)
buttonPVP.Position = UDim2.new(0.75, 85, 0, 48)
buttonPVP.BackgroundColor3 = Color3.fromRGB(15, 30, 20)
buttonPVP.BackgroundTransparency = 0.2
buttonPVP.Text = "PVP: ON"
buttonPVP.Font = Enum.Font.GothamBold
buttonPVP.TextSize = 10
buttonPVP.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonPVP.Active = true
buttonPVP.Draggable = true
buttonPVP.Parent = gui

local cornerPVP = Instance.new("UICorner")
cornerPVP.CornerRadius = UDim.new(0, 6)
cornerPVP.Parent = buttonPVP

local strokePVP = Instance.new("UIStroke")
strokePVP.Thickness = 1.2
strokePVP.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
strokePVP.Parent = buttonPVP

-- 3. BOTÓN INTERRUPTOR: NPC
local buttonNPC = Instance.new("TextButton")
buttonNPC.Size = UDim2.new(0, 65, 0, 30)
buttonNPC.Position = UDim2.new(0.75, 85, 0, 85)
buttonNPC.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
buttonNPC.BackgroundTransparency = 0.2
buttonNPC.Text = "NPC: OFF"
buttonNPC.Font = Enum.Font.GothamBold
buttonNPC.TextSize = 10
buttonNPC.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonNPC.Active = true
buttonNPC.Draggable = true
buttonNPC.Parent = gui

local cornerNPC = Instance.new("UICorner")
cornerNPC.CornerRadius = UDim.new(0, 6)
cornerNPC.Parent = buttonNPC

local strokeNPC = Instance.new("UIStroke")
strokeNPC.Thickness = 1.2
strokeNPC.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
strokeNPC.Parent = buttonNPC

-- 4. BOTÓN INTERRUPTOR: LOCK CAM
local buttonCAM = Instance.new("TextButton")
buttonCAM.Size = UDim2.new(0, 65, 0, 30)
buttonCAM.Position = UDim2.new(0.75, 85, 0, 122)
buttonCAM.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
buttonCAM.BackgroundTransparency = 0.2
buttonCAM.Text = "LOCK: OFF"
buttonCAM.Font = Enum.Font.GothamBold
buttonCAM.TextSize = 10
buttonCAM.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonCAM.Active = true
buttonCAM.Draggable = true
buttonCAM.Parent = gui

local cornerCAM = Instance.new("UICorner")
cornerCAM.CornerRadius = UDim.new(0, 6)
cornerCAM.Parent = buttonCAM

local strokeCAM = Instance.new("UIStroke")
strokeCAM.Thickness = 1.2
strokeCAM.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
strokeCAM.Parent = buttonCAM

-- Bucle Coroutine único para animar el degradado RGB en los contornos de los botones interactivos
coroutine.wrap(function()
    while true do
        for hue = 0, 1, 0.01 do
            local color = Color3.fromHSV(hue, 0.75, 0.85)
            strokePVP.Color = color
            strokeNPC.Color = color
            strokeCAM.Color = color
            task.wait(0.02)
        end
    end
end)()
local function actualizarBotonPVP()
    if aimPlayers then
        buttonPVP.BackgroundColor3 = Color3.fromRGB(15, 30, 20)
        buttonPVP.Text = "PVP: ON"
    else
        buttonPVP.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
        buttonPVP.Text = "PVP: OFF"
    end
end

local function actualizarBotonNPC()
    if aimNPCs then
        buttonNPC.BackgroundColor3 = Color3.fromRGB(15, 30, 20)
        buttonNPC.Text = "NPC: ON"
    else
        buttonNPC.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
        buttonNPC.Text = "NPC: OFF"
    end
end

-- APARTADO INDEPENDIENTE: LOCK CAM SMOOTH (CFrame Suavizado profesional)
local function alternarLockCam()
    camLockActive = not camLockActive
    if camLockActive then
        buttonCAM.BackgroundColor3 = Color3.fromRGB(15, 30, 20)
        buttonCAM.Text = "LOCK: ON"
        camConnection = RunService.RenderStepped:Connect(function()
            objetivoActual = obtenerObjetivoPro()
            if objetivoActual and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Interpolación Lineal (Lerp) a velocidad de refresco del dispositivo móvil
                local actualCFrame = camera.CFrame
                local destinoCFrame = CFrame.lookAt(camera.CFrame.Position, objetivoActual.Position)
                camera.CFrame = actualCFrame:Lerp(destinoCFrame, 0.25) -- 0.25 da un seguimiento ultra fluido y profesional
            end
        end)
    else
        buttonCAM.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
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

-- PRO AIMBOT SKILL SYSTEM: Interpolación de movimiento de vectores + Compensación de Ping
local function alinearVectoresPro(objetivo)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") and objetivo then
        local hrp = character.HumanoidRootPart
        
        -- Compensación predictiva avanzada basándose en los frames de red
        local vel = objetivo.Velocity or Vector3.new(0, 0, 0)
        local pingCompensation = vel * 0.055
        local posicionPredicha = objetivo.Position + pingCompensation
        
        -- Forzar la rotación del cuerpo mirando a la hitbox con suavizado Lerp instantáneo
        local targetRotation = CFrame.lookAt(hrp.Position, Vector3.new(posicionPredicha.X, hrp.Position.Y, posicionPredicha.Z))
        hrp.CFrame = hrp.CFrame:Lerp(targetRotation, 0.8) -- Transición limpia en 1 tick físico
        
        if not camLockActive then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, objetivo.Position)
        end
        RunService.Heartbeat:Wait()
    end
end

-- CANCELACIÓN DE ANIMACIONES POR MARCADORES DE RED DE EXPLOITS PROFESIONALES
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

-- EJECUCIÓN DE LA MACRO META PORTAL ONE-SHOT DEFINITIVA (MÁXIMA EFICIENCIA)
local comboEjecutandose = false
local function Combo()
    if comboEjecutandose then return end
    comboEjecutandose = true

    objetivoActual = obtenerObjetivoPro()
    if not objetivoActual then comboEjecutandose = false return end

    -- 1. Portal [Z]
    equiparHerramientaPC(MI_SET.Fruit)
    alinearVectoresPro(objetivoActual)
    esperarTickAnimacion("Z")
    RunService.Heartbeat:Wait() task.wait(0.85)

    -- 2. Soul Guitar [X]
    equiparHerramientaPC(MI_SET.Gun)
    alinearVectoresPro(objetivoActual)
    esperarTickAnimacion("X")
    task.wait(0.4)

    -- 3. Sanguine Art [Z]
    equiparHerramientaPC(MI_SET.Melee)
    alinearVectoresPro(objetivoActual)
    esperarTickAnimacion("Z")
    task.wait(0.3)

    -- 4. Sanguine Art [C]
    alinearVectoresPro(objetivoActual)
    esperarTickAnimacion("C")
    task.wait(0.8)

    -- 5. TTK [Z]
    equiparHerramientaPC(MI_SET.Sword)
    alinearVectoresPro(objetivoActual)
    esperarTickAnimacion("Z")
    task.wait(0.35)

    -- 6. Sanguine Art [X]
    equiparHerramientaPC(MI_SET.Melee)
    alinearVectoresPro(objetivoActual)
    esperarTickAnimacion("X")

    comboEjecutandose = false
end

-- Animación premium de escala interactiva al pulsar el botón "LAUNCH"
buttonCombo.TouchTap:Connect(function()
    local tweenShrink = TweenService:Create(buttonCombo, TweenInfo.new(0.06), {Size = UDim2.new(0, 69, 0, 38)})
    local tweenExpand = TweenService:Create(buttonCombo, TweenInfo.new(0.06), {Size = UDim2.new(0, 75, 0, 42)})
    
    tweenShrink:Play()
    tweenShrink.Completed:Wait()
    tweenExpand:Play()
    Combo()
end)
