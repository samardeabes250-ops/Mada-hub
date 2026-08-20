-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- CORE REFERENCES
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

-- VALUES
local isFlying = false
local isEspActive = false
local flySpeed = 5 -- Default speed scale (1 to 10)
local baseSpeedMultiplier = 15 -- From the original working physics flight math
local walkSpeedScale = 5
local jumpPowerScale = 5

-- RESP AWN MANAGEMENT
LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
	HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
	Humanoid = char:WaitForChild("Humanoid")
	
	if isFlying then 
		task.wait(0.1)
		BodyVelocity.Parent = HumanoidRootPart
		BodyGyro.Parent = HumanoidRootPart
		Humanoid.PlatformStand = true 
	end
	
	Humanoid.WalkSpeed = 16 + ((walkSpeedScale - 5) * 10)
	if Humanoid.UseJumpPower then Humanoid.JumpPower = 50 + ((jumpPowerScale - 5) * 15)
	else Humanoid.JumpHeight = 7.2 + ((jumpPowerScale - 5) * 2) end
end)

-- ABSOLUTE CANVAS ELEMENT (Forced Render Hierarchy to ensure it shows)
local ForcedGui = Instance.new("ScreenGui")
ForcedGui.Name = "MadaHubCenteredV13"
ForcedGui.ResetOnSpawn = false
pcall(function() ForcedGui.Parent = CoreGui end)
if not ForcedGui.Parent then ForcedGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- FLOATING MINIMIZE/OPEN TOGGLE BUTTON
local FloatingToggle = Instance.new("TextButton")
FloatingToggle.Size = UDim2.new(0, 55, 0, 55)
FloatingToggle.Position = UDim2.new(0.03, 0, 0.25, 0)
FloatingToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
FloatingToggle.BorderSizePixel = 2
FloatingToggle.BorderColor3 = Color3.fromRGB(255, 30, 70)
FloatingToggle.Text = "M"
FloatingToggle.TextColor3 = Color3.fromRGB(255, 30, 70)
FloatingToggle.Font = Enum.Font.SourceSansBold
FloatingToggle.TextSize = 24
FloatingToggle.Visible = false 
FloatingToggle.Parent = ForcedGui

-- MAIN CONTROL PANEL (Centered and Enlarged)
local ControlBox = Instance.new("Frame")
ControlBox.Size = UDim2.new(0, 240, 0, 270) 
ControlBox.Position = UDim2.new(0.5, -120, 0.5, -135) 
ControlBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ControlBox.BorderSizePixel = 2
ControlBox.BorderColor3 = Color3.fromRGB(255, 30, 70) 
ControlBox.Active = true
ControlBox.Parent = ForcedGui

-- TITLE BANNER AREA
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "MADA HUB"
Title.TextColor3 = Color3.fromRGB(255, 30, 70)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Title.Parent = ControlBox

-- INLINE MINIMIZE UTILITY BUTTON
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 2)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "_"
MinBtn.TextColor3 = Color3.fromRGB(255, 30, 70)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 18
MinBtn.Parent = ControlBox

-- ORIGINAL PHYSICS LOCOMOTION OBJECTS
local BodyVelocity = Instance.new("BodyVelocity")
local BodyGyro = Instance.new("BodyGyro")

local function startFlying()
	if not HumanoidRootPart then return end
	BodyVelocity.Velocity = Vector3.new(0, 0, 0)
	BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyVelocity.Parent = HumanoidRootPart
	
	BodyGyro.CFrame = HumanoidRootPart.CFrame
	BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.Parent = HumanoidRootPart
	
	Humanoid.PlatformStand = true
end

local function stopFlying()
	BodyVelocity.Parent = nil
	BodyGyro.Parent = nil
	if Humanoid then
		Humanoid.PlatformStand = false
	end
end

-- BUTTON FACTORY LAYOUT MAPPING
local function buildRawButton(yOffset, name, textOn, textOff, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0.9, 0, 0, 36) 
	Btn.Position = UDim2.new(0.05, 0, 0, yOffset)
	Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	Btn.Text = name .. ": " .. textOff
	Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	Btn.Font = Enum.Font.SourceSansBold
	Btn.TextSize = 14
	Btn.Parent = ControlBox
	
	local toggle = false
	Btn.MouseButton1Click:Connect(function()
		toggle = not toggle
		if toggle then
			Btn.BackgroundColor3 = Color3.fromRGB(255, 30, 70)
			Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			Btn.Text = name .. ": " .. textOn
		else
			Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			Btn.Text = name .. ": " .. textOff
		end
		callback(toggle)
	end)
	return Btn
end

