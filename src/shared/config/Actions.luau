-- Only these actions are accepted. "none" takes no client argument; the others take exactly
-- one name or ID, which the server validates: an upgrade track, a machine, a pet ID, a pet
-- type, a bulk rarity (Common, Uncommon, Rare), or a setting name.
return table.freeze({ Pack = "none", Sell = "none", Return = "none", Sync = "none", Rebirth = "none",
    Expand = "none", VisitMachine = "none",
    Upgrade = "upgrade", Spin = "machine", Equip = "pet", Unequip = "pet", DeletePet = "pet",
    MergePets = "petType", DeleteRarity = "bulkRarity", ToggleAutoDelete = "bulkRarity", ToggleSetting = "setting" })
