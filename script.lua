--// LEGNA HUB v3.0 Ultra Premium - High Performance Combat & ESP System
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- // LIMPIEZA TOTAL PARA EVITAR DUPLICACIONES
if player.PlayerGui:FindFirstChild("LEGNA_HUB_PREMIUM") then
    player.PlayerGui.LEGNA_HUB_PREMIUM:Destroy()
end

-- // ENTORNO DE INTERFAZ GRÁFICA
local gui = Instance.new("ScreenGui")
gui.Name = "LEGNA_HUB_PREMIUM"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- GEMA FLOTANTE INDEPENDIENTE "L" (Abre y cierra todo el menú)
local gemaBtn = Instance.new("TextButton", gui)
gemaBtn.Size = UDim2.new(0, 52, 0, 52)
gemaBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
gemaBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
gemaBtn.Text = "L"
gemaBtn.TextColor3 = Color3.fromRGB(0, 229, 255)
gemaBtn.Font = Enum.Font.GothamBold
gemaBtn.TextSize = 22
Instance.new("UICorner", gemaBtn).CornerRadius = UDim.new(1, 0)

local gemaStroke = Instance.new("UIStroke", gemaBtn)
gemaStroke.Color = Color3.fromRGB(0, 229, 255)
gemaStroke.Thickness = 1.8

