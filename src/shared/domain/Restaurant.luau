-- Restaurant tiers: which machines a player has, and buying the next tier with Cash. Pure rules.
local Config = require(script.Parent.Parent.config.Restaurants)
local Machines = require(script.Parent.Parent.config.Machines)
local Restaurant = {}
-- Saved in `restaurantTier`; missing (older saves) means tier 1.
function Restaurant.tier(p)
    local tier = type(p) == "table" and p.restaurantTier
    return if type(tier) == "number" and tier >= 1 and tier <= Config.Max and tier % 1 == 0 then tier else 1
end
function Restaurant.info(tier) return Config.Tiers[tier] end
function Restaurant.nextTier(p)
    local tier = Restaurant.tier(p)
    return if tier < Config.Max then Config.Tiers[tier + 1] else nil
end
-- A machine can be used once the restaurant has reached that machine's tier.
function Restaurant.unlocked(p, machineId)
    local machine = Machines.Machines[machineId]
    return machine ~= nil and machine.Tier <= Restaurant.tier(p)
end
-- The best machine the player has (the one the SPIN button visits).
function Restaurant.bestMachine(p) return Config.Tiers[Restaurant.tier(p)].Machine end
-- Pays the next tier's price and raises the tier in one non-yielding step. Tiers are never lost.
function Restaurant.expand(p)
    local nextTier = Restaurant.nextTier(p)
    if not nextTier then return false, "Your restaurant is fully upgraded." end
    if p.cash < nextTier.Price then return false, "Not enough Cash to expand." end
    p.cash -= nextTier.Price
    p.restaurantTier = Restaurant.tier(p) + 1
    return true, nextTier
end
-- Display data for the client: current tier and what the next one costs and adds.
function Restaurant.snapshot(p)
    local tier = Restaurant.tier(p)
    local nextTier = Restaurant.nextTier(p)
    local row = { tier = tier, max = Config.Max, name = Config.Tiers[tier].Name, id = Config.Tiers[tier].Id }
    if nextTier then
        local machine = Machines.Machines[nextTier.Machine]
        row.nextTier = { tier = tier + 1, id = nextTier.Id, name = nextTier.Name, price = nextTier.Price,
            tagline = nextTier.Tagline, machine = nextTier.Machine, machineName = machine.Name,
            spinPrice = machine.Price, legendary = machine.Pool[#machine.Pool],
            affordable = (p.cash or 0) >= nextTier.Price }
    end
    return row
end
return Restaurant
