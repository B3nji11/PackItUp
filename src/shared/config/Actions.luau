-- Only these actions are accepted. "none" takes no client argument; the others take exactly
-- one name or ID, which the server validates: an upgrade track, a machine, or an owned pet ID.
return table.freeze({ Pack = "none", Sell = "none", Return = "none", Sync = "none", Rebirth = "none",
    Upgrade = "upgrade", Spin = "machine", Equip = "pet", Unequip = "pet", DeletePet = "pet" })
