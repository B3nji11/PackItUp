local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Economy = require(Shared.config.Economy)
local E = require(script.Parent.Elements)
local Theme = require(script.Parent.Theme)
local UpgradeView = {}
UpgradeView.__index = UpgradeView
function UpgradeView.new(parent, send)
    local self = setmetatable({ frame = E.column(parent, "Upgrades") }, UpgradeView)
    E.label(self.frame, "PERMANENT TRAINING", 36, Theme.Gold)
    E.label(self.frame, "Spend Cash to improve every shift. Your training stays when you change equipment.", 64, Theme.Muted)
    self.click = E.label(self.frame, "", 50)
    self.clickButton = E.button(self.frame, "", function() send("Upgrade", "Click") end)
    self.sales = E.label(self.frame, "", 50)
    self.salesButton = E.button(self.frame, "", function() send("Upgrade", "Sales") end)
    E.label(self.frame, "A full bag keeps the value it had when it finished. Sales training applies to your next completed bag.", 78, Theme.Muted)
    return self
end
function UpgradeView:update(state)
    local u = state.profile.upgrades
    self.click.Text = "SCOOPING SKILL  Level " .. u.Click .. " / " .. Economy.MaxUpgradeLevel .. "\nCurrently " .. state.stats.perClick .. " fries per click"
    self.sales.Text = "SALES SKILL  Level " .. u.Sales .. " / " .. Economy.MaxUpgradeLevel .. "\nCurrent sales bonus: +" .. math.floor(u.Sales * Economy.SalesBonusPerLevel * 100 + 0.5) .. "%"
    self.clickButton.Text = if u.Click >= Economy.MaxUpgradeLevel then "MAX LEVEL" else "+1 FRY PER CLICK  |  $" .. state.stats.clickCost
    self.salesButton.Text = if u.Sales >= Economy.MaxUpgradeLevel then "MAX LEVEL" else "+20% BASE SALE VALUE  |  $" .. state.stats.salesCost
end
return UpgradeView
