local Economy = require(script.Parent.Parent.config.Economy)
local Pricing = {}
function Pricing.click() return Economy.BaseClick end
function Pricing.automatic() return Economy.BasicFryerPerSecond end
function Pricing.sale() return Economy.BaseSale end
function Pricing.credit(p, currency, amount)
    p[currency] = math.min(Economy.MaxCurrency, p[currency] + amount)
end
return Pricing
