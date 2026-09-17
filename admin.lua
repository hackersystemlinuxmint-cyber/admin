--// QUEEN-PUFF ADMIN SYSTEM
--// Place this Script inside ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

--------------------------------------------------
-- CONFIGURATION
--------------------------------------------------

local PREFIX = "/"

-- IMPORTANT:
-- Replace this with your Roblox UserId.
-- You can add multiple UserIds.
local ADMINS = {
	[123456789] = true,
}

local MAX_SPEED = 200
local MAX_SIZE = 10

--------------------------------------------------
-- REMOTE EVENT
--------------------------------------------------

local remote = ReplicatedStorage:FindFirstChild("QueenPuffCommand")

if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = "QueenPuffCommand"
	remote.Parent = ReplicatedStorage
end

--------------------------------------------------
-- ADMIN CHECK
--------------------------------------------------

local function isAdmin(player)
	return ADMINS[player.UserId] == true
end

--------------------------------------------------
-- FIND PLAYER
--------------------------------------------------

local function findPlayer(name)
	if not name then
		return nil
	end

	name = string.lower(name)

	for _, player in ipairs(Players:GetPlayers()) do
		if string.lower(player.Name) == name
			or string.lower(player.DisplayName) == name then
			return player
		end
	end

	-- Partial name
	for _, player in ipairs(Players:GetPlayers()) do
		if string.sub(string.lower(player.Name), 1, #name) == name then
			return player
		end
	end

	return nil
end

--------------------------------------------------
-- CHARACTER HELPERS
--------------------------------------------------

local function getCharacter(player)
	if not player then
		return nil
	end

	return player.Character
end

local function getHumanoid(player)
	local character = getCharacter(player)

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

--------------------------------------------------
-- SEND MESSAGE TO GUI
--------------------------------------------------

local function message(player, text)
	remote:FireClient(player, "Message", text)
end

--------------------------------------------------
-- GOD MODE
--------------------------------------------------

local function setGod(player, enabled)
	local humanoid = getHumanoid(player)

	if not humanoid then
		return
	end

	if enabled then
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		humanoid:SetAttribute("QueenPuffGod", true)

		message(player, "God mode enabled.")
	else
		humanoid:SetAttribute("QueenPuffGod", false)

		humanoid.MaxHealth = 100
		humanoid.Health = math.min(humanoid.Health, humanoid.MaxHealth)

		message(player, "God mode disabled.")
	end
end

--------------------------------------------------
-- INVISIBILITY
--------------------------------------------------

local function setInvisible(player, enabled)
	local character = getCharacter(player)

	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			if enabled then
				object:SetAttribute("QueenPuffOriginalTransparency", object.Transparency)
				object.Transparency = 1
			else
				local original = object:GetAttribute(
					"QueenPuffOriginalTransparency"
				)

				if original ~= nil then
					object.Transparency = original
				else
					object.Transparency = 0
				end
			end
		elseif object:IsA("Decal") then
			if enabled then
				object:SetAttribute(
					"QueenPuffOriginalTransparency",
					object.Transparency
				)

				object.Transparency = 1
			else
				local original = object:GetAttribute(
					"QueenPuffOriginalTransparency"
				)

				if original ~= nil then
					object.Transparency = original
				else
					object.Transparency = 0
				end
			end
		end
	end

	message(
		player,
		enabled and "You are now invisible." or "You are visible again."
	)
end

--------------------------------------------------
-- HEAL
--------------------------------------------------

local function heal(player)
	local humanoid = getHumanoid(player)

	if not humanoid then
		return
	end

	humanoid.Health = humanoid.MaxHealth
	message(player, "Health restored.")
end

--------------------------------------------------
-- FREEZE
--------------------------------------------------

local function freeze(target, enabled)
	local humanoid = getHumanoid(target)

	if not humanoid then
		return false
	end

	if enabled then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid:SetAttribute("QueenPuffFrozen", true)
	else
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		humanoid:SetAttribute("QueenPuffFrozen", false)
	end

	return true
end

--------------------------------------------------
-- TELEPORT
--------------------------------------------------

local function teleportTo(player, target)
	local character = getCharacter(player)
	local targetCharacter = getCharacter(target)

	if not character or not targetCharacter then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")

	if not root or not targetRoot then
		return false
	end

	root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)

	return true
end

--------------------------------------------------
-- BRING PLAYER
--------------------------------------------------

local function bringPlayer(player, target)
	local character = getCharacter(player)
	local targetCharacter = getCharacter(target)

	if not character or not targetCharacter then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")

	if not root or not targetRoot then
		return false
	end

	targetRoot.CFrame = root.CFrame * CFrame.new(0, 0, -5)

	return true