-- MENÚ PRINCIPAL COMPACTO (Estilo Dark Semi-Transparente Profesional)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 360, 0, 260)
main.Position = UDim2.new(0.5, -180, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
main.BackgroundTransparency = 0.15 -- Semi-transparente premium solicitado
main.BorderSizePixel = 0
main.Visible = false -- Inicia oculto hasta tocar la gema "L"
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(0, 229, 255)
mainStroke.Thickness = 1.2

-- Barra de Título Superior
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(1, -80, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "LEGNA HUB  •  v3.0 Premium"
titleText.TextColor3 = Color3.fromRGB(0, 229, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextXAlignment = Enum.TextXAlignment.Left

local divider = Instance.new("Frame", titleBar)
divider.Size = UDim2.new(1, 0, 0, 1)
divider.Position = UDim2.new(0, 0, 1, -1)
divider.BackgroundColor3 = Color3.fromRGB(0, 229, 255)
divider.BorderSizePixel = 0

-- Botón "X" de Minimizado Rápido dentro de la Barra de Título
local minMenuBtn = Instance.new("TextButton", titleBar)
minMenuBtn.Size = UDim2.new(0, 26, 0, 26)
minMenuBtn.Position = UDim2.new(1, -35, 0.5, -13)
minMenuBtn.Text = "✕"
minMenuBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
minMenuBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
minMenuBtn.Font = Enum.Font.GothamBold
minMenuBtn.TextSize = 12
Instance.new("UICorner", minMenuBtn).CornerRadius = UDim.new(0, 6)

-- Barra Lateral de Pestañas (Sidebar)
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 110, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(7, 7, 9)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

-- Contenedores con Scrolling para las Secciones
local combatTab = Instance.new("ScrollingFrame", main)
combatTab.Size = UDim2.new(1, -125, 1, -55)
combatTab.Position = UDim2.new(0, 120, 0, 50)
combatTab.BackgroundTransparency = 1
combatTab.CanvasSize = UDim2.new(0, 0, 0, 480)
combatTab.ScrollBarThickness = 3
combatTab.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 255)

local macroTab = Instance.new("ScrollingFrame", main)
macroTab.Size = UDim2.new(1, -125, 1, -55)
macroTab.Position = UDim2.new(0, 120, 0, 50)
macroTab.BackgroundTransparency = 1
macroTab.CanvasSize = UDim2.new(0, 0, 0, 400)
macroTab.ScrollBarThickness = 3
macroTab.ScrollBarImageColor3 = Color3.fromRGB(0, 229, 255)
macroTab.Visible = false

local visualTab = Instance.new("Frame", main)
visualTab.Size = UDim2.new(1, -125, 1, -55)
visualTab.Position = UDim2.new(0, 120, 0, 50)
visualTab.BackgroundTransparency = 1
visualTab.Visible = false

-- Framework de Arrastre Táctil Premium Especial Móvil (Delta)
local function applySmoothDrag(trigger, target)
    local dragging, dragStart, startPos
    trigger.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = target.Position end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            TweenService:Create(target, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
    trigger.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
applySmoothDrag(titleBar, main)
applySmoothDrag(gemaBtn, gemaBtn)

-- Lógica de Apertura y Cierre mediante la Gema "L"
gemaBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)
minMenuBtn.MouseButton1Click:Connect(function()
    main.Visible = false
end)
-- Función Premium para crear Interruptores Interactivos con Luces Neón
local function createPremiumToggle(text, pos, parent, defaultState, callback)
    local active = defaultState
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.98, 0, 0, 36)
    frame.Position = pos
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local switchBG = Instance.new("Frame", frame)
    switchBG.Size = UDim2.new(0, 30, 0, 16)
    switchBG.Position = UDim2.new(1, -40, 0.5, -8)
    switchBG.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)
    
    local ball = Instance.new("Frame", switchBG)
    ball.Size = UDim2.new(0, 12, 0, 12)
    ball.Position = UDim2.new(0, 2, 0.5, -6)
    ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)
    
    local function updateSwitch(animate)
        local duration = animate and 0.2 or 0
        local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(switchBG, info, {BackgroundColor3 = active and Color3.fromRGB(0, 210, 120) or Color3.fromRGB(35, 35, 45)}):Play()
        TweenService:Create(stroke, info, {Color = active and Color3.fromRGB(0, 210, 120) or Color3.fromRGB(45, 45, 55)}):Play()
        TweenService:Create(ball, info, {Position = active and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
        TweenService:Create(label, info, {TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)}):Play()
    end
    updateSwitch(false)
    
    local hitBtn = Instance.new("TextButton", frame)
    hitBtn.Size = UDim2.new(1, 0, 1, 0)
    hitBtn.BackgroundTransparency = 1
    hitBtn.Text = ""
    hitBtn.MouseButton1Click:Connect(function() active = not active updateSwitch(true) callback(active) end)
    return frame
end

local function createTabButton(text, pos, parent, isActive, onSelect)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.86, 0, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = isActive and Color3.fromRGB(22, 22, 28) or Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = isActive and 0 or 1
    btn.Text = text
    btn.TextColor3 = isActive and Color3.fromRGB(0, 229, 255) or Color3.fromRGB(130, 130, 140)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(onSelect)
    return btn
end

local tab1, tab2, tab3
local function setTabState(activeTab)
    combatTab.Visible = (activeTab == "Combat")
    macroTab.Visible = (activeTab == "Macro")
    visualTab.Visible = (activeTab == "Visuals")
    
    TweenService:Create(tab1, TweenInfo.new(0.2), {BackgroundTransparency = (activeTab == "Combat" and 0 or 1), TextColor3 = (activeTab == "Combat" and Color3.fromRGB(0, 229, 255) or Color3.fromRGB(130, 130, 140))}):Play()
    TweenService:Create(tab1, TweenInfo.new(0.2), {BackgroundColor3 = (activeTab == "Combat" and Color3.fromRGB(22, 22, 28) or Color3.fromRGB(0,0,0))}):Play()
    
    TweenService:Create(tab2, TweenInfo.new(0.2), {BackgroundTransparency = (activeTab == "Macro" and 0 or 1), TextColor3 = (activeTab == "Macro" and Color3.fromRGB(0, 229, 255) or Color3.fromRGB(130, 130, 140))}):Play()
    TweenService:Create(tab2, TweenInfo.new(0.2), {BackgroundColor3 = (activeTab == "Macro" and Color3.fromRGB(22, 22, 28) or Color3.fromRGB(0,0,0))}):Play()
    
    TweenService:Create(tab3, TweenInfo.new(0.2), {BackgroundTransparency = (activeTab == "Visuals" and 0 or 1), TextColor3 = (activeTab == "Visuals" and Color3.fromRGB(0, 229, 255) or Color3.fromRGB(130, 130, 140))}):Play()
    TweenService:Create(tab3, TweenInfo.new(0.2), {BackgroundColor3 = (activeTab == "Visuals" and Color3.fromRGB(22, 22, 28) or Color3.fromRGB(0,0,0))}):Play()
end

tab1 = createTabButton("⚔️ Combat", UDim2.new(0.07, 0, 0, 12), sidebar, true, function() setTabState("Combat") end)
tab2 = createTabButton("📜 Macros", UDim2.new(0.07, 0, 0, 48), sidebar, false, function() setTabState("Macro") end)
tab3 = createTabButton("👁️ Visuals", UDim2.new(0.07, 0, 0, 84), sidebar, false, function() setTabState("Visuals") end)

-- CONFIGURACIONES DEL MOTOR DE COMBATE
local aimbotEnabled = false
local autoClosest = true
local espEnabled = true
local predictionEnabled = true
local silentAimEnabled = false
local autoEvadeEnabled = false
local autoBusoHaki = true
local smartKenHaki = true
local autoRazaV3 = true
local targetPart = "Head"
local useZ, useX, useC, useV = true, false, false, false
local maxDistance = 1000
local ajusteAltura = -0.9
_G.selectedTarget = nil

-- BOTÓN FLOTANTE APARTADO INDEPENDIENTE "LOCK CAM" (Movible con el dedo)
local lockCamBtn = Instance.new("TextButton", gui)
lockCamBtn.Size = UDim2.new(0, 65, 0, 65)
lockCamBtn.Position = UDim2.new(0.15, 0, 0.4, 0)
lockCamBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
lockCamBtn.Text = "LOCK\nCAM"
lockCamBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
lockCamBtn.Font = Enum.Font.GothamBold
lockCamBtn.TextSize = 11
Instance.new("UICorner", lockCamBtn).CornerRadius = UDim.new(1, 0)

local lockStroke = Instance.new("UIStroke", lockCamBtn)
lockStroke.Color = Color3.fromRGB(255, 50, 50)
lockStroke.Thickness = 2.5

applySmoothDrag(lockCamBtn, lockCamBtn)

-- Lógica del botón flotante independiente Lock Cam
lockCamBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        lockCamBtn.Text = "LOCK\nON ✅"
        lockCamBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
        lockStroke.Color = Color3.fromRGB(100, 255, 100)
        lockCamBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        lockCamBtn.Text = "LOCK\nCAM"
        lockCamBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        lockStroke.Color = Color3.fromRGB(255, 50, 50)
        lockCamBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)
