local Theme = require(script.Parent.Theme)
local E = require(script.Parent.Elements)
local HudView = require(script.Parent.HudView)
local UpgradeView = require(script.Parent.UpgradeView)
local DeliveryView = require(script.Parent.DeliveryView)
local InventoryView = require(script.Parent.InventoryView)
local IndexView = require(script.Parent.IndexView)
local AppView = {}
AppView.__index = AppView
function AppView.new(playerGui, send)
    local self = setmetatable({ views = {}, tabs = {} }, AppView)
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.ZIndexBehavior = "FriesInterface", false, Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui
    local panel = Instance.new("Frame")
    panel.Name, panel.AnchorPoint = "Panel", Vector2.new(1, 0.5)
    panel.Position, panel.Size = UDim2.new(1, -12, 0.5, 0), UDim2.fromOffset(420, 670)
    panel.BackgroundColor3, panel.BorderSizePixel, panel.Parent = Theme.Background, 0, gui
    E.corner(panel, 16)
    self.panel = panel
    local scale = Instance.new("UIScale")
    scale.Parent = panel
    self.scale = scale
    local title = E.label(panel, "PUT THE FRIES IN THE BAG", 32, Theme.Gold)
    title.Position, title.Size = UDim2.fromOffset(16, 12), UDim2.fromOffset(386, 32)
    title.Font, title.TextSize = Enum.Font.GothamBlack, 19
    self.wallet = E.label(panel, "Loading saved progress...", 32)
    self.wallet.Position, self.wallet.Size = UDim2.fromOffset(16, 46), UDim2.fromOffset(386, 32)
    self.mode = E.label(panel, "", 23, Theme.Muted)
    self.mode.Position, self.mode.Size, self.mode.TextSize = UDim2.fromOffset(16, 78), UDim2.fromOffset(386, 23), 12
    local names = { "PLAY", "UPGRADES", "DELIVERY", "GEAR", "INDEX" }
    for n, name in ipairs(names) do
        local button = E.button(panel, name, function() self:select(n) end, Theme.Muted)
        button.Position, button.Size = UDim2.fromOffset(16 + (n - 1) * 78, 110), UDim2.fromOffset(73, 34)
        button.TextSize = 11
        self.tabs[n] = button
    end
    local content = Instance.new("Frame")
    content.Position, content.Size = UDim2.fromOffset(16, 155), UDim2.fromOffset(390, 432)
    content.BackgroundTransparency, content.Parent = 1, panel
    self.content = content
    self.views = { HudView.new(content, send), UpgradeView.new(content, send), DeliveryView.new(content, send),
        InventoryView.new(content, send), IndexView.new(content) }
    self.noticeLabel = E.label(panel, "Fill your first bag to begin.", 62)
    self.noticeLabel.Position, self.noticeLabel.Size = UDim2.fromOffset(16, 596), UDim2.fromOffset(386, 62)
    local toggle = E.button(gui, "HIDE MENU", function()
        panel.Visible = not panel.Visible
        self.toggle.Text = if panel.Visible then "HIDE MENU" else "SHOW MENU"
    end, Theme.Gold)
    toggle.Position, toggle.Size = UDim2.new(0, 12, 0, 12), UDim2.fromOffset(124, 36)
    toggle.TextSize = 13
    self.toggle = toggle
    self:select(1)
    return self
end
function AppView:select(index)
    for n, view in ipairs(self.views) do
        view.frame.Visible = n == index
        self.tabs[n].BackgroundColor3 = if n == index then Theme.Gold else Theme.Muted
    end
end
function AppView:update(state)
    self.wallet.Text = "$" .. state.profile.cash .. " Cash     |     " .. state.profile.tickets .. " Tickets"
    self.mode.Text = if state.volatile then "STUDIO TEST MODE - progress resets after stopping" else "Saved progression - gameplay-earned Tickets"
    for _, view in ipairs(self.views) do view:update(state) end
end
function AppView:notice(text, success)
    self.noticeLabel.Text = text
    self.noticeLabel.TextColor3 = if success then Theme.Green else Theme.Red
end
function AppView:resize(viewport)
    -- Preserve readable text on landscape phones; shorten the scroll area instead.
    local scale = math.max(0.3, math.min(1, (viewport.X - 24) / 420))
    local height = math.max(290, math.min(670, (viewport.Y - 65) / scale))
    self.scale.Scale = scale
    self.panel.Size = UDim2.fromOffset(420, height)
    self.content.Size = UDim2.fromOffset(390, height - 238)
    self.noticeLabel.Position = UDim2.fromOffset(16, height - 74)
end
return AppView
