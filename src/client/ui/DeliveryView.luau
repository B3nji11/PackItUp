local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Equipment = require(Shared.config.Equipment)
local Economy = require(Shared.config.Economy)
local E = require(script.Parent.Elements)
local Theme = require(script.Parent.Theme)
local DeliveryView = {}
DeliveryView.__index = DeliveryView
function DeliveryView.new(parent, send)
    local self = setmetatable({ frame = E.column(parent, "Delivery"), labels = {} }, DeliveryView)
    E.label(self.frame, "OPEN A SUPPLY DELIVERY", 36, Theme.Gold)
    E.label(self.frame, "Each delivery costs 3 Tickets earned in-game. A duplicate returns 1 Ticket. New items go to GEAR.", 68, Theme.Muted)
    for _, category in ipairs(Equipment.Categories) do
        self.labels[category] = E.label(self.frame, "", 56)
        E.button(self.frame, "OPEN " .. string.upper(category) .. " DELIVERY  |  3 Tickets", function() send("Roll", category) end)
        local lines = {}
        for _, rarity in ipairs(Equipment.Rarities) do
            local item = Equipment.Items[Equipment.Pools[category][rarity.id]]
            table.insert(lines, rarity.weight .. "%  " .. item.name .. " (" .. item.power .. (if category == "Machine" then "/sec)" else "x value)"))
        end
        E.label(self.frame, table.concat(lines, "\n"), 98, Theme.Muted)
    end
    E.label(self.frame, "After 9 rolls without Epic/Legendary, the next roll is 90% Epic / 10% Legendary. Each delivery type has its own saved counter. Any Epic/Legendary resets that counter.", 105, Theme.Muted)
    return self
end
function DeliveryView:update(state)
    for _, category in ipairs(Equipment.Categories) do
        local count = state.profile.pity[category]
        self.labels[category].Text = string.upper(category) .. " DELIVERY\n" .. (if count >= Economy.PityAt - 1 then "NEXT ROLL: 90% Epic / 10% Legendary"
            else "Normal odds below | Guarantee in " .. (Economy.PityAt - count) .. " rolls")
    end
end
return DeliveryView
