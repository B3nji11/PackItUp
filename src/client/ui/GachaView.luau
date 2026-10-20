-- Gacha machine: the last pull (live portrait, rarity tag, bonus), a pity progress bar, the
-- SPIN button, and every pet in the machine as a tile with its own chance. Two columns on
-- wide screens, stacked on narrow ones. The server rolls; this view only displays and requests.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local PetConfig = require(Shared.config.Pets)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local PetText = require(script.Parent.PetText)
local PetPortrait = require(script.Parent.PetPortrait)
local GachaView = {}
GachaView.__index = GachaView
GachaView.Accent = Theme.Green
local MinWidth, MaxWidth, MinHeight, MaxHeight, NarrowMaxHeight = 340, 680, 440, 540, 680
local WideAt, LeftWidth = 560, 240
local PoolTileWidth, PoolTileHeight = 88, 112
function GachaView.new(gui, send)
    local self = setmetatable({ send = send, hasStation = false, canSpin = false, poolTiles = {} }, GachaView)
    self.button = E.menuButton(gui, "SpinButton", "SPIN", "spin", GachaView.Accent, function() self:toggle() end)
    local frame = E.panel(gui, "GachaPanel", MaxWidth, MaxHeight, Theme.Green)
    self.panel, self.scale, self.close, self.title, self.caption = frame.panel, frame.scale, frame.close, frame.title, frame.caption
    self.title.Text = "STARTER FRYER"
    self.close.Activated:Connect(function() self:setOpen(false) end)
    local panel = self.panel

    -- The last pull.
    self.result = E.card(panel, "Result", UDim2.fromOffset(16, E.PanelTop + 12), UDim2.fromOffset(LeftWidth, 196), 18)
    self.portrait = PetPortrait.make(self.result, "Portrait", UDim2.fromOffset(110, 110))
    self.mystery = E.label(self.result, "?", 110, Theme.Tan)
    self.mystery.Name, self.mystery.Font, self.mystery.TextSize = "Mystery", Theme.Display, 72
    self.mystery.TextXAlignment = Enum.TextXAlignment.Center
    self.tag = E.label(self.result, "", 22, Theme.OnColor)
    self.tag.Name, self.tag.Font, self.tag.TextSize = "Tag", Theme.Display, 13
    self.tag.TextXAlignment, self.tag.BackgroundTransparency, self.tag.Visible = Enum.TextXAlignment.Center, 0, false
    E.corner(self.tag, 11)
    self.resultName = E.label(self.result, "Spin to get a Fry Buddy!", 26, Theme.Ink)
    self.resultName.Name, self.resultName.Font, self.resultName.TextSize = "PetName", Theme.Display, 18
    E.fit(self.resultName, 9, 18)
    self.resultBonus = E.label(self.result, "Pets you win appear in PETS.", 18, Theme.Muted)
    self.resultBonus.Name, self.resultBonus.TextSize = "Bonus", 12
    E.fit(self.resultBonus, 7, 12)

    -- Pity progress, count, and the SPIN button.
    self.pity = Instance.new("Frame")
    self.pity.Name, self.pity.BackgroundTransparency, self.pity.Parent = "Pity", 1, panel
    self.pityText = E.label(self.pity, "", 16, Theme.Gem)
    self.pityText.Name, self.pityText.Font, self.pityText.TextSize = "PityText", Theme.Display, 12
    self.pityText.Size = UDim2.new(1, 0, 0, 16)
    E.fit(self.pityText, 7, 12)
    local track
    track, self.pityFill = E.bar(self.pity, Theme.Gem, 10)
    track.Name, track.Position, track.Size = "Progress", UDim2.fromOffset(0, 20), UDim2.new(1, 0, 0, 10)
    self.count = E.label(panel, "", 16, Theme.Muted)
    self.count.Name, self.count.TextSize = "Count", 12
    self.spin = E.button(panel, "SPIN", function() self:spinOnce() end, Theme.Green, 5)
    self.spin.Name, self.spin.AutoButtonColor, self.spin.TextColor3, self.spin.TextSize = "Spin", false, Theme.OnColor, 22
    self.spinOutline = E.textStroke(self.spin, Theme.Ink, 2)

    -- Every pet in the machine.
    self.poolLabel = E.label(panel, "IN THIS MACHINE", 20, Theme.Ink)
    self.poolLabel.Name, self.poolLabel.Font, self.poolLabel.TextSize = "PoolLabel", Theme.Display, 15
    self.poolArea = E.box(panel, "PoolArea", UDim2.new(), UDim2.new(), Theme.Cream, 0)
    self.pool, self.poolLayout = E.grid(self.poolArea, "Pool", PoolTileWidth, PoolTileHeight, 8)
    self.wide = nil
    return self
