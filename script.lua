-- ====================================================================
-- LEGNA HUB ✦ PARTE 1: SERVICIOS, CONFIGURACIÓN Y BOTONES FLOTANTES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variables de Control del Menú
_G.SilentAimEnabled = false
_G.LockCamEnabled = false
_G.ShowFpsActive = false
_G.UltraLowActive = false
_G.EspLineActive = false

-- Configuración del Combo Macro
_G.MacroZ, _G.MacroX, _G.MacroC, _G.MacroV, _G.MacroF = false, false, false, false, false
_G.MaxDistance = 500
_G.FovRadius = 200

-- Eliminar menús duplicados anteriores
if localPlayer.PlayerGui:FindFirstChild("LEGNA_HUB_MAIN") then
    localPlayer.PlayerGui.LEGNA_HUB_MAIN:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LEGNA_HUB_MAIN"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- FUNCIÓN: Arrastre Suave para Pantallas Táctiles
local function makeDraggable(frame, dragAnchor)
    dragAnchor = dragAnchor or frame
    local dragging, dragInput, dragStart, startPos
    dragAnchor.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragAnchor.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        end
    end)
end

-- BOTÓN FLOTANTE "L" (Cuadrado con bordes redondeados)
local ToggleL = Instance.new("TextButton")
ToggleL.Size = UDim2.new(0, 50, 0, 50)
ToggleL.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleL.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleL.Text = "L"
ToggleL.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleL.Font = Enum.Font.SourceSansBold
ToggleL.TextSize = 24
ToggleL.Parent = ScreenGui

local LCorner = Instance.new("UICorner")
LCorner.CornerRadius = UDim.new(0, 10)
LCorner.Parent = ToggleL

local LStroke = Instance.new("UIStroke")
LStroke.Color = Color3.fromRGB(255, 255, 255)
LStroke.Thickness = 1.5
LStroke.Parent = ToggleL
makeDraggable(ToggleL)

-- BOTÓN FLOTANTE VIRTUAL "M" (Bordes Blancos Redondos)
local VirtualM = Instance.new("TextButton")
VirtualM.Size = UDim2.new(0, 55, 0, 55)
VirtualM.Position = UDim2.new(0.8, 0, 0.2, 0)
VirtualM.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
VirtualM.Text = "M"
VirtualM.TextColor3 = Color3.fromRGB(255, 255, 255)
VirtualM.Font = Enum.Font.SourceSansBold
VirtualM.TextSize = 24
VirtualM.Visible = false
VirtualM.ZIndex = 10
VirtualM.Parent = ScreenGui

local VMCorner = Instance.new("UICorner")
VMCorner.CornerRadius = UDim.new(1, 0)
VMCorner.Parent = VirtualM

local VMStroke = Instance.new("UIStroke")
VMStroke.Color = Color3.fromRGB(255, 255, 255)
VMStroke.Thickness = 2.5
VMStroke.Parent = VirtualM
makeDraggable(VirtualM)

-- Ejecución de las Habilidades del Combo
local function simulateKey(key)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        task.wait(0.08)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
        task.wait(0.15)
    end)
end

VirtualM.MouseButton1Click:Connect(function()
    task.spawn(function()
        if _G.MacroZ then simulateKey("Z") end
        if _G.MacroX then simulateKey("X") end
        if _G.MacroC then simulateKey("C") end
        if _G.MacroV then simulateKey("V") end
        if _G.MacroF then simulateKey("F") end
    end)
end)
-- ====================================================================
-- LEGNA HUB ✦ PARTE 2: DISEÑO MINIMALISTA DE LA INTERFAZ Y PESTAÑAS
-- ====================================================================
local ScreenGui = localPlayer.PlayerGui:WaitForChild("LEGNA_HUB_MAIN")
local ToggleL = ScreenGui:WaitForChild("TextButton")
local VirtualM = ScreenGui:WaitForChild("TextButton", 5) -- Busca el botón M

-- Panel Principal del Menú
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 380)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Barra Lateral (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 80, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 8)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = Sidebar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 15)
SidePadding.Parent = Sidebar

-- Zona superior de Arrastre
local DragBar = Instance.new("Frame")
DragBar.Size = UDim2.new(1, -80, 0, 40)
DragBar.Position = UDim2.new(0, 80, 0, 0)
DragBar.BackgroundTransparency = 1
DragBar.Parent = MainFrame
makeDraggable(MainFrame, DragBar)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -15, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "LEGNA HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = DragBar

