-- Cash upgrade rules and their saved levels.
local Profile = loadModule("shared/domain/Profile")
local Pricing = loadModule("shared/domain/Pricing")
local Packing = loadModule("shared/domain/Packing")
local Upgrades = loadModule("shared/domain/Upgrades")
local Config = loadModule("shared/config/Upgrades")
local Store = loadModule("server/storage/ProfileStore")
local Copy = loadModule("shared/util/Copy")

test("upgrade costs follow the agreed curves and round to whole Cash", function()
    eq(Upgrades.cost("FriesPerClick", 0), 25); eq(Upgrades.cost("FriesPerClick", 1), 30)
    eq(Upgrades.cost("MoneyPerFry", 0), 40); eq(Upgrades.cost("MoneyPerFry", 1), 48)
    eq(Upgrades.cost("BagCapacity", 0), 50); eq(Upgrades.cost("BagCapacity", 1), 63)
    eq(Upgrades.cost("FriesPerClick", 10), math.floor(25 * 1.18 ^ 10 + 0.5))
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

test("buying deducts the cost once and raises one level", function()
    local p = Profile.new(); p.cash = 100
    local ok, cost = Upgrades.buy(p, "FriesPerClick")
    eq(ok, true); eq(cost, 25); eq(p.cash, 75); eq(Pricing.level(p, "FriesPerClick"), 1)
    ok = Upgrades.buy(p, "FriesPerClick"); eq(ok, true); eq(p.cash, 45); eq(Pricing.click(p), 3)
    ok = Upgrades.buy(p, "MoneyPerFry"); eq(ok, true); eq(p.cash, 5)
    local message
    ok, message = Upgrades.buy(p, "BagCapacity")
    eq(ok, false); eq(message, "Not enough Cash for this upgrade."); eq(p.cash, 5); eq(Pricing.level(p, "BagCapacity"), 0)
    eq(p.lifetimeCash, 0); assert(Profile.validate(p))
end)

test("exactly enough Cash buys an upgrade and unknown tracks are rejected", function()
    local p = Profile.new(); p.cash = 50
    eq(Upgrades.buy(p, "BagCapacity"), true); eq(p.cash, 0)
    for _, bad in ipairs({ "Click", "Sales", "upgrades", "", 5, true }) do
        eq(Upgrades.isTrack(bad), false)
        p.cash = 1000; eq(Upgrades.buy(p, bad), false); eq(p.cash, 1000)
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
    local p = Profile.new(); p.cash = 50
    eq(Packing.add(p, 20), true); eq(p.bag.fries, 20)
    eq(Upgrades.buy(p, "BagCapacity"), true)
    eq(p.bag.fries, 20); eq(Packing.sell(p), false)
    eq(Packing.add(p, 3), false); eq(p.bag.fries, 23)
    eq(Packing.add(p, 10), true); eq(p.bag.fries, 25)
    local ok, value = Packing.sell(p); eq(ok, true); eq(value, 12); eq(p.cash, 12); eq(p.bag.fries, 0)
end)

test("shop snapshot rows show level value next value and cost in shop order", function()
    local p = Profile.new(); p.upgradeLevels = { MoneyPerFry = 2 }
    local rows = Upgrades.snapshot(p)
    eq(rows[1].id, "FriesPerClick"); eq(rows[1].value, 1); eq(rows[1].nextValue, 2); eq(rows[1].cost, 25)
    eq(rows[2].id, "MoneyPerFry"); eq(rows[2].level, 2); near(rows[2].value, 0.6); near(rows[2].nextValue, 0.65)
    eq(rows[2].cost, Upgrades.cost("MoneyPerFry", 2))
    eq(rows[3].id, "BagCapacity"); eq(rows[3].value, 20); eq(rows[3].nextValue, 25)
    eq(rows[1].name, "Fries per click")
end)

test("saved upgrade levels are validated", function()
    local p = Profile.new(); p.upgradeLevels = { FriesPerClick = 3, BagCapacity = 1 }; assert(Profile.validate(p))
    for _, bad in ipairs({ { Click = 1 }, { FriesPerClick = -1 }, { FriesPerClick = 1.5 }, { FriesPerClick = "2" },
        { FriesPerClick = 0/0 }, { BagCapacity = Config.MaxLevel + 1 }, { [1] = 1 } }) do
        p.upgradeLevels = bad; eq(Profile.validate(p), false)
    end
    p.upgradeLevels = "levels"; eq(Profile.validate(p), false)
    -- A bag above base capacity is valid only with the capacity level that allows it.
    p.upgradeLevels = { BagCapacity = 1 }; p.bag.fries = 24; assert(Profile.validate(p))
    p.upgradeLevels = {}; eq(Profile.validate(p), false)
end)

test("upgrade levels save and load with cash and the bag", function()
    local db = { records = {} }
    function db:UpdateAsync(key, fn)
        local result = fn(Copy(self.records[key]))
        if result ~= nil then self.records[key] = Copy(result) end
        return Copy(result)
    end
    local store = Store.new(db, { validate = Profile.validate, copy = Copy, newProfile = Profile.new,
        now = function() return 100 end, wait = function() end, attempts = 3, leaseSeconds = 180 })
    local p = store:load("1", "A")
    eq(next(p.upgradeLevels), nil)
    p.cash = 200
    eq(Upgrades.buy(p, "BagCapacity"), true); eq(Upgrades.buy(p, "MoneyPerFry"), true)
    Packing.add(p, 24)
    eq(store:save("1", "A", p, true), true)
    local restored = store:load("1", "B")
    eq(restored.cash, 110); eq(Pricing.level(restored, "BagCapacity"), 1); eq(Pricing.level(restored, "MoneyPerFry"), 1)
    eq(Pricing.level(restored, "FriesPerClick"), 0); eq(restored.bag.fries, 24)
    -- Saves made before upgrade levels existed load at level 0.
    local old = Profile.new(); old.upgradeLevels = nil; old.cash = 7; old.upgrades = { Click = 20 }
    db.records["2"] = { data = Copy(old) }
    local loaded = store:load("2", "C")
    eq(loaded.cash, 7); eq(Pricing.click(loaded), 1)
    -- Corrupt upgrade data refuses to load rather than granting or wiping progress.
    old.upgradeLevels = { FriesPerClick = -3 }
    db.records["3"] = { data = Copy(old) }
    eq(store:load("3", "D"), nil)
end)
