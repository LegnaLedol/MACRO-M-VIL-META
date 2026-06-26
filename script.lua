-- =============================================================================
-- LEGNA HUB v3.0 - PREMIUM EDITION (MOBILE OPTIMIZED)
-- BLOQUE 1: NÚCLEO, CONFIGURACIÓN PERSISTENTE Y SISTEMA SELF-HEAL
-- =============================================================================

-- // EVITAR DUPLICADOS EN LA EJECUCIÓN
if _G.LegnaLoaded then 
    print("[LEGNA HUB]: El script ya está corriendo en segundo plano.")
    return 
end
_G.LegnaLoaded = true

-- // SERVICIOS CRÍTICOS DE ROBLOX
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // CONFIGURACIÓN MAESTRA GLOBAL (Con valores predeterminados de fábrica)
_G.LegnaConfig = {
    -- Estado de Funciones
    AimbotEnabled = false,
    SilentAimEnabled = true,
    GunAimEnabled = true,
    PredictionEnabled = true,
    PredictionVelocity = 1.35,
    TargetPart = "HumanoidRootPart",
    FovRadius = 250,
    MaxDistance = 600,
    
    -- Automatizaciones
    SmartKen = true,
    AutoBuso = true,
    AutoSoru = true,
    DashEvade = true,
    GhostMode = false,
    
    -- Visuales / ESP
    ESP = {
        Enabled = true,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        FruitTracker = true,
        NightMode = false
    },
    
    -- Memoria de Posición Táctil (Botones Flotantes)
    Positions = {
        GemaL = {X = 0.05, Y = 0.2},
        LockCam = {X = 0.1, Y = 0.4},
        MacroM = {X = 0.1, Y = 0.55}
    }
}

-- // HISTORIAL DE LA CONSOLA DE DESARROLLADOR (Estructura interna)
_G.ConsoleLogs = {}
local MaxConsoleLogs = 50

-- // FUNCIÓN DELTA: REGISTRAR LOGS CON CÓDIGO DE COLORES (Para la UI posterior)
local function LogMessage(type, text)
    local timestamp = os.date("%X")
    local formattedText = string.format("[%s] [%s]: %s", timestamp, string.upper(type), text)
    
    table.insert(_G.ConsoleLogs, {Type = type, Text = formattedText})
    if #_G.ConsoleLogs > MaxConsoleLogs then
        table.remove(_G.ConsoleLogs, 1)
    end
    
    -- Imprimir en la consola nativa del ejecutor para verificación inicial
    if type == "error" then
        warn("🔴 " .. formattedText)
    elseif type == "heal" then
        print("🔵 " .. formattedText)
    elseif type == "warn" then
        warn("🟡 " .. formattedText)
    else
        print("🟢 " .. formattedText)
    end
end

-- // ENTORNO SEGURO CON AUTOCORRECCIÓN (Cerebro del Self-Heal)
_G.SafeExecute = function(func, sectionName)
    local success, err = pcall(func)
    if not success then
        LogMessage("error", "Falla en " .. sectionName .. " -> " .. tostring(err))
        
        -- Intentar autoreparación (Bucle de recuperación inteligente)
        task.spawn(function()
            LogMessage("heal", "Iniciando protocolo de autoreparación en: " .. sectionName)
            task.wait(0.5)
            local retrySuccess, retryErr = pcall(func)
            if retrySuccess then
                LogMessage("heal", "Módulo " .. sectionName .. " restaurado con éxito.")
            else
                LogMessage("warn", "No se pudo auto-reparar " .. sectionName .. ". Reintentando en background.")
            end
        end)
    end
    return success
end

-- // GESTOR DE ARCHIVOS JSON LOCALES (Config Manager)
local ConfigFileName = "LegnaHub_v3_Config.json"

local function SaveSettings()
    _G.SafeExecute(function()
        if writefile then
            local jsonConfig = HttpService:JSONEncode(_G.LegnaConfig)
            writefile(ConfigFileName, jsonConfig)
        end
    end, "ConfigManager (Save)")
end

local function LoadSettings()
    _G.SafeExecute(function()
        if readfile and isfile and isfile(ConfigFileName) then
            local rawConfig = readfile(ConfigFileName)
            local decodedConfig = HttpService:JSONDecode(rawConfig)
            
            -- Fusión segura para evitar pérdida de datos si añadimos opciones después
            for key, value in pairs(decodedConfig) do
                if type(value) == "table" then
                    for subKey, subValue in pairs(value) do
                        _G.LegnaConfig[key][subKey] = subValue
                    end
                else
                    _G.LegnaConfig[key] = value
                end
            end
            LogMessage("info", "Configuración guardada cargada correctamente.")
        else
            LogMessage("warn", "No se encontró archivo de configuración. Usando valores de fábrica.")
        end
    end, "ConfigManager (Load)")
end

-- Ejecutar la carga inicial de datos persistentes
LoadSettings()

-- // SISTEMA DE MONITOREO EN TIEMPO REAL (Server Metrics)
_G.ServerMetrics = {
    FPS = 60,
    Ping = 0,
    Region = "Detectando...",
    Age = 0
}

-- Calcular FPS y Ping frame por frame de forma asíncrona
task.spawn(function()
    local lastIteration = os.clock()
    local frameHistory = {}
    
    -- Detectar Región aproximada por el huso horario o IP simulada del servidor
    _G.SafeExecute(function()
        local localizationService = game:GetService("LocalizationService")
        local success, code = pcall(function() return localizationService.RobloxLocaleId end)
        if success and code then
            _G.ServerMetrics.Region = string.upper(string.sub(code, 6, 7)) or "Desconocida"
        else
            _G.ServerMetrics.Region = "Server Global"
        end
    end, "ServerMetrics (Region Deteccion)")

    -- Bucle infinito controlado sin lag (Heartbeat)
    RunService.Heartbeat:Connect(function()
        _G.SafeExecute(function()
            -- Cálculo preciso de FPS
            local currentTime = os.clock()
            local currentFPS = 1 / (currentTime - lastIteration)
            lastIteration = currentTime
            
            table.insert(frameHistory, currentFPS)
            if #frameHistory > 60 then table.remove(frameHistory, 1) end
            
            local fpsSum = 0
            for _, fpsValue in pairs(frameHistory) do fpsSum = fpsSum + fpsValue end
            _G.ServerMetrics.FPS = math.floor(fpsSum / #frameHistory)
            
            -- Cálculo de Ping real de red de Roblox
            local networkStats = Stats:FindFirstChild("Network")
            if networkStats then
                local serverStats = networkStats:FindFirstChild("ServerStatsItem")
                if serverStats then
                    _G.ServerMetrics.Ping = math.floor(serverStats:GetValue())
                else
                    -- Alternativa nativa si el ejecutor bloquea ServerStats
                    _G.ServerMetrics.Ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
                end
            end
            
            -- Calcular edad del servidor
            _G.ServerMetrics.Age = math.floor(Workspace.DistributedGameTime / 3600)
        end, "ServerMetrics (Bucle de Rendimiento)")
    end)
end)

-- Marcar inicialización exitosa del núcleo
LogMessage("info", "Núcleo de LEGNA HUB v3.0 inicializado perfectamente.")
-- =============================================================================
-- LEGNA HUB v3.0 - PREMIUM EDITION (MOBILE OPTIMIZED)
-- BLOQUE 2: GATILLOS FLOTANTES CON MEMORIA Y ARRASTRE TÁCTIL MÓVIL
-- =============================================================================

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- // CREACIÓN CONTENEDOR PRINCIPAL SEGURO
local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "LegnaFloatingButtons_v3"
FloatingGui.ResetOnSpawn = false

-- Proteger interfaz en ejecutores premium que lo soporten
if syn and syn.protect_gui then syn.protect_gui(FloatingGui) end
FloatingGui.Parent = CoreGui

-- // VARIABLES DE DISEÑO (ESTILO PREMIUM DARK NEÓN)
local ColorOscuro = Color3.fromRGB(15, 15, 15)
local ColorRojoNeon = Color3.fromRGB(255, 60, 60)
local ColorCianNeon = Color3.fromRGB(0, 255, 255)
local ColorVerdeNeon = Color3.fromRGB(0, 255, 150)

-- // FUNCIÓN MAESTRA: APLICAR FÍSICA DE ARRASTRE MÓVIL Y GUARDADO AUTOMÁTICO
local function MakeButtonDraggable(ButtonInstance, ConfigKey)
    local Dragging = false
    local DragInput, DragStart, StartPosition

    ButtonInstance.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not _G.LegnaConfig.GhostMode then
            Dragging = true
            DragStart = input.Position
            StartPosition = ButtonInstance.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    -- GUARDAR POSICIÓN AL SOLTAR EL BOTÓN
                    _G.SafeExecute(function()
                        _G.LegnaConfig.Positions[ConfigKey].X = ButtonInstance.Position.X.Scale
                        _G.LegnaConfig.Positions[ConfigKey].Y = ButtonInstance.Position.Y.Scale
                        if writefile then
                            writefile("LegnaHub_v3_Config.json", HttpService:JSONEncode(_G.LegnaConfig))
                        end
                    end, "Guardar Posicion Táctil: " .. ConfigKey)
                end
            end)
        end
    end)

    ButtonInstance.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            ButtonInstance.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        end
    end)
