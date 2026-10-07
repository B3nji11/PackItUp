local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Equipment = require(Shared.config.Equipment)
local E = require(script.Parent.Elements)
local Theme = require(script.Parent.Theme)
local InventoryView = {}
InventoryView.__index = InventoryView
function InventoryView.new(parent, send)
    local self = setmetatable({ frame = E.column(parent, "Gear"), buttons = {} }, InventoryView)
    E.label(self.frame, "YOUR EQUIPMENT", 36, Theme.Gold)
    E.label(self.frame, "Equip one machine and one bag. Only equipped gear affects your stats. New deliveries never replace your current gear automatically.", 82, Theme.Muted)
    for _, category in ipairs(Equipment.Categories) do
        E.label(self.frame, string.upper(category), 30, Theme.Blue)
        local ids = { Equipment.Starter[category] }
        for _, rarity in ipairs(Equipment.Rarities) do table.insert(ids, Equipment.Pools[category][rarity.id]) end
        for _, id in ipairs(ids) do
            self.buttons[id] = E.button(self.frame, Equipment.Items[id].name, function() send("Equip", id) end)
        end
    end
    return self
end
function InventoryView:update(state)
    local p = state.profile
    for id, button in pairs(self.buttons) do
        local item = Equipment.Items[id]
        local equipped = p.equipped[item.category] == id
        local owned = p.owned[id] == true
        button.Text = (if equipped then "EQUIPPED  " elseif owned then "EQUIP  " else "LOCKED  ") .. item.name
            .. "  |  " .. item.power .. (if item.category == "Machine" then "/sec" else "x")
        button.BackgroundColor3 = if equipped then Theme.Green elseif owned then Theme.Gold else Theme.Muted
    end
end
return InventoryView
