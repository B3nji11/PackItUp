-- Only these core actions are accepted; none takes a client argument.
return table.freeze({ Pack = true, Sell = true, Return = true, Sync = true })
