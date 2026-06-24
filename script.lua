local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- CONFIGURACIÓN DEL SET PORTAL META INSTA-KILL
local MI_SET = {
    Fruit = "Portal",
    Melee = "Sanguine Art",
    Sword = "True Triple Katana",
    Gun = "Soul Guitar"
}

-- ESTADOS DEL MENÚ
local aimPlayers = true
local aimNPCs = false
local camLockActive = false

local objetivoActual = nil
local camera = workspace.CurrentCamera
local camConnection = nil

-- Cambiar de arma de forma forzada instantáneamente sin retrasos
local function equiparHerramienta(nombreReal)
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character
    if not character then return end
    
    local currentTool = character:FindFirstChildOfClass("Tool")
    if currentTool and currentTool.Name ~= nombreReal then 
        currentTool.Parent = backpack 
    end
    
    local tool = backpack:FindFirstChild(nombreReal)
    if tool then 
        tool.Parent = character 
    end
end

-- RASTREADOR POR FOV AVANZADO (Fija al oponente más cercano a tu mira de pantalla)
local function obtenerObjetivoFOV()
    local personajeLocal = player.Character
    if not personajeLocal or not personajeLocal:FindFirstChild("HumanoidRootPart") then return nil end
    
    local mejorObjetivo = nil
    local menorDistanciaPantalla = math.huge
    local maxRangoStuds = 140

    local function escanearCuerpo(modelo)
        if modelo and modelo:FindFirstChild("HumanoidRootPart") and modelo:FindFirstChildOfClass("Humanoid") then
            if modelo:FindFirstChildOfClass("Humanoid").Health > 0 and modelo ~= personajeLocal then
                local hrp = modelo.HumanoidRootPart
                local distanciaStuds = (personajeLocal.HumanoidRootPart.Position - hrp.Position).Magnitude
                if distanciaStuds <= maxRangoStuds then
                    local vector, enPantalla = camera:WorldToViewportPoint(hrp.Position)
                    if enPantalla then
                        local centroPantalla = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                        local distanciaPantalla = (Vector2.new(vector.X, vector.Y) - centroPantalla).Magnitude
                        
                        if distanciaPantalla < menorDistanciaPantalla then
                            menorDistanciaPantalla = distanciaPantalla
                            mejorObjetivo = hrp
                        end
                    end
                end
            end
        end
    end

    if aimPlayers then
        for _, otroPlayer in ipairs(game.Players:GetPlayers()) do
            if otroPlayer ~= player and otroPlayer.Character then escanearCuerpo(otroPlayer.Character) end
        end
    end
    
    if aimNPCs and not mejorObjetivo then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent and not game.Players:GetPlayerFromCharacter(v.Parent) then
                escanearCuerpo(v.Parent)
            end
        end
    end
    
    return mejorObjetivo
end

-- INTERFAZ GRÁFICA (GUI)
local gui = Instance.new("ScreenGui")
gui.Name = "L_PortalMeta_Ultra_Hub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local buttonCombo = Instance.new("TextButton")
buttonCombo.Size = UDim2.new(0, 55, 0, 55)
buttonCombo.Position = UDim2.new(0.75, 0, 0.5, 0)
buttonCombo.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
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
buttonCAM.BackgroundColor3 = Color3.fromRGB(178, 34, 34)
buttonCAM.Text = "LOCK: OFF"
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

-- LOCK CAM SEPARADO (Control de cámara nativo frame por frame)
local function alternarLockCam()
    camLockActive = not camLockActive
    if camLockActive then
        buttonCAM.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
        buttonCAM.Text = "LOCK: ON"
        
        camConnection = RunService.RenderStepped:Connect(function()
            objetivoActual = obtenerObjetivoFOV()
            if objetivoActual and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, objetivoActual.Position)
            end
        end)
    else
        buttonCAM.BackgroundColor3 = Color3.fromRGB(178, 34, 34)
        buttonCAM.Text = "LOCK: OFF"
        if camConnection then camConnection:Disconnect() camConnection = nil end
    end
end

buttonPVP.TouchTap:Connect(function() aimPlayers = not aimPlayers; actualizarBotonPVP() end)
buttonNPC.TouchTap:Connect(function() aimNPCs = not aimNPCs; actualizarBotonNPC() end)
buttonCAM.TouchTap:Connect(alternarLockCam)

