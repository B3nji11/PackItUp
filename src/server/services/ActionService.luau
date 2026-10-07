local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Economy = require(Shared.config.Economy)
local Equipment = require(Shared.config.Equipment)
local AllowedActions = require(Shared.config.Actions)
local RateLimiter = require(Shared.util.RateLimiter)
local Packing = require(Shared.domain.Packing)
local Pricing = require(Shared.domain.Pricing)
local Folding = require(Shared.domain.Folding)
local Orders = require(Shared.domain.Orders)
local Upgrades = require(Shared.domain.Upgrades)
local Gacha = require(Shared.domain.Gacha)
local ActionService = {}
ActionService.__index = ActionService
function ActionService.new(data, stations, rush, network, snapshots, nextUnit)
    return setmetatable({ data = data, stations = stations, rush = rush, network = network,
        snapshots = snapshots, nextUnit = nextUnit, generalLimit = RateLimiter.new(12, 18),
        clickLimit = RateLimiter.new(Economy.ClicksPerSecond, 1), cooldowns = {} }, ActionService)
end
function ActionService:remove(player)
    self.generalLimit:remove(player)
    self.clickLimit:remove(player)
    self.cooldowns[player] = nil
end
function ActionService:handle(player, action, argument)
    local now = workspace:GetServerTimeNow()
    if not self.generalLimit:allow(player, now) then return end
    if type(action) ~= "string" or #action > 24 then return end
    if AllowedActions[action] == nil then return end
    if argument ~= nil and (type(argument) ~= "string" or #argument > 64) then return end
    if AllowedActions[action] and type(argument) ~= "string" then return end
    if not AllowedActions[action] and argument ~= nil then return end
    local p, runtime = self.data:get(player)
    if not p then return end
    local physical = action == "Pack" or action == "Sell" or action == "StartFold" or action == "FinishFold"
    if physical and not self.stations:near(player) then
        self.network:notice(player, "Return to your counter to work.", false)
        return
    end
    if action == "Pack" then
        if not self.clickLimit:allow(player, now) then return end
        Packing.add(p, Pricing.click(p), self.nextUnit)
        return -- Periodic snapshots coalesce rapid input.
    end
    local delay = if action == "Roll" or action == "Sync" or action == "Return" then 1 else 0.2
    local cooldowns = self.cooldowns[player] or {}
    self.cooldowns[player] = cooldowns
    if now < (cooldowns[action] or 0) then return end
    cooldowns[action] = now + delay
    local ok, message
    if action == "Sync" then self.snapshots:send(player); return
    elseif action == "Return" then self.stations:teleport(player); self.snapshots:send(player); return
    elseif action == "Sell" then
        local amount
        ok, amount = Packing.sell(p)
        if ok then
            runtime.foldStart = nil
            local tickets = Orders(p)
            self.rush:sale(player.UserId, now)
            message = "Served! +$" .. amount .. (if tickets > 0 then "  +" .. tickets .. " Tickets" else "")
        else message = amount end
    elseif action == "StartFold" then ok, message = Folding.start(p, runtime, now)
    elseif action == "FinishFold" then ok, message = Folding.finish(p, runtime, now)
    elseif action == "Upgrade" then ok, message = Upgrades.buy(p, argument)
    elseif action == "Equip" then ok, message = Upgrades.equip(p, argument)
    elseif action == "Roll" then
        local result
        ok, result = Gacha(p, argument, self.nextUnit)
        if ok then
            local item = Equipment.Items[result.id]
            message = result.rarity .. " delivery: " .. item.name
                .. (if result.duplicate then " | Duplicate: +1 Ticket refunded" else " | Equip it in GEAR")
        else message = result end
    else return end
    self.network:notice(player, message, ok)
    self.snapshots:send(player)
end
return ActionService
