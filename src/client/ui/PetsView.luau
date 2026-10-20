-- Pet inventory: a grid of pet tiles (live 3D portrait, rarity band, name, bonus, equipped
-- tick, Golden sparkle). Tapping a tile selects it; the detail bar below shows it larger with
-- EQUIP or UNEQUIP and a two-tap DELETE. Tools above the grid: auto-delete and delete-all by
-- rarity, and merging copies into Golden pets. The server owns the inventory; this view only
-- displays and requests.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local PetConfig = require(Shared.config.Pets)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local Icons = require(script.Parent.Icons)
local PetText = require(script.Parent.PetText)
local PetPortrait = require(script.Parent.PetPortrait)
local PetsView = {}
PetsView.__index = PetsView
PetsView.Accent = Theme.Blue
local MinWidth, MaxWidth, MinHeight, MaxHeight = 340, 680, 400, 580
local GridTop, DetailHeight = 202, 86
local TileWidth, TileHeight = 92, 124
local ConfirmSeconds = 3
local function accentOf(pet) return if pet.golden then PetText.color("Legendary") else PetText.color(pet.rarity) end
local function chipRow(self, parent, name, label, y, onPress)
    local caption = E.label(parent, label, 28, Theme.Muted)
    caption.Name, caption.Position, caption.Size, caption.TextSize = name .. "Label", UDim2.fromOffset(20, y), UDim2.fromOffset(94, 28), 12
    caption.Font = Theme.Display
    E.fit(caption, 8, 12)
    local chips = {}
    for _, rarity in ipairs(PetConfig.BulkRarities) do
        local chip = E.button(parent, string.upper(rarity), function() onPress(rarity) end, Theme.Chip)
        chip.Name, chip.Size = name .. rarity, UDim2.fromOffset(84, 28)
        chip.TextSize, chip.AutoButtonColor = 12, false
        chip:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 14)
        E.fit(chip, 7, 12)
        chips[rarity] = chip
    end
    return chips
