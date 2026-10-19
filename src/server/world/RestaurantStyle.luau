-- The shared restaurant skin. The original station owns all gameplay and collision.
-- No external assets, remotes, timers, economy changes, or equipment billboards.
local Art = require(script.Parent.ArtPrimitives)
local P = require(script.Parent.Primitives)

return function(model, stationPart)
    local colors = Art.Palette
    local cream, coral, red, gold, honey = colors.Cream, colors.Coral, colors.Red, colors.Gold, colors.Honey
    local mint, teal, ink, pink = colors.Mint, colors.Teal, colors.Ink, colors.Pink
    local art = Instance.new("Model")
    art.Name, art.Parent = "RestaurantDecor", model

    local decor = Art.new(art, stationPart)
    local piece, ball, disc, rounded, label = decor.piece, decor.ball, decor.disc, decor.rounded, decor.label

    model:SetAttribute("VisualStyle", "CoralGold")
    model.BackWall.Color, model.LeftWall.Color, model.RightWall.Color = coral, coral, coral
    model.Fascia.Color, model.RoofCap.Color = coral, gold
    model.Counter.Color, model.Worktop.Color = red, cream
    model.Machine.Color, model.MachineScreen.Color = mint, ink
    model.FryerBasket.Color, model.Bag.Color = honey, gold
    model.Counter.Transparency, model.Worktop.Transparency = 1, 1
    model.Machine.Transparency, model.MachineScreen.Transparency, model.FryerBasket.Transparency = 1, 1, 1
    -- The original structural shell and its collision dimensions are unchanged.
    -- Cream lining keeps the work area bright while the exterior remains coral.
    piece("BackLining", Vector3.new(40.8, 13.5, 0.08), Vector3.new(0, 7.4, -19.55), cream)
    for _, x in ipairs({-20.55, 20.55}) do
        piece("SideLining", Vector3.new(0.08, 13.5, 32.5), Vector3.new(x, 7.4, -3), cream)
        piece("InteriorSkirting", Vector3.new(0.12, 1.1, 32.5), Vector3.new(x, 1.15, -3), mint)
    end
    for _, x in ipairs({-21.45, 21.45}) do
        piece("ExteriorGoldBand", Vector3.new(0.16, 1, 34.3), Vector3.new(x, 3.1, -3), gold)
    end
    piece("BackGoldBand", Vector3.new(42.8, 1, 0.16), Vector3.new(0, 3.1, -20.48), gold)
    rounded("RoofLip", Vector3.new(45.4, 0.55, 37.4), Vector3.new(0, 19.6, -3), gold, 1.1)
    piece("FasciaHighlight", Vector3.new(43, 0.35, 0.3), Vector3.new(0, 18.1, 14.8), cream)
    for _, x in ipairs({-20, 20}) do
        rounded("FrontPillar", Vector3.new(2, 17.4, 2), Vector3.new(x, 9.25, 14.3), coral, 0.6)
        rounded("PillarFoot", Vector3.new(2.8, 0.9, 2.8), Vector3.new(x, 1.1, 14.3), gold, 0.7)
    end

    -- A sloping candy-striped canopy and soft scalloped edge frame the entrance.
    for n = 1, 10 do
        local stripe = model["AwningStripe" .. n]
        stripe.Size, stripe.Color = Vector3.new(4.2, 0.35, 6), if n % 2 == 0 then cream else coral
        -- Use the station factory so this skin also respects a rotated plot.
        local guide = piece("CanopyGuide", stripe.Size, Vector3.new(-23.1 + n * 4.2, 14.2, 17), stripe.Color)
        stripe.CFrame = guide.CFrame * CFrame.Angles(math.rad(12), 0, 0)
        stripe.CanCollide, stripe.CanTouch, stripe.CanQuery, stripe.CastShadow = false, false, false, false
        guide:Destroy()
        ball("AwningScallop", Vector3.new(4.2, 1.15, 0.65), Vector3.new(-23.1 + n * 4.2, 13, 19.95), stripe.Color)
    end
    -- Preserve the live ownership text, mounted below the canopy for readability.
    local plaqueGuide = piece("PlaqueGuide", Vector3.new(27, 3.8, 0.2), Vector3.new(0, 10.2, 20.35), red)
    model.RestaurantPlaque.CFrame = plaqueGuide.CFrame
    model.RestaurantPlaque.Size = plaqueGuide.Size
    P.fitSurfaceLabel(model.RestaurantPlaque, model.RestaurantPlaque.WallArt)
    model.RestaurantPlaque.Color, model.RestaurantPlaque.CanCollide = red, false
    plaqueGuide:Destroy()
    rounded("PlaqueBorder", Vector3.new(27.7, 4.3, 0.6), Vector3.new(0, 10.2, 20), gold, 0.25)

    -- An original dimensional fries mascot, offset from the roof's owner card.
    rounded("SignCarton", Vector3.new(7.8, 5.5, 2.8), Vector3.new(-14.2, 22.8, 12.8), coral, 0.65)
    rounded("SignCartonRim", Vector3.new(8.1, 0.65, 3), Vector3.new(-14.2, 25.3, 12.8), gold, 0.65)
    for n, height in ipairs({4.1, 5.6, 6.1, 5.2, 4.4}) do
        rounded("SignFry" .. n, Vector3.new(1.05, height, 1.1),
            Vector3.new(-17.1 + (n - 1) * 1.45, 24.7 + height / 2, 12.75), if n % 2 == 0 then honey else gold, 0.22)
    end
    for _, x in ipairs({-15.5, -12.9}) do
        ball("MascotEye", Vector3.new(0.48, 0.65, 0.22), Vector3.new(x, 23.2, 14.25), ink)
        ball("MascotCheek", Vector3.new(0.72, 0.35, 0.12), Vector3.new(x - 0.35, 22.55, 14.26), pink)
    end
    local smile = piece("MascotSmile", Vector3.new(2, 0.8, 0.1), Vector3.new(-14.2, 22.2, 14.27), coral)
    label(smile, "u", cream)
    -- Brand below the roof leaves the existing central owner billboard clear.
    rounded("BrandBorder", Vector3.new(38.2, 5.1, 1.4), Vector3.new(0, 16.65, 14.7), gold, 0.6)
    local brand = piece("BrandFace", Vector3.new(37, 4.4, 0.12), Vector3.new(0, 16.65, 15.46), red)
    label(brand, "FRY DAY!", cream)

    -- Keep the central route and all gameplay objects in their original positions.
    rounded("CounterSkin", Vector3.new(16.2, 2.9, 3.05), Vector3.new(0, 2, -1), coral, 0.45)
    rounded("CounterRim", Vector3.new(16.9, 0.35, 3.7), Vector3.new(0, 3.67, -1), cream, 0.55)
    piece("CounterGoldRail", Vector3.new(14.8, 0.3, 0.12), Vector3.new(0, 2.9, 0.59), gold)
    for n = 1, 5 do
        piece("CounterFlute", Vector3.new(0.22, 1.5, 0.12), Vector3.new(-5.4 + (n - 1) * 2.7, 1.85, 0.59), red)
    end
    rounded("FryerHousing", Vector3.new(3.15, 2.2, 2.55), Vector3.new(-3.5, 4.9, -1), mint, 0.45)
    rounded("FryerFoot", Vector3.new(3.35, 0.25, 2.7), Vector3.new(-3.5, 3.95, -1), teal, 0.35)
    local screen = piece("FryerControlFace", Vector3.new(1.7, 0.65, 0.12), Vector3.new(-3.5, 5.1, 0.34), ink)
    label(screen, "• • •", cream)
    for _, x in ipairs({-4.4, -2.6}) do
        ball("FryerButton", Vector3.new(0.32, 0.32, 0.18), Vector3.new(x, 4.5, 0.36), gold)
    end
    rounded("BasketRim", Vector3.new(2.65, 0.22, 1.95), Vector3.new(-3.5, 6.12, -1), gold, 0.22)
    piece("BasketOil", Vector3.new(2.05, 0.08, 1.35), Vector3.new(-3.5, 6.27, -1), honey)
    for n = 1, 5 do
        piece("BasketGrill", Vector3.new(0.1, 0.07, 1.5), Vector3.new(-4.4 + n * 0.3, 6.33, -1), cream)
    end
    rounded("BasketHandle", Vector3.new(0.4, 0.3, 1.15), Vector3.new(-3.5, 6.15, 0.5), teal, 0.14)
    -- This badge sits on the existing bag and never covers the ten live fry tips.
    local badge = piece("BagBadge", Vector3.new(1.75, 1.55, 0.08), Vector3.new(1, 4.55, -0.3), coral)
    label(badge, "FRY", cream)

    -- Give the existing counter character a friendly face and a small matching uniform.
    model.CustomerBody.Transparency = 1
    rounded("CustomerShirt", Vector3.new(1.9, 2.4, 1.1), Vector3.new(3.5, 2.8, -5), mint, 0.3)
    local apron = piece("CustomerApron", Vector3.new(1.75, 1.9, 0.1), Vector3.new(3.5, 2.6, -4.4), cream)
    label(apron, "FRY", red)
    for _, x in ipairs({3.25, 3.75}) do
        ball("CustomerEye", Vector3.new(0.13, 0.18, 0.1), Vector3.new(x, 4.85, -4.34), ink)
    end
    local customerSmile = piece("CustomerSmile", Vector3.new(0.48, 0.3, 0.06), Vector3.new(3.5, 4.5, -4.31),
        Color3.fromRGB(255, 205, 163))
    label(customerSmile, "u", ink)
    disc("CustomerCap", 1.7, 0.26, Vector3.new(3.5, 5.4, -5), gold)
    ball("CustomerCapCrown", Vector3.new(1.5, 0.6, 1.4), Vector3.new(3.5, 5.6, -5), coral)

    -- Soft tabletops and capsule benches replace only the visible furniture skin.
    -- Original invisible furniture retains its previous collision envelope.
    for _, child in ipairs(model:GetChildren()) do
        if child.Name == "DiningTable" or child.Name == "DiningBench" or child.Name == "TableBase" then
            child.Transparency = 1
        end
    end
    for _, x in ipairs({-14, 14}) do
        local seatColor = if x < 0 then mint else pink
        rounded("DiningTop", Vector3.new(6, 0.45, 5), Vector3.new(x, 3, -11), cream, 1.1)
        disc("DiningPedestal", 1.2, 2.25, Vector3.new(x, 1.6, -11), gold)
        disc("DiningFoot", 2.8, 0.2, Vector3.new(x, 0.7, -11), seatColor)
        for _, z in ipairs({-15, -7}) do
            rounded("BenchCushion", Vector3.new(6, 1.6, 1.5), Vector3.new(x, 1.3, z), seatColor, 0.7)
            piece("BenchPlinth", Vector3.new(4.4, 0.45, 1.1), Vector3.new(x, 0.8, z), gold)
        end
        -- Ketchup and mustard make the dining area feel inhabited without NPCs.
        for n, sauce in ipairs({coral, gold}) do
            disc("SauceBottle", 0.38, 0.65, Vector3.new(x - 0.7 + n * 0.5, 3.56, -11), sauce)
            ball("SauceCap", Vector3.new(0.18, 0.3, 0.18), Vector3.new(x - 0.7 + n * 0.5, 4, -11), cream)
        end
    end

    -- Physical wall art, confetti tiles, and topiary complete each plot.
    local poster = piece("HappyFriesPoster", Vector3.new(12, 4.8, 0.18), Vector3.new(0, 9, -19.4), mint)
    label(poster, "GOOD FRIES.\nGREAT DAY.", cream).TextWrapped = true
    for n = 1, 7 do
        local x = -17 + (n - 1) * 5.6
        ball("WallConfetti", Vector3.new(0.7, 0.7, 0.15), Vector3.new(x, 13.6 + n % 2 * 1.1, -19.4),
            if n % 2 == 0 then gold else pink)
    end
    for _, x in ipairs({-15.5, 15.5}) do
        rounded("WelcomePlanter", Vector3.new(3.6, 1.5, 3.6), Vector3.new(x, 1.15, 21.5), cream, 0.9)
        disc("TopiaryStem", 0.4, 2.3, Vector3.new(x, 2.9, 21.5), honey)
        ball("TopiaryCrown", Vector3.new(3.6, 3.6, 3.6), Vector3.new(x, 4.8, 21.5), mint)
        ball("TopiaryHighlight", Vector3.new(2.5, 2.5, 2.5), Vector3.new(x - 0.6, 5.5, 21.4), colors.Lime)
    end
    local welcome = piece("WelcomeMat", Vector3.new(12.5, 0.05, 7.5), Vector3.new(0, 0.41, 20.5), coral)
    label(welcome, "HELLO,\nFRY FRIEND!", cream, Enum.NormalId.Top)
    for n = 1, 3 do
        piece("FloorConfetti", Vector3.new(0.65, 0.04, 1.8), Vector3.new(-2.6 + n * 1.3, 0.63, 10), gold)
    end
end
