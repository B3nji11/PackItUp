-- Rebirth: a REBIRTH button and a confirmation panel. The server checks the threshold,
-- resets Cash and the bag, and awards gems; this view only displays and requests.
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local RebirthView = {}
RebirthView.__index = RebirthView
local PanelWidth, PanelHeight = 340, 312
local function line(parent, name, text, y, height, color, size)
    local label = E.label(parent, text, height, color)
    label.Name, label.Position, label.Size, label.TextSize = name, UDim2.fromOffset(20, y), UDim2.fromOffset(PanelWidth - 40, height), size
    return label
end
function RebirthView.new(gui, send)
    local self = setmetatable({ send = send, hasStation = false, ready = false, count = nil }, RebirthView)
    self.button = E.button(gui, "REBIRTH", function() self:toggle() end, Theme.Background)
    self.button.Name, self.button.TextSize, self.button.TextColor3 = "RebirthButton", 13, Theme.Gem
    self.button.Size = UDim2.fromOffset(105, 44)
    self.buttonStroke = E.stroke(self.button, Theme.Gem, 1.5, 0.3)

    local panel = E.box(gui, "RebirthPanel", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(PanelWidth, PanelHeight), Theme.Background, 18)
    panel.AnchorPoint, panel.Visible = Vector2.new(0.5, 0.5), false
    panel.ZIndex = 5 -- above the HUD buttons when open
    E.stroke(panel, Theme.Gem, 2, 0.12)
    self.panel = panel
    self.scale = Instance.new("UIScale")
    self.scale.Parent = panel
    local title = line(panel, "Title", "REBIRTH", 14, 28, Theme.Text, 21)
    title.Font, title.Size = Enum.Font.GothamBold, UDim2.fromOffset(240, 28)
    local caption = line(panel, "Caption", "Trade your Cash for gems", 42, 16, Theme.Muted, 11)
    caption.Size = UDim2.fromOffset(240, 16)
    self.close = E.button(panel, "X", function() self:setOpen(false) end, Theme.Card)
    self.close.Name, self.close.Position, self.close.Size = "Close", UDim2.fromOffset(PanelWidth - 52, 14), UDim2.fromOffset(36, 36)
    self.close.TextColor3, self.close.TextSize = Theme.Text, 14

    local card = E.box(panel, "Details", UDim2.fromOffset(16, 70), UDim2.fromOffset(PanelWidth - 32, 164), Theme.Card, 14)
    self.reward = E.label(card, "+10 GEMS", 32, Theme.Gem)
    self.reward.Name, self.reward.Position, self.reward.Size = "Reward", UDim2.fromOffset(14, 8), UDim2.fromOffset(PanelWidth - 60, 32)
    self.reward.Font, self.reward.TextSize = Enum.Font.GothamBold, 24
    self.need = E.label(card, "", 18, Theme.Text)
    self.need.Name, self.need.Position, self.need.Size, self.need.TextSize = "Need", UDim2.fromOffset(14, 44), UDim2.fromOffset(PanelWidth - 60, 18), 13
    -- Large amounts shrink to one line instead of wrapping out of the card.
    self.need.TextScaled, self.need.TextWrapped = true, false
    local fit = Instance.new("UITextSizeConstraint")
    fit.MinTextSize, fit.MaxTextSize, fit.Parent = 8, 13, self.need
    local track
    track, self.fill = E.bar(card, Theme.Gem, 8)
    track.Position, track.Size, track.BackgroundColor3 = UDim2.fromOffset(14, 66), UDim2.fromOffset(PanelWidth - 60, 8), Theme.Background
    local resets = E.label(card, "Resets: your Cash and current bag", 16, Theme.Muted)
    resets.Name, resets.Position, resets.Size, resets.TextSize = "Resets", UDim2.fromOffset(14, 88), UDim2.fromOffset(PanelWidth - 60, 16), 12
    local keeps = E.label(card, "Keeps: gems, upgrades, and rebirth count", 16, Theme.Muted)
    keeps.Name, keeps.Position, keeps.Size, keeps.TextSize = "Keeps", UDim2.fromOffset(14, 108), UDim2.fromOffset(PanelWidth - 60, 16), 12
    self.countLabel = E.label(card, "REBIRTHS: 0", 16, Theme.Muted)
    self.countLabel.Name, self.countLabel.Position, self.countLabel.Size = "Count", UDim2.fromOffset(14, 136), UDim2.fromOffset(PanelWidth - 60, 16)
    self.countLabel.TextSize = 11

    self.confirm = E.button(panel, "REBIRTH", function() self:rebirth() end, Theme.Green)
    self.confirm.Name, self.confirm.Position, self.confirm.Size = "Confirm", UDim2.fromOffset(16, 248), UDim2.fromOffset(PanelWidth - 32, 48)
    self.confirm.AutoButtonColor, self.confirm.TextColor3, self.confirm.TextSize = false, Theme.Ink, 16
    return self
end
function RebirthView:setOpen(open) self.panel.Visible = open and self.hasStation end
function RebirthView:toggle() if self.hasStation then self:setOpen(not self.panel.Visible) end end
function RebirthView:rebirth()
    if self.hasStation and self.ready and self.panel.Visible then self.send("Rebirth") end
end
function RebirthView:update(state)
    local info = state.rebirth
    self.hasStation = state.hasStation
    self.button.Active, self.button.Selectable, self.button.AutoButtonColor = state.hasStation, state.hasStation, state.hasStation
    if not state.hasStation then self.panel.Visible = false end
    if not info then return end
    -- A completed rebirth closes the panel; the Cash and Gems card shows the result.
    if self.count and info.count > self.count then self.panel.Visible = false end
    self.count = info.count
    self.ready = state.hasStation and state.profile.cash >= info.threshold
    local glow = self.ready
    self.button.BackgroundColor3 = if glow then Theme.Gem else Theme.Background
    self.button.TextColor3 = if glow then Theme.Ink elseif state.hasStation then Theme.Gem else Theme.Muted
    self.reward.Text = "+" .. E.count(info.reward) .. " GEMS"
    self.need.Text = "Needs " .. E.money(info.threshold) .. " Cash  (you have " .. E.money(state.profile.cash) .. ")"
    self.fill.Size = UDim2.fromScale(math.clamp(state.profile.cash / info.threshold, 0, 1), 1)
    self.countLabel.Text = "REBIRTHS: " .. E.count(info.count)
    self.confirm.Active, self.confirm.Selectable = self.ready, self.ready
    self.confirm.Text = if self.ready then "REBIRTH NOW" else "NEED " .. E.money(info.threshold)
    self.confirm.BackgroundColor3 = if self.ready then Theme.Green else Theme.Card
    self.confirm.TextColor3 = if self.ready then Theme.Ink else Theme.Muted
end
function RebirthView:resize(viewport)
    self.scale.Scale = math.min(1, (viewport.X - 32) / PanelWidth, (viewport.Y - 60 - 24) / PanelHeight)
end
return RebirthView
