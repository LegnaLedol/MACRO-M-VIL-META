--// LEGNA HUB v2.0 - COMBAT EDITION (Anti-Freeze & Zero Latency)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- // LIMPIEZA DE INTERFAZ ANTERIOR
if player.PlayerGui:FindFirstChild("LEGNA_HUB_V2") then
    player.PlayerGui.LEGNA_HUB_V2:Destroy()
end

-- // INSTANCIAS DE LA INTERFAZ PREMIUM
local gui = Instance.new("ScreenGui")
gui.Name = "LEGNA_HUB_V2"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 340, 0, 520)
main.Position = UDim2.new(0.5, -170, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

-- Borde Neón Estilizado
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 210, 255)
stroke.Thickness = 1.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 55)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
title.Text = "⚡ LEGNA HUB v2.0 ⚡"
title.TextColor3 = Color3.fromRGB(0, 210, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 16)

local titleDivider = Instance.new("Frame", title)
titleDivider.Size = UDim2.new(1, 0, 0, 2)
titleDivider.Position = UDim2.new(0, 0, 1, -2)
titleDivider.BackgroundColor3 = Color3.fromRGB(0, 210, 255)
titleDivider.BorderSizePixel = 0

-- Sistema de Arrastre Táctil Especial para Delta
local dragging, dragStart, startPos
title.InputBegan:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
        dragging = true 
        dragStart = i.Position 
        startPos = main.Position 
    end 
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end 
end)

-- Botón de Cerrado Completo (✕)
local closeBtn = Instance.new("TextButton", title)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -45, 0, 10)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Contenedor Principal con Scroll (Evita que colapsen los botones)
local container = Instance.new("ScrollingFrame", main)
container.Size = UDim2.new(1, -20, 1, -75)
container.Position = UDim2.new(0, 10, 0, 65)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 0, 580)
container.ScrollBarThickness = 4
container.ScrollBarImageColor3 = Color3.fromRGB(0, 210, 255)
-- Función interna para generar botones estéticos rápidamente
local function createButton(text, pos, sizeY, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, sizeY)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local bstroke = Instance.new("UIStroke", btn)
    bstroke.Color = Color3.fromRGB(45, 45, 55)
    bstroke.Thickness = 1
    return btn
end

-- 1. Botón Principal Aimbot
local toggleBtn = createButton("AIMBOT: DESACTIVADO ❌", UDim2.new(0.025, 0, 0, 5), 50, container)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)

-- 2. Botón de Modo de Bloqueo
local closestBtn = createButton("Modo: Enemigo Más Cercano [ON]", UDim2.new(0.025, 0, 0, 65), 45, container)
closestBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 30)
closestBtn.TextColor3 = Color3.fromRGB(100, 255, 100)

-- 3. Configuración de Habilidades Combo
local comboTitle = Instance.new("TextLabel", container)
comboTitle.Size = UDim2.new(0.95, 0, 0, 25)
comboTitle.Position = UDim2.new(0.025, 0, 0, 125)
comboTitle.Text = "⚔️ CONFIGURACIÓN DE HABILIDADES AUTO"
comboTitle.TextColor3 = Color3.fromRGB(0, 210, 255)
comboTitle.Font = Enum.Font.GothamBold
comboTitle.TextSize = 13
comboTitle.BackgroundTransparency = 1

local useZ, useX, useC, useV = true, false, false, false
local btnZ = createButton("Skill [Z]: ON", UDim2.new(0.025, 0, 0, 155), 38, container)
local btnX = createButton("Skill [X]: OFF", UDim2.new(0.5, 5, 0, 155), 38, container)
btnZ.Size = UDim2.new(0.45, 0, 0, 38) btnX.Size = UDim2.new(0.45, 0, 0, 38)
btnZ.BackgroundColor3 = Color3.fromRGB(20, 40, 25)

local btnC = createButton("Skill [C]: OFF", UDim2.new(0.025, 0, 0, 200), 38, container)
local btnV = createButton("Skill [V]: OFF", UDim2.new(0.5, 5, 0, 200), 38, container)
btnC.Size = UDim2.new(0.45, 0, 0, 38) btnV.Size = UDim2.new(0.45, 0, 0, 38)

btnZ.MouseButton1Click:Connect(function() useZ = not useZ btnZ.Text = "Skill [Z]: "..(useZ and "ON" or "OFF") btnZ.BackgroundColor3 = useZ and Color3.fromRGB(20,40,25) or Color3.fromRGB(28,28,35) end)
btnX.MouseButton1Click:Connect(function() useX = not useX btnX.Text = "Skill [X]: "..(useX and "ON" or "OFF") btnX.BackgroundColor3 = useX and Color3.fromRGB(20,40,25) or Color3.fromRGB(28,28,35) end)
btnC.MouseButton1Click:Connect(function() useC = not useC btnC.Text = "Skill [C]: "..(useC and "ON" or "OFF") btnC.BackgroundColor3 = useC and Color3.fromRGB(20,40,25) or Color3.fromRGB(28,28,35) end)
btnV.MouseButton1Click:Connect(function() useV = not useV btnV.Text = "Skill [V]: "..(useV and "ON" or "OFF") btnV.BackgroundColor3 = useV and Color3.fromRGB(20,40,25) or Color3.fromRGB(28,28,35) end)