end

-- // FUNCIÓN MATEMÁTICA: CONTROL DE LÍMITES DE PANTALLA (ANTI-BUGEO)
local function GetSafePosition(ConfigKey, DefaultX, DefaultY)
    local SavedPos = _G.LegnaConfig.Positions[ConfigKey]
    
    -- Si los datos están corruptos o fuera del rango seguro (0.0 a 1.0)
    if not SavedPos or type(SavedPos.X) ~= "number" or type(SavedPos.Y) ~= "number" or 
       SavedPos.X < 0 or SavedPos.X > 1 or SavedPos.Y < 0 or SavedPos.Y > 1 then
        
        -- Reiniciar coordenadas a valores originales de fábrica
        _G.LegnaConfig.Positions[ConfigKey] = {X = DefaultX, Y = DefaultY}
        return UDim2.new(DefaultX, 0, DefaultY, 0)
    end
    
    return UDim2.new(SavedPos.X, 0, SavedPos.Y, 0)
end

-- =============================================================================
-- 1. CREACIÓN: GEMA "L" FLOTANTE (APERTURA DEL SCRIPT)
-- =============================================================================
local GemaL = Instance.new("TextButton")
GemaL.Name = "GemaL"
GemaL.Size = UDim2.new(0, 50, 0, 50)
GemaL.Position = GetSafePosition("GemaL", 0.05, 0.2)
GemaL.BackgroundColor3 = ColorOscuro
GemaL.Text = "L"
GemaL.TextColor3 = Color3.fromRGB(255, 255, 255)
GemaL.TextSize = 22
GemaL.Font = Enum.Font.GothamBold
GemaL.BorderSizePixel = 0
GemaL.Parent = FloatingGui

local GemaCorner = Instance.new("UICorner")
GemaCorner.CornerRadius = UDim.new(1, 0) -- Círculo perfecto
GemaCorner.Parent = GemaL

local GemaStroke = Instance.new("UIStroke")
GemaStroke.Thickness = 2
GemaStroke.Color = ColorCianNeon
GemaStroke.Parent = GemaL

MakeButtonDraggable(GemaL, "GemaL")

-- Animación de Respiración Lenta (Idle Effect)
task.spawn(function()
    while FloatingGui.Parent do
        if not _G.LegnaConfig.GhostMode then
            local Tween1 = TweenService:Create(GemaStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.8})
            Tween1:Play()
            Tween1.Completed:Wait()
            local Tween2 = TweenService:Create(GemaStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0})
            Tween2:Play()
            Tween2.Completed:Wait()
        else
            task.wait(1)
        end
    end
end)

-- =============================================================================
-- 2. CREACIÓN: BOTÓN LOCK CAM INDEPENDIENTE
-- =============================================================================
local LockCamBtn = Instance.new("TextButton")
LockCamBtn.Name = "LockCamBtn"
LockCamBtn.Size = UDim2.new(0, 110, 0, 45)
LockCamBtn.Position = GetSafePosition("LockCam", 0.1, 0.4)
LockCamBtn.BackgroundColor3 = ColorOscuro
LockCamBtn.Text = "LOCK OFF ❌"
LockCamBtn.TextColor3 = ColorRojoNeon
LockCamBtn.TextSize = 13
LockCamBtn.Font = Enum.Font.GothamBold
LockCamBtn.BorderSizePixel = 0
LockCamBtn.Parent = FloatingGui

local LockCorner = Instance.new("UICorner")
LockCorner.CornerRadius = UDim.new(0, 12)
LockCorner.Parent = LockCamBtn

local LockStroke = Instance.new("UIStroke")
LockStroke.Thickness = 2
LockStroke.Color = ColorRojoNeon
LockStroke.Parent = LockCamBtn

MakeButtonDraggable(LockCamBtn, "LockCam")

-- Lógica Interactiva del Toggle del LockCam
LockCamBtn.MouseButton1Click:Connect(function()
    if _G.LegnaConfig.GhostMode then return end
    
    _G.LegnaConfig.AimbotEnabled = not _G.LegnaConfig.AimbotEnabled
    
    -- Animación de Elasticidad al presionar (Pop Effect)
    LockCamBtn:TweenSize(UDim2.new(0, 100, 0, 40), "Out", "Quad", 0.05, true, function()
        LockCamBtn:TweenSize(UDim2.new(0, 110, 0, 45), "Out", "Elastic", 0.15, true)
    end)

    if _G.LegnaConfig.AimbotEnabled then
        LockCamBtn.Text = "LOCK ON ✅"
        LockCamBtn.TextColor3 = ColorVerdeNeon
        LockStroke.Color = ColorVerdeNeon
    else
        LockCamBtn.Text = "LOCK OFF ❌"
        LockCamBtn.TextColor3 = ColorRojoNeon
        LockStroke.Color = ColorRojoNeon
    end
end)

-- =============================================================================
-- 3. CREACIÓN: BOTÓN MACRO "M" INDEPENDIENTE
-- =============================================================================
local MacroMBtn = Instance.new("TextButton")
MacroMBtn.Name = "MacroMBtn"
MacroMBtn.Size = UDim2.new(0, 50, 0, 50)
MacroMBtn.Position = GetSafePosition("MacroM", 0.1, 0.55)
MacroMBtn.BackgroundColor3 = ColorOscuro
MacroMBtn.Text = "M"
MacroMBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MacroMBtn.TextSize = 22
MacroMBtn.Font = Enum.Font.GothamBold
MacroMBtn.BorderSizePixel = 0
MacroMBtn.Parent = FloatingGui

local MacroCorner = Instance.new("UICorner")
MacroCorner.CornerRadius = UDim.new(1, 0) -- Redondo perfecto
MacroCorner.Parent = MacroMBtn

local MacroStroke = Instance.new("UIStroke")
MacroStroke.Thickness = 2
MacroStroke.Color = Color3.fromRGB(230, 230, 230) -- Borde blanco grueso de fábrica
MacroStroke.Parent = MacroMBtn

MakeButtonDraggable(MacroMBtn, "MacroM")

-- Interacción del Botón Macro (La lógica de ejecución irá en el módulo de combate)
MacroMBtn.MouseButton1Click:Connect(function()
    if _G.LegnaConfig.GhostMode then return end
    
    -- Animación Pop 3D táctil
    MacroMBtn:TweenSize(UDim2.new(0, 42, 0, 42), "Out", "Quad", 0.05, true, function()
        MacroMBtn:TweenSize(UDim2.new(0, 50, 0, 50), "Out", "Elastic", 0.15, true)
    end)
    
    -- Disparar evento global para indicar que la macro fue presionada táctilmente
    _G.MacroClicked = true
    task.delay(0.1, function() _G.MacroClicked = false end)
end)

-- =============================================================================
-- MONITOR DE INTEGRIDAD Y RECEPTOR DE GHOST MODE
-- =============================================================================
RunService.Heartbeat:Connect(function()
    _G.SafeExecute(function()
        -- Control del Modo Fantasma en tiempo real para Transmisiones
        if _G.LegnaConfig.GhostMode then
            GemaL.Visible = false
            LockCamBtn.Visible = false
            MacroMBtn.Visible = false
        else
            GemaL.Visible = true
            LockCamBtn.Visible = true
            MacroMBtn.Visible = true
        end
    end, "FloatingButtons (Ghost Monitor)")
end)

print("[LEGNA HUB]: Bloque 2 (Gatillos Flotantes) cargado y posicionado de forma segura.")
-- =============================================================================
-- LEGNA HUB v3.0 - PREMIUM EDITION (MOBILE OPTIMIZED)
-- BLOQUE 3: INGENIERÍA DE COMBATE, METATABLAS (SILENT/GUN AIM) Y PREDICCIÓN 2.0
-- =============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // DIBUJAR CÍRCULO FOV VISUAL (API Drawing Nativa)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 255) -- Cian Neón
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Radius = _G.LegnaConfig.FovRadius
FOVCircle.Visible = true

