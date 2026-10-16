-- Gem upgrade tracks, in shop order. Cost in gems = round(BaseCost x Growth ^ level).
-- Each level adds Step to the track's base value in Economy. There are no level caps;
-- MaxLevel only bounds saved data, far beyond any affordable level.
local Tracks = {
    FriesPerClick = table.freeze({ Name = "Fries per click", BaseCost = 3, Growth = 1.25, Step = 1 }),
    MoneyPerFry = table.freeze({ Name = "Money per fry", BaseCost = 4, Growth = 1.25, Step = 5 }), -- cents
    BagCapacity = table.freeze({ Name = "Bag capacity", BaseCost = 5, Growth = 1.25, Step = 5 }),
}
return table.freeze({
    Order = table.freeze({ "FriesPerClick", "MoneyPerFry", "BagCapacity" }),
    Tracks = table.freeze(Tracks),
    MaxLevel = 10000,
})
