-- Shared pet display text and rarity colors.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local PetConfig = require(Shared.config.Pets)
local Format = require(Shared.util.Format)
local PetText = {}
-- Pets add flat amounts: fries per click, dollars per fry, and bag slots.
local function amount(bonus)
    if bonus.stat == "MoneyPerFry" then return "+" .. Format.money(bonus.amount) end
    return "+" .. Format.short(bonus.amount)
end
local Long = { FriesPerClick = " fries/click", MoneyPerFry = "/fry", BagCapacity = " bag" }
local Short = { FriesPerClick = " fries", MoneyPerFry = "/fry", BagCapacity = " bag" }
-- "+4 fries/click  ·  +$1/fry  ·  +10 bag"; `short` is one line per stat for pet tiles.
function PetText.bonus(bonuses, short)
    local names = if short then Short else Long
    local parts = {}
    for _, bonus in ipairs(bonuses) do table.insert(parts, amount(bonus) .. names[bonus.stat]) end
    return table.concat(parts, if short then "\n" else "  ·  ")
end
function PetText.color(rarity)
    local c = PetConfig.Rarities[rarity].Color
    return Color3.fromRGB(c[1], c[2], c[3])
end
return PetText
