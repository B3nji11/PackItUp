local Economy = require(script.Parent.Parent.config.Economy)
local Upgrades = require(script.Parent.Parent.config.Upgrades)
local Pricing = require(script.Parent.Pricing)
local Profile = {}
function Profile.emptyBag() return { fries = 0 } end
function Profile.new()
    return { version = 1, cash = 0, sales = 0, lifetimeCash = 0, bag = Profile.emptyBag(),
        upgradeLevels = {}, gems = 0, rebirths = 0 }
end
local function numberIn(value, low, high, integer)
    return type(value) == "number" and value == value and value >= low and value <= high
        and (not integer or value % 1 == 0)
end
-- Version 1 core fields, plus optional upgradeLevels, gems, and rebirths (missing means 0).
-- Extra fields from the earlier prototype, such as `upgrades`, stay in storage but are
-- never used or sent to clients.
function Profile.validate(p)
    if type(p) ~= "table" or p.version ~= 1 then return false end
    for _, key in ipairs({ "cash", "sales", "lifetimeCash" }) do
        if not numberIn(p[key], 0, Economy.MaxCurrency, true) then return false end
    end
    for _, key in ipairs({ "gems", "rebirths" }) do
        if p[key] ~= nil and not numberIn(p[key], 0, Economy.MaxCurrency, true) then return false end
    end
    if p.upgradeLevels ~= nil then
        if type(p.upgradeLevels) ~= "table" then return false end
        for id, level in pairs(p.upgradeLevels) do
            if type(id) ~= "string" or not Upgrades.Tracks[id] or not numberIn(level, 0, Upgrades.MaxLevel, true) then
                return false
            end
        end
    end
    return type(p.bag) == "table" and numberIn(p.bag.fries, 0, Pricing.capacity(p), false)
end
-- Saves from before gems existed (no `gems` field) bought upgrades with Cash. The owner
-- chose to reset those levels to 0 (16 Oct 2026, no live players). Runs once per save,
-- after a validated load; returns true when it changed the profile.
function Profile.migrate(p)
    if p.gems ~= nil then return false end
    p.gems, p.rebirths, p.upgradeLevels = 0, 0, {}
    p.bag.fries = math.min(p.bag.fries, Pricing.capacity(p))
    return true
end
return Profile