-- Cargar Toggles en Sección de Combate de forma ordenada
local currentY = 0
local function nextY(spacing) local val = currentY currentY = currentY + spacing return val end

createPremiumToggle("Silent Aim (Redirección Clicks)", UDim2.new(0, 0, 0, nextY(40)), combatTab, false, function(v) silentAimEnabled = v end)
createPremiumToggle("Prediction 2.0 (Física Anticipada)", UDim2.new(0, 0, 0, nextY(40)), combatTab, true, function(v) predictionEnabled = v end)
createPremiumToggle("Auto Dash Evade (Combo Breaker)", UDim2.new(0, 0, 0, nextY(40)), combatTab, false, function(v) autoEvadeEnabled = v end)
createPremiumToggle("Auto Buso Haki (Armadura)", UDim2.new(0, 0, 0, nextY(40)), combatTab, true, function(v) autoBusoHaki = v end)
createPremiumToggle("Smart Ken Haki (Visión Táctica)", UDim2.new(0, 0, 0, nextY(40)), combatTab, true, function(v) smartKenHaki = v end)
createPremiumToggle("Auto Race V3 Awakening", UDim2.new(0, 0, 0, nextY(40)), combatTab, true, function(v) autoRazaV3 = v end)

-- Selector de Parte del Cuerpo a apuntar
local partBtn = Instance.new("TextButton", combatTab)
partBtn.Size = UDim2.new(0.98, 0, 0, 36)
partBtn.Position = UDim2.new(0, 0, 0, nextY(46))
partBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
partBtn.Text = "  Fijar Objetivo en: Cabeza 👤"
partBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
partBtn.Font = Enum.Font.GothamBold
partBtn.TextSize = 11
partBtn.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", partBtn).CornerRadius = UDim.new(0, 6)
local partStroke = Instance.new("UIStroke", partBtn)
partStroke.Color = Color3.fromRGB(45, 45, 55)

