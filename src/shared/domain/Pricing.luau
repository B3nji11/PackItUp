-- Effective stats: (base + upgrade levels) x (1 + equipped pet bonus). Old prototype
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
local function stepped(p, id, base)
    return (base + Pricing.level(p, id) * Upgrades.Tracks[id].Step) * (1 + Pets.bonus(p, id))
end
function Pricing.click(p) return stepped(p, "FriesPerClick", Economy.BaseClick) end
function Pricing.perFryCents(p) return stepped(p, "MoneyPerFry", Economy.MoneyPerFryCents) end
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
