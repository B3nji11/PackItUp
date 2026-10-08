-- Composition root: connects independently testable game rules to Roblox services.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Runtime = require(Shared.config.Runtime)
local Packing = require(Shared.domain.Packing)
local Pricing = require(Shared.domain.Pricing)
local RateLimiter = require(Shared.util.RateLimiter)
local Network = require(script.Parent.Network)
local DataService = require(script.Parent.services.DataService)
local StationService = require(script.Parent.services.StationService)
local SnapshotService = require(script.Parent.services.SnapshotService)
local ActionService = require(script.Parent.services.ActionService)
local WorldBuilder = require(script.Parent.world.WorldBuilder)

local stations = WorldBuilder(Runtime.StationCount)
local data = DataService.new()
local stationService = StationService.new(stations)
local network = Network.new()
local snapshots = SnapshotService.new(data, stationService, network)
local actions = ActionService.new(data, stationService, network, snapshots)
local connections = {}
local joining = {}
local shuttingDown = false
local admitted, admittedCount = {}, 0
local claimLimit = RateLimiter.new(2, 3)
local function releaseAdmission(player)
    if admitted[player] then admitted[player] = nil; admittedCount -= 1 end
end

for index, station in ipairs(stations) do
    station.prompt.Triggered:Connect(function(player)
        if shuttingDown then return end
        if not claimLimit:allow(player, workspace:GetServerTimeNow()) then return end
        local p = data:get(player)
        if not p then return end
        local ok, message = stationService:claim(player, index)
        if ok then stationService:render(player, p) else network:notice(player, message, false) end
        snapshots:send(player)
    end)
end

local function moveCharacter(player, character)
    if character:WaitForChild("HumanoidRootPart", 10) and player.Character == character then
        stationService:teleport(player)
    end
end
local function join(player)
    if joining[player] or data.entries[player] or shuttingDown then return end
    joining[player] = true
    if admittedCount >= Runtime.StationCount then
        joining[player] = nil
        player:Kick("All player spaces are taken. Please join another server.")
        return
    end
    admitted[player], admittedCount = true, admittedCount + 1
    if not data:load(player) then
        releaseAdmission(player)
        joining[player] = nil
        return
    end
    joining[player] = nil
    if shuttingDown or not player.Parent then
        releaseAdmission(player)
        data:close(player)
        return
    end
    connections[player] = player.CharacterAdded:Connect(function(character)
        task.spawn(moveCharacter, player, character)
    end)
    if player.Character then task.spawn(moveCharacter, player, player.Character) end
    snapshots:send(player)
end
Players.PlayerAdded:Connect(function(player) task.spawn(join, player) end)
Players.PlayerRemoving:Connect(function(player)
    if connections[player] then connections[player]:Disconnect(); connections[player] = nil end
    actions:remove(player)
    claimLimit:remove(player)
    stationService:release(player)
    releaseAdmission(player)
    data:close(player)
end)
network.Action.OnServerEvent:Connect(function(player, action, argument)
    if not shuttingDown then actions:handle(player, action, argument) end
end)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(join, player) end

local accumulated = 0
RunService.Heartbeat:Connect(function(dt)
    if shuttingDown then return end
    for _, player in ipairs(Players:GetPlayers()) do
        local p = data:get(player)
        if p and stationService:hasStation(player) then
            -- Full bags halt production. There is no offline production in this version.
            Packing.add(p, Pricing.automatic() * math.min(dt, 0.5))
        end
    end
    accumulated += dt
    if accumulated >= Runtime.SnapshotInterval then
        accumulated = 0
        for _, player in ipairs(Players:GetPlayers()) do
            local p = data:get(player)
            if p then stationService:render(player, p); snapshots:send(player) end
        end
        data:tick()
    end
end)
game:BindToClose(function() shuttingDown = true; data:shutdown() end)
print("[Fries] Restaurant ready. Studio memory mode:", data.volatile)