partBtn.MouseButton1Click:Connect(function()
    if targetPart == "Head" then
        targetPart = "HumanoidRootPart"
        partBtn.Text = "  Fijar Objetivo en: Torso (HRP) 👕"
    else
        targetPart = "Head"
        partBtn.Text = "  Fijar Objetivo en: Cabeza 👤"
    end
end)

-- Cuadrícula del Auto Combo (Z, X, C, V)
local gridFrame = Instance.new("Frame", combatTab)
gridFrame.Size = UDim2.new(1, 0, 0, 72)
gridFrame.Position = UDim2.new(0, 0, 0, nextY(80))
gridFrame.BackgroundTransparency = 1

local tZ = createPremiumToggle("Skill [Z]", UDim2.new(0, 0, 0, 0), gridFrame, true, function(v) useZ = v end)
local tX = createPremiumToggle("Skill [X]", UDim2.new(0.51, 0, 0, 0), gridFrame, false, function(v) useX = v end)
local tC = createPremiumToggle("Skill [C]", UDim2.new(0, 0, 0, 38), gridFrame, false, function(v) useC = v end)
local tV = createPremiumToggle("Skill [V]", UDim2.new(0.51, 0, 0, 38), gridFrame, false, function(v) useV = v end)
tZ.Size = UDim2.new(0.47, 0, 0, 34) tX.Size = UDim2.new(0.47, 0, 0, 34)
tC.Size = UDim2.new(0.47, 0, 0, 34) tV.Size = UDim2.new(0.47, 0, 0, 34)

-- Contenido de la pestaña de Visuales (ESP)
createPremiumToggle("Activar Player ESP (Paredes)", UDim2.new(0, 0, 0, 5), visualTab, true, function(v) espEnabled = v end)

local infoStatus = Instance.new("TextLabel", visualTab)
infoStatus.Size = UDim2.new(0.96, 0, 0, 60)
infoStatus.Position = UDim2.new(0.02, 0, 0, 55)
infoStatus.Text = "Estado Motor ESP: Activo\nRastrea automáticamente la Salud [%], Nombre y Distancia de los oponentes de forma limpia sobre sus personajes."
infoStatus.TextColor3 = Color3.fromRGB(130, 130, 140)
infoStatus.Font = Enum.Font.Gotham
infoStatus.TextSize = 11
infoStatus.TextWrapped = true
infoStatus.TextYAlignment = Enum.TextYAlignment.Top
infoStatus.TextXAlignment = Enum.TextXAlignment.Left
infoStatus.BackgroundTransparency = 1
-- =========================================================================
-- PARTE 4 DE 5: SISTEMA CREADOR DE BOTONES FLOTANTES COMPACTOS "M" [+]
-- =========================================================================

local addMacroBtn = Instance.new("TextButton", macroTab)
addMacroBtn.Size = UDim2.new(0.96, 0, 0, 40)
addMacroBtn.Position = UDim2.new(0.02, 0, 0, 10)
addMacroBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
addMacroBtn.Text = "[+] Crear Nuevo Botón Macro Flotante"
addMacroBtn.TextColor3 = Color3.fromRGB(0, 229, 255)
addMacroBtn.Font = Enum.Font.GothamBold
addMacroBtn.TextSize = 12
Instance.new("UICorner", addMacroBtn).CornerRadius = UDim.new(0, 6)
local addStroke = Instance.new("UIStroke", addMacroBtn)
addStroke.Color = Color3.fromRGB(0, 229, 255)

-- Ventana emergente interna para configurar la secuencia del Macro
local popup = Instance.new("Frame", main)
popup.Size = UDim2.new(0, 240, 0, 180)
popup.Position = UDim2.new(0.5, -120, 0.5, -90)
popup.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
popup.BorderSizePixel = 0
popup.Visible = false
Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)
local popStroke = Instance.new("UIStroke", popup)
popStroke.Color = Color3.fromRGB(45, 45, 55)

local popTitle = Instance.new("TextLabel", popup)
popTitle.Size = UDim2.new(1, 0, 0, 30)
popTitle.Text = "Configurar Secuencia Macro"
popTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popTitle.Font = Enum.Font.GothamBold
popTitle.TextSize = 11
popTitle.BackgroundTransparency = 1

