-- Restaurant tiers (20 October 2026): six restaurants, one machine each, bought with Cash.
local Profile = loadModule("shared/domain/Profile")
local Restaurant = loadModule("shared/domain/Restaurant")
local Rebirth = loadModule("shared/domain/Rebirth")
local Gacha = loadModule("shared/domain/Gacha")
local Pets = loadModule("shared/domain/Pets")
local Restaurants = loadModule("shared/config/Restaurants")
local Machines = loadModule("shared/config/Machines")
local PetConfig = loadModule("shared/config/Pets")
local Store = loadModule("server/storage/ProfileStore")
local Copy = loadModule("shared/util/Copy")
local function zero() return 0 end

test("six restaurant tiers each add one machine with eight pets four times stronger than the last", function()
    eq(Restaurants.Max, 6); eq(#Restaurants.Tiers, 6); eq(#Machines.Order, 6)
    local expected = { { "Fry Stand", 0 }, { "Fry Diner", 5e6 }, { "Drive-In", 30e6 }, { "Fish & Chips Pier", 750e6 },
        { "Cosmic Diner", 10e9 }, { "Fry Palace", 350e9 } }
    local seen = {}
    for tier, info in ipairs(Restaurants.Tiers) do
        eq(info.Name, expected[tier][1]); eq(info.Price, expected[tier][2])
        local machine = Machines.Machines[info.Machine]
        assert(machine, info.Machine); eq(machine.Tier, tier); eq(Machines.Order[tier], info.Machine)
        eq(#machine.Pool, 8)
        assert(type(info.Tagline) == "string" and #info.Tagline > 0)
        for _, key in ipairs({ "Main", "Trim", "Glow", "Floor" }) do eq(#info.Theme[key], 3) end
        if tier > 1 then
            local previous = Machines.Machines[Restaurants.Tiers[tier - 1].Machine]
            assert(machine.Price > previous.Price and info.Price > Restaurants.Tiers[tier - 1].Price)
            for slot, petType in ipairs(machine.Pool) do
                local now, before = PetConfig.Types[petType], PetConfig.Types[previous.Pool[slot]]
                eq(now.Rarity, before.Rarity)
                for _, stat in ipairs(PetConfig.StatOrder) do near(now.Stats[stat], before.Stats[stat] * 4) end
            end
        end
        for _, petType in ipairs(machine.Pool) do
            assert(not seen[petType], petType .. " is in two machines"); seen[petType] = true
        end
    end
    local count = 0
    for petType in pairs(PetConfig.Types) do count += 1; assert(seen[petType], petType .. " is in no machine") end
    eq(count, 48)
end)

test("expanding costs the next tier's Cash, goes one tier at a time, and stops at the top", function()
    local p = Profile.new(); eq(Restaurant.tier(p), 1); eq(Restaurant.bestMachine(p), "StarterFryer")
    p.restaurantTier = nil; eq(Restaurant.tier(p), 1) -- older saves
    p.cash = 4999999
    local ok, message = Restaurant.expand(p)
    eq(ok, false); eq(message, "Not enough Cash to expand."); eq(p.cash, 4999999); eq(Restaurant.tier(p), 1)
    p.cash = 6e6
    local info
    ok, info = Restaurant.expand(p)
    eq(ok, true); eq(info.Name, "Fry Diner"); eq(p.cash, 1e6); eq(p.restaurantTier, 2); eq(Restaurant.bestMachine(p), "DeluxeFryer")
    eq(Restaurant.expand(p), false); eq(p.restaurantTier, 2) -- the Drive-In costs $30M
    for tier = 3, 6 do
        p.cash = Restaurants.Tiers[tier].Price
        eq(Restaurant.expand(p), true); eq(Restaurant.tier(p), tier); eq(p.cash, 0)
    end
    p.cash = 1e300
    ok, message = Restaurant.expand(p)
    eq(ok, false); eq(message, "Your restaurant is fully upgraded."); eq(p.cash, 1e300); eq(Restaurant.tier(p), 6)
    eq(Restaurant.nextTier(p), nil); eq(Restaurant.snapshot(p).nextTier, nil); eq(Restaurant.snapshot(p).name, "Fry Palace")
    assert(Profile.validate(p))
end)

test("locked machines cannot spin and charge nothing until the restaurant reaches their tier", function()
    local p = Profile.new(); p.cash = 1e7
    local ok, message = Gacha.spin(p, "DeluxeFryer", zero)
    eq(ok, false); eq(message, "Expand your restaurant to unlock this machine."); eq(p.cash, 1e7); eq(#p.pets, 0)
    eq(Gacha.snapshot(p, "DeluxeFryer").unlocked, false); eq(Gacha.snapshot(p, "StarterFryer").unlocked, true)
    eq(Restaurant.expand(p), true)
    local pet
    ok, pet = Gacha.spin(p, "DeluxeFryer", zero)
    eq(ok, true); eq(pet.type, "OnionRing"); eq(pet.machine, "DeluxeFryer"); eq(p.cash, 5e6 - 150000)
    eq(Gacha.pity(p, "DeluxeFryer"), 1); eq(Gacha.pity(p, "StarterFryer"), 0) -- pity is per machine
    -- Older machines keep working.
    ok, pet = Gacha.spin(p, "StarterFryer", zero); eq(ok, true); eq(pet.type, "CrinkleFry")
    eq(Gacha.spin(p, "RoyalFryer", zero), false)
    local snap = Restaurant.snapshot(p)
    eq(snap.tier, 2); eq(snap.nextTier.name, "Drive-In"); eq(snap.nextTier.machineName, "Drive-In Grill")
    eq(snap.nextTier.legendary, "BurgerDragon"); eq(snap.nextTier.affordable, false); eq(snap.nextTier.spinPrice, 1.5e6)
end)

test("rebirth keeps the restaurant tier and tiers are validated and saved", function()
    local p = Profile.new(); p.restaurantTier = 3; p.cash = 250000
    eq(Rebirth.perform(p), true); eq(p.cash, 0); eq(Restaurant.tier(p), 3)
    for _, bad in ipairs({ 0, 7, 1.5, "2", -1, 0/0, math.huge }) do
        local q = Profile.new(); q.restaurantTier = bad; eq(Profile.validate(q), false)
    end
    local q = Profile.new(); q.restaurantTier = nil; assert(Profile.validate(q))
    local db = { records = {} }
    function db:UpdateAsync(key, fn)
        local result = fn(Copy(self.records[key]))
        if result ~= nil then self.records[key] = Copy(result) end
        return Copy(result)
    end
    local store = Store.new(db, { validate = Profile.validate, copy = Copy, newProfile = Profile.new,
        now = function() return 100 end, wait = function() end, attempts = 3, leaseSeconds = 180 })
    local saved = store:load("1", "A"); eq(Restaurant.tier(saved), 1)
    saved.cash = 5e6; eq(Restaurant.expand(saved), true)
    Pets.add(saved, "FryPhoenix", "DeluxeFryer")
    eq(store:save("1", "A", saved, true), true)
    local restored = store:load("1", "B")
    eq(Restaurant.tier(restored), 2); eq(restored.pets[1].type, "FryPhoenix"); eq(restored.pets[1].machine, "DeluxeFryer")
end)

test("the world shows every stand, unlocks them by tier, themes the plot, and resets on release", function()
    local StationBuilder = loadModule("server/world/StationBuilder")
    local TierBuilder = loadModule("server/world/TierBuilder")
    local folder = Instance.new("Folder")
    local station = StationBuilder(folder, 9, Vector3.new(0, 0, 0), 0)
    local stands = station.model.MachineStands
    local function unlocked()
        local n = 0
        for _, id in ipairs(Machines.Order) do if stands[id]:GetAttribute("Unlocked") then n += 1 end end
        return n
    end
    eq(#stands:GetChildren(), 6); eq(unlocked(), 1); eq(station.model:FindFirstChild("TierDecor"), nil)
    local roof = station.model.RoofCap
    local original = roof.Color
    eq(station.kiosk.label.Text, "EXPAND\nFRY DINER  $5M")
    for tier = 2, 6 do
        TierBuilder.apply(station, tier, "Ann")
        eq(unlocked(), tier); eq(station.model:GetAttribute("RestaurantTier"), tier)
        local decor = station.model.TierDecor
        assert(#decor:GetChildren() >= 8, "tier " .. tier .. " decoration")
        local theme = Restaurants.Tiers[tier].Theme.Main
        eq(roof.Color.R, theme[1] / 255)
        assert(string.find(station.sign.Text, string.upper(Restaurants.Tiers[tier].Name), 1, true))
        for _, part in ipairs(decor:GetChildren()) do
            if part.ClassName == "Part" then eq(part.Anchored, true); eq(part.CanTouch, false) end
        end
    end
    eq(station.kiosk.label.Text, "FULLY\nUPGRADED")
    -- Pads sit in front of each stand inside the plot, apart from each other and the entrance path.
    for _, stand in ipairs(station.standOrder) do
        local front = stand.front
        assert(math.abs(front.X) <= 24 and front.Z <= 26 and math.abs(front.X) >= 6, stand.id)
    end
    TierBuilder.apply(station, 1)
    eq(unlocked(), 1); eq(station.model:FindFirstChild("TierDecor"), nil); eq(roof.Color, original)
end)
