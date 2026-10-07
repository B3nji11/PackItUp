local Config = require(script.Parent.Parent.config.Rush)
local LunchRush = {}
LunchRush.__index = LunchRush
function LunchRush.new(now)
    return setmetatable({ active = false, nextStart = now + Config.FirstDelay, endsAt = 0,
        participants = {}, contributions = {}, target = 0, count = 0, result = "Waiting for lunch rush" }, LunchRush)
end
function LunchRush:step(now, playerIds)
    if self.active and now >= self.endsAt then
        self.active = false
        local winners = {}
        local success = self.count >= self.target
        self.result = if success then "Lunch rush complete!" else "Rush ended. Keep your normal sales!"
        if success then
            for id in pairs(self.participants) do
                if (self.contributions[id] or 0) >= Config.MinimumContribution then table.insert(winners, id) end
            end
        end
        self.nextStart = now + Config.Interval
        return winners
    end
    if not self.active and now >= self.nextStart and #playerIds > 0 then
        self.active = true
        self.endsAt = now + Config.Duration
        self.participants, self.contributions = {}, {}
        for _, id in ipairs(playerIds) do self.participants[id] = true end
        self.target = #playerIds * Config.BagsPerPlayer
        self.count = 0
        self.result = "The school bus is here!"
    end
    return nil
end
function LunchRush:sale(id, now)
    if not self.active or now >= self.endsAt or not self.participants[id] then return end
    self.contributions[id] = (self.contributions[id] or 0) + 1
    self.count += 1
end
function LunchRush:snapshot(id)
    return { active = self.active, nextStart = self.nextStart, endsAt = self.endsAt,
        count = self.count, target = self.target, contribution = self.contributions[id] or 0,
        eligible = self.participants[id] == true, result = self.result }
end
return LunchRush
