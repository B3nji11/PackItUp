-- Inventory management (Golden merges, bulk delete, auto-delete) and saved settings.
local Profile = loadModule("shared/domain/Profile")
local Pricing = loadModule("shared/domain/Pricing")
local Gacha = loadModule("shared/domain/Gacha")
local Pets = loadModule("shared/domain/Pets")
local Settings = loadModule("shared/domain/Settings")
local Store = loadModule("server/storage/ProfileStore")
local Copy = loadModule("shared/util/Copy")
local function owner(types)
    local p = Profile.new(); p.cash = 100000
    for _, petType in ipairs(types) do Pets.add(p, petType, "StarterFryer") end
    return p
end
local function always(value) return function() return value end end

test("five unequipped copies merge into one Golden pet with double stats", function()
    local p = owner({ "CrinkleFry", "CrinkleFry", "CrinkleFry", "CrinkleFry", "CrinkleFry", "CrinkleFry", "MayoJar" })
    Pets.equip(p, "P1")
    eq(#Pets.mergeable(p), 1); eq(Pets.mergeable(p)[1].type, "CrinkleFry"); eq(Pets.mergeable(p)[1].count, 5)
    local ok, golden = Pets.merge(p, "CrinkleFry")
    eq(ok, true); eq(golden.id, "P8"); eq(golden.golden, true); eq(golden.type, "CrinkleFry")
    eq(#p.pets, 3) -- equipped P1, MayoJar, and the Golden pet
    eq(Pets.isEquipped(p, "P1"), true); assert(Pets.find(p, "P1")); assert(Pets.find(p, "P7"))
    eq(Pets.petStat(golden, "FriesPerClick"), 8); eq(Pets.petStat(golden, "MoneyPerFry"), 2); eq(Pets.petStat(golden, "BagCapacity"), 20)
    Pets.equip(p, "P8"); eq(Pricing.click(p), 14) -- base 2 + Crinkle Fry 4 + Golden Crinkle Fry 8
    local message
    ok, message = Pets.merge(p, "CrinkleFry")
    eq(ok, false); eq(message, "You need 5 unequipped copies of that pet to merge.")
    eq(#Pets.mergeable(p), 0); assert(Profile.validate(p))
end)

test("Golden pets are never merged again and mergeable lists rarest first", function()
    local p = owner({})
    for _ = 1, 5 do Pets.add(p, "FryerBot", "StarterFryer") end
    for _ = 1, 5 do Pets.add(p, "SaltShaker", "StarterFryer") end
    local rows = Pets.mergeable(p)
    eq(rows[1].type, "FryerBot"); eq(rows[2].type, "SaltShaker")
    Pets.merge(p, "FryerBot")
    for _ = 1, 4 do Pets.add(p, "FryerBot", "StarterFryer") end
    eq(Pets.mergeable(p)[1].type, "SaltShaker") -- 4 normal + 1 Golden is not 5
    eq(Pets.merge(p, "Dragon"), false); eq(Pets.isPetType("Dragon"), false); eq(Pets.isPetType("FryKing"), true)
end)

test("delete all removes only unequipped non-golden pets of a bulk rarity", function()
    local p = owner({ "CrinkleFry", "SaltShaker", "PaperCup", "PotatoPup", "FryerBot" })
    Pets.equip(p, "P1")
    Pets.add(p, "SaltShaker", "StarterFryer", true)
    local ok, count = Pets.deleteRarity(p, "Common")
    eq(ok, true); eq(count, 2)
    eq(#p.pets, 4); assert(Pets.find(p, "P1")); assert(Pets.find(p, "P6")); assert(Pets.find(p, "P4")); assert(Pets.find(p, "P5"))
    local message
    ok, message = Pets.deleteRarity(p, "Common")
    eq(ok, false); eq(message, "No unequipped Common pets to delete.")
    for _, protected in ipairs({ "Epic", "Legendary", "Mythic", nil }) do eq(Pets.deleteRarity(p, protected), false) end
    eq(#p.pets, 4)
end)

test("auto-deleted rarities still cost the spin and count for pity but are not kept", function()
    local p = owner({})
    eq(Pets.toggleAutoDelete(p, "Common"), true); eq(Pets.autoDeletes(p, "Common"), true)
    local ok, result = Gacha.spin(p, "StarterFryer", always(0))
    eq(ok, true); eq(result.autoDeleted, true); eq(result.type, "CrinkleFry"); eq(result.rarity, "Common")
    eq(#p.pets, 0); eq(p.cash, 99850); eq(Gacha.pity(p, "StarterFryer"), 1)
    ok, result = Gacha.spin(p, "StarterFryer", always(0.7))
    eq(result.autoDeleted, nil); eq(result.type, "KetchupPacket"); eq(#p.pets, 1)
    eq(Pets.toggleAutoDelete(p, "Epic"), false); eq(Pets.toggleAutoDelete(p, "Legendary"), false)
    Pets.toggleAutoDelete(p, "Common"); eq(Pets.autoDeletes(p, "Common"), false)
    Gacha.spin(p, "StarterFryer", always(0)); eq(#p.pets, 2)
    assert(Profile.validate(p))
end)

test("settings default on toggle and reject unknown names", function()
    local p = Profile.new()
    eq(Settings.get(p, "PetsFollow"), true); eq(Settings.get(p, "ShowOtherPets"), true)
    eq(select(2, Settings.toggle(p, "PetsFollow")), false); eq(Settings.get(p, "PetsFollow"), false)
    eq(select(2, Settings.toggle(p, "PetsFollow")), true)
    eq(Settings.toggle(p, "Admin"), false); eq(Settings.isSetting("Admin"), false); eq(Settings.isSetting(nil), false)
    local snap = Settings.snapshot(p); eq(snap.PetsFollow, true); eq(snap.ShowOtherPets, true)
    assert(Profile.validate(p))
end)

test("the public follow text lists equipped pets and respects Pets follow me", function()
    local followText = loadModule("server/services/SnapshotService").followText
    local p = owner({ "FryKing", "MayoJar", "CrinkleFry" })
    eq(followText(p), "")
    p.pets[1].golden = true
    Pets.equip(p, "P1"); Pets.equip(p, "P2")
    eq(followText(p), "FryKing*,MayoJar")
    Settings.toggle(p, "PetsFollow"); eq(followText(p), "")
end)

test("golden flags settings and auto-delete are validated", function()
    local function valid(change) local p = owner({ "CrinkleFry" }); change(p); return Profile.validate(p) end
    eq(valid(function(p) p.pets[1].golden = true; p.settings = { PetsFollow = false }; p.autoDelete = { Common = true, Rare = true } end), true)
    for _, change in ipairs({
        function(p) p.pets[1].golden = false end,
        function(p) p.pets[1].golden = "yes" end,
        function(p) p.settings = { Admin = true } end,
        function(p) p.settings = { PetsFollow = "off" } end,
        function(p) p.settings = "on" end,
        function(p) p.autoDelete = { Epic = true } end,
        function(p) p.autoDelete = { Common = false } end,
        function(p) p.autoDelete = { "Common" } end,
    }) do eq(valid(change), false) end
end)

test("golden pets settings and auto-delete save and load", function()
    local db = { records = {} }
    function db:UpdateAsync(key, fn)
        local result = fn(Copy(self.records[key]))
        if result ~= nil then self.records[key] = Copy(result) end
        return Copy(result)
    end
    local store = Store.new(db, { validate = Profile.validate, copy = Copy, newProfile = Profile.new,
        now = function() return 100 end, wait = function() end, attempts = 3, leaseSeconds = 180 })
    local p = store:load("1", "A")
    for _ = 1, 5 do Pets.add(p, "MayoJar", "StarterFryer") end
    Pets.merge(p, "MayoJar"); Pets.equip(p, "P6")
    Settings.toggle(p, "ShowOtherPets"); Pets.toggleAutoDelete(p, "Uncommon")
    eq(store:save("1", "A", p, true), true)
    local restored = store:load("1", "B")
    eq(#restored.pets, 1); eq(restored.pets[1].golden, true); eq(restored.equippedPets[1], "P6")
    eq(Pricing.perFry(restored), 9) -- $1 base + Golden Mayo Jar $8
    eq(Settings.get(restored, "ShowOtherPets"), false); eq(Settings.get(restored, "PetsFollow"), true)
    eq(Pets.autoDeletes(restored, "Uncommon"), true)
end)
