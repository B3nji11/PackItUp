-- Rebirth balance. Threshold = BaseThreshold x Growth ^ rebirths (rounded, in Cash).
-- Gems = BaseGems + GemsPerRebirth x rebirths. Rebirth resets Cash and the current bag only.
return table.freeze({
    BaseThreshold = 250000,
    Growth = 2.0,
    BaseGems = 10,
    GemsPerRebirth = 5,
})
