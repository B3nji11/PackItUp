-- RGB arrays keep catalogue data usable in both Roblox and offline tests.
return {
    Categories = { "Machine", "Bag" },
    Rarities = {
        { id = "Common", weight = 60 },
        { id = "Rare", weight = 30 },
        { id = "Epic", weight = 9 },
        { id = "Legendary", weight = 1 },
    },
    GuaranteedRarities = {
        { id = "Epic", weight = 90 },
        { id = "Legendary", weight = 10 },
    },
    Starter = { Machine = "starter_fryer", Bag = "starter_bag" },
    Pools = {
        Machine = { Common = "countertop", Rare = "conveyor", Epic = "robot", Legendary = "ufo" },
        Bag = { Common = "paper", Rare = "striped", Epic = "neon", Legendary = "briefcase" },
    },
    Items = {
        starter_fryer = { name = "Training Fryer", category = "Machine", rarity = "Starter", power = 0.5, color = { 145, 151, 161 } },
        countertop = { name = "Countertop Fryer", category = "Machine", rarity = "Common", power = 1, color = { 198, 209, 224 } },
        conveyor = { name = "Conveyor Fryer", category = "Machine", rarity = "Rare", power = 2, color = { 72, 166, 245 } },
        robot = { name = "Robot Fry Chef", category = "Machine", rarity = "Epic", power = 3, color = { 173, 101, 244 } },
        ufo = { name = "UFO Fry Dispenser", category = "Machine", rarity = "Legendary", power = 5, color = { 255, 207, 73 } },
        starter_bag = { name = "Training Bag", category = "Bag", rarity = "Starter", power = 1, color = { 165, 130, 92 } },
        paper = { name = "Paper Takeaway Bag", category = "Bag", rarity = "Common", power = 1.1, color = { 205, 172, 115 } },
        striped = { name = "Striped Carton", category = "Bag", rarity = "Rare", power = 1.3, color = { 234, 104, 98 } },
        neon = { name = "Neon Takeaway Box", category = "Bag", rarity = "Epic", power = 1.6, color = { 108, 243, 211 } },
        briefcase = { name = "Golden Briefcase", category = "Bag", rarity = "Legendary", power = 2, color = { 255, 211, 79 } },
    },
}
