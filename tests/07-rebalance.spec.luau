-- Rebalance (20 October 2026): flat three-stat pets, percentage upgrades, short numbers, no cap.
local Profile = loadModule("shared/domain/Profile")
local Pricing = loadModule("shared/domain/Pricing")
local Packing = loadModule("shared/domain/Packing")
local Pets = loadModule("shared/domain/Pets")
local PetConfig = loadModule("shared/config/Pets")
local Machines = loadModule("shared/config/Machines")
local Economy = loadModule("shared/config/Economy")
local Format = loadModule("shared/util/Format")

test("short numbers use K M B T and longer suffixes then scientific notation", function()
    local cases = {
        { 0, "0" }, { 7, "7" }, { 950, "950" }, { 999, "999" }, { 1000, "1K" }, { 1250, "1.25K" }, { 12500, "12.5K" },
        { 125000, "125K" }, { 999499, "999K" }, { 999949, "1M" }, { 999999, "1M" }, { 1234567, "1.23M" }, { 1.25e9, "1.25B" }, { 2e12, "2T" },
        { 3.4e15, "3.4Qa" }, { 1e18, "1Qi" }, { 1e21, "1Sx" }, { 1e24, "1Sp" }, { 1e27, "1Oc" }, { 1e30, "1No" },
        { 1e33, "1Dc" }, { 1.2e36, "1.2e36" }, { 5e120, "5e120" }, { -1500, "-1.5K" }, { 2.5, "2.5" }, { 2.25, "2.25" },
    }
    for _, case in ipairs(cases) do eq(Format.short(case[1]), case[2]) end
    eq(Format.short(0/0), "0"); eq(Format.short(math.huge), "MAX"); eq(Format.short("12"), "0")
    eq(Format.money(40), "$40"); eq(Format.money(1.5), "$1.50"); eq(Format.money(0.05), "$0.05")
    eq(Format.money(250000), "$250K"); eq(Format.money(5000000), "$5M")
end)

test("Cash has no practical cap but can never become infinity", function()
    eq(Economy.MaxCurrency, 1e300)
    local p = Profile.new(); p.cash = 5e12; p.lifetimeCash = 5e12
    Packing.add(p, 40); eq(Packing.sell(p), true)
    eq(p.cash, 5e12 + 40); assert(Profile.validate(p)) -- past the old $1 trillion cap
    p.cash = 1e200; assert(Profile.validate(p))
    p.cash = 1e300; Pricing.credit(p, "cash", 1e300); eq(p.cash, 1e300); assert(p.cash < math.huge)
    p.cash = math.huge; eq(Profile.validate(p), false)
end)

test("every pet adds all three stats and each machine has six to eight pets", function()
    for petType, kind in pairs(PetConfig.Types) do
        for _, stat in ipairs(PetConfig.StatOrder) do
            local value = kind.Stats[stat]
            assert(type(value) == "number" and value > 0, petType .. " " .. stat)
        end
        eq(kind.Bonuses, nil) -- percentage bonuses are gone
    end
    for id, machine in pairs(Machines.Machines) do
        assert(#machine.Pool >= 6 and #machine.Pool <= 8, id)
        local commons = 0
        for _, petType in ipairs(machine.Pool) do if PetConfig.Types[petType].Rarity == "Common" then commons += 1 end end
        eq(commons, 3) -- one Common for each lean
    end
    -- Moved to the Deluxe Fryer: still valid pet types so saves keep them, but not in the Starter pool.
    local pool = Machines.Machines.StarterFryer.Pool
    for _, moved in ipairs({ "NapkinGhost", "CurlyFryCat" }) do
        assert(PetConfig.Types[moved]); eq(table.find(pool, moved), nil)
    end
    local p = Profile.new(); Pets.add(p, "NapkinGhost", "StarterFryer"); assert(Profile.validate(p))
end)

test("Starter pets lean towards one stat and rarer pets are stronger", function()
    local s = function(t) return PetConfig.Types[t].Stats end
    -- Each Common is best at its own stat.
    assert(s("CrinkleFry").FriesPerClick > s("SaltShaker").FriesPerClick and s("CrinkleFry").FriesPerClick > s("PaperCup").FriesPerClick)
    assert(s("SaltShaker").MoneyPerFry > s("CrinkleFry").MoneyPerFry and s("SaltShaker").MoneyPerFry > s("PaperCup").MoneyPerFry)
    assert(s("PaperCup").BagCapacity > s("CrinkleFry").BagCapacity and s("PaperCup").BagCapacity > s("SaltShaker").BagCapacity)
    -- A fresh player's sale value rises with rarity.
    local function sale(t) local p = Profile.new(); Pets.add(p, t, "StarterFryer"); Pets.equip(p, "P1"); return Pricing.sale(p) end
    local order = { "CrinkleFry", "KetchupPacket", "MayoJar", "FryerBot", "FryKing" }
    for i = 2, #order do assert(sale(order[i]) > sale(order[i - 1]), order[i]) end
    eq(sale("FryKing"), 700) -- (40 + 60) bag x ($1 + $6) per fry
end)