-- // FUNCIÓN MATEMÁTICA: OBTENER EL OBJETIVO MÁS CERCANO AL CENTRO DE LA PANTALLA
local function GetClosestTarget()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge
    local CenterScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(_G.LegnaConfig.TargetPart) then
            local Character = Player.Character
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            
            -- Verificar que el rival esté vivo y tenga vida real
            if Humanoid and Humanoid.Health > 0 then
                local TargetPart = Character[_G.LegnaConfig.TargetPart]
                local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                
                if OnScreen then
                    -- Calcular distancia en píxeles desde el centro de la pantalla táctil
                    local ScreenDistance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - CenterScreen).Magnitude
                    
                    -- Verificar distancia física real entre los modelos 3D
                    local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if MyRoot then
                        local PhysicalDistance = (TargetPart.Position - MyRoot.Position).Magnitude
                        
                        -- Filtrar que esté dentro del círculo FOV y del rango en metros
                        if ScreenDistance < _G.LegnaConfig.FovRadius and PhysicalDistance < _G.LegnaConfig.MaxDistance then
                            if ScreenDistance < ShortestDistance then
                                ShortestDistance = ScreenDistance
                                ClosestPlayer = Player
                            end
                        end
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

-- // BUCLE DE RENDERIZADO: LOCK CAM, PREDICCIÓN Y ACTUALIZACIÓN FOV
RunService.RenderStepped:Connect(function()
    _G.SafeExecute(function()
        -- Sincronizar radio y visibilidad del FOV según Ghost Mode
        FOVCircle.Radius = _G.LegnaConfig.FovRadius
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Visible = (not _G.LegnaConfig.GhostMode and _G.LegnaConfig.AimbotEnabled)

        -- Si el Lock Cam flotante está activo, clavar la cámara físicamente
        if _G.LegnaConfig.AimbotEnabled and LocalPlayer.Character then
            local Target = GetClosestTarget()
            if Target and Target.Character and Target.Character:FindFirstChild(_G.LegnaConfig.TargetPart) then
                local TargetPart = Target.Character[_G.LegnaConfig.TargetPart]
                local TargetPosition = TargetPart.Position
                
                -- Aplicación de Prediction 2.0 mediante Vectores de Velocidad Lineal
                if _G.LegnaConfig.PredictionEnabled then
                    local Velocity = TargetPart.AssemblyLinearVelocity
                    TargetPosition = TargetPosition + (Velocity * (_G.LegnaConfig.PredictionVelocity / 10))
                end
                
                -- Rotación directa de cámara para evitar pérdidas de tracking con frutas rápidas
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPosition)
            end
        end
    end, "CombatModule (RenderStepped LockCam)")
end)

-- // INTERCEPCIÓN HOOK METAMETHOD: __INDEX (ENGAÑO DE CURSOR PARA ARMAS / GUN AIM)
local IndexHook
IndexHook = hookmetamethod(game, "__index", function(Self, Key)
    if _G.LegnaConfig.SilentAimEnabled and not checkcaller() and (Self == Mouse) then
        local Target = GetClosestTarget()
        if Target and Target.Character and Target.Character:FindFirstChild(_G.LegnaConfig.TargetPart) then
            local TargetPart = Target.Character[_G.LegnaConfig.TargetPart]
            local TargetPosition = TargetPart.Position
            
            if _G.LegnaConfig.PredictionEnabled then
                TargetPosition = TargetPosition + (TargetPart.AssemblyLinearVelocity * (_G.LegnaConfig.PredictionVelocity / 10))
            end
            
            -- Si el script del arma pide las coordenadas de tu dedo (Hit o Target), le devolvemos al enemigo
            if Key == "Hit" or Key == "HitCFrame" then
                return CFrame.new(TargetPosition)
            elseif Key == "Target" then
                return TargetPart
            end
        end
    end
    return IndexHook(Self, Key)
end)

-- // INTERCEPCIÓN HOOK METAMETHOD: __NAMECALL (REDIRECCIÓN TOTAL DE CLICKS Y EVENTOS REMOTOS)
local NamecallHook
NamecallHook = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if _G.SilentAimEnabled and not checkcaller() then
        -- 1. Redirección de Raycasts nativos del motor gráfico
        if Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRay" or Method == "Raycast" then
            local Target = GetClosestTarget()
            if Target and Target.Character and Target.Character:FindFirstChild(_G.LegnaConfig.TargetPart) then
                return Target.Character[_G.LegnaConfig.TargetPart], Target.Character[_G.LegnaConfig.TargetPart].Position, Vector3.new(0,1,0), Target.Character[_G.LegnaConfig.TargetPart].Material
            end
        end
        
        -- 2. Manipulación masiva de argumentos de red (Blox Fruits Remote Bypass)
        if Method == "FireServer" or Method == "InvokeServer" then
            local Target = GetClosestTarget()
            if Target and Target.Character and Target.Character:FindFirstChild(_G.LegnaConfig.TargetPart) then
                local TargetPosition = Target.Character[_G.LegnaConfig.TargetPart].Position
                
                if _G.LegnaConfig.PredictionEnabled then
                    TargetPosition = TargetPosition + (Target.Character[_G.LegnaConfig.TargetPart].AssemblyLinearVelocity * (_G.LegnaConfig.PredictionVelocity / 10))
                end
                
                -- Rastrear cualquier Vector3 o CFrame enviado por la habilidad al servidor y forzar el objetivo
                for i, arg in pairs(Args) do
                    if typeof(arg) == "Vector3" then
                        Args[i] = TargetPosition
                    elseif typeof(arg) == "CFrame" then
                        Args[i] = CFrame.new(TargetPosition)
                    end
                end
            end
        end
    end
    return NamecallHook(Self, unpack(Args))
end)

-- // SISTEMA DE DISPARO DEL GATILLO "M" (Macro Ejecutor Automatizado)
RunService.Heartbeat:Connect(function()
    if _G.MacroClicked then
        _G.MacroClicked = false -- Resetear gatillo inmediatamente
        
        _G.SafeExecute(function()
            local Target = GetClosestTarget()
            -- Solo suelta el combo ráfaga si hay un enemigo válido en rango de PvP
            if Target then
                -- Lista default de habilidades de Blox Fruits (Se controlará con los toggles de la UI)
                local SkillsToPress = {"Z", "X", "C", "V"}
                
                task.spawn(function()
                    for _, Skill in pairs(SkillsToPress) do
                        -- Simular pulsación de tecla virtual limpia a nivel de hardware móvil
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[Skill], false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[Skill], false, game)
                        task.wait(0.15) -- Retraso óptimo entre ráfagas para evitar bloqueos del juego
                    end
                end)
            end
        end, "CombatModule (Macro Trigger)")
    end
end)

print("[LEGNA HUB]: Bloque 3 (Módulo de Combate Avanzado e Intercepción) inyectado perfectamente.")
-- =============================================================================
-- LEGNA HUB v3.0 - PREMIUM EDITION (MOBILE OPTIMIZED)
-- BLOQUE 4 - PARTE 1: ENTORNO DE ESCAPE Y MOTOR DE DASH EVADE ORGÁNICO
-- =============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- // VARIABLES INTERNAS DE TRABAJO (ANTI-SPAM)
local Evading = false
local LastEvadeTime = 0
local EvadeCooldown = 3 -- Segundos de enfriamiento antes de poder volver a evadir

-- // FUNCIÓN DELTA: ENCONTRAR ENEMIGO CERCANO EN RANGO DE COMBATE
local function GetNearbyEnemy(maxDistance)
    local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local Distance = (Player.Character.HumanoidRootPart.Position - MyRoot.Position).Magnitude
                if Distance < maxDistance then
                    return Player
                end
            end
        end
    end
    return nil
end

