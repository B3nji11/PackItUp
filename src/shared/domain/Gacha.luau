-- Gacha spins. Pure rules: the server injects `random` (returns 0 <= x < 1).
local Machines = require(script.Parent.Parent.config.Machines)
local PetConfig = require(script.Parent.Parent.config.Pets)
local Pets = require(script.Parent.Pets)
local Restaurant = require(script.Parent.Restaurant)
local Gacha = {}
function Gacha.isMachine(id) return type(id) == "string" and Machines.Machines[id] ~= nil end
function Gacha.pity(p, id)
    local counts = type(p.pity) == "table" and p.pity
    local count = counts and counts[id]
    return if type(count) == "number" then count else 0
end
local function rank(rarity) return PetConfig.Rarities[rarity].Rank end
-- Rarity odds for the next spin; when pity triggers, only PityRarity or better (renormalised).
function Gacha.odds(p, id)
    local machine = Machines.Machines[id]
    local forced = Gacha.pity(p, id) >= machine.PityEvery - 1
    local odds, total = {}, 0
    for _, rarity in ipairs(PetConfig.RarityOrder) do
        local chance = machine.Odds[rarity] or 0
        if forced and rank(rarity) < rank(machine.PityRarity) then chance = 0 end
        odds[rarity] = chance; total += chance
    end
    for rarity, chance in pairs(odds) do odds[rarity] = chance / total end
    return odds, forced
end
local function poolOf(machine, rarity)
    local pool = {}
    for _, petType in ipairs(machine.Pool) do
        if PetConfig.Types[petType].Rarity == rarity then table.insert(pool, petType) end
    end
    return pool
end
function Gacha.roll(p, id, random)
    local machine = Machines.Machines[id]
    local odds = Gacha.odds(p, id)
    local pick, chosen = random(), nil
    for _, rarity in ipairs(PetConfig.RarityOrder) do
        if odds[rarity] > 0 and #poolOf(machine, rarity) > 0 then
            chosen = rarity
            pick -= odds[rarity]
            if pick < 0 then break end
        end
    end
    local pool = poolOf(machine, chosen)
    local index = math.clamp(math.floor(random() * #pool) + 1, 1, #pool)
    return pool[index], chosen
end
-- Price, roll, new pet, and pity change together in one non-yielding step.
function Gacha.spin(p, id, random)
    local machine = Machines.Machines[id]
    if not machine then return false, "That machine is unavailable." end
    if not Restaurant.unlocked(p, id) then return false, "Expand your restaurant to unlock this machine." end
    if Pets.full(p) then return false, "Your pet inventory is full. Delete a pet to spin again." end
    if p.cash < machine.Price then return false, "Not enough Cash to spin." end
    local petType, rarity = Gacha.roll(p, id, random)
    p.cash -= machine.Price
    if type(p.pity) ~= "table" then p.pity = {} end
    p.pity[id] = if rank(rarity) >= rank(machine.PityRarity) then 0 else Gacha.pity(p, id) + 1
    -- Auto-deleted rarities still cost the spin and count for pity, but are not kept.
    if Pets.autoDeletes(p, rarity) then return true, { type = petType, rarity = rarity, autoDeleted = true } end
    return true, Pets.add(p, petType, id)
end
-- Display data for the client: price, odds per rarity with pet names, and pity progress.
function Gacha.snapshot(p, id)
    local machine = Machines.Machines[id]
    local rows = {}
    for _, rarity in ipairs(PetConfig.RarityOrder) do
        local names, types = {}, {}
        for _, petType in ipairs(poolOf(machine, rarity)) do
            table.insert(names, PetConfig.Types[petType].Name); table.insert(types, petType)
        end
        if #names > 0 then table.insert(rows, { rarity = rarity, chance = machine.Odds[rarity] or 0, pets = names, types = types }) end
    end
    return { id = id, name = machine.Name, price = machine.Price, odds = rows, pity = Gacha.pity(p, id),
        pityEvery = machine.PityEvery, pityRarity = machine.PityRarity, tier = machine.Tier, accent = machine.Accent,
        unlocked = Restaurant.unlocked(p, id) }
end
return Gacha
