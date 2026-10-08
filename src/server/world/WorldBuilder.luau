local Lighting = game:GetService("Lighting")
local P = require(script.Parent.Primitives)
local StationBuilder = require(script.Parent.StationBuilder)
return function(count)
    assert(count <= 6, "Expand the plot layout before adding more restaurants.")
    local previous = workspace:FindFirstChild("FriesRestaurant")
    if previous then previous:Destroy() end
    local model = Instance.new("Model")
    model.Name, model.Parent = "FriesRestaurant", workspace
    P.part(model, "Ground", Vector3.new(220, 1, 192), Vector3.new(0, -0.5, 0), Color3.fromRGB(112, 198, 91))
    P.part(model, "CentralPlaza", Vector3.new(198, 0.25, 48), Vector3.new(0, 0.1, 0), Color3.fromRGB(166, 113, 73))
    local pathBrown = Color3.fromRGB(190, 137, 88)
    P.part(model, "Promenade", Vector3.new(198, 0.05, 12), Vector3.new(0, 0.25, 0), pathBrown)
    -- Continuous solid hedges sit at the ground edges, outside all six plots.
    local boundary = Instance.new("Model")
    boundary.Name, boundary.Parent = "Boundary", model
    for _, edge in ipairs({
        {"North", Vector3.new(220, 12, 2), Vector3.new(0, 6, -95)},
        {"South", Vector3.new(220, 12, 2), Vector3.new(0, 6, 95)},
        {"West", Vector3.new(2, 12, 192), Vector3.new(-109, 6, 0)},
        {"East", Vector3.new(2, 12, 192), Vector3.new(109, 6, 0)},
    }) do
        local wall = P.part(boundary, edge[1], edge[2], edge[3], Color3.fromRGB(73, 156, 83))
        wall.CanCollide = true
        P.part(boundary, edge[1] .. "Cap", Vector3.new(edge[2].X, 1, edge[2].Z),
            Vector3.new(edge[3].X, 12.5, edge[3].Z), Color3.fromRGB(101, 186, 92))
    end
    for _, x in ipairs({-109, 109}) do
        for _, z in ipairs({-95, 95}) do
            P.part(boundary, "CornerPost", Vector3.new(2, 14, 2), Vector3.new(x, 7, z), Color3.fromRGB(255, 218, 147))
        end
    end
    -- The title belongs to a physical wall and follows its perspective.
    local muralWall = P.part(model, "MuralWall", Vector3.new(1.2, 14, 38), Vector3.new(-104, 7, 0), Color3.fromRGB(245, 112, 113))
    P.surfaceLabel(muralWall, "PUT THE FRIES\nIN THE BAG", Enum.NormalId.Right, Color3.fromRGB(255, 235, 181))
    local spawn = Instance.new("SpawnLocation")
    spawn.Name, spawn.Anchored, spawn.Neutral = "PlazaEntrance", true, true
    spawn.Size, spawn.Position = Vector3.new(8, 0.3, 8), Vector3.new(0, 0.35, 0)
    spawn.Color, spawn.Duration, spawn.Transparency = pathBrown, 0, 1
    spawn.Parent = model
    local stations = {}
    for index = 1, count do
        local column = (index - 1) % 3
        local south = index > 3
        stations[index] = StationBuilder(model, index, Vector3.new((column - 1) * 64, 0, if south then 60 else -60),
            if south then math.pi else 0)
        P.part(model, "PlotPath" .. index, Vector3.new(12, 0.2, 12),
            Vector3.new((column - 1) * 64, 0.2, if south then 30 else -30), pathBrown)
    end
    -- Central space stays open for meeting and future, separately agreed features.
    for _, x in ipairs({-84, -32, 32, 84}) do
        for _, z in ipairs({-17, 17}) do
            P.part(model, "Planter", Vector3.new(7, 1.1, 5), Vector3.new(x, 0.8, z), Color3.fromRGB(255, 218, 147))
            local greenery = P.part(model, "Greenery", Vector3.new(6, 2, 4), Vector3.new(x, 2.1, z), Color3.fromRGB(86, 196, 73))
            greenery.Shape = Enum.PartType.Ball
        end
    end
    for _, x in ipairs({-48, 48}) do
        P.part(model, "PlazaBench", Vector3.new(8, 1.5, 2.5), Vector3.new(x, 1, 12), Color3.fromRGB(250, 183, 101))
    end
    -- Broad, soft lighting keeps the solid cartoon colors readable indoors and out.
    -- Dimmed on owner review (8 Oct 2026): the earlier values washed out the colors.
    -- LightingStyle is saved by the place builder/Rojo; runtime writes stop startup.
    Lighting.ClockTime, Lighting.Brightness = 13.5, 1.5
    Lighting.Ambient = Color3.fromRGB(136, 146, 162)
    Lighting.OutdoorAmbient = Color3.fromRGB(148, 159, 176)
    Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale = 0.3, 0.12
    Lighting.GlobalShadows, Lighting.ShadowSoftness = true, 1
    Lighting.ExposureCompensation = -0.25
    return stations
end
