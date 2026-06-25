--// LEGNA HUB v3.0 Ultra Premium - Ultimate UI, Combat & Dynamic Macro System
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- // LIMPIEZA DE INTERFAZ ANTERIOR PARA EVITAR BUG VISUAL
if player.PlayerGui:FindFirstChild("LEGNA_HUB_PREMIUM") then
    player.PlayerGui.LEGNA_HUB_PREMIUM:Destroy()
end

-- // INSTANCIAS BASE DE LA INTERFAZ
local gui = Instance.new("ScreenGui")
gui.Name = "LEGNA_HUB_PREMIUM"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Contenedor Principal (Con transparencia inicial para el Fade-in)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 390, 0, 320)
main.Position = UDim2.new(0.5, -195, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- Borde Neón Inteligente
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(0, 229, 255)
mainStroke.Thickness = 1.5

-- Barra de Título Superior Arrastrable
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(1, -90, 1, 0)
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

-- Barra Lateral de Pestañas (Sidebar)
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 110, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = Color3.fromRGB(7, 7, 9)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 14)

-- Contenedores con Scrolling para las Secciones (Evita lag de renderizado)
local combatTab = Instance.new("ScrollingFrame", main)
combatTab.Size = UDim2.new(1, -125, 1, -55)
combatTab.Position = UDim2.new(0, 120, 0, 50)
combatTab.BackgroundTransparency = 1
combatTab.CanvasSize = UDim2.new(0, 0, 0, 560)
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

-- GEMA FLOTANTE DE MINIMIZADO CIRULAR "L"
local gemaBtn = Instance.new("TextButton", gui)
gemaBtn.Size = UDim2.new(0, 48, 0, 48)
gemaBtn.Position = UDim2.new(0.03, 0, 0.15, 0)
gemaBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
gemaBtn.Text = "L"
gemaBtn.TextColor3 = Color3.fromRGB(0, 229, 255)
gemaBtn.Font = Enum.Font.GothamBold
gemaBtn.TextSize = 20
gemaBtn.Visible = false
Instance.new("UICorner", gemaBtn).CornerRadius = UDim.new(1, 0)
local gemaStroke = Instance.new("UIStroke", gemaBtn)
gemaStroke.Color = Color3.fromRGB(0, 229, 255)
gemaStroke.Thickness = 1.8

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

-- Cargar Toggles en Sección de Combate
local currentY = 0
local function nextY(spacing) local val = currentY currentY = currentY + spacing return val end

createPremiumToggle("Lock Cam (Fijado de Cámara)", UDim2.new(0, 0, 0, nextY(40)), combatTab, false, function(v) aimbotEnabled = v end)
createPremiumToggle("Silent Aim (Redirección Clicks)", UDim2.new(0, 0, 0, nextY(40)), combatTab, false, function(v) silentAimEnabled = v end)
createPremiumToggle("Prediction 2.0 (Física Anticipada)", UDim2.new(0, 0, 0, nextY(40)), combatTab, true, function(v) predictionEnabled = v end)
createPremiumToggle("Auto Dash Evade (Combo Breaker)", UDim2.new(0, 0, 0, nextY(40)), combatTab, false, function(v) autoEvadeEnabled = v end)
createPremiumToggle("Auto Buso Haki (Armadura)", UDim2.new(0, 0, 0, nextY(40)), combatTab, true, function(v) autoBusoHaki = v end)
createPremiumToggle("Smart Ken Haki (Visión Táctica)", UDim2.new(0, 0, 0, nextY(40)), combatTab, true, function(v) smartKenHaki = v end)
createPremiumToggle("Auto Race V3 Awakening", UDim2.new(0, 0, 0, nextY(40)), combatTab, true, function(v) autoRazaV3 = v end)
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

createPremiumToggle("Activar Player ESP (Paredes)", UDim2.new(0, 0, 0, 5), visualTab, true, function(v) espEnabled = v end)

-- =========================================================================
-- SISTEMA EXCLUSIVO: CREADOR DE MACROS DINÁMICOS CON BOTONES FLOTANTES [+]
-- =========================================================================
local vim = game:GetService("VirtualInputManager")

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

-- Panel emergente interno para configurar el Macro
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
confirmBtn.MouseButton1Click:Connect(function()
    local keysString = inputKeys.Text:gsub("%s+", ""):upper()
    local delayTime = tonumber(inputDelay.Text) or 0.1
    if keysString == "" then return end
    
    popup.Visible = false
    inputKeys.Text = ""
    macroCount = macroCount + 1
    
    -- Crear el botón flotante independiente en la pantalla
    local fBtn = Instance.new("TextButton", gui)
    fBtn.Size = UDim2.new(0, 55, 0, 55)
    fBtn.Position = UDim2.new(0.8, 0, 0.2 + (macroCount * 0.1), 0)
    fBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    fBtn.Text = "MACRO\n" .. keysString
    fBtn.TextColor3 = Color3.fromRGB(0, 229, 255)
    fBtn.Font = Enum.Font.GothamBold
    fBtn.TextSize = 9
    Instance.new("UICorner", fBtn).CornerRadius = UDim.new(1, 0)
    
    local fStroke = Instance.new("UIStroke", fBtn)
    fStroke.Color = Color3.fromRGB(0, 229, 255)
    fStroke.Thickness = 1.5
    
    applySmoothDrag(fBtn, fBtn) -- Hace el nuevo botón flotante arrastrable
    
    -- Separar el string por comas para guardar las teclas en una tabla Lua
    local keySequence = {}
    for key in string.gmatch(keysString, "[^,]+") do
        table.insert(keySequence, key)
    end
    
    -- Lógica de activación al presionar el botón flotante creado
    local runningMacro = false
    fBtn.MouseButton1Click:Connect(function()
        if runningMacro then return end
        runningMacro = true
        fStroke.Color = Color3.fromRGB(0, 210, 100)
        
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
            fStroke.Color = Color3.fromRGB(0, 229, 255)
            runningMacro = false
        end)
    end)
end)