end
function GachaView:setOpen(open) self.panel.Visible = open and self.hasStation end
function GachaView:toggle() if self.hasStation then self:setOpen(not self.panel.Visible) end end
function GachaView:spinOnce()
    if self.canSpin and self.panel.Visible and self.machineId then self.send("Spin", self.machineId) end
end
-- One tile per pet in the machine, with that pet's own chance.
function GachaView:poolTile(petType, rarity, chance, order)
    local color = PetText.color(rarity)
    local tile = E.box(self.pool, petType, UDim2.new(), UDim2.new(), Theme.Card, 14)
    tile.LayoutOrder = order
    E.stroke(tile, color, 3, 0)
    E.box(tile, "Band", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 8), color, 8)
    PetPortrait.set(PetPortrait.make(tile, "Portrait", UDim2.fromOffset(60, 60), UDim2.new(0.5, -30, 0, 10)), petType, false)
    local name = E.label(tile, PetConfig.Types[petType].Name, 16, Theme.Ink)
    name.Name, name.Position, name.Size = "PetName", UDim2.new(0, 4, 0, 72), UDim2.new(1, -8, 0, 16)
    name.Font, name.TextSize, name.TextXAlignment = Theme.Display, 12, Enum.TextXAlignment.Center
    E.fit(name, 7, 12)
    local odds = E.label(tile, E.number(chance) .. "%", 18, color)
    odds.Name, odds.Position, odds.Size = "Chance", UDim2.new(0, 4, 0, 90), UDim2.new(1, -8, 0, 18)
    odds.Font, odds.TextSize, odds.TextXAlignment = Theme.Display, 14, Enum.TextXAlignment.Center
    return tile
end
function GachaView:showResult(pet, rarity, autoDeleted)
    local color = PetText.color(rarity)
    PetPortrait.set(self.portrait, pet.type, pet.golden)
    self.mystery.Visible = false
    self.tag.Visible = true
    self.tag.Text = if autoDeleted then "AUTO-DELETED" else string.upper(rarity) .. "!"
    self.tag.BackgroundColor3 = if autoDeleted then Theme.Muted else color
    self.resultName.Text = if autoDeleted then "Auto-deleted " .. pet.name else "You got " .. pet.name .. "!"
    self.resultName.TextColor3 = if autoDeleted then Theme.Muted else color
    self.resultBonus.Text = if autoDeleted then "Turn auto-delete off in PETS to keep these." else PetText.bonus(pet.bonuses)