local function buildRawStepper(yOffset, name, start, callback)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.45, 0, 0, 36)
	Label.Position = UDim2.new(0.05, 0, 0, yOffset)
	Label.Text = name .. ": " .. tostring(start)
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.Font = Enum.Font.SourceSansBold
	Label.TextSize = 13
	Label.BackgroundTransparency = 1
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ControlBox
	
	local Up = Instance.new("TextButton")
	Up.Size = UDim2.new(0.2, 0, 0, 30)
	Up.Position = UDim2.new(0.52, 0, 0, yOffset + 3)
	Up.Text = "+"
	Up.TextSize = 16
	Up.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	Up.TextColor3 = Color3.fromRGB(255, 255, 255)
	Up.Parent = ControlBox
	
	local Down = Instance.new("TextButton")
	Down.Size = UDim2.new(0.2, 0, 0, 30)
	Down.Position = UDim2.new(0.75, 0, 0, yOffset + 3)
	Down.Text = "-"
	Down.TextSize = 16
	Down.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	Down.TextColor3 = Color3.fromRGB(255, 255, 255)
	Down.Parent = ControlBox
	
	local current = start
	Up.MouseButton1Click:Connect(function()
		if current < 10 then
			current = current + 1
			Label.Text = name .. ": " .. tostring(current)
			callback(current)
		end
	end)
	Down.MouseButton1Click:Connect(function()
		if current > 1 then
			current = current - 1
			Label.Text = name .. ": " .. tostring(current)
			callback(current)
		end
	end)
end

-- GENERATE ENLARGED MENU ITEMS WITH PROPER OFFSETS
buildRawButton(45, "Flight Engine", "ON", "OFF", function(state)
	isFlying = state
	if isFlying then
		startFlying()
	else
		stopFlying()
	end
end)

buildRawStepper(85, "Fly Speed", flySpeed, function(v) flySpeed = v end)
buildRawStepper(125, "Run Speed", walkSpeedScale, function(v)
	walkSpeedScale = v
	if Humanoid then Humanoid.WalkSpeed = 16 + ((v - 5) * 10) end
end)
buildRawStepper(165, "Jump Boost", jumpPowerScale, function(v)
	jumpPowerScale = v
	if Humanoid then
		if Humanoid.UseJumpPower then Humanoid.JumpPower = 50 + ((v - 5) * 15)
		else Humanoid.JumpHeight = 7.2 + ((v - 5) * 2) end
	end
end)

-- INTEGRATE CHAMS TRACKING INTERFACES
local function applyChams(p)
	if p == LocalPlayer then return end
	local function draw(char)
		if char:FindFirstChild("MadaForcedHighlight") then return end
		local hl = Instance.new("Highlight")
		hl.Name = "MadaForcedHighlight"
		hl.FillColor = Color3.fromRGB(255, 30, 70)
		hl.FillTransparency = 0.5
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.Enabled = isEspActive
		hl.Adornee = char
		hl.Parent = char
	end
	if p.Character then draw(p.Character) end
	p.CharacterAdded:Connect(draw)
end
for _, pl in pairs(Players:GetPlayers()) do applyChams(pl) end
Players.PlayerAdded:Connect(applyChams)

buildRawButton(210, "Player ESP Box", "ON", "OFF", function(state)
	isEspActive = state
	for _, pl in pairs(Players:GetPlayers()) do
		if pl.Character and pl.Character:FindFirstChild("MadaForcedHighlight") then
			pl.Character.MadaForcedHighlight.Enabled = isEspActive
		end
	end
end)

-- INTERACTION MANAGEMENT: MINIMIZE WINDOW MECHANISMS
MinBtn.MouseButton1Click:Connect(function()
	ControlBox.Visible = false
	FloatingToggle.Visible = true
end)

FloatingToggle.MouseButton1Click:Connect(function()
	ControlBox.Visible = true
	FloatingToggle.Visible = false
end)

-- ORIGINAL SMOOTH DIRECTIONAL LOCOMOTION ENGINE UPDATER
RunService.RenderStepped:Connect(function()
	if isFlying and Character and HumanoidRootPart and Humanoid then
		-- Keeps character rotated relative to camera angle perfectly
		BodyGyro.CFrame = Camera.CFrame
		
		-- Capture exact dynamic mobile thumbstick placement vectors
		local moveDirection = Humanoid.MoveDirection
		
		if moveDirection.Magnitude > 0 then
			local velocityVector = moveDirection * (flySpeed * baseSpeedMultiplier)
			BodyVelocity.Velocity = Vector3.new(velocityVector.X, Camera.CFrame.LookVector.Y * (flySpeed * baseSpeedMultiplier) * moveDirection.Magnitude, velocityVector.Z)
		else
			-- Locks physics positioning straight in midair when releasing joystick
			BodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end
	end
end)
