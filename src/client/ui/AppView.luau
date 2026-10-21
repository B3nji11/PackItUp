-- Screen layout in the Diner Sticker style: a receipt-style wallet (Cash and Gems) at the top
-- left, the menu below it (labelled pills, or labelled tiles on short screens), Return
-- to Counter and Settings at the top, guidance above Pack and Sell at the bottom centre.
local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local Icons = require(script.Parent.Icons)
local HudView = require(script.Parent.HudView)
local ShopView = require(script.Parent.ShopView)
local RebirthView = require(script.Parent.RebirthView)
local GachaView = require(script.Parent.GachaView)
local PetsView = require(script.Parent.PetsView)
local SettingsView = require(script.Parent.SettingsView)
local RestaurantView = require(script.Parent.RestaurantView)
local AppView = {}
AppView.__index = AppView
local Margin, TopBar = 16, 48
function AppView.new(playerGui, send)
    local self = setmetatable({}, AppView)
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior = "FriesInterface", false, Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui
    -- Wallet: a cream receipt card with a coin row, a dashed divider, and a gem row.
    self.cashCard = E.box(gui, "CashCard", UDim2.fromOffset(Margin, 12), UDim2.fromOffset(220, 112), Theme.Cream, 20)
    self.cashCard.AnchorPoint = Vector2.new(0, 0)
    E.sticker(self.cashCard, 4, 6)
    local coin = Icons.make(self.cashCard, "cash", 40, Theme.Ink, UDim2.fromOffset(12, 10))
    coin.Name = "Coin"
    self.wallet = E.label(self.cashCard, "$0", 40, Theme.Ink)
    self.wallet.Name, self.wallet.Position, self.wallet.Size = "Cash", UDim2.fromOffset(60, 10), UDim2.new(1, -72, 0, 40)
    self.wallet.Font, self.wallet.TextSize = Theme.Display, 30
    E.fit(self.wallet, 12, 30)
    self.divider = E.dashes(self.cashCard, "Divider", UDim2.fromOffset(12, 56), 196)
    local gem = Icons.make(self.cashCard, "gem", 36, Theme.Gem, UDim2.fromOffset(14, 64))
    gem.Name = "GemIcon"
    self.gems = E.label(self.cashCard, "0", 36, Theme.Ink)
    self.gems.Name, self.gems.Position, self.gems.Size = "Gems", UDim2.fromOffset(60, 64), UDim2.new(1, -124, 0, 36)
    self.gems.Font, self.gems.TextSize = Theme.Display, 26
    E.fit(self.gems, 10, 26)
    local gemCaption = E.label(self.cashCard, "GEMS", 18, Theme.Muted)
    gemCaption.Name, gemCaption.AnchorPoint = "GemCaption", Vector2.new(1, 0)
    gemCaption.Position, gemCaption.Size, gemCaption.TextSize = UDim2.new(1, -12, 0, 74), UDim2.fromOffset(52, 18), 13
    gemCaption.TextXAlignment = Enum.TextXAlignment.Right
    -- Studio-only label in the bottom-left corner, below every control.
    self.mode = E.label(gui, "", 16, Theme.Ink)
    self.mode.Name, self.mode.Position, self.mode.Size, self.mode.TextSize = "Mode", UDim2.new(0, Margin, 1, -21), UDim2.fromOffset(220, 15), 11
    -- Return to Counter: a ketchup sticker pill with a home icon.
    self.teleport = E.button(gui, "RETURN TO COUNTER", function()
        if self.hasStation then send("Return") end
    end, Theme.Red, 0)
    self.teleport.Name, self.teleport.TextColor3, self.teleport.TextSize = "Teleport", Theme.OnColor, 16
    self.teleport:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 24)
    E.sticker(self.teleport, 4, 5)
    E.textStroke(self.teleport, Theme.Ink, 2)
    E.fit(self.teleport, 9, 16)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft, padding.PaddingRight, padding.Parent = UDim.new(0, 44), UDim.new(0, 12), self.teleport
    local home = Icons.make(self.teleport, "home", 26, Theme.White, UDim2.new(0, -32, 0.5, -13))
    home.Name = "HomeIcon"
    -- Guidance and errors: a cream sticker strip.
    self.guidance = E.label(gui, "", 48, Theme.Ink)
    self.guidance.Name, self.guidance.AnchorPoint = "Guidance", Vector2.new(0.5, 0)
    self.guidance.TextXAlignment, self.guidance.TextSize = Enum.TextXAlignment.Center, 14
    self.guidance.BackgroundColor3, self.guidance.BackgroundTransparency = Theme.Cream, 0
    E.corner(self.guidance, 16)
    E.stroke(self.guidance, Theme.White, 3, 0)
    self.hud = HudView.new(gui, send)
    self.shop = ShopView.new(gui, send)
    self.rebirth = RebirthView.new(gui, send)
    self.gacha = GachaView.new(gui, send)
    self.pets = PetsView.new(gui, send)
    -- Menu order: Upgrades, Rebirth, Spin, Pets.
    self.menus = { self.shop, self.rebirth, self.gacha, self.pets }
    self.settings = SettingsView.new(gui, send)
    -- The EXPAND panel has no menu button: it opens at the kiosk in the restaurant.
    self.restaurant = RestaurantView.new(gui, send)
    -- Opening one panel closes the others so they never stack.
    self.panels = { self.shop, self.rebirth, self.gacha, self.pets, self.settings, self.restaurant }
    for _, menu in ipairs(self.panels) do
        if menu.button then menu.button.Activated:Connect(function()
            if not menu.panel.Visible then return end
            for _, other in ipairs(self.panels) do if other ~= menu then other:setOpen(false) end end
        end) end
    end
    self:resize(Vector2.new(1280, 720))
    return self