-- // ENTORNO DE ESCAPE: LÓGICA DE DASH EVADE ORGÁNICO HUMANIZADO
local function ExecuteOrganicEvade(Character, Humanoid)
    if Evading or (os.clock() - LastEvadeTime) < EvadeCooldown then return end
    Evading = true
    LastEvadeTime = os.clock()
    
    _G.SafeExecute(function()
        -- RETRASO DE REACCIÓN HUMANA (Simula el tiempo que tarda tu pulgar tras notar el golpe)
        local HumanDelay = math.random(12, 22) / 100
        task.wait(HumanDelay)
        
        local MyRoot = Character:FindFirstChild("HumanoidRootPart")
        local Enemy = GetNearbyEnemy(35) -- Buscar si hay alguien cerca pegándonos
        
        if MyRoot and Enemy and Enemy.Character and Enemy.Character:FindFirstChild("HumanoidRootPart") then
            local EnemyRoot = Enemy.Character.HumanoidRootPart
            
            -- Calcular vector en diagonal / semicírculo opuesto a la mirada del rival (Flanqueo)
            local DirectionToEnemy = (EnemyRoot.Position - MyRoot.Position).Unit
            local EscapeDirection = (CFrame.new(Vector3.zero, DirectionToEnemy) * CFrame.Angles(0, math.rad(math.random(120, 150)), 0)).LookVector
            
            -- FILTRO ANTI-PAREDES (Raycast rápido para no quedar corriendo contra un muro)
            local RayParam = RaycastParams.new()
            RayParam.FilterDescendantsInstances = {Character, Enemy.Character}
            RayParam.FilterType = Enum.RaycastFilterType.Exclude
            
            local WallCheck = Workspace:Raycast(MyRoot.Position, EscapeDirection * 15, RayParam)
            if WallCheck then
                -- Si hay un obstáculo, invertir el ángulo hacia la zona que esté abierta
                EscapeDirection = (CFrame.new(Vector3.zero, DirectionToEnemy) * CFrame.Angles(0, math.rad(math.random(-150, -120)), 0)).LookVector
            end
            
            -- MÁXIMO DOS DASHES NATIVOS DE ESCAPE EN LÓGICA DE FÍSICA ORGÁNICA
            for dashCount = 1, 2 do
                if Humanoid.Health > 0 and Humanoid.Health / Humanoid.MaxHealth < 0.3 then
                    -- Modificar de forma limpia el MoveDirection nativo del motor de Roblox
                    Humanoid:Move(EscapeDirection * 10, true)
                    
                    -- Activar la pulsación virtual del Dash oficial del juego (Tecla Q)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                    
                    -- CURVA DE DESACELERACIÓN SUAVE (Simula la fricción de frenado humano)
                    for i = 1, 5 do
                        local LerpSpeed = 1 - (i / 5)
                        Humanoid:Move(EscapeDirection * (LerpSpeed * 5), true)
                        task.wait(0.02)
                    end
                    task.wait(0.2) -- Micro-pausa orgánica entre esquives para no alarmar al juego
                end
            end
        end
    end, "Automatizaciones (Dash Evade Motor)")
    
    Evading = false
end

-- BUCLE DE CONEXIÓN CON EL ESCAPE CRÍTICO
RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if Character and Humanoid and Humanoid.Health > 0 then
        -- Monitor activo del Dash Evade Inteligente al llegar al 30% de Vida
        if _G.LegnaConfig.DashEvade and (Humanoid.Health / Humanoid.MaxHealth) < 0.30 then
            task.spawn(ExecuteOrganicEvade, Character, Humanoid)
        end
    end
end)

print("[LEGNA HUB]: Bloque 4 - Parte 1 (Motor de Dash Evade Orgánico) inyectado correctamente.")
-- =============================================================================
-- LEGNA HUB v3.0 - PREMIUM EDITION (MOBILE OPTIMIZED)
-- BLOQUE 4 - PARTE 2: HAKIS INTELIGENTES Y AUTO SORU TÁCTICO
-- =============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- // REPETICIÓN LOCAL DE FUNCIÓN DE BÚSQUEDA PARA INDEPENDENCIA DE BLOQUE
local function GetNearbyEnemy(maxDistance)
    local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return nil end
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local Distance = (Player.Character.HumanoidRootPart.Position - MyRoot.Position).Magnitude
                if Distance < maxDistance then
                    return Player
                end
            end
        end
    end
    return nil
end

-- =============================================================================
-- 2. LÓGICA: SMART KEN HAKI (FILTRO CRÍTICO ANTI-DESPERDICIO DE ESQUIVES)
-- =============================================================================
local function ManageSmartKen(Character, Humanoid)
    if not _G.LegnaConfig.SmartKen then return end
    
    _G.SafeExecute(function()
        local MyRoot = Character:FindFirstChild("HumanoidRootPart")
        local Enemy = GetNearbyEnemy(45)
        
        if MyRoot and Enemy then
            -- Condición A: Detección de Stun (Tu joystick se mueve pero tu velocidad física es cero)
            local IsStunned = (MyRoot.AssemblyLinearVelocity.Magnitude < 0.5 and Humanoid.MoveDirection.Magnitude > 0)
            
            -- Condición B: Escaneo tridimensional de hitbox/proyectiles pesados enemigos en 12 metros
            local DangerousAttack = false
            local Hitboxes = Workspace:GetPartBoundsInRadius(MyRoot.Position, 12)
            
            for _, Part in pairs(Hitboxes) do
                if Part:IsDescendantOf(Enemy.Character) and (string.find(string.lower(Part.Name), "hitbox") or string.find(string.lower(Part.Name), "ability") or string.find(string.lower(Part.Name), "attack")) then
                    DangerousAttack = true
                    break
                end
            end
            
            -- Encendido quirúrgico (Tecla E)
            local ActiveHaki = Character:FindFirstChild("HasBuso")
            if (IsStunned or DangerousAttack) and not ActiveHaki then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        else
            -- Apagado táctico automático si el peligro se aleja para recargar tus esquives
            local ActiveKen = Character:FindFirstChild("ObservationHaki") or Character:FindFirstChild("KenHaki")
            if ActiveKen then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end
    end, "SmartKenHaki Engine")
end

-- =============================================================================
-- 3. LÓGICA: AUTO BUSO HAKI (ARMADURA DE DAÑO INTEGRAL AUTOMÁTICA)
-- =============================================================================
local function ManageAutoBuso(Character)
    if not _G.LegnaConfig.AutoBuso then return end
    
    _G.SafeExecute(function()
        local HasWeapon = Character:FindFirstChildOfClass("Tool")
        local ActiveBuso = Character:FindFirstChild("HasBuso") or Character:FindFirstChild("BusoHaki")
        
        -- Se activa solo si apuntas a alguien o tienes espada/estilo de pelea en la mano (Tecla J)
        if (_G.LegnaConfig.AimbotEnabled or HasWeapon) and not ActiveBuso then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.J, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.J, false, game)
        end
    end, "AutoBuso Engine")
end

-- =============================================================================
-- 4. LÓGICA: AUTO SORU PREDICTIVO (PERSECUCIÓN HUMANA FLUIDA)
-- =============================================================================
local function ManageAutoSoru(Character)
    if not _G.LegnaConfig.AutoSoru then return end
    
    _G.SafeExecute(function()
        local MyRoot = Character:FindFirstChild("HumanoidRootPart")
        local Enemy = GetNearbyEnemy(40)
        
        if MyRoot and Enemy and Enemy.Character and Enemy.Character:FindFirstChild("HumanoidRootPart") then
            local EnemyHumanoid = Enemy.Character:FindFirstChildOfClass("Humanoid")
            
            -- Si el oponente está herido (menos del 25% de salud) e intenta huir corriendo
            if EnemyHumanoid and EnemyHumanoid.Health / EnemyHumanoid.MaxHealth < 0.25 and EnemyHumanoid.MoveDirection.Magnitude > 0 then
                local EnemyRoot = Enemy.Character.HumanoidRootPart
                local Distance = (EnemyRoot.Position - MyRoot.Position).Magnitude
                
                -- Teletransporte nativo oficial de carrera (Tecla R) para alcanzarlo e impactar el combo
                if Distance > 18 then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                end
            end
        end
    end, "AutoSoru Engine")
end

-- // ENLACE MAESTRO CON EL HILO ASÍNCRONO DE CONTROL DE ENTORNO
RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
    if Character and Humanoid and Humanoid.Health > 0 then
        task.spawn(ManageSmartKen, Character, Humanoid)
        task.spawn(ManageAutoBuso, Character)
        task.spawn(ManageAutoSoru, Character)
    end
end)

print("[LEGNA HUB]: Bloque 4 - Parte 2 (Hakis Inteligentes y Control Táctico) cargado perfectamente.")
-- =============================================================================
-- LEGNA HUB v3.0 - PREMIUM EDITION (MOBILE OPTIMIZED)
-- BLOQUE 5: VISUALES AVANZADOS, ESP CROMÁTICO Y BUSCADOR DE FRUTAS (FRUIT TRACKER)
-- =============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- // VARIABLES DE COLOR PREMIUM
local ColorCian = Color3.fromRGB(0, 255, 255)
local ColorNaranja = Color3.fromRGB(255, 128, 0)
local ColorRojo = Color3.fromRGB(255, 60, 60)
local ColorFruta = Color3.fromRGB(255, 0, 255) -- Magenta brillante para frutas

