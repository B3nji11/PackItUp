local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Economy = require(Shared.config.Economy)
local Runtime = require(Shared.config.Runtime)
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
        station.model:SetAttribute("OwnerUserId", 0)
        station.prompt.Enabled = true
        for _, fry in ipairs(station.fries) do fry.Transparency = 1 end
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
function StationService:render(player, p)
    local station = self.assigned[player]
    if not station then return end
    local visible = math.floor(p.bag.fries / Economy.Capacity * #station.fries)
    for n, fry in ipairs(station.fries) do fry.Transparency = if n <= visible then 0 else 1 end
end
return StationService