end
function PetsView.new(gui, send)
    local self = setmetatable({ send = send, hasStation = false, tiles = {}, confirm = {}, selected = nil }, PetsView)
    self.button = E.menuButton(gui, "PetsButton", "PETS", "pets", PetsView.Accent, function() self:toggle() end)
    local frame = E.panel(gui, "PetsPanel", MaxWidth, MaxHeight, Theme.Blue)
    local panel = frame.panel
    self.panel, self.scale, self.close, self.caption = panel, frame.scale, frame.close, frame.caption
    frame.title.Text = "PETS"
    self.close.Activated:Connect(function() self:setOpen(false) end)

    self.autoChips = chipRow(self, panel, "Auto", "AUTO-DELETE", 80, function(rarity)
        if self.hasStation then self.send("ToggleAutoDelete", rarity) end
    end)
    self.clearChips = chipRow(self, panel, "Clear", "DELETE ALL", 114, function(rarity) self:arm("rarity:" .. rarity, "DeleteRarity", rarity) end)
    self.autoLabel, self.clearLabel = panel.AutoLabel, panel.ClearLabel
    local merge = E.box(panel, "Merge", UDim2.fromOffset(16, 150), UDim2.new(1, -32, 0, 44), Theme.Card, 14)
    E.stroke(merge, Theme.Gold, 3, 0)
    local sparkle = Icons.make(merge, "sparkle", 24, Theme.Gold, UDim2.fromOffset(10, 10))
    sparkle.Name = "Sparkle"
    self.mergeText = E.label(merge, "", 30, Theme.Accent)
    self.mergeText.Name, self.mergeText.Position, self.mergeText.Size, self.mergeText.TextSize = "MergeText", UDim2.fromOffset(42, 7), UDim2.new(1, -144, 0, 30), 12
    self.mergeButton = E.button(merge, "MERGE", function() self:merge() end, Theme.Gold)
    self.mergeButton.Name, self.mergeButton.AnchorPoint = "MergeButton", Vector2.new(1, 0.5)
    self.mergeButton.Position, self.mergeButton.Size, self.mergeButton.TextSize = UDim2.new(1, -10, 0.5, -1), UDim2.fromOffset(86, 32), 14

    self.mergeBanner = merge
    local area = E.box(panel, "GridArea", UDim2.fromOffset(12, GridTop), UDim2.new(1, -24, 1, -GridTop - DetailHeight - 28), Theme.Cream, 0)
    self.gridArea = area
    self.grid, self.gridLayout = E.grid(area, "Grid", TileWidth, TileHeight, 10)
    self.empty = E.label(area, "No pets yet. Spin the machine to get one!", 40, Theme.Muted)
    self.empty.Name, self.empty.TextXAlignment, self.empty.TextSize = "Empty", Enum.TextXAlignment.Center, 14

    -- Detail bar for the selected pet.
    local detail = E.card(panel, "Selected", UDim2.new(0, 16, 1, -DetailHeight - 16), UDim2.new(1, -32, 0, DetailHeight), 18)
    self.detail = detail
    self.detailPortrait = PetPortrait.make(detail, "Portrait", UDim2.fromOffset(70, 70), UDim2.fromOffset(8, 8))
    self.detailName = E.label(detail, "", 26, Theme.Ink)
    self.detailName.Name, self.detailName.Position, self.detailName.Size = "PetName", UDim2.fromOffset(88, 8), UDim2.new(1, -290, 0, 26)
    self.detailName.Font, self.detailName.TextSize = Theme.Display, 19
    E.fit(self.detailName, 10, 19)
    self.detailTags = E.label(detail, "", 16, Theme.Muted)
    self.detailTags.Name, self.detailTags.Position, self.detailTags.Size, self.detailTags.TextSize = "Rarity", UDim2.fromOffset(88, 36), UDim2.new(1, -290, 0, 16), 11
    E.fit(self.detailTags, 7, 11)
    self.detailBonus = E.label(detail, "", 18, Theme.Accent)
    self.detailBonus.Name, self.detailBonus.Position, self.detailBonus.Size, self.detailBonus.TextSize = "Bonus", UDim2.fromOffset(88, 56), UDim2.new(1, -290, 0, 18), 13
    E.fit(self.detailBonus, 7, 13)
    self.equip = E.button(detail, "EQUIP", function() self:equipSelected() end, Theme.Gold)
    self.equip.Name, self.equip.AnchorPoint = "Equip", Vector2.new(1, 0.5)
    self.equip.Position, self.equip.Size, self.equip.TextSize = UDim2.new(1, -96, 0.5, -1), UDim2.fromOffset(104, 44), 15
    self.deleteButton = E.button(detail, "DELETE", function() if self.selected then self:delete(self.selected) end end, Theme.Card)
    self.deleteButton.Name, self.deleteButton.AnchorPoint = "Delete", Vector2.new(1, 0.5)
    self.deleteButton.Position, self.deleteButton.Size, self.deleteButton.TextSize = UDim2.new(1, -12, 0.5, -1), UDim2.fromOffset(76, 44), 13
    self.hint = E.label(detail, "Tap a pet to see it here.", DetailHeight, Theme.Muted)
    self.hint.Name, self.hint.TextXAlignment, self.hint.TextSize = "Hint", Enum.TextXAlignment.Center, 14
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
function PetsView:select(id)
    self.selected = id
    if self.state then self:update(self.state) end
end
function PetsView:equipSelected()
    local pet = self.byId and self.selected and self.byId[self.selected]
    if not self.hasStation or not pet then return end
    if pet.equipped then self.send("Unequip", pet.id) elseif not self.slotsFull then self.send("Equip", pet.id) end
end
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
function PetsView:tile(pet)
    local tile = E.button(self.grid, "", function() self:select(pet.id) end, Theme.Card, 0)
    tile.Name, tile.AutoButtonColor = pet.id, true
    tile:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 16)
    local stroke = E.stroke(tile, accentOf(pet), 3, 0)
    stroke.Name = "Outline"
    local band = E.box(tile, "Band", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 10), accentOf(pet), 8)
    band.ZIndex = 2
    PetPortrait.set(PetPortrait.make(tile, "Portrait", UDim2.fromOffset(70, 70), UDim2.new(0.5, -35, 0, 12)), pet.type, pet.golden)
    local name = E.label(tile, pet.name, 18, Theme.Ink)
    name.Name, name.Position, name.Size = "PetName", UDim2.new(0, 4, 0, 84), UDim2.new(1, -8, 0, 18)
    name.Font, name.TextSize, name.TextXAlignment = Theme.Display, 13, Enum.TextXAlignment.Center
    E.fit(name, 7, 13)
    local bonus = E.label(tile, PetText.bonus(pet.bonuses, true), 14, Theme.Accent)
    bonus.Name, bonus.Position, bonus.Size = "Bonus", UDim2.new(0, 4, 0, 104), UDim2.new(1, -8, 0, 14)
    bonus.TextSize, bonus.TextXAlignment = 10, Enum.TextXAlignment.Center
    E.fit(bonus, 6, 10)
    local badge = E.box(tile, "Equipped", UDim2.new(1, -20, 0, -6), UDim2.fromOffset(26, 26), Theme.Green, 13)
    E.stroke(badge, Theme.White, 2, 0)
    badge.ZIndex = 3
    local tick = Icons.make(badge, "check", 18, Theme.White, UDim2.fromOffset(4, 4))
    tick.ZIndex = 3
    if pet.golden then
        local glint = Icons.make(tile, "sparkle", 22, Theme.Gold, UDim2.fromOffset(-6, -6))
        glint.Name = "Golden"
    end
    return tile
