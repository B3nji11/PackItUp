local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Economy = require(Shared.config.Economy)
local AllowedActions = require(Shared.config.Actions)
local RateLimiter = require(Shared.util.RateLimiter)
local Packing = require(Shared.domain.Packing)
local Pricing = require(Shared.domain.Pricing)
local ActionService = {}
ActionService.__index = ActionService
function ActionService.new(data, stations, network, snapshots)
    return setmetatable({ data = data, stations = stations, network = network, snapshots = snapshots,
        generalLimit = RateLimiter.new(12, 18), clickLimit = RateLimiter.new(Economy.ClicksPerSecond, 1),
        cooldowns = {} }, ActionService)
end
function ActionService:remove(player)
    self.generalLimit:remove(player)
    self.clickLimit:remove(player)
    self.cooldowns[player] = nil
end
function ActionService:handle(player, action, argument)
    local now = workspace:GetServerTimeNow()
    if not self.generalLimit:allow(player, now) then return end
    if type(action) ~= "string" or #action > 24 or not AllowedActions[action] or argument ~= nil then return end
    local p = self.data:get(player)
    if not p then return end
    if action ~= "Sync" and not self.stations:hasStation(player) then
        self.network:notice(player, "Choose an available restaurant and press E at its entrance.", false)
        return
    end
    if (action == "Pack" or action == "Sell") and not self.stations:near(player) then
        self.network:notice(player, "Return to your counter to work.", false)
        return
    end
    if action == "Pack" then
        if self.clickLimit:allow(player, now) then Packing.add(p, Pricing.click()) end
        return -- Periodic snapshots coalesce rapid input.
    end
    local delay = if action == "Sell" then 0.2 else 1
    local cooldowns = self.cooldowns[player] or {}
    self.cooldowns[player] = cooldowns
    if now < (cooldowns[action] or 0) then return end
    cooldowns[action] = now + delay
    if action == "Return" then self.stations:teleport(player)
    elseif action == "Sell" then
        local ok, result = Packing.sell(p)
        if not ok then self.network:notice(player, result, false) end
    end
    self.snapshots:send(player)
end
return ActionService
