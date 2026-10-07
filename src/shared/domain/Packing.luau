local Economy = require(script.Parent.Parent.config.Economy)
local Variants = require(script.Parent.Parent.config.Variants)
local Weighted = require(script.Parent.Parent.util.Weighted)
local Pricing = require(script.Parent.Pricing)
local Discovery = require(script.Parent.Discovery)
local Profile = require(script.Parent.Profile)
local Packing = {}
function Packing.add(p, amount, nextUnit)
    if p.bag.fries >= Economy.Capacity or amount <= 0 then return false end
    p.bag.fries = math.min(Economy.Capacity, p.bag.fries + amount)
    if p.bag.fries == Economy.Capacity then
        local variant = Weighted(Variants, nextUnit)
        p.bag.variant = variant.id
        -- Lock the price at completion: equipment swaps cannot reprice a full bag.
        p.bag.value = Pricing.sale(p, variant.multiplier)
        Discovery(p, variant.id)
        return true
    end
    return false
end
function Packing.sell(p)
    if p.bag.fries < Economy.Capacity then return false, "Fill your bag first." end
    local value = p.bag.value
    if p.bag.perfect then value = math.floor(value * Economy.PerfectMultiplier + 0.5) end
    Pricing.credit(p, "cash", value)
    Pricing.credit(p, "lifetimeCash", value)
    Pricing.credit(p, "sales", 1)
    p.bag = Profile.emptyBag()
    return true, value
end
return Packing
