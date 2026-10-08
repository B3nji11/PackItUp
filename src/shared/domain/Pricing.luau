local Economy = require(script.Parent.Parent.config.Economy)
local Pricing = {}
function Pricing.click() return Economy.BaseClick end
function Pricing.automatic() return Economy.BasicFryerPerSecond end
function Pricing.perFry() return Economy.MoneyPerFryCents / 100 end
-- Sale value scales with the fries in a full bag. Integer cents keep Cash whole and exact.
function Pricing.sale() return math.floor(Economy.Capacity * Economy.MoneyPerFryCents / 100) end
function Pricing.credit(p, currency, amount)
    p[currency] = math.min(Economy.MaxCurrency, p[currency] + amount)
end
return Pricing
