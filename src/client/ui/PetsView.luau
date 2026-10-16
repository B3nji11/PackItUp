-- Pet inventory: owned pets with rarity, bonus, Equip/Unequip, and a two-tap Delete, plus
-- tools: auto-delete by rarity, delete all of a rarity (two taps), and merging into Golden pets.
-- The server owns the inventory; this view only displays and requests.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local PetConfig = require(Shared.config.Pets)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local PetText = require(script.Parent.PetText)
local PetsView = {}
PetsView.__index = PetsView
local PanelWidth, PanelHeight, RowHeight = 380, 480, 60
local ListTop = 188
local ConfirmSeconds = 3
local function chipRow(self, parent, name, label, y, onPress)
    local caption = E.label(parent, label, 26, Theme.Muted)
    caption.Name, caption.Position, caption.Size, caption.TextSize = name .. "Label", UDim2.fromOffset(20, y), UDim2.fromOffset(92, 26), 10
    caption.Font = Enum.Font.GothamBold
    local chips = {}
    for index, rarity in ipairs(PetConfig.BulkRarities) do
        local chip = E.button(parent, string.upper(rarity), function() onPress(rarity) end, Theme.Card)
        chip.Name, chip.Position, chip.Size = name .. rarity, UDim2.fromOffset(112 + (index - 1) * 86, y), UDim2.fromOffset(80, 26)
        chip.TextSize, chip.AutoButtonColor = 10, false
        E.fit(chip, 7, 10)
        chips[rarity] = chip
    end
    return chips
end
function PetsView.new(gui, send)
    local self = setmetatable({ send = send, hasStation = false, rows = {}, confirm = {} }, PetsView)
    self.button = E.button(gui, "PETS", function() self:toggle() end, Theme.Background)
    self.button.Name, self.button.TextSize, self.button.TextColor3 = "PetsButton", 13, Theme.Blue
    E.stroke(self.button, Theme.Blue, 1.5, 0.3)
    E.fit(self.button, 8, 13)

    local panel = E.box(gui, "PetsPanel", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(PanelWidth, PanelHeight), Theme.Background, 18)
    panel.AnchorPoint, panel.Visible, panel.ZIndex = Vector2.new(0.5, 0.5), false, 5
    E.stroke(panel, Theme.Blue, 2, 0.12)
    self.panel = panel
    self.scale = Instance.new("UIScale")
    self.scale.Parent = panel
    local title = E.label(panel, "PETS", 28, Theme.Text)
    title.Name, title.Position, title.Size = "Title", UDim2.fromOffset(20, 14), UDim2.fromOffset(260, 28)
    title.Font, title.TextSize = Enum.Font.GothamBold, 21
    self.caption = E.label(panel, "", 16, Theme.Muted)
    self.caption.Name, self.caption.Position, self.caption.Size, self.caption.TextSize = "Caption", UDim2.fromOffset(20, 42), UDim2.fromOffset(280, 16), 11
    self.close = E.button(panel, "X", function() self:setOpen(false) end, Theme.Card)
    self.close.Name, self.close.Position, self.close.Size = "Close", UDim2.fromOffset(PanelWidth - 52, 14), UDim2.fromOffset(36, 36)
    self.close.TextColor3, self.close.TextSize = Theme.Text, 14

    self.autoChips = chipRow(self, panel, "Auto", "AUTO-DELETE", 68, function(rarity)
        if self.hasStation then self.send("ToggleAutoDelete", rarity) end
    end)
    self.clearChips = chipRow(self, panel, "Clear", "DELETE ALL", 100, function(rarity) self:arm("rarity:" .. rarity, "DeleteRarity", rarity) end)
    local merge = E.box(panel, "Merge", UDim2.fromOffset(16, 134), UDim2.fromOffset(PanelWidth - 32, 44), Theme.Card, 12)
    E.stroke(merge, Theme.Gold, 1, 0.5)
    self.mergeText = E.label(merge, "", 30, Theme.GoldLight)
    self.mergeText.Name, self.mergeText.Position, self.mergeText.Size, self.mergeText.TextSize = "MergeText", UDim2.fromOffset(12, 7), UDim2.new(1, -112, 0, 30), 11
    self.mergeButton = E.button(merge, "MERGE", function() self:merge() end, Theme.Gold)
    self.mergeButton.Name, self.mergeButton.AnchorPoint = "MergeButton", Vector2.new(1, 0.5)
    self.mergeButton.Position, self.mergeButton.Size, self.mergeButton.TextSize = UDim2.new(1, -8, 0.5, 0), UDim2.fromOffset(88, 32), 12
    self.mergeButton.TextColor3 = Theme.Ink

    local holder = E.box(panel, "ListArea", UDim2.fromOffset(16, ListTop), UDim2.fromOffset(PanelWidth - 32, PanelHeight - ListTop - 16), Theme.Background, 0)
    self.list = E.column(holder, "List")
    self.empty = E.label(holder, "No pets yet. Spin the machine to get one!", 40, Theme.Muted)
    self.empty.Name, self.empty.TextXAlignment, self.empty.TextSize = "Empty", Enum.TextXAlignment.Center, 13
    return self
