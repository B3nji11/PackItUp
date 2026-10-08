-- Effective stats from base values plus Cash upgrade levels. Old prototype fields
-- (such as `upgrades`) are never read; only `upgradeLevels` counts.
local Economy = require(script.Parent.Parent.config.Economy)
local Upgrades = require(script.Parent.Parent.config.Upgrades)
local Pricing = {}
function Pricing.level(p, id)
    local levels = type(p) == "table" and p.upgradeLevels
    local level = type(levels) == "table" and levels[id]
    return if type(level) == "number" then level else 0
end
local function stepped(p, id, base) return base + Pricing.level(p, id) * Upgrades.Tracks[id].Step end
function Pricing.click(p) return stepped(p, "FriesPerClick", Economy.BaseClick) end
function Pricing.perFryCents(p) return stepped(p, "MoneyPerFry", Economy.MoneyPerFryCents) end
function Pricing.perFry(p) return Pricing.perFryCents(p) / 100 end
function Pricing.capacity(p) return stepped(p, "BagCapacity", Economy.BaseCapacity) end
function Pricing.automatic() return Economy.BasicFryerPerSecond end
-- Sale value scales with the fries in a full bag. Integer cents keep Cash whole and exact.
function Pricing.sale(p) return (Pricing.capacity(p) * Pricing.perFryCents(p)) // 100 end
function Pricing.credit(p, currency, amount)
    p[currency] = math.min(Economy.MaxCurrency, p[currency] + amount)
end
return Pricing