-- Contenedor de Páginas (Scrollable hacia abajo)
local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -95, 1, -55)
PageContainer.Position = UDim2.new(0, 85, 0, 45)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

-- Animación de abrir/cerrar con el botón "L"
local menuOpen = false
ToggleL.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Size = UDim2.new(0, 0, 0, 380)
        MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 340, 0, 380), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    else
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 380), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.15, true, function()
            MainFrame.Visible = false
        end)
    end
end)

-- Sistema de Mapeo de Pestañas
local pages = {}
local function createTab(tabName, order)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 70, 0, 32)
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 12
    tabBtn.LayoutOrder = order
    tabBtn.Parent = Sidebar
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 6)
    tCorner.Parent = tabBtn
    
    local scrollPage = Instance.new("ScrollingFrame")
    scrollPage.Size = UDim2.new(1, 0, 1, 0)
    scrollPage.BackgroundTransparency = 1
    scrollPage.BorderSizePixel = 0
    scrollPage.ScrollBarThickness = 2
    scrollPage.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    scrollPage.Visible = false
    scrollPage.Parent = PageContainer
    
    local pLayout = Instance.new("UIListLayout")
    pLayout.Padding = UDim.new(0, 8)
    pLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Parent = scrollPage
    
    pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollPage.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 15)
    end)
    
    pages[tabName] = {btn = tabBtn, page = scrollPage}
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do
            p.page.Visible = false
            p.btn.TextColor3 = Color3.fromRGB(160, 160, 160)
            p.btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        end
        scrollPage.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)
    
    if order == 1 then
        scrollPage.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end
    return scrollPage
end

