local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ASIGNACIÓN DEL SET PORTAL META
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

-- Función forzada para equipar herramientas rápido en móvil
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

-- BÚSQUEDA POR FOV (Busca al enemigo más cercano al CENTRO de tu pantalla)
local function obtenerObjetivoFOV()
    local personajeLocal = player.Character
    if not personajeLocal or not personajeLocal:FindFirstChild("HumanoidRootPart") then return nil end
    
    local mejorObjetivo = nil
    local menorDistanciaPantalla = math.huge
    local maxRangoStuds = 150 -- Distancia máxima en el juego

    local function escanearCuerpo(modelo)
        if modelo and modelo:FindFirstChild("HumanoidRootPart") and modelo:FindFirstChildOfClass("Humanoid") then
            if modelo:FindFirstChildOfClass("Humanoid").Health > 0 and modelo ~= personajeLocal then
                local hrp = modelo.HumanoidRootPart
                -- Verifica la distancia en studs primero
                local distanciaStuds = (personajeLocal.HumanoidRootPart.Position - hrp.Position).Magnitude
                if distanciaStuds <= maxRangoStuds then
                    -- Proyecta la posición del mundo 3D a la pantalla móvil 2D
                    local vector, enPantalla = camera:WorldToViewportPoint(hrp.Position)
                    if enPantalla then
                        -- Calcula qué tan cerca está del centro exacto de tu FOV
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

    -- 1. Filtrar Jugadores si PVP está ON
    if aimPlayers then
        for _, otroPlayer in ipairs(game.Players:GetPlayers()) do
            if otroPlayer ~= player and otroPlayer.Character then
                escanearCuerpo(otroPlayer.Character)
            end
        end
    end
    
    -- 2. Filtrar NPCs si NPC está ON y no hay un jugador en la mira
    if aimNPCs and not mejorObjetivo then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Parent then
                if not game.Players:GetPlayerFromCharacter(v.Parent) then
                    escanearCuerpo(v.Parent)
                end
            end
        end
    end
    
    return mejorObjetivo
end

-- INTERFAZ GRÁFICA (GUI)
local gui = Instance.new("ScreenGui")
gui.Name = "L_PortalFOV_Hub"
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

-- APARTADO INDEPENDIENTE: LOCK CAM REAL (Fija la vista en el rival frame a frame)
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

-- AIMBOT SKILL INTELLIGENT (Alinea los ataques directo al objetivo en tu FOV)
local function redireccionarAtaque(objetivo)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") and objetivo then
        local hrp = character.HumanoidRootPart
        local velocidad = objetivo.Velocity or Vector3.new(0,0,0)
        -- Pequeña predicción por si se mueve rápido
        local posicionObjetivo = objetivo.Position + (velocidad * 0.07)
        
        -- Hace que el cuerpo mire directamente a la posición del rival en horizontal y vertical
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(posicionObjetivo.X, hrp.Position.Y, posicionObjetivo.Z))
        
        -- Si el LOCK CAM está apagado, de todas formas forzamos la dirección exacta de disparo en ese microsegundo
        if not camLockActive then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, objetivo.Position)
        end
        task.wait(0.02)
    end
end

-- EJECUCIÓN DEL COMBO COMPETITIVO COMPLETO
local comboEjecutandose = false
local function Combo()
    if comboEjecutandose then return end
    comboEjecutandose = true

    -- Detecta al enemigo más cercano a tu mira (FOV) en este instante
    objetivoActual = obtenerObjetivoFOV()

    -- 1. Portal Z (Abre el combo con la fruta y teletransporte)
    equiparHerramienta(MI_SET.Fruit)
    redireccionarAtaque(objetivoActual)
    waitms(50) pressKey("Z", 0.08) 
    waitms(850)

    -- 2. Soul Guitar X (Dispara la guitarra de inmediato para romper Ken-Esquive)
    equiparHerramienta(MI_SET.Gun)
    redireccionarAtaque(objetivoActual)
    waitms(50) pressKey("X", 0.08) 
    waitms(450)

    -- 3. Sanguine Art Z (Habilidad de levantamiento continuo)
    equiparHerramienta(MI_SET.Melee)
    redireccionarAtaque(objetivoActual)
    waitms(50) pressKey("Z", 0.08) 
    waitms(300)

    -- 4. Sanguine Art C (Ráfaga de garras roba vida)
    redireccionarAtaque(objetivoActual)
    pressKey("C", 0.08) 
    waitms(800)

    -- 5. TTK Z (True Triple Katana - Estocada rápida en suspensión)
    equiparHerramienta(MI_SET.Sword)
    redireccionarAtaque(objetivoActual)
    waitms(50) pressKey("Z", 0.08) 
    waitms(380)

    -- 6. Sanguine Art X (Golpe final de impacto al suelo)
    equiparHerramienta(MI_SET.Melee)
    redireccionarAtaque(objetivoActual)
    waitms(50) pressKey("X", 0.08)

    comboEjecutandose = false
end

-- Botón redondo L del Combo
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
