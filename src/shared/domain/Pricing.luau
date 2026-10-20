-- Effective stats: (base + equipped pets' flat stats) x (1 + upgrade percent). Old prototype
-- fields (such as `upgrades`) are never read; only `upgradeLevels` and equipped pets count.
local Economy = require(script.Parent.Parent.config.Economy)
local Upgrades = require(script.Parent.Parent.config.Upgrades)
local Pets = require(script.Parent.Pets)
local Pricing = {}
function Pricing.level(p, id)
    local levels = type(p) == "table" and p.upgradeLevels
    local level = type(levels) == "table" and levels[id]
    return if type(level) == "number" then level else 0
end
-- The upgrade multiplier for a track: 1 + Percent x level (levels add up, they do not compound).
function Pricing.multiplier(p, id) return 1 + Pricing.level(p, id) * Upgrades.Tracks[id].Percent end
local function stepped(p, id, base, petScale)
    return (base + Pets.total(p, id) * (petScale or 1)) * Pricing.multiplier(p, id)
end
function Pricing.click(p) return stepped(p, "FriesPerClick", Economy.BaseClick) end
-- Pets list money in dollars; Economy keeps it in cents.
function Pricing.perFryCents(p) return stepped(p, "MoneyPerFry", Economy.MoneyPerFryCents, 100) end
function Pricing.perFry(p) return Pricing.perFryCents(p) / 100 end
-- Capacity is whole fries.
function Pricing.capacity(p) return math.floor(stepped(p, "BagCapacity", Economy.BaseCapacity) + 1e-9) end
function Pricing.automatic() return Economy.BasicFryerPerSecond end
-- Sale value scales with the fries in a full bag, rounded down to whole Cash.
function Pricing.sale(p) return math.floor(Pricing.capacity(p) * Pricing.perFryCents(p) / 100 + 1e-9) end
function Pricing.credit(p, currency, amount)
    p[currency] = math.min(Economy.MaxCurrency, p[currency] + amount)
end
return Pricing
