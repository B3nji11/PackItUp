local Economy = require(script.Parent.Parent.config.Economy)
local Folding = {}
function Folding.start(p, runtime, now)
    if p.bag.fries < Economy.Capacity then return false, "Fill your bag first." end
    if p.bag.foldAttempted then return false, "One folding attempt per bag." end
    p.bag.foldAttempted = true
    runtime.foldStart = now + Economy.FoldLeadTime
    return true, "Stop the marker inside the green zone!"
end
function Folding.finish(p, runtime, now)
    if not runtime.foldStart or p.bag.fries < Economy.Capacity then return false, "No active folding attempt." end
    local fraction = (now - runtime.foldStart) / Economy.FoldDuration
    runtime.foldStart = nil
    p.bag.perfect = fraction >= Economy.FoldWindowMin and fraction <= Economy.FoldWindowMax
    return true, if p.bag.perfect then "Perfect fold! +25% sale value." else "Regular fold. Your bag is still ready to sell."
end
return Folding
