-- SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGURACIÓN ULTRA AGRESIVA
_G.AimbotActive = true
_G.AjusteAltura = -0.9 -- Ajuste profundo para ataques de área/Luz
_G.MaxDistance = 1000

-- BUSCADOR INSTANTÁNEO (MAX AGILIDAD)
local function GetClosestTarget()
    local target = nil
    local shortestDistance = _G.MaxDistance

    -- Escaneo ultra rápido de jugadores
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
            local root = v.Character:FindFirstChild("HumanoidRootPart")
            local hum = v.Character.Humanoid
            
            -- Filtro de salud y equipo
            if root and hum.Health > 0 and v.Team ~= LocalPlayer.Team then
                local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    target = root
                end
            end
        end
    end
    return target
end

-- EJECUCIÓN SIN RETRASO (ZERO LATENCY)
RunService.RenderStepped:Connect(function()
    if _G.AimbotActive then
        local target = GetClosestTarget()
        if target then
            -- Punto de impacto corregido para compensar animaciones de la Light
            local aimPosition = target.Position + Vector3.new(0, _G.AjusteAltura, 0)
            
            -- CFrame directo (Sin Lerp) para máxima velocidad de seguimiento
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
        end
    end
end)

-- INTERFAZ SKYBLUE V4 (ESTILO NEÓN)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Button = Instance.new("TextButton", ScreenGui)

Button.Size = UDim2.new(0, 85, 0, 85)
Button.Position = UDim2.new(0.1, 0, 0.4, 0)
Button.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Azul Sky
Button.Text = "SKYBLUE V4"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Button.Draggable = true
Button.Active = true

local Corner = Instance.new("UICorner", Button)
Corner.CornerRadius = UDim.new(1, 0)

-- Stroke para que se vea más pro
local Stroke = Instance.new("UIStroke", Button)
Stroke.Thickness = 3
Stroke.Color = Color3.fromRGB(255, 255, 255)

Button.MouseButton1Click:Connect(function()
    _G.AimbotActive = not _G.AimbotActive
    if _G.AimbotActive then
        Button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        Stroke.Color = Color3.fromRGB(255, 255, 255)
    else
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Stroke.Color = Color3.fromRGB(255, 0, 0)
    end
end)
