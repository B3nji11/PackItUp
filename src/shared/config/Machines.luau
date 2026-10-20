-- Gacha machines are data: a fixed Cash price, rarity odds, a pet pool, and pity.
-- Pets in the same rarity share that rarity's chance equally. New machines are added here.
local Machines = {
    StarterFryer = table.freeze({
        Name = "Starter Fryer",
        Price = 150,
        Odds = table.freeze({ Common = 0.60, Uncommon = 0.25, Rare = 0.10, Epic = 0.04, Legendary = 0.01 }),
        Pool = table.freeze({ "CrinkleFry", "SaltShaker", "PaperCup", "PotatoPup", "KetchupPacket", "MayoJar",
            "FryerBot", "FryKing" }),
        -- The PityEvery-th spin in a row without PityRarity or better is guaranteed PityRarity or better.
        PityEvery = 50,
        PityRarity = "Epic",
    }),
}
return table.freeze({ Order = table.freeze({ "StarterFryer" }), Machines = table.freeze(Machines) })
