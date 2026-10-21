-- Restaurant tiers in the world: one gacha stand per machine along the front of the plot, the
-- EXPAND kiosk inside, and themed decoration for tiers 2 and up. Stands for tiers the owner has
-- not reached yet stay visible but grey and LOCKED, so everyone can see what comes next.
-- Everything here is cosmetic and anchored; the server checks distances to the stand and kiosk
-- fronts before it spins or expands.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Restaurants = require(Shared.config.Restaurants)
local Machines = require(Shared.config.Machines)
local Format = require(Shared.util.Format)
local P = require(script.Parent.Primitives)
local TierBuilder = {}
local function color(list) return Color3.fromRGB(list[1], list[2], list[3]) end
local Upright = CFrame.Angles(0, 0, math.pi / 2) -- Cylinders run along X; this stands them on Y
local Locked, Ink, White = Color3.fromRGB(150, 140, 130), Color3.fromRGB(61, 31, 31), Color3.fromRGB(255, 255, 255)
local CeilingBottom = 18.5
-- Stand slots in plot space (the restaurant faces +Z): nearest the entrance path first.
local StandX = { -9, 9, -15, 15, -21, 21 }
local StandZ, PadZ = 21, 24
local KioskOffset, KioskPad = Vector3.new(-15, 0, 9), Vector3.new(-15, 0.62, 11.6)
TierBuilder.StandX = StandX

-- Adds an anchored, non-colliding part at a plot-space offset. `options`: shape, material,
-- transparency, rotation (CFrame), collide.
local function adder(station, parent)
    return function(name, size, offset, tint, options)
        options = options or {}
        local part = P.part(parent, name, size, station.transform:PointToWorldSpace(offset), tint, options.material)
        part.CFrame = station.transform * CFrame.new(offset) * (options.rotation or CFrame.new())
        if options.shape == "Ball" then part.Shape = Enum.PartType.Ball
        elseif options.shape == "Cylinder" then part.Shape = Enum.PartType.Cylinder end
        part.Transparency = options.transparency or 0
        part.CanCollide = options.collide == true
        part.CanTouch, part.CanQuery, part.CastShadow = false, false, options.shadow == true
        return part
    end
end
local function sign(part, text, tint)
    local label = P.surfaceLabel(part, text, Enum.NormalId.Back, tint)
    label.Font = Enum.Font.LuckiestGuy
    return label
end

-- One gacha stand: plinth, body, a glass dome of capsules, a sign, and a glowing pad in front.
local function buildStand(station, folder, machineId, slot)
    local machine = Machines.Machines[machineId]
    local theme = Restaurants.Tiers[machine.Tier].Theme
    local model = Instance.new("Model")
    model.Name = machineId
    model:SetAttribute("Machine", machineId)
    model.Parent = folder
    local add = adder(station, model)
    local x = StandX[slot]
    local stand = { id = machineId, model = model, theme = theme, capsules = {} }
    add("Plinth", Vector3.new(5, 0.6, 4), Vector3.new(x, 0.55, StandZ), color(theme.Trim), { collide = true })
    stand.body = add("Body", Vector3.new(4.2, 4.4, 3), Vector3.new(x, 3.05, StandZ), color(theme.Main), { collide = true, shadow = true })
    add("Chute", Vector3.new(2.6, 1.4, 0.1), Vector3.new(x, 2.2, StandZ + 1.55), Ink)
    stand.dome = add("Dome", Vector3.new(3.6, 3.6, 3.6), Vector3.new(x, 6.6, StandZ), Color3.fromRGB(200, 235, 255),
        { shape = "Ball", material = Enum.Material.Glass, transparency = 0.45 })
    for n, tint in ipairs({ { 42, 157, 143 }, { 123, 44, 191 }, { 255, 183, 3 } }) do
        table.insert(stand.capsules, add("Capsule", Vector3.new(0.9, 0.9, 0.9), Vector3.new(x - 1.4 + n * 0.7, 6.1, StandZ), color(tint), { shape = "Ball" }))
    end
    stand.cap = add("Cap", Vector3.new(0.6, 1.6, 1.6), Vector3.new(x, 8.6, StandZ), color(theme.Main), { shape = "Cylinder", rotation = Upright })
    stand.board = add("Sign", Vector3.new(5.4, 1.8, 0.3), Vector3.new(x, 10.2, StandZ), color(theme.Main))
    stand.label = sign(stand.board, machine.Name, color(theme.Trim))
    stand.pad = add("Pad", Vector3.new(0.12, 3.4, 3.4), Vector3.new(x, 0.32, PadZ), color(theme.Glow),
        { shape = "Cylinder", material = Enum.Material.Neon, rotation = Upright })
    stand.front = station.transform:PointToWorldSpace(Vector3.new(x, 3, PadZ))
    stand.facing = station.transform:PointToWorldSpace(Vector3.new(x, 3, StandZ))
    return stand
