--// QUEEN-PUFF BLOX FRUITS ADMIN
--// Roblox Studio / Luau

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PREFIX = "/"

--// PUT YOUR ROBLOX USER ID HERE
local ADMINS = {
	[123456789] = true,
}

local MAX_SPEED = 200
local MAX_SIZE = 10

local Remote = ReplicatedStorage:FindFirstChild("QueenPuffCommand")

if not Remote then
	Remote = Instance.new("RemoteEvent")
	Remote.Name = "QueenPuffCommand"
	Remote.Parent = ReplicatedStorage
end

local function isAdmin(player)
	return ADMINS[player.UserId] == true
end

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

	for _, player in ipairs(Players:GetPlayers()) do
		if string.sub(string.lower(player.Name), 1, #name) == name then
			return player
		end
	end

	return nil
end

local function getCharacter(player)
	return player and player.Character
end

local function getHumanoid(player)
	local character = getCharacter(player)
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function god(player)
	local humanoid = getHumanoid(player)
	if not humanoid then return end

	humanoid.MaxHealth = math.huge
	humanoid.Health = math.huge
end

local function ungod(player)
	local humanoid = getHumanoid(player)
	if not humanoid then return end

	humanoid.MaxHealth = 100
	humanoid.Health = math.min(humanoid.Health, 100)
end

local function invisible(player, state)
	local character = getCharacter(player)
	if not character then return end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.Transparency = state and 1 or 0
		elseif object:IsA("Decal") then
			object.Transparency = state and 1 or 0
		end
	end
end

local function speed(player, value)
	local humanoid = getHumanoid(player)
	if not humanoid then return end

	value = math.clamp(tonumber(value) or 16, 0, MAX_SPEED)
	humanoid.WalkSpeed = value
end

local function heal(player)
	local humanoid = getHumanoid(player)
	if humanoid then
		humanoid.Health = humanoid.MaxHealth
	end
end

local function teleport(player, target)
	if not target then return end

	local character = getCharacter(player)
	local targetCharacter = getCharacter(target)

	if character and targetCharacter then
		local root = character:FindFirstChild("HumanoidRootPart")
		local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")

		if root and targetRoot then
			root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
		end
	end
end

local function bring(player, target)
	if not target then return end
	teleport(target, player)
end

local function freeze(player, state)
	local character = getCharacter(player)
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.Anchored = state
	end
end

local function kill(player)
	local humanoid = getHumanoid(player)
	if humanoid then
		humanoid.Health = 0
	end
end

local function resize(player, amount)
	local character = getCharacter(player)
	if not character then return end

	amount = math.clamp(tonumber(amount) or 1, 0.5, MAX_SIZE)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.BodyDepthScale.Value = amount
		humanoid.BodyHeightScale.Value = amount
		humanoid.BodyWidthScale.Value = amount
		humanoid.HeadScale.Value = amount
	end
end

local function setDay()
	Lighting.ClockTime = 14
end

local function setNight()
	Lighting.ClockTime = 0
end

local function rain()
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Parent = Lighting

	task.delay(10, function()
		if atmosphere then
			atmosphere:Destroy()
		end
	end)
end

local function executeCommand(player, message)
	if not isAdmin(player) then
		return
	end

	if string.sub(message, 1, 1) ~= PREFIX then
		return
	end

	local args = string.split(string.sub(message, 2), " ")
	local command = string.lower(args[1] or "")

	--// DAY / NIGHT
	if command == "fm" or command == "daytime" then
		setDay()

	elseif command == "unfm" or command == "nighttime" then
		setNight()

	--// GOD
	elseif command == "god" then
		god(player)

	elseif command == "ungod" then
		ungod(player)

	--// INVISIBILITY
	elseif command == "invis" then
		invisible(player, true)

	elseif command == "uninvis" then
		invisible(player, false)

	--// SPEED
	elseif command == "speed" then
		speed(player, args[2])

	--// HEAL
	elseif command == "heal" then
		heal(player)

	--// TELEPORT
	elseif command == "tp" then
		local target = findPlayer(args[2])
		teleport(player, target)

	--// BRING
	elseif command == "br" then
		local target = findPlayer(args[2])
		bring(player, target)

	--// FREEZE
	elseif command == "freeze" then
		local target = findPlayer(args[2])
		if target then
			freeze(target, true)
		end

	elseif command == "unfreeze" then
		local target = findPlayer(args[2])
		if target then
			freeze(target, false)
		end

	--// KILL
	elseif command == "kill" then
		local targetName = args[2]

		if targetName == "all" then
			for _, target in ipairs(Players:GetPlayers()) do
				kill(target)
			end

		elseif targetName == "others" then
			for _, target in ipairs(Players:GetPlayers()) do
				if target ~= player then
					kill(target)
				end
			end

		else
			local target = findPlayer(targetName)
			if target then
				kill(target)
			end
		end

	--// SIZE
	elseif command == "size" then
		local targetName = args[2]
		local amount = args[3]

		if targetName == "all" then
			for _, target in ipairs(Players:GetPlayers()) do
				resize(target, amount)
			end
		else
			local target = findPlayer(targetName)
			if target then
				resize(target, amount)
			end
		end

	--// RAIN
	elseif command == "rain" then
		rain()

	--// BLOX-FRUITS-STYLE COMMANDS
	elseif command == "g" then
		local fruit = args[2]
		print("Giving fruit abilities:", fruit)

	elseif command == "c" then
		local fruit = args[2]
		print("Creating physical fruit:", fruit)

	elseif command == "f" then
		local fightingStyle = table.concat(args, " ", 2)
		print("Setting fighting style:", fightingStyle)

	elseif command == "race" then
		local race = args[2]
		print("Setting race:", race)

	elseif command == "spawn" then
		local npc = table.concat(args, " ", 2)
		print("Spawning NPC:", npc)

	elseif command == "aw" then
		local fruit = args[2]
		print("Awakening fruit:", fruit)

	elseif command == "unaw" then
		local fruit = args[2]
		print("Removing awakening:", fruit)

	elseif command == "rage" then
		print(player.Name .. " activated RAGE!")

	elseif command == "fruitrain" then
		print("Fruit rain activated!")

	elseif command == "help" then
		print([[
		QUEEN-PUFF COMMANDS

		/fm
		/unfm
		/god
		/ungod
		/invis
		/uninvis
		/speed 100
		/heal
		/tp Player
		/br Player
		/freeze Player
		/unfreeze Player
		/kill Player
		/kill all
		/size Player 3
		/rain

		/g Dark
		/c Dark
		/f Dragon Talon
		/race Rabbit
		/aw Dark
		/unaw Dark
		/spawn Bandit
		/rage
		/fruitrain
		]])
	end
end

Remote.OnServerEvent:Connect(function(player, message)
	if typeof(message) ~= "string" then
		return
	end

	executeCommand(player, message)
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)

		if isAdmin(player) then
			print("Queen-Puff admin loaded for " .. player.Name)
		end
	end)
end)
