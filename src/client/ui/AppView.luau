local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local HudView = require(script.Parent.HudView)
local ShopView = require(script.Parent.ShopView)
local RebirthView = require(script.Parent.RebirthView)
local GachaView = require(script.Parent.GachaView)
local PetsView = require(script.Parent.PetsView)
local AppView = {}
AppView.__index = AppView
-- The wallet card holds Cash (top) and Gems (bottom row).
local CardHeight, ButtonGap, ButtonHeight = 112, 10, 44
local function scaledText(label, max)
    label.TextScaled, label.TextWrapped = true, false
    local fit = Instance.new("UITextSizeConstraint")
    fit.MinTextSize, fit.MaxTextSize, fit.Parent = 10, max, label
end
function AppView.new(playerGui, send)
    local self = setmetatable({}, AppView)
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior = "FriesInterface", false, Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui
    self.cashCard = E.box(gui, "CashCard", UDim2.fromOffset(16, 16), UDim2.fromOffset(218, CardHeight), Theme.Background, 18)
    self.cashCard.AnchorPoint = Vector2.new(0, 0.5)
    E.stroke(self.cashCard, Theme.Gold, 2, 0.12)
    local coin = E.box(self.cashCard, "Coin", UDim2.fromOffset(12, 17), UDim2.fromOffset(42, 42), Theme.Gold, 21)
    local symbol = E.label(coin, "$", 42, Theme.Ink)
    symbol.Size, symbol.TextSize, symbol.Font = UDim2.fromScale(1, 1), 29, Enum.Font.GothamBold
    symbol.TextXAlignment = Enum.TextXAlignment.Center
    local caption = E.label(self.cashCard, "CASH", 18, Theme.Muted)
    caption.Position, caption.Size, caption.TextSize = UDim2.fromOffset(65, 10), UDim2.fromOffset(140, 18), 11
    self.wallet = E.label(self.cashCard, "$0", 36, Theme.Text)
    self.wallet.Name, self.wallet.Position, self.wallet.Size = "Cash", UDim2.fromOffset(65, 29), UDim2.fromOffset(142, 36)
    self.wallet.Font, self.wallet.TextSize = Enum.Font.GothamBold, 27
    scaledText(self.wallet, 27)
    local divider = E.box(self.cashCard, "Divider", UDim2.fromOffset(12, 74), UDim2.new(1, -24, 0, 1), Theme.Muted, 0)
    divider.BackgroundTransparency = 0.7
    -- A code-built gem: a small rotated square, no texture assets.
    local gem = E.box(self.cashCard, "GemIcon", UDim2.fromOffset(24, 84), UDim2.fromOffset(18, 18), Theme.Gem, 3)
    gem.Rotation = 45
    self.gems = E.label(self.cashCard, "0", 26, Theme.Text)
    self.gems.Name, self.gems.Position, self.gems.Size = "Gems", UDim2.fromOffset(65, 80), UDim2.new(1, -125, 0, 26)
    self.gems.Font, self.gems.TextSize = Enum.Font.GothamBold, 20
    scaledText(self.gems, 20)
    local gemCaption = E.label(self.cashCard, "GEMS", 18, Theme.Gem)
    gemCaption.Name, gemCaption.AnchorPoint = "GemCaption", Vector2.new(1, 0)
    gemCaption.Position, gemCaption.Size, gemCaption.TextSize = UDim2.new(1, -14, 0, 84), UDim2.fromOffset(50, 18), 11
    gemCaption.TextXAlignment = Enum.TextXAlignment.Right
    self.mode = E.label(gui, "", 20, Theme.Text)
    -- Studio-only label in the bottom-left corner, below every control.
    self.mode.Name, self.mode.Position, self.mode.Size, self.mode.TextSize = "Mode", UDim2.new(0, 16, 1, -18), UDim2.fromOffset(220, 16), 10
    self.teleport = E.button(gui, "RETURN TO COUNTER", function()
        if self.hasStation then send("Return") end
    end, Theme.Background)
    self.teleport.TextColor3 = Theme.Text
    self.teleport.Name, self.teleport.AnchorPoint = "Teleport", Vector2.new(0.5, 0)
    self.teleport.Size, self.teleport.TextSize = UDim2.fromOffset(212, 44), 12
    E.stroke(self.teleport, Theme.Gold, 1.5, 0.3)
    self.guidance = E.label(gui, "", 44, Theme.Text)
    self.guidance.Name, self.guidance.AnchorPoint = "Guidance", Vector2.new(0.5, 0)
    self.guidance.TextXAlignment, self.guidance.TextSize = Enum.TextXAlignment.Center, 13
    self.guidance.BackgroundColor3, self.guidance.BackgroundTransparency = Theme.Background, 0.08
    E.corner(self.guidance, 12)
    self.hud = HudView.new(gui, send)
    self.shop = ShopView.new(gui, send)
    self.rebirth = RebirthView.new(gui, send)
    self.gacha = GachaView.new(gui, send)
    self.pets = PetsView.new(gui, send)
    -- Grid order: UPGRADES | REBIRTH on the first row, SPIN | PETS on the second.
    self.menus = { self.shop, self.rebirth, self.gacha, self.pets }
    -- Opening one panel closes the others so they never stack.
    for _, menu in ipairs(self.menus) do
        menu.button.Activated:Connect(function()
            if not menu.panel.Visible then return end
            for _, other in ipairs(self.menus) do if other ~= menu then other:setOpen(false) end end
        end)
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
    if not self.errorUntil or os.clock() >= self.errorUntil then
        self.guidance.Visible = not state.hasStation
        self.guidance.Text = "Follow an AVAILABLE arrow. Press E or tap the entrance prompt to claim."
        self.guidance.TextColor3 = Theme.Text
    end
    self.hud:update(state)
    for _, menu in ipairs(self.menus) do menu:update(state) end
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
    local portrait = viewport.X < 760 and viewport.Y >= 500
    local compact = viewport.X < 760 and not portrait
    local hudScale = math.min(1, (viewport.X - 24) / 392)
    local height = viewport.Y - 60
    local actionTop = height - 22 - 104 * hudScale
    local cardWidth = if compact then 172 else 218
    -- Centre the wallet on the left; lift it only when a short screen needs room for actions.
    -- Tall screens put the 2x2 menu grid below it, which needs room too. Short screens
    -- (under 500 px high) put the grid at the top right instead.
    local side = viewport.Y < 500
    local below = if side then 0 else ButtonGap + ButtonHeight * 2 + 8
    local cashOffset = math.min(0, actionTop - 12 - below - CardHeight / 2 - height / 2)
    self.cashCard.Position = UDim2.new(0, 16, 0.5, cashOffset)
    self.cashCard.Size = UDim2.fromOffset(cardWidth, CardHeight)
    self.wallet.Size = UDim2.fromOffset(if compact then 105 else 142, 36)
    self.wallet.Position = UDim2.fromOffset(if compact then 58 else 65, 29)
    self.gems.Position = UDim2.fromOffset(if compact then 58 else 65, 80)
    self.teleport.Position = UDim2.new(0.5, if compact then 22 else 0, 0, if portrait then 36 else 16)
    self.guidance.Position = UDim2.new(0.5, if compact then 22 else 0, 0, if portrait then 88 else 68)
    self.guidance.Size = UDim2.fromOffset(if compact then 230 else math.min(460, viewport.X - 32), 44)
    local gridLeft = viewport.X
    for index, menu in ipairs(self.menus) do
        local column, row = (index - 1) % 2, math.floor((index - 1) / 2)
        local button = menu.button
        if side then
            -- Top right, clear of Return to Counter and the guidance strip.
            local width = if compact then 60 else 96
            button.AnchorPoint = Vector2.new(1, 0)
            button.Position = UDim2.new(1, -16 - (1 - column) * (width + 8), 0, 16 + row * (ButtonHeight + 8))
            button.Size = UDim2.fromOffset(width, ButtonHeight)
            gridLeft = viewport.X - 16 - width * 2 - 8
        else
            local half = (cardWidth - 8) / 2
            button.AnchorPoint = Vector2.new(0, 0)
            button.Position = UDim2.new(0, 16 + column * (half + 8), 0.5, cashOffset + CardHeight / 2 + ButtonGap + row * (ButtonHeight + 8))
            button.Size = UDim2.fromOffset(half, ButtonHeight)
        end
    end
    if side and not compact then
        -- Keep the centred guidance strip clear of the top-right grid.
        self.guidance.Size = UDim2.fromOffset(math.min(460, 2 * (gridLeft - 12 - viewport.X / 2)), 44)
    end
    for _, menu in ipairs(self.menus) do menu:resize(viewport) end
    self.hud.scale.Scale = hudScale
end
return AppView
