-- Rebirth: a REBIRTH menu button and a confirmation panel. The server checks the threshold,
-- resets Cash and the bag, and awards gems; this view only displays and requests.
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local Icons = require(script.Parent.Icons)
local RebirthView = {}
RebirthView.__index = RebirthView
RebirthView.Accent = Theme.Gem
local PanelWidth, PanelHeight = 360, 344
function RebirthView.new(gui, send)
    local self = setmetatable({ send = send, hasStation = false, ready = false, count = nil }, RebirthView)
    self.button = E.menuButton(gui, "RebirthButton", "REBIRTH", "rebirth", RebirthView.Accent, function() self:toggle() end)
    local frame = E.panel(gui, "RebirthPanel", PanelWidth, PanelHeight, Theme.Gem)
    self.panel, self.scale, self.close = frame.panel, frame.scale, frame.close
    frame.title.Text, frame.caption.Text = "REBIRTH", "Trade your Cash for gems"
    self.close.Activated:Connect(function() self:setOpen(false) end)

    local card = E.card(self.panel, "Details", UDim2.fromOffset(16, E.PanelTop + 10), UDim2.fromOffset(PanelWidth - 32, 180))
    local gem = Icons.make(card, "gem", 40, Theme.Gem, UDim2.fromOffset(14, 10))
    gem.Name = "GemIcon"
    self.reward = E.label(card, "+10 GEMS", 40, Theme.Gem)
    self.reward.Name, self.reward.Position, self.reward.Size = "Reward", UDim2.fromOffset(62, 10), UDim2.fromOffset(PanelWidth - 108, 40)
    self.reward.Font, self.reward.TextSize = Theme.Display, 30
    E.fit(self.reward, 14, 30)
    self.need = E.label(card, "", 18, Theme.Ink)
    self.need.Name, self.need.Position, self.need.Size, self.need.TextSize = "Need", UDim2.fromOffset(14, 58), UDim2.fromOffset(PanelWidth - 60, 18), 13
    E.fit(self.need, 8, 13)
    local track
    track, self.fill = E.bar(card, Theme.Gem, 10)
    track.Name, track.Position, track.Size = "Progress", UDim2.fromOffset(14, 82), UDim2.fromOffset(PanelWidth - 60, 10)
    E.dashes(card, "Divider", UDim2.fromOffset(14, 104), PanelWidth - 60)
    local resets = E.label(card, "Resets: your Cash and current bag", 16, Theme.Muted)
    resets.Name, resets.Position, resets.Size, resets.TextSize = "Resets", UDim2.fromOffset(14, 112), UDim2.fromOffset(PanelWidth - 60, 16), 12
    local keeps = E.label(card, "Keeps: gems, upgrades, pets, and rebirth count", 16, Theme.Muted)
    keeps.Name, keeps.Position, keeps.Size, keeps.TextSize = "Keeps", UDim2.fromOffset(14, 130), UDim2.fromOffset(PanelWidth - 60, 16), 12
    E.fit(keeps, 8, 12)
    self.countLabel = E.label(card, "REBIRTHS: 0", 16, Theme.Ink)
    self.countLabel.Name, self.countLabel.Position, self.countLabel.Size = "Count", UDim2.fromOffset(14, 154), UDim2.fromOffset(PanelWidth - 60, 16)
    self.countLabel.Font, self.countLabel.TextSize = Theme.Display, 12

    self.confirm = E.button(self.panel, "REBIRTH", function() self:rebirth() end, Theme.Green, 5)
    self.confirm.Name, self.confirm.Position, self.confirm.Size = "Confirm", UDim2.fromOffset(16, PanelHeight - 70), UDim2.fromOffset(PanelWidth - 37, 50)
    self.confirm.AutoButtonColor, self.confirm.TextColor3, self.confirm.TextSize = false, Theme.OnColor, 20
    self.confirmOutline = E.textStroke(self.confirm, Theme.Ink, 2)
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
    E.setMenuEnabled(self.button, state.hasStation, RebirthView.Accent)
    if not state.hasStation then self.panel.Visible = false end
    if not info then return end
    -- A completed rebirth closes the panel; the Cash and Gems card shows the result.
    if self.count and info.count > self.count then self.panel.Visible = false end
    self.count = info.count
    self.ready = state.hasStation and state.profile.cash >= info.threshold
    self.button.Badge.Visible = self.ready -- "!" when a rebirth is available
    self.reward.Text = "+" .. E.count(info.reward) .. " GEMS"
    self.need.Text = "Needs " .. E.money(info.threshold) .. " Cash  (you have " .. E.money(state.profile.cash) .. ")"
    self.fill.Size = UDim2.fromScale(math.clamp(state.profile.cash / info.threshold, 0, 1), 1)
    self.countLabel.Text = "REBIRTHS: " .. E.count(info.count)
    self.confirm.Active, self.confirm.Selectable = self.ready, self.ready
    self.confirm.Text = if self.ready then "REBIRTH NOW" else "NEED " .. E.money(info.threshold)
    self.confirm.BackgroundColor3 = if self.ready then Theme.Green else Theme.Disabled
    self.confirm.TextColor3 = if self.ready then Theme.OnColor else Theme.Muted
    self.confirmOutline.Enabled = self.ready
end
function RebirthView:resize(viewport)
    self.scale.Scale = math.min(1, (viewport.X - 32) / PanelWidth, (viewport.Y - 60 - 24) / PanelHeight)
end
return RebirthView
