-- Gacha machine panel: price, odds, pity, last result, and the SPIN button.
-- The server rolls; this view only displays and requests.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local PetConfig = require(Shared.config.Pets)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local PetText = require(script.Parent.PetText)
local GachaView = {}
GachaView.__index = GachaView
local PanelWidth, PanelHeight = 360, 376
function GachaView.new(gui, send)
    local self = setmetatable({ send = send, hasStation = false, canSpin = false, odds = {} }, GachaView)
    self.button = E.button(gui, "SPIN", function() self:toggle() end, Theme.Background)
    self.button.Name, self.button.TextSize, self.button.TextColor3 = "SpinButton", 13, Theme.Green
    E.stroke(self.button, Theme.Green, 1.5, 0.3)
    E.fit(self.button, 8, 13)

    local panel = E.box(gui, "GachaPanel", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(PanelWidth, PanelHeight), Theme.Background, 18)
    panel.AnchorPoint, panel.Visible, panel.ZIndex = Vector2.new(0.5, 0.5), false, 5
    E.stroke(panel, Theme.Green, 2, 0.12)
    self.panel = panel
    self.scale = Instance.new("UIScale")
    self.scale.Parent = panel
    self.title = E.label(panel, "STARTER FRYER", 28, Theme.Text)
    self.title.Name, self.title.Position, self.title.Size = "Title", UDim2.fromOffset(20, 14), UDim2.fromOffset(260, 28)
    self.title.Font, self.title.TextSize = Enum.Font.GothamBold, 21
    self.caption = E.label(panel, "", 16, Theme.Muted)
    self.caption.Name, self.caption.Position, self.caption.Size, self.caption.TextSize = "Caption", UDim2.fromOffset(20, 42), UDim2.fromOffset(270, 16), 11
    self.close = E.button(panel, "X", function() self:setOpen(false) end, Theme.Card)
    self.close.Name, self.close.Position, self.close.Size = "Close", UDim2.fromOffset(PanelWidth - 52, 14), UDim2.fromOffset(36, 36)
    self.close.TextColor3, self.close.TextSize = Theme.Text, 14

    local odds = E.box(panel, "Odds", UDim2.fromOffset(16, 70), UDim2.fromOffset(PanelWidth - 32, 136), Theme.Card, 14)
    for index, rarity in ipairs(PetConfig.RarityOrder) do
        local y = 8 + (index - 1) * 24
        local chance = E.label(odds, "", 22, PetText.color(rarity))
        chance.Name, chance.Position, chance.Size = rarity, UDim2.fromOffset(12, y), UDim2.fromOffset(112, 22)
        chance.Font, chance.TextSize = Enum.Font.GothamBold, 12
        E.fit(chance, 8, 12)
        local names = E.label(odds, "", 22, Theme.Muted)
        names.Name, names.Position, names.Size, names.TextSize = rarity .. "Pets", UDim2.fromOffset(126, y), UDim2.fromOffset(PanelWidth - 32 - 138, 22), 10
        E.fit(names, 7, 10)
        self.odds[rarity] = { chance = chance, names = names }
    end

    local result = E.box(panel, "Result", UDim2.fromOffset(16, 216), UDim2.fromOffset(PanelWidth - 32, 64), Theme.Card, 14)
    self.resultName = E.label(result, "Spin to get a Fry Buddy!", 26, Theme.Text)
    self.resultName.Name, self.resultName.Position, self.resultName.Size = "PetName", UDim2.fromOffset(14, 8), UDim2.fromOffset(PanelWidth - 60, 26)
    self.resultName.Font, self.resultName.TextSize = Enum.Font.GothamBold, 17
    E.fit(self.resultName, 9, 17)
    self.resultBonus = E.label(result, "Pets you win appear in PETS.", 18, Theme.Muted)
    self.resultBonus.Name, self.resultBonus.Position, self.resultBonus.Size, self.resultBonus.TextSize = "Bonus", UDim2.fromOffset(14, 36), UDim2.fromOffset(PanelWidth - 60, 18), 12

    self.count = E.label(panel, "", 16, Theme.Muted)
    self.count.Name, self.count.Position, self.count.Size, self.count.TextSize = "Count", UDim2.fromOffset(20, 290), UDim2.fromOffset(PanelWidth - 40, 16), 11
    self.spin = E.button(panel, "SPIN", function() self:spinOnce() end, Theme.Green)
    self.spin.Name, self.spin.Position, self.spin.Size = "Spin", UDim2.fromOffset(16, 312), UDim2.fromOffset(PanelWidth - 32, 48)
    self.spin.AutoButtonColor, self.spin.TextColor3, self.spin.TextSize = false, Theme.Ink, 16
    return self
end
function GachaView:setOpen(open) self.panel.Visible = open and self.hasStation end
function GachaView:toggle() if self.hasStation then self:setOpen(not self.panel.Visible) end end
function GachaView:spinOnce()
    if self.canSpin and self.panel.Visible and self.machineId then self.send("Spin", self.machineId) end
end
function GachaView:update(state)
    self.hasStation = state.hasStation
    self.button.Active, self.button.Selectable, self.button.AutoButtonColor = state.hasStation, state.hasStation, state.hasStation
    self.button.TextColor3 = if state.hasStation then Theme.Green else Theme.Muted
    if not state.hasStation then self.panel.Visible = false end
    local machine, pets = state.machine, state.pets
    if not machine or not pets then return end
    self.machineId = machine.id
    self.title.Text = string.upper(machine.name)
    local left = machine.pityEvery - machine.pity
    self.caption.Text = E.money(machine.price) .. " per spin  ·  " .. machine.pityRarity .. " or better within " .. left
        .. (if left == 1 then " spin" else " spins")
    for _, row in ipairs(machine.odds) do
        local view = self.odds[row.rarity]
        if view then
            view.chance.Text = string.upper(row.rarity) .. "  " .. E.number(row.chance * 100) .. "%"
            view.names.Text = table.concat(row.pets, ", ")
        end
    end
    local full = #pets.owned >= pets.max
    local affordable = state.profile.cash >= machine.price
    self.canSpin = state.hasStation and affordable and not full
    self.count.Text = "PETS " .. #pets.owned .. " / " .. pets.max .. (if full then "  ·  inventory full" else "")
    self.spin.Active, self.spin.Selectable = self.canSpin, self.canSpin
    self.spin.Text = if full then "INVENTORY FULL" elseif affordable then "SPIN  " .. E.money(machine.price) else "NEED " .. E.money(machine.price)
    self.spin.BackgroundColor3 = if self.canSpin then Theme.Green else Theme.Card
    self.spin.TextColor3 = if self.canSpin then Theme.Ink else Theme.Muted
    -- A new spin result names the pet in its rarity color.
    local spin = state.spin
    if spin and spin.serial ~= self.lastSerial then
        self.lastSerial = spin.serial
        for _, owned in ipairs(pets.owned) do
            if owned.id == spin.id then
                self.resultName.Text = "You got " .. owned.name .. "!"
                self.resultName.TextColor3 = PetText.color(owned.rarity)
                self.resultBonus.Text = string.upper(owned.rarity) .. "  ·  " .. PetText.bonus(owned.bonuses)
            end
        end
    end
end
function GachaView:resize(viewport)
    self.scale.Scale = math.min(1, (viewport.X - 32) / PanelWidth, (viewport.Y - 60 - 24) / PanelHeight)
end
return GachaView
