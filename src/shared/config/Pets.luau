-- Fry Buddies (placeholder names). Every pet adds all three stats as flat amounts, with a lean
-- (click, money, or bag): effective stat = (base + equipped pets) x (1 + upgrade percent).
-- MoneyPerFry is in dollars. Golden pets give GoldenMultiplier x these stats.
local Rarities = {
    -- Colours are dark enough to read on cream and white (Diner Sticker style).
    Common = table.freeze({ Rank = 1, Name = "Common", Color = { 128, 108, 88 } }),
    Uncommon = table.freeze({ Rank = 2, Name = "Uncommon", Color = { 31, 138, 126 } }),
    Rare = table.freeze({ Rank = 3, Name = "Rare", Color = { 29, 111, 216 } }),
    Epic = table.freeze({ Rank = 4, Name = "Epic", Color = { 123, 44, 191 } }),
    Legendary = table.freeze({ Rank = 5, Name = "Legendary", Color = { 176, 118, 0 } }),
}
local function pet(name, rarity, click, money, bag)
    return table.freeze({ Name = name, Rarity = rarity,
        Stats = table.freeze({ FriesPerClick = click, MoneyPerFry = money, BagCapacity = bag }) })
end
-- Numbers from tools/simulate.py (agreed 20 October 2026).
local Types = {
    -- Starter Fryer
    CrinkleFry = pet("Crinkle Fry", "Common", 4, 1.00, 10),
    SaltShaker = pet("Salt Shaker", "Common", 2, 2.00, 10),
    PaperCup = pet("Paper Cup", "Common", 2, 1.00, 20),
    PotatoPup = pet("Potato Pup", "Uncommon", 6, 1.50, 15),
    KetchupPacket = pet("Ketchup Packet", "Uncommon", 3, 3.00, 15),
    MayoJar = pet("Mayo Jar", "Rare", 4, 4.00, 20),
    FryerBot = pet("Fryer Bot", "Epic", 6, 3.00, 60),
    FryKing = pet("Fry King", "Legendary", 12, 6.00, 60),
    -- Deluxe Fryer (restaurant tier 2, not built yet). Kept here so existing saves stay valid.
    NapkinGhost = pet("Napkin Ghost", "Common", 8, 4.00, 80),
    CurlyFryCat = pet("Curly Fry Cat", "Rare", 16, 16.00, 80),
}
return table.freeze({
    RarityOrder = table.freeze({ "Common", "Uncommon", "Rare", "Epic", "Legendary" }),
    Rarities = table.freeze(Rarities),
    Types = table.freeze(Types),
    StatOrder = table.freeze({ "FriesPerClick", "MoneyPerFry", "BagCapacity" }),
    MaxPets = 50,
    EquipSlots = 3,
    -- MergeCount unequipped copies of one pet merge into one Golden pet with GoldenMultiplier x bonus.
    MergeCount = 5,
    GoldenMultiplier = 2,
    -- Rarities that can be bulk deleted or auto-deleted. Epic and Legendary are protected.
    BulkRarities = table.freeze({ "Common", "Uncommon", "Rare" }),
})
