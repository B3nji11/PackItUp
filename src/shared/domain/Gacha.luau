local Economy = require(script.Parent.Parent.config.Economy)
local Equipment = require(script.Parent.Parent.config.Equipment)
local Weighted = require(script.Parent.Parent.util.Weighted)
return function(p, category, nextUnit)
    local pool = Equipment.Pools[category]
    if not pool then return false, "Unknown delivery type." end
    if p.tickets < Economy.RollCost then return false, "You need 3 Order Tickets." end
    local guaranteed = p.pity[category] >= Economy.PityAt - 1
    local rarity = Weighted(if guaranteed then Equipment.GuaranteedRarities else Equipment.Rarities, nextUnit).id
    local id = pool[rarity]
    local duplicate = p.owned[id] == true
    p.tickets -= Economy.RollCost
    if duplicate then p.tickets += Economy.DuplicateRefund end
    p.owned[id] = true
    p.pity[category] = if rarity == "Epic" or rarity == "Legendary" then 0 else p.pity[category] + 1
    return true, { id = id, rarity = rarity, duplicate = duplicate, guaranteed = guaranteed }
end
