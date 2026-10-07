local Economy = require(script.Parent.Parent.config.Economy)
local Equipment = require(script.Parent.Parent.config.Equipment)
local Pricing = {}
function Pricing.click(p) return Economy.BaseClick + p.upgrades.Click end
function Pricing.automatic(p) return Equipment.Items[p.equipped.Machine].power end
function Pricing.sale(p, variantMultiplier)
    local bagBonus = Equipment.Items[p.equipped.Bag].power
    return math.floor(Economy.BaseSale * bagBonus * (1 + p.upgrades.Sales * Economy.SalesBonusPerLevel) * variantMultiplier + 0.5)
end
function Pricing.upgrade(level)
    return math.ceil(Economy.UpgradeBaseCost * Economy.UpgradeGrowth ^ level)
end
function Pricing.credit(p, currency, amount)
    p[currency] = math.min(Economy.MaxCurrency, p[currency] + amount)
end
return Pricing
