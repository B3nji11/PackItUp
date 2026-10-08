local Economy = require(script.Parent.Parent.config.Economy)
local Pricing = require(script.Parent.Pricing)
local Profile = require(script.Parent.Profile)
local Packing = {}
function Packing.add(p, amount)
    if type(amount) ~= "number" or amount ~= amount or amount == math.huge or amount <= 0
        or p.bag.fries >= Economy.Capacity then return false end
    p.bag.fries = math.min(Economy.Capacity, p.bag.fries + amount)
    return p.bag.fries == Economy.Capacity
end
function Packing.sell(p)
    if p.bag.fries < Economy.Capacity then return false, "Fill your bag first." end
    local value = Pricing.sale()
    Pricing.credit(p, "cash", value)
    Pricing.credit(p, "lifetimeCash", value)
    Pricing.credit(p, "sales", 1)
    p.bag = Profile.emptyBag()
    return true, value
end
return Packing