end

--------------------------------------------------
-- SIZE
--------------------------------------------------

local function resizePlayer(target, amount)
	local character = getCharacter(target)

	if not character then
		return false
	end

	amount = math.clamp(amount, 0.5, MAX_SIZE)

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		local description = humanoid:GetAppliedDescription()

		description.HeightScale = amount
		description.WidthScale = amount
		description.DepthScale = amount
		description.HeadScale = amount

		humanoid:ApplyDescription(description)
	end

	return true
end

--------------------------------------------------
-- RAIN EFFECT
--------------------------------------------------

local function createRain(player)
	local character = getCharacter(player)

	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Parent = root

	local emitter = Instance.new("ParticleEmitter")
	emitter.Parent = attachment

	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = 150
	emitter.Lifetime = NumberRange.new(1, 2)
	emitter.Speed = NumberRange.new(30, 50)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Acceleration = Vector3.new(0, -50, 0)
	emitter.Size = NumberSequence.new(0.15)

	Debris:AddItem(attachment, 15)

	message(player, "Rain zone created for 15 seconds.")
end

--------------------------------------------------
-- RAGE
--------------------------------------------------

local function rage(player)
	local character = getCharacter(player)

	if not character then
		return
	end

	character:SetAttribute("QueenPuffRage", 100)

	message(player, "Rage meter filled.")
end

--------------------------------------------------
-- TIME
--------------------------------------------------

local function setDay()
	Lighting.ClockTime = 14
end

local function setFullMoon()
	Lighting.ClockTime = 0
end

--------------------------------------------------
-- COMMAND EXECUTION
--------------------------------------------------

local function executeCommand(player, rawCommand)

	if not isAdmin(player) then
		message(player, "You are not authorized to use Queen-Puff.")
		return
	end

	if typeof(rawCommand) ~= "string" then
		return
	end

	rawCommand = string.sub(rawCommand, 1, 200)

	if string.sub(rawCommand, 1, 1) == PREFIX then
		rawCommand = string.sub(rawCommand, 2)
	end

	local args = string.split(rawCommand, " ")

	local command = string.lower(args[1] or "")

	--------------------------------------------------
	-- TIME
	--------------------------------------------------

	if command == "fm" or command == "daytime" then

		setDay()
		message(player, "Time changed to day.")

	--------------------------------------------------

	elseif command == "unfm" or command == "nighttime" then

		setFullMoon()
		message(player, "Time changed to full-moon night.")

	--------------------------------------------------
	-- INVISIBLE
	--------------------------------------------------

	elseif command == "invis" then

		setInvisible(player, true)

	elseif command == "uninvis" then

		setInvisible(player, false)

	--------------------------------------------------
	-- GOD
	--------------------------------------------------

	elseif command == "god" then

		setGod(player, true)

	elseif command == "ungod" then

		setGod(player, false)

	--------------------------------------------------
	-- SPEED
	--------------------------------------------------

	elseif command == "speed" then

		local speed = tonumber(args[2])

		if not speed then
			message(player, "Usage: /speed [number]")
			return
		end

		speed = math.clamp(speed, 0, MAX_SPEED)

		local humanoid = getHumanoid(player)

		if humanoid then
			humanoid.WalkSpeed = speed
			message(player, "Speed set to " .. speed .. ".")
		end

	--------------------------------------------------
	-- HEAL
	--------------------------------------------------

	elseif command == "heal" then

		heal(player)

	--------------------------------------------------
	-- TELEPORT
	--------------------------------------------------

	elseif command == "tp" then

		local target = findPlayer(args[2])

		if not target then
			message(player, "Player not found.")
			return
		end

		if teleportTo(player, target) then
			message(player, "Teleported to " .. target.Name .. ".")
		end

	--------------------------------------------------
	-- BRING
	--------------------------------------------------

	elseif command == "br" then

		local target = findPlayer(args[2])

		if not target then
			message(player, "Player not found.")
			return
		end

		if bringPlayer(player, target) then
			message(player, "Brought " .. target.Name .. ".")
		end

	--------------------------------------------------
	-- FREEZE
	--------------------------------------------------

	elseif command == "freeze" then

		local target = findPlayer(args[2])

		if not target then
			message(player, "Player not found.")
			return
		end

		if freeze(target, true) then
			message(player, "Froze " .. target.Name .. ".")
		end

	--------------------------------------------------

	elseif command == "unfreeze" then

		local target = findPlayer(args[2])

		if not target then
			message(player, "Player not found.")
			return
		end

		if freeze(target, false) then
			message(player, "Unfroze " .. target.Name .. ".")
		end

	--------------------------------------------------
	-- KILL
	--------------------------------------------------

	elseif command == "kill" then

		local targetName = args[2]

		if not targetName then
			message(player, "Usage: /kill [username]")
			return
		end

		if string.lower(targetName) == "all"
			or string.lower(targetName) == "others" then

			for _, target in ipairs(Players:GetPlayers()) do

				if target ~= player
					or string.lower(targetName) == "all" then

					local humanoid = getHumanoid(target)

					if humanoid then
						humanoid.Health = 0
					end
				end
			end

			message(player, "Players reset.")

		else

			local target = findPlayer(targetName)

			if not target then
				message(player, "Player not found.")
				return
			end

			local humanoid = getHumanoid(target)

			if humanoid then
				humanoid.Health = 0
				message(player, "Reset " .. target.Name .. ".")
			end
		end

	--------------------------------------------------
	-- SIZE
	--------------------------------------------------

	elseif command == "size" then

		local targetName = args[2]
		local amount = tonumber(args[3])

		if not targetName or not amount then
			message(player, "Usage: /size [username] [number]")
			return
		end

		if string.lower(targetName) == "all" then

			for _, target in ipairs(Players:GetPlayers()) do
				resizePlayer(target, amount)
			end

			message(player, "Resized all players.")

		else

			local target = findPlayer(targetName)

			if not target then
				message(player, "Player not found.")
				return
			end

			resizePlayer(target, amount)
			message(player, "Resized " .. target.Name .. ".")
		end

	--------------------------------------------------
	-- RAIN
	--------------------------------------------------

	elseif command == "rain" then

		createRain(player)

	--------------------------------------------------
	-- RAGE
	--------------------------------------------------

	elseif command == "rage" then

		rage(player)

	--------------------------------------------------
	-- HELP
	--------------------------------------------------

	elseif command == "help"
		or command == "commands" then

		remote:FireClient(player, "Help")

	else

		message(player, "Unknown command: /" .. command)
	end
