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
-- Numbers from tools/simulate.py. Every machine's pets are 4x the machine before, slot for slot.
local Types = {
    -- Fry Stand (StarterFryer): stats x1 the Starter pet in the same slot
    CrinkleFry = pet("Crinkle Fry", "Common", 4, 1, 10),
    SaltShaker = pet("Salt Shaker", "Common", 2, 2, 10),
    PaperCup = pet("Paper Cup", "Common", 2, 1, 20),
    PotatoPup = pet("Potato Pup", "Uncommon", 6, 1.50, 15),
    KetchupPacket = pet("Ketchup Packet", "Uncommon", 3, 3, 15),
    MayoJar = pet("Mayo Jar", "Rare", 4, 4, 20),
    FryerBot = pet("Fryer Bot", "Epic", 6, 3, 60),
    FryKing = pet("Fry King", "Legendary", 12, 6, 60),
    -- Fry Diner (DeluxeFryer): stats x4 the Starter pet in the same slot
    OnionRing = pet("Onion Ring", "Common", 16, 4, 40),
    PickleChip = pet("Pickle Chip", "Common", 8, 8, 40),
    NapkinGhost = pet("Napkin Ghost", "Common", 8, 4, 80),
    HashBrownHamster = pet("Hash Brown Hamster", "Uncommon", 24, 6, 60),
    Milkshake = pet("Milkshake", "Uncommon", 12, 12, 60),
    CurlyFryCat = pet("Curly Fry Cat", "Rare", 16, 16, 80),
    CheeseSlime = pet("Cheese Sauce Slime", "Epic", 24, 12, 240),
    FryPhoenix = pet("Fry Phoenix", "Legendary", 48, 24, 240),
    -- Drive-In (DriveInGrill): stats x16 the Starter pet in the same slot
    SesameBun = pet("Sesame Bun", "Common", 64, 16, 160),
    MustardBottle = pet("Mustard Bottle", "Common", 32, 32, 160),
    PaperTray = pet("Paper Tray", "Common", 32, 16, 320),
    BurgerBear = pet("Burger Bear", "Uncommon", 96, 24, 240),
    SodaSeal = pet("Soda Seal", "Uncommon", 48, 48, 240),
    HotDogPup = pet("Hot Dog Pup", "Rare", 64, 64, 320),
    CarhopBot = pet("Carhop Bot", "Epic", 96, 48, 960),
    BurgerDragon = pet("Burger Dragon", "Legendary", 192, 96, 960),
    -- Fish & Chips Pier (PierFryer): stats x64 the Starter pet in the same slot
    FishStick = pet("Fish Stick", "Common", 256, 64, 640),
    TartarTub = pet("Tartar Tub", "Common", 128, 128, 640),
    NewspaperCone = pet("Newspaper Cone", "Common", 128, 64, 1280),
    ChipCrab = pet("Chip Crab", "Uncommon", 384, 96, 960),
    VinegarOwl = pet("Vinegar Owl", "Uncommon", 192, 192, 960),
    SeagullThief = pet("Seagull Thief", "Rare", 256, 256, 1280),
    BatterOctopus = pet("Battered Octopus", "Epic", 384, 192, 3840),
    FryKraken = pet("Fry Kraken", "Legendary", 768, 384, 3840),
    -- Cosmic Diner (CosmicFryer): stats x256 the Starter pet in the same slot
    MoonFry = pet("Moon Fry", "Common", 1024, 256, 2560),
    StarSalt = pet("Star Salt", "Common", 512, 512, 2560),
    AstroCup = pet("Astro Cup", "Common", 512, 256, 5120),
    AlienTot = pet("Alien Tot", "Uncommon", 1536, 384, 3840),
    CometCola = pet("Comet Cola", "Uncommon", 768, 768, 3840),
    SaucerBurger = pet("Saucer Burger", "Rare", 1024, 1024, 5120),
    RoboChef = pet("Robo Chef", "Epic", 1536, 768, 15360),
    GalaxyFry = pet("Galaxy Fry Lord", "Legendary", 3072, 1536, 15360),
    -- Fry Palace (RoyalFryer): stats x1024 the Starter pet in the same slot
    TruffleFry = pet("Truffle Fry", "Common", 4096, 1024, 10240),
    PepperKnight = pet("Pepper Knight", "Common", 2048, 2048, 10240),
    VelvetBox = pet("Velvet Box", "Common", 2048, 1024, 20480),
    ButlerSpud = pet("Butler Spud", "Uncommon", 6144, 1536, 15360),
    CrownKetchup = pet("Crown Ketchup", "Uncommon", 3072, 3072, 15360),
    DiamondDip = pet("Diamond Dip", "Rare", 4096, 4096, 20480),
    FryUnicorn = pet("Fry Unicorn", "Epic", 6144, 3072, 61440),
    FryEmperor = pet("Fry Emperor", "Legendary", 12288, 6144, 61440),
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
