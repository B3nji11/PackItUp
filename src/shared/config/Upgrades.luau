-- Gem upgrade tracks, in shop order. Cost in gems = round(BaseCost x Growth ^ level).
-- Each level adds Percent to the track's multiplier: stat = (base + pets) x (1 + Percent x level).
-- Levels add up (level 5 = +50%), they do not compound. There are no level caps;
-- MaxLevel only bounds saved data, far beyond any affordable level.
local Tracks = {
    FriesPerClick = table.freeze({ Name = "Fries per click", BaseCost = 3, Growth = 1.25, Percent = 0.10 }),
    MoneyPerFry = table.freeze({ Name = "Money per fry", BaseCost = 4, Growth = 1.25, Percent = 0.10 }),
    BagCapacity = table.freeze({ Name = "Bag capacity", BaseCost = 5, Growth = 1.25, Percent = 0.10 }),
}
return table.freeze({
    Order = table.freeze({ "FriesPerClick", "MoneyPerFry", "BagCapacity" }),
    Tracks = table.freeze(Tracks),
    MaxLevel = 10000,
})
