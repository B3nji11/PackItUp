local Economy = require(script.Parent.Parent.config.Economy)
local Equipment = require(script.Parent.Parent.config.Equipment)
local Pricing = require(script.Parent.Pricing)
local Upgrades = {}
function Upgrades.buy(p, track)
    if track ~= "Click" and track ~= "Sales" then return false, "Unknown upgrade." end
    local level = p.upgrades[track]
    if level >= Economy.MaxUpgradeLevel then return false, "Upgrade is at maximum level." end
    local cost = Pricing.upgrade(level)
    if p.cash < cost then return false, "Not enough Cash." end
    p.cash -= cost
    p.upgrades[track] += 1
    return true, track .. " upgraded!"
end
function Upgrades.equip(p, id)
    local item = Equipment.Items[id]
    if not item or not p.owned[id] then return false, "You do not own that equipment." end
    p.equipped[item.category] = id
    return true, "Equipped " .. item.name
end
return Upgrades