-- =============================================================================
-- 1. SISTEMA DE ESP COMPLETO PARA JUGADORES (CROMÁTICO + TEXTOS NEÓN)
-- =============================================================================
local function CrearESP(Player)
    if Player == LocalPlayer then return end

    local function CharacterAdded(Character)
        -- Limpieza de interfaces antiguas para evitar duplicados y lag
        if Character:FindFirstChild("LEGNA_ESP_GUI") then Character.LEGNA_ESP_GUI:Destroy() end
        if Character:FindFirstChild("LEGNA_ESP_HL") then Character.LEGNA_ESP_HL:Destroy() end

        -- Contorno de color GPU nativo (Highlight)
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "LEGNA_ESP_HL"
        Highlight.FillTransparency = 0.6
        Highlight.OutlineTransparency = 0
        Highlight.Adornee = Character
        Highlight.Parent = Character

        -- Interfaz flotante de Texto en la cabeza (BillboardGui)
        local Billboard = Instance.new("BillboardGui")
        Billboard.Name = "LEGNA_ESP_GUI"
        Billboard.Size = UDim2.new(0, 200, 0, 50)
        Billboard.AlwaysOnTop = true
        Billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        Billboard.Adornee = Character:WaitForChild("HumanoidRootPart", 5)
        Billboard.Parent = Character

        local InfoText = Instance.new("TextLabel")
        InfoText.Size = UDim2.new(1, 0, 1, 0)
        InfoText.BackgroundTransparency = 1
        InfoText.TextColor3 = ColorCian
        InfoText.TextSize = 13
        InfoText.Font = Enum.Font.GothamBold
        InfoText.TextStrokeTransparency = 0 -- Borde negro grueso para lectura perfecta
        InfoText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        InfoText.Parent = Billboard

        local Humanoid = Character:WaitForChild("Humanoid", 5)
        
        -- Actualización síncrona en tiempo real
        local Connection
        Connection = RunService.Heartbeat:Connect(function()
            if Character and Character.Parent and Humanoid and Humanoid.Health > 0 and MyRoot then
                -- Control de visibilidad global y Ghost Mode
                if _G.LegnaConfig.ESP.Enabled and not _G.LegnaConfig.GhostMode then
                    Billboard.Enabled = true
                    Highlight.Enabled = true
                    
                    local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local EnemyRoot = Character:FindFirstChild("HumanoidRootPart")
                    
                    if MyRoot and EnemyRoot then
                        local Distancia = math.floor((EnemyRoot.Position - MyRoot.Position).Magnitude)
                        local Vida = math.floor((Humanoid.Health / Humanoid.MaxHealth) * 100)

                        -- Armar el texto dinámico según la configuración activa de la UI
                        local Str = ""
                        if _G.LegnaConfig.ESP.ShowNames then Str = Str .. Player.Name .. "\n" end
                        if _G.LegnaConfig.ESP.ShowDistance then Str = Str .. "[" .. Distancia .. "m] " end
                        if _G.LegnaConfig.ESP.ShowHealth then Str = Str .. Vida .. "%" end
                        InfoText.Text = Str

                        -- LÓGICA DE ALERTAS CROMÁTICAS SEGÚN PORCENTAJE DE SALUD REAL
                        if Vida > 60 then
                            Highlight.FillColor = ColorCian
                            Highlight.OutlineColor = ColorCian
                            InfoText.TextColor3 = ColorCian
                        elseif Vida > 25 then
                            Highlight.FillColor = ColorNaranja
                            Highlight.OutlineColor = ColorNaranja
                            InfoText.TextColor3 = ColorNaranja
                        else
                            Highlight.FillColor = ColorRojo
                            Highlight.OutlineColor = ColorRojo
                            InfoText.TextColor3 = ColorRojo
                        end
                    end
                else
                    Billboard.Enabled = false
                    Highlight.Enabled = false
                end
            else
                Connection:Disconnect() -- Romper conexión si el jugador muere o se desinstala el modelo
            end
        end)
    end

    if Player.Character then task.spawn(CharacterAdded, Player.Character) end
    Player.CharacterAdded:Connect(function(Char) task.spawn(CharacterAdded, Char) end)
end

-- Inicialización del ESP en la lista de jugadores actuales y nuevos
for _, Player in pairs(Players:GetPlayers()) do CrearESP(Player) end
Players.PlayerAdded:Connect(CrearESP)

-- =============================================================================
-- 2. SISTEMA DETECTOR Y RASTREADOR DE FRUTAS FÍSICAS (FRUIT TRACKER)
-- =============================================================================
local function AplicarFruitTracker(Item)
    -- Verificar si el objeto en el mapa es una fruta física tirada
    if Item:IsA("Tool") and (string.find(string.lower(Item.Name), "fruit") or Item:FindFirstChild("Handle")) then
        task.wait(0.2) -- Esperar el renderizado físico
        
        if Item:FindFirstChild("LEGNA_FRUIT_HL") then return end

        -- Contorno brillante magenta para identificarla al instante
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "LEGNA_FRUIT_HL"
        Highlight.FillColor = ColorFruta
        Highlight.OutlineColor = ColorFruta
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.Adornee = Item
        Highlight.Parent = Item

        -- Marcador de texto flotante tridimensional sobre la fruta
        local Billboard = Instance.new("BillboardGui")
        Billboard.Name = "LEGNA_FRUIT_GUI"
        Billboard.Size = UDim2.new(0, 150, 0, 40)
        Billboard.AlwaysOnTop = true
        Billboard.ExtentsOffset = Vector3.new(0, 2, 0)
        Billboard.Adornee = Item:FindFirstChild("Handle") or Item
        Billboard.Parent = Item

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextColor3 = ColorFruta
        TextLabel.TextSize = 12
        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.TextStrokeTransparency = 0
        TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.Parent = Billboard

        -- Bucle de actualización de metros para la fruta detectada
        local Connection
        Connection = RunService.Heartbeat:Connect(function()
            if Item and Item.Parent and Item:FindFirstChild("Handle") then
                if _G.LegnaConfig.ESP.FruitTracker and not _G.LegnaConfig.GhostMode then
                    Billboard.Enabled = true
                    Highlight.Enabled = true
                    
                    local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if MyRoot then
                        local Distance = math.floor((Item.Handle.Position - MyRoot.Position).Magnitude)
                        -- Reemplazar el nombre genérico por el real de la fruta limpia
                        local CleanName = string.gsub(Item.Name, "Fruit", "")
                        TextLabel.Text = "🍓 " .. CleanName .. "\n[" .. Distance .. "m]"
                    end
                else
                    Billboard.Enabled = false
                    Highlight.Enabled = false
                end
            else
                Connection:Disconnect() -- Si alguien agarra la fruta, se destruye el bucle limpiamente
            end
        end)
    end
end

-- Escaneo de frutas físicas spawneadas y nuevas en el Workspace
for _, Item in pairs(Workspace:GetChildren()) do task.spawn(AplicarFruitTracker, Item) end
Workspace.ChildAdded:Connect(function(Item) task.spawn(AplicarFruitTracker, Item) end)

-- =============================================================================
-- 3. MOTOR DEL MODO NOCHE ABSOLUTO (LOCAL LIGHTING INJECTOR)
-- =============================================================================
task.spawn(function()
    while true do
        _G.SafeExecute(function()
            if _G.LegnaConfig.ESP.NightMode then
                -- Congelar el reloj del servidor de forma local a la medianoche pura
                Lighting.ClockTime = 0
                Lighting.GeographicLatitude = 45
            end
        end, "VisualsModule (NightMode Loop)")
        task.wait(2) -- Verificar y mantener cada 2 segundos sin saturar el procesador
    end
end)

print("[LEGNA HUB]: Bloque 5 (Módulo Visual de ESP Cromático y Fruit Tracker) cargado de forma impecable.")
-- =============================================================================
-- LEGNA HUB v3.0 - PREMIUM EDITION (MOBILE OPTIMIZED)
-- BLOQUE 6 - PARTE 1: ESTRUCTURA DE LA UI PREMIUM, HEADER Y SIDEBAR LATERAL
-- =============================================================================

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- // BUSCAR EL CONTENEDOR FLOTANTE DEL BLOQUE 2
local FloatingGui = CoreGui:FindFirstChild("LegnaFloatingButtons_v3")
if not FloatingGui then
    warn("[LEGNA UI ERROR]: No se encontró el Bloque 2 cargado. Asegúrate de ejecutar los bloques en orden.")
    return
end

-- // VARIABLES DE COLOR PREMIUM
local ColorFondo = Color3.fromRGB(15, 15, 15)
local ColorBorde = Color3.fromRGB(0, 255, 255) -- Cian Neón
local ColorRojo = Color3.fromRGB(255, 60, 60)

-- =============================================================================
-- 1. CREACIÓN DEL CONTENEDOR PRINCIPAL DEL MENÚ (MAIN FRAME)
-- =============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Inicia en 0 para la animación elástica de apertura
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centrado en la pantalla
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = ColorFondo
MainFrame.BackgroundTransparency = 0.15 -- Semi-transparencia premium para celulares
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = FloatingGui

-- Esquinas hiper-redondeadas
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- Contorno neón reactivo cian
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = ColorBorde
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- LÓGICA DE ARRASTRE PARA EL MENÚ PRINCIPAL (Soporte táctil móvil completo)
local UserInputService = game:GetService("UserInputService")
local Dragging, DragInput, DragStart, StartPosition

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
    end
