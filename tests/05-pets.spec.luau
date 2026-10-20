-- Gacha rolls, pity, pet inventory, equipping, bonuses, and saved pet fields.
local Profile = loadModule("shared/domain/Profile")
local Pricing = loadModule("shared/domain/Pricing")
local Packing = loadModule("shared/domain/Packing")
local Upgrades = loadModule("shared/domain/Upgrades")
local Rebirth = loadModule("shared/domain/Rebirth")
local Gacha = loadModule("shared/domain/Gacha")
local Pets = loadModule("shared/domain/Pets")
local PetConfig = loadModule("shared/config/Pets")
local Machines = loadModule("shared/config/Machines")
local Store = loadModule("server/storage/ProfileStore")
local Copy = loadModule("shared/util/Copy")
local function sequence(values)
    local index = 0
    return function() index += 1; return values[(index - 1) % #values + 1] end
end
local function rich(cash) local p = Profile.new(); p.cash = cash or 100000; return p end

test("starter machine odds sum to one and every pet belongs to a listed rarity", function()
    local machine = Machines.Machines.StarterFryer
    local total = 0
    for _, chance in pairs(machine.Odds) do total += chance end
    near(total, 1); eq(machine.Price, 150); eq(machine.PityEvery, 50); eq(#machine.Pool, 8)
    for _, petType in ipairs(machine.Pool) do assert(PetConfig.Types[petType]); assert(machine.Odds[PetConfig.Types[petType].Rarity]) end
    local snap = Gacha.snapshot(Profile.new(), "StarterFryer")
    eq(#snap.odds, 5); eq(snap.odds[1].rarity, "Common"); eq(#snap.odds[1].pets, 3); eq(snap.odds[5].pets[1], "Fry King")
    eq(#snap.odds[2].pets, 2); eq(#snap.odds[3].pets, 1); eq(snap.pity, 0); eq(snap.price, 150)
end)

test("rolls map random numbers to rarities and share each rarity equally", function()
    local p = Profile.new()
    local cases = { {0, 0, "CrinkleFry"}, {0.59, 0.5, "SaltShaker"}, {0.3, 0.99, "PaperCup"}, {0.7, 0, "PotatoPup"},
        {0.84, 0.99, "KetchupPacket"}, {0.86, 0, "MayoJar"}, {0.9, 0.6, "MayoJar"}, {0.96, 0.5, "FryerBot"}, {0.995, 0, "FryKing"} }
    for _, case in ipairs(cases) do
        local petType, rarity = Gacha.roll(p, "StarterFryer", sequence({case[1], case[2]}))
        eq(petType, case[3]); eq(rarity, PetConfig.Types[case[3]].Rarity)
    end
end)

test("many spins match the advertised odds", function()
    math.randomseed(7)
    local p = rich(1e12)
    local counts, spins = {}, 40000
    for _ = 1, spins do
        if Pets.full(p) then p.pets = {} end
        local ok, owned = Gacha.spin(p, "StarterFryer", math.random)
        assert(ok)
        local rarity = PetConfig.Types[owned.type].Rarity
        counts[rarity] = (counts[rarity] or 0) + 1
    end
    assert(math.abs(counts.Common / spins - 0.60) < 0.015, counts.Common)
    assert(math.abs(counts.Uncommon / spins - 0.25) < 0.015)
    assert(math.abs(counts.Rare / spins - 0.10) < 0.01)
    assert(counts.Epic / spins > 0.035 and counts.Epic / spins < 0.055) -- pity adds a little
    assert(counts.Legendary / spins > 0.005 and counts.Legendary / spins < 0.02)
end)

test("the fiftieth spin without an Epic is guaranteed Epic or better and resets pity", function()
    local p = rich()
    local low = sequence({0})
    for n = 1, 49 do
        local ok, owned = Gacha.spin(p, "StarterFryer", low)
        assert(ok); eq(PetConfig.Types[owned.type].Rarity, "Common"); eq(Gacha.pity(p, "StarterFryer"), n)
        if Pets.full(p) then p.pets = {} end
    end
    eq(Gacha.snapshot(p, "StarterFryer").pityEvery - Gacha.snapshot(p, "StarterFryer").pity, 1)
    local odds, forced = Gacha.odds(p, "StarterFryer")
    eq(forced, true); eq(odds.Common, 0); near(odds.Epic + odds.Legendary, 1); near(odds.Epic, 0.8)
    local ok, owned = Gacha.spin(p, "StarterFryer", low)
    assert(ok); eq(owned.type, "FryerBot"); eq(Gacha.pity(p, "StarterFryer"), 0)
    -- A natural Epic or Legendary also resets the counter.
    p.pets = {}
    Gacha.spin(p, "StarterFryer", low); eq(Gacha.pity(p, "StarterFryer"), 1)
    ok, owned = Gacha.spin(p, "StarterFryer", sequence({0.995, 0}))
    eq(owned.type, "FryKing"); eq(Gacha.pity(p, "StarterFryer"), 0)
    assert(Profile.validate(p))
end)

test("spins charge the fixed price add uniquely numbered pets and stop when full or broke", function()
    local p = rich(400)
    local ok, owned = Gacha.spin(p, "StarterFryer", sequence({0}))
    eq(ok, true); eq(p.cash, 250); eq(owned.id, "P1"); eq(owned.machine, "StarterFryer"); eq(#p.pets, 1)
    ok, owned = Gacha.spin(p, "StarterFryer", sequence({0})); eq(owned.id, "P2"); eq(p.cash, 100)
    local message
    ok, message = Gacha.spin(p, "StarterFryer", sequence({0}))
    eq(ok, false); eq(message, "Not enough Cash to spin."); eq(p.cash, 100); eq(#p.pets, 2)
    eq(Gacha.spin(p, "Nope", sequence({0})), false); eq(Gacha.isMachine("Nope"), false); eq(Gacha.isMachine(nil), false)
    p.cash = 1e9
    while #p.pets < PetConfig.MaxPets do Gacha.spin(p, "StarterFryer", sequence({0})) end
    ok, message = Gacha.spin(p, "StarterFryer", sequence({0}))
    eq(ok, false); eq(message, "Your pet inventory is full. Delete a pet to spin again."); eq(#p.pets, 50)
    eq(p.lifetimeCash, 0); assert(Profile.validate(p))
end)

test("equipping up to three pets adds their flat stats before upgrade percentages", function()
    local p = rich()
    for _, petType in ipairs({ "CrinkleFry", "CrinkleFry", "PotatoPup", "FryKing" }) do Pets.add(p, petType, "StarterFryer") end
    -- Crinkle Fry +4 / +$1 / +10, Potato Pup +6 / +$1.50 / +15, Fry King +12 / +$6 / +60.
    eq(Pets.equip(p, "P1"), true); eq(Pricing.click(p), 6)
    eq(Pets.equip(p, "P1"), false)
    eq(Pets.equip(p, "P2"), true); eq(Pets.equip(p, "P3"), true); eq(Pricing.click(p), 16)
    local ok, message = Pets.equip(p, "P4")
    eq(ok, false); eq(message, "All pet slots are full. Unequip a pet first.")
    eq(Pets.equip(p, "P99"), false)
    eq(Pets.unequip(p, "P2"), true); eq(Pets.unequip(p, "P2"), false)
    eq(Pets.equip(p, "P4"), true)
    eq(Pricing.click(p), 24); near(Pricing.perFry(p), 9.5); eq(Pricing.capacity(p), 125); eq(Pricing.sale(p), 1187) -- $1,187.50
    p.upgradeLevels = { FriesPerClick = 1, MoneyPerFry = 1 }
    near(Pricing.click(p), 26.4); eq(Pricing.sale(p), 1306) -- 125 x $10.45 = $1,306.25 rounds down
    assert(Profile.validate(p))
end)

test("capacity pets round down to whole fries and unequipping trims an over-full bag", function()
    local p = rich()
    Pets.add(p, "FryerBot", "StarterFryer"); Pets.add(p, "PotatoPup", "StarterFryer")
    Pets.equip(p, "P1"); eq(Pricing.capacity(p), 100); eq(Pricing.sale(p), 400)
    p.upgradeLevels = { BagCapacity = 1 }; eq(Pricing.capacity(p), 110)
    Pets.equip(p, "P2"); eq(Pricing.capacity(p), 126) -- 115 x 1.1 = 126.5
    p.upgradeLevels = {}
    eq(Packing.add(p, 200), true); eq(p.bag.fries, 115)
    eq(Pets.unequip(p, "P1"), true); Profile.normalize(p); eq(p.bag.fries, 55)
    eq(Pricing.capacity(p), 55); eq(Packing.sell(p), true); eq(p.bag.fries, 0)
end)

test("only unequipped pets can be deleted and IDs are never reused", function()
    local p = rich()
    Pets.add(p, "CrinkleFry", "StarterFryer"); Pets.add(p, "MayoJar", "StarterFryer")
    Pets.equip(p, "P2")
    local ok, message = Pets.delete(p, "P2")
    eq(ok, false); eq(message, "Unequip this pet before deleting it."); eq(#p.pets, 2)
    eq(Pets.delete(p, "P1"), true); eq(#p.pets, 1); eq(Pets.delete(p, "P1"), false)
    eq(Pets.add(p, "CrinkleFry", "StarterFryer").id, "P3")
    for _, bad in ipairs({ "1", "P", "PX", "P1;", string.rep("P1", 9), 1, {} }) do eq(Pets.isPetId(bad), false) end
    eq(Pets.isPetId("P42"), true)
end)

test("rebirth keeps pets equipped pets and pity", function()
    local p = rich(250000)
    Pets.add(p, "FryKing", "StarterFryer"); Pets.equip(p, "P1"); p.pity = { StarterFryer = 12 }
    eq(Rebirth.perform(p), true)
    eq(#p.pets, 1); eq(Pets.isEquipped(p, "P1"), true); eq(Gacha.pity(p, "StarterFryer"), 12); eq(Pricing.click(p), 14)
end)

test("upgrade shop values include equipped pet stats", function()
    local p = rich(); Pets.add(p, "CrinkleFry", "StarterFryer"); Pets.equip(p, "P1")
    local row = Upgrades.snapshot(p)[1]
    eq(row.value, 6); near(row.nextValue, 6.6)
end)

test("old prototype equipment never counts as equipped pets", function()
    local p = Profile.new(); p.equipped = { Machine = "ufo", Bag = "briefcase" }; p.owned = { ufo = true }
    assert(Profile.validate(p)); eq(Pets.total(p, "FriesPerClick"), 0); eq(#Pets.equipped(p), 0); eq(Pricing.click(p), 2)
end)

test("saved pets equipped pets and pity are validated", function()
    local function with(change) local p = Profile.new(); Pets.add(p, "CrinkleFry", "StarterFryer"); Pets.add(p, "MayoJar", "StarterFryer"); change(p); return Profile.validate(p) end
    eq(with(function() end), true)
    eq(with(function(p) p.equippedPets = { "P1", "P2" } end), true)
    for _, change in ipairs({
        function(p) p.pets[1].type = "Dragon" end,
        function(p) p.pets[1].machine = "Nope" end,
        function(p) p.pets[2].id = "P1" end,
        function(p) p.pets[1].id = "X1" end,
        function(p) p.pets[1] = "CrinkleFry" end,
        function(p) p.pets.extra = true end,
        function(p) p.equippedPets = { "P9" } end,
        function(p) p.equippedPets = { "P1", "P1" } end,
        function(p) p.equippedPets = { "P1", "P2", "P1", "P2" } end,
        function(p) p.equippedPets = "P1" end,
        function(p) p.pity = { Nope = 1 } end,
        function(p) p.pity = { StarterFryer = 51 } end,
        function(p) p.pity = { StarterFryer = 1.5 } end,
        function(p) p.nextPetId = -1 end,
        function(p) for _ = 1, 49 do Pets.add(p, "CrinkleFry", "StarterFryer") end end,
        function(p) p.pets = nil; p.equippedPets = { "P1" } end,
    }) do eq(with(change), false) end
end)

test("pets equipped pets and pity save and load", function()
    local db = { records = {} }
    function db:UpdateAsync(key, fn)
        local result = fn(Copy(self.records[key]))
        if result ~= nil then self.records[key] = Copy(result) end
        return Copy(result)
    end
    local store = Store.new(db, { validate = Profile.validate, copy = Copy, newProfile = Profile.new,
        now = function() return 100 end, wait = function() end, attempts = 3, leaseSeconds = 180 })
    local p = store:load("1", "A")
    eq(#p.pets, 0); eq(#p.equippedPets, 0)
    p.cash = 300
    Gacha.spin(p, "StarterFryer", sequence({0.96, 0})); Gacha.spin(p, "StarterFryer", sequence({0}))
    Pets.equip(p, "P1")
    eq(store:save("1", "A", p, true), true)
    local restored = store:load("1", "B")
    eq(Profile.migrate(restored), false)
    eq(#restored.pets, 2); eq(restored.pets[1].type, "FryerBot"); eq(restored.equippedPets[1], "P1")
    eq(restored.nextPetId, 2); eq(Gacha.pity(restored, "StarterFryer"), 1); eq(Pricing.capacity(restored), 100)
    eq(restored.cash, 0)
end)
