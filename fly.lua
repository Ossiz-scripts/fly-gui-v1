local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- UI CREATION
local FlyGuiMain = Instance.new("ScreenGui")
FlyGuiMain.Name = "FlyGui_Final_StatusText"
FlyGuiMain.ResetOnSpawn = false
FlyGuiMain.Parent = player:WaitForChild("PlayerGui")

-- Status Label (GUI CLOSED - Visas i 3 sekunder)
local ClosedLabel = Instance.new("TextLabel")
ClosedLabel.Name = "ClosedStatus"
ClosedLabel.Text = "GUI CLOSED"
ClosedLabel.Size = UDim2.new(0, 120, 0, 35)
ClosedLabel.Position = UDim2.new(1, -130, 1, -45)
ClosedLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ClosedLabel.BackgroundTransparency = 0.4
ClosedLabel.TextColor3 = Color3.new(1, 1, 1)
ClosedLabel.Font = Enum.Font.GothamBold
ClosedLabel.TextSize = 14
ClosedLabel.Visible = false
ClosedLabel.Parent = FlyGuiMain
Instance.new("UICorner", ClosedLabel).CornerRadius = UDim.new(0, 6)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 250, 0, 215)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -107)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = FlyGuiMain
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- DRAGGING
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = input.Position; startPos = MainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
MainFrame.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local function createBtn(name, text, pos, size, color, parent)
	local b = Instance.new("TextButton")
	b.Name = name; b.Text = text; b.Position = pos; b.Size = size
	b.BackgroundColor3 = color; b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamBold; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 14
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	return b
end

-- UI Elements
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "FLY & NOCLIP"; Title.Size = UDim2.new(1, 0, 0.18, 0)
Title.BackgroundTransparency = 1; Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold; Title.TextSize = 16

local StartBtn = createBtn("Start", "FLY: OFF (F)", UDim2.new(0.05, 0, 0.2, 0), UDim2.new(0.9, 0, 0.18, 0), Color3.fromRGB(60, 60, 60), MainFrame)
local NoclipBtn = createBtn("Noclip", "NOCLIP: OFF (G)", UDim2.new(0.05, 0, 0.41, 0), UDim2.new(0.9, 0, 0.18, 0), Color3.fromRGB(60, 60, 60), MainFrame)
local PlusBtn = createBtn("Plus", "+10", UDim2.new(0.05, 0, 0.62, 0), UDim2.new(0.2, 0, 0.18, 0), Color3.fromRGB(50, 100, 255), MainFrame)
local SpeedDisp = createBtn("Disp", "Speed: 50", UDim2.new(0.3, 0, 0.62, 0), UDim2.new(0.4, 0, 0.18, 0), Color3.fromRGB(40, 40, 40), MainFrame)
local MinusBtn = createBtn("Minus", "-10", UDim2.new(0.75, 0, 0.62, 0), UDim2.new(0.2, 0, 0.18, 0), Color3.fromRGB(200, 50, 50), MainFrame)

local Hint = Instance.new("TextLabel", MainFrame)
Hint.Text = "Press [L-CTRL] to Hide/Show"
Hint.Position = UDim2.new(0, 0, 0.85, 0)
Hint.Size = UDim2.new(1, 0, 0.12, 0)
Hint.BackgroundTransparency = 1
Hint.TextColor3 = Color3.fromRGB(120, 120, 120)
Hint.Font = Enum.Font.SourceSansItalic
Hint.TextSize = 13

-- LOGIC
local flying, noclip = false, false
local speed = 50
local ctrl = {f = 0, b = 0, l = 0, r = 0, u = 0, d = 0}
local closeCount = 0

local function toggleUI()
	MainFrame.Visible = not MainFrame.Visible
	if not MainFrame.Visible then
		closeCount = closeCount + 1
		local currentSession = closeCount
		ClosedLabel.Visible = true
		task.wait(3)
		if currentSession == closeCount then
			ClosedLabel.Visible = false
		end
	else
		ClosedLabel.Visible = false
	end
end

RunService.Stepped:Connect(function()
	if noclip and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

local function toggleFly()
	if flying then 
		flying = false
		StartBtn.Text = "FLY: OFF (F)"
	else
		flying = true
		StartBtn.Text = "FLY: ON (F)"
		local char = player.Character; local root = char:WaitForChild("HumanoidRootPart")
		local bg = Instance.new("BodyGyro", root); bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 9e4
		local bv = Instance.new("BodyVelocity", root); bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			while flying and char and root do RunService.RenderStepped:Wait()
				char.Humanoid.PlatformStand = true; local cam = workspace.CurrentCamera.CFrame
				bv.velocity = ((cam.LookVector * (ctrl.f + ctrl.b)) + (cam * CFrame.new(ctrl.l + ctrl.r, (ctrl.u + ctrl.d), 0).Position - cam.Position)).Unit * speed
				bg.cframe = cam
				if (ctrl.f+ctrl.b+ctrl.l+ctrl.r+ctrl.u+ctrl.d) == 0 then bv.velocity = Vector3.new(0,0,0) end
			end
			bg:Destroy(); bv:Destroy()
			if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
		end)
	end
end

StartBtn.MouseButton1Click:Connect(toggleFly)
NoclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip; NoclipBtn.Text = noclip and "NOCLIP: ON (G)" or "NOCLIP: OFF (G)"
end)
PlusBtn.MouseButton1Click:Connect(function() speed = speed + 10; SpeedDisp.Text = "Speed: "..speed end)
MinusBtn.MouseButton1Click:Connect(function() speed = math.max(10, speed - 10); SpeedDisp.Text = "Speed: "..speed end)

UserInputService.InputBegan:Connect(function(i, g) if g then return end
	if i.KeyCode == Enum.KeyCode.F then toggleFly()
	elseif i.KeyCode == Enum.KeyCode.G then noclip = not noclip; NoclipBtn.Text = noclip and "NOCLIP: ON (G)" or "NOCLIP: OFF (G)"
	elseif i.KeyCode == Enum.KeyCode.LeftControl then toggleUI()
	elseif i.KeyCode == Enum.KeyCode.W then ctrl.f = 1 elseif i.KeyCode == Enum.KeyCode.S then ctrl.b = -1
	elseif i.KeyCode == Enum.KeyCode.A then ctrl.l = -1 elseif i.KeyCode == Enum.KeyCode.D then ctrl.r = 1
	elseif i.KeyCode == Enum.KeyCode.E then ctrl.u = 1 elseif i.KeyCode == Enum.KeyCode.Q then ctrl.d = -1 end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.W or i.KeyCode == Enum.KeyCode.S then ctrl.f, ctrl.b = 0, 0
	elseif i.KeyCode == Enum.KeyCode.A or i.KeyCode == Enum.KeyCode.D then ctrl.l, ctrl.r = 0, 0
	elseif i.KeyCode == Enum.KeyCode.E or i.KeyCode == Enum.KeyCode.Q then ctrl.u, ctrl.d = 0, 0 end
end)
