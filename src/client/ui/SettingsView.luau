-- Settings: a gear button beside Return to Counter and a panel of saved ON/OFF toggles.
-- The server saves each setting; this view only displays and requests changes.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Config = require(Shared.config.Settings)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local Icons = require(script.Parent.Icons)
local SettingsView = {}
SettingsView.__index = SettingsView
local PanelWidth, RowHeight = 350, 72
local PanelHeight = E.PanelTop + 16 + #Config.Order * (RowHeight + 10)
function SettingsView.new(gui, send)
    local self = setmetatable({ send = send, rows = {}, hasStation = true }, SettingsView)
    self.button = E.button(gui, "", function() self:toggle() end, Theme.Cream, 0)
    self.button.Name, self.button.Size = "SettingsButton", UDim2.fromOffset(48, 48)
    self.button:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 24)
    E.sticker(self.button, 4, 5)
    local gear = Icons.make(self.button, "settings", 30, Theme.Ink)
    gear.AnchorPoint, gear.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)

    local frame = E.panel(gui, "SettingsPanel", PanelWidth, PanelHeight, Theme.Ink)
    self.panel, self.scale, self.close = frame.panel, frame.scale, frame.close
    frame.title.Text, frame.caption.Text = "SETTINGS", "Saved to your profile"
    self.close.BackgroundColor3 = Theme.Red
    self.close.Activated:Connect(function() self:setOpen(false) end)
    for index, key in ipairs(Config.Order) do
        local row = E.card(self.panel, key, UDim2.fromOffset(16, E.PanelTop + 12 + (index - 1) * (RowHeight + 10)), UDim2.fromOffset(PanelWidth - 32, RowHeight))
        local name = E.label(row, Config.Names[key], 24, Theme.Ink)
        name.Name, name.Position, name.Size = "SettingName", UDim2.fromOffset(14, 8), UDim2.fromOffset(PanelWidth - 140, 24)
        name.Font, name.TextSize = Theme.Display, 16
        E.fit(name, 9, 16)
        local hint = E.label(row, Config.Hints[key], 32, Theme.Muted)
        hint.Name, hint.Position, hint.Size, hint.TextSize = "Hint", UDim2.fromOffset(14, 34), UDim2.fromOffset(PanelWidth - 140, 32), 11
        local switch = E.button(row, "", function() self.send("ToggleSetting", key) end, Theme.Green)
        switch.Name, switch.AnchorPoint, switch.Position, switch.Size = "Toggle", Vector2.new(1, 0.5), UDim2.new(1, -14, 0.5, -1), UDim2.fromOffset(72, 36)
        switch.TextSize, switch.AutoButtonColor = 16, false
        switch:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 18)
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
        switch.BackgroundColor3 = if on then Theme.Green else Theme.Chip
        switch.TextColor3 = if on then Theme.OnColor else Theme.Muted
    end
end
function SettingsView:resize(viewport)
    self.scale.Scale = math.min(1, (viewport.X - 32) / PanelWidth, (viewport.Y - 60 - 24) / PanelHeight)
end
return SettingsView
