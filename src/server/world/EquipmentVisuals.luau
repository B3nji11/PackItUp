-- Rebuild cosmetic geometry only when the equipped machine or bag changes.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Equipment = require(Shared.config.Equipment)
local P = require(script.Parent.Primitives)
return function(station, machineId, bagId)
    local key = machineId .. ":" .. bagId
    if station.visualKey == key then return end
    station.visualKey = key
    local old = station.model:FindFirstChild("EquipmentDetails")
    if old then old:Destroy() end
    local details = Instance.new("Model")
    details.Name, details.Parent = "EquipmentDetails", station.model
    local function part(name, size, offset, color, material)
        local value = P.part(details, name, size, station.origin + offset, color, material)
        value.CanCollide = false
        return value
    end
    local machineColor = Color3.fromRGB(table.unpack(Equipment.Items[machineId].color))
    station.machine.Transparency = if machineId == "ufo" then 1 else 0
    if machineId == "conveyor" then
        part("ConveyorBelt", Vector3.new(4, 0.3, 1), Vector3.new(-2.7, 5.8, -1), Color3.fromRGB(40, 43, 52))
        for n = 1, 4 do
            part("Roller"..n, Vector3.new(0.15, 0.15, 1.1), Vector3.new(-4.5+n*0.8, 6, -1), machineColor)
        end
    elseif machineId == "robot" then
        part("RobotHead", Vector3.new(2, 1.4, 1.5), Vector3.new(-3.5, 6.4, -1), machineColor)
        for _, x in ipairs({-4, -3}) do
            part("RobotEye", Vector3.new(0.3, 0.3, 0.15), Vector3.new(x, 6.5, -0.2), Color3.fromRGB(89, 255, 211), Enum.Material.Neon)
        end
        part("RobotArm", Vector3.new(2.4, 0.4, 0.4), Vector3.new(-1.2, 5.4, -1), machineColor)
    elseif machineId == "ufo" then
        local disc = part("UFODisc", Vector3.new(4.5, 0.7, 3.3), Vector3.new(-3.5, 6.2, -1), machineColor)
        disc.Shape = Enum.PartType.Ball
        local dome = part("UFODome", Vector3.new(2, 1.3, 1.8), Vector3.new(-3.5, 6.7, -1), Color3.fromRGB(106, 255, 199), Enum.Material.Neon)
        dome.Shape = Enum.PartType.Ball
        local beam = part("FryBeam", Vector3.new(1.3, 2.3, 1.3), Vector3.new(-3.5, 4.9, -1), Color3.fromRGB(107, 255, 197), Enum.Material.Neon)
        beam.Transparency = 0.65
    else
        part("FryerBasket", Vector3.new(2.3, 0.15, 1.6), Vector3.new(-3.5, 5.8, -1), Color3.fromRGB(80, 83, 94))
    end
    station.bag.Material = if bagId == "neon" then Enum.Material.Neon else Enum.Material.SmoothPlastic
    if bagId == "striped" then
        for n = 1, 3 do
            part("BagStripe"..n, Vector3.new(0.16, 1.6, 0.05), Vector3.new(0.3+n*0.35, 4.35, -0.32), Color3.fromRGB(250, 235, 207))
        end
    elseif bagId == "briefcase" then
        local black = Color3.fromRGB(43, 42, 35)
        part("HandleTop", Vector3.new(0.8, 0.13, 0.14), Vector3.new(1, 5.45, -1), black)
        for _, x in ipairs({0.6, 1.4}) do
            part("HandleSide", Vector3.new(0.13, 0.3, 0.14), Vector3.new(x, 5.3, -1), black)
        end
    end
end
