-- Shared pet display text and rarity colors.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local PetConfig = require(Shared.config.Pets)
local PetText = {}
local StatNames = { FriesPerClick = "fries per click", MoneyPerFry = "money per fry", BagCapacity = "bag capacity" }
local ShortNames = { FriesPerClick = "fries/click", MoneyPerFry = "money/fry", BagCapacity = "bag size" }
-- `short` uses compact stat names for narrow rows.
function PetText.bonus(bonuses, short)
    local names = if short then ShortNames else StatNames
    local parts = {}
    for _, bonus in ipairs(bonuses) do
        table.insert(parts, "+" .. math.floor(bonus.amount * 100 + 0.5) .. "% " .. names[bonus.stat])
    end
    return table.concat(parts, ", ")
end
function PetText.color(rarity)
    local c = PetConfig.Rarities[rarity].Color
    return Color3.fromRGB(c[1], c[2], c[3])
end
return PetText
