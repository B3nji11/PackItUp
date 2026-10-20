-- Base balance for the core filling-and-selling loop, before upgrades.
return table.freeze({
    BaseCapacity = 40,
    -- Money per fry, in cents. A bag sells for capacity x this value ($1.00 x 40 = $40).
    MoneyPerFryCents = 100,
    BaseClick = 2,
    BasicFryerPerSecond = 0.5,
    ClicksPerSecond = 4,
    -- No practical cap (owner, 20 October 2026). This safety limit only stops a number ever
    -- becoming infinity, which would corrupt a save; no player can reach it.
    MaxCurrency = 1e300,
})