end)

-- =============================================================================
-- 2. BARRA DE ESTADO SUPERIOR (HEADER MODERNO Y ANIMACIONES)
-- =============================================================================
local TopHeader = Instance.new("Frame")
TopHeader.Name = "TopHeader"
TopHeader.Size = UDim2.new(1, 0, 0, 40)
TopHeader.Position = UDim2.new(0, 0, 0, 0)
TopHeader.BackgroundTransparency = 1
TopHeader.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(0, 300, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEGNA HUB v3.0 | PREMIUM EDITION"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopHeader

-- Botón de Cierre "✕"
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -35, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = ColorRojo
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopHeader

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0) -- Círculo pequeño
CloseCorner.Parent = CloseBtn

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Thickness = 1.5
CloseStroke.Color = ColorRojo
CloseStroke.Parent = CloseBtn

-- Línea Neón de Carga Infinita (Loading Effect)
local LoadingTrack = Instance.new("Frame")
LoadingTrack.Name = "LoadingTrack"
LoadingTrack.Size = UDim2.new(1, 0, 0, 2)
LoadingTrack.Position = UDim2.new(0, 0, 0, 38)
LoadingTrack.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LoadingTrack.BorderSizePixel = 0
LoadingTrack.Parent = TopHeader

local LoadingBar = Instance.new("Frame")
LoadingBar.Name = "LoadingBar"
LoadingBar.Size = UDim2.new(0.2, 0, 1, 0)
LoadingBar.Position = UDim2.new(-0.2, 0, 0, 0)
LoadingBar.BackgroundColor3 = ColorBorde
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = LoadingTrack

-- Bucle de la animación de la barra de carga infinita
task.spawn(function()
    while MainFrame.Parent do
        if MainFrame.Visible then
            LoadingBar.Position = UDim2.new(-0.2, 0, 0, 0)
            local MoveTween = TweenService:Create(LoadingBar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Position = UDim2.new(1, 0, 0, 0)})
            MoveTween:Play()
            MoveTween.Completed:Wait()
        else
            task.wait(0.5)
        end
    end
end)

-- =============================================================================
-- 3. PANEL LATERAL DE NAVEGACIÓN (SIDEBAR)
-- =============================================================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Sidebar.BackgroundTransparency = 0.3
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Contenedor de los botones de pestañas con Scroll Limpio
local TabButtonLayout = Instance.new("UIListLayout")
TabButtonLayout.Padding = UDim.new(0, 6)
TabButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidebarScroll = Instance.new("ScrollingFrame")
SidebarScroll.Name = "SidebarScroll"
SidebarScroll.Size = UDim2.new(1, 0, 1, -10)
SidebarScroll.Position = UDim2.new(0, 0, 0, 5)
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.BorderSizePixel = 0
SidebarScroll.ScrollBarThickness = 0 -- Ocultar barra fea de scroll en móvil
SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SidebarScroll.Parent = Sidebar
TabButtonLayout.Parent = SidebarScroll

-- =============================================================================
-- 4. VINCULACIÓN DE LA GEMA "L" CON LA INTERFAZ CENTRAL
-- =============================================================================
local GemaL = FloatingGui:WaitForChild("GemaL")
local UI_Abierta = false

local function AlternarMenu()
    if _G.LegnaConfig.GhostMode then return end
    UI_Abierta = not UI_Abierta
    
    if UI_Abierta then
        -- Efecto Pop de apertura elástica expandiéndose desde el centro
        MainFrame.Visible = true
        MainFrame:TweenSizeAndPosition(UDim2.new(0, 560, 0, 340), UDim2.new(0.5, 0, 0.5, 0), "Out", "Back", 0.35, true)
    else
        -- Efecto de contracción y desaparición fluida
        MainFrame:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), "In", "Quad", 0.2, true, function()
            MainFrame.Visible = false
        end)
    end
end

GemaL.MouseButton1Click:Connect(AlternarMenu)
CloseBtn.MouseButton1Click:Connect(AlternarMenu)

print("[LEGNA HUB]: Bloque 6 - Parte 1 (Estructura de la Interfaz y Animación Core) inyectado perfectamente.")
-- =============================================================================
-- LEGNA HUB v3.0 - PREMIUM EDITION (MOBILE OPTIMIZED)
-- BLOQUE 6 - PARTE 2: NAVEGACIÓN SMOOTH SLIDING E INTERRUPTORES ESTILO iOS
-- =============================================================================

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- // RESCATAR INSTANCIAS DE LA PARTE 1
local FloatingGui = CoreGui:FindFirstChild("LegnaFloatingButtons_v3")
local MainFrame = FloatingGui and FloatingGui:FindFirstChild("MainFrame")
local Sidebar = MainFrame and MainFrame:FindFirstChild("Sidebar")
local SidebarScroll = Sidebar and Sidebar:FindFirstChild("SidebarScroll")

if not MainFrame or not SidebarScroll then
    warn("[LEGNA UI ERROR]: Falta la estructura de la Parte 1 para inyectar este bloque.")
    return
end

-- // CONFIGURACIÓN DE PÁGINAS Y CONTENEDOR DERECHO
local PageFolder = Instance.new("Folder")
PageFolder.Name = "PageFolder"
PageFolder.Parent = MainFrame

_G.LegnaPages = {}
local ActiveTabButton = nil
local ActivePage = nil

-- =============================================================================
-- 1. FUNCIÓN MAESTRA: CREAR PESTAÑAS CON DESPLAZAMIENTO FLUIDO (SMOOTH SLIDING)
-- =============================================================================
_G.CreateTab = function(tabName, tabIcon)
    -- Crear botón lateral en el Sidebar
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabName .. "TabBtn"
    TabBtn.Size = UDim2.new(0, 125, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabBtn.BackgroundTransparency = 1 -- Transparente de fábrica si no está seleccionado
    TabBtn.Text = tabIcon .. " " .. tabName
    TabBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = SidebarScroll

    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 8)
    TabBtnCorner.Parent = TabBtn

    -- Crear contenedor derecho específico para el contenido de esta pestaña
    local PageFrame = Instance.new("ScrollingFrame")
    PageFrame.Name = tabName .. "Page"
    PageFrame.Size = UDim2.new(1, -155, 1, -55)
    -- Inicia desplazado hacia la derecha para la animación de entrada
    PageFrame.Position = UDim2.new(1, 0, 0, 48)
    PageFrame.BackgroundTransparency = 1
    PageFrame.BorderSizePixel = 0
    PageFrame.ScrollBarThickness = 2
    PageFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    PageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    PageFrame.Visible = false
    PageFrame.Parent = PageFolder

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Parent = PageFrame

    -- Ajustar tamaño del scroll lateral según los botones agregados
    SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarScroll.UIListLayout.AbsoluteContentSize.Y + 10)

    -- Lógica de navegación táctil con transiciones fluidas
    TabBtn.MouseButton1Click:Connect(function()
        if ActiveTabButton == TabBtn then return end

        -- Deseleccionar pestaña vieja (Animación de apagado suave)
        if ActiveTabButton then
            TweenService:Create(ActiveTabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(160, 160, 160)}):Play()
        end

        -- Seleccionar pestaña nueva (Iluminación premium)
        ActiveTabButton = TabBtn
        TweenService:Create(TabBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()

        -- ANIMACIÓN SMOOTH SLIDING ENTRE PÁGINAS
        if ActivePage then
            local OldPage = ActivePage
            -- Deslizar la página vieja hacia la izquierda y ocultar
            local SlideOut = TweenService:Create(OldPage, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(-0.5, 0, 0, 48)})
            SlideOut:Play()
            task.spawn(function()
                SlideOut.Completed:Wait()
                OldPage.Visible = false
            end)
        end

        -- Configurar y deslizar la página nueva desde la derecha
        ActivePage = PageFrame
        PageFrame.Position = UDim2.new(1, 0, 0, 48)
        PageFrame.Visible = true
        TweenService:Create(PageFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 148, 0, 48)}):Play()
    end)

    _G.LegnaPages[tabName] = PageFrame
    return PageFrame
end

