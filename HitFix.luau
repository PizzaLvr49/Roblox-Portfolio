local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UpdateLocal = script:WaitForChild("UpdateLocal")

local HitFix = {}
HitFix.Registers = {}
HitFix.StorageTime = 1
HitFix.TolerableTolerance = 10
HitFix.TimeOutTolerance = 2

function HitFix:CreateHitBoxRegister(player: Player)
	if RunService:IsClient() then error("CreateHitBoxRegister must be invoked from the server") end
	if not player then warn("Player is nil") return end

	HitFix.Registers[player] = { Local = {}, Server = {} }
	print("Register Initialized Successfully")
end

function HitFix:UpdateHitBox(player: Player, hitbox: CFrame)
	if RunService:IsClient() then return end
	if not player then warn("Player is nil") return end
	if not hitbox then warn("Hitbox is nil") return end

	HitFix.Registers[player].Server[tick()] = hitbox
end

function HitFix:GetHitBox(player: Player, directory: string)
	local latestTime = 0
	for time in pairs(HitFix.Registers[player][directory]) do
		if time > latestTime then
			latestTime = time
		end
	end

	if not next(HitFix.Registers[player][directory]) then
		warn("Empty Directory")
		return false
	end

	return HitFix.Registers[player][directory][latestTime]
end

function HitFix:ValidateHit(player: Player, part: BasePart, clientTimestamp: number, tolerance: number)
	if RunService:IsClient() then return end
	if not player then error("Player is nil") end
	if not HitFix.Registers[player] then
		warn("Player has no register, creating one")
		HitFix:CreateHitBoxRegister(player)
	end
	if math.abs(clientTimestamp - tick()) > HitFix.TimeOutTolerance then error("Time out") end
	if tolerance > HitFix.TolerableTolerance then error("Tolerance Too high") end

	local target = HitFix.Registers[player].Local[clientTimestamp]
	if not target then error("Local Time Doesn't Exist") end

	local serverTimestamps = {}
	for time in pairs(HitFix.Registers[player].Server) do
		table.insert(serverTimestamps, time)
	end

	table.sort(serverTimestamps)
	local closestTime = HitFix:BinarySearchClosest(serverTimestamps, clientTimestamp)

	if closestTime then
		local distance = (target.Position - HitFix.Registers[player].Server[closestTime].Position).Magnitude
		return distance < tolerance
	else
		warn("Could not find closest timestamp")
		return false
	end
end

function HitFix:BinarySearchClosest(timestamps: {number}, target: number): number
	local low, high = 1, #timestamps
	local closest = nil

	while low <= high do
		local mid = math.floor((low + high) / 2)
		if timestamps[mid] == target then
			return timestamps[mid]
		elseif timestamps[mid] < target then
			closest = timestamps[mid]
			low = mid + 1
		else
			high = mid - 1
		end
	end

	return closest
end

if RunService:IsServer() then
	UpdateLocal.OnServerEvent:Connect(function(player: Player, Cframe: CFrame, Time: number)
		HitFix.Registers[player].Local[Time] = Cframe
	end)
end

local function RemoveOldestTimestamp(table: {number})
	local oldestTime = math.huge
	for time in pairs(table) do
		if time < oldestTime then
			oldestTime = time
		end
	end
	return oldestTime
end

RunService.Stepped:Connect(function()
	for player, register in pairs(HitFix.Registers) do
		if tick() - RemoveOldestTimestamp(register.Local) > HitFix.StorageTime then
			local oldest = RemoveOldestTimestamp(register.Local)
			register.Local[oldest] = nil
		end
		if tick() - RemoveOldestTimestamp(register.Server) > HitFix.StorageTime then
			local oldest = RemoveOldestTimestamp(register.Server)
			register.Server[oldest] = nil
		end
	end
end)

return HitFix
