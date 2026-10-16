local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Economy = require(Shared.config.Economy)
local AllowedActions = require(Shared.config.Actions)
local RateLimiter = require(Shared.util.RateLimiter)
local Packing = require(Shared.domain.Packing)
local Pricing = require(Shared.domain.Pricing)
local Upgrades = require(Shared.domain.Upgrades)
local Rebirth = require(Shared.domain.Rebirth)
local Gacha = require(Shared.domain.Gacha)
local Pets = require(Shared.domain.Pets)
local Profile = require(Shared.domain.Profile)
local ActionService = {}
ActionService.__index = ActionService
function ActionService.new(data, stations, network, snapshots)
    return setmetatable({ data = data, stations = stations, network = network, snapshots = snapshots,
        generalLimit = RateLimiter.new(12, 18), clickLimit = RateLimiter.new(Economy.ClicksPerSecond, 1),
        cooldowns = {}, random = Random.new() }, ActionService)
end
function ActionService:remove(player)
    self.generalLimit:remove(player)
    self.clickLimit:remove(player)
    self.cooldowns[player] = nil
end
local function validArgument(action, argument)
    local kind = AllowedActions[action]
    if kind == "none" then return argument == nil end
    -- Upgrade takes only a known track name; never prices, levels, or Cash amounts.
    if kind == "upgrade" then return Upgrades.isTrack(argument) end
    if kind == "machine" then return Gacha.isMachine(argument) end
    if kind == "pet" then return Pets.isPetId(argument) end
    return false
end
function ActionService:handle(player, action, argument)
    local now = workspace:GetServerTimeNow()
    if not self.generalLimit:allow(player, now) then return end
    if type(action) ~= "string" or #action > 24 or not validArgument(action, argument) then return end
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
        if self.clickLimit:allow(player, now) then Packing.add(p, Pricing.click(p)) end
        return -- Periodic snapshots coalesce rapid input.
    end
    local delay = if action == "Sell" then 0.2 elseif action == "Upgrade" or action == "Spin" then 0.25
        elseif action == "Rebirth" then 2 elseif action == "Return" or action == "Sync" then 1 else 0.15
    local cooldowns = self.cooldowns[player] or {}
    self.cooldowns[player] = cooldowns
    if now < (cooldowns[action] or 0) then return end
    cooldowns[action] = now + delay
    if action == "Return" then self.stations:teleport(player)
    elseif action == "Sell" then
        local ok, result = Packing.sell(p)
        if not ok then self.network:notice(player, result, false) end
    elseif action == "Upgrade" then
        -- Purchase and level change happen in one non-yielding step.
        local ok, result = Upgrades.buy(p, argument)
        if ok then self.stations:render(player, p) else self.network:notice(player, result, false) end
    elseif action == "Rebirth" then
        -- Cash, bag, gems, and count change together in one non-yielding step.
        local ok, result = Rebirth.perform(p)
        if ok then self.stations:render(player, p) else self.network:notice(player, result, false) end
    elseif action == "Spin" then
        -- Price, roll, pet, and pity change together; the roll happens only here.
        local ok, result = Gacha.spin(p, argument, function() return self.random:NextNumber() end)
        if not ok then self.network:notice(player, result, false)
        else
            self.spins = (self.spins or 0) + 1
            self.snapshots:send(player, { spin = { serial = self.spins, id = result.id, type = result.type } })
            return
        end
    elseif action == "Equip" or action == "Unequip" or action == "DeletePet" then
        local operation = if action == "Equip" then Pets.equip elseif action == "Unequip" then Pets.unequip else Pets.delete
        local ok, result = operation(p, argument)
        if ok then
            Profile.normalize(p) -- removing a capacity bonus trims an over-full bag
            self.stations:render(player, p)
        else self.network:notice(player, result, false) end
    end
    self.snapshots:send(player)
end
return ActionService
