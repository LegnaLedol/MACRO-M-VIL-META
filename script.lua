local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- CONFIGURACIÓN DE FIJACIÓN INVISIBLE POR DISTANCIA REAL (PVP)
local objetivoActual = nil
local camera = workspace.CurrentCamera
local RANGO_MAX_STUDS = 160 -- Distancia máxima en bloques en el mapa

-- ALGORITMO COMPETITIVO: Busca estrictamente al jugador más cercano en studs
local function obtenerJugadorMasCercano()
    local personajeLocal = player.Character
    if not personajeLocal or not personajeLocal:FindFirstChild("HumanoidRootPart") then return nil end
    
    local mejorObjetivo = nil
    local menorDistanciaStuds = math.huge

    -- Escanea a todos los jugadores del servidor
    for _, otroPlayer in ipairs(game.Players:GetPlayers()) do
        if otroPlayer ~= player and otroPlayer.Character and otroPlayer.Character:FindFirstChild("HumanoidRootPart") and otroPlayer.Character:FindFirstChildOfClass("Humanoid") then
            if otroPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = otroPlayer.Character.HumanoidRootPart
                -- Calcula la distancia física real en el mapa 3D (No usa FOV de pantalla)
                local distanciaStuds = (personajeLocal.HumanoidRootPart.Position - hrp.Position).Magnitude
                
                -- Filtra y elige al que esté más pegado a ti
                if distanciaStuds <= RANGO_MAX_STUDS and distanciaStuds < menorDistanciaStuds then
                    menorDistanciaStuds = distanciaStuds
                    mejorObjetivo = hrp
                end
            end
        end
    end
    return mejorObjetivo
end
-- =========================================================
--    MONITOR DE ENCLAVAMIENTO AL OBJETIVO MÁS CERCANO
-- =========================================================

RunService.RenderStepped:Connect(function()
    -- Detecta el estado del botón de bloqueo (Shift Lock nativo) de Roblox móvil
    local success, mouselock = pcall(function()
        return player.PlayerScripts.PlayerModule.CameraModule.MouseLockController:GetIsMouseLocked()
    end)

    -- Si el candado del juego está activo (El "ajá")
    if (success and mouselock) or camera.CameraMode == Enum.CameraMode.LockFirstPerson then
        -- Busca al oponente más cercano físicamente en ese frame
        local objetivo = obtenerJugadorMasCercano()
        
        if Corporate and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local vel = objetivo.Velocity or Vector3.new(0, 0, 0)
            
            -- CÁLCULO DE ÁNGULO: Revisa si el oponente más cercano se teletransportó a tu espalda
            local direccionAlObjetivo = (objetivo.Position - hrp.Position).Unit
            local direccionMiradaActual = hrp.LookVector
            local productoPunto = direccionMiradaActual:Dot(direccionAlObjetivo)
            
            -- Posición destino con compensación física para contrarrestar dashes rápidos
            local destinoLook = Vector3.new(objetivo.Position.X + (vel.X * 0.04), hrp.Position.Y, objetivo.Position.Z + (vel.Z * 0.04))
            local cframeDestino = CFrame.lookAt(hrp.Position, destinoLook)
            
            if productoPunto < -0.2 then
                -- [BYPASS HUMANIZADO] Si se teletransporta atrás, gira con fluidez (0.45) para evitar alertas del juego
                hrp.CFrame = hrp.CFrame:Lerp(cframeDestino, 0.45)
            else
                -- [MODO DESCARADO] Si está frente a ti, se ancla al 100% frame a frame sin soltarlo ni un milímetro
                hrp.CFrame = cframeDestino
            end
        end
    else
        -- Si el candado del juego se desactiva (Botón Blanco), se limpia el rastreo por completo
        objetivoActual = nil
    end
end)

print("[GHOUL SYSTEM] Enclavamiento al JUGADOR MÁS CERCANO acoplado al Camera Lock.")
print("[GHOUL SYSTEM] Candado Activo = Anclaje descarado al más cercano. Candado Blanco = Apagado.")