end
function PetsView:setOpen(open) self.panel.Visible = open and self.hasStation end
function PetsView:toggle() if self.hasStation then self:setOpen(not self.panel.Visible) end end
function PetsView:armed(key) return self.confirm.key == key and os.clock() < (self.confirm.untilTime or 0) end
-- Destructive requests need a second tap within a few seconds.
function PetsView:arm(key, action, argument)
    if not self.hasStation then return end
    if self:armed(key) then
        self.confirm = {}
        self.send(action, argument)
    else
        self.confirm = { key = key, untilTime = os.clock() + ConfirmSeconds }
    end
    if self.state then self:update(self.state) end
end
function PetsView:delete(id) self:arm("pet:" .. id, "DeletePet", id) end
function PetsView:merge()
    local first = self.mergeable and self.mergeable[1]
    if self.hasStation and first then self.send("MergePets", first.type) end
end
local function sorted(owned)
    local list = table.clone(owned)
    table.sort(list, function(a, b)
        if a.equipped ~= b.equipped then return a.equipped end
        if a.rank ~= b.rank then return a.rank > b.rank end
        if a.golden ~= b.golden then return a.golden end
        return tonumber(string.sub(a.id, 2)) < tonumber(string.sub(b.id, 2))
    end)
    return list
end
function PetsView:row(pet, order, full)
    local accent = if pet.golden then Theme.Gold else PetText.color(pet.rarity)
    local row = E.box(self.list, pet.id, UDim2.new(), UDim2.new(1, 0, 0, RowHeight), Theme.Card, 12)
    row.LayoutOrder = order
    E.stroke(row, accent, if pet.equipped or pet.golden then 2 else 1, if pet.equipped then 0 else 0.6)
    local name = E.label(row, pet.name, 22, accent)
    name.Name, name.Position, name.Size = "PetName", UDim2.fromOffset(12, 7), UDim2.new(1, -180, 0, 22)
    name.Font, name.TextSize = Enum.Font.GothamBold, 14
    E.fit(name, 9, 14)
    local tags = string.upper(pet.rarity) .. (if pet.golden then "  ·  GOLDEN" else "") .. (if pet.equipped then "  ·  EQUIPPED" else "")
    local detail = E.label(row, tags, 14, Theme.Muted)
    detail.Name, detail.Position, detail.Size, detail.TextSize = "Rarity", UDim2.fromOffset(12, 29), UDim2.new(1, -180, 0, 14), 9
    local bonus = E.label(row, PetText.bonus(pet.bonuses, true), 14, Theme.GoldLight)
    bonus.Name, bonus.Position, bonus.Size, bonus.TextSize = "Bonus", UDim2.fromOffset(12, 43), UDim2.new(1, -180, 0, 14), 10
    E.fit(bonus, 7, 10)
    local canEquip = pet.equipped or not full
    local equip = E.button(row, if pet.equipped then "UNEQUIP" else "EQUIP", function()
        if not self.hasStation then return end
        if pet.equipped then self.send("Unequip", pet.id) elseif not full then self.send("Equip", pet.id) end
    end, if pet.equipped then Theme.Background elseif canEquip then Theme.Gold else Theme.Background)
    equip.Name, equip.AnchorPoint = "Equip", Vector2.new(1, 0.5)
    equip.Position, equip.Size = UDim2.new(1, if pet.equipped then -8 else -78, 0.5, 0), UDim2.fromOffset(84, 38)
    equip.TextSize, equip.AutoButtonColor = 11, canEquip
    equip.TextColor3 = if pet.equipped then Theme.Text elseif canEquip then Theme.Ink else Theme.Muted
    equip.Active, equip.Selectable = canEquip, canEquip
    if not pet.equipped then
        local armed = self:armed("pet:" .. pet.id)
        local delete = E.button(row, if armed then "SURE?" else "DELETE", function() self:delete(pet.id) end,
            if armed then Theme.Red else Theme.Background)
        delete.Name, delete.AnchorPoint, delete.Position, delete.Size = "Delete", Vector2.new(1, 0.5), UDim2.new(1, -8, 0.5, 0), UDim2.fromOffset(64, 38)
        delete.TextSize, delete.TextColor3 = 10, if armed then Theme.Ink else Theme.Red
        E.stroke(delete, Theme.Red, 1, 0.5)
    end
    return row
