-- Fry Buddies (placeholder names). Each bonus is a fraction added to one stat:
-- effective value = (base + upgrade levels) x (1 + total equipped bonus for that stat).
local Rarities = {
    -- Colours are dark enough to read on cream and white (Diner Sticker style).
    Common = table.freeze({ Rank = 1, Name = "Common", Color = { 128, 108, 88 } }),
    Uncommon = table.freeze({ Rank = 2, Name = "Uncommon", Color = { 31, 138, 126 } }),
    Rare = table.freeze({ Rank = 3, Name = "Rare", Color = { 29, 111, 216 } }),
    Epic = table.freeze({ Rank = 4, Name = "Epic", Color = { 123, 44, 191 } }),
    Legendary = table.freeze({ Rank = 5, Name = "Legendary", Color = { 176, 118, 0 } }),
}
local function pet(name, rarity, bonuses)
    return table.freeze({ Name = name, Rarity = rarity, Bonuses = table.freeze(bonuses) })
end
local Types = {
    CrinkleFry = pet("Crinkle Fry", "Common", { FriesPerClick = 0.05 }),
    SaltShaker = pet("Salt Shaker", "Common", { MoneyPerFry = 0.05 }),
    PaperCup = pet("Paper Cup", "Common", { BagCapacity = 0.05 }),
    PotatoPup = pet("Potato Pup", "Uncommon", { FriesPerClick = 0.10 }),
    KetchupPacket = pet("Ketchup Packet", "Uncommon", { MoneyPerFry = 0.10 }),
    NapkinGhost = pet("Napkin Ghost", "Uncommon", { BagCapacity = 0.10 }),
    CurlyFryCat = pet("Curly Fry Cat", "Rare", { FriesPerClick = 0.20 }),
    MayoJar = pet("Mayo Jar", "Rare", { MoneyPerFry = 0.20 }),
    FryerBot = pet("Fryer Bot", "Epic", { BagCapacity = 0.40 }),
    FryKing = pet("Fry King", "Legendary", { FriesPerClick = 0.50, MoneyPerFry = 0.50 }),
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