-- =============================================================================
-- 2. FUNCIÓN MAESTRA: CREAR INTERRUPTORES ESTILO iOS (TOGGLES NEÓN)
-- =============================================================================
_G.CreateToggle = function(parentPage, text, configTable, configKey, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = text .. "ToggleFrame"
    ToggleFrame.Size = UDim2.new(0, 385, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parentPage

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleFrame

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Thickness = 1.2
    ToggleStroke.Color = Color3.fromRGB(35, 35, 35) -- Gris apagado inicial
    ToggleStroke.Parent = ToggleFrame

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0, 250, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.TextSize = 13
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    -- Estructura del Switch estilo iOS
    local SwitchContainer = Instance.new("TextButton")
    SwitchContainer.Name = "SwitchContainer"
    SwitchContainer.Size = UDim2.new(0, 45, 0, 22)
    SwitchContainer.Position = UDim2.new(1, -60, 0, 11)
    SwitchContainer.BackgroundColor3 = Color3.fromRGB(40, 25, 25) -- Rojo/Gris oscuro inicial
    SwitchContainer.Text = ""
    SwitchContainer.BorderSizePixel = 0
    SwitchContainer.Parent = ToggleFrame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchContainer

    local SwitchCircle = Instance.new("Frame")
    SwitchCircle.Name = "SwitchCircle"
    SwitchCircle.Size = UDim2.new(0, 16, 0, 16)
    SwitchCircle.Position = UDim2.new(0, 3, 0, 3) -- Posición izquierda (Apagado)
    SwitchCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    SwitchCircle.BorderSizePixel = 0
    SwitchCircle.Parent = SwitchContainer

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = SwitchCircle

    -- Sincronizar estado visual interno según los datos cargados del JSON
    local State = configTable[configKey]
    
    local function UpdateVisuals(animate)
        local targetPos = State and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
        local targetBg = State and Color3.fromRGB(15, 50, 30) or Color3.fromRGB(40, 25, 25)
        local targetStroke = State and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(35, 35, 35)
        
        if animate then
            TweenService:Create(SwitchCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
            TweenService:Create(SwitchContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetBg}):Play()
            TweenService:Create(ToggleStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Color = targetStroke}):Play()
        else
            SwitchCircle.Position = targetPos
            SwitchContainer.BackgroundColor3 = targetBg
            ToggleStroke.Color = targetStroke
        end
    end
    
    UpdateVisuals(false) -- Sincronización inicial rápida

    -- Interacción táctil del interruptor
    SwitchContainer.MouseButton1Click:Connect(function()
        State = not State
        configTable[configKey] = State
        
        -- Ejecutar guardado JSON global en background de forma segura
        _G.SafeExecute(function()
            if writefile then
                writefile("LegnaHub_v3_Config.json", game:GetService("HttpService"):JSONEncode(_G.LegnaConfig))
            end
        end, "Guardado JSON desde Toggle: " .. text)

        UpdateVisuals(true)

        -- Lanzar el callback para activar la función real en el juego
        if callback then
            task.spawn(callback, State)
        end
    end)

    -- Ajustar el tamaño del scroll dinámicamente según se agreguen interruptores
    parentPage.CanvasSize = UDim2.new(0, 0, 0, parentPage.UIListLayout.AbsoluteContentSize.Y + 15)
end

print("[LEGNA HUB]: Bloque 6 - Parte 2 (Desplazamiento Smooth e Interruptores iOS) acoplado perfectamente.")
-- =============================================================================
-- LEGNA HUB v3.0 - PREMIUM EDITION (MOBILE OPTIMIZED)
-- BLOQUE 7 - PARTE 1: INYECCIÓN DE PESTAÑAS, MÓDULO COMBAT Y SLIDER DE FOV
-- =============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // VERIFICACIÓN E INICIALIZACIÓN DE LAS PESTAÑAS CORE
local CombatPage    = _G.CreateTab("Combat", "⚔️")
local MacrosPage    = _G.CreateTab("Macros", "📜")
local AutoFarmPage  = _G.CreateTab("Auto Farm", "🌾")
local VisualsPage   = _G.CreateTab("Visuals", "👁️")
local SettingsPage  = _G.CreateTab("Settings", "⚙️")

-- =============================================================================
-- [⚔️] APARTADO 1: CONFIGURACIÓN DE COMBAT AVANZADO
-- =============================================================================
_G.CreateToggle(CombatPage, "Silent Aim Masivo (Auto-Hit)", _G.LegnaConfig, "SilentAimEnabled", function(Value)
    _G.SilentAimEnabled = Value -- Sincronizar directo con el módulo de metatablas
end)

_G.CreateToggle(CombatPage, "Gun Aim Especial (Armas/Guns)", _G.LegnaConfig, "GunAimEnabled")
_G.CreateToggle(CombatPage, "Prediction 2.0 (Anticipación Vectorial)", _G.LegnaConfig, "PredictionEnabled")

-- CREACIÓN DEL SLIDER DE FOV DINÁMICO TÁCTIL
local SliderFrame = Instance.new("Frame")
SliderFrame.Name = "FovSliderFrame"
SliderFrame.Size = UDim2.new(0, 385, 0, 55)
SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SliderFrame.BorderSizePixel = 0
SliderFrame.Parent = CombatPage

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 10)
SliderCorner.Parent = SliderFrame

local SliderTitle = Instance.new("TextLabel")
SliderTitle.Size = UDim2.new(0, 200, 0, 25)
SliderTitle.Position = UDim2.new(0, 15, 0, 5)
SliderTitle.BackgroundTransparency = 1
SliderTitle.Text = "Radio del Círculo FOV"
SliderTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
SliderTitle.TextSize = 12
SliderTitle.Font = Enum.Font.GothamBold
SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
SliderTitle.Parent = SliderFrame

local SliderValueLabel = Instance.new("TextLabel")
SliderValueLabel.Size = UDim2.new(0, 60, 0, 25)
SliderValueLabel.Position = UDim2.new(1, -75, 0, 5)
SliderValueLabel.BackgroundTransparency = 1
SliderValueLabel.Text = tostring(_G.LegnaConfig.FovRadius) .. "px"
SliderValueLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
SliderValueLabel.TextSize = 12
SliderValueLabel.Font = Enum.Font.GothamBold
SliderValueLabel.TextXAlignment = Enum.TextXAlignment.Right
SliderValueLabel.Parent = SliderFrame

-- Barra base del Slider
local SliderTrack = Instance.new("TextButton")
SliderTrack.Name = "SliderTrack"
SliderTrack.Size = UDim2.new(1, -30, 0, 6)
SliderTrack.Position = UDim2.new(0, 15, 0, 36)
SliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SliderTrack.Text = ""
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = SliderFrame

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = SliderTrack

-- Barra interna neón rellena
local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Size = UDim2.new(0, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

-- LÓGICA DE DETECCIÓN Y DESLIZAMIENTO TÁCTIL (MÓVIL MOUSE/TOUCH)
local MinValue = 50
local MaxValue = 500
local Sliding = false

local function UpdateSlider(inputPosition)
    local RelativeX = inputPosition.X - SliderTrack.AbsolutePosition.X
    local Percentage = math.clamp(RelativeX / SliderTrack.AbsoluteSize.X, 0, 1)
    
    -- Calcular el valor matemático exacto según el porcentaje de arrastre
    local ActualValue = math.floor(MinValue + (Percentage * (MaxValue - MinValue)))
    _G.LegnaConfig.FovRadius = ActualValue
    
    -- Actualizar interfaz de forma inmediata e interactiva
    SliderFill.Size = UDim2.new(Percentage, 0, 1, 0)
    SliderValueLabel.Text = tostring(ActualValue) .. "px"
end

SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Sliding = true
        UpdateSlider(input.Position)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSlider(input.Position)
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Soltar arrastre de forma segura al levantar el dedo
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End and Sliding then
                Sliding = false
                -- Guardar en el JSON local al soltar el slider
                _G.SafeExecute(function()
                    if writefile then
                        writefile("LegnaHub_v3_Config.json", game:GetService("HttpService"):JSONEncode(_G.LegnaConfig))
                    end
                end, "Guardar Ajuste Slider FOV")
            end
        end)
    end
end)

-- Sincronizar posición del Slider con los datos del archivo JSON cargado
local InitialPercent = (_G.LegnaConfig.FovRadius - MinValue) / (MaxValue - MinValue)
SliderFill.Size = UDim2.new(math.clamp(InitialPercent, 0, 1), 0, 1, 0)

-- Ajustar contenedor del scroll
CombatPage.CanvasSize = UDim2.new(0, 0, 0, CombatPage.UIListLayout.AbsoluteContentSize.Y + 15)

print("[LEGNA HUB]: Bloque 7 - Parte 1 (Módulo Combat y Control Deslizable) cargado con éxito.")
-- =============================================================================
-- LEGNA HUB v3.0 - PREMIUM EDITION (MOBILE OPTIMIZED)
-- BLOQUE 7 - PARTE 2: AUTO FARM, AUTOMATIZACIONES, VISUALES Y TERMINAL SELF-HEAL
-- =============================================================================

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- // RESCATAR LAS PÁGINAS CREADAS EN LA PARTE 1
local MacrosPage    = _G.LegnaPages["Macros"]
local AutoFarmPage  = _G.LegnaPages["Auto Farm"]
local VisualsPage   = _G.LegnaPages["Visuals"]
local SettingsPage  = _G.LegnaPages["Settings"]