local inputKeys = Instance.new("TextBox", popup)
inputKeys.Size = UDim2.new(0.9, 0, 0, 30)
inputKeys.Position = UDim2.new(0.05, 0, 0, 40)
inputKeys.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
inputKeys.Text = ""
inputKeys.PlaceholderText = "Teclas separadas por coma (Ej: Z,X,C)"
inputKeys.TextColor3 = Color3.new(1,1,1)
inputKeys.Font = Enum.Font.Gotham
inputKeys.TextSize = 10
Instance.new("UICorner", inputKeys)

local inputDelay = Instance.new("TextBox", popup)
inputDelay.Size = UDim2.new(0.9, 0, 0, 30)
inputDelay.Position = UDim2.new(0.05, 0, 0, 80)
inputDelay.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
inputDelay.Text = "0.1"
inputDelay.PlaceholderText = "Retraso en segundos (Ej: 0.1)"
inputDelay.TextColor3 = Color3.new(1,1,1)
inputDelay.Font = Enum.Font.Gotham
inputDelay.TextSize = 11
Instance.new("UICorner", inputDelay)

local confirmBtn = Instance.new("TextButton", popup)
confirmBtn.Size = UDim2.new(0.42, 0, 0, 32)
confirmBtn.Position = UDim2.new(0.05, 0, 0, 130)
confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 210, 100)
confirmBtn.Text = "Crear Botón"
confirmBtn.TextColor3 = Color3.new(1,1,1)
confirmBtn.Font = Enum.Font.GothamBold
confirmBtn.TextSize = 11
Instance.new("UICorner", confirmBtn)

local cancelBtn = Instance.new("TextButton", popup)
cancelBtn.Size = UDim2.new(0.42, 0, 0, 32)
cancelBtn.Position = UDim2.new(0.53, 0, 0, 130)
cancelBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
cancelBtn.Text = "Cancelar"
cancelBtn.TextColor3 = Color3.new(1,1,1)
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.TextSize = 11
Instance.new("UICorner", cancelBtn)

addMacroBtn.MouseButton1Click:Connect(function() popup.Visible = true end)
cancelBtn.MouseButton1Click:Connect(function() popup.Visible = false inputKeys.Text = "" end)

local macroCount = 0
local vim = game:GetService("VirtualInputManager")

confirmBtn.MouseButton1Click:Connect(function()
    local keysString = inputKeys.Text:gsub("%s+", ""):upper()
    local delayTime = tonumber(inputDelay.Text) or 0.1
    if keysString == "" then return end
    
    popup.Visible = false
    inputKeys.Text = ""
    macroCount = macroCount + 1
    
    -- DISEÑO SOLICITADO: Botón Flotante Redondo, Fondo Negro, Borde Blanco, Letra "M" blanca
    local fBtn = Instance.new("TextButton", gui)
    fBtn.Size = UDim2.new(0, 50, 0, 50) -- Tamaño chico y estético (menor que el botón de salto)
    fBtn.Position = UDim2.new(0.8, 0, 0.2 + (macroCount * 0.09), 0)
    fBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Fondo Negro profundo
    fBtn.Text = "M" -- Letra M Blanca
    fBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fBtn.Font = Enum.Font.GothamBold
    fBtn.TextSize = 18
    Instance.new("UICorner", fBtn).CornerRadius = UDim.new(1, 0) -- Totalmente Redondo
    
    local fStroke = Instance.new("UIStroke", fBtn)
    fStroke.Color = Color3.fromRGB(255, 255, 255) -- Bordes Blancos originales
    fStroke.Thickness = 2
    
    -- Arrastre Táctil Suave y optimizado para pantallas móviles
    local dragging, dragStart, startPos
    fBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = fBtn.Position end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            fBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    fBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    
    -- Separar las teclas escritas por comas y meterlas a una tabla
    local keySequence = {}
    for key in string.gmatch(keysString, "[^,]+") do
        table.insert(keySequence, key)
    end
    
    -- Ejecución de las combinaciones al presionar el botón flotante "M" creado
    local runningMacro = false
    fBtn.MouseButton1Click:Connect(function()
        if runningMacro then return end
        runningMacro = true
        fStroke.Color = Color3.fromRGB(0, 210, 100) -- Cambia temporalmente a verde neón para avisar que está corriendo el combo
        
        task.spawn(function()
            for idx = 1, #keySequence do
                local k = keySequence[idx]
                if Enum.KeyCode[k] then
                    vim:SendKeyEvent(true, Enum.KeyCode[k], false, game)
                    task.wait(0.04)
                    vim:SendKeyEvent(false, Enum.KeyCode[k], false, game)
                    task.wait(delayTime)
                end
            end
            fStroke.Color = Color3.fromRGB(255, 255, 255) -- Vuelve a su borde blanco original al terminar
            runningMacro = false
        end)
    end)
end)
--// CONTINUACIÓN DE PARTE 5 NATIVA Y CIERRE TOTAL

