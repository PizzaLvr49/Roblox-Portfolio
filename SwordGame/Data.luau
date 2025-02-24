local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ProfileService = require(ServerScriptService.Data:WaitForChild("ProfileService"))
local MarketplaceService = game:GetService("MarketplaceService")
local IncrementCash = script:WaitForChild("IncrementCash")
local GetCash = script:WaitForChild("GetCash")
local GetSwords = script:WaitForChild("GetSwords")
local SetSwords = script:WaitForChild("SetSwords")

local ProfileTemplate = {
	Cash = 0,
	Swords = {
		{
			ID = 1,
			XP = 0,
			Augments = {
				Slot1 = {Type = 0,Rarity = 0,XP = 0},
				Slot2 = {Type = 0,Rarity = 0,XP = 0},
				Slot3 = {Type = 0,Rarity = 0,XP = 0},
				Slot4 = {Type = 0,Rarity = 0,XP = 0},
				Slot5 = {Type = 0,Rarity = 0,XP = 0}
			}
		}
	}
}

local ProfileStore = ProfileService.GetProfileStore(
	"TestDataDev4",
	ProfileTemplate
)

local Profiles = {}

IncrementCash.OnInvoke = function(player: Player, amount: number)
	-- If "Cash" was not defined in the ProfileTemplate at game launch,
	--   you will have to perform the following:
	if Profiles[player].Data.Cash == nil then
		Profiles[player].Data.Cash = 0
	end
	-- Increment the "Cash" value:
	Profiles[player].Data.Cash += amount
	local Sucess, Result = pcall(function() player:WaitForChild("leaderstats"):FindFirstChild("Cash") end)
	if Sucess then
		Result.Value = Profiles[player].Data.Cash
	end
end

GetCash.OnInvoke = function(player: Player) : number
	return Profiles[player].Data.Cash
end

GetSwords.OnInvoke = function(player: Player)
	return Profiles[player].Data.Swords
end

SetSwords.OnInvoke = function(player: Player, Swords)
	Profiles[player].Data.Swords = Swords
end

local function CreateLeaderStats(player, profile)
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"
	local Cash = Instance.new("NumberValue", leaderstats)
	Cash.Name = "Cash"
	Cash.Value = profile.Data.Cash
end

local function PlayerAdded(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			Profiles[player] = profile
			CreateLeaderStats(player, profile)
			local tool = ServerStorage.Tools:FindFirstChild(profile.Data.Swords[1].ID):Clone()
			tool.Parent = player.Character
			tool.Name = tool:GetAttribute("Name")
			local respawnTool = tool:Clone()
			respawnTool.Parent = player:FindFirstChild("StarterGear")
			-- A profile has been successfully loaded:
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick("Error Loading Profile") 
	end
end

----- Initialize -----

-- In case Players have joined the server earlier than this script ran:
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

----- Connections -----

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	if profile ~= nil then
		profile:Release()
	end
end)
