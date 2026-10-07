local Profile = loadModule("shared/domain/Profile")
local Pricing = loadModule("shared/domain/Pricing")
local Packing = loadModule("shared/domain/Packing")
local Folding = loadModule("shared/domain/Folding")
local Orders = loadModule("shared/domain/Orders")
local Upgrades = loadModule("shared/domain/Upgrades")
local Gacha = loadModule("shared/domain/Gacha")
local LunchRush = loadModule("shared/domain/LunchRush")
local Weighted = loadModule("shared/util/Weighted")
local RateLimiter = loadModule("shared/util/RateLimiter")
local Economy = loadModule("shared/config/Economy")
local Equipment = loadModule("shared/config/Equipment")
local Variants = loadModule("shared/config/Variants")
local function rng(value) return function() return value end end
local function full(p, value) Packing.add(p, 100, rng(value or 0)) end

test("fresh profiles are valid and isolated", function()
    local a, b = Profile.new(), Profile.new()
    a.upgrades.Click = 3
    eq(b.upgrades.Click, 0)
    assert(Profile.validate(a))
end)
test("reject corrupt, nonfinite and future profiles", function()
    for _, bad in ipairs({ -1, math.huge, 0/0, "100" }) do
        local p = Profile.new(); p.cash = bad; eq(Profile.validate(p), false)
    end
    local p = Profile.new(); p.version = 2; eq(Profile.validate(p), false)
end)
test("catalogue probabilities and starter equipment are consistent", function()
    for _, list in ipairs({ Equipment.Rarities, Equipment.GuaranteedRarities, Variants }) do
        local sum = 0
        for _, entry in ipairs(list) do sum += entry.weight end
        eq(sum, 100)
    end
    for _, category in ipairs(Equipment.Categories) do
        assert(Equipment.Items[Equipment.Starter[category]])
        for _, rarity in ipairs(Equipment.Rarities) do
            eq(Equipment.Items[Equipment.Pools[category][rarity.id]].category, category)
        end
    end
end)
test("weighted boundaries have no gaps or overlaps", function()
    for _, example in ipairs({ {0, "Common"}, {0.599999, "Common"}, {0.60, "Rare"},
        {0.899999, "Rare"}, {0.90, "Epic"}, {0.99, "Legendary"}, {0.999999, "Legendary"} }) do
        eq(Weighted(Equipment.Rarities, rng(example[1])).id, example[2])
    end
    eq(pcall(function() Weighted(Equipment.Rarities, rng(1)) end), false)
end)
test("packing clamps overflow and rolls only once", function()
    local p, calls = Profile.new(), 0
    local function random() calls += 1; return 0.99 end
    Packing.add(p, 19.5, random); eq(calls, 0)
    Packing.add(p, 50, random); eq(p.bag.fries, 20); eq(calls, 1)
    Packing.add(p, 50, random); eq(calls, 1)
    eq(p.bag.variant, "golden"); eq(p.bag.value, 30)
    assert(Profile.validate(p))
end)
test("partial bag cannot be sold", function()
    local p = Profile.new(); Packing.add(p, 19, rng(0))
    eq(Packing.sell(p), false); eq(p.cash, 0); eq(p.bag.fries, 19)
end)
test("repeated sell cannot duplicate a reward", function()
    local p = Profile.new(); full(p)
    eq(Packing.sell(p), true); eq(Packing.sell(p), false)
    eq(p.cash, 10); eq(p.sales, 1); eq(p.lifetimeCash, 10)
    assert(Profile.validate(p))
end)
test("full bag value is locked across upgrades and equipment swaps", function()
    local p = Profile.new(); full(p)
    p.upgrades.Sales = 5; p.owned.briefcase = true
    Upgrades.equip(p, "briefcase")
    Packing.sell(p); eq(p.cash, 10)
    full(p); eq(p.bag.value, 40)
end)
test("upgrades check balance, spend once and respect level cap", function()
    local p = Profile.new()
    eq(Upgrades.buy(p, "Click"), false)
    p.cash = 30; eq(Upgrades.buy(p, "Click"), true)
    eq(p.cash, 0); eq(Pricing.click(p), 2)
    p.cash = 100000000; p.upgrades.Click = Economy.MaxUpgradeLevel
    eq(Upgrades.buy(p, "Click"), false)
    eq(Upgrades.buy(p, "bad"), false)
end)
test("sales bonus is additive and upgrade costs grow", function()
    local p = Profile.new(); p.upgrades.Sales = 2
    eq(Pricing.sale(p, 1), 14)
    eq(Pricing.upgrade(0), 30); eq(Pricing.upgrade(1), 45); eq(Pricing.upgrade(2), 68)
end)
test("unowned or unknown equipment cannot be equipped", function()
    local p = Profile.new()
    eq(Upgrades.equip(p, "ufo"), false)
    eq(Upgrades.equip(p, "made_up"), false)
    eq(p.equipped.Machine, "starter_fryer")
end)
test("gacha rejects invalid pool and insufficient tickets", function()
    local p = Profile.new()
    eq(Gacha(p, "Machine", rng(0)), false)
    p.tickets = 3; eq(Gacha(p, "fake", rng(0)), false); eq(p.tickets, 3)
end)
test("gacha grants ownership without auto-equipping", function()
    local p = Profile.new(); p.tickets = 3
    local ok, result = Gacha(p, "Machine", rng(0))
    eq(ok, true); eq(result.id, "countertop"); eq(result.duplicate, false)
    eq(p.tickets, 0); eq(p.owned.countertop, true); eq(p.equipped.Machine, "starter_fryer")
end)
test("duplicate refunds exactly one ticket and advances counter", function()
    local p = Profile.new(); p.tickets = 6
    Gacha(p, "Machine", rng(0))
    local _, result = Gacha(p, "Machine", rng(0))
    eq(result.duplicate, true); eq(p.tickets, 1); eq(p.pity.Machine, 2)
end)
test("tenth unlucky roll guarantees Epic and resets only its pool", function()
    local p = Profile.new(); p.tickets = 100
    for _ = 1, 9 do Gacha(p, "Machine", rng(0)) end
    eq(p.pity.Machine, 9); eq(p.pity.Bag, 0)
    p.pity.Bag = 4
    local _, result = Gacha(p, "Machine", rng(0))
    eq(result.rarity, "Epic"); eq(result.guaranteed, true)
    eq(p.pity.Machine, 0); eq(p.pity.Bag, 4)
end)
test("guaranteed Legendary boundary is 90 percent", function()
    local p = Profile.new(); p.tickets = 3; p.pity.Bag = 9
    local _, result = Gacha(p, "Bag", rng(0.90))
    eq(result.rarity, "Legendary")
end)
test("natural Epic resets pity", function()
    local p = Profile.new(); p.tickets = 3; p.pity.Bag = 5
    Gacha(p, "Bag", rng(0.91)); eq(p.pity.Bag, 0)
end)
test("order milestones carry overflow and tutorial pays once", function()
    local p = Profile.new()
    for _ = 1, 10 do full(p); Packing.sell(p); Orders(p) end
    eq(p.tickets, 5); eq(p.orderProgress, 0); eq(p.tutorialClaimed, true)
    p.orderProgress = 90; Orders(p); eq(p.orderProgress, 10); eq(p.tickets, 6)
end)
test("index completion pays once and survives sales", function()
    local p = Profile.new()
    for _, unit in ipairs({0, 0.85, 0.99, 0.99}) do full(p, unit); Packing.sell(p) end
    eq(p.tickets, 3); eq(p.indexRewardClaimed, true)
    eq(p.discoveries.regular, true); eq(p.discoveries.loaded, true); eq(p.discoveries.golden, true)
end)
test("perfect fold uses server time and can be attempted only once", function()
    local p, runtime = Profile.new(), {}
    eq(Folding.start(p, runtime, 0), false)
    full(p); eq(Folding.start(p, runtime, 10), true)
    eq(Folding.start(p, runtime, 10), false)
    eq(Folding.finish(p, runtime, 10 + Economy.FoldLeadTime + Economy.FoldDuration * 0.5), true)
    eq(p.bag.perfect, true); eq(Folding.finish(p, runtime, 11), false)
    Packing.sell(p); eq(p.cash, 13)
end)
test("early and late fold misses preserve normal sale", function()
    for _, time in ipairs({0, 100}) do
        local p, runtime = Profile.new(), {}; full(p); Folding.start(p, runtime, 5)
        Folding.finish(p, runtime, time); eq(p.bag.perfect, false)
        Packing.sell(p); eq(p.cash, 10)
    end
end)
test("currency credits stay within safe range", function()
    local p = Profile.new(); p.cash = Economy.MaxCurrency - 1
    Pricing.credit(p, "cash", 100); eq(p.cash, Economy.MaxCurrency)
end)
test("rate limiter blocks bursts and cleans disconnected players", function()
    local limit = RateLimiter.new(4, 1)
    eq(limit:allow("a", 0), true); eq(limit:allow("a", 0), false)
    eq(limit:allow("a", 0.24), false); eq(limit:allow("a", 0.25), true)
    eq(limit:allow("b", 0), true)
    limit:remove("a"); eq(limit.buckets.a, nil)
end)
test("rush freezes participant roster and rejects late sales", function()
    local rush = LunchRush.new(0)
    rush:step(90, {1, 2})
    eq(rush.target, 16)
    rush:sale(3, 100); eq(rush.count, 0)
    rush:sale(1, 180); eq(rush.count, 0)
    eq(rush:snapshot(3).eligible, false)
end)
test("rush rewards only qualifying contributors once", function()
    local rush = LunchRush.new(0); rush:step(90, {1, 2})
    for _ = 1, 14 do rush:sale(1, 100) end
    for _ = 1, 2 do rush:sale(2, 100) end
    local winners = rush:step(180, {1, 2})
    eq(#winners, 1); eq(winners[1], 1)
    eq(rush:step(181, {1, 2}), nil)
end)
test("failed rush pays no tickets and empty servers do not start", function()
    local rush = LunchRush.new(0); rush:step(90, {}); eq(rush.active, false)
    rush:step(95, {1}); rush:sale(1, 100)
    eq(#rush:step(185, {1}), 0)
end)
test("10000 mixed progression actions preserve profile invariants", function()
    local p = Profile.new()
    local seed = 12345
    local function random() seed = (seed * 16807) % 2147483647; return seed / 2147483647 end
    for i = 1, 10000 do
        Packing.add(p, Pricing.click(p) + Pricing.automatic(p), random)
        if p.bag.fries == Economy.Capacity then Packing.sell(p); Orders(p) end
        if i % 7 == 0 then Upgrades.buy(p, "Click") end
        if i % 11 == 0 then Upgrades.buy(p, "Sales") end
        if i % 13 == 0 then
            local ok, result = Gacha(p, if i % 2 == 0 then "Machine" else "Bag", random)
            if ok then Upgrades.equip(p, result.id) end
        end
        assert(Profile.validate(p), "Invalid profile at action " .. i)
    end
end)
