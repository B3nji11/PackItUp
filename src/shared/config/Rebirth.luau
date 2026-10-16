-- Rebirth balance. Threshold = BaseThreshold x Growth ^ rebirths (rounded, in Cash).
-- Gems = BaseGems + GemsPerRebirth x rebirths. Rebirth resets Cash and the current bag only.
return table.freeze({
    BaseThreshold = 1000,
    Growth = 1.6,
    BaseGems = 10,
    GemsPerRebirth = 5,
})
