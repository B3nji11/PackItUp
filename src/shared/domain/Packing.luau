local Pricing = require(script.Parent.Pricing)
local Profile = require(script.Parent.Profile)
local Packing = {}
function Packing.add(p, amount)
    local capacity = Pricing.capacity(p)
    if type(amount) ~= "number" or amount ~= amount or amount == math.huge or amount <= 0
        or p.bag.fries >= capacity then return false end
    p.bag.fries = math.min(capacity, p.bag.fries + amount)
    return p.bag.fries == capacity
end
function Packing.sell(p)
    if p.bag.fries < Pricing.capacity(p) then return false, "Fill your bag first." end
    local value = Pricing.sale(p)
    Pricing.credit(p, "cash", value)
    Pricing.credit(p, "lifetimeCash", value)
    Pricing.credit(p, "sales", 1)
    p.bag = Profile.emptyBag()
    return true, value
end
return Packing
