local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Variants = require(Shared.config.Variants)
local E = require(script.Parent.Elements)
local Theme = require(script.Parent.Theme)
local IndexView = {}
IndexView.__index = IndexView
function IndexView.new(parent)
    local self = setmetatable({ frame = E.column(parent, "Index"), labels = {} }, IndexView)
    E.label(self.frame, "THE FRY INDEX", 36, Theme.Gold)
    E.label(self.frame, "A variation is rolled when a bag becomes full. Discoveries stay in your index after selling. Collect all three for a one-time +3 Tickets.", 92, Theme.Muted)
    for _, variant in ipairs(Variants) do self.labels[variant.id] = E.label(self.frame, "", 65) end
    self.reward = E.label(self.frame, "", 60, Theme.Green)
    return self
end
function IndexView:update(state)
    for _, variant in ipairs(Variants) do
        self.labels[variant.id].Text = (if state.profile.discoveries[variant.id] then "DISCOVERED: " else "UNDISCOVERED: ")
            .. variant.name .. "\n" .. variant.weight .. "% chance  |  " .. variant.multiplier .. "x sale value"
    end
    self.reward.Text = if state.profile.indexRewardClaimed then "Index complete! Your 3-Ticket reward has been credited." else "Keep serving to complete your collection."
end
return IndexView
