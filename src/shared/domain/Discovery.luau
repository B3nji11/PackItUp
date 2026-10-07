local Variants = require(script.Parent.Parent.config.Variants)
local Economy = require(script.Parent.Parent.config.Economy)
local Pricing = require(script.Parent.Pricing)
return function(p, id)
    p.discoveries[id] = true
    if p.indexRewardClaimed then return false end
    for _, variant in ipairs(Variants) do
        if not p.discoveries[variant.id] then return false end
    end
    p.indexRewardClaimed = true
    Pricing.credit(p, "tickets", Economy.IndexTickets)
    return true
end
