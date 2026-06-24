local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- CONFIGURACIÓN ULTRA-DESCARADA INVISIBLE (SÓLO PVP JUGADORES)
local rangoMaximoStuds = 150
local camera = workspace.CurrentCamera
local objetivoActual = nil

-- =========================================================
--      NOTIFICACIÓN DE PRUEBA: ALERTA LEGNA (5 SEGUNDOS)
-- =========================================================
local function mostrarAlertaLegna()
    local gui = Instance.new("ScreenGui")
    gui.Name = "LegnaAlert_Gui"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 240, 0, 35)
    label.Position = UDim2.new(0.5, -120, 0, -50) -- Inicia fuera de la pantalla arriba
    label.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    label.BackgroundTransparency = 0.1
    label.Text = "Legna Hub Loaded Successfully!"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = label

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(60, 60, 65)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = label

    -- Animación de entrada (Baja suavemente)
    label:TweenPosition(UDim2.new(0.5, -120, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
    
    -- Espera los 5 segundos de visualización solicitados
    task.wait(5)
    
    -- Animación de salida (Sube y se borra)
    label:TweenPosition(UDim2.new(0.5, -120, 0, -50), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.5, true, function()
        gui:Destroy()
    end)
end

-- Ejecuta la alerta de forma asíncrona en un hilo separado para no trabar el juego
coroutine.wrap(mostrarAlertaLegna)()

-- ALGORITMO EXCLUSIVO: Busca estrictamente al jugador más cercano en el mapa
local function obtenerJugadorMasCercano()
    local personajeLocal = player.Character
    if not personajeLocal or not personajeLocal:FindFirstChild("HumanoidRootPart") then return nil end
    
    local mejorObjetivo = nil
    local menorDistancia = math.huge

    for _, otroPlayer in ipairs(game.Players:GetPlayers()) do
        if otroPlayer ~= player and otroPlayer.Character and otroPlayer.Character:FindFirstChild("HumanoidRootPart") and otroPlayer.Character:FindFirstChildOfClass("Humanoid") then
            if otroPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = otroPlayer.Character.HumanoidRootPart
                local distancia = (personajeLocal.HumanoidRootPart.Position - hrp.Position).Magnitude
                
                if distancia <= rangoMaximoStuds and distancia < menorDistancia then
                    menorDistancia = distancia
                    mejorObjetivo = hrp
                end
            end
        end
    end
    return mejorObjetivo
end

-- =========================================================
--    MONITOR DE ENCLAVAMIENTO RAGE UNIDO AL CANDADO VERDE
-- =========================================================
RunService.RenderStepped:Connect(function()
    -- Detecta de forma nativa el estado del Shift Lock de Roblox móvil
    local success, mouselock = pcall(function()
        return player.PlayerScripts.PlayerModule.CameraModule.MouseLockController:GetIsMouseLocked()
    end)

    -- Si el bloqueo de cámara original de Blox Fruits está activo (El candado verde / El "ajá")
    if (success and mouselock) or camera.CameraMode == Enum.CameraMode.LockFirstPerson then
        objetivoActual = obtenerJugadorMasCercano()
        
        if objetivoActual and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local vel = objetivoActual.Velocity or Vector3.new(0,0,0)
            
            -- Compensación de Ping: Predice la posición del rival para contrarrestar dashes
            local posicionPredicha = objetivoActual.Position + (vel * 0.05)
            
            -- [LOCK CAM DESCARADO] Clava tu mirada frame a frame al oponente sin soltarlo
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, objetivoActual.Position)
            
            -- [AIMBOT CORPORAL] Gira tu cuerpo hacia el oponente al mismo tiempo
            hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(posicionPredicha.X, hrp.Position.Y, posicionPredicha.Z))
        end
    else
        -- Cuando el botón original se vuelve blanco, limpia el objetivo y te da control libre normal
        objetivoActual = nil
    end
end)

print("[BLOX FRUITS] Legna Hub inicializado con exito.")
