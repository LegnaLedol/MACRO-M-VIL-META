-- =========================================================
--   REPLICA EXACTA HERMANOS'DEV UI (REDZ LIBRARY CLONE)
--              GHOUL GRAY EDITION v4 - PVP ONLY
-- =========================================================

local RedzLibrary = loadstring(game:HttpGet("https://githubusercontent.com"))()

-- Variable global para la foto flotante de Tokyo Ghoul
local GHOUL_ASSET_ID = "rbxassetid://9073144883"

-- Variables de estado para el PVP Manual
local pvpAimbotActive = false
local lockCamActive = false
local walkSpeedValue = 16

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local camConnection, charConnection

-- ALGORITMO DE HITBOX PROFESIONAL (Filtra solo Jugadores reales en tu campo de visión)
local function obtenerObjetivoPVP()
    local personajeLocal = player.Character
    if not personajeLocal or not personajeLocal:FindFirstChild("HumanoidRootPart") then return nil end
    
    local mejorObjetivo = nil
    local menorDistanciaPantalla = math.huge
    local maxRangoStuds = 150

    for _, otroPlayer in ipairs(game.Players:GetPlayers()) do
        if otroPlayer ~= player and otroPlayer.Character and otroPlayer.Character:FindFirstChild("HumanoidRootPart") and otroPlayer.Character:FindFirstChildOfClass("Humanoid") then
            if otroPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = otroPlayer.Character.HumanoidRootPart
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
    return mejorObjetivo
end

-- CREACIÓN DE LA VENTANA PRINCIPAL (Réplica exacta gris oscuro)
local Window = RedzLibrary:CreateWindow({
    Name = "Hermanos'Dev | PVP",
    SubName = "Blox Fruit | Tokyo Ghoul Ed.",
    Discord = "https://discord.gg" -- Botón de Discord real como en tu foto
})

-- CREACIÓN DE SECCIONES LATERALES (Legit:, Rage:, Utility:)
Window:AddSection({Name = "Legit:"})
local TabGeneral = Window:CreateTab({Name = "General", Icon = "rbxassetid://4483362458"})
local TabCombat = Window:CreateTab({Name = "Combat", Icon = "rbxassetid://4483362458"})
local TabESP = Window:CreateTab({Name = "ESP", Icon = "rbxassetid://4483362458"})

Window:AddSection({Name = "Rage:"})
local TabKeyBind = Window:CreateTab({Name = "Key Bind", Icon = "rbxassetid://4483362458"})
local TabMisc = Window:CreateTab({Name = "Misc", Icon = "rbxassetid://4483362458"})

Window:AddSection({Name = "Utility:"})
local TabServer = Window:CreateTab({Name = "Server", Icon = "rbxassetid://4483362458"})
-- =========================================================
--          CONTENIDO PESTAÑA: PLAYER MODIFIER (GENERAL)
-- =========================================================
TabGeneral:AddSection({Name = "Player Modifier:"})

TabGeneral:AddToggle({
    Name = "Anti Stun",
    Description = "Enable to activate Anti Stun",
    Default = false,
    Callback = function(Value)
        _G.AntiStun = Value
        RunService.Stepped:Connect(function()
            if _G.AntiStun and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                player.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
            end
        end)
    end
})

TabGeneral:AddSlider({
    Name = "Speed Multiply",
    Description = "Multiply the speed of the player",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(Value)
        walkSpeedValue = Value
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end
})

TabGeneral:AddToggle({
    Name = "Speed Boost",
    Description = "Enable to activate Speed Boost",
    Default = false,
    Callback = function(Value)
        _G.SpeedBoost = Value
        RunService.Heartbeat:Connect(function()
            if _G.SpeedBoost and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeedValue
            elseif not _G.SpeedBoost and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
        end)
    end
})

-- =========================================================
--             CONTENIDO PESTAÑA: COMBAT (PVP)
-- =========================================================
TabCombat:AddSection({Name = "PVP Manual Aim Assist:"})

TabCombat:AddToggle({
    Name = "Silent Aim (FOV Directo)",
    Description = "Redirige tus skills manuales al oponente",
    Default = false,
    Callback = function(Value)
        silentAimActive = Value
        if silentAimActive then
            charConnection = RunService.Heartbeat:Connect(function()
                objetivoActual = obtenerObjetivoPVP()
                if objetivoActual and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    local vel = objetivoActual.Velocity or Vector3.new(0,0,0)
                    local lookDestino = Vector3.new(objetivoActual.Position.X + (vel.X * 0.05), hrp.Position.Y, objetivoActual.Position.Z + (vel.Z * 0.05))
                    hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, lookDestino), 0.8)
                end
            end)
        else
            if charConnection then charConnection:Disconnect() charConnection = nil end
        end
    end
})

TabCombat:AddToggle({
    Name = "Lock Camera (Lerp)",
    Description = "Fija tu mirada en el oponente de forma fluida",
    Default = false,
    Callback = function(Value)
        lockCamActive = Value
        if lockCamActive then
            camConnection = RunService.RenderStepped:Connect(function()
                local objetivo = obtenerObjetivoPVP()
                if objetivo then
                    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, objetivo.Position), 0.22)
                end
            end)
        else
            if camConnection then camConnection:Disconnect() camConnection = nil end
        end
    end
})

-- =========================================================
--      SISTEMA TOGGLE FLOTANTE REAL: FOTO TOKYO GHOUL
-- =========================================================
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "GhoulToggle_Gui"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = player:WaitForChild("PlayerGui")

local toggleIcon = Instance.new("ImageButton")
toggleIcon.Size = UDim2.new(0, 45, 0, 45)
toggleIcon.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
toggleIcon.Image = GHOUL_ASSET_ID
toggleIcon.Active = true
toggleIcon.Draggable = true
toggleIcon.Parent = toggleGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent = toggleIcon

local iconStroke = Instance.new("UIStroke")
iconStroke.Thickness = 1.8
iconStroke.Color = Color3.fromRGB(70, 70, 75)
iconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
iconStroke.Parent = toggleIcon

-- Conexión física para esconder/mostrar el menú oficial de Redz
toggleIcon.TouchTap:Connect(function()
    -- Comando nativo de Redz Library para alternar la visibilidad de su Main Frame
    if game.CoreGui:FindFirstChild("Hermanos'Dev | PVP") then
        local mainUI = game.CoreGui["Hermanos'Dev | PVP"]:FindFirstChild("Main") or game.CoreGui["Hermanos'Dev | PVP"]:FindFirstChildOfClass("Frame")
        if mainUI then
            mainUI.Visible = not mainUI.Visible
        end
    elseif player.PlayerGui:FindFirstChild("Hermanos'Dev | PVP") then
        local mainUI = player.PlayerGui["Hermanos'Dev | PVP"]:FindFirstChild("Main") or player.PlayerGui["Hermanos'Dev | PVP"]:FindFirstChildOfClass("Frame")
        if mainUI then
            mainUI.Visible = not mainUI.Visible
        end
    end
end)
