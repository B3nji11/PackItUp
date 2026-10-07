-- Composition root: connects independently testable game rules to Roblox services.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Runtime = require(Shared.config.Runtime)
local RushConfig = require(Shared.config.Rush)
local Economy = require(Shared.config.Economy)
local Packing = require(Shared.domain.Packing)
local Pricing = require(Shared.domain.Pricing)
local LunchRush = require(Shared.domain.LunchRush)
local Network = require(script.Parent.Network)
local DataService = require(script.Parent.services.DataService)
local StationService = require(script.Parent.services.StationService)
local SnapshotService = require(script.Parent.services.SnapshotService)
local ActionService = require(script.Parent.services.ActionService)
local WorldBuilder = require(script.Parent.world.WorldBuilder)

local stations, rushLabel = WorldBuilder(Runtime.StationCount)
local data = DataService.new()
local stationService = StationService.new(stations)
local network = Network.new()
local rush = LunchRush.new(workspace:GetServerTimeNow())
local snapshots = SnapshotService.new(data, stationService, rush, network)
local random = Random.new()
local function nextUnit() return math.min(random:NextNumber(), 1 - 1e-12) end
local actions = ActionService.new(data, stationService, rush, network, snapshots, nextUnit)
local connections = {}
local joining = {}
local shuttingDown = false

local function moveCharacter(player, character)
    if character:WaitForChild("HumanoidRootPart", 10) and player.Character == character then
        stationService:teleport(player)
    end
end
local function join(player)
    if joining[player] or data.entries[player] or shuttingDown then return end
    joining[player] = true
    if not stationService:assign(player) then
        joining[player] = nil
        player:Kick("This restaurant is full. Please join another server.")
        return
    end
    if not data:load(player) then
        stationService:release(player)
        joining[player] = nil
        return
    end
    joining[player] = nil
    if shuttingDown or not player.Parent then
        stationService:release(player)
        data:close(player)
        return
    end
    connections[player] = player.CharacterAdded:Connect(function(character)
        task.spawn(moveCharacter, player, character)
    end)
    if player.Character then task.spawn(moveCharacter, player, player.Character) end
    snapshots:send(player)
    network:notice(player, "Welcome! Fill a bag, then SERVE. Your first five sales unlock a delivery.", true)
end
Players.PlayerAdded:Connect(function(player) task.spawn(join, player) end)
Players.PlayerRemoving:Connect(function(player)
    if connections[player] then connections[player]:Disconnect(); connections[player] = nil end
    actions:remove(player)
    stationService:release(player)
    data:close(player)
end)
network.Action.OnServerEvent:Connect(function(player, action, argument)
    if not shuttingDown then actions:handle(player, action, argument) end
end)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(join, player) end

local accumulated = 0
RunService.Heartbeat:Connect(function(dt)
    if shuttingDown then return end
    local now = workspace:GetServerTimeNow()
    local ids = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local p, runtime = data:get(player)
        if p then
            table.insert(ids, player.UserId)
            -- Full bags halt production. There is no offline production in this version.
            Packing.add(p, Pricing.automatic(p) * math.min(dt, 0.5), nextUnit)
            if runtime.foldStart and now > runtime.foldStart + Economy.FoldDuration then runtime.foldStart = nil end
        end
    end
    local winners = rush:step(now, ids)
    if winners then
        for _, id in ipairs(winners) do
            local player = Players:GetPlayerByUserId(id)
            local p = if player then data:get(player) else nil
            if p then
                Pricing.credit(p, "tickets", RushConfig.TicketReward)
                network:notice(player, "Lunch rush complete! +3 Order Tickets", true)
            end
        end
    end
    accumulated += dt
    if accumulated >= Runtime.SnapshotInterval then
        accumulated = 0
        for _, player in ipairs(Players:GetPlayers()) do
            local p = data:get(player)
            if p then stationService:render(player, p); snapshots:send(player) end
        end
        rushLabel.Text = if rush.active then "LUNCH RUSH: " .. rush.count .. " / " .. rush.target
            .. " bags\n" .. math.max(0, math.ceil(rush.endsAt - now)) .. " seconds left"
            else rush.result .. "\nNext rush in " .. math.max(0, math.ceil(rush.nextStart - now)) .. " seconds"
        data:tick()
    end
end)
game:BindToClose(function() shuttingDown = true; data:shutdown() end)
print("[Fries] Restaurant ready. Studio memory mode:", data.volatile)