-- MOTOR DE VISUALES ESP PREMIUM (Ultra Fluido Nativo)
local function createEsp(targetPlayer)
    if targetPlayer == player then return end
    
    local function applyEsp(char)
        task.wait(0.5)
        local head = char:WaitForChild("Head", 5)
        if not head or head:FindFirstChild("LegnaESP") then return end
        
        local bgui = Instance.new("BillboardGui")
        bgui.Name = "LegnaESP"
        bgui.AlwaysOnTop = true
        bgui.Size = UDim2.new(0, 180, 0, 35)
        bgui.StudsOffset = Vector3.new(0, 2.2, 0)
        bgui.Parent = head
        
        local label = Instance.new("TextLabel", bgui)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(0, 229, 255)
        label.TextStrokeTransparency = 0.2
        label.Font = Enum.Font.GothamBold
        label.TextSize = 10
        
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not bgui or not bgui.Parent or not head.Parent then connection:Disconnect() return end
            if not espEnabled then label.Text = "" return end
            
            local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            
            if localRoot and targetRoot and hum and hum.Health > 0 then
                local dist = math.floor((localRoot.Position - targetRoot.Position).Magnitude)
                local hpPercent = math.floor((hum.Health / hum.MaxHealth) * 100)
                
                label.Text = string.format("%s (%dm) [%d%%]", targetPlayer.Name, dist, hpPercent)
                
                if hpPercent > 50 then
                    label.TextColor3 = Color3.fromRGB(0, 229, 255)
                elseif hpPercent > 20 then
                    label.TextColor3 = Color3.fromRGB(255, 165, 0)
                else
                    label.TextColor3 = Color3.fromRGB(255, 50, 50)
                end
            else
                label.Text = ""
            end
        end)
    end
    
    if targetPlayer.Character then task.spawn(applyEsp, targetPlayer.Character) end
    targetPlayer.CharacterAdded:Connect(function(char) task.spawn(applyEsp, char) end)
end

for _, p in ipairs(Players:GetPlayers()) do createEsp(p) end
Players.PlayerAdded:Connect(createEsp)

-- BUSCADOR ASÍNCRONO DE OBJETIVOS ANTI-LAG
task.spawn(function()
    while true do
        if (aimbotEnabled or silentAimEnabled) and autoClosest then
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local closest, minDist = nil, maxDistance
                local allPlayers = Players:GetPlayers()
                for i = 1, #allPlayers do
                    local v = allPlayers[i]
                    if v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") then
                        local tPart = v.Character:FindFirstChild(targetPart)
                        local hum = v.Character.Humanoid
                        if tPart and hum.Health > 0 and v.Team ~= player.Team then
                            local dist = (tPart.Position - root.Position).Magnitude
                            if dist < minDist then minDist = dist closest = tPart end
                        end
                    end
                end
                _G.selectedTarget = closest
            end
        elseif not aimbotEnabled and not silentAimEnabled then
            _G.selectedTarget = nil
        end
        task.wait(0.1)
    end
end)

-- MOTOR DE HAKI DE OBSERVACIÓN INTELIGENTE (SMART KEN HAKI)
local function triggerKenHaki()
    local bRem = ReplicatedStorage:FindFirstChild("Remotes") and (ReplicatedStorage.Remotes:FindFirstChild("Ken") or ReplicatedStorage.Remotes:FindFirstChild("Observation"))
    if bRem then bRem:FireServer() end
end