-- Generador de Interruptores (Toggles de Diseño)
local function addToggle(parentPage, text, layoutOrder, callback)
    local tFrame = Instance.new("Frame")
    tFrame.Size = UDim2.new(1, -10, 0, 40)
    tFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    tFrame.BorderSizePixel = 0
    tFrame.LayoutOrder = layoutOrder
    tFrame.Parent = parentPage
    
    local tfCorner = Instance.new("UICorner")
    tfCorner.CornerRadius = UDim.new(0, 6)
    tfCorner.Parent = tFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tFrame
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 45, 0, 22)
    switch.Position = UDim2.new(1, -55, 0.5, -11)
    switch.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    switch.Text = ""
    switch.Parent = tFrame
    
    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = switch
    
    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0, 16, 0, 16)
    ball.Position = UDim2.new(0, 3, 0.5, -8)
    ball.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    ball.BorderSizePixel = 0
    ball.Parent = switch
    
    local ballCorner = Instance.new("UICorner")
    ballCorner.CornerRadius = UDim.new(1, 0)
    ballCorner.Parent = ball
    
    local toggled = false
    switch.MouseButton1Click:Connect(function()
        toggled = not toggled
        TweenService:Create(switch, TweenInfo.new(0.15), {BackgroundColor3 = toggled and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(40, 40, 40)}):Play()
        TweenService:Create(ball, TweenInfo.new(0.15), {Position = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        callback(toggled)
    end)
end

-- Instanciar las 4 Páginas Principales
local combatPage = createTab("Combate", 1)
local macroPage = createTab("Macros", 2)
local visualPage = createTab("Visuales", 3)
local perfPage = createTab("Sistema", 4)

-- Conectar los Toggles de Macros
addToggle(macroPage, "Mostrar Botón Macro M", 1, function(v) VirtualM.Visible = v end)
addToggle(macroPage, "Incluir habilidad [Z]", 2, function(v) _G.MacroZ = v end)
addToggle(macroPage, "Incluir habilidad [X]", 3, function(v) _G.MacroX = v end)
addToggle(macroPage, "Incluir habilidad [C]", 4, function(v) _G.MacroC = v end)
addToggle(macroPage, "Incluir habilidad [V]", 5, function(v) _G.MacroV = v end)
addToggle(macroPage, "Incluir habilidad [F]", 6, function(v) _G.MacroF = v end)
-- ====================================================================
-- LEGNA HUB ✦ PARTE 3: FILTROS DE COMBATE, FPS, OPTIMIZACIÓN Y ESP
-- ====================================================================

-- 1. ENLAZAR COMPONENTES DE LAS PESTAÑAS (Viene de la Parte 2)
addToggle(combatPage, "Activar Silent Aim", 1, function(v) _G.SilentAimEnabled = v end)
addToggle(combatPage, "Activar Lock Cam", 2, function(v) _G.LockCamEnabled = v end)

addToggle(visualPage, "Activar Trazo ESP (Línea)", 1, function(v) _G.EspLineActive = v end)

-- Creación del contador de FPS (Texto blanco puro sin fondo)
local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(0, 100, 0, 30)
FpsLabel.Position = UDim2.new(0.02, 0, 0.02, 0)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = ""
FpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.TextSize = 18
FpsLabel.TextXAlignment = Enum.TextXAlignment.Left
FpsLabel.Visible = false
FpsLabel.Parent = ScreenGui

addToggle(perfPage, "Activar Contador FPS", 1, function(v)
    _G.ShowFpsActive = v
    FpsLabel.Visible = v
end)

addToggle(perfPage, "Optimización Ultra Low", 2, function(v)
    _G.UltraLowActive = v
    if _G.UltraLowActive then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsA("MeshPart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
    end
end)

-- 2. BUSCADOR AVANZADO CON FILTROS (500m, Crew, Zona Segura)
local function getValidTarget()
    local bestTarget = nil
    local closestMouseDistance = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    fovCircle.Position = screenCenter
    fovCircle.Radius = _G.FovRadius
    fovCircle.Visible = _G.SilentAimEnabled

    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            
            if root and hum and hum.Health > 0 then
                -- FILTRO A: Límite estricto de 500 metros
                local realDistance = (root.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
                if realDistance <= _G.MaxDistance then
                    
                    -- FILTRO B: Aliados (Misma tripulación/equipo)
                    local isAlly = false
                    if player.Team == localPlayer.Team and localPlayer.Team ~= nil then
                        isAlly = true
                    end
                    
                    -- FILTRO C: Verificar si está en Zona Segura o sin PVP activo
                    local pvpActive = true
                    if player.Character:FindFirstChild("CombatFolder") or player.Character:FindFirstChild("SafeZone") then
                        pvpActive = false
                    end
                    
                    if not isAlly and pvpActive then
                        local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                        if onScreen then
                            local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if mouseDistance < closestMouseDistance and mouseDistance <= _G.FovRadius then
                                closestMouseDistance = mouseDistance
                                bestTarget = root
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- 3. TRAZO ESP ROSA (Igual al video de TikTok)
local currentLine = Drawing.new("Line")
currentLine.Thickness = 2
currentLine.Color = Color3.fromRGB(255, 0, 150)
currentLine.Transparency = 0.8
currentLine.Visible = false

-- 4. MODIFICACIÓN DE METATODOS NATIVOS (Silent Aim Indestructible)
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if _G.SilentAimEnabled and tostring(self) == "Mouse" and (key == "Hit" or key == "Target") then
        local target = getValidTarget()
        if target then
            return key == "Hit" and target.CFrame or target
        end
    end
    return oldIndex(self, key)
end)
setreadonly(mt, true)

-- 5. BUCLE DE RENDERIZACIÓN DE FPS, LOCK CAM Y TRAZO
task.spawn(function()
    local lastIteration, startSecond = 0, os.clock()
    
    RunService.RenderStepped:Connect(function()
        -- Cálculo continuo de FPS reales
        lastIteration = lastIteration + 1
        if os.clock() - startSecond >= 1 then
            if _G.ShowFpsActive then FpsLabel.Text = "FPS: " .. lastIteration end
            lastIteration = 0
            startSecond = os.clock()
        end
        
        pcall(function()
            local currentTarget = getValidTarget()
            
            -- Lock Cam Suave (Gira la cámara sin tirones)
            if _G.LockCamEnabled and currentTarget then
                local targetCFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, 0.2)
            end
            
            -- Dibujar la línea rosa hacia el objetivo
            if _G.EspLineActive and currentTarget then
                local screenPos, onScreen = camera:WorldToViewportPoint(currentTarget.Position)
                if onScreen then
                    currentLine.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    currentLine.To = Vector2.new(screenPos.X, screenPos.Y)
                    currentLine.Visible = true
                else
                    currentLine.Visible = false
                end
            else
                currentLine.Visible = false
            end
        end)
    end)
end)
