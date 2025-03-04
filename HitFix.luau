local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UpdateLocal = script:WaitForChild("UpdateLocal")
local Serializer = require(script:WaitForChild("Serializer"))

local HitFix = {}
self = HitFix
self.Registers = {}
self.StorageTime = 1

-- Creates a new hitbox register for a player
function HitFix:CreateHitBoxRegister(player: Player)
    if RunService:IsClient() then error("CreateHitBoxRegister must be invoked from the server") end
    if not player then warn("Player is nil") return end

    self.Registers[player] = { Local = {}, Server = {} }
    print("Register Initialized Successfully")
end

-- Updates the hitbox for a player with a new CFrame
function HitFix:UpdateHitBox(player: Player, hitbox: CFrame)
    if RunService:IsClient() then return end
    if not player then warn("Player is nil") return end
    if not hitbox then warn("Hitbox is nil") return end

    self.Registers[player].Server[tick()] = hitbox
end

-- Retrieves the latest hitbox from the specified directory (Local or Server)
function HitFix:GetHitBox(player: Player, directory: string)
    local latestTime = 0
    for time in pairs(self.Registers[player][directory]) do
        if time > latestTime then
            latestTime = time
        end
    end

    if not next(self.Registers[player][directory]) then
        warn("Empty Directory")
        return false
    end

    return self.Registers[player][directory][latestTime]
end

-- Validates a hit based on the player's hitbox and the server's recorded hitbox
function HitFix:ValidateHit(player: Player, part: BasePart, clientTimestamp: number, tolerance: number)
    if RunService:IsClient() then return end
    if not player then error("Player is nil") end
    if not self.Registers[player] then
        warn("Player has no register, creating one")
        self:CreateHitBoxRegister(player)
    end
    if math.abs(clientTimestamp - tick()) > 10 then error("Time out") end
    if tolerance > 10 then error("Tolerance Too high") end

    local target = self.Registers[player].Local[clientTimestamp]
    if not target then error("Local Time Doesn't Exist") end

    local serverTimestamps = {}
    for time in pairs(self.Registers[player].Server) do
        table.insert(serverTimestamps, time)
    end

    table.sort(serverTimestamps)
    local closestTime = self:BinarySearchClosest(serverTimestamps, clientTimestamp)

    if closestTime then
        local distance = (target.Position - self.Registers[player].Server[closestTime].Position).Magnitude
        return distance < tolerance
    else
        warn("Could not find closest timestamp")
        return false
    end
end

-- Helper function to find the closest timestamp using binary search
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
        self.Registers[player].Local[Time] = Cframe
    end)
end

-- Helper function to find and remove the oldest timestamp in a table
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
    for player, register in pairs(self.Registers) do
        if tick() - RemoveOldestTimestamp(register.Local) > self.StorageTime then
            local oldest = RemoveOldestTimestamp(register.Local)
            register.Local[oldest] = nil
        end
        if tick() - RemoveOldestTimestamp(register.Server) > self.StorageTime then
            local oldest = RemoveOldestTimestamp(register.Server)
            register.Server[oldest] = nil
        end
        print(register.Server)
    end
end)

return HitFix
