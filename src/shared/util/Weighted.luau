-- nextUnit() must return a number in [0, 1). RNG is supplied by the server.
return function(entries, nextUnit)
    local total = 0
    for _, entry in ipairs(entries) do
        assert(entry.weight > 0, "Weights must be positive")
        total += entry.weight
    end
    assert(total > 0, "Empty weighted pool")
    local unit = nextUnit()
    assert(type(unit) == "number" and unit >= 0 and unit < 1, "Invalid RNG sample")
    local target = unit * total
    local cumulative = 0
    for _, entry in ipairs(entries) do
        cumulative += entry.weight
        if target < cumulative then return entry end
    end
    return entries[#entries]
end