end
function PetsView:update(state)
    self.state = state
    self.hasStation = state.hasStation
    E.setMenuEnabled(self.button, state.hasStation, PetsView.Accent)
    if not state.hasStation then self.panel.Visible = false end
    local pets = state.pets
    if not pets then return end
    self.slotsFull = pets.equipped >= pets.slots
    self.caption.Text = "Equipped " .. pets.equipped .. " / " .. pets.slots .. "  ·  " .. #pets.owned .. " / " .. pets.max .. " pets"
    self.empty.Visible = #pets.owned == 0
    -- Tools: auto-delete chips are toggles; delete-all chips need a second tap.
    local autoDelete = pets.autoDelete or {}
    for rarity, chip in pairs(self.autoChips) do
        local on = autoDelete[rarity] == true
        chip.BackgroundColor3 = if on then Theme.Red else Theme.Chip
        chip.TextColor3 = if on then Theme.OnColor else PetText.color(rarity)
    end
    for rarity, chip in pairs(self.clearChips) do
        local armed = self:armed("rarity:" .. rarity)
        chip.Text = if armed then "SURE?" else string.upper(rarity)
        chip.BackgroundColor3 = if armed then Theme.Red else Theme.Chip
        chip.TextColor3 = if armed then Theme.OnColor else PetText.color(rarity)
    end
    self.mergeable = pets.mergeable or {}
    local first = self.mergeable[1]
    self.mergeButton.Visible, self.mergeButton.Active = first ~= nil, first ~= nil
    self.mergeText.Text = if first then "Merge " .. (pets.mergeCount or 5) .. " " .. first.name .. " into a Golden "
        .. first.name .. " (2x bonus)" .. (if #self.mergeable > 1 then "  ·  +" .. (#self.mergeable - 1) .. " more" else "")
        else "Collect " .. (pets.mergeCount or 5) .. " unequipped copies of a pet to merge them into a Golden pet (2x bonus)."
    self.mergeText.TextColor3 = if first then Theme.Accent else Theme.Muted
    -- Tiles: reuse by ID so portraits are only built for new pets.
    self.byId = {}
    for order, pet in ipairs(sorted(pets.owned)) do
        self.byId[pet.id] = pet
        local tile = self.tiles[pet.id]
        if tile and tile:GetAttribute("Golden") ~= pet.golden then tile:Destroy(); tile = nil end
        if not tile then
            tile = self:tile(pet)
            tile:SetAttribute("Golden", pet.golden)
            self.tiles[pet.id] = tile
        end
        tile.LayoutOrder = order
        tile.Equipped.Visible = pet.equipped
        local selected = self.selected == pet.id
        tile.BackgroundColor3 = if selected then Theme.Cream else Theme.Card
        tile.Outline.Color = if selected then Theme.Ink else accentOf(pet)
        tile.Outline.Thickness = if selected then 4 else 3
    end
    for id, tile in pairs(self.tiles) do
        if not self.byId[id] then tile:Destroy(); self.tiles[id] = nil end
    end
    -- Detail bar.
    local pet = self.selected and self.byId[self.selected]
    if not pet then self.selected = nil end
    for _, child in ipairs({ self.detailPortrait, self.detailName, self.detailTags, self.detailBonus, self.equip }) do child.Visible = pet ~= nil end
    self.hint.Visible = pet == nil
    self.deleteButton.Visible = pet ~= nil and not pet.equipped
    if pet then
        PetPortrait.set(self.detailPortrait, pet.type, pet.golden)
        self.detailName.Text, self.detailName.TextColor3 = pet.name, accentOf(pet)
        self.detailTags.Text = string.upper(pet.rarity) .. (if pet.golden then "  ·  GOLDEN" else "") .. (if pet.equipped then "  ·  EQUIPPED" else "")
        self.detailBonus.Text = PetText.bonus(pet.bonuses)
        local canEquip = pet.equipped or not self.slotsFull
        self.equip.Text = if pet.equipped then "UNEQUIP" elseif canEquip then "EQUIP" else "SLOTS FULL"
        self.equip.Active, self.equip.Selectable, self.equip.AutoButtonColor = canEquip, canEquip, canEquip
        self.equip.BackgroundColor3 = if pet.equipped then Theme.Chip elseif canEquip then Theme.Gold else Theme.Disabled
        self.equip.TextColor3 = if canEquip then Theme.Ink else Theme.Muted
        local armed = self:armed("pet:" .. pet.id)
        self.deleteButton.Text = if armed then "SURE?" else "DELETE"
        self.deleteButton.BackgroundColor3 = if armed then Theme.Red else Theme.Card
        self.deleteButton.TextColor3 = if armed then Theme.OnColor else Theme.Red
    end
end
-- The panel grows with the screen (more tile columns) and only scales below its minimum.
function PetsView:resize(viewport)
    local availableWidth, availableHeight = viewport.X - 32, viewport.Y - 60 - 24
    local width = math.clamp(availableWidth, MinWidth, MaxWidth)
    -- Short, wide screens (phone landscape): both chip rows share one line so a full row of
    -- pet tiles still fits above the detail bar.
    local compact = width >= 600 and availableHeight < 480
    local height = math.clamp(availableHeight, if compact then 410 else MinHeight, MaxHeight)
    self.panel.Size = UDim2.fromOffset(width, height)
    self.scale.Scale = math.min(1, availableWidth / width, availableHeight / height)
    local groupWidth = if compact then math.floor((width - 32 - 16) / 2) else width - 32
    local chipWidth = math.clamp(math.floor((groupWidth - 88 - 16) / 3), 60, 100)
    for row, chips in ipairs({ self.autoChips, self.clearChips }) do
        local left = if compact and row == 2 then 16 + groupWidth + 16 else 16
        local y = if compact then 80 else (if row == 1 then 80 else 114)
        local label = if row == 1 then self.autoLabel else self.clearLabel
        label.Position, label.Size = UDim2.fromOffset(left + 4, y), UDim2.fromOffset(if compact then 82 else 94, 28)
        for index, rarity in ipairs(PetConfig.BulkRarities) do
            local chip = chips[rarity]
            chip.Size = UDim2.fromOffset(chipWidth, 28)
            chip.Position = UDim2.fromOffset(left + (if compact then 88 else 98) + (index - 1) * (chipWidth + 8), y)
        end
    end
    local gridTop = if compact then GridTop - 34 else GridTop
    self.mergeBanner.Position = UDim2.fromOffset(16, gridTop - 52)
    self.gridArea.Position = UDim2.fromOffset(12, gridTop)
    self.gridArea.Size = UDim2.new(1, -24, 1, -gridTop - DetailHeight - 28)
    E.fitGrid(self.gridLayout, width - 24, TileWidth)
    -- Detail bar: buttons side by side on wide panels, stacked on narrow ones so the name fits.
    local narrow = width < 520
    local textWidth = if narrow then -(88 + 96 + 24) else -290
    for _, label in ipairs({ self.detailName, self.detailTags, self.detailBonus }) do
        label.Size = UDim2.new(1, textWidth, 0, label.Size.Y.Offset)
    end
    if narrow then
        self.equip.AnchorPoint, self.equip.Position, self.equip.Size = Vector2.new(1, 0), UDim2.new(1, -14, 0, 8), UDim2.fromOffset(96, 36)
        self.deleteButton.AnchorPoint, self.deleteButton.Position = Vector2.new(1, 1), UDim2.new(1, -14, 1, -12)
        self.deleteButton.Size = UDim2.fromOffset(96, 28)
    else
        self.equip.AnchorPoint, self.equip.Position, self.equip.Size = Vector2.new(1, 0.5), UDim2.new(1, -96, 0.5, -1), UDim2.fromOffset(104, 44)
        self.deleteButton.AnchorPoint, self.deleteButton.Position = Vector2.new(1, 0.5), UDim2.new(1, -12, 0.5, -1)
        self.deleteButton.Size = UDim2.fromOffset(76, 44)
    end
end
return PetsView
