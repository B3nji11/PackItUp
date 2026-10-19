-- District art layers over the existing paths, plaza furniture, and solid boundary.
local Art = require(script.Parent.ArtPrimitives)

return function(model)
    local c = Art.Palette
    local art = Instance.new("Model")
    art.Name, art.Parent = "PlazaDecor", model
    model:SetAttribute("DistrictStyle", "CoralGold")
    local decor = Art.new(art)
    local piece, ball, disc, rounded, label = decor.piece, decor.ball, decor.disc, decor.rounded, decor.label

    -- Keep the brown promenade, spawn, and six connecting paths exactly where they were.
    for _, z in ipairs({-6.2, 6.2}) do
        piece("PromenadeCreamEdge", Vector3.new(196, 0.16, 0.65), Vector3.new(0, 0.31, z), c.Cream)
        piece("PromenadeGoldEdge", Vector3.new(196, 0.12, 0.22), Vector3.new(0, 0.3, z + (if z < 0 then -0.5 else 0.5)), c.Gold)
    end
    for n = 0, 23 do
        piece("PromenadePaver", Vector3.new(7.7, 0.05, 10.8), Vector3.new(-92 + n * 8, 0.3, 0),
            if n % 2 == 0 then Color3.fromRGB(198, 146, 98) else Color3.fromRGB(190, 137, 88))
    end
    for index = 1, 6 do
        local column, south = (index - 1) % 3, index > 3
        local x, z = (column - 1) * 64, if south then 30 else -30
        for _, edge in ipairs({-6.3, 6.3}) do
            piece("PlotPathEdge", Vector3.new(0.5, 0.16, 11.8), Vector3.new(x + edge, 0.31, z), c.Cream)
        end
        disc("PlotNumberBorder", 9.8, 0.05, Vector3.new(x, 0.34, z), c.Gold)
        local badge = disc("PlotNumber", 9.6, 0.05, Vector3.new(x, 0.38, z), c.Coral)
        -- Cylinder caps face local Right, which the disc helper rotates upward.
        label(badge, string.format("%02d", index), c.Cream, Enum.NormalId.Right)
    end
    disc("WelcomeBorder", 19.5, 0.05, Vector3.new(0, 0.54, 0), c.Gold)
    disc("WelcomeCentre", 19, 0.055, Vector3.new(0, 0.57, 0), c.Cream)
    -- A flat sign keeps the spawn and the central sight lines open.
    local welcome = piece("WelcomeLettering", Vector3.new(17, 0.05, 8), Vector3.new(0, 0.625, 0), c.Cream)
    label(welcome, "FRY DAY!\nDISTRICT", c.Red, Enum.NormalId.Top).TextWrapped = true

    -- Keep the original collision envelopes while replacing their blocky visible skin.
    for _, child in ipairs(model:GetChildren()) do
        if child.Name == "Planter" or child.Name == "Greenery" or child.Name == "PlazaBench" then
            child.Transparency = 1
        end
    end
    for _, x in ipairs({-84, -32, 32, 84}) do
        for _, z in ipairs({-17, 17}) do
            rounded("PlazaPlanter", Vector3.new(7, 1.1, 5), Vector3.new(x, 0.8, z), c.Cream, 1.1)
            rounded("PlanterGoldRim", Vector3.new(7.2, 0.18, 5.2), Vector3.new(x, 1.4, z), c.Gold, 1.1)
            ball("PlanterCrown", Vector3.new(6.3, 2.4, 4.1), Vector3.new(x, 2.5, z), c.Mint)
            for _, side in ipairs({-1, 1}) do
                ball("PlanterPuff", Vector3.new(3.3, 2.6, 3.3), Vector3.new(x + side * 1.5, 3, z), c.Lime)
            end
            local flowerZ = z + (if z < 0 then 2.15 else -2.15)
            for _, offset in ipairs({Vector3.new(-0.42, 0, 0), Vector3.new(0.42, 0, 0),
                Vector3.new(0, 0.42, 0), Vector3.new(0, -0.42, 0)}) do
                ball("FlowerPetal", Vector3.new(0.65, 0.65, 0.23), Vector3.new(x, 2.8, flowerZ) + offset, c.Pink)
            end
            ball("FlowerCentre", Vector3.new(0.5, 0.5, 0.3), Vector3.new(x, 2.8, flowerZ), c.Gold)
        end
    end
    for _, x in ipairs({-48, 48}) do
        local color = if x < 0 then c.Mint else c.Pink
        rounded("PlazaSeat", Vector3.new(8, 1.5, 2.5), Vector3.new(x, 1, 12), color, 0.9)
        rounded("PlazaBackrest", Vector3.new(8, 1.7, 0.7), Vector3.new(x, 2.4, 13), color, 0.3)
        for _, side in ipairs({-1, 1}) do
            piece("PlazaBenchFoot", Vector3.new(0.65, 0.55, 2.1), Vector3.new(x + side * 2.6, 0.5, 12), c.Gold)
        end
    end

    -- Puffy hedge caps soften the existing continuous solid perimeter.
    for _, z in ipairs({-95, 95}) do
        for x = -96, 96, 16 do
            ball("BoundaryPuff", Vector3.new(16, 2.5, 3), Vector3.new(x, 13, z), c.Lime)
        end
    end
    for _, x in ipairs({-109, 109}) do
        for z = -80, 80, 16 do
            ball("BoundaryPuff", Vector3.new(3, 2.5, 16), Vector3.new(x, 13, z), c.Lime)
        end
    end
    for _, x in ipairs({-109, 109}) do
        for _, z in ipairs({-95, 95}) do
            ball("BoundaryFinial", Vector3.new(2.8, 2.8, 2.8), Vector3.new(x, 14.9, z), c.Coral)
        end
    end

    -- Frame the original title wall without replacing its message or collision.
    model.MuralWall.Color = c.Coral
    rounded("MuralCap", Vector3.new(1.6, 0.9, 39), Vector3.new(-104, 14.3, 0), c.Gold, 0.65)
    for _, z in ipairs({-18.8, 18.8}) do
        piece("MuralFrame", Vector3.new(0.3, 14.4, 0.6), Vector3.new(-103.3, 7.2, z), c.Gold)
    end
    local district = piece("DistrictSign", Vector3.new(0.2, 6.6, 36), Vector3.new(-103.2, 18.1, 0), c.Red)
    label(district, "FRY DAY!", c.Cream, Enum.NormalId.Right)
end
