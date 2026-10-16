-- Rebirth: convert Cash into gems at a rising threshold. Pure rules: no Instances,
-- messages, or DataStores. Gems, upgrade levels, and the rebirth count are kept.
local Config = require(script.Parent.Parent.config.Rebirth)
local Economy = require(script.Parent.Parent.config.Economy)
local Profile = require(script.Parent.Profile)
local Rebirth = {}
function Rebirth.count(p) return if type(p.rebirths) == "number" then p.rebirths else 0 end
function Rebirth.threshold(p)
    return math.floor(Config.BaseThreshold * Config.Growth ^ Rebirth.count(p) + 0.5)
end
function Rebirth.reward(p) return Config.BaseGems + Config.GemsPerRebirth * Rebirth.count(p) end
function Rebirth.ready(p) return p.cash >= Rebirth.threshold(p) end
-- One non-yielding step: reset Cash and the bag, add gems, count the rebirth.
function Rebirth.perform(p)
    local threshold = Rebirth.threshold(p)
    if p.cash < threshold then return false, "Reach the rebirth threshold first." end
    local gems = Rebirth.reward(p)
    p.cash = 0
    p.bag = Profile.emptyBag()
    p.gems = math.min(Economy.MaxCurrency, (p.gems or 0) + gems)
    p.rebirths = Rebirth.count(p) + 1
    return true, gems
end
function Rebirth.snapshot(p)
    return { count = Rebirth.count(p), threshold = Rebirth.threshold(p), reward = Rebirth.reward(p), ready = Rebirth.ready(p) }
end
return Rebirth