task.spawn(function()
    while true do
        if smartKenHaki and player.Character and player.Character:FindFirstChild("Humanoid") then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char.Humanoid
            
            if hum.Health > 0 and root then
                local hasKenActive = char:FindFirstChild("HasBuso") or char:FindFirstChild("KenActive")
                local enemyNear = false
                local projectileIncoming = false
                
                if _G.selectedTarget then
                    local dist = (root.Position - _G.selectedTarget.Position).Magnitude
                    if dist < 45 then
                        enemyNear = true
                        if root.Velocity.Magnitude < 2 and hum.Health < hum.MaxHealth then
                            if not hasKenActive then triggerKenHaki() end
                        end
                    end
                end
                
                local raycastParams = RaycastParams.new()
                raycastParams.FilterPlayers = {player}
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                
                local scanRay = workspace:Raycast(root.Position + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), raycastParams)
                if scanRay and scanRay.Instance and (scanRay.Instance.Name:find("Attack") or scanRay.Instance.Name:find("Skill") or scanRay.Instance.Name:find("Projectile")) then
                    projectileIncoming = true
                    if not hasKenActive then triggerKenHaki() end
                end
                
                if hasKenActive and not enemyNear and not projectileIncoming and hum.Health > (hum.MaxHealth * 0.90) then
                    triggerKenHaki()
                end
            end
        end
        task.wait(0.15)
    end
end)

-- AUTOMATIZACIONES EXTRA (Buso Haki y Raza V3)
task.spawn(function()
    while true do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local hum = player.Character.Humanoid
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if hum.Health > 0 and root then
                if autoBusoHaki and (aimbotEnabled or player.Character:FindFirstChildOfClass("Tool")) then
                    if not player.Character:FindFirstChild("Buso") then
                        local bRem = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Buso")
                        if bRem then bRem:FireServer() end
                    end
                end
                if autoEvadeEnabled and (hum.Health / hum.MaxHealth) <= 0.30 then
                    root.Velocity = root.Velocity + Vector3.new(math.random(-35, 35), 0, math.random(-35, 35))
                    task.wait(0.35)
                end
                if autoRazaV3 and _G.selectedTarget and (root.Position - _G.selectedTarget.Position).Magnitude < 90 then
                    vim:SendKeyEvent(true, Enum.KeyCode.T, false, game) task.wait(0.05) vim:SendKeyEvent(false, Enum.KeyCode.T, false, game)
                    task.wait(20)
                end
            end
        end
        task.wait(0.1)
    end
end)

-- INTERCEPTOR SILENT AIM (Hookmetamethod del CFrame de la cámara)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, index)
    if silentAimEnabled and _G.selectedTarget and not checkcaller() then
        if self == Camera and index == "CFrame" then
            return CFrame.lookAt(Camera.CFrame.Position, _G.selectedTarget.Position)
        end
    end
    return oldIndex(self, index)
end)

local function castSkill(key)
    vim:SendKeyEvent(true, Enum.KeyCode[key], false, game) task.wait(0.04) vim:SendKeyEvent(false, Enum.KeyCode[key], false, game)
end

-- HILO COMBATE PRINCIPAL (ZERO LATENCY CON APUNTADO AGRESIVO ORIGINAL + PREDICCIÓN)
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled or not _G.selectedTarget then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if (root.Position - _G.selectedTarget.Position).Magnitude > maxDistance then return end

    local finalAimPos = _G.selectedTarget.Position + Vector3.new(0, ajusteAltura, 0)
    if predictionEnabled and _G.selectedTarget.Parent:FindFirstChild("HumanoidRootPart") then
        local targetVelocity = _G.selectedTarget.Parent.HumanoidRootPart.Velocity
        finalAimPos = finalAimPos + (targetVelocity * 0.125)
    end

    Camera.CFrame = CFrame.new(Camera.CFrame.Position, finalAimPos)
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool and (root.Position - _G.selectedTarget.Position).Magnitude < 120 then tool:Activate() end
    
    if (root.Position - _G.selectedTarget.Position).Magnitude < 85 then
        if useZ then castSkill("Z") task.wait(0.04) end
        if useX then castSkill("X") task.wait(0.04) end
        if useC then castSkill("C") task.wait(0.04) end
        if useV then castSkill("V") task.wait(0.04) end
    end
end)

print("⚡ LEGNA HUB v3.0 Ultimate Automation cargada con éxito.")
