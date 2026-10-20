-- Pack and Sell: two big Diner Sticker buttons at the bottom centre.
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local Icons = require(script.Parent.Icons)
local HudView = {}
HudView.__index = HudView
-- Two 232 x 104 buttons, a 14 px gap, and the 7 px sticker shadow. Wide enough that
-- Luckiest Guy titles such as "CLAIM FIRST" fit with room to spare.
local ButtonWidth, ButtonHeight, Shadow, Gap = 232, 104, 7, 14
HudView.Width, HudView.Height = ButtonWidth * 2 + Gap + Shadow, ButtonHeight + Shadow + 1
local TextLeft, TextWidth = 72, ButtonWidth - 72 - 16
local function action(parent, name, x, color, key, icon, callback)
    local button = E.button(parent, "", callback, color, 0)
    button.Name, button.Position, button.Size = name, UDim2.fromOffset(x, 0), UDim2.fromOffset(ButtonWidth, ButtonHeight)
    button.AutoButtonColor = false
    button:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 26)
    E.stroke(button, Theme.White, 5, 0)
    E.shadow(button, Shadow)
    local disc = E.box(button, "IconDisc", UDim2.fromOffset(12, 26), UDim2.fromOffset(50, 50), Theme.Cream, 25)
    Icons.make(disc, icon, 36, Theme.Ink, UDim2.fromOffset(7, 7))
    local title = E.label(button, "", 36, Theme.Ink)
    title.Name, title.Position, title.Size = "Title", UDim2.fromOffset(TextLeft, 20), UDim2.fromOffset(TextWidth, 34)
    title.Font, title.TextSize = Theme.Display, 23
    E.fit(title, 10, 23)
    local outline = E.textStroke(title, Theme.Ink, 2)
    outline.Enabled = false
    local detail = E.label(button, "", 18, Theme.Ink)
    detail.Name, detail.Position, detail.Size, detail.TextSize = "Detail", UDim2.fromOffset(TextLeft, 58), UDim2.fromOffset(TextWidth, 18), 12
    E.fit(detail, 8, 12)
    local shortcut = E.label(button, key, 18, Theme.Ink)
    shortcut.Name, shortcut.Position, shortcut.Size, shortcut.TextSize = "Key", UDim2.fromOffset(ButtonWidth - 26, 4), UDim2.fromOffset(18, 16), 11
    shortcut.TextXAlignment, shortcut.Font = Enum.TextXAlignment.Center, Theme.Display
    return button, title, detail, shortcut, outline
end
function HudView.new(parent, send)
    local self = setmetatable({ send = send, hovered = false }, HudView)
    local frame = Instance.new("Frame")
    frame.Name, frame.AnchorPoint = "Actions", Vector2.new(0.5, 1)
    frame.Position, frame.Size = UDim2.new(0.5, 0, 1, -22), UDim2.fromOffset(HudView.Width, HudView.Height)
    frame.BackgroundTransparency, frame.Parent = 1, parent
    self.frame = frame
    self.scale = Instance.new("UIScale")
    self.scale.Parent = frame
    self.pack, self.packTitle, self.packDetail, self.packKey = action(frame, "Click", 0, Theme.Gold, "F", "fries", nil)
    self.sell, self.sellTitle, self.sellDetail, self.sellKey, self.sellOutline =
        action(frame, "Sell", ButtonWidth + Gap, Theme.Cream, "R", "bag", function() self:sellBag() end)
    local track
    track, self.fill = E.bar(self.sell, Theme.Gold, 8)
    track.Name, track.Position, track.Size = "Progress", UDim2.fromOffset(TextLeft, 82), UDim2.fromOffset(TextWidth - 4, 8)
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
    self.pack.Active, self.sell.Active = false, false
    self.pack.Selectable, self.sell.Selectable = false, false
    return self
end
function HudView:sellBag()
    local state = self.state
    if state and state.hasStation and state.nearStation and state.profile.bag.fries >= state.stats.capacity then self.send("Sell") end
end
function HudView:update(state)
    self.state = state
    local bag = state.profile.bag
    local capacity = state.stats.capacity
    local full = bag.fries >= capacity
    local canPack = state.hasStation and state.nearStation and not full
    local canSell = state.hasStation and state.nearStation and full
    local perClick = state.stats.perClick
    local yieldText = "+" .. E.number(perClick) .. (if perClick == 1 then " fry/click" else " fries/click")
    self.pack.Active, self.pack.Selectable = canPack, canPack
    self.sell.Active, self.sell.Selectable = canSell, canSell
    self.pack.BackgroundColor3 = if not canPack then Theme.Disabled elseif self.hovered then Theme.GoldLight else Theme.Gold
    self.packTitle.Text = if not state.hasStation then "CLAIM FIRST" elseif full then "BAG FULL"
        elseif not state.nearStation then "AT COUNTER" elseif self.hovered then "CLICK" else yieldText
    self.packDetail.Text = if not state.hasStation then "CLAIM AT THE ENTRANCE" elseif full then "SELL TO KEEP PACKING"
        elseif not state.nearStation then "RETURN TO COUNTER" elseif self.hovered then string.upper(yieldText) else "TAP / HOLD TO PACK"
    self.sellTitle.Text = if full then "SELL BAG" else math.floor(bag.fries) .. " / " .. capacity
    self.sellDetail.Text = if not state.hasStation then "CLAIM A RESTAURANT"
        elseif full and not state.nearStation then "RETURN TO COUNTER"
        elseif full then "+" .. E.money(state.stats.saleValue) .. " CASH"
        else "FRIES IN BAG"
    -- Ready to sell: teal with white outlined text; otherwise cream with ink text.
    self.sell.BackgroundColor3 = if canSell then Theme.Green else Theme.Cream
    self.sellTitle.TextColor3 = if canSell then Theme.OnColor else Theme.Ink
    self.sellOutline.Enabled = canSell
    self.sellDetail.TextColor3 = if canSell then Theme.OnColor else Theme.Muted
    self.sellKey.TextColor3 = if canSell then Theme.OnColor else Theme.Muted
    self.fill.Parent.Visible = not full
    self.fill.BackgroundColor3 = Theme.Gold
    self.fill.Size = UDim2.fromScale(math.clamp(bag.fries / capacity, 0, 1), 1)
end
return HudView
