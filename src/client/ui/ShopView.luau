-- Upgrade shop: an UPGRADES menu button and a panel with one row per gem upgrade track.
-- Rows display server-computed levels, values, and costs; the server decides purchases.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Upgrades = require(Shared.config.Upgrades)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local Icons = require(script.Parent.Icons)
local ShopView = {}
ShopView.__index = ShopView
ShopView.Accent = Theme.Orange
local PanelWidth, PanelHeight = 380, 350
local TrackIcons = { FriesPerClick = "upgrade-fries-per-click", MoneyPerFry = "upgrade-money-per-fry", BagCapacity = "upgrade-bag-capacity" }
local function describe(row)
    if row.id == "MoneyPerFry" then
        return string.format("$%.2f » $%.2f per fry", row.value, row.nextValue)
    elseif row.id == "FriesPerClick" then
        return E.number(row.value) .. " » " .. E.number(row.nextValue) .. " fries/click"
    end
    return E.number(row.value) .. " » " .. E.number(row.nextValue) .. " fries per bag"
end
function ShopView.new(gui, send)
    local self = setmetatable({ send = send, rows = {}, data = {}, hasStation = false }, ShopView)
    self.button = E.menuButton(gui, "UpgradesButton", "UPGRADES", "upgrades", ShopView.Accent, function() self:toggle() end)
    local frame = E.panel(gui, "UpgradeShop", PanelWidth, PanelHeight)
    self.panel, self.scale, self.close = frame.panel, frame.scale, frame.close
    frame.title.Text, frame.caption.Text = "UPGRADES", "Spend gems to boost your restaurant"
    self.close.Activated:Connect(function() self:setOpen(false) end)
    for index, id in ipairs(Upgrades.Order) do
        local row = E.card(self.panel, id, UDim2.fromOffset(16, E.PanelTop + 12 + (index - 1) * 88), UDim2.fromOffset(PanelWidth - 32, 78))
        local disc = E.box(row, "IconDisc", UDim2.fromOffset(12, 16), UDim2.fromOffset(46, 46), Theme.Cream, 23)
        Icons.make(disc, TrackIcons[id], 34, Theme.Ink, UDim2.fromOffset(6, 6))
        local name = E.label(row, Upgrades.Tracks[id].Name, 24, Theme.Ink)
        name.Name, name.Position, name.Size = "TrackName", UDim2.fromOffset(68, 8), UDim2.fromOffset(170, 24)
        name.Font, name.TextSize = Theme.Display, 17
        E.fit(name, 10, 17)
        local level = E.label(row, "LEVEL 0", 16, Theme.Muted)
        level.Name, level.Position, level.Size, level.TextSize = "Level", UDim2.fromOffset(68, 33), UDim2.fromOffset(170, 16), 12
        local value = E.label(row, "", 18, Theme.Accent)
        value.Name, value.Position, value.Size, value.TextSize = "Value", UDim2.fromOffset(68, 51), UDim2.fromOffset(176, 18), 13
        E.fit(value, 8, 13)
        local buy = E.button(row, "", function() self:buy(id) end, Theme.Gold)
        buy.Name, buy.Position, buy.Size = "Buy", UDim2.fromOffset(PanelWidth - 32 - 104, 17), UDim2.fromOffset(90, 42)
        buy.AutoButtonColor, buy.TextColor3 = false, Theme.Ink
        E.fit(buy, 9, 15)
        self.rows[id] = { level = level, value = value, buy = buy }
    end
    return self
end
function ShopView:setOpen(open)
    self.panel.Visible = open and self.hasStation
end
function ShopView:toggle()
    if self.hasStation then self:setOpen(not self.panel.Visible) end
end
function ShopView:buy(id)
    local data = self.data[id]
    if self.hasStation and data and data.affordable then self.send("Upgrade", id) end
end
function ShopView:update(state)
    self.hasStation = state.hasStation
    E.setMenuEnabled(self.button, state.hasStation, ShopView.Accent)
    if not state.hasStation then self.panel.Visible = false end
    for _, row in ipairs(state.shop or {}) do
        local view = self.rows[row.id]
        if view then
            local affordable = state.hasStation and (state.profile.gems or 0) >= row.cost
            self.data[row.id] = { affordable = affordable }
            view.level.Text = "LEVEL " .. row.level
            view.value.Text = describe(row)
            view.buy.Text = E.count(row.cost) .. (if row.cost == 1 then " GEM" else " GEMS")
            view.buy.TextSize = if #view.buy.Text > 10 then 11 else 14
            view.buy.Active, view.buy.Selectable = affordable, affordable
            view.buy.BackgroundColor3 = if affordable then Theme.Gold else Theme.Disabled
            view.buy.TextColor3 = if affordable then Theme.Ink else Theme.Muted
        end
    end
end
-- AppView places the button; the panel scales to fit the screen.
function ShopView:resize(viewport)
    self.scale.Scale = math.min(1, (viewport.X - 32) / PanelWidth, (viewport.Y - 60 - 24) / PanelHeight)
end
return ShopView
