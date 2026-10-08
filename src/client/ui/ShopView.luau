-- Upgrade shop: an UPGRADES button and a panel with one row per Cash upgrade track.
-- Rows display server-computed levels, values, and costs; the server decides purchases.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Upgrades = require(Shared.config.Upgrades)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local ShopView = {}
ShopView.__index = ShopView
local PanelWidth, PanelHeight = 360, 322
local function describe(row)
    if row.id == "MoneyPerFry" then
        return string.format("$%.2f → $%.2f per fry", row.value, row.nextValue)
    elseif row.id == "FriesPerClick" then
        return row.value .. " → " .. row.nextValue .. " fries/click"
    end
    return row.value .. " → " .. row.nextValue .. " fries per bag"
end
function ShopView.new(gui, send)
    local self = setmetatable({ send = send, rows = {}, data = {}, hasStation = false }, ShopView)
    self.button = E.button(gui, "UPGRADES", function() self:toggle() end, Theme.Background)
    self.button.Name, self.button.TextSize, self.button.TextColor3 = "UpgradesButton", 13, Theme.Gold
    self.button.Size = UDim2.fromOffset(218, 44)
    E.stroke(self.button, Theme.Gold, 1.5, 0.3)

    local panel = E.box(gui, "UpgradeShop", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(PanelWidth, PanelHeight), Theme.Background, 18)
    panel.AnchorPoint, panel.Visible = Vector2.new(0.5, 0.5), false
    E.stroke(panel, Theme.Gold, 2, 0.12)
    self.panel = panel
    self.scale = Instance.new("UIScale")
    self.scale.Parent = panel
    local title = E.label(panel, "UPGRADES", 28, Theme.Text)
    title.Name, title.Position, title.Size = "Title", UDim2.fromOffset(20, 14), UDim2.fromOffset(250, 28)
    title.Font, title.TextSize = Enum.Font.GothamBold, 21
    local caption = E.label(panel, "Spend Cash to boost your restaurant", 16, Theme.Muted)
    caption.Position, caption.Size, caption.TextSize = UDim2.fromOffset(20, 42), UDim2.fromOffset(260, 16), 11
    self.close = E.button(panel, "X", function() self:setOpen(false) end, Theme.Card)
    self.close.Name, self.close.Position, self.close.Size = "Close", UDim2.fromOffset(PanelWidth - 52, 14), UDim2.fromOffset(36, 36)
    self.close.TextColor3, self.close.TextSize = Theme.Text, 14

    for index, id in ipairs(Upgrades.Order) do
        local row = E.box(panel, id, UDim2.fromOffset(16, 70 + (index - 1) * 82), UDim2.fromOffset(PanelWidth - 32, 74), Theme.Card, 14)
        local name = E.label(row, Upgrades.Tracks[id].Name, 22, Theme.Text)
        name.Name, name.Position, name.Size = "TrackName", UDim2.fromOffset(14, 8), UDim2.fromOffset(190, 22)
        name.Font, name.TextSize = Enum.Font.GothamBold, 15
        local level = E.label(row, "LEVEL 0", 16, Theme.Muted)
        level.Name, level.Position, level.Size, level.TextSize = "Level", UDim2.fromOffset(14, 30), UDim2.fromOffset(190, 16), 11
        local value = E.label(row, "", 18, Theme.GoldLight)
        value.Name, value.Position, value.Size, value.TextSize = "Value", UDim2.fromOffset(14, 48), UDim2.fromOffset(196, 18), 12
        value.TextWrapped = false
        local buy = E.button(row, "", function() self:buy(id) end, Theme.Gold)
        buy.Name, buy.Position, buy.Size = "Buy", UDim2.fromOffset(PanelWidth - 32 - 112, 15), UDim2.fromOffset(100, 44)
        buy.AutoButtonColor, buy.TextColor3 = false, Theme.Ink
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
    self.button.Active, self.button.Selectable, self.button.AutoButtonColor = state.hasStation, state.hasStation, state.hasStation
    self.button.TextColor3 = if state.hasStation then Theme.Gold else Theme.Muted
    if not state.hasStation then self.panel.Visible = false end
    for _, row in ipairs(state.shop or {}) do
        local view = self.rows[row.id]
        if view then
            local affordable = state.hasStation and state.profile.cash >= row.cost
            self.data[row.id] = { affordable = affordable }
            view.level.Text = "LEVEL " .. row.level
            view.value.Text = describe(row)
            view.buy.Text = E.money(row.cost)
            view.buy.TextSize = if #view.buy.Text > 9 then 12 else 16
            view.buy.Active, view.buy.Selectable = affordable, affordable
            view.buy.BackgroundColor3 = if affordable then Theme.Gold else Theme.Background
            view.buy.TextColor3 = if affordable then Theme.Ink else Theme.Muted
        end
    end
end
-- `compact` short landscape screens put the button top right; otherwise it sits below Cash.
function ShopView:resize(viewport, compact, cashWidth, cashOffset)
    if compact then
        self.button.AnchorPoint = Vector2.new(1, 0)
        self.button.Position, self.button.Size = UDim2.new(1, -16, 0, 16), UDim2.fromOffset(112, 44)
    else
        self.button.AnchorPoint = Vector2.new(0, 0)
        self.button.Position, self.button.Size = UDim2.new(0, 16, 0.5, cashOffset + 38 + 10), UDim2.fromOffset(cashWidth, 44)
    end
    self.scale.Scale = math.min(1, (viewport.X - 32) / PanelWidth, (viewport.Y - 60 - 24) / PanelHeight)
end
ShopView.ButtonGap, ShopView.ButtonHeight = 10, 44
return ShopView