-- 4. Panel Selector Manual de Jugadores
local selectBtn = createButton("Seleccionar Objetivo Manual", UDim2.new(0.025, 0, 0, 250), 45, container)
local status = Instance.new("TextLabel", container)
status.Size = UDim2.new(0.95, 0, 0, 30)
status.Position = UDim2.new(0.025, 0, 0, 300)
status.Text = "Estado: Buscando..."
status.TextColor3 = Color3.fromRGB(150, 150, 160)
status.Font = Enum.Font.Gotham
status.TextSize = 15
status.BackgroundTransparency = 1

local listFrame = Instance.new("ScrollingFrame", container)
listFrame.Size = UDim2.new(0.95, 0, 0, 140)
listFrame.Position = UDim2.new(0.025, 0, 0, 335)
listFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
listFrame.CanvasSize = UDim2.new(0, 0, 0, 350)
listFrame.Visible = false
Instance.new("UICorner", listFrame)

local function refreshList()
    for _,v in ipairs(listFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local offset = 5
    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do
        local plr = allPlayers[i]
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if dist <= 1000 then
                local btn = Instance.new("TextButton", listFrame)
                btn.Size = UDim2.new(0.95, 0, 0, 35)
                btn.Position = UDim2.new(0.025, 0, 0, offset)
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                btn.Text = plr.Name .. " ("..math.floor(dist).."m)"
                btn.TextColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", btn)
                offset = offset + 40
                btn.MouseButton1Click:Connect(function()
                    _G.selectedTarget = plr.Character:FindFirstChild("HumanoidRootPart")
                    status.Text = "🎯 Locked: " .. plr.Name
                    listFrame.Visible = false
                end)
            end
        end
        if i % 5 == 0 then task.wait() end -- Anti-congelamiento móvil
    end
end
-- VARIABLES INTERNAS DE ACCIÓN
local aimbotEnabled = false
local autoClosest = true
_G.selectedTarget = nil
local maxDistance = 1000
local ajusteAltura = -0.9 -- Compensación exacta del script original

-- BUSCADOR EN SEGUNDO PLANO (Aislar procesos evita congelar la pantalla)
task.spawn(function()
    while true do
        if aimbotEnabled and autoClosest then
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local closest, minDist = nil, maxDistance
                local allPlayers = Players:GetPlayers()
                
                for i = 1, #allPlayers do
                    local v = allPlayers[i]
                    if v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") then
                        local tRoot = v.Character:FindFirstChild("HumanoidRootPart")
                        local hum = v.Character.Humanoid
                        
                        if tRoot and hum.Health > 0 and v.Team ~= player.Team then
                            local dist = (tRoot.Position - root.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closest = tRoot
                            end
                        end
                    end
                end
                _G.selectedTarget = closest
            end
        elseif not aimbotEnabled then
            _G.selectedTarget = nil
        end
        task.wait(0.1) -- Escaneo dosificado ultra estable
    end
end)

-- INTERACCIONES DE CONFIGURACIÓN DE BOTONES
toggleBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        toggleBtn.Text = "AIMBOT: ACTIVADO ✅"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
        toggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        toggleBtn.Text = "AIMBOT: DESACTIVADO ❌"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

closestBtn.MouseButton1Click:Connect(function()
    autoClosest = not autoClosest
    closestBtn.Text = "Modo: Enemigo Más Cercano ["..(autoClosest and "ON" or "OFF").."]"
    closestBtn.BackgroundColor3 = autoClosest and Color3.fromRGB(20, 40, 30) or Color3.fromRGB(35, 35, 45)
    closestBtn.TextColor3 = autoClosest and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(200, 200, 200)
    if autoClosest then _G.selectedTarget = nil status.Text = "Estado: En Espera Auto..." end
end)

selectBtn.MouseButton1Click:Connect(function() listFrame.Visible = not listFrame.Visible if listFrame.Visible then refreshList() end end)

-- SISTEMA DE CASTEO DE SKILLS
local vim = game:GetService("VirtualInputManager")
local function castSkill(key)
    vim:SendKeyEvent(true, Enum.KeyCode[key], false, game)
    task.wait(0.05)
    vim:SendKeyEvent(false, Enum.KeyCode[key], false, game)
end

-- EJECUCIÓN DIRECTA AL CFRAME (MÁXIMA VELOCIDAD ORIGINAL SIN LERP)
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled or not _G.selectedTarget then return end
    
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local dist = (root.Position - _G.selectedTarget.Position).Magnitude
    if dist > maxDistance then status.Text = "Estado: Objetivo fuera de rango" return end

    -- Lógica del punto de impacto agresivo original
    local aimPosition = _G.selectedTarget.Position + Vector3.new(0, ajusteAltura, 0)
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)

    -- Auto-Clicks con Herramienta en mano (Espada / Estilos)
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool and dist < 120 then tool:Activate() end
    
    -- Disparador secuencial del combo de habilidades
    if dist < 85 then
        if useZ then castSkill("Z") task.wait(0.04) end
        if useX then castSkill("X") task.wait(0.04) end
        if useC then castSkill("C") task.wait(0.04) end
        if useV then castSkill("V") task.wait(0.04) end
    end
    status.Text = "🔥 Fijado: " .. _G.selectedTarget.Parent.Name .. " (" .. math.floor(dist) .. "m)"
end)

print("✅ LEGNA HUB v2.0 Full Premium cargado con éxito en Delta.")