end

-- Shows a stand as usable or LOCKED for the given tier.
local function showStand(stand, tier)
    local machine = Machines.Machines[stand.id]
    local open = machine.Tier <= tier
    stand.model:SetAttribute("Unlocked", open)
    stand.body.Color = if open then color(stand.theme.Main) else Locked
    stand.cap.Color = stand.body.Color
    stand.board.Color = stand.body.Color
    stand.dome.Transparency = if open then 0.45 else 0.8
    for _, capsule in ipairs(stand.capsules) do capsule.Transparency = if open then 0 else 1 end
    stand.pad.Transparency = if open then 0 else 0.7
    stand.label.Text = if open then string.upper(machine.Name) .. "\n" .. Format.money(machine.Price) .. " A SPIN"
        else "LOCKED\nNEEDS " .. string.upper(Restaurants.Tiers[machine.Tier].Name)
end

-- Builds the stands and the kiosk once per station, and remembers the base colours.
function TierBuilder.build(station)
    local folder = Instance.new("Folder")
    folder.Name, folder.Parent = "MachineStands", station.model
    station.stands, station.standOrder = {}, {}
    for slot, machineId in ipairs(Machines.Order) do
        local stand = buildStand(station, folder, machineId, slot)
        station.stands[machineId] = stand
        table.insert(station.standOrder, stand)
    end
    local kioskModel = Instance.new("Model")
    kioskModel.Name, kioskModel.Parent = "ExpandKiosk", station.model
    local add = adder(station, kioskModel)
    local k = KioskOffset
    station.kiosk = {
        model = kioskModel,
        podium = add("Podium", Vector3.new(3, 3.5, 2), k + Vector3.new(0, 2.35, 0), station.accent, { collide = true, shadow = true }),
        board = add("Board", Vector3.new(4.6, 2.6, 0.3), k + Vector3.new(0, 5.4, 0.4), Color3.fromRGB(255, 183, 3)),
        pad = add("Pad", Vector3.new(0.12, 3, 3), KioskPad, Color3.fromRGB(255, 214, 102),
            { shape = "Cylinder", material = Enum.Material.Neon, rotation = Upright }),
        front = station.transform:PointToWorldSpace(KioskPad + Vector3.new(0, 2.5, 0)),
    }
    station.kiosk.label = sign(station.kiosk.board, "EXPAND", Ink)
    -- Parts the theme recolours, with their tier 1 colours so a released plot can be reset.
    station.themed = {}
    for _, part in ipairs(station.model:GetChildren()) do
        local name = part.Name
        if part:IsA("BasePart") and (name == "RoofCap" or name == "Fascia" or name == "FrontPost" or name == "RestaurantPlaque"
            or name == "Counter" or name == "TableBase" or name == "DiningBench" or name == "RestaurantFloor"
            or string.sub(name, 1, 12) == "AwningStripe") then
            table.insert(station.themed, { part = part, original = part.Color })
        end
    end
    TierBuilder.apply(station, 1)