-- Disparador Virtual de Inputs Forzado de 1 Frame
local function ejecutarKeyInstant(keyName)
    local success, VIM = pcall(function() return game:GetService("VirtualInputManager") end)
    if success and VIM then
        local keyCode = Enum.KeyCode[keyName]
        VIM:SendKeyEvent(true, keyCode, false, game)
        RunService.Heartbeat:Wait()
        VIM:SendKeyEvent(false, keyCode, false, game)
    end
end

-- EL AIMBOT MANO: Aimbot predictivo de Hitbox por FOV (Corregido 'listO')
local function forzarAimbotHitbox(objetivo)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") and objetivo then
        local hrp = character.HumanoidRootPart
        -- Cálculo Predictivo: Intercepta al rival basándose en su velocidad actual
        local vel = objetivo.Velocity or Vector3.new(0, 0, 0)
        local puntoPredicho = objetivo.Position + (vel * 0.09)
        
        -- Clava la orientación del cuerpo directo a la hitbox del objetivo
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(puntoPredicho.X, hrp.Position.Y, puntoPredicho.Z))
        
        -- Forzar el apuntado de la cámara al objetivo si LOCK está en OFF para que la skill no falle
        if not camLockActive then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, objetivo.Position)
        end
        RunService.Heartbeat:Wait()
    end
end

-- SISTEMA ASISTENTE: Escucha si la animación se activa realmente en el personaje
local function verificarYForzarSkill(keyName)
    local character = player.Character
    if not character or not character:FindFirstChildOfClass("Humanoid") then return end
    
    local animator = character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
    local skillVerificada = false
    local intentos = 0
    
    -- Intenta lanzar y verificar hasta 8 veces seguidas a súper velocidad (Antilag/Anti-miss)
    while not skillVerificada and intentos < 8 do
        ejecutarKeyInstant(keyName)
        RunService.Heartbeat:Wait()
        
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local name = track.Animation.Name:lower()
                -- Si se detecta cualquier movimiento de ataque, se confirma el casteo
                if name:find("attack") or name:find("slash") or name:find("skill") or name:find("z") or name:find("x") or name:find("c") then
                    skillVerificada = true
                    break
                end
            end
        end
        intentos = intentos + 1
    end
end

local function waitms(ms) task.wait(ms / 1000) end

-- SECUENCIA DE COMBO PORTAL INSTA-KILL META CON CONTROL ASISTIDO FORZADO
local comboEjecutandose = false
local function Combo()
    if comboEjecutandose then return end
    comboEjecutandose = true

    objetivoActual = obtenerObjetivoFOV()
    if not objetivoActual then comboEjecutandose = false return end

    -- 1. Portal [Z] (Teletransporta y atrapa. FORZADO SI O SI)
    equiparHerramienta(MI_SET.Fruit)
    forzarAimbotHitbox(objetivoActual)
    waitms(30)
    verificarYForzarSkill("Z") -- Obliga al script a realizar la Z pase lo que pase
    waitms(880)

    -- 2. Soul Guitar [X] (Ruptura instantánea de Ken)
    equiparHerramienta(MI_SET.Gun)
    forzarAimbotHitbox(objetivoActual)
    waitms(30)
    verificarYForzarSkill("X")
    waitms(420)

    -- 3. Sanguine Art [Z] (Levantamiento y agarre físico)
    equiparHerramienta(MI_SET.Melee)
    forzarAimbotHitbox(objetivoActual)
    waitms(30)
    verificarYForzarSkill("Z")
    waitms(320)

    -- 4. Sanguine Art [C] (Drenaje masivo de vida en el aire)
    forzarAimbotHitbox(objetivoActual)
    verificarYForzarSkill("C")
    waitms(820)

    -- 5. TTK [Z] (True Triple Katana - Daño masivo aéreo)
    equiparHerramienta(MI_SET.Sword)
    forzarAimbotHitbox(objetivoActual)
    waitms(30)
    verificarYForzarSkill("Z")
    waitms(390)

    -- 6. Sanguine Art [X] (Remate One-Shot contra el suelo)
    equiparHerramienta(MI_SET.Melee)
    forzarAimbotHitbox(objetivoActual)
    waitms(30)
    verificarYForzarSkill("X")

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
