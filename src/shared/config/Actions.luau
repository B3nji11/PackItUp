-- A closed action vocabulary prevents arbitrary remote names from allocating state.
return table.freeze({
    Pack = false, Sell = false, StartFold = false, FinishFold = false,
    Sync = false, Return = false,
    Upgrade = true, Equip = true, Roll = true,
})
