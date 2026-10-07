local Economy = require(script.Parent.Parent.config.Economy)
local Pricing = require(script.Parent.Pricing)
return function(p)
    p.orderProgress += Economy.Capacity
    local completed = math.floor(p.orderProgress / Economy.OrderFries)
    p.orderProgress %= Economy.OrderFries
    local reward = completed * Economy.OrderReward
    if not p.tutorialClaimed and p.sales >= Economy.TutorialSales then
        p.tutorialClaimed = true
        reward += Economy.TutorialTickets
    end
    Pricing.credit(p, "tickets", reward)
    return reward
end
