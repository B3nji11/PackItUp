-- EXPAND: opens at the kiosk in the player's restaurant and shows the next restaurant tier, the
-- machine it adds (with its top pet as a live portrait), and the Cash price. The server checks
-- the kiosk distance and the price and raises the tier; this view only displays and requests.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local PetConfig = require(Shared.config.Pets)
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local PetPortrait = require(script.Parent.PetPortrait)
local RestaurantView = {}
RestaurantView.__index = RestaurantView
local PanelWidth, PanelHeight = 380, 372
function RestaurantView.new(gui, send)
    local self = setmetatable({ send = send, hasStation = false, ready = false }, RestaurantView)
    local frame = E.panel(gui, "RestaurantPanel", PanelWidth, PanelHeight, Theme.Gold)
    self.panel, self.scale, self.close, self.title, self.caption = frame.panel, frame.scale, frame.close, frame.title, frame.caption
    self.title.Text = "EXPAND"
    self.close.Activated:Connect(function() self:setOpen(false) end)

    local card = E.card(self.panel, "Next", UDim2.fromOffset(16, E.PanelTop + 10), UDim2.fromOffset(PanelWidth - 32, 206))
    self.card = card
    self.tierName = E.label(card, "", 34, Theme.Ink)
    self.tierName.Name, self.tierName.Position, self.tierName.Size = "TierName", UDim2.fromOffset(14, 10), UDim2.new(1, -28, 0, 34)
    self.tierName.Font, self.tierName.TextSize = Theme.Display, 28
    E.fit(self.tierName, 14, 28)
    self.tagline = E.label(card, "", 18, Theme.Muted)
    self.tagline.Name, self.tagline.Position, self.tagline.Size, self.tagline.TextSize = "Tagline", UDim2.fromOffset(14, 44), UDim2.new(1, -28, 0, 18), 13
    E.fit(self.tagline, 8, 13)
    E.dashes(card, "Divider", UDim2.fromOffset(14, 70), PanelWidth - 60)
    self.portrait = PetPortrait.make(card, "Portrait", UDim2.fromOffset(100, 100), UDim2.fromOffset(10, 82))
    self.adds = E.label(card, "", 22, Theme.Ink)
    self.adds.Name, self.adds.Position, self.adds.Size = "Adds", UDim2.fromOffset(118, 86), UDim2.new(1, -132, 0, 22)
    self.adds.Font, self.adds.TextSize = Theme.Display, 16
    E.fit(self.adds, 9, 16)
    self.spinPrice = E.label(card, "", 18, Theme.Accent)
    self.spinPrice.Name, self.spinPrice.Position, self.spinPrice.Size, self.spinPrice.TextSize = "SpinPrice", UDim2.fromOffset(118, 110), UDim2.new(1, -132, 0, 18), 13
    E.fit(self.spinPrice, 8, 13)
    self.topPet = E.label(card, "", 18, Theme.Muted)
    self.topPet.Name, self.topPet.Position, self.topPet.Size, self.topPet.TextSize = "TopPet", UDim2.fromOffset(118, 130), UDim2.new(1, -132, 0, 18), 12
    E.fit(self.topPet, 7, 12)
    local keeps = E.label(card, "Keeps every machine. Survives rebirth.", 18, Theme.Muted)
    keeps.Name, keeps.Position, keeps.Size, keeps.TextSize = "Keeps", UDim2.fromOffset(118, 158), UDim2.new(1, -132, 0, 32), 12
    keeps.TextWrapped = true

    self.confirm = E.button(self.panel, "EXPAND", function() self:expand() end, Theme.Green, 5)
    self.confirm.Name, self.confirm.Position, self.confirm.Size = "Confirm", UDim2.fromOffset(16, PanelHeight - 70), UDim2.fromOffset(PanelWidth - 37, 50)
    self.confirm.AutoButtonColor, self.confirm.TextColor3, self.confirm.TextSize = false, Theme.OnColor, 20
    self.confirmOutline = E.textStroke(self.confirm, Theme.Ink, 2)
    return self
end
function RestaurantView:setOpen(open) self.panel.Visible = open and self.hasStation end
function RestaurantView:toggle() if self.hasStation then self:setOpen(not self.panel.Visible) end end
function RestaurantView:expand()
    if self.hasStation and self.ready and self.panel.Visible then self.send("Expand") end
end
function RestaurantView:update(state)
    self.hasStation = state.hasStation
    if not state.hasStation then self.panel.Visible = false end
    -- Open at the kiosk, close on walking away.
    local near = state.hasStation and state.nearExpand == true
    if near ~= self.near then
        self.near = near
        self.panel.Visible = near
        if near then self.focusRequested = true end
    end
    local info = state.restaurant
    if not info then return end
    self.caption.Text = "Tier " .. info.tier .. " of " .. info.max .. "  ·  your " .. info.name
    local nextTier = info.nextTier
    if nextTier then
        self.tierName.Text = string.upper(nextTier.name)
        self.tagline.Text = nextTier.tagline
        self.adds.Text = "Adds the " .. string.upper(nextTier.machineName)
        self.spinPrice.Text = E.money(nextTier.spinPrice) .. " a spin  ·  8 new pets"
        PetPortrait.set(self.portrait, nextTier.legendary, false)
        local top = PetConfig.Types[nextTier.legendary]
        self.topPet.Text = "Top pet: " .. (if top then top.Name .. " (Legendary)" else "a new Legendary")
        self.portrait.Visible = true
    else
        self.tierName.Text = "FULLY UPGRADED"
        self.tagline.Text = "Your " .. info.name .. " is the finest on the plaza."
        self.adds.Text, self.spinPrice.Text, self.topPet.Text = "Every machine is unlocked", "", ""
        self.portrait.Visible = false
    end
    self.ready = state.hasStation and nextTier ~= nil and nextTier.affordable == true
    self.confirm.Active, self.confirm.Selectable = self.ready, self.ready
    self.confirm.Text = if not nextTier then "ALL UNLOCKED" elseif self.ready then "EXPAND  " .. E.money(nextTier.price)
        else "NEED " .. E.money(nextTier.price)
    self.confirm.BackgroundColor3 = if self.ready then Theme.Green else Theme.Disabled
    self.confirm.TextColor3 = if self.ready then Theme.OnColor else Theme.Muted
    self.confirmOutline.Enabled = self.ready
end
function RestaurantView:resize(viewport)
    self.scale.Scale = math.min(1, (viewport.X - 32) / PanelWidth, (viewport.Y - 60 - 24) / PanelHeight)
end
return RestaurantView
