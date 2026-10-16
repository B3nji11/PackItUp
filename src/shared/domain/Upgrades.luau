-- Gem upgrade purchases. Pure rules: no Instances, messages, or DataStores.
local Config = require(script.Parent.Parent.config.Upgrades)
local Pricing = require(script.Parent.Pricing)
local Upgrades = {}
function Upgrades.isTrack(id) return type(id) == "string" and Config.Tracks[id] ~= nil end
function Upgrades.cost(id, level)
    local track = Config.Tracks[id]
    return math.floor(track.BaseCost * track.Growth ^ level + 0.5)
end
function Upgrades.nextCost(p, id) return Upgrades.cost(id, Pricing.level(p, id)) end
-- The current effective value of a track for display (fries, dollars per fry, or capacity).
function Upgrades.value(p, id)
    if id == "FriesPerClick" then return Pricing.click(p)
    elseif id == "MoneyPerFry" then return Pricing.perFry(p) end
    return Pricing.capacity(p)
end
-- Deducts the cost and raises the level in one non-yielding step.
function Upgrades.buy(p, id)
    if not Upgrades.isTrack(id) then return false, "That upgrade is unavailable." end
    local level = Pricing.level(p, id)
    if level >= Config.MaxLevel then return false, "That upgrade is maxed out." end
    local cost = Upgrades.cost(id, level)
    local gems = if type(p.gems) == "number" then p.gems else 0
    if gems < cost then return false, "Not enough gems for this upgrade." end
    p.gems = gems - cost
    if type(p.upgradeLevels) ~= "table" then p.upgradeLevels = {} end
    p.upgradeLevels[id] = level + 1
    return true, cost
end
-- Server-computed shop rows for the client to display, in shop order.
function Upgrades.snapshot(p)
    local rows = {}
    for _, id in ipairs(Config.Order) do
        local level = Pricing.level(p, id)
        -- The next value includes the same equipped pets, so it matches what the player will get.
        local nextProfile = { upgradeLevels = { [id] = level + 1 }, pets = p.pets, equippedPets = p.equippedPets }
        table.insert(rows, { id = id, name = Config.Tracks[id].Name, level = level,
            cost = Upgrades.cost(id, level), value = Upgrades.value(p, id),
            nextValue = Upgrades.value(nextProfile, id) })
    end
    return rows
end
return Upgrades
