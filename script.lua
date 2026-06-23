local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

-- CONFIG
local delayC = 0.9
local enabled = true

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 140)
frame.Position = UDim2.new(0.7, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Parent = gui
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.Text = "Combo Panel"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

local comboBtn = Instance.new("TextButton")
comboBtn.Size = UDim2.new(0.8,0,0,40)
comboBtn.Position = UDim2.new(0.1,0,0.35,0)
comboBtn.Text = "EXECUTE"
comboBtn.BackgroundColor3 = Color3.fromRGB(100,0,200)
comboBtn.TextColor3 = Color3.new(1,1,1)
comboBtn.Parent = frame
Instance.new("UICorner", comboBtn)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8,0,0,25)
toggleBtn.Position = UDim2.new(0.1,0,0.7,0)
toggleBtn.Text = "ON"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn)

-- DRAG
local dragging, dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- TOGGLE
toggleBtn.MouseButton1Click:Connect(function()
	enabled = not enabled
	
	if enabled then
		toggleBtn.Text = "ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
	else
		toggleBtn.Text = "OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
	end
end)

-- COMBO
comboBtn.MouseButton1Click:Connect(function()
	if not enabled then return end
	
	task.spawn(function()

		VIM:SendKeyEvent(true, "Z", false, game)
		task.wait(0.15)

		VIM:SendKeyEvent(true, "Three", false, game)
		task.wait(0.2)
		VIM:SendKeyEvent(true, "X", false, game)

		task.wait(0.15)

		VIM:SendKeyEvent(true, "Four", false, game)
		task.wait(0.2)
		VIM:SendKeyEvent(true, "X", false, game)
		task.wait(0.15)
		VIM:SendKeyEvent(true, "Z", false, game)

		task.wait(0.15)

		mousemoverel(0, -300)
		task.wait(0.1)

		VIM:SendKeyEvent(true, "C", false, game)

		task.wait(delayC)

		VIM:SendKeyEvent(true, "Three", false, game)
		task.wait(0.15)
		VIM:SendKeyEvent(true, "Z", false, game)

	end)
end)
