-- Small, code-built diner props. Original station geometry owns collision/gameplay.
local Art = require(script.Parent.ArtPrimitives)

return function(model, stationPart)
    local c = Art.Palette
    local pink = Color3.fromRGB(255, 181, 201)
    local lilac = Color3.fromRGB(193, 177, 232)
    local butter = Color3.fromRGB(255, 222, 139)
    local mint = Color3.fromRGB(149, 222, 198)
    local art = Instance.new("Model")
    art.Name, art.Parent = "CuteDecor", model
    model:SetAttribute("DetailStyle", "FryFriends")
    local decor = Art.new(art, stationPart)
    local piece, ball, disc, label = decor.piece, decor.ball, decor.disc, decor.label

    -- High candy garlands and sleepy cloud mobiles leave the central headroom open.
    piece("GarlandCord",Vector3.new(40.5,0.07,0.07),Vector3.new(0,14.8,10.8),c.Cream)
    for _,x in ipairs({-20.25,20.25}) do
        ball("GarlandHook",Vector3.new(0.4,0.4,0.4),Vector3.new(x,14.8,10.8),c.Gold)
    end
    local sweets = {pink,mint,butter,lilac}
    for n=1,9 do
        local x=-16+(n-1)*4
        piece("GarlandDrop",Vector3.new(0.05,0.45,0.05),Vector3.new(x,14.55,10.8),c.Cream)
        piece("CandyPennant",Vector3.new(1.05,1.05,0.12),Vector3.new(x,13.95,10.8),sweets[(n-1)%4+1],nil,CFrame.Angles(0,0,math.pi/4))
    end
    for _,x in ipairs({-13.5,13.5}) do
        piece("CloudCord",Vector3.new(0.06,1.8,0.06),Vector3.new(x,17.5,-3.5),c.Gold)
        for _,puff in ipairs({{-0.8,0,1.35},{0,0.3,1.8},{0.9,0,1.3}}) do
            ball("CloudPuff",Vector3.new(puff[3],0.95,0.85),Vector3.new(x+puff[1],15.95+puff[2],-3.5),c.Cream)
        end
        for _,side in ipairs({-1,1}) do
            ball("CloudEye",Vector3.new(0.13,0.17,0.08),Vector3.new(x+side*0.34,16.06,-3.04),c.Ink)
            ball("CloudBlush",Vector3.new(0.25,0.13,0.06),Vector3.new(x+side*0.62,15.85,-3.04),pink)
        end
        local smile=piece("CloudSmile",Vector3.new(0.4,0.22,0.03),Vector3.new(x,15.85,-3.03),c.Cream)
        label(smile,"u",c.Ink)
        piece("CloudCharmCord",Vector3.new(0.05,0.55,0.05),Vector3.new(x+0.9,15.25,-3.5),c.Gold)
        piece("CloudCharm",Vector3.new(0.5,0.5,0.14),Vector3.new(x+0.9,14.75,-3.5),butter,nil,CFrame.Angles(0,0,math.pi/4))
    end

    -- Round mascot medallions add illustrated wall art, rather than more large text.
    for _,side in ipairs({-1,1}) do
        local x=side*20.3
        local muralZ=-3
        local faceId=if side<0 then Enum.NormalId.Right else Enum.NormalId.Left
        piece("MascotMedallionRim",Vector3.new(0.16,5,5),Vector3.new(x,9.4,muralZ),c.Gold,Enum.PartType.Cylinder)
        piece("MascotMedallion",Vector3.new(0.1,4.65,4.65),Vector3.new(x-side*0.12,9.4,muralZ),c.Cream,Enum.PartType.Cylinder)
        local front=x-side*0.28
        if side<0 then
            piece("WallFriesCarton",Vector3.new(0.18,1.45,1.9),Vector3.new(front,9.1,muralZ),c.Coral)
            for n=1,3 do
                piece("WallFriesTip",Vector3.new(0.13,1.25+(n%2)*0.2,0.38),Vector3.new(front,10.4,muralZ-0.9+n*0.45),butter)
            end
        else
            for _,z in ipairs({muralZ-0.45,muralZ+0.45}) do
                ball("WallHeartLobe",Vector3.new(0.2,1.3,1.3),Vector3.new(front,9.7,z),pink)
            end
            piece("WallHeartTip",Vector3.new(0.18,1.3,1.3),Vector3.new(front,9.15,muralZ),pink,nil,CFrame.Angles(math.pi/4,0,0))
        end
        for _,offset in ipairs({-0.34,0.34}) do
            ball("WallMascotEye",Vector3.new(0.08,0.16,0.14),Vector3.new(front-side*0.12,9.3,muralZ+offset),c.Ink)
            ball("WallMascotBlush",Vector3.new(0.06,0.15,0.28),Vector3.new(front-side*0.13,9.04,muralZ+offset*1.85),if side<0 then pink else c.Coral)
        end
        local smile=piece("WallMascotSmile",Vector3.new(0.03,0.25,0.44),Vector3.new(front-side*0.14,8.97,muralZ),if side<0 then c.Coral else pink)
        label(smile,"u",c.Ink,faceId)
    end

    for _,x in ipairs({-14,14}) do
        -- Flowers and takeaway cups sit on the original tables, clear of the sauces.
        disc("TableVase",0.75,0.6,Vector3.new(x,3.55,-12.2),lilac)
        piece("FlowerStem",Vector3.new(0.07,0.8,0.07),Vector3.new(x,4.1,-12.2),mint)
        for _,offset in ipairs({Vector3.new(-0.25,0,0),Vector3.new(0.25,0,0),Vector3.new(0,0.25,0),Vector3.new(0,-0.25,0)}) do
            ball("TableFlowerPetal",Vector3.new(0.38,0.38,0.18),Vector3.new(x,4.6,-12.2)+offset,pink)
        end
        ball("TableFlowerCentre",Vector3.new(0.28,0.28,0.2),Vector3.new(x,4.6,-12.1),butter)
        piece("TablePlacemat",Vector3.new(1.8,0.025,1.35),Vector3.new(x-1.5,3.26,-10.8),mint)
        disc("TableCup",0.48,0.58,Vector3.new(x-1.5,3.57,-10.8),pink)
        disc("TableCupLid",0.55,0.08,Vector3.new(x-1.5,3.9,-10.8),c.Cream)
        piece("TableStraw",Vector3.new(0.06,0.5,0.06),Vector3.new(x-1.42,4.16,-10.8),c.Coral)
        -- Heart cushions sit off-center on the front booths.
        ball("BoothPillow",Vector3.new(1.2,1,0.5),Vector3.new(x+1.7,2.45,-7),lilac)
        for _,offset in ipairs({-0.16,0.16}) do
            ball("PillowHeartLobe",Vector3.new(0.42,0.42,0.08),Vector3.new(x+1.7+offset,2.56,-6.72),pink)
        end
        piece("PillowHeartTip",Vector3.new(0.4,0.4,0.07),Vector3.new(x+1.7,2.38,-6.72),pink,nil,CFrame.Angles(0,0,math.pi/4))
    end

    -- A small bun mascot on a display plate adds character beside, not over, the bag.
    disc("BunPlate",1.8,0.1,Vector3.new(6,3.91,-0.8),pink)
    ball("BunBuddy",Vector3.new(1.4,0.7,1.1),Vector3.new(6,4.31,-0.8),butter)
    for _,side in ipairs({-1,1}) do
        ball("BunEye",Vector3.new(0.1,0.14,0.08),Vector3.new(6+side*0.24,4.38,-0.28),c.Ink)
        ball("BunBlush",Vector3.new(0.2,0.1,0.06),Vector3.new(6+side*0.43,4.21,-0.37),pink)
    end
    local bunSmile=piece("BunSmile",Vector3.new(0.35,0.2,0.025),Vector3.new(6,4.21,-0.25),butter)
    label(bunSmile,"u",c.Ink)

    for _,side in ipairs({-1,1}) do
        -- Potted leaves occupy the side corners, outside the approach to the counter.
        local x=side*18.5
        disc("CornerPot",1.8,1.4,Vector3.new(x,1.37,7),pink)
        disc("CornerPotRim",2,0.18,Vector3.new(x,2.1,7),butter)
        piece("CornerPlantStem",Vector3.new(0.14,1.8,0.14),Vector3.new(x,3.05,7),mint)
        for n,offset in ipairs({-0.5,0,0.5}) do
            ball("CornerPlantLeaf",Vector3.new(1.05,0.7,0.5),Vector3.new(x+offset,3.3+(n%2)*0.5,7),if n%2==0 then c.Mint else mint)
        end
        -- Pastel bows on the facade and cheerful faces on the existing topiary.
        local pillarX=side*20
        for _,offset in ipairs({-0.45,0.45}) do
            ball("PillarBowLoop",Vector3.new(1,0.7,0.25),Vector3.new(pillarX+offset,8.6,15.36),lilac)
            piece("PillarBowTail",Vector3.new(0.24,0.7,0.14),Vector3.new(pillarX+offset*0.5,8.02,15.38),lilac,nil,CFrame.Angles(0,0,offset*0.55))
        end
        ball("PillarBowKnot",Vector3.new(0.4,0.4,0.3),Vector3.new(pillarX,8.6,15.4),pink)
        local treeX=side*15.5
        for _,offset in ipairs({-0.5,0.5}) do
            ball("TopiaryEye",Vector3.new(0.15,0.23,0.09),Vector3.new(treeX+offset,4.95,23.25),c.Ink)
            ball("TopiaryBlush",Vector3.new(0.36,0.16,0.07),Vector3.new(treeX+offset*1.6,4.55,23.16),pink)
        end
        local smile=piece("TopiarySmile",Vector3.new(0.65,0.35,0.03),Vector3.new(treeX,4.55,23.31),c.Mint)
        label(smile,"u",c.Ink)
    end
end
