local Lighting = game:GetService("Lighting")
local P = require(script.Parent.Primitives)
local StationBuilder = require(script.Parent.StationBuilder)
return function(count)
    local previous = workspace:FindFirstChild("FriesRestaurant")
    if previous then previous:Destroy() end
    local model = Instance.new("Model")
    model.Name = "FriesRestaurant"
    model.Parent = workspace
    P.part(model, "Floor", Vector3.new(82, 1, 70), Vector3.new(0, -0.5, 0), Color3.fromRGB(222, 212, 190))
    P.part(model, "BackWall", Vector3.new(82, 18, 1), Vector3.new(0, 9, -34), Color3.fromRGB(47, 62, 77))
    P.part(model, "LeftWall", Vector3.new(1, 10, 70), Vector3.new(-41, 5, 0), Color3.fromRGB(190, 70, 64))
    P.part(model, "RightWall", Vector3.new(1, 10, 70), Vector3.new(41, 5, 0), Color3.fromRGB(190, 70, 64))
    local title = P.part(model, "TitleBoard", Vector3.new(28, 4, 1), Vector3.new(0, 12, -32), Color3.fromRGB(255, 198, 62))
    P.label(title, "PUT THE FRIES IN THE BAG\nPACK  /  SERVE  /  COLLECT", Vector3.zero, 440, 90)
    local spawn = Instance.new("SpawnLocation")
    spawn.Name, spawn.Anchored, spawn.Neutral = "RestaurantEntrance", true, true
    spawn.Size, spawn.Position = Vector3.new(7, 0.3, 7), Vector3.new(0, 0.2, 27)
    spawn.Color = Color3.fromRGB(87, 183, 162)
    spawn.Duration = 0
    spawn.Parent = model
    local board = P.part(model, "RushBoard", Vector3.new(9, 3, 1), Vector3.new(0, 5, 17), Color3.fromRGB(47, 62, 77))
    local rushLabel = P.label(board, "LUNCH RUSH", Vector3.new(0, 2, 0), 340, 75)
    local stations = {}
    for index = 1, count do
        local column = (index - 1) % 3
        local row = math.floor((index - 1) / 3)
        stations[index] = StationBuilder(model, index, Vector3.new((column - 1) * 24, 0, -19 + row * 23))
    end
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(145, 145, 155)
    return stations, rushLabel
end
