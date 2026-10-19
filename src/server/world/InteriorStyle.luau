-- A warmer, layered diner interior. Existing collision and gameplay references stay intact.
local Art = require(script.Parent.ArtPrimitives)

return function(model, stationPart)
    local plaster = Color3.fromRGB(197, 184, 163)
    local stone = Color3.fromRGB(189, 175, 151)
    local wood = Color3.fromRGB(124, 100, 80)
    local brass = Color3.fromRGB(189, 149, 83)
    local teal = Color3.fromRGB(55, 112, 107)
    local sage = Color3.fromRGB(117, 154, 143)
    local clay = Color3.fromRGB(193, 103, 91)
    local ink = Color3.fromRGB(48, 59, 61)
    local lettering = Color3.fromRGB(233, 212, 174)
    local art = Instance.new("Model")
    art.Name, art.Parent = "InteriorDecor", model
    model:SetAttribute("InteriorStyle", "WarmDiner")
    local decor = Art.new(art, stationPart)
    local piece, ball, disc, rounded, label = decor.piece, decor.ball, decor.disc, decor.rounded, decor.label

    model.Ceiling.Color = Color3.fromRGB(160, 145, 126)
    model.RestaurantFloor.Color = Color3.fromRGB(134, 117, 97)
    model.Bag.Color = Color3.fromRGB(211, 166, 98)
    -- Retain the approved exterior. Refinish only the existing interior skin.
    for _, child in ipairs(model.RestaurantDecor:GetChildren()) do
        local name = child.Name
        if name == "BackLining" or name == "SideLining" then child.Color = plaster
        elseif name == "InteriorSkirting" or string.find(name, "FryerFoot", 1, true) then child.Color = teal
        elseif string.find(name, "CounterSkin", 1, true) or name == "BagBadge" then child.Color = clay
        elseif string.find(name, "CounterRim", 1, true) or string.find(name, "DiningTop", 1, true) then child.Color = stone
        elseif name == "CounterGoldRail" or name == "DiningPedestal" or string.find(name, "BasketRim", 1, true) then child.Color = brass
        elseif name == "CounterFlute" or name == "BenchPlinth" then child.Color = wood
        elseif string.find(name, "FryerHousing", 1, true) then child.Color = sage
        elseif name == "DiningFoot" then child.Color = teal
        elseif string.find(name, "BenchCushion", 1, true) then
            child.Color = if child.Color.G > child.Color.R then teal else clay
        elseif name == "WallConfetti" or name == "FloorConfetti" or name == "HappyFriesPoster" then
            child.Transparency = 1
            local gui = child:FindFirstChildOfClass("SurfaceGui")
            if gui then gui.Enabled = false end
        end
    end
    for n=1,3 do
        piece("FryerSideVent",Vector3.new(0.06,0.12,1.45),Vector3.new(-5.12,4.45+n*0.32,-1),teal)
    end
    for _,x in ipairs({-4.4,-2.6}) do
        piece("FryerDialMark",Vector3.new(0.05,0.17,0.06),Vector3.new(x,4.54,0.48),ink)
    end
    piece("CounterKickboard",Vector3.new(15.4,0.3,3.08),Vector3.new(0,0.74,-1),wood)

    -- Large matte floor tiles create rhythm without a bright white checkerboard.
    for column = 0, 4 do
        for row = 0, 3 do
            piece("FloorTile", Vector3.new(7.86, 0.05, 7.86), Vector3.new(-16 + column * 8, 0.625, -15 + row * 8),
                if (column + row) % 2 == 0 then Color3.fromRGB(166, 149, 126) else Color3.fromRGB(190, 174, 147))
        end
    end
    piece("EntryRunnerBorder", Vector3.new(10.6, 0.05, 6.6), Vector3.new(0, 0.65, 8), brass)
    piece("EntryRunner", Vector3.new(10, 0.05, 6), Vector3.new(0, 0.66, 8), clay)

    -- Dark wainscoting, trim, and upper plaster break up the tall plain walls.
    piece("BackWainscot", Vector3.new(40.8, 3.55, 0.14), Vector3.new(0, 2.45, -19.4), teal)
    piece("BackChairRail", Vector3.new(40.8, 0.18, 0.22), Vector3.new(0, 4.32, -19.34), brass)
    piece("BackUpperPlaster", Vector3.new(40.8, 4.4, 0.1), Vector3.new(0, 16.3, -19.5), plaster)
    for _, x in ipairs({-20.45, 20.45}) do
        piece("SideWainscot", Vector3.new(0.14, 3.55, 32.5), Vector3.new(x, 2.45, -3), teal)
        piece("SideChairRail", Vector3.new(0.24, 0.18, 32.5), Vector3.new(x, 4.32, -3), brass)
        piece("SideUpperPlaster", Vector3.new(0.1, 4.4, 32.5), Vector3.new(x, 16.3, -3), plaster)
        for z = -17, 11, 4 do
            piece("WallPanelStile", Vector3.new(0.2, 3.15, 0.1), Vector3.new(x, 2.45, z), sage)
        end
    end
    for _, x in ipairs({-20, 0, 20}) do
        piece("CeilingBeam", Vector3.new(0.4, 0.45, 33), Vector3.new(x, 18.15, -3), wood)
    end
    for _, z in ipairs({-19, -3, 13}) do
        piece("CeilingCrossBeam", Vector3.new(40.4, 0.45, 0.4), Vector3.new(0, 18.15, z), wood)
    end

    -- The four broad fixtures still cover the whole floor, at 60% lower intensity.
    for n = 1, 4 do
        model["LightTrim" .. n].Color = wood
        local panel = model["LightPanel" .. n]
        panel.Color = Color3.fromRGB(224, 190, 146)
        local light = panel.InteriorLight
        light.Color, light.Brightness = Color3.fromRGB(255, 220, 179), 0.32
    end
    for _, x in ipairs({-14, 14}) do
        piece("PendantCord", Vector3.new(0.12, 4, 0.12), Vector3.new(x, 16.2, -11), ink)
        disc("PendantMount", 0.65, 0.18, Vector3.new(x, 18.2, -11), brass)
        disc("PendantShade", 2.7, 0.6, Vector3.new(x, 14, -11), clay)
        disc("PendantLip", 2.95, 0.16, Vector3.new(x, 13.7, -11), brass)
        local diffuser = disc("PendantDiffuser", 2.35, 0.1, Vector3.new(x, 13.57, -11), Color3.fromRGB(228, 196, 151))
        local light = Instance.new("SurfaceLight")
        -- Disc local Left (-X) rotates downward with the cylinder's upright transform.
        light.Name, light.Face = "PendantLight", Enum.NormalId.Left
        light.Color, light.Brightness, light.Range, light.Angle = Color3.fromRGB(255, 214, 167), 0.12, 16, 110
        light.Enabled, light.Shadows, light.Parent = true, false, diffuser
    end

    -- Upholstered booth backs stay outside the original seat/table approach space.
    for _, x in ipairs({-14, 14}) do
        local upholstery = if x < 0 then teal else clay
        for _, z in ipairs({-15, -7}) do
            local towardTable = if z < -11 then 1 else -1
            local backZ = z - towardTable * 0.72
            rounded("BoothBack", Vector3.new(6.1, 2.8, 0.7), Vector3.new(x, 2.9, backZ), upholstery, 0.3)
            for _, offset in ipairs({-1.6, 0, 1.6}) do
                ball("BoothButton", Vector3.new(0.16, 0.16, 0.12), Vector3.new(x + offset, 3.25, backZ + towardTable * 0.37), brass)
            end
        end
    end

    -- A small prep line adds a believable kitchen behind the working counter.
    for _, x in ipairs({-6.5, 0}) do
        rounded("PrepCabinet", Vector3.new(6.3, 3.6, 2.8), Vector3.new(x, 2.45, -17.6), sage, 0.35)
        for _, side in ipairs({-1, 1}) do
            piece("CabinetDoor", Vector3.new(2.8, 2.65, 0.13), Vector3.new(x + side * 1.5, 2.55, -16.12), teal)
            piece("CabinetHandle", Vector3.new(0.12, 0.65, 0.15), Vector3.new(x + side * 1.5 + 0.95, 2.8, -16), brass)
        end
    end
    rounded("PrepWorktop", Vector3.new(13.6, 0.28, 3.15), Vector3.new(-3.25, 4.35, -17.6), stone, 0.4)
    rounded("ColdCabinet", Vector3.new(4.6, 6.9, 2.8), Vector3.new(7.3, 4.1, -17.6), sage, 0.4)
    for _, door in ipairs({{2.5, 3.1}, {5.85, 2.75}}) do
        piece("ColdCabinetDoor", Vector3.new(4.15, door[2], 0.15), Vector3.new(7.3, door[1], -16.1), teal)
        piece("ColdCabinetHandle", Vector3.new(0.12, 1, 0.2), Vector3.new(5.85, door[1], -15.95), brass)
    end
    for row = 0, 1 do
        for column = 0, 7 do
            piece("BacksplashTile", Vector3.new(2.35, 1.05, 0.12), Vector3.new(-9.3 + column * 2.4, 5.25 + row * 1.12, -19.28),
                if (row + column) % 2 == 0 then sage else stone)
        end
    end
    piece("PrepShelf", Vector3.new(7.6, 0.2, 1.35), Vector3.new(-7, 6.55, -18.55), wood)
    for _, x in ipairs({-9.8, -4.2}) do
        piece("ShelfBracket", Vector3.new(0.15, 0.9, 0.8), Vector3.new(x, 6.05, -18.8), brass)
    end
    for n, x in ipairs({-9, -7, -5}) do
        disc("PrepJar", 0.72, 0.65, Vector3.new(x, 6.99, -18.5), if n % 2 == 0 then clay else stone)
        disc("PrepJarLid", 0.8, 0.12, Vector3.new(x, 7.38, -18.5), brass)
    end
    rounded("PrepBoard", Vector3.new(2.6, 0.12, 1.7), Vector3.new(-2, 4.55, -17.4), wood, 0.25)
    piece("NapkinHolder", Vector3.new(1.3, 0.65, 0.85), Vector3.new(-6.2, 4.78, -17.4), teal)
    for n=1,3 do
        piece("NapkinFold", Vector3.new(0.09, 0.6, 0.6), Vector3.new(-6.5+n*0.15, 5.13, -17.4), lettering)
    end

    -- Framed physical wall graphics use no prices, fake offers, or new interactions.
    local function board(name, width, height, x, y)
        piece(name .. "Frame", Vector3.new(width + 0.4, height + 0.4, 0.22), Vector3.new(x, y, -19.12), brass)
        piece(name .. "Face", Vector3.new(width, height, 0.1), Vector3.new(x, y, -18.94), ink)
    end
    local function caption(name, text, width, height, x, y, background, foreground)
        local face=piece(name,Vector3.new(width,height,0.06),Vector3.new(x,y,-18.83),background)
        return label(face,text,foreground)
    end
    board("HouseMenu",15,4.4,0,10.1)
    board("LeftMenu",6,4.4,-13.5,10.1)
    board("RightMenu",6,4.4,13.5,10.1)
    caption("HouseTitle","FRY DAY!",12,1.25,0,11.25,ink,lettering)
    caption("HouseSubtitle","HOT & CRISPY, ALWAYS",12,0.58,0,10.05,ink,brass)
    piece("MenuDivider",Vector3.new(12.8,0.06,0.08),Vector3.new(0,9.45,-18.78),brass)
    for n,text in ipairs({"PACK","SELL","REPEAT"}) do
        caption("HouseStep",text,3.4,0.72,(n-2)*4.2,8.68,teal,lettering)
    end
    caption("GoldenCaption","GOLDEN BITES",5.3,0.72,-13.5,8.72,ink,lettering)
    rounded("MenuCarton",Vector3.new(1.85,1.2,0.35),Vector3.new(-13.5,10.3,-18.65),clay,0.12)
    for n=1,3 do
        piece("MenuFry",Vector3.new(0.3,1.2+(n%2)*0.22,0.18),Vector3.new(-14.1+n*0.3,11.18,-18.62),brass)
    end
    caption("HappyTitle","MADE WITH",5.3,0.58,13.5,11.58,ink,brass)
    caption("HappyCaption","HAPPINESS",5.3,0.72,13.5,8.72,ink,lettering)
    for _,x in ipairs({13.15,13.85}) do
        ball("MenuHeartLobe",Vector3.new(0.95,0.95,0.2),Vector3.new(x,10.65,-18.65),clay)
    end
    piece("MenuHeartTip",Vector3.new(1,1,0.18),Vector3.new(13.5,10.27,-18.64),clay,nil,CFrame.Angles(0,0,math.pi/4))
    for _, side in ipairs({-1, 1}) do
        local x = side * 20.3
        piece("SideArtFrame", Vector3.new(0.2, 5.2, 7.4), Vector3.new(x, 9, -11), brass)
        local face = piece("SideArtFace", Vector3.new(0.1, 4.8, 7), Vector3.new(x - side * 0.17, 9, -11), clay)
        label(face, if side < 0 then "GOOD FOOD\nGOOD MOOD" else "STAY\nGOLDEN", lettering,
            if side < 0 then Enum.NormalId.Right else Enum.NormalId.Left).TextWrapped = true
    end
end
