local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Pricing = require(Shared.domain.Pricing)
local Runtime = require(Shared.config.Runtime)
local Restaurant = require(Shared.domain.Restaurant)
local TierBuilder = require(script.Parent.Parent.world.TierBuilder)
local StationService = {}
StationService.__index = StationService
function StationService.new(stations) return setmetatable({ stations = stations, assigned = {} }, StationService) end
local function livingRoot(player)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not player.Parent or not root or not humanoid or humanoid.Health <= 0 then return nil end
    return root
end
function StationService:claim(player, index)
    local station = self.stations[index]
    if not station then return false, "That restaurant is unavailable." end
    if self.assigned[player] then return false, "You already have a restaurant. Use Return to Counter." end
    if station.owner then return false, "Someone has already claimed this restaurant." end
    local root = livingRoot(player)
    if not root or (root.Position - station.claimPart.Position).Magnitude > Runtime.ClaimDistance then
        return false, "Walk to the entrance to claim this restaurant."
    end
    -- No yields between availability and assignment: only one claimant can win.
    station.owner, self.assigned[player] = player, station
    station.prompt.Enabled = false
    station.sign.Text = player.DisplayName .. "'s\nRESTAURANT"
    station.shownTier = nil -- the next render dresses the plot in the owner's tier
    station.model:SetAttribute("OwnerUsername", player.Name)
    station.model:SetAttribute("OwnerUserId", player.UserId)
    self:teleport(player)
    return true, "Your restaurant is ready."
end
function StationService:hasStation(player) return self.assigned[player] ~= nil end
function StationService:release(player)
    local station = self.assigned[player]
    if station then
        station.owner = nil
        station.sign.Text = "RESTAURANT " .. station.index .. "\nAVAILABLE"
        station.model:SetAttribute("OwnerUsername", nil)
        station.model:SetAttribute("OwnerUserId", 0)
        station.prompt.Enabled = true
        for _, fry in ipairs(station.fries) do fry.Transparency = 1 end
        if station.stands then TierBuilder.apply(station, 1) end
    end
    self.assigned[player] = nil
end
function StationService:teleport(player)
    local station, character = self.assigned[player], player.Character
    if station and character and character:FindFirstChild("HumanoidRootPart") then
        character:PivotTo(station.spawn)
        return true
    end
    return false
end
function StationService:near(player)
    local station, root = self.assigned[player], livingRoot(player)
    return station ~= nil and root ~= nil and (root.Position - station.origin).Magnitude <= Runtime.StationDistance
end
-- The id of the gacha stand whose pad the player is standing at (locked stands count, so the
-- panel can show what it needs), or nil.
function StationService:nearMachine(player)
    local station, root = self.assigned[player], livingRoot(player)
    if not station or not root or not station.stands then return nil end
    local best, bestDistance = nil, Runtime.StandDistance
    for _, stand in ipairs(station.standOrder) do
        local distance = (root.Position - stand.front).Magnitude
        if distance <= bestDistance then best, bestDistance = stand.id, distance end
    end
    return best
end
function StationService:nearExpand(player)
    local station, root = self.assigned[player], livingRoot(player)
    return station ~= nil and root ~= nil and station.kiosk ~= nil
        and (root.Position - station.kiosk.front).Magnitude <= Runtime.StandDistance
end
-- Moves the player onto a stand's pad, facing the stand (the SPIN menu button).
function StationService:visitMachine(player, machineId)
    local station, character = self.assigned[player], player.Character
    local stand = station and station.stands and station.stands[machineId]
    if stand and character and character:FindFirstChild("HumanoidRootPart") then
        character:PivotTo(CFrame.lookAt(stand.front, stand.facing))
        return true
    end
    return false
end
function StationService:render(player, p)
    local station = self.assigned[player]
    if not station then return end
    -- Restaurant tier visuals follow the owner's saved tier (claiming, expanding).
    local tier = Restaurant.tier(p)
    if station.stands and station.shownTier ~= tier then TierBuilder.apply(station, tier, player.DisplayName) end
    local visible = math.floor(p.bag.fries / Pricing.capacity(p) * #station.fries)
    for n, fry in ipairs(station.fries) do fry.Transparency = if n <= visible then 0 else 1 end
end
return StationService
