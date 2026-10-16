-- Gem upgrade rules, rebirth, and their saved fields.
local Profile = loadModule("shared/domain/Profile")
local Pricing = loadModule("shared/domain/Pricing")
local Packing = loadModule("shared/domain/Packing")
local Upgrades = loadModule("shared/domain/Upgrades")
local Rebirth = loadModule("shared/domain/Rebirth")
local Config = loadModule("shared/config/Upgrades")
local Store = loadModule("server/storage/ProfileStore")
local Copy = loadModule("shared/util/Copy")

test("gem upgrade costs follow the agreed curves and round to whole gems", function()
    eq(Upgrades.cost("FriesPerClick", 0), 3); eq(Upgrades.cost("FriesPerClick", 1), 4); eq(Upgrades.cost("FriesPerClick", 2), 5)
    eq(Upgrades.cost("MoneyPerFry", 0), 4); eq(Upgrades.cost("MoneyPerFry", 1), 5)
    eq(Upgrades.cost("BagCapacity", 0), 5); eq(Upgrades.cost("BagCapacity", 1), 6)
    eq(Upgrades.cost("FriesPerClick", 10), math.floor(3 * 1.25 ^ 10 + 0.5))
    for _, id in ipairs(Config.Order) do
        local previous = 0
        for level = 0, 120 do
            local cost = Upgrades.cost(id, level)
            eq(cost % 1, 0); assert(cost >= previous); previous = cost
        end
    end
    eq(#Config.Order, 3)
end)

test("upgrade levels raise fries per click money per fry and bag capacity", function()
    local p = Profile.new()
    eq(Pricing.click(p), 1); eq(Pricing.perFry(p), 0.5); eq(Pricing.capacity(p), 20); eq(Pricing.sale(p), 10)
    p.upgradeLevels = { FriesPerClick = 2 }; eq(Pricing.click(p), 3)
    p.upgradeLevels = { MoneyPerFry = 1 }; eq(Pricing.perFryCents(p), 55); eq(Pricing.sale(p), 11)
    p.upgradeLevels = { BagCapacity = 1 }; eq(Pricing.capacity(p), 25); eq(Pricing.sale(p), 12) -- 12.50 rounds down
    p.upgradeLevels = { MoneyPerFry = 1, BagCapacity = 1 }; eq(Pricing.sale(p), 13) -- 13.75 rounds down
    p.upgradeLevels = { MoneyPerFry = 10 }; eq(Pricing.sale(p), 20)
    eq(Pricing.automatic(), 0.5)
end)

test("buying spends gems once raises one level and never spends Cash", function()
    local p = Profile.new(); p.gems = 15; p.cash = 500
    local ok, cost = Upgrades.buy(p, "FriesPerClick")
    eq(ok, true); eq(cost, 3); eq(p.gems, 12); eq(Pricing.level(p, "FriesPerClick"), 1)
    ok = Upgrades.buy(p, "FriesPerClick"); eq(ok, true); eq(p.gems, 8); eq(Pricing.click(p), 3)
    ok = Upgrades.buy(p, "MoneyPerFry"); eq(ok, true); eq(p.gems, 4)
    local message
    ok, message = Upgrades.buy(p, "BagCapacity")
    eq(ok, false); eq(message, "Not enough gems for this upgrade."); eq(p.gems, 4); eq(Pricing.level(p, "BagCapacity"), 0)
    eq(p.cash, 500); eq(p.lifetimeCash, 0); assert(Profile.validate(p))
end)

test("exactly enough gems buys an upgrade and unknown tracks are rejected", function()
    local p = Profile.new(); p.gems = 5
    eq(Upgrades.buy(p, "BagCapacity"), true); eq(p.gems, 0)
    p.cash = 1000000; eq(Upgrades.buy(p, "FriesPerClick"), false); eq(p.cash, 1000000)
    for _, bad in ipairs({ "Click", "Sales", "upgrades", "", 5, true }) do
        eq(Upgrades.isTrack(bad), false)
        p.gems = 1000; eq(Upgrades.buy(p, bad), false); eq(p.gems, 1000)
    end
    eq(Upgrades.isTrack(nil), false)
end)

test("old prototype upgrade data never grants levels", function()
    local p = Profile.new(); p.upgrades = { Click = 20, Sales = 20, FriesPerClick = 9 }
    p.upgradeLevels = nil
    eq(Pricing.click(p), 1); eq(Pricing.capacity(p), 20); eq(Pricing.sale(p), 10)
    assert(Profile.validate(p))
    for _, row in ipairs(Upgrades.snapshot(p)) do eq(row.level, 0) end
end)

test("buying capacity with a full bag makes it partial without losing fries", function()
    local p = Profile.new(); p.gems = 5
    eq(Packing.add(p, 20), true); eq(p.bag.fries, 20)
    eq(Upgrades.buy(p, "BagCapacity"), true)
    eq(p.bag.fries, 20); eq(Packing.sell(p), false)
    eq(Packing.add(p, 3), false); eq(p.bag.fries, 23)
    eq(Packing.add(p, 10), true); eq(p.bag.fries, 25)
    local ok, value = Packing.sell(p); eq(ok, true); eq(value, 12); eq(p.cash, 12); eq(p.bag.fries, 0)
end)

test("shop snapshot rows show level value next value and gem cost in shop order", function()
    local p = Profile.new(); p.upgradeLevels = { MoneyPerFry = 2 }
    local rows = Upgrades.snapshot(p)
    eq(rows[1].id, "FriesPerClick"); eq(rows[1].value, 1); eq(rows[1].nextValue, 2); eq(rows[1].cost, 3)
    eq(rows[2].id, "MoneyPerFry"); eq(rows[2].level, 2); near(rows[2].value, 0.6); near(rows[2].nextValue, 0.65)
    eq(rows[2].cost, Upgrades.cost("MoneyPerFry", 2))
    eq(rows[3].id, "BagCapacity"); eq(rows[3].value, 20); eq(rows[3].nextValue, 25)
    eq(rows[1].name, "Fries per click")
end)

test("rebirth thresholds and gem rewards rise with each rebirth", function()
    local p = Profile.new()
    local expected = { {1000, 10}, {1600, 15}, {2560, 20}, {4096, 25}, {6554, 30} }
    for n, pair in ipairs(expected) do
        p.rebirths = n - 1
        eq(Rebirth.threshold(p), pair[1]); eq(Rebirth.reward(p), pair[2])
    end
    p.rebirths = 20; eq(Rebirth.threshold(p) % 1, 0)
    p.rebirths = nil; eq(Rebirth.count(p), 0); eq(Rebirth.threshold(p), 1000)
end)

test("rebirth needs the threshold and resets only Cash and the bag", function()
    local p = Profile.new(); p.cash = 999; p.gems = 2
    p.upgradeLevels = { FriesPerClick = 3 }; p.bag.fries = 7; p.sales = 50; p.lifetimeCash = 999
    local ok, message = Rebirth.perform(p)
    eq(ok, false); eq(message, "Reach the rebirth threshold first."); eq(p.cash, 999); eq(p.gems, 2); eq(p.rebirths, 0)
    eq(Rebirth.ready(p), false)
    p.cash = 1450 -- everything above the threshold is lost too
    eq(Rebirth.ready(p), true)
    local gems
    ok, gems = Rebirth.perform(p)
    eq(ok, true); eq(gems, 10)
    eq(p.cash, 0); eq(p.bag.fries, 0); eq(p.gems, 12); eq(p.rebirths, 1)
    eq(Pricing.level(p, "FriesPerClick"), 3); eq(p.sales, 50); eq(p.lifetimeCash, 999)
    eq(Rebirth.perform(p), false); eq(p.gems, 12)
    p.cash = 1600; eq(select(2, Rebirth.perform(p)), 15); eq(p.gems, 27); eq(Rebirth.threshold(p), 2560)
    assert(Profile.validate(p))
end)

test("saves from before gems reset Cash-bought upgrades to level 0 once", function()
    local old = Profile.new(); old.gems, old.rebirths = nil, nil
    old.cash = 300; old.upgradeLevels = { FriesPerClick = 4, BagCapacity = 2 }; old.bag.fries = 28
    assert(Profile.validate(old))
    eq(Profile.migrate(old), true)
    eq(old.gems, 0); eq(old.rebirths, 0); eq(next(old.upgradeLevels), nil)
    eq(old.cash, 300); eq(old.bag.fries, 20); assert(Profile.validate(old))
    -- Profiles that already have gems are never migrated again.
    old.upgradeLevels = { FriesPerClick = 1 }; old.gems = 4
    eq(Profile.migrate(old), false); eq(Pricing.level(old, "FriesPerClick"), 1)
    local fresh = Profile.new(); eq(Profile.migrate(fresh), false)
end)

test("saved upgrade levels gems and rebirths are validated", function()
    local p = Profile.new(); p.upgradeLevels = { FriesPerClick = 3, BagCapacity = 1 }; assert(Profile.validate(p))
    for _, bad in ipairs({ { Click = 1 }, { FriesPerClick = -1 }, { FriesPerClick = 1.5 }, { FriesPerClick = "2" },
        { FriesPerClick = 0/0 }, { BagCapacity = Config.MaxLevel + 1 }, { [1] = 1 } }) do
        p.upgradeLevels = bad; eq(Profile.validate(p), false)
    end
    p.upgradeLevels = "levels"; eq(Profile.validate(p), false)
    p.upgradeLevels = { BagCapacity = 1 }; p.bag.fries = 24; assert(Profile.validate(p))
    p.upgradeLevels = {}; assert(Profile.validate(p)); Profile.normalize(p); eq(p.bag.fries, 20)
    p.bag.fries = 0
    for _, key in ipairs({ "gems", "rebirths" }) do
        for _, bad in ipairs({ -1, 1.5, "3", 0/0, math.huge }) do
            local q = Profile.new(); q[key] = bad; eq(Profile.validate(q), false)
        end
    end
end)

test("gems rebirths and upgrade levels save and load with Cash and the bag", function()
    local db = { records = {} }
    function db:UpdateAsync(key, fn)
        local result = fn(Copy(self.records[key]))
        if result ~= nil then self.records[key] = Copy(result) end
        return Copy(result)
    end
    local store = Store.new(db, { validate = Profile.validate, copy = Copy, newProfile = Profile.new,
        now = function() return 100 end, wait = function() end, attempts = 3, leaseSeconds = 180 })
    local p = store:load("1", "A")
    eq(next(p.upgradeLevels), nil); eq(p.gems, 0); eq(p.rebirths, 0)
    p.cash = 1000
    eq(Rebirth.perform(p), true)
    eq(Upgrades.buy(p, "BagCapacity"), true); eq(Upgrades.buy(p, "MoneyPerFry"), true)
    p.cash = 40; Packing.add(p, 24)
    eq(store:save("1", "A", p, true), true)
    local restored = store:load("1", "B")
    eq(Profile.migrate(restored), false)
    eq(restored.cash, 40); eq(restored.gems, 1); eq(restored.rebirths, 1)
    eq(Pricing.level(restored, "BagCapacity"), 1); eq(Pricing.level(restored, "MoneyPerFry"), 1)
    eq(Pricing.level(restored, "FriesPerClick"), 0); eq(restored.bag.fries, 24)
    -- Corrupt saved fields refuse to load rather than granting or wiping progress.
    local old = Profile.new(); old.upgradeLevels = { FriesPerClick = -3 }
    db.records["3"] = { data = Copy(old) }
    eq(store:load("3", "D"), nil)
    old.upgradeLevels = {}; old.gems = -5
    db.records["4"] = { data = Copy(old) }
    eq(store:load("4", "E"), nil)
end)