end

--------------------------------------------------
-- REMOTE CONNECTION
--------------------------------------------------

remote.OnServerEvent:Connect(function(player, command)
	executeCommand(player, command)
end)

--------------------------------------------------
-- ADMIN SETUP
--------------------------------------------------

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function(character)

		task.wait(1)

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid:GetAttribute("QueenPuffGod") then
			humanoid.MaxHealth = math.huge
			humanoid.Health = math.huge
		end
	end)

	if isAdmin(player) then
		task.wait(2)
		message(player, "Queen-Puff Admin loaded. Type /help.")
	end
end)
2. Queen-Puff GUI

Create:

StarterPlayer → StarterPlayerScripts → LocalScript

Name it:

QueenPuffGUI

Paste:

--// QUEEN-PUFF ADMIN GUI
--// Place this LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("QueenPuffCommand")

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "QueenPuff"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 500, 0, 430)
main.Position = UDim2.new(0.5, -250, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
main.BorderSizePixel = 0
main.Visible = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = main

--------------------------------------------------
-- TITLE
--------------------------------------------------

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 55)
title.Position = UDim2.new(0, 20, 0, 5)
title.BackgroundTransparency = 1
title.Text = "QUEEN-PUFF"
title.TextSize = 26
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 25)
subtitle.Position = UDim2.new(0, 20, 0, 48)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Admin Control Panel"
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham
subtitle.TextColor3 = Color3.fromRGB(160, 160, 170)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 40, 0, 40)
close.Position = UDim2.new(1, -50, 0, 10)
close.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
close.Text = "×"
close.TextSize = 25
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = close

--------------------------------------------------
-- LOGO
--------------------------------------------------

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.Size = UDim2.new(0, 65, 0, 65)
logo.Position = UDim2.new(1, -135, 0, 55)
logo.BackgroundTransparency = 1

-- Replace this with the Roblox image asset ID
-- after uploading your Queen-Puff logo.
logo.Image = "rbxassetid://0"

logo.Parent = main

--------------------------------------------------
-- COMMAND INPUT
--------------------------------------------------

local input = Instance.new("TextBox")
input.Name = "CommandInput"
input.Size = UDim2.new(1, -40, 0, 48)
input.Position = UDim2.new(0, 20, 0, 100)
input.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
input.BorderSizePixel = 0
input.PlaceholderText = "Enter command...  /help"
input.Text = ""
input.TextSize = 16
input.Font = Enum.Font.Gotham
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
input.ClearTextOnFocus = false
input.Parent = main

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 10)
inputCorner.Parent = input

--------------------------------------------------
-- EXECUTE BUTTON
--------------------------------------------------

