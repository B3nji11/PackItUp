local Economy = require(script.Parent.Parent.config.Economy)
local Upgrades = require(script.Parent.Parent.config.Upgrades)
local PetConfig = require(script.Parent.Parent.config.Pets)
local Machines = require(script.Parent.Parent.config.Machines)
local SettingsConfig = require(script.Parent.Parent.config.Settings)
local Restaurants = require(script.Parent.Parent.config.Restaurants)
local Pricing = require(script.Parent.Pricing)
local Profile = {}
function Profile.emptyBag() return { fries = 0 } end
function Profile.new()
    return { version = 1, cash = 0, sales = 0, lifetimeCash = 0, bag = Profile.emptyBag(),
        upgradeLevels = {}, gems = 0, rebirths = 0, pets = {}, equippedPets = {}, nextPetId = 0, pity = {}, settings = {}, autoDelete = {},
        restaurantTier = 1 }
end
local function numberIn(value, low, high, integer)
    return type(value) == "number" and value == value and value >= low and value <= high
        and (not integer or value % 1 == 0)
end
local function validPets(p)
    if p.pets ~= nil then
        if type(p.pets) ~= "table" or #p.pets > PetConfig.MaxPets then return false end
        local count, seen = 0, {}
        for _ in pairs(p.pets) do count += 1 end
        if count ~= #p.pets then return false end -- a plain list
        for _, owned in ipairs(p.pets) do
            if type(owned) ~= "table" or type(owned.id) ~= "string" or not string.match(owned.id, "^P%d+$")
                or seen[owned.id] or not PetConfig.Types[owned.type] or not Machines.Machines[owned.machine]
                or (owned.golden ~= nil and owned.golden ~= true) then
                return false
            end
            seen[owned.id] = true
        end
        if p.equippedPets ~= nil then
            if type(p.equippedPets) ~= "table" or #p.equippedPets > PetConfig.EquipSlots then return false end
            local equippedCount, equippedSeen = 0, {}
            for _ in pairs(p.equippedPets) do equippedCount += 1 end
            if equippedCount ~= #p.equippedPets then return false end
            for _, id in ipairs(p.equippedPets) do
                if not seen[id] or equippedSeen[id] then return false end
                equippedSeen[id] = true
            end
        end
    elseif p.equippedPets ~= nil and (type(p.equippedPets) ~= "table" or next(p.equippedPets) ~= nil) then
        return false
    end
    if p.nextPetId ~= nil and not numberIn(p.nextPetId, 0, Economy.MaxCurrency, true) then return false end
    if p.pity ~= nil then
        if type(p.pity) ~= "table" then return false end
        for id, count in pairs(p.pity) do
            local machine = type(id) == "string" and Machines.Machines[id]
            if not machine or not numberIn(count, 0, machine.PityEvery, true) then return false end
        end
    end
    if p.settings ~= nil then
        if type(p.settings) ~= "table" then return false end
        for key, value in pairs(p.settings) do
            if type(key) ~= "string" or SettingsConfig.Defaults[key] == nil or type(value) ~= "boolean" then return false end
        end
    end
    if p.autoDelete ~= nil then
        if type(p.autoDelete) ~= "table" then return false end
        for rarity, value in pairs(p.autoDelete) do
            if type(rarity) ~= "string" or not table.find(PetConfig.BulkRarities, rarity) or value ~= true then return false end
        end
    end
    return true
end
-- Version 1 core fields, plus optional upgradeLevels, gems, rebirths, pets, equippedPets,
-- nextPetId, pity, settings, autoDelete, and restaurantTier (missing means none, defaults, or tier 1). Extra fields from the earlier prototype,
-- such as `upgrades`, stay in storage but are never used or sent to clients.
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
    if p.restaurantTier ~= nil and not numberIn(p.restaurantTier, 1, Restaurants.Max, true) then return false end
    if not validPets(p) then return false end
    -- Capacity depends on balance data that may change between releases, so a bag only
    -- needs a sane size here; normalize() trims it to the current capacity on load.
    return type(p.bag) == "table" and numberIn(p.bag.fries, 0, Economy.MaxCurrency, false)
end
-- Keeps the bag within the current capacity (after unequipping, deleting, or a balance change).
function Profile.normalize(p)
    p.bag.fries = math.min(p.bag.fries, Pricing.capacity(p))
end
-- Saves from before gems existed (no `gems` field) bought upgrades with Cash. The owner
-- chose to reset those levels to 0 (16 Oct 2026, no live players). Runs once per save,
-- after a validated load; returns true when it changed the profile.
function Profile.migrate(p)
    local changed = false
    if p.gems == nil then
        p.gems, p.rebirths, p.upgradeLevels = 0, 0, {}
        changed = true
    end
    Profile.normalize(p)
    return changed
end
return Profile
