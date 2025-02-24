local Players = game:GetService("Players")
local Tool = script.Parent
local CollectionService = game:GetService("CollectionService")
local Data = game:GetService("ServerScriptService"):WaitForChild("Data").Data
local SwordInfo = require(game:GetService("ServerScriptService").Data.SwordInfo)
local player = Players:GetPlayerFromCharacter(Tool.Parent)
local Sword = Data.GetSwords:Invoke(player)[Tool:GetAttribute("ID")]

local Debounce = true

local Hitbox = Tool:FindFirstChild("HitBox")

Tool.Activated:Connect(function()
	if Debounce then
		local newHitbox = Hitbox:Clone()
		newHitbox.Parent = Tool
		newHitbox.Transparency = 0
		Debounce = false
		task.wait(1)
		newHitbox.Transparency = 1
		task.wait(0.1)
		Debounce = true
		local Hits = CollectionService:GetTagged("Hit"..player.UserId)
		for _,V in pairs(Hits) do
			CollectionService:RemoveTag(V, "Hit"..player.UserId)
		end
		newHitbox:Destroy()
	end
end)

Hitbox.Touched:Connect(function(otherPart: BasePart) 
	if Players:GetPlayerFromCharacter(otherPart:FindFirstAncestorOfClass("Model")) then
		local otherPlayer = Players:GetPlayerFromCharacter(otherPart:FindFirstAncestorOfClass("Model"))
		if otherPlayer.Character ~= Tool.Parent and not(Debounce) and not(otherPlayer.Character:HasTag("Hit"..player.UserId)) then
			otherPlayer.Character:AddTag("Hit"..player.UserId)
			otherPlayer.Character:FindFirstChildOfClass("Humanoid"):TakeDamage(SwordInfo[Sword.ID].Damage)
		end
	end
end)