end

-- Themed decoration for one tier. Every piece is cosmetic.
local Decor = {}
Decor[2] = function(add, theme) -- Fry Diner: chrome stools, a jukebox, a checkered entrance
    for _, x in ipairs({ -6, -2, 2, 6 }) do
        add("StoolPole", Vector3.new(1.6, 0.3, 0.3), Vector3.new(x, 1.4, 2.4), color(theme.Trim), { shape = "Cylinder", rotation = Upright })
        add("StoolSeat", Vector3.new(0.4, 1.7, 1.7), Vector3.new(x, 2.4, 2.4), color(theme.Main), { shape = "Cylinder", rotation = Upright })
    end
    add("Jukebox", Vector3.new(3, 4.6, 2), Vector3.new(16.5, 2.9, 9), color(theme.Main), { collide = true })
    add("JukeboxTop", Vector3.new(3, 3, 3), Vector3.new(16.5, 5.2, 9), color(theme.Glow), { shape = "Ball", material = Enum.Material.Neon })
    for row = 0, 3 do
        for column = 0, 3 do
            local dark = (row + column) % 2 == 0
            add("CheckerTile", Vector3.new(3, 0.06, 3), Vector3.new(-4.5 + column * 3, 0.4, 15.5 + row * 3), if dark then Ink else White)
        end
    end
end
Decor[3] = function(add, theme) -- Drive-In: a giant burger and a classic car on the roof, string lights
    local top = CeilingBottom + 1.4
    add("BurgerBun", Vector3.new(1.4, 8, 8), Vector3.new(-4, top + 0.7, -6), Color3.fromRGB(226, 156, 72), { shape = "Cylinder", rotation = Upright })
    add("BurgerPatty", Vector3.new(1.1, 8.6, 8.6), Vector3.new(-4, top + 1.9, -6), Color3.fromRGB(110, 60, 35), { shape = "Cylinder", rotation = Upright })
    add("BurgerCheese", Vector3.new(8.4, 0.3, 8.4), Vector3.new(-4, top + 2.55, -6), Color3.fromRGB(255, 200, 40), { rotation = CFrame.Angles(0, math.pi / 4, 0) })
    add("BurgerLettuce", Vector3.new(0.4, 8.8, 8.8), Vector3.new(-4, top + 2.9, -6), Color3.fromRGB(110, 200, 70), { shape = "Cylinder", rotation = Upright })
    add("BurgerTop", Vector3.new(7.6, 7.6, 7.6), Vector3.new(-4, top + 3.6, -6), Color3.fromRGB(232, 168, 82), { shape = "Ball" })
    add("CarBody", Vector3.new(7, 1.6, 3.4), Vector3.new(12, top + 1.4, -6), color(theme.Trim))
    add("CarCabin", Vector3.new(3.8, 1.4, 3), Vector3.new(11.6, top + 2.9, -6), color(theme.Main))
    for _, wx in ipairs({ 9.6, 14.4 }) do
        for _, wz in ipairs({ -7.7, -4.3 }) do
            add("CarWheel", Vector3.new(0.7, 1.6, 1.6), Vector3.new(wx, top + 0.7, wz), Ink, { shape = "Cylinder", rotation = CFrame.Angles(0, math.pi / 2, 0) })
        end
    end
    for n = 0, 9 do
        add("StringLight", Vector3.new(0.7, 0.7, 0.7), Vector3.new(-18 + n * 4, CeilingBottom - 3.6, 15.1),
            if n % 2 == 0 then color(theme.Glow) else color(theme.Trim), { shape = "Ball", material = Enum.Material.Neon })
    end
