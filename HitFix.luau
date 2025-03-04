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

function HitFix:ValidateHit(player: Player, part: CFrame, clientTimestamp: number, tolerance: number)
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
	
	local serverTimeStamps = HitFix.Registers[player].Server
	
	local closestTime = HitFix:BinarySearchClosest(serverTimeStamps, clientTimestamp)
	local distance = (target.Position - HitFix.Registers[player].Server[closestTime].Position).Magnitude

	if closestTime and distance < tolerance then
		return Hitbox_Check(target, part, 90, 5, 5) -- TODO: make these numbers come from somewhere
	elseif distance < tolerance then
		warn("Could not find closest timestamp")
		return false
	else
		error("Hitbox differs too much")
	end
end

function Hitbox_Check(P1: CFrame, P2: CFrame, Range: number, Limit: number, VerticalLimit: number): boolean
	--> Setup	
	local Look = P1.LookVector --> Already is normalized
	local Resultant = P2.Position - P1.Position
	local Normal_Resultant = Resultant.Unit
	local Distance = Resultant.Magnitude

	--> Calculate
	local Dot = Look:Dot(Normal_Resultant)
	local Rad_Angle = math.acos(Dot)
	local Deg_Angle = math.deg(Rad_Angle)

	local In_Range = Distance <= Range
	local In_View = Deg_Angle <= Limit
	local Is_Hit = In_Range and In_View and math.abs(P1.Position.Y - P2.Position.Y) <= VerticalLimit

	return Is_Hit
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
