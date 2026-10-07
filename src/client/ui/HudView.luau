local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Economy = require(Shared.config.Economy)
local RushConfig = require(Shared.config.Rush)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local HudView = {}
HudView.__index = HudView
function HudView.new(parent, send)
    local self = setmetatable({ frame = E.column(parent, "Play") }, HudView)
    self.status = E.label(self.frame, "Loading your restaurant...", 48)
    local _, fill = E.bar(self.frame, Theme.Gold)
    self.fill = fill
    self.pack = E.button(self.frame, "PACK FRIES  /  hold or tap", nil, Theme.Gold)
    self.sell = E.button(self.frame, "SERVE BAG", function() send("Sell") end, Theme.Green)
    self.fold = E.button(self.frame, "TRY A PERFECT FOLD  +25%", function()
        if self.state and self.state.foldStart then send("FinishFold") else send("StartFold") end
    end, Theme.Blue)
    local bar = E.bar(self.frame, Theme.Card, 22)
    local zone = Instance.new("Frame")
    zone.Position = UDim2.fromScale(Economy.FoldWindowMin, 0)
    zone.Size = UDim2.fromScale(Economy.FoldWindowMax - Economy.FoldWindowMin, 1)
    zone.BackgroundColor3, zone.BorderSizePixel, zone.Parent = Theme.Green, 0, bar
    local marker = Instance.new("Frame")
    marker.Size = UDim2.new(0, 4, 1, 6)
    marker.Position = UDim2.new(0, 0, 0, -3)
    marker.BackgroundColor3, marker.BorderSizePixel, marker.Parent = Theme.Text, 0, bar
    self.marker = marker
    self.order = E.label(self.frame, "", 50, Theme.Muted)
    self.rush = E.label(self.frame, "", 76, Theme.Green)
    E.button(self.frame, "RETURN TO MY COUNTER", function() send("Return") end, Theme.Muted)
    E.label(self.frame, "Keyboard: F pack | E serve | Q fold\nFirst 5 sales: +3 bonus Tickets. Deliveries are in the DELIVERY tab.", 65, Theme.Muted)
    return self
end
function HudView:update(state)
    self.state = state
    local p, bag = state.profile, state.profile.bag
    local full = bag.fries >= Economy.Capacity
    self.fill.Size = UDim2.fromScale(bag.fries / Economy.Capacity, 1)
    self.status.Text = if full then string.upper(bag.variant) .. " FRIES - READY!\nBase sale: $" .. bag.value
        else math.floor(bag.fries) .. " / " .. Economy.Capacity .. " fries  |  " .. state.stats.perClick .. "/click\n" .. state.stats.perSecond .. " automatic fries/sec"
    self.pack.Text = if not state.nearStation then "RETURN TO YOUR COUNTER" elseif full then "BAG FULL - SERVE IT!" else "PACK FRIES  /  hold or tap"
    self.sell.Text = if full then "SERVE BAG  +$" .. math.floor(bag.value * (if bag.perfect then Economy.PerfectMultiplier else 1) + 0.5) else "SERVE BAG  (fill it first)"
    self.fold.Text = if state.foldStart then "STOP IN THE GREEN ZONE!" elseif bag.perfect then "PERFECT FOLD  +25%"
        elseif bag.foldAttempted then "FOLD COMPLETE" else "TRY A PERFECT FOLD  +25%"
    self.order.Text = "REPEAT ORDER: " .. p.orderProgress .. " / " .. Economy.OrderFries .. " fries served\nReward: 1 Ticket  |  Lifetime bags: " .. p.sales
    self:animate(workspace:GetServerTimeNow())
end
function HudView:animate(now)
    local state = self.state
    if not state then return end
    local start = state.foldStart
    local fraction = if start then math.clamp((now - start) / Economy.FoldDuration, 0, 1) else 0
    self.marker.Position = UDim2.new(fraction, -2, 0, -3)
    local rush = state.rush
    if rush.active then
        self.rush.Text = "LUNCH RUSH  " .. rush.count .. "/" .. rush.target .. " bags  |  " .. math.max(0, math.ceil(rush.endsAt - now)) .. "s\n"
            .. (if rush.eligible then "Your contribution: " .. rush.contribution .. "/" .. RushConfig.MinimumContribution .. " minimum. Team success: +3 Tickets."
                else "You joined mid-rush. You can participate for rewards in the next one.")
    else
        self.rush.Text = rush.result .. "\nNext rush in " .. math.max(0, math.ceil(rush.nextStart - now)) .. "s"
    end
end
return HudView
