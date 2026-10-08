local Economy = require(script.Parent.Parent.config.Economy)
local Profile = {}
function Profile.emptyBag() return { fries = 0 } end
function Profile.new()
    return { version = 1, cash = 0, sales = 0, lifetimeCash = 0, bag = Profile.emptyBag() }
end
local function numberIn(value, low, high, integer)
    return type(value) == "number" and value == value and value >= low and value <= high
        and (not integer or value % 1 == 0)
end
-- Keep the v1 core fields compatible with existing saves. Extra fields from the
-- earlier prototype remain in storage, but are neither used nor sent to clients.
function Profile.validate(p)
    if type(p) ~= "table" or p.version ~= 1 then return false end
    for _, key in ipairs({ "cash", "sales", "lifetimeCash" }) do
        if not numberIn(p[key], 0, Economy.MaxCurrency, true) then return false end
    end
    return type(p.bag) == "table" and numberIn(p.bag.fries, 0, Economy.Capacity, false)
end
return Profile