end
function GachaView:update(state)
    self.hasStation = state.hasStation
    E.setMenuEnabled(self.button, state.hasStation, GachaView.Accent)
    if not state.hasStation then self.panel.Visible = false end
    local machine, pets = state.machine, state.pets
    if not machine or not pets then return end
    self.machineId = machine.id
    self.title.Text = string.upper(machine.name)
    local left = machine.pityEvery - machine.pity
    self.caption.Text = E.money(machine.price) .. " per spin  ·  " .. machine.pityRarity .. " or better within " .. left
        .. (if left == 1 then " spin" else " spins")
    self.pityText.Text = string.upper(machine.pityRarity) .. "+ GUARANTEED IN " .. left .. (if left == 1 then " SPIN" else " SPINS")
    self.pityFill.Size = UDim2.fromScale(math.clamp(machine.pity / machine.pityEvery, 0, 1), 1)
    if not next(self.poolTiles) then
        local order = 0
        for _, row in ipairs(machine.odds) do
            for _, petType in ipairs(row.types or {}) do
                order += 1
                self.poolTiles[petType] = self:poolTile(petType, row.rarity, row.chance * 100 / #row.types, order)
            end
        end
    end
    local full = #pets.owned >= pets.max
    local affordable = state.profile.cash >= machine.price
    self.canSpin = state.hasStation and affordable and not full
    self.count.Text = "PETS " .. #pets.owned .. " / " .. pets.max .. (if full then "  ·  inventory full" else "")
    self.spin.Active, self.spin.Selectable = self.canSpin, self.canSpin
    self.spin.Text = if full then "INVENTORY FULL" elseif affordable then "SPIN  " .. E.money(machine.price) else "NEED " .. E.money(machine.price)
    self.spin.BackgroundColor3 = if self.canSpin then Theme.Green else Theme.Disabled
    self.spin.TextColor3 = if self.canSpin then Theme.OnColor else Theme.Muted
    self.spinOutline.Enabled = self.canSpin
    -- A new spin result shows the pet large in its rarity colour.
    local spin = state.spin
    if spin and spin.serial ~= self.lastSerial then
        self.lastSerial = spin.serial
        if spin.autoDeleted then
            local kind = PetConfig.Types[spin.type]
            self:showResult({ type = spin.type, name = kind.Name, golden = false, bonuses = {} }, kind.Rarity, true)
        else
            for _, owned in ipairs(pets.owned) do
                if owned.id == spin.id then self:showResult(owned, owned.rarity, false) end
            end
        end
    end
end
-- Two columns on wide panels, stacked on narrow ones; the panel grows with the screen.
function GachaView:resize(viewport)
    local availableWidth, availableHeight = viewport.X - 32, viewport.Y - 60 - 24
    local width = math.clamp(availableWidth, MinWidth, MaxWidth)
    local wide = width >= WideAt
    -- Stacked (phone portrait) panels may grow taller so more of the pool shows.
    local height = math.clamp(availableHeight, MinHeight, if wide then MaxHeight else NarrowMaxHeight)
    self.panel.Size = UDim2.fromOffset(width, height)
    self.scale.Scale = math.min(1, availableWidth / width, availableHeight / height)
    local top = E.PanelTop + 12
    local spinTop = height - 74
    if wide then
        self.result.Position, self.result.Size = UDim2.fromOffset(16, top), UDim2.fromOffset(LeftWidth, 196)
        self.portrait.Position, self.portrait.Size = UDim2.new(0.5, -55, 0, 8), UDim2.fromOffset(110, 110)
        self.mystery.Position, self.mystery.Size = UDim2.new(0.5, -55, 0, 8), UDim2.fromOffset(110, 110)
        self.tag.Position, self.tag.Size = UDim2.new(0.5, -60, 0, 114), UDim2.fromOffset(120, 22)
        self.resultName.Position, self.resultName.Size = UDim2.fromOffset(10, 140), UDim2.new(1, -20, 0, 26)
        self.resultName.TextXAlignment = Enum.TextXAlignment.Center
        self.resultBonus.Position, self.resultBonus.Size = UDim2.fromOffset(10, 168), UDim2.new(1, -20, 0, 18)
        self.resultBonus.TextXAlignment = Enum.TextXAlignment.Center
        self.pity.Position, self.pity.Size = UDim2.fromOffset(16, top + 210), UDim2.fromOffset(LeftWidth, 32)
        self.count.Position, self.count.Size = UDim2.fromOffset(16, spinTop - 24), UDim2.fromOffset(LeftWidth, 16)
        self.spin.Position, self.spin.Size = UDim2.fromOffset(16, spinTop), UDim2.fromOffset(LeftWidth, 54)
        self.poolLabel.Position, self.poolLabel.Size = UDim2.fromOffset(LeftWidth + 34, top - 2), UDim2.fromOffset(width - LeftWidth - 50, 20)
        self.poolArea.Position = UDim2.fromOffset(LeftWidth + 28, top + 22)
        self.poolArea.Size = UDim2.fromOffset(width - LeftWidth - 40, height - top - 22 - 14)
    else
        self.result.Position, self.result.Size = UDim2.fromOffset(16, top), UDim2.new(1, -32, 0, 104)
        self.portrait.Position, self.portrait.Size = UDim2.fromOffset(6, 6), UDim2.fromOffset(92, 92)
        self.mystery.Position, self.mystery.Size = UDim2.fromOffset(6, 6), UDim2.fromOffset(92, 92)
        self.tag.Position, self.tag.Size = UDim2.fromOffset(106, 12), UDim2.fromOffset(120, 22)
        self.resultName.Position, self.resultName.Size = UDim2.fromOffset(106, 40), UDim2.new(1, -116, 0, 26)
        self.resultName.TextXAlignment = Enum.TextXAlignment.Left
        self.resultBonus.Position, self.resultBonus.Size = UDim2.fromOffset(106, 70), UDim2.new(1, -116, 0, 18)
        self.resultBonus.TextXAlignment = Enum.TextXAlignment.Left
        self.poolLabel.Position, self.poolLabel.Size = UDim2.fromOffset(20, top + 114), UDim2.new(1, -40, 0, 20)
        self.poolArea.Position = UDim2.fromOffset(12, top + 136)
        self.poolArea.Size = UDim2.new(1, -24, 0, math.max(60, spinTop - 70 - (top + 136)))
        self.pity.Position, self.pity.Size = UDim2.fromOffset(16, spinTop - 64), UDim2.new(1, -32, 0, 32)
        self.count.Position, self.count.Size = UDim2.fromOffset(16, spinTop - 24), UDim2.new(1, -32, 0, 16)
        self.spin.Position, self.spin.Size = UDim2.fromOffset(16, spinTop), UDim2.new(1, -37, 0, 54)
    end
    E.fitGrid(self.poolLayout, if wide then width - LeftWidth - 40 else width - 24, PoolTileWidth)
    self.wide = wide
end
return GachaView