end
Decor[4] = function(add, theme) -- Fish & Chips Pier: a lighthouse, a giant fish, life rings
    local top = CeilingBottom + 1.4
    for n = 0, 2 do
        add("Lighthouse", Vector3.new(3, 3, 3), Vector3.new(14, top + 1.5 + n * 3, -10), if n % 2 == 0 then Color3.fromRGB(230, 57, 70) else White,
            { shape = "Cylinder", rotation = Upright })
    end
    add("LighthouseLamp", Vector3.new(2.6, 2.6, 2.6), Vector3.new(14, top + 10.2, -10), color(theme.Glow), { shape = "Ball", material = Enum.Material.Neon })
    add("LighthouseCap", Vector3.new(0.6, 3.4, 3.4), Vector3.new(14, top + 11.6, -10), color(theme.Main), { shape = "Cylinder", rotation = Upright })
    add("FishBody", Vector3.new(5, 5, 5), Vector3.new(-8, top + 3, -6), Color3.fromRGB(255, 160, 70), { shape = "Ball" })
    add("FishTail", Vector3.new(0.6, 3.4, 3.4), Vector3.new(-11.6, top + 3, -6), Color3.fromRGB(255, 130, 50), { rotation = CFrame.Angles(0, math.pi / 2, math.pi / 4) })
    add("FishEye", Vector3.new(1.2, 1.2, 1.2), Vector3.new(-6.2, top + 3.8, -3.9), White, { shape = "Ball" })
    add("FishPupil", Vector3.new(0.6, 0.6, 0.6), Vector3.new(-6, top + 3.8, -3.4), Ink, { shape = "Ball" })
    for _, x in ipairs({ -20, 20 }) do
        add("LifeRing", Vector3.new(0.5, 3.2, 3.2), Vector3.new(x, 8, 14.8), Color3.fromRGB(230, 57, 70), { shape = "Cylinder", rotation = CFrame.Angles(0, math.pi / 2, 0) })
        add("LifeRingCentre", Vector3.new(0.6, 1.6, 1.6), Vector3.new(x, 8, 14.8), color(theme.Main), { shape = "Cylinder", rotation = CFrame.Angles(0, math.pi / 2, 0) })
    end
end
Decor[5] = function(add, theme) -- Cosmic Diner: a ringed planet, a satellite dish, floating stars
    local top = CeilingBottom + 1.4
    add("Planet", Vector3.new(7, 7, 7), Vector3.new(-9, top + 6, -8), color(theme.Trim), { shape = "Ball" })
    add("PlanetRing", Vector3.new(0.3, 11.5, 11.5), Vector3.new(-9, top + 6, -8), color(theme.Glow),
        { shape = "Cylinder", material = Enum.Material.Neon, rotation = CFrame.Angles(0, 0, math.pi / 2 - 0.35) })
    add("DishBase", Vector3.new(2.4, 1.4, 1.4), Vector3.new(11, top + 1.2, -8), Color3.fromRGB(200, 205, 220), { shape = "Cylinder", rotation = Upright })
    add("Dish", Vector3.new(0.5, 6, 6), Vector3.new(11, top + 3.6, -8), Color3.fromRGB(225, 230, 240), { shape = "Cylinder", rotation = CFrame.Angles(0, 0, math.pi / 2 - 0.6) })
    add("DishAntenna", Vector3.new(0.3, 0.3, 3.2), Vector3.new(11, top + 4.6, -7), color(theme.Glow), { material = Enum.Material.Neon })
    for n, offset in ipairs({ { -16, 6, 2 }, { -2, 9, -2 }, { 4, 7, 6 }, { 17, 10, 2 }, { 8, 12, -12 }, { -14, 11, -14 } }) do
        add("Star" .. n, Vector3.new(0.9, 0.9, 0.9), Vector3.new(offset[1], top + offset[2], offset[3]), color(theme.Glow), { shape = "Ball", material = Enum.Material.Neon })
    end