end
function AppView:update(state)
    self.hasStation = state.hasStation
    self.wallet.Text = E.money(state.profile.cash)
    self.gems.Text = E.count(state.profile.gems or 0)
    self.mode.Text = if state.volatile then "STUDIO TEST / resets on stop" else ""
    self.teleport.Active, self.teleport.Selectable = state.hasStation, state.hasStation
    self.teleport.Text = if state.hasStation then "RETURN TO COUNTER" else "CHOOSE A RESTAURANT"
    self.teleport.AutoButtonColor = state.hasStation
    self.teleport.BackgroundColor3 = if state.hasStation then Theme.Red else Theme.Muted
    if not self.errorUntil or os.clock() >= self.errorUntil then
        local nextTier = state.restaurant and state.restaurant.nextTier
        local canExpand = state.hasStation and nextTier ~= nil and nextTier.affordable and not state.nearExpand
        self.guidance.Visible = not state.hasStation or canExpand
        self.guidance.Text = if canExpand then "You can afford the " .. nextTier.name .. "! Walk to the EXPAND kiosk inside your restaurant."
            else "Follow an AVAILABLE arrow. Press E or tap the entrance prompt to claim."
        self.guidance.TextColor3 = Theme.Ink
    end
    self.hud:update(state)
    for _, menu in ipairs(self.panels) do menu:update(state) end
    -- A panel that opened itself (walking up to a stand or the kiosk) closes the others.
    for _, menu in ipairs(self.panels) do
        if menu.focusRequested then
            menu.focusRequested = nil
            for _, other in ipairs(self.panels) do if other ~= menu then other:setOpen(false) end end
        end
    end
end
function AppView:notice(text, success)
    -- Sales are acknowledged by the wallet and bag reset, without a bottom toast.
    if success then return end
    self.errorUntil = os.clock() + 4
    self.guidance.Visible, self.guidance.Text, self.guidance.TextColor3 = true, text, Theme.Red
