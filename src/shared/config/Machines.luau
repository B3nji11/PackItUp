-- Gacha machines are data: a fixed Cash price, rarity odds, a pet pool, and pity. Each
-- machine belongs to a restaurant tier (config/Restaurants) and needs that tier to spin.
-- Pets in the same rarity share that rarity's chance equally. Prices from tools/simulate.py.
local Odds = table.freeze({ Common = 0.60, Uncommon = 0.25, Rare = 0.10, Epic = 0.04, Legendary = 0.01 })
local function machine(name, tier, price, accent, pool)
    return table.freeze({ Name = name, Tier = tier, Price = price, Odds = Odds, Pool = table.freeze(pool),
        -- The PityEvery-th spin in a row without PityRarity or better is guaranteed PityRarity or better.
        PityEvery = 50, PityRarity = "Epic",
        -- Theme colour name (client Theme) for the panel header and stand.
        Accent = accent })
end
local Machines = {
    StarterFryer = machine("Starter Fryer", 1, 150, "Green", { "CrinkleFry", "SaltShaker", "PaperCup", "PotatoPup", "KetchupPacket", "MayoJar", "FryerBot", "FryKing" }),
    DeluxeFryer = machine("Deluxe Fryer", 2, 150000, "Red", { "OnionRing", "PickleChip", "NapkinGhost", "HashBrownHamster", "Milkshake", "CurlyFryCat", "CheeseSlime", "FryPhoenix" }),
    DriveInGrill = machine("Drive-In Grill", 3, 1500000, "Orange", { "SesameBun", "MustardBottle", "PaperTray", "BurgerBear", "SodaSeal", "HotDogPup", "CarhopBot", "BurgerDragon" }),
    PierFryer = machine("Pier Fryer", 4, 25000000, "Blue", { "FishStick", "TartarTub", "NewspaperCone", "ChipCrab", "VinegarOwl", "SeagullThief", "BatterOctopus", "FryKraken" }),
    CosmicFryer = machine("Cosmic Fryer", 5, 200000000, "Gem", { "MoonFry", "StarSalt", "AstroCup", "AlienTot", "CometCola", "SaucerBurger", "RoboChef", "GalaxyFry" }),
    RoyalFryer = machine("Royal Fryer", 6, 4000000000, "Gold", { "TruffleFry", "PepperKnight", "VelvetBox", "ButlerSpud", "CrownKetchup", "DiamondDip", "FryUnicorn", "FryEmperor" }),
}
return table.freeze({ Order = table.freeze({ "StarterFryer", "DeluxeFryer", "DriveInGrill", "PierFryer", "CosmicFryer", "RoyalFryer" }), Machines = table.freeze(Machines) })
