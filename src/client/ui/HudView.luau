local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Economy = require(Shared.config.Economy)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local HudView = {}
HudView.__index = HudView
local function action(parent, name, x, color, key, callback)
    local shadow = E.box(parent, name .. "Shadow", UDim2.fromOffset(x, 7), UDim2.fromOffset(190, 96), Theme.Shadow, 18)
    shadow.BackgroundTransparency = 0.18
    local button = E.button(parent, "", callback, color)
    button.Name, button.Position, button.Size = name, UDim2.fromOffset(x, 0), UDim2.fromOffset(190, 96)
    button.AutoButtonColor = false
    button:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 18)
    E.stroke(button, Theme.Text, 1.5, 0.65)
    local title = E.label(button, "", 34, Theme.Ink)
    title.Name, title.Position, title.Size = "Title", UDim2.fromOffset(48, 13), UDim2.fromOffset(136, 34)
    title.Font, title.TextSize = Enum.Font.GothamBold, 21
    local detail = E.label(button, "", 20, Theme.Ink)
    detail.Name, detail.Position, detail.Size, detail.TextSize = "Detail", UDim2.fromOffset(12, 50), UDim2.fromOffset(166, 20), 12
    local shortcut = E.label(button, key, 16, Theme.Ink)
    shortcut.Position, shortcut.Size, shortcut.TextSize = UDim2.fromOffset(168, 3), UDim2.fromOffset(18, 16), 10
    shortcut.TextXAlignment = Enum.TextXAlignment.Center
    return button, title, detail, shortcut
end
function HudView.new(parent, send)
    local self = setmetatable({ send = send, hovered = false }, HudView)
    local frame = Instance.new("Frame")
    frame.Name, frame.AnchorPoint = "Actions", Vector2.new(0.5, 1)
    frame.Position, frame.Size = UDim2.new(0.5, 0, 1, -22), UDim2.fromOffset(392, 104)
    frame.BackgroundTransparency, frame.Parent = 1, parent
    self.frame = frame
    self.scale = Instance.new("UIScale")
    self.scale.Parent = frame
    self.pack, self.packTitle, self.packDetail = action(frame, "Click", 0, Theme.Gold, "F", nil)
    self.sell, self.sellTitle, self.sellDetail, self.sellShortcut = action(frame, "Sell", 202, Theme.Card, "R", function() self:sellBag() end)
    -- Small code-built fry and bag symbols; no external texture assets.
    for n = 1, 3 do
        E.box(self.pack, "Fry" .. n, UDim2.fromOffset(14 + (n - 1) * 8, 15 - n % 2 * 3),
            UDim2.fromOffset(6, 27), Theme.Ink, 2)
    end
    E.box(self.sell, "BagIcon", UDim2.fromOffset(15, 18), UDim2.fromOffset(24, 28), Theme.Gold, 4)
    E.box(self.sell, "BagRim", UDim2.fromOffset(13, 16), UDim2.fromOffset(28, 5), Theme.GoldLight, 2)
    local track
    track, self.fill = E.bar(self.sell, Theme.Gold, 6)
    track.Position, track.Size, track.BackgroundColor3 = UDim2.fromOffset(12, 79), UDim2.fromOffset(166, 6), Theme.Background
    local hint = E.label(self.pack, "PACK FRIES", 14, Theme.Ink)
    hint.Position, hint.Size, hint.TextSize = UDim2.fromOffset(12, 76), UDim2.fromOffset(166, 14), 10
    local function hover(on)
        self.hovered = on
        if self.state then self:update(self.state) end
    end
    self.pack.MouseEnter:Connect(function() hover(true) end)
    self.pack.MouseLeave:Connect(function() hover(false) end)
    self.pack.SelectionGained:Connect(function() hover(true) end)
    self.pack.SelectionLost:Connect(function() hover(false) end)
    self.packTitle.Text, self.packDetail.Text = "LOADING", "YOUR RESTAURANT"
    self.sellTitle.Text, self.sellDetail.Text = "0 / 20", "FRIES IN BAG"
    self.sellTitle.TextColor3, self.sellDetail.TextColor3 = Theme.Text, Theme.Muted
    self.sellShortcut.TextColor3 = Theme.Muted
    self.pack.Active, self.sell.Active = false, false
    self.pack.Selectable, self.sell.Selectable = false, false
    return self
end
function HudView:sellBag()
    local state = self.state
    if state and state.hasStation and state.nearStation and state.profile.bag.fries >= Economy.Capacity then self.send("Sell") end
end
function HudView:update(state)
    self.state = state
    local bag = state.profile.bag
    local full = bag.fries >= Economy.Capacity
    local canPack = state.hasStation and state.nearStation and not full
    local canSell = state.hasStation and state.nearStation and full
    self.pack.Active, self.pack.Selectable = canPack, canPack
    self.sell.Active, self.sell.Selectable = canSell, canSell
    self.pack.BackgroundColor3 = if canPack and self.hovered then Theme.GoldLight else Theme.Gold
    self.packTitle.Text = if not state.hasStation then "CLAIM FIRST" elseif full then "BAG FULL"
        elseif not state.nearStation then "AT COUNTER" elseif self.hovered then "CLICK" else Economy.ClicksPerSecond .. " clicks/sec"
    self.packTitle.TextSize = if not state.hasStation then 17 else 21
    self.packDetail.Text = if not state.hasStation then "CLAIM AT THE ENTRANCE" elseif full then "SELL TO KEEP PACKING"
        elseif not state.nearStation then "RETURN TO COUNTER" elseif self.hovered then "TAP / HOLD TO PACK" else "+" .. state.stats.perClick .. " FRY PER CLICK"
    self.sellTitle.Text = if full then "SELL BAG" else math.floor(bag.fries) .. " / " .. Economy.Capacity
    self.sellDetail.Text = if not state.hasStation then "CLAIM A RESTAURANT"
        elseif full and not state.nearStation then "RETURN TO COUNTER"
        elseif full then "+" .. E.money(state.stats.saleValue) .. " CASH"
        else "FRIES IN BAG"
    self.sell.BackgroundColor3 = if canSell then Theme.Green else Theme.Card
    self.sellTitle.TextColor3 = if canSell then Theme.Ink else Theme.Text
    self.sellDetail.TextColor3 = if canSell then Theme.Ink else Theme.Muted
    self.sellShortcut.TextColor3 = if canSell then Theme.Ink else Theme.Muted
    self.fill.BackgroundColor3 = if full then Theme.Green else Theme.Gold
    self.fill.Size = UDim2.fromScale(bag.fries / Economy.Capacity, 1)
end
return HudView
