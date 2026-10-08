local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local HudView = require(script.Parent.HudView)
local AppView = {}
AppView.__index = AppView
function AppView.new(playerGui, send)
    local self = setmetatable({}, AppView)
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior = "FriesInterface", false, Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui
    self.cashCard = E.box(gui, "CashCard", UDim2.fromOffset(16, 16), UDim2.fromOffset(218, 76), Theme.Background, 18)
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
    self.wallet.Font, self.wallet.TextSize, self.wallet.TextWrapped = Enum.Font.GothamBold, 27, false
    self.wallet.TextScaled = true
    local cashTextSize = Instance.new("UITextSizeConstraint")
    cashTextSize.MinTextSize, cashTextSize.MaxTextSize, cashTextSize.Parent = 10, 27, self.wallet
    self.mode = E.label(gui, "", 20, Theme.Text)
    self.mode.Position, self.mode.Size, self.mode.TextSize = UDim2.fromOffset(16, 8), UDim2.fromOffset(220, 20), 10
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
    self:resize(Vector2.new(1280, 720))
    return self
end
function AppView:update(state)
    self.hasStation = state.hasStation
    self.wallet.Text = E.money(state.profile.cash)
    self.wallet.TextSize = if #self.wallet.Text > 12 then 14 elseif #self.wallet.Text > 9 then 19 else 27
    self.mode.Text = if state.volatile then "STUDIO TEST / resets on stop" else ""
    self.teleport.Active, self.teleport.Selectable = state.hasStation, state.hasStation
    self.teleport.Text = if state.hasStation then "RETURN TO COUNTER" else "CHOOSE A RESTAURANT"
    self.teleport.AutoButtonColor = state.hasStation
    if not self.errorUntil or os.clock() >= self.errorUntil then
        self.guidance.Visible = not state.hasStation
        self.guidance.Text = "Walk to a free restaurant. Press E or tap its entrance prompt to claim."
        self.guidance.TextColor3 = Theme.Text
    end
    self.hud:update(state)
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
    -- Centre Cash on the left; lift it only when a short screen needs room for actions.
    local cashOffset = math.min(0, actionTop - 12 - 38 - height / 2)
    self.cashCard.Position = UDim2.new(0, 16, 0.5, cashOffset)
    self.cashCard.Size = UDim2.fromOffset(if compact then 172 else 218, 76)
    self.wallet.Size = UDim2.fromOffset(if compact then 105 else 142, 36)
    self.wallet.Position = UDim2.fromOffset(if compact then 58 else 65, 29)
    self.teleport.Position = UDim2.new(0.5, if compact then 22 else 0, 0, if portrait then 36 else 16)
    self.guidance.Position = UDim2.new(0.5, if compact then 22 else 0, 0, if portrait then 88 else 68)
    self.guidance.Size = UDim2.fromOffset(if compact then 230 else math.min(460, viewport.X - 32), 44)
    self.hud.scale.Scale = hudScale
end
return AppView
