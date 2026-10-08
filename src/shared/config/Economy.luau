-- Balance for the core filling-and-selling loop.
return table.freeze({
    Capacity = 20,
    -- Money per fry, in cents. A bag sells for Capacity x this value ($0.50 x 20 = $10).
    MoneyPerFryCents = 50,
    BaseClick = 1,
    BasicFryerPerSecond = 0.5,
    ClicksPerSecond = 4,
    MaxCurrency = 1e12,
})