end
function PetsView:update(state)
    self.state = state
    self.hasStation = state.hasStation
    self.button.Active, self.button.Selectable, self.button.AutoButtonColor = state.hasStation, state.hasStation, state.hasStation
    self.button.TextColor3 = if state.hasStation then Theme.Blue else Theme.Muted
    if not state.hasStation then self.panel.Visible = false end
    local pets = state.pets
    if not pets then return end
    local full = pets.equipped >= pets.slots
    self.caption.Text = "Equipped " .. pets.equipped .. " / " .. pets.slots .. "  ·  " .. #pets.owned .. " / " .. pets.max .. " pets"
    self.empty.Visible = #pets.owned == 0
    -- Tools: auto-delete chips are toggles; delete-all chips need a second tap.
    local autoDelete = pets.autoDelete or {}
    for rarity, chip in pairs(self.autoChips) do
        local on = autoDelete[rarity] == true
        chip.BackgroundColor3 = if on then Theme.Red else Theme.Card
        chip.TextColor3 = if on then Theme.Ink else PetText.color(rarity)
    end
    for rarity, chip in pairs(self.clearChips) do
        local armed = self:armed("rarity:" .. rarity)
        chip.Text = if armed then "SURE?" else string.upper(rarity)
        chip.BackgroundColor3 = if armed then Theme.Red else Theme.Card
        chip.TextColor3 = if armed then Theme.Ink else PetText.color(rarity)
    end
    self.mergeable = pets.mergeable or {}
    local first = self.mergeable[1]
    self.mergeButton.Visible, self.mergeButton.Active = first ~= nil, first ~= nil
    self.mergeText.Text = if first then "Merge " .. (pets.mergeCount or 5) .. " " .. first.name .. " into a Golden "
        .. first.name .. " (2x bonus)" .. (if #self.mergeable > 1 then "  ·  +" .. (#self.mergeable - 1) .. " more" else "")
        else "Collect " .. (pets.mergeCount or 5) .. " unequipped copies of a pet to merge them into a Golden pet (2x bonus)."
    self.mergeText.TextColor3 = if first then Theme.GoldLight else Theme.Muted
    -- Rebuild rows only when the pets, their state, or a Delete confirmation changes.
    local parts = { tostring(full), tostring(self.confirm.key), tostring(self:armed(self.confirm.key)) }
    for _, pet in ipairs(pets.owned) do table.insert(parts, pet.id .. (if pet.equipped then "*" else "") .. (if pet.golden then "g" else "")) end
    local signature = table.concat(parts, ",")
    if signature == self.signature then return end
    self.signature = signature
    for _, row in pairs(self.rows) do row:Destroy() end
    self.rows = {}
    for order, pet in ipairs(sorted(pets.owned)) do self.rows[pet.id] = self:row(pet, order, full) end
end
function PetsView:resize(viewport)
    self.scale.Scale = math.min(1, (viewport.X - 32) / PanelWidth, (viewport.Y - 60 - 24) / PanelHeight)
end
return PetsView
