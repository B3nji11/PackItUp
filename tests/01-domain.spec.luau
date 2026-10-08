local Profile = loadModule("shared/domain/Profile")
local Pricing = loadModule("shared/domain/Pricing")
local Packing = loadModule("shared/domain/Packing")
local RateLimiter = loadModule("shared/util/RateLimiter")
local Economy = loadModule("shared/config/Economy")

test("fresh profiles start with an empty bag and zero cash", function()
    local a, b = Profile.new(), Profile.new()
    assert(Profile.validate(a)); eq(a.cash, 0); eq(a.bag.fries, 0)
    a.bag.fries = 5; eq(b.bag.fries, 0)
    eq(a.owned, nil); eq(a.upgrades, nil); eq(a.tickets, nil)
end)

test("corrupt nonfinite and future core profiles are rejected", function()
    for _, bad in ipairs({-1, math.huge, 0/0, "100", 0.5}) do
        local p = Profile.new(); p.cash = bad; eq(Profile.validate(p), false)
    end
    for _, bad in ipairs({-1, math.huge, 0/0, "20", Economy.Capacity + 1}) do
        local p = Profile.new(); p.bag.fries = bad; eq(Profile.validate(p), false)
    end
    local p = Profile.new(); p.version = 2; eq(Profile.validate(p), false)
    p = Profile.new(); p.bag = nil; eq(Profile.validate(p), false)
end)

test("basic fryer click and sale values do not depend on old progression", function()
    local old = {upgrades={Click=20,Sales=20}, equipped={Machine="ufo",Bag="briefcase"}}
    eq(Pricing.click(old), 1); eq(Pricing.automatic(old), 0.5); eq(Pricing.sale(old), 10)
end)

test("click and fryer filling clamp at one full bag", function()
    local p = Profile.new()
    for _ = 1, 19 do Packing.add(p, Pricing.click()) end
    eq(p.bag.fries, 19)
    eq(Packing.add(p, 0.5), false); eq(p.bag.fries, 19.5)
    eq(Packing.add(p, 10), true); eq(p.bag.fries, 20)
    eq(Packing.add(p, 1), false); eq(p.bag.fries, 20)
    assert(Profile.validate(p))
end)

test("invalid additions cannot corrupt a bag", function()
    local p = Profile.new()
    for _, bad in ipairs({-1, 0, math.huge, 0/0, "5"}) do eq(Packing.add(p, bad), false) end
    eq(p.bag.fries, 0); assert(Profile.validate(p))
end)

test("empty and partial bags cannot be sold", function()
    for _, fries in ipairs({0, 1, 19, 19.99}) do
        local p = Profile.new(); p.bag.fries = fries
        eq(Packing.sell(p), false)
        eq(p.cash, 0); eq(p.sales, 0); eq(p.lifetimeCash, 0); eq(p.bag.fries, fries)
    end
end)

test("full bag credits cash once and clears for the next bag", function()
    local p = Profile.new(); Packing.add(p, 20)
    local ok, amount = Packing.sell(p)
    eq(ok, true); eq(amount, 10); eq(p.cash, 10); eq(p.sales, 1); eq(p.lifetimeCash, 10)
    eq(p.bag.fries, 0); eq(Packing.sell(p), false); eq(p.cash, 10)
    Packing.add(p, 20); eq(Packing.sell(p), true); eq(p.cash, 20); eq(p.sales, 2)
    assert(Profile.validate(p))
end)

test("legacy cash and fries remain usable while all old bonuses are ignored", function()
    local p = Profile.new()
    p.cash, p.sales, p.lifetimeCash = 123, 5, 123
    p.upgrades = {Click=20, Sales=20}; p.equipped = {Machine="ufo", Bag="briefcase"}
    p.tickets = 99; p.owned = {ufo=true}; p.discoveries = {golden=true}
    p.bag = {fries=20, value=999, perfect=true, foldAttempted=true, variant="golden"}
    assert(Profile.validate(p))
    local ok, amount = Packing.sell(p)
    eq(ok, true); eq(amount, 10); eq(p.cash, 133); eq(p.bag.fries, 0)
    eq(p.tickets, 99); eq(p.bag.perfect, nil)
end)

test("cash and counters stay within the configured bound", function()
    local p = Profile.new()
    p.cash, p.lifetimeCash, p.sales = Economy.MaxCurrency - 1, Economy.MaxCurrency - 1, Economy.MaxCurrency
    Packing.add(p, 20); Packing.sell(p)
    eq(p.cash, Economy.MaxCurrency); eq(p.lifetimeCash, Economy.MaxCurrency); eq(p.sales, Economy.MaxCurrency)
    assert(Profile.validate(p))
end)

test("rate limiter blocks bursts and cleans disconnected players", function()
    local limit = RateLimiter.new(4, 1)
    eq(limit:allow("a", 0), true); eq(limit:allow("a", 0), false)
    eq(limit:allow("a", 0.24), false); eq(limit:allow("a", 0.25), true)
    eq(limit:allow("b", 0), true)
    limit:remove("a"); eq(limit.buckets.a, nil)
end)

test("10000 core actions preserve valid profiles and exact cash totals", function()
    local p = Profile.new()
    local sales = 0
    for n = 1, 10000 do
        if n % 7 == 0 then
            local ok = Packing.sell(p)
            if ok then sales += 1 end
        else Packing.add(p, if n % 2 == 0 then Pricing.click() else Pricing.automatic() * 0.2) end
        assert(Profile.validate(p))
        eq(p.cash, sales * Economy.BaseSale); eq(p.sales, sales)
    end
    assert(sales > 0)
end)
