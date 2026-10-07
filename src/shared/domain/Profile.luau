local Economy = require(script.Parent.Parent.config.Economy)
local Equipment = require(script.Parent.Parent.config.Equipment)
local Variants = require(script.Parent.Parent.config.Variants)
local Profile = {}
function Profile.emptyBag()
    return { fries = 0, variant = "", value = 0, foldAttempted = false, perfect = false }
end
function Profile.new()
    return {
        version = 1, cash = 0, tickets = 0,
        upgrades = { Click = 0, Sales = 0 },
        owned = { starter_fryer = true, starter_bag = true },
        equipped = { Machine = "starter_fryer", Bag = "starter_bag" },
        pity = { Machine = 0, Bag = 0 },
        discoveries = {}, indexRewardClaimed = false,
        orderProgress = 0, tutorialClaimed = false,
        sales = 0, lifetimeCash = 0, bag = Profile.emptyBag(),
    }
end
local function numberIn(value, low, high, integer)
    return type(value) == "number" and value == value and value >= low and value <= high
        and (not integer or value % 1 == 0)
end
-- Invalid/future profiles are rejected, never replaced with a default save.
function Profile.validate(p)
    if type(p) ~= "table" or p.version ~= 1 then return false end
    for _, key in ipairs({ "cash", "tickets", "sales", "lifetimeCash" }) do
        if not numberIn(p[key], 0, Economy.MaxCurrency, true) then return false end
    end
    if type(p.upgrades) ~= "table" or type(p.owned) ~= "table" or type(p.equipped) ~= "table"
        or type(p.pity) ~= "table" or type(p.discoveries) ~= "table" then return false end
    for _, key in ipairs({ "Click", "Sales" }) do
        if not numberIn(p.upgrades[key], 0, Economy.MaxUpgradeLevel, true) then return false end
    end
    for id, owned in pairs(p.owned) do
        if not Equipment.Items[id] or owned ~= true then return false end
    end
    for _, category in ipairs(Equipment.Categories) do
        local item = Equipment.Items[p.equipped[category]]
        if not item or item.category ~= category or not p.owned[p.equipped[category]] then return false end
        if not numberIn(p.pity[category], 0, Economy.PityAt - 1, true) then return false end
    end
    local known = {}
    for _, variant in ipairs(Variants) do known[variant.id] = true end
    for id, discovered in pairs(p.discoveries) do
        if not known[id] or discovered ~= true then return false end
    end
    if not numberIn(p.orderProgress, 0, Economy.OrderFries - 1, true)
        or type(p.tutorialClaimed) ~= "boolean" or type(p.indexRewardClaimed) ~= "boolean" then return false end
    local bag = p.bag
    if type(bag) ~= "table" or not numberIn(bag.fries, 0, Economy.Capacity, false)
        or type(bag.foldAttempted) ~= "boolean" or type(bag.perfect) ~= "boolean" then return false end
    if bag.fries == Economy.Capacity then
        if not known[bag.variant] or not numberIn(bag.value, 1, Economy.MaxCurrency, true) then return false end
    elseif bag.variant ~= "" or bag.value ~= 0 or bag.foldAttempted or bag.perfect then
        return false
    end
    if bag.perfect and not bag.foldAttempted then return false end
    return true
end
return Profile
