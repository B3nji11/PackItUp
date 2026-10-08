local Lighting = game:GetService("Lighting")
local P = require(script.Parent.Primitives)
local StationBuilder = require(script.Parent.StationBuilder)
return function(count)
    assert(count <= 6, "Expand the plot layout before adding more restaurants.")
    local previous = workspace:FindFirstChild("FriesRestaurant")
    if previous then previous:Destroy() end
    local model = Instance.new("Model")
    model.Name, model.Parent = "FriesRestaurant", workspace
    P.part(model, "Ground", Vector3.new(220, 1, 192), Vector3.new(0, -0.5, 0), Color3.fromRGB(111, 153, 102), Enum.Material.Grass)
    P.part(model, "CentralPlaza", Vector3.new(198, 0.25, 48), Vector3.new(0, 0.1, 0), Color3.fromRGB(225, 212, 187), Enum.Material.Concrete)
    P.part(model, "Promenade", Vector3.new(198, 0.05, 12), Vector3.new(0, 0.25, 0), Color3.fromRGB(246, 232, 206), Enum.Material.Concrete)
    -- The title belongs to a physical wall and follows its perspective.
    local muralWall = P.part(model, "MuralWall", Vector3.new(1.2, 14, 38), Vector3.new(-104, 7, 0), Color3.fromRGB(176, 77, 56), Enum.Material.Brick)
    P.surfaceLabel(muralWall, "PUT THE FRIES\nIN THE BAG", Enum.NormalId.Right, Color3.fromRGB(255, 235, 181))
    local spawn = Instance.new("SpawnLocation")
    spawn.Name, spawn.Anchored, spawn.Neutral = "PlazaEntrance", true, true
    spawn.Size, spawn.Position = Vector3.new(8, 0.3, 8), Vector3.new(0, 0.35, 0)
    spawn.Color, spawn.Duration, spawn.Transparency = Color3.fromRGB(246, 232, 206), 0, 1
    spawn.Parent = model
    local stations = {}
    for index = 1, count do
        local column = (index - 1) % 3
        local south = index > 3
        stations[index] = StationBuilder(model, index, Vector3.new((column - 1) * 64, 0, if south then 60 else -60),
            if south then math.pi else 0)
        P.part(model, "PlotPath" .. index, Vector3.new(12, 0.2, 12),
            Vector3.new((column - 1) * 64, 0.2, if south then 30 else -30), Color3.fromRGB(218, 202, 174), Enum.Material.Concrete)
    end
    -- Central space stays open for meeting and future, separately agreed features.
    for _, x in ipairs({-84, -32, 32, 84}) do
        for _, z in ipairs({-17, 17}) do
            P.part(model, "Planter", Vector3.new(7, 1.1, 5), Vector3.new(x, 0.8, z), Color3.fromRGB(187, 149, 107), Enum.Material.Wood)
            P.part(model, "Greenery", Vector3.new(6, 2, 4), Vector3.new(x, 2.1, z), Color3.fromRGB(64, 116, 80), Enum.Material.Grass)
        end
    end
    for _, x in ipairs({-48, 48}) do
        P.part(model, "PlazaBench", Vector3.new(8, 1.5, 2.5), Vector3.new(x, 1, 12), Color3.fromRGB(184, 123, 79), Enum.Material.Wood)
    end
    Lighting.ClockTime, Lighting.Brightness = 14, 2
    Lighting.Ambient = Color3.fromRGB(155, 151, 140)
    return stations
end
