local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Equipment = require(Shared.config.Equipment)
local Economy = require(Shared.config.Economy)
local Runtime = require(Shared.config.Runtime)
local Variants = require(Shared.config.Variants)
local EquipmentVisuals = require(script.Parent.Parent.world.EquipmentVisuals)
local StationService = {}
StationService.__index = StationService
function StationService.new(stations) return setmetatable({ stations = stations, assigned = {} }, StationService) end
function StationService:assign(player)
    for _, station in ipairs(self.stations) do
        if not station.owner then
            station.owner = player
            self.assigned[player] = station
            return true
        end
    end
    return false
end
function StationService:release(player)
    local station = self.assigned[player]
    if station then
        station.owner = nil
        station.sign.Text = "AVAILABLE COUNTER"
        station.orderSign.Text = "Put the fries in the bag!"
        station.equipmentSign.Text = "Training Fryer"
        station.machine.Color = Color3.fromRGB(145, 151, 161)
        station.bag.Color = Color3.fromRGB(165, 130, 92)
        EquipmentVisuals(station, "starter_fryer", "starter_bag")
        for _, fry in ipairs(station.fries) do fry.Transparency = 1 end
    end
    self.assigned[player] = nil
end
function StationService:teleport(player)
    local station, character = self.assigned[player], player.Character
    if station and character and character:FindFirstChild("HumanoidRootPart") then
        character:PivotTo(station.spawn)
    end
end
function StationService:near(player)
    local station = self.assigned[player]
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return station ~= nil and root ~= nil and humanoid ~= nil and humanoid.Health > 0
        and (root.Position - station.origin).Magnitude <= Runtime.StationDistance
end
function StationService:render(player, p)
    local station = self.assigned[player]
    if not station then return end
    EquipmentVisuals(station, p.equipped.Machine, p.equipped.Bag)
    local machine, bag = Equipment.Items[p.equipped.Machine], Equipment.Items[p.equipped.Bag]
    station.machine.Color = Color3.fromRGB(table.unpack(machine.color))
    station.bag.Color = Color3.fromRGB(table.unpack(bag.color))
    station.equipmentSign.Text = machine.name .. "\n" .. machine.power .. " fries / sec"
    station.sign.Text = player.DisplayName .. "'s counter\n" .. math.floor(p.bag.fries) .. " / " .. Economy.Capacity .. " fries"
    station.orderSign.Text = if p.bag.fries >= Economy.Capacity then "Ready! Serve my fries!" else "Put the fries in the bag!"
    local color = Variants[1].color
    for _, variant in ipairs(Variants) do if variant.id == p.bag.variant then color = variant.color end end
    local visible = math.floor(p.bag.fries / Economy.Capacity * #station.fries)
    for n, fry in ipairs(station.fries) do
        fry.Transparency = if n <= visible then 0 else 1
        fry.Color = Color3.fromRGB(table.unpack(color))
    end
end
return StationService