end
function AppView:resize(viewport)
    if self.viewportX == viewport.X and self.viewportY == viewport.Y then return end
    self.viewportX, self.viewportY = viewport.X, viewport.Y
    local width, height = viewport.X, viewport.Y - 60
    local portrait = viewport.X < 760 and viewport.Y >= 500
    local short = viewport.Y < 500
    local compact = viewport.X < 760 and short
    -- Wallet, top left.
    local cardWidth, cardHeight = if compact then 184 else 220, if compact then 100 else 112
    self.cashCard.Size = UDim2.fromOffset(cardWidth, cardHeight)
    self.divider.Position = UDim2.fromOffset(12, if compact then 50 else 56)
    self.divider.Size = UDim2.fromOffset(cardWidth - 24, 3)
    local walletRight = Margin + cardWidth
    local teleportWidth = if compact then 150 elseif portrait then math.min(220, width - Margin * 2 - TopBar - 10) else 220
    local groupWidth = teleportWidth + 10 + TopBar
    local groupLeft, groupTop, guidanceLeft, guidanceRight, guidanceTop, guidanceHeight, menuTop, menuMode
    local hudScale = math.min(1, (width - 24) / HudView.Width)
    if short then
        -- Short screens: labelled tiles in a row at the top right, the top bar under them,
        -- guidance between the wallet and the tiles, and Pack and Sell scaled to fit below.
        local tileWidth, tileHeight, tileGap = 58, 64, 6
        local tilesLeft = width - Margin - #self.menus * tileWidth - (#self.menus - 1) * tileGap
        for index, menu in ipairs(self.menus) do
            E.setMenuMode(menu.button, "tile", tileWidth, tileHeight)
            menu.button.AnchorPoint = Vector2.new(0, 0)
            menu.button.Position = UDim2.fromOffset(tilesLeft + (index - 1) * (tileWidth + tileGap), 12)
        end
        groupLeft, groupTop = width - Margin - groupWidth, 12 + tileHeight + 12
        guidanceLeft, guidanceRight = walletRight + 18, math.min(tilesLeft, groupLeft) - 12
        guidanceTop, guidanceHeight = 12, 76
        local topBottom = math.max(12 + cardHeight + 6, groupTop + TopBar + 5)
        hudScale = math.min(hudScale, (height - 22 - topBottom - 12) / HudView.Height)
    else
        if portrait then
            groupLeft, groupTop = Margin, 12 + cardHeight + 14
            menuTop = groupTop + TopBar + 16
        else
            groupLeft, groupTop = math.max(walletRight + 20, math.floor(width / 2 - groupWidth / 2)), 12
            menuTop = 12 + cardHeight + 16
        end
        local actionTop = height - 22 - HudView.Height * hudScale
        if portrait then
            -- Portrait: guidance sits just above Pack and Sell.
            guidanceLeft, guidanceRight, guidanceHeight = Margin, width - Margin, 48
            guidanceTop = actionTop - 12 - guidanceHeight
        else
            -- Wide screens: guidance under the top bar, clear of the wallet.
            local half = math.min(230, width / 2 - walletRight - 18)
            guidanceLeft, guidanceRight, guidanceHeight = width / 2 - half, width / 2 + half, 48
            guidanceTop = groupTop + TopBar + 14
        end
        -- Labelled pills when the column fits; otherwise labelled tiles in a 2x2 grid.
        local limit = if portrait then guidanceTop - 12 else actionTop - 12
        local pillHeight, pillGap = 50, 9
        menuMode = if menuTop + #self.menus * (pillHeight + pillGap) - pillGap <= limit then "pill" else "tile"
        for index, menu in ipairs(self.menus) do
            local button = menu.button
            button.AnchorPoint = Vector2.new(0, 0)
            if menuMode == "pill" then
                E.setMenuMode(button, "pill", cardWidth, pillHeight)
                button.Position = UDim2.fromOffset(Margin, menuTop + (index - 1) * (pillHeight + pillGap))
            else
                local column, row = (index - 1) % 2, math.floor((index - 1) / 2)
                local tileWidth = math.floor((cardWidth - 10) / 2)
                E.setMenuMode(button, "tile", tileWidth, 70)
                button.Position = UDim2.fromOffset(Margin + column * (tileWidth + 10), menuTop + row * 80)
            end
        end
    end
    self.teleport.AnchorPoint = Vector2.new(0, 0)
    self.teleport.Size = UDim2.fromOffset(teleportWidth, TopBar)
    self.teleport.Position = UDim2.fromOffset(groupLeft, groupTop)
    self.settings.button.AnchorPoint = Vector2.new(0, 0)
    self.settings.button.Size = UDim2.fromOffset(TopBar, TopBar)
    self.settings.button.Position = UDim2.fromOffset(groupLeft + teleportWidth + 10, groupTop)
    local guidanceWidth = math.max(120, guidanceRight - guidanceLeft)
    self.guidance.Position = UDim2.fromOffset(guidanceLeft + guidanceWidth / 2, guidanceTop)
    self.guidance.Size = UDim2.fromOffset(guidanceWidth, guidanceHeight)
    self.guidance.TextSize = if guidanceWidth >= 300 then 14 else 12
    for _, menu in ipairs(self.panels) do menu:resize(viewport) end
    self.hud.scale.Scale = hudScale
end
return AppView
