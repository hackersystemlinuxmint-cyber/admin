--// QUEEN-PUFF GLOBAL JOIN ANNOUNCEMENT
--// Put this Script in ServerScriptService

local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")
local StarterGui = game:GetService("StarterGui")

local ADMIN_USERNAME = "xlex175"
local TOPIC = "QueenPuff_GlobalAnnouncement"

local MESSAGE = "<ADMIN PUFF HAS JOINED!>"

local function announce(message)
	print(message)

	-- Sends the message to every server running this game
	local success, err = pcall(function()
		MessagingService:PublishAsync(TOPIC, message)
	end)

	if not success then
		warn("Global announcement failed:", err)
	end
end

local function showAnnouncement(message)
	-- Your GUI system can display this message.
	-- This print is visible in the server output.
	print("[GLOBAL] " .. message)
end

-- Listen for announcements from other servers
pcall(function()
	MessagingService:SubscribeAsync(TOPIC, function(data)
		local message = data.Data

		if typeof(message) == "string" then
			showAnnouncement(message)
		end
	end)
end)

Players.PlayerAdded:Connect(function(player)
	if player.Name:lower() == ADMIN_USERNAME:lower() then
		announce(MESSAGE)
	end
end)
