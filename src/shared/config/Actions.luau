-- Only these actions are accepted. "none" takes no client argument; "upgrade" takes
-- exactly one upgrade track name, which the server validates.
return table.freeze({ Pack = "none", Sell = "none", Return = "none", Sync = "none", Upgrade = "upgrade" })