end
Decor[6] = function(add, theme) -- Fry Palace: gold columns, a crown on the roof, a red carpet, banners
    local top = CeilingBottom + 1.4
    for _, x in ipairs({ -20, 20 }) do
        add("Column", Vector3.new(CeilingBottom, 2.4, 2.4), Vector3.new(x, CeilingBottom / 2 + 0.5, 15.4), color(theme.Trim), { shape = "Cylinder", rotation = Upright, collide = true })
        add("Banner", Vector3.new(3, 8, 0.2), Vector3.new(x * 0.6, 11, 14.9), color(theme.Main))
        add("BannerStripe", Vector3.new(3, 0.6, 0.25), Vector3.new(x * 0.6, 7.3, 14.95), color(theme.Trim))
    end
    add("CrownBase", Vector3.new(2, 10, 10), Vector3.new(0, top + 1, -5), color(theme.Trim), { shape = "Cylinder", rotation = Upright })
    for n = 0, 5 do
        local angle = n * math.pi / 3
        local x, z = math.cos(angle) * 4.2, -5 + math.sin(angle) * 4.2
        add("CrownSpike", Vector3.new(1.4, 3.2, 1.4), Vector3.new(x, top + 3.4, z), color(theme.Trim), { rotation = CFrame.Angles(0, -angle, 0) })
        add("CrownJewel", Vector3.new(1.2, 1.2, 1.2), Vector3.new(x, top + 5.4, z), if n % 2 == 0 then Color3.fromRGB(230, 57, 70) else color(theme.Main),
            { shape = "Ball", material = Enum.Material.Neon })
    end
    add("RedCarpet", Vector3.new(6, 0.08, 12), Vector3.new(0, 0.42, 20), Color3.fromRGB(196, 30, 58))
end

-- Dresses the station for a tier: stands, theme colours, roof sign, decoration, and kiosk.
function TierBuilder.apply(station, tier, ownerName)
    tier = math.clamp(tier or 1, 1, Restaurants.Max)
    local info = Restaurants.Tiers[tier]
    for _, stand in ipairs(station.standOrder) do showStand(stand, tier) end
    for _, entry in ipairs(station.themed) do
        local name = entry.part.Name
        if tier == 1 then entry.part.Color = entry.original
        elseif name == "RestaurantFloor" then entry.part.Color = color(info.Theme.Floor)
        elseif string.sub(name, 1, 12) == "AwningStripe" and tonumber(string.sub(name, 13)) % 2 == 0 then entry.part.Color = color(info.Theme.Trim)
        else entry.part.Color = color(info.Theme.Main) end
    end
    local old = station.model:FindFirstChild("TierDecor")
    if old then old:Destroy() end
    if tier >= 2 then
        local folder = Instance.new("Folder")
        folder.Name, folder.Parent = "TierDecor", station.model
        local add = adder(station, folder)
        local board = add("RoofSign", Vector3.new(22, 4.5, 0.6), Vector3.new(0, CeilingBottom + 4.6, 12), color(info.Theme.Main))
        sign(board, string.upper(info.Name), color(info.Theme.Glow))
        for _, x in ipairs({ -8, 8 }) do add("RoofSignPost", Vector3.new(0.6, 3, 0.6), Vector3.new(x, CeilingBottom + 2.4, 12), color(info.Theme.Trim)) end
        add("NeonStrip", Vector3.new(42, 0.3, 0.3), Vector3.new(0, CeilingBottom - 3.4, 14.8), color(info.Theme.Glow), { material = Enum.Material.Neon })
        Decor[tier](add, info.Theme)
    end
    local kiosk, nextTier = station.kiosk, Restaurants.Tiers[tier + 1]
    kiosk.podium.Color = if tier == 1 then station.accent else color(info.Theme.Main)
    kiosk.label.Text = if nextTier then "EXPAND\n" .. string.upper(nextTier.Name) .. "  " .. Format.money(nextTier.Price) else "FULLY\nUPGRADED"
    if ownerName then station.sign.Text = ownerName .. "'s\n" .. string.upper(info.Name) end
    station.model:SetAttribute("RestaurantTier", tier)
    station.shownTier = tier
end
return TierBuilder
