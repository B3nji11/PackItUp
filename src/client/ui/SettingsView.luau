-- Settings: a gear button beside Return to Counter and a panel of saved ON/OFF toggles.
-- The server saves each setting; this view only displays and requests changes.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Config = require(Shared.config.Settings)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local SettingsView = {}
SettingsView.__index = SettingsView
local PanelWidth, PanelHeight, RowHeight = 340, 92 + #Config.Order * 76, 68
-- A code-built gear: four bars under a ring with a dark centre.
local function gear(parent)
    for index = 0, 3 do
        local tooth = E.box(parent, "Tooth" .. index, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(5, 24), Theme.Muted, 1)
        tooth.AnchorPoint, tooth.Rotation = Vector2.new(0.5, 0.5), index * 45
    end
    local ring = E.box(parent, "Ring", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(18, 18), Theme.Muted, 9)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    local hole = E.box(parent, "Hole", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(8, 8), Theme.Background, 4)
    hole.AnchorPoint = Vector2.new(0.5, 0.5)
end
function SettingsView.new(gui, send)
    local self = setmetatable({ send = send, rows = {}, hasStation = true }, SettingsView)
    self.button = E.button(gui, "", function() self:toggle() end, Theme.Background)
    self.button.Name, self.button.Size = "SettingsButton", UDim2.fromOffset(44, 44)
    E.stroke(self.button, Theme.Muted, 1.5, 0.4)
    gear(self.button)

    local panel = E.box(gui, "SettingsPanel", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(PanelWidth, PanelHeight), Theme.Background, 18)
    panel.AnchorPoint, panel.Visible, panel.ZIndex = Vector2.new(0.5, 0.5), false, 5
    E.stroke(panel, Theme.Muted, 2, 0.2)
    self.panel = panel
    self.scale = Instance.new("UIScale")
    self.scale.Parent = panel
    local title = E.label(panel, "SETTINGS", 28, Theme.Text)
    title.Name, title.Position, title.Size = "Title", UDim2.fromOffset(20, 14), UDim2.fromOffset(240, 28)
    title.Font, title.TextSize = Enum.Font.GothamBold, 21
    local caption = E.label(panel, "Saved to your profile", 16, Theme.Muted)
    caption.Position, caption.Size, caption.TextSize = UDim2.fromOffset(20, 42), UDim2.fromOffset(240, 16), 11
    self.close = E.button(panel, "X", function() self:setOpen(false) end, Theme.Card)
    self.close.Name, self.close.Position, self.close.Size = "Close", UDim2.fromOffset(PanelWidth - 52, 14), UDim2.fromOffset(36, 36)
    self.close.TextColor3, self.close.TextSize = Theme.Text, 14
    for index, key in ipairs(Config.Order) do
        local row = E.box(panel, key, UDim2.fromOffset(16, 70 + (index - 1) * (RowHeight + 8)), UDim2.fromOffset(PanelWidth - 32, RowHeight), Theme.Card, 14)
        local name = E.label(row, Config.Names[key], 22, Theme.Text)
        name.Name, name.Position, name.Size = "SettingName", UDim2.fromOffset(14, 8), UDim2.fromOffset(PanelWidth - 140, 22)
        name.Font, name.TextSize = Enum.Font.GothamBold, 14
        E.fit(name, 9, 14)
        local hint = E.label(row, Config.Hints[key], 30, Theme.Muted)
        hint.Name, hint.Position, hint.Size, hint.TextSize = "Hint", UDim2.fromOffset(14, 32), UDim2.fromOffset(PanelWidth - 140, 30), 10
        local switch = E.button(row, "", function() self.send("ToggleSetting", key) end, Theme.Green)
        switch.Name, switch.AnchorPoint, switch.Position, switch.Size = "Toggle", Vector2.new(1, 0.5), UDim2.new(1, -12, 0.5, 0), UDim2.fromOffset(76, 36)
        switch.TextSize, switch.AutoButtonColor = 13, false
        E.stroke(switch, Theme.Muted, 1.5, 0.4)
        self.rows[key] = switch
    end
    return self
end
function SettingsView:setOpen(open) self.panel.Visible = open end
function SettingsView:toggle() self:setOpen(not self.panel.Visible) end
function SettingsView:update(state)
    local values = state.settings or {}
    for key, switch in pairs(self.rows) do
        local on = values[key] ~= false
        switch.Text = if on then "ON" else "OFF"
        switch.BackgroundColor3 = if on then Theme.Green else Theme.Card
        switch.TextColor3 = if on then Theme.Ink else Theme.Muted
    end
end
function SettingsView:resize(viewport)
    self.scale.Scale = math.min(1, (viewport.X - 32) / PanelWidth, (viewport.Y - 60 - 24) / PanelHeight)
end
return SettingsView