-- =============================================================================
-- [📜] APARTADO 2: SECCIÓN DE MACROS INTERACTIVOS
-- =============================================================================
-- (El botón físico 'M' y los retardos optimizados ya operan de forma independiente)
_G.CreateToggle(MacrosPage, "Habilitar Gatillo Flotante 'M'", _G.LegnaConfig, "AimbotEnabled") -- Vinculado al gatillo

-- =============================================================================
-- [🌾] APARTADO 3: CONTROL DE AUTO FARM (ESTILO SCRIPT DE PAGA)
-- =============================================================================
_G.CreateToggle(AutoFarmPage, "Auto Farm Level (Optimizado)", _G.LegnaConfig, "AutoSoru") -- Marcador de ejemplo estructural
_G.CreateToggle(AutoFarmPage, "Auto Click Ráfaga (Bring Mobs)", _G.LegnaConfig, "AutoBuso")

-- =============================================================================
-- [🧠] APARTADO 4: AUTOMATIZACIONES INTELIGENTES DE COMBATE
-- =============================================================================
_G.CreateToggle(SettingsPage, "Smart Ken Haki (Filtro Anti-Stun)", _G.LegnaConfig, "SmartKen")
_G.CreateToggle(SettingsPage, "Auto Buso Haki (Armadura Instantánea)", _G.LegnaConfig, "AutoBuso")
_G.CreateToggle(SettingsPage, "Auto Dash Evade Orgánico (Escape al 30%)", _G.LegnaConfig, "DashEvade")

-- =============================================================================
-- [👁️] APARTADO 5: MÓDULO DE VISUALES COMPLETO Y ESP CROMÁTICO
-- =============================================================================
_G.CreateToggle(VisualsPage, "Activar ESP Maestro (GPU Highlight)", _G.LegnaConfig.ESP, "Enabled")
_G.CreateToggle(VisualsPage, "Ver Nombres de Rivales", _G.LegnaConfig.ESP, "ShowNames")
_G.CreateToggle(VisualsPage, "Ver Distancia en Metros", _G.LegnaConfig.ESP, "ShowDistance")
_G.CreateToggle(VisualsPage, "Ver Porcentaje de Vida [%]", _G.LegnaConfig.ESP, "ShowHealth")
_G.CreateToggle(VisualsPage, "Fruit Tracker (Buscador de Frutas Neón)", _G.LegnaConfig.ESP, "FruitTracker")
_G.CreateToggle(VisualsPage, "Modo Noche Absoluto (Local Dark Mode)", _G.LegnaConfig.ESP, "NightMode")

-- =============================================================================
-- [⚙️] APARTADO 6: AJUSTES AVANZADOS Y MODO FANTASMA (STREAMER CONSOLE)
-- =============================================================================
_G.CreateToggle(SettingsPage, "GHOST MODE (Invisibilidad Total de Hack)", _G.LegnaConfig, "GhostMode")

-- =============================================================================
-- 💻 7. CREACIÓN DE LA TERMINAL GRÁFICA "DEV CONSOLE" (CONSOLA SELF-HEAL)
-- =============================================================================
local ConsoleFrame = Instance.new("Frame")
ConsoleFrame.Name = "LegnaDevConsole"
ConsoleFrame.Size = UDim2.new(0, 385, 0, 140)
ConsoleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ConsoleFrame.BorderSizePixel = 0
ConsoleFrame.Parent = SettingsPage

local ConsoleCorner = Instance.new("UICorner")
ConsoleCorner.CornerRadius = UDim.new(0, 10)
ConsoleCorner.Parent = ConsoleFrame

local ConsoleStroke = Instance.new("UIStroke")
ConsoleStroke.Thickness = 1
ConsoleStroke.Color = Color3.fromRGB(30, 30, 30)
ConsoleStroke.Parent = ConsoleFrame

-- Contenedor de Texto con Scroll de la Terminal
local ConsoleScroll = Instance.new("ScrollingFrame")
ConsoleScroll.Size = UDim2.new(1, -20, 1, -40)
ConsoleScroll.Position = UDim2.new(0, 10, 0, 32)
ConsoleScroll.BackgroundTransparency = 1
ConsoleScroll.BorderSizePixel = 0
ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ConsoleScroll.ScrollBarThickness = 2
ConsoleScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
ConsoleScroll.Parent = ConsoleFrame

local ConsoleLayout = Instance.new("UIListLayout")
ConsoleLayout.Padding = UDim.new(0, 4)
ConsoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConsoleLayout.Parent = ConsoleScroll

-- Banner superior interno de la consola con Métricas en vivo (Ping / FPS / Región)
local ConsoleHeader = Instance.new("TextLabel")
ConsoleHeader.Size = UDim2.new(1, -20, 0, 22)
ConsoleHeader.Position = UDim2.new(0, 10, 0, 5)
ConsoleHeader.BackgroundTransparency = 1
ConsoleHeader.Text = "RENDIMIENTO: FPS: -- | PING: --ms | SERVER: -- | EDAD: --h"
ConsoleHeader.TextColor3 = Color3.fromRGB(150, 150, 150)
ConsoleHeader.TextSize = 10
ConsoleHeader.Font = Enum.Font.Code
ConsoleHeader.TextXAlignment = Enum.TextXAlignment.Left
ConsoleHeader.Parent = ConsoleFrame

-- Bucle de actualización para la Barra de Métricas y el Autocierre / Ghost Mode de la Consola
RunService.Heartbeat:Connect(function()
    if ConsoleFrame.Visible then
        local pingColor = "🟢"
        if _G.ServerMetrics.Ping > 200 then pingColor = "🔴" elseif _G.ServerMetrics.Ping > 120 then pingColor = "🟡" end
        
        ConsoleHeader.Text = string.format(
            "METRICS -> FPS: %d | PING: %dms %s | REGION: %s | EDAD: %dh",
            _G.ServerMetrics.FPS,
            _G.ServerMetrics.Ping,
            pingColor,
            _G.ServerMetrics.Region,
            _G.ServerMetrics.Age
        )
    end
end)

-- LÓGICA DE ACTUALIZACIÓN DINÁMICA DE MENSAJES (Sincronizado con _G.ConsoleLogs)
local LastLogCount = 0
task.spawn(function()
    while true do
        if #_G.ConsoleLogs ~= LastLogCount and not _G.LegnaConfig.GhostMode then
            LastLogCount = #_G.ConsoleLogs
            
            -- Limpiar consola gráfica antigua de forma segura
            for _, child in pairs(ConsoleScroll:GetChildren()) do
                if child:IsA("TextLabel") then child:Destroy() end
            end
            
            -- Re-dibujar logs con colores estratégicos en la terminal de tu celular
            for _, log in pairs(_G.ConsoleLogs) do
                local LogText = Instance.new("TextLabel")
                LogText.Size = UDim2.new(1, 0, 0, 16)
                LogText.BackgroundTransparency = 1
                LogText.Text = log.Text
                LogText.TextSize = 10
                LogText.Font = Enum.Font.Code
                LogText.TextXAlignment = Enum.TextXAlignment.Left
                
                -- Asignación de colores neón según la categoría atrapada por el Self-Heal
                if log.Type == "error" then
                    LogText.TextColor3 = Color3.fromRGB(255, 60, 60)   -- Rojo / Error
                elseif log.Type == "heal" then
                    LogText.TextColor3 = Color3.fromRGB(0, 255, 255)   -- Celeste / Auto-reparado
                elseif log.Type == "warn" then
                    LogText.TextColor3 = Color3.fromRGB(255, 180, 0)  -- Amarillo / Alerta
                else
                    LogText.TextColor3 = Color3.fromRGB(0, 255, 150)  -- Verde / Éxito info
                end
                
                LogText.Parent = ConsoleScroll
            end
            
            -- Auto-Scroll: Deslizar automáticamente la terminal hacia abajo para ver el último log
            ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, ConsoleLayout.AbsoluteContentSize.Y + 5)
            ConsoleScroll.CanvasPosition = Vector2.new(0, ConsoleScroll.CanvasSize.Y.Offset)
        end
        task.wait(1) -- Escaneo inteligente por segundo para evitar caídas de FPS
    end
end)

-- Sincronizar tamaño final de los contenedores
SettingsPage.CanvasSize = UDim2.new(0, 0, 0, SettingsPage.UIListLayout.AbsoluteContentSize.Y + 15)

print("[LEGNA HUB]: Bloque 7 - Parte 2 (Módulos Finales de Control e Interfaz) acoplado al 100%.")
print("=============================================================================")
print("🚀 LEGNA HUB v3.0 CARGADO CON ÉXITO Y TOTALMENTE OPERATIVO EN DISPOSITIVOS MÓVILES.")
print("=============================================================================")