local execute = Instance.new("TextButton")
execute.Size = UDim2.new(0, 110, 0, 48)
execute.Position = UDim2.new(1, -130, 0, 158)
execute.BackgroundColor3 = Color3.fromRGB(90, 50, 180)
execute.BorderSizePixel = 0
execute.Text = "EXECUTE"
execute.TextSize = 14
execute.Font = Enum.Font.GothamBold
execute.TextColor3 = Color3.fromRGB(255, 255, 255)
execute.Parent = main

local executeCorner = Instance.new("UICorner")
executeCorner.CornerRadius = UDim.new(0, 10)
executeCorner.Parent = execute

--------------------------------------------------
-- STATUS
--------------------------------------------------

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -170, 0, 48)
status.Position = UDim2.new(0, 20, 0, 158)
status.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
status.BorderSizePixel = 0
status.Text = "Ready."
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.TextColor3 = Color3.fromRGB(190, 190, 200)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 10)
statusCorner.Parent = status

--------------------------------------------------
-- COMMAND LIST
--------------------------------------------------

local list = Instance.new("ScrollingFrame")
list.Name = "CommandList"
list.Size = UDim2.new(1, -40, 0, 195)
list.Position = UDim2.new(0, 20, 0, 220)
list.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = main

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 10)
listCorner.Parent = list

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.Parent = list

--------------------------------------------------
-- COMMANDS
--------------------------------------------------

local commands = {
	"/fm",
	"/unfm",
	"/invis",
	"/uninvis",
	"/god",
	"/ungod",
	"/speed [number]",
	"/heal",
	"/tp [username]",
	"/br [username]",
	"/freeze [username]",
	"/unfreeze [username]",
	"/kill [username]",
	"/kill all",
	"/kill others",
	"/size [username] [number]",
	"/size all [number]",
	"/rain",
	"/rage",
	"/help",
}

for _, command in ipairs(commands) do

	local item = Instance.new("TextButton")

	item.Size = UDim2.new(1, -10, 0, 30)
	item.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	item.BorderSizePixel = 0

	item.Text = "  " .. command
	item.TextSize = 13
	item.Font = Enum.Font.Gotham
	item.TextColor3 = Color3.fromRGB(220, 220, 230)
	item.TextXAlignment = Enum.TextXAlignment.Left

	item.Parent = list

	local itemCorner = Instance.new("UICorner")
	itemCorner.CornerRadius = UDim.new(0, 6)
	itemCorner.Parent = item

	item.MouseButton1Click:Connect(function()

		local cleanCommand = command

		cleanCommand = string.gsub(
			cleanCommand,
			"%s*%[number%]",
			" 100"
		)

		cleanCommand = string.gsub(
			cleanCommand,
			"%s*%[username%]",
			""
		)

		input.Text = cleanCommand
		input:CaptureFocus()
	end)
end

task.wait()

list.CanvasSize = UDim2.new(
	0,
	0,
	0,
	layout.AbsoluteContentSize.Y + 10
)

--------------------------------------------------
-- EXECUTE
--------------------------------------------------

local function executeCommand()

	local command = input.Text

	if command == "" then
		status.Text = "Enter a command first."
		return
	end

	remote:FireServer(command)

	status.Text = "Executed: " .. command
	input.Text = ""
end

execute.MouseButton1Click:Connect(executeCommand)

input.FocusLost:Connect(function(enterPressed)

	if enterPressed then
		executeCommand()
	end
end)

--------------------------------------------------
-- SERVER MESSAGES
--------------------------------------------------

remote.OnClientEvent:Connect(function(action, data)

	if action == "Message" then

		status.Text = tostring(data)

	elseif action == "Help" then

		status.Text = "Available commands are shown below."
	end
end)

--------------------------------------------------
-- OPEN / CLOSE
--------------------------------------------------

close.MouseButton1Click:Connect(function()
	main.Visible = false
end)

--------------------------------------------------
-- TOGGLE WITH RIGHT SHIFT
--------------------------------------------------

UserInputService.InputBegan:Connect(function(inputObject, processed)

	if processed then
		return
	end

	if inputObject.KeyCode == Enum.KeyCode.RightShift then
		main.Visible = not main.Visible
	end
end)

--------------------------------------------------
-- DRAG WINDOW
--------------------------------------------------

local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(inputObject)

	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = inputObject.Position
		startPosition = main.Position
	end
end)

UserInputService.InputChanged:Connect(function(inputObject)

	if not dragging then
		return
	end

	if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local delta = inputObject.Position - dragStart

	main.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

UserInputService.InputEnded:Connect(function(inputObject)

	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
