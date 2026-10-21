-- Code-built cartoon pet models (no uploaded assets). Each pet is a short recipe of smooth
-- parts plus a shared face: white eyes with dark pupils and a shine, blush cheeks, and a smile.
-- Pets face -Z. Models are about 2 studs tall. Golden pets get a gold body, a slight shine,
-- and two sparkles. Used by the following pets and by the UI portraits.
local PetModels = {}
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local Ink, White, Blush = rgb(45, 30, 30), rgb(255, 255, 255), rgb(255, 150, 160)
local Gold = rgb(255, 204, 64)
local Upright = CFrame.Angles(0, 0, math.pi / 2) -- turns a Cylinder (X axis) to stand on Y

-- Builder: collects parts with their local offsets.
local function builder(model, golden)
    local pieces = {}
    local b = {}
    function b.add(shape, size, position, color, options)
        options = options or {}
        local part = Instance.new("Part")
        part.Shape = if shape == "Ball" then Enum.PartType.Ball elseif shape == "Cylinder" then Enum.PartType.Cylinder else Enum.PartType.Block
        part.Size = Vector3.new(size[1], size[2], size[3])
        part.Color = color
        part.Transparency = options.transparency or 0
        part.Material = if options.neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
        part.Reflectance = if golden and options.body then 0.3 else 0
        part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
        part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery, part.CastShadow = true, false, false, false, false
        part.Name = options.name or shape
        part.Parent = model
        local offset = CFrame.new(Vector3.new(position[1], position[2], position[3]))
        if options.upright then offset = offset * Upright end
        if options.rotation then offset = offset * options.rotation end
        table.insert(pieces, { part = part, offset = offset })
        return part
    end
    -- Body pieces turn gold on Golden pets.
    function b.body(shape, size, position, color, options)
        options = options or {}
        options.body, options.name = true, options.name or "Body"
        return b.add(shape, size, position, if golden then Gold else color, options)
    end
    -- Eyes, blush, and a smile on the front surface at depth z (negative), centred at height y.
    function b.face(z, y, spread, eyeSize)
        spread, eyeSize = spread or 0.24, eyeSize or 0.34
        for _, side in ipairs({ -1, 1 }) do
            local x = side * spread
            b.add("Ball", { eyeSize, eyeSize, eyeSize }, { x, y, z - 0.02 }, White, { name = "Eye" })
            b.add("Ball", { eyeSize * 0.62, eyeSize * 0.62, eyeSize * 0.62 }, { x, y - 0.02, z - eyeSize * 0.3 }, Ink, { name = "Pupil" })
            b.add("Ball", { eyeSize * 0.22, eyeSize * 0.22, eyeSize * 0.22 }, { x + 0.04, y + 0.06, z - eyeSize * 0.48 }, White, { name = "Shine" })
            b.add("Ball", { 0.18, 0.18, 0.18 }, { side * (spread + 0.2), y - 0.22, z - 0.02 }, Blush, { name = "Blush", transparency = 0.15 })
        end
        b.add("Block", { 0.18, 0.05, 0.05 }, { 0, y - 0.26, z - 0.03 }, Ink, { name = "Smile" })
    end
    function b.feet(y, spread, color)
        for _, side in ipairs({ -1, 1 }) do
            b.add("Ball", { 0.36, 0.36, 0.36 }, { side * (spread or 0.28), y, -0.05 }, color or Ink, { name = "Foot" })
        end
    end
    function b.sparkles()
        if not golden then return end
        b.add("Ball", { 0.16, 0.16, 0.16 }, { 0.75, 0.9, -0.2 }, rgb(255, 245, 190), { name = "Sparkle", neon = true })
        b.add("Ball", { 0.12, 0.12, 0.12 }, { -0.7, 0.3, -0.25 }, rgb(255, 245, 190), { name = "Sparkle", neon = true })
    end
    return b, pieces
end

local Recipes = {}
function Recipes.CrinkleFry(b)
    b.body("Block", { 0.8, 1.9, 0.8 }, { 0, 0.1, 0 }, rgb(255, 214, 90))
    for index, y in ipairs({ -0.5, 0.05, 0.6 }) do
        b.add("Block", { 0.84, 0.1, 0.84 }, { 0, y, 0 }, rgb(236, 176, 52), { name = "Crinkle" .. index })
    end
    b.add("Block", { 0.82, 0.22, 0.82 }, { 0, 1.0, 0 }, rgb(214, 140, 40), { name = "Toast" })
    b.face(-0.41, 0.35, 0.18, 0.28)
    b.feet(-0.92, 0.22, rgb(214, 140, 40))
end
function Recipes.SaltShaker(b)
    b.body("Cylinder", { 1.4, 1.1, 1.1 }, { 0, 0, 0 }, rgb(246, 246, 242), { upright = true })
    b.add("Cylinder", { 0.42, 1.16, 1.16 }, { 0, 0.88, 0 }, rgb(170, 180, 194), { upright = true, name = "Cap" })
    for index, x in ipairs({ -0.22, 0, 0.22 }) do
        b.add("Ball", { 0.1, 0.1, 0.1 }, { x, 1.1, -0.1 }, Ink, { name = "Hole" .. index })
    end
    b.face(-0.56, 0.05)
    b.feet(-0.78)
end
function Recipes.PaperCup(b)
    b.body("Cylinder", { 1.3, 1.2, 1.2 }, { 0, -0.1, 0 }, rgb(232, 72, 72), { upright = true })
    b.add("Cylinder", { 0.46, 1.24, 1.24 }, { 0, -0.05, 0 }, rgb(255, 248, 236), { upright = true, name = "Band" })
    for index, spot in ipairs({ { -0.3, 0.05 }, { 0, -0.12 }, { 0.3, 0.08 } }) do
        b.add("Block", { 0.2, 0.9, 0.2 }, { spot[1], 0.85, spot[2] }, rgb(255, 214, 90), { name = "Fry" .. index })
    end
    b.face(-0.63, -0.05, 0.24, 0.3)
    b.feet(-0.82)
end
function Recipes.PotatoPup(b)
    b.body("Ball", { 1.6, 1.6, 1.6 }, { 0, 0, 0 }, rgb(196, 150, 92))
    for _, side in ipairs({ -1, 1 }) do
        b.add("Ball", { 0.6, 0.6, 0.6 }, { side * 0.6, 0.62, 0.05 }, rgb(150, 105, 60), { name = "Ear" })
    end
    b.add("Ball", { 0.62, 0.62, 0.62 }, { 0, -0.15, -0.62 }, rgb(232, 196, 140), { name = "Snout" })
    b.add("Ball", { 0.2, 0.2, 0.2 }, { 0, -0.05, -0.92 }, Ink, { name = "Nose" })
    b.add("Ball", { 0.3, 0.3, 0.3 }, { 0, -0.1, 0.82 }, rgb(150, 105, 60), { name = "Tail" })
    b.add("Ball", { 0.3, 0.3, 0.3 }, { 0.45, 0.25, -0.58 }, rgb(170, 125, 75), { name = "Spot" })
    b.face(-0.7, 0.22, 0.3, 0.3)
    b.feet(-0.78, 0.4, rgb(150, 105, 60))
end
function Recipes.KetchupPacket(b)
    b.body("Block", { 1.5, 1.2, 0.32 }, { 0, 0, 0 }, rgb(222, 44, 44))
    b.add("Block", { 1.1, 0.7, 0.05 }, { 0, -0.05, -0.18 }, rgb(255, 248, 236), { name = "Label" })
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.18, 0.18, 0.34 }, { side * 0.66, 0.52, 0 }, rgb(180, 30, 30), { name = "Corner" })
    end
    b.add("Ball", { 0.24, 0.24, 0.24 }, { 0.5, -0.66, -0.05 }, rgb(200, 30, 30), { name = "Drip" })
    b.face(-0.21, 0.0, 0.22, 0.26)
    b.feet(-0.72, 0.4)
end
function Recipes.NapkinGhost(b)
    b.body("Ball", { 1.6, 1.6, 1.6 }, { 0, 0.15, 0 }, rgb(252, 252, 255), { transparency = 0.08 })
    for index, x in ipairs({ -0.5, 0, 0.5 }) do
        b.add("Ball", { 0.62, 0.62, 0.62 }, { x, -0.6, 0 }, rgb(252, 252, 255), { name = "Skirt" .. index, transparency = 0.08 })
    end
    b.add("Block", { 1.7, 0.1, 0.4 }, { 0, -0.05, -0.62 }, rgb(150, 205, 232), { name = "Stripe" })
    b.face(-0.78, 0.35, 0.28, 0.32)
end
function Recipes.CurlyFryCat(b)
    b.body("Ball", { 1.5, 1.5, 1.5 }, { 0, 0, 0 }, rgb(240, 150, 60))
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.42, 0.42, 0.22 }, { side * 0.45, 0.72, 0 }, rgb(214, 118, 40), { name = "Ear", rotation = CFrame.Angles(0, 0, math.pi / 4) })
    end
    for index, spot in ipairs({ { 0.62, 0.0 }, { 0.8, 0.28 }, { 0.68, 0.55 }, { 0.42, 0.62 } }) do
        b.add("Ball", { 0.24, 0.24, 0.24 }, { spot[1], spot[2], 0.55 }, rgb(214, 118, 40), { name = "Curl" .. index })
    end
    b.add("Block", { 1.3, 0.1, 0.1 }, { 0, 0.1, -0.7 }, rgb(214, 118, 40), { name = "Stripe" })
    b.face(-0.68, 0.22, 0.28, 0.32)
    b.feet(-0.7, 0.36, rgb(214, 118, 40))
end
function Recipes.MayoJar(b)
    b.body("Cylinder", { 1.4, 1.2, 1.2 }, { 0, 0, 0 }, rgb(252, 246, 222), { upright = true })
    b.add("Cylinder", { 0.34, 1.28, 1.28 }, { 0, 0.85, 0 }, rgb(92, 150, 232), { upright = true, name = "Lid" })
    b.add("Cylinder", { 0.5, 1.24, 1.24 }, { 0, -0.12, 0 }, rgb(255, 214, 90), { upright = true, name = "Label" })
    b.face(-0.63, 0.2, 0.24, 0.3)
    b.feet(-0.8)
end
function Recipes.FryerBot(b)
    b.body("Block", { 1.4, 1.2, 1.1 }, { 0, 0, 0 }, rgb(170, 186, 202))
    b.add("Block", { 1.0, 0.6, 0.06 }, { 0, 0.1, -0.56 }, rgb(126, 245, 215), { name = "Screen" })
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.18, 0.24, 0.05 }, { side * 0.22, 0.14, -0.6 }, Ink, { name = "Eye" })
        b.add("Block", { 0.2, 0.6, 0.2 }, { side * 0.82, -0.1, 0 }, rgb(140, 156, 172), { name = "Arm" })
    end
    b.add("Block", { 0.3, 0.06, 0.05 }, { 0, -0.08, -0.6 }, Ink, { name = "Smile" })
    b.add("Cylinder", { 0.5, 0.1, 0.1 }, { 0, 0.85, 0 }, rgb(120, 130, 145), { upright = true, name = "Antenna" })
    b.add("Ball", { 0.28, 0.28, 0.28 }, { 0, 1.15, 0 }, rgb(244, 112, 111), { name = "Light", neon = true })
    b.feet(-0.72, 0.36, rgb(120, 130, 145))
end
function Recipes.FryKing(b)
    b.body("Block", { 1.0, 2.0, 1.0 }, { 0, 0.05, 0 }, rgb(255, 206, 64))
    for index, y in ipairs({ -0.55, 0.0 }) do
        b.add("Block", { 1.04, 0.1, 1.04 }, { 0, y, 0 }, rgb(236, 170, 40), { name = "Crinkle" .. index })
    end
    b.add("Block", { 1.0, 1.6, 0.1 }, { 0, -0.1, 0.56 }, rgb(200, 40, 50), { name = "Cape" })
    b.add("Cylinder", { 0.36, 1.1, 1.1 }, { 0, 1.22, 0 }, rgb(255, 176, 0), { upright = true, name = "Crown", body = false })
    for index, spot in ipairs({ { -0.32, rgb(220, 50, 70) }, { 0, rgb(70, 130, 230) }, { 0.32, rgb(220, 50, 70) } }) do
        b.add("Ball", { 0.24, 0.24, 0.24 }, { spot[1], 1.5, -0.25 }, spot[2], { name = "Jewel" .. index })
    end
    b.face(-0.51, 0.45, 0.22, 0.32)
    b.feet(-0.98, 0.26, rgb(214, 140, 40))
end
-- Fry Diner (Deluxe Fryer)
function Recipes.OnionRing(b)
    b.body("Cylinder", { 0.7, 1.8, 1.8 }, { 0, 0, 0 }, rgb(226, 166, 72), { upright = true })
    b.add("Cylinder", { 0.72, 0.7, 0.7 }, { 0, 0.02, 0 }, rgb(250, 238, 214), { upright = true, name = "Hole" })
    for index, spot in ipairs({ { -0.6, -0.4 }, { 0.55, -0.5 }, { 0.7, 0.3 }, { -0.5, 0.55 } }) do
        b.add("Ball", { 0.2, 0.2, 0.2 }, { spot[1], 0.36, spot[2] }, rgb(196, 130, 50), { name = "Crumb" .. index })
    end
    b.face(-0.9, 0.02, 0.24, 0.26)
    b.feet(-0.5, 0.42, rgb(196, 130, 50))
end
function Recipes.PickleChip(b)
    local facing = CFrame.Angles(0, math.pi / 2, 0)
    b.body("Cylinder", { 0.32, 1.6, 1.6 }, { 0, 0, 0 }, rgb(118, 176, 64), { rotation = facing })
    b.add("Cylinder", { 0.34, 1.1, 1.1 }, { 0, 0, 0 }, rgb(170, 214, 100), { rotation = facing, name = "Core" })
    for index, spot in ipairs({ { -0.3, 0.3 }, { 0.32, 0.25 }, { 0, -0.4 }, { -0.4, -0.2 } }) do
        b.add("Ball", { 0.14, 0.14, 0.14 }, { spot[1], spot[2], -0.17 }, rgb(240, 236, 190), { name = "Seed" .. index })
    end
    b.face(-0.2, 0.15, 0.24, 0.28)
    b.feet(-0.86, 0.3, rgb(80, 130, 40))
end
function Recipes.HashBrownHamster(b)
    b.body("Block", { 1.5, 1.2, 1.2 }, { 0, -0.05, 0 }, rgb(214, 160, 78))
    for index, spot in ipairs({ { -0.5, 0.3 }, { 0.4, -0.2 }, { 0.1, 0.4 }, { -0.2, -0.35 } }) do
        b.add("Block", { 0.2, 0.06, 0.2 }, { spot[1], 0.56, spot[2] }, rgb(186, 126, 52), { name = "Crisp" .. index })
    end
    for _, side in ipairs({ -1, 1 }) do
        b.add("Ball", { 0.42, 0.42, 0.42 }, { side * 0.55, 0.62, 0.1 }, rgb(240, 196, 150), { name = "Ear" })
        b.add("Ball", { 0.46, 0.46, 0.46 }, { side * 0.5, -0.25, -0.5 }, rgb(240, 196, 150), { name = "Cheek" })
    end
    b.face(-0.61, 0.18, 0.26, 0.3)
    b.feet(-0.7, 0.4, rgb(186, 126, 52))
end
function Recipes.Milkshake(b)
    b.body("Cylinder", { 1.3, 1.1, 1.1 }, { 0, -0.15, 0 }, rgb(255, 170, 200), { upright = true })
    b.add("Cylinder", { 0.18, 1.2, 1.2 }, { 0, 0.5, 0 }, rgb(255, 255, 255), { upright = true, name = "Rim" })
    b.add("Ball", { 1.0, 1.0, 1.0 }, { 0, 0.75, 0 }, rgb(255, 252, 245), { name = "Cream" })
    b.add("Ball", { 0.36, 0.36, 0.36 }, { 0, 1.3, 0 }, rgb(220, 30, 50), { name = "Cherry" })
    b.add("Block", { 0.14, 1.3, 0.14 }, { 0.3, 1.2, 0.15 }, rgb(230, 57, 70), { name = "Straw", rotation = CFrame.Angles(0, 0, -0.3) })
    b.face(-0.56, -0.05, 0.22, 0.28)
    b.feet(-0.86, 0.3, rgb(220, 120, 160))
end
function Recipes.CheeseSlime(b)
    b.body("Ball", { 1.7, 1.7, 1.7 }, { 0, 0.05, 0 }, rgb(255, 190, 40), { transparency = 0.08 })
    for index, spot in ipairs({ { -0.55, -0.1 }, { 0.15, -0.35 }, { 0.6, 0.0 } }) do
        b.add("Ball", { 0.42, 0.42, 0.42 }, { spot[1], -0.75, spot[2] }, rgb(255, 170, 20), { name = "Drip" .. index })
    end
    b.add("Ball", { 0.5, 0.5, 0.5 }, { 0.35, 0.75, 0.1 }, rgb(255, 214, 90), { name = "Bubble" })
    b.face(-0.82, 0.2, 0.3, 0.34)
end
function Recipes.FryPhoenix(b)
    b.body("Ball", { 1.4, 1.4, 1.4 }, { 0, 0.1, 0 }, rgb(240, 90, 40))
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 1.0, 0.18, 0.7 }, { side * 0.95, 0.3, 0.1 }, rgb(255, 160, 40), { name = "Wing", rotation = CFrame.Angles(0, 0, side * 0.5) })
        b.add("Block", { 0.7, 0.14, 0.5 }, { side * 1.25, 0.65, 0.15 }, rgb(255, 214, 90), { name = "WingTip", rotation = CFrame.Angles(0, 0, side * 0.8) })
    end
    for index, x in ipairs({ -0.22, 0, 0.22 }) do
        b.add("Block", { 0.16, 0.6 + (index % 2) * 0.2, 0.16 }, { x, 0.95, 0 }, rgb(255, 214, 90), { name = "Crest" .. index })
    end
    b.add("Block", { 0.5, 0.18, 0.9 }, { 0, -0.1, 0.85 }, rgb(255, 130, 30), { name = "Tail", rotation = CFrame.Angles(0.5, 0, 0) })
    b.add("Block", { 0.2, 0.14, 0.24 }, { 0, 0.02, -0.72 }, rgb(255, 200, 40), { name = "Beak" })
    b.face(-0.64, 0.3, 0.26, 0.3)
    b.feet(-0.66, 0.26, rgb(255, 160, 40))
end
-- Drive-In (Drive-In Grill)
function Recipes.SesameBun(b)
    b.body("Ball", { 1.6, 1.6, 1.6 }, { 0, 0, 0 }, rgb(232, 168, 82))
    b.add("Cylinder", { 0.3, 1.5, 1.5 }, { 0, -0.62, 0 }, rgb(250, 224, 170), { upright = true, name = "Base" })
    for index, spot in ipairs({ { -0.3, 0.62, -0.2 }, { 0.25, 0.68, 0.05 }, { 0, 0.72, 0.3 }, { 0.42, 0.5, -0.35 }, { -0.5, 0.48, 0.25 } }) do
        b.add("Block", { 0.14, 0.06, 0.2 }, { spot[1], spot[2], spot[3] }, rgb(255, 248, 230), { name = "Seed" .. index, rotation = CFrame.Angles(0, index, 0) })
    end
    b.face(-0.74, 0.05, 0.28, 0.32)
    b.feet(-0.78, 0.4, rgb(200, 130, 60))
end
function Recipes.MustardBottle(b)
    b.body("Cylinder", { 1.5, 1.0, 1.0 }, { 0, -0.1, 0 }, rgb(255, 204, 0), { upright = true })
    b.add("Cylinder", { 0.3, 0.7, 0.7 }, { 0, 0.78, 0 }, rgb(230, 57, 70), { upright = true, name = "Cap" })
    b.add("Cylinder", { 0.4, 0.2, 0.2 }, { 0, 1.1, 0 }, rgb(230, 57, 70), { upright = true, name = "Nozzle" })
    b.add("Block", { 0.7, 0.32, 0.05 }, { 0, -0.4, -0.5 }, rgb(230, 57, 70), { name = "Label" })
    b.face(-0.51, 0.18, 0.2, 0.28)
    b.feet(-0.9, 0.28, rgb(200, 150, 0))
end
function Recipes.PaperTray(b)
    b.body("Block", { 1.6, 0.7, 1.1 }, { 0, -0.3, 0 }, rgb(255, 250, 240))
    for index, x in ipairs({ -0.6, -0.2, 0.2, 0.6 }) do
        b.add("Block", { 0.2, 0.72, 1.12 }, { x, -0.3, 0 }, rgb(230, 57, 70), { name = "Check" .. index })
    end
    for index, spot in ipairs({ { -0.45, 0.1 }, { -0.15, -0.15 }, { 0.15, 0.2 }, { 0.45, -0.05 }, { 0, 0.05 } }) do
        b.add("Block", { 0.18, 0.9, 0.18 }, { spot[1], 0.35, spot[2] }, rgb(255, 214, 90), { name = "Fry" .. index, rotation = CFrame.Angles(0, 0, spot[1] * 0.4) })
    end
    b.face(-0.57, -0.3, 0.3, 0.28)
    b.feet(-0.78, 0.5)
end
function Recipes.BurgerBear(b)
    b.body("Ball", { 1.6, 1.6, 1.6 }, { 0, -0.05, 0 }, rgb(156, 98, 56))
    for _, side in ipairs({ -1, 1 }) do
        b.add("Ball", { 0.5, 0.5, 0.5 }, { side * 0.6, 0.6, 0.05 }, rgb(126, 76, 42), { name = "Ear" })
    end
    b.add("Ball", { 0.6, 0.6, 0.6 }, { 0, -0.25, -0.6 }, rgb(222, 180, 130), { name = "Snout" })
    b.add("Ball", { 0.2, 0.2, 0.2 }, { 0, -0.12, -0.9 }, Ink, { name = "Nose" })
    b.add("Cylinder", { 0.22, 0.9, 0.9 }, { 0, 0.82, 0 }, rgb(232, 168, 82), { upright = true, name = "MiniBun" })
    b.add("Cylinder", { 0.16, 0.95, 0.95 }, { 0, 0.98, 0 }, rgb(110, 60, 35), { upright = true, name = "MiniPatty" })
    b.add("Ball", { 0.8, 0.8, 0.8 }, { 0, 1.15, 0 }, rgb(232, 168, 82), { name = "MiniTop" })
    b.face(-0.72, 0.2, 0.28, 0.3)
    b.feet(-0.8, 0.4, rgb(126, 76, 42))
end
function Recipes.SodaSeal(b)
    b.body("Ball", { 1.5, 1.5, 1.5 }, { 0, -0.05, 0 }, rgb(130, 160, 190))
    b.add("Ball", { 0.7, 0.7, 0.7 }, { 0, -0.4, -0.45 }, rgb(200, 215, 230), { name = "Belly" })
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.6, 0.14, 0.4 }, { side * 0.75, -0.45, -0.1 }, rgb(100, 130, 160), { name = "Flipper", rotation = CFrame.Angles(0, 0, side * -0.4) })
    end
    b.add("Cylinder", { 0.7, 0.62, 0.62 }, { 0, 0.95, 0 }, rgb(230, 57, 70), { upright = true, name = "Cup" })
    b.add("Block", { 0.1, 0.7, 0.1 }, { 0.1, 1.4, 0 }, rgb(255, 255, 255), { name = "Straw", rotation = CFrame.Angles(0, 0, -0.2) })
    b.face(-0.68, 0.15, 0.26, 0.3)
end
function Recipes.HotDogPup(b)
    b.body("Cylinder", { 1.9, 0.8, 0.8 }, { 0, 0.05, 0 }, rgb(196, 80, 60))
    b.add("Block", { 1.7, 0.4, 1.0 }, { 0, -0.35, 0 }, rgb(232, 178, 100), { name = "Bun" })
    for index = 0, 3 do
        b.add("Block", { 0.3, 0.06, 0.12 }, { -0.6 + index * 0.4, 0.46, (index % 2) * 0.15 - 0.07 }, rgb(255, 204, 0), { name = "Mustard" .. index, rotation = CFrame.Angles(0, (index % 2 - 0.5) * 1.2, 0) })
    end
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.22, 0.5, 0.36 }, { side * 0.55, 0.45, 0.05 }, rgb(150, 56, 40), { name = "Ear", rotation = CFrame.Angles(0, 0, side * 0.5) })
    end
    b.add("Ball", { 0.3, 0.3, 0.3 }, { 1.0, 0.1, 0 }, rgb(150, 56, 40), { name = "Tail" })
    b.face(-0.42, 0.1, 0.24, 0.26)
    b.feet(-0.7, 0.5, rgb(150, 56, 40))
end
function Recipes.CarhopBot(b)
    b.body("Block", { 1.2, 1.3, 1.0 }, { 0, 0.05, 0 }, rgb(42, 157, 143))
    b.add("Block", { 0.9, 0.55, 0.06 }, { 0, 0.15, -0.51 }, rgb(255, 250, 240), { name = "Screen" })
    b.add("Cylinder", { 0.3, 1.0, 1.0 }, { 0, 0.85, 0 }, rgb(230, 57, 70), { upright = true, name = "Cap" })
    b.add("Block", { 0.7, 0.08, 0.5 }, { 0.85, 0.35, -0.2 }, rgb(200, 205, 215), { name = "Tray" })
    b.add("Cylinder", { 0.36, 0.3, 0.3 }, { 0.85, 0.58, -0.2 }, rgb(230, 57, 70), { upright = true, name = "TrayCup" })
    for _, side in ipairs({ -1, 1 }) do
        b.add("Cylinder", { 0.2, 0.4, 0.4 }, { side * 0.3, -0.85, -0.2 }, rgb(247, 127, 0), { name = "Wheel" })
        b.add("Cylinder", { 0.2, 0.4, 0.4 }, { side * 0.3, -0.85, 0.2 }, rgb(247, 127, 0), { name = "Wheel" })
    end
    b.face(-0.55, 0.15, 0.2, 0.26)
end
function Recipes.BurgerDragon(b)
    b.body("Ball", { 1.6, 1.6, 1.6 }, { 0, 0.05, 0 }, rgb(90, 180, 80))
    b.add("Ball", { 0.9, 0.9, 0.9 }, { 0, -0.25, -0.45 }, rgb(232, 168, 82), { name = "Belly" })
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.9, 0.12, 0.7 }, { side * 0.95, 0.45, 0.2 }, rgb(60, 140, 60), { name = "Wing", rotation = CFrame.Angles(0, 0, side * 0.6) })
        b.add("Block", { 0.16, 0.5, 0.16 }, { side * 0.35, 0.95, 0 }, rgb(255, 214, 90), { name = "Horn", rotation = CFrame.Angles(0, 0, side * -0.35) })
    end
    b.add("Block", { 0.3, 0.3, 1.0 }, { 0, -0.35, 0.95 }, rgb(70, 160, 70), { name = "Tail", rotation = CFrame.Angles(0.4, 0, 0) })
    b.add("Ball", { 0.24, 0.24, 0.24 }, { 0, 0.3, -0.85 }, rgb(255, 120, 40), { name = "Ember", neon = true })
    b.face(-0.74, 0.35, 0.28, 0.32)
    b.feet(-0.8, 0.4, rgb(60, 140, 60))
end
-- Fish & Chips Pier (Pier Fryer)
function Recipes.FishStick(b)
    b.body("Block", { 1.9, 0.8, 0.8 }, { 0, -0.1, 0 }, rgb(230, 170, 70))
    for index, spot in ipairs({ { -0.6, 0.31 }, { -0.1, 0.32 }, { 0.5, 0.31 }, { 0.2, 0.3 } }) do
        b.add("Block", { 0.16, 0.06, 0.16 }, { spot[1], spot[2], (index % 2) * 0.3 - 0.15 }, rgb(196, 130, 50), { name = "Crumb" .. index })
    end
    b.add("Block", { 0.1, 0.5, 0.5 }, { 1.0, -0.1, 0 }, rgb(196, 130, 50), { name = "Tail", rotation = CFrame.Angles(math.pi / 4, 0, 0) })
    b.face(-0.41, -0.05, 0.26, 0.26)
    b.feet(-0.65, 0.5, rgb(196, 130, 50))
end
function Recipes.TartarTub(b)
    b.body("Cylinder", { 1.0, 1.3, 1.3 }, { 0, -0.2, 0 }, rgb(250, 246, 226), { upright = true })
    b.add("Ball", { 1.1, 1.1, 1.1 }, { 0, 0.25, 0 }, rgb(245, 240, 215), { name = "Sauce" })
    for index, spot in ipairs({ { -0.3, 0.1 }, { 0.2, -0.2 }, { 0.1, 0.3 }, { -0.1, -0.3 } }) do
        b.add("Block", { 0.12, 0.06, 0.12 }, { spot[1], 0.78, spot[2] }, rgb(110, 170, 60), { name = "Fleck" .. index })
    end
    b.add("Cylinder", { 0.16, 1.36, 1.36 }, { 0, -0.62, 0 }, rgb(29, 111, 216), { upright = true, name = "Band" })
    b.face(-0.66, -0.15, 0.26, 0.3)
    b.feet(-0.78, 0.36, rgb(29, 111, 216))
end
function Recipes.NewspaperCone(b)
    b.body("Cylinder", { 1.4, 1.1, 1.1 }, { 0, -0.15, 0 }, rgb(226, 224, 216), { upright = true })
    for index, y in ipairs({ -0.5, -0.25, 0.0 }) do
        b.add("Block", { 0.6, 0.06, 0.05 }, { 0.15, y, -0.56 }, rgb(90, 90, 90), { name = "Print" .. index })
    end
    for index, spot in ipairs({ { -0.3, 0.1 }, { 0, -0.15 }, { 0.3, 0.12 }, { 0.12, 0.25 } }) do
        b.add("Block", { 0.2, 0.9, 0.2 }, { spot[1], 0.85, spot[2] }, rgb(255, 214, 90), { name = "Chip" .. index, rotation = CFrame.Angles(0, 0, spot[1] * 0.5) })
    end
    b.face(-0.56, 0.3, 0.22, 0.28)
    b.feet(-0.9, 0.3)
end
function Recipes.ChipCrab(b)
    b.body("Block", { 1.5, 0.8, 1.1 }, { 0, -0.15, 0 }, rgb(240, 90, 60))
    for _, side in ipairs({ -1, 1 }) do
        b.add("Ball", { 0.55, 0.55, 0.55 }, { side * 1.0, 0.1, -0.35 }, rgb(240, 90, 60), { name = "Claw" })
        b.add("Block", { 0.3, 0.12, 0.12 }, { side * 0.75, -0.1, -0.2 }, rgb(220, 70, 45), { name = "Arm" })
        for index = 0, 1 do
            b.add("Block", { 0.4, 0.1, 0.1 }, { side * 0.85, -0.5, -0.1 + index * 0.35 }, rgb(220, 70, 45), { name = "Leg", rotation = CFrame.Angles(0, 0, side * 0.6) })
        end
    end
    b.add("Block", { 0.16, 0.7, 0.16 }, { 1.0, 0.55, -0.35 }, rgb(255, 214, 90), { name = "Chip", rotation = CFrame.Angles(0, 0, -0.3) })
    b.face(-0.56, 0.0, 0.26, 0.3)
end
function Recipes.VinegarOwl(b)
    b.body("Cylinder", { 1.4, 1.2, 1.2 }, { 0, -0.1, 0 }, rgb(140, 92, 46), { upright = true, transparency = 0.15 })
    b.add("Cylinder", { 0.3, 0.5, 0.5 }, { 0, 0.75, 0 }, rgb(90, 60, 30), { upright = true, name = "Cork" })
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.22, 0.4, 0.22 }, { side * 0.42, 0.72, 0 }, rgb(110, 72, 36), { name = "Tuft", rotation = CFrame.Angles(0, 0, side * -0.4) })
        b.add("Block", { 0.14, 0.7, 0.5 }, { side * 0.66, -0.15, 0 }, rgb(110, 72, 36), { name = "Wing" })
    end
    b.add("Block", { 0.18, 0.16, 0.16 }, { 0, 0.02, -0.62 }, rgb(255, 170, 40), { name = "Beak" })
    b.face(-0.61, 0.25, 0.24, 0.36)
    b.feet(-0.86, 0.3, rgb(255, 170, 40))
end
function Recipes.SeagullThief(b)
    b.body("Ball", { 1.4, 1.4, 1.4 }, { 0, 0.05, 0 }, rgb(250, 250, 250))
    b.add("Block", { 1.2, 0.3, 0.1 }, { 0, 0.3, -0.62 }, Ink, { name = "Mask" })
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.9, 0.12, 0.6 }, { side * 0.85, 0.15, 0.1 }, rgb(170, 180, 190), { name = "Wing", rotation = CFrame.Angles(0, 0, side * 0.3) })
    end
    b.add("Block", { 0.24, 0.16, 0.4 }, { 0, -0.05, -0.8 }, rgb(255, 170, 40), { name = "Beak" })
    b.add("Block", { 0.14, 0.14, 0.9 }, { 0.12, -0.12, -1.0 }, rgb(255, 214, 90), { name = "StolenFry", rotation = CFrame.Angles(0, 0.6, 0) })
    b.face(-0.71, 0.3, 0.26, 0.3)
    b.feet(-0.7, 0.26, rgb(255, 170, 40))
end
function Recipes.BatterOctopus(b)
    b.body("Ball", { 1.6, 1.6, 1.6 }, { 0, 0.2, 0 }, rgb(226, 166, 72))
    for index = 0, 5 do
        local angle = index * math.pi / 3
        b.add("Cylinder", { 0.7, 0.3, 0.3 }, { math.cos(angle) * 0.55, -0.55, math.sin(angle) * 0.55 }, rgb(206, 140, 52),
            { name = "Tentacle" .. index, rotation = CFrame.Angles(0, -angle, -0.9) })
    end
    for index, spot in ipairs({ { -0.4, 0.8 }, { 0.3, 0.9 }, { 0.1, 0.6 } }) do
        b.add("Ball", { 0.2, 0.2, 0.2 }, { spot[1], spot[2], 0.2 }, rgb(196, 130, 50), { name = "Crumb" .. index })
    end
    b.face(-0.78, 0.3, 0.28, 0.32)
end
function Recipes.FryKraken(b)
    b.body("Ball", { 1.8, 1.8, 1.8 }, { 0, 0.25, 0 }, rgb(96, 64, 160))
    for index = 0, 7 do
        local angle = index * math.pi / 4
        b.add("Cylinder", { 0.8, 0.32, 0.32 }, { math.cos(angle) * 0.6, -0.55, math.sin(angle) * 0.6 }, rgb(72, 202, 228),
            { name = "Tentacle" .. index, rotation = CFrame.Angles(0, -angle, -0.9) })
    end
    for index, x in ipairs({ -0.35, 0, 0.35 }) do
        b.add("Block", { 0.18, 0.7, 0.18 }, { x, 1.35, 0 }, rgb(255, 214, 90), { name = "FryCrown" .. index })
    end
    b.face(-0.88, 0.35, 0.3, 0.36)
end
-- Cosmic Diner (Cosmic Fryer)
function Recipes.MoonFry(b)
    b.body("Block", { 0.85, 1.9, 0.85 }, { 0, 0.1, 0 }, rgb(226, 226, 204))
    for index, spot in ipairs({ { -0.2, 0.75 }, { 0.22, -0.25 }, { -0.15, -0.6 } }) do
        b.add("Ball", { 0.24, 0.24, 0.24 }, { spot[1], spot[2], -0.38 }, rgb(170, 170, 150), { name = "Crater" .. index })
    end
    b.face(-0.44, 0.35, 0.18, 0.28)
    b.feet(-0.92, 0.22, rgb(170, 170, 150))
end
function Recipes.StarSalt(b)
    b.body("Cylinder", { 1.4, 1.1, 1.1 }, { 0, 0, 0 }, rgb(40, 50, 110), { upright = true })
    b.add("Cylinder", { 0.42, 1.16, 1.16 }, { 0, 0.88, 0 }, rgb(200, 205, 220), { upright = true, name = "Cap" })
    for index, spot in ipairs({ { -0.3, 0.3 }, { 0.32, 0.4 }, { 0.2, -0.45 }, { -0.35, -0.35 } }) do
        b.add("Ball", { 0.12, 0.12, 0.12 }, { spot[1], spot[2], -0.55 }, rgb(255, 230, 120), { name = "Star" .. index, neon = true })
    end
    b.face(-0.56, 0.05)
    b.feet(-0.78)
end
function Recipes.AstroCup(b)
    b.body("Cylinder", { 1.2, 1.2, 1.2 }, { 0, -0.2, 0 }, rgb(240, 242, 250), { upright = true })
    b.add("Cylinder", { 0.3, 1.24, 1.24 }, { 0, -0.2, 0 }, rgb(76, 201, 240), { upright = true, name = "Band" })
    b.add("Ball", { 1.2, 1.2, 1.2 }, { 0, 0.55, 0 }, rgb(210, 240, 255), { name = "Helmet", transparency = 0.55 })
    for index, x in ipairs({ -0.2, 0.15 }) do
        b.add("Block", { 0.16, 0.7, 0.16 }, { x, 0.55, 0.05 }, rgb(255, 214, 90), { name = "Fry" .. index })
    end
    b.face(-0.62, -0.3, 0.24, 0.28)
    b.feet(-0.92, 0.32, rgb(76, 201, 240))
end
function Recipes.AlienTot(b)
    b.body("Cylinder", { 1.2, 1.2, 1.2 }, { 0, -0.05, 0 }, rgb(176, 220, 90), { upright = true })
    for index, y in ipairs({ -0.35, 0.05, 0.42 }) do
        b.add("Cylinder", { 0.06, 1.24, 1.24 }, { 0, y, 0 }, rgb(140, 190, 60), { upright = true, name = "Ridge" .. index })
    end
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.08, 0.6, 0.08 }, { side * 0.3, 0.85, 0 }, rgb(140, 190, 60), { name = "Antenna", rotation = CFrame.Angles(0, 0, side * -0.3) })
        b.add("Ball", { 0.24, 0.24, 0.24 }, { side * 0.42, 1.15, 0 }, rgb(255, 92, 168), { name = "AntennaTip", neon = true })
    end
    b.face(-0.61, 0.15, 0.26, 0.3)
    b.feet(-0.75, 0.34, rgb(140, 190, 60))
end
function Recipes.CometCola(b)
    b.body("Cylinder", { 1.4, 1.0, 1.0 }, { 0, 0, 0 }, rgb(76, 201, 240), { upright = true })
    b.add("Cylinder", { 0.12, 0.92, 0.92 }, { 0, 0.75, 0 }, rgb(200, 205, 220), { upright = true, name = "Lid" })
    b.add("Block", { 0.5, 0.25, 0.05 }, { 0, -0.2, -0.51 }, rgb(255, 255, 255), { name = "Label" })
    for index, spot in ipairs({ { 0.2, 0.9 }, { -0.15, 1.3 }, { 0.1, 1.7 } }) do
        b.add("Ball", { 0.5 - index * 0.1, 0.5 - index * 0.1, 0.5 - index * 0.1 }, { spot[1], 0.1, spot[2] }, rgb(255, 140, 40), { name = "Flame" .. index, neon = true })
    end
    b.face(-0.51, 0.2, 0.2, 0.28)
    b.feet(-0.8, 0.28)
end
function Recipes.SaucerBurger(b)
    b.body("Cylinder", { 0.5, 1.6, 1.6 }, { 0, -0.15, 0 }, rgb(110, 60, 35), { upright = true })
    b.add("Cylinder", { 0.4, 1.5, 1.5 }, { 0, -0.55, 0 }, rgb(232, 168, 82), { upright = true, name = "Bun" })
    b.add("Cylinder", { 0.12, 2.3, 2.3 }, { 0, -0.15, 0 }, rgb(76, 201, 240), { upright = true, name = "Rim", neon = true })
    b.add("Ball", { 1.2, 1.2, 1.2 }, { 0, 0.3, 0 }, rgb(210, 240, 255), { name = "Dome", transparency = 0.45 })
    b.add("Ball", { 0.7, 0.7, 0.7 }, { 0, 0.25, 0 }, rgb(232, 168, 82), { name = "TopBun" })
    b.face(-0.82, -0.15, 0.3, 0.26)
end
function Recipes.RoboChef(b)
    b.body("Block", { 1.3, 1.3, 1.0 }, { 0, -0.05, 0 }, rgb(196, 204, 216))
    b.add("Cylinder", { 0.5, 1.0, 1.0 }, { 0, 0.85, 0 }, rgb(255, 255, 255), { upright = true, name = "HatBand" })
    b.add("Ball", { 1.1, 1.1, 1.1 }, { 0, 1.3, 0 }, rgb(255, 255, 255), { name = "HatTop" })
    b.add("Block", { 0.12, 0.7, 0.12 }, { 0.9, 0.1, -0.2 }, rgb(150, 160, 175), { name = "SpatulaHandle" })
    b.add("Block", { 0.4, 0.3, 0.06 }, { 0.9, 0.55, -0.2 }, rgb(120, 130, 145), { name = "Spatula" })
    b.add("Block", { 0.7, 0.06, 0.05 }, { 0, -0.45, -0.51 }, rgb(76, 201, 240), { name = "Lights", neon = true })
    b.face(-0.51, 0.15, 0.24, 0.3)
    b.feet(-0.8, 0.36, rgb(150, 160, 175))
end
function Recipes.GalaxyFry(b)
    b.body("Block", { 1.0, 2.0, 1.0 }, { 0, 0.05, 0 }, rgb(70, 36, 128))
    for index, spot in ipairs({ { -0.25, 0.7 }, { 0.3, 0.2 }, { -0.3, -0.5 }, { 0.2, -0.75 } }) do
        b.add("Ball", { 0.12, 0.12, 0.12 }, { spot[1], spot[2], -0.5 }, rgb(255, 230, 140), { name = "Star" .. index, neon = true })
    end
    b.add("Block", { 1.0, 1.6, 0.1 }, { 0, -0.1, 0.56 }, rgb(76, 201, 240), { name = "Cape" })
    b.add("Cylinder", { 0.36, 1.1, 1.1 }, { 0, 1.22, 0 }, rgb(76, 201, 240), { upright = true, name = "Crown", neon = true })
    b.face(-0.51, 0.45, 0.22, 0.32)
    b.feet(-0.98, 0.26, rgb(50, 26, 100))
end
-- Fry Palace (Royal Fryer)
function Recipes.TruffleFry(b)
    b.body("Block", { 0.85, 1.9, 0.85 }, { 0, 0.1, 0 }, rgb(196, 140, 60))
    for index, spot in ipairs({ { -0.2, 0.6 }, { 0.25, 0.85 }, { 0.15, -0.3 }, { -0.25, -0.65 }, { 0.2, -0.75 } }) do
        b.add("Ball", { 0.1, 0.1, 0.1 }, { spot[1], spot[2], -0.43 }, Ink, { name = "Truffle" .. index })
    end
    b.add("Block", { 0.87, 0.22, 0.87 }, { 0, 1.0, 0 }, rgb(255, 214, 90), { name = "GoldLeaf" })
    b.face(-0.44, 0.3, 0.18, 0.28)
    b.feet(-0.92, 0.22, rgb(150, 100, 40))
end
function Recipes.PepperKnight(b)
    b.body("Cylinder", { 1.6, 1.0, 1.0 }, { 0, -0.05, 0 }, rgb(96, 58, 32), { upright = true })
    b.add("Ball", { 0.5, 0.5, 0.5 }, { 0, 0.95, 0 }, rgb(70, 40, 20), { name = "Knob" })
    b.add("Block", { 0.9, 0.24, 0.1 }, { 0, 0.45, -0.5 }, rgb(200, 205, 215), { name = "Visor" })
    b.add("Block", { 0.7, 0.9, 0.12 }, { 0.75, -0.2, -0.2 }, rgb(200, 205, 215), { name = "Shield", rotation = CFrame.Angles(0, -0.5, 0) })
    b.add("Block", { 0.3, 0.3, 0.13 }, { 0.78, -0.15, -0.28 }, rgb(230, 57, 70), { name = "Crest", rotation = CFrame.Angles(0, -0.5, 0) })
    b.face(-0.51, 0.0, 0.2, 0.28)
    b.feet(-0.9, 0.3, rgb(70, 40, 20))
end
function Recipes.VelvetBox(b)
    b.body("Block", { 1.4, 1.0, 1.1 }, { 0, -0.2, 0 }, rgb(150, 20, 46))
    b.add("Block", { 1.5, 0.3, 1.2 }, { 0, 0.42, 0 }, rgb(170, 26, 56), { name = "Lid" })
    b.add("Block", { 1.52, 0.08, 1.22 }, { 0, 0.28, 0 }, rgb(255, 183, 3), { name = "Trim" })
    b.add("Ball", { 0.36, 0.36, 0.36 }, { 0, 0.66, 0 }, rgb(255, 183, 3), { name = "Clasp" })
    b.face(-0.56, -0.15, 0.26, 0.3)
    b.feet(-0.82, 0.42, rgb(110, 14, 34))
end
function Recipes.ButlerSpud(b)
    b.body("Ball", { 1.6, 1.6, 1.6 }, { 0, -0.05, 0 }, rgb(190, 146, 90))
    b.add("Cylinder", { 0.9, 0.8, 0.8 }, { 0, 1.05, 0 }, Ink, { upright = true, name = "TopHat" })
    b.add("Cylinder", { 0.08, 1.2, 1.2 }, { 0, 0.62, 0 }, Ink, { upright = true, name = "HatBrim" })
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.3, 0.24, 0.1 }, { side * 0.17, -0.45, -0.7 }, Ink, { name = "BowTie", rotation = CFrame.Angles(0, 0, side * 0.3) })
    end
    b.add("Cylinder", { 0.06, 0.42, 0.42 }, { 0.26, 0.25, -0.76 }, rgb(255, 183, 3), { name = "Monocle", rotation = CFrame.Angles(0, math.pi / 2, 0) })
    b.face(-0.72, 0.22, 0.26, 0.3)
    b.feet(-0.8, 0.4, rgb(150, 110, 60))
end
function Recipes.CrownKetchup(b)
    b.body("Cylinder", { 1.6, 1.0, 1.0 }, { 0, -0.1, 0 }, rgb(214, 36, 40), { upright = true })
    b.add("Cylinder", { 0.3, 0.6, 0.6 }, { 0, 0.82, 0 }, rgb(255, 250, 240), { upright = true, name = "Cap" })
    b.add("Cylinder", { 0.3, 0.8, 0.8 }, { 0, 1.1, 0 }, rgb(255, 183, 3), { upright = true, name = "Crown", body = false })
    for index = 0, 3 do
        local angle = index * math.pi / 2
        b.add("Block", { 0.14, 0.3, 0.14 }, { math.cos(angle) * 0.32, 1.38, math.sin(angle) * 0.32 }, rgb(255, 183, 3), { name = "Point" .. index })
    end
    b.add("Block", { 0.6, 0.4, 0.05 }, { 0, -0.35, -0.51 }, rgb(255, 250, 240), { name = "Label" })
    b.face(-0.51, 0.2, 0.2, 0.28)
    b.feet(-0.92, 0.28, rgb(160, 24, 28))
end
function Recipes.DiamondDip(b)
    b.body("Cylinder", { 0.8, 1.5, 1.5 }, { 0, -0.35, 0 }, rgb(250, 250, 255), { upright = true })
    b.add("Cylinder", { 0.2, 1.3, 1.3 }, { 0, 0.08, 0 }, rgb(255, 230, 160), { upright = true, name = "Dip" })
    b.add("Block", { 0.8, 0.8, 0.8 }, { 0, 0.75, 0 }, rgb(120, 210, 255), { name = "Diamond", neon = true, rotation = CFrame.Angles(math.pi / 4, 0, math.pi / 4) })
    b.add("Cylinder", { 0.12, 1.56, 1.56 }, { 0, -0.7, 0 }, rgb(255, 183, 3), { upright = true, name = "GoldBand" })
    b.face(-0.76, -0.35, 0.3, 0.28)
end
function Recipes.FryUnicorn(b)
    b.body("Ball", { 1.5, 1.5, 1.5 }, { 0, 0, 0 }, rgb(252, 250, 255))
    b.add("Block", { 0.2, 0.9, 0.2 }, { 0, 1.0, -0.25 }, rgb(255, 214, 90), { name = "Horn", rotation = CFrame.Angles(-0.35, 0, 0) })
    for index, tint in ipairs({ rgb(255, 92, 168), rgb(255, 183, 3), rgb(76, 201, 240), rgb(123, 44, 191) }) do
        b.add("Ball", { 0.4, 0.4, 0.4 }, { 0.15 - index * 0.05, 0.75 - index * 0.25, 0.55 }, tint, { name = "Mane" .. index })
    end
    for _, side in ipairs({ -1, 1 }) do
        b.add("Block", { 0.2, 0.36, 0.2 }, { side * 0.4, 0.75, 0.05 }, rgb(240, 236, 250), { name = "Ear", rotation = CFrame.Angles(0, 0, side * -0.3) })
    end
    b.face(-0.7, 0.18, 0.28, 0.3)
    b.feet(-0.75, 0.38, rgb(230, 220, 240))
end
function Recipes.FryEmperor(b)
    b.body("Block", { 1.1, 2.1, 1.1 }, { 0, 0.05, 0 }, rgb(255, 214, 90))
    for index, y in ipairs({ -0.6, 0.0 }) do
        b.add("Block", { 1.14, 0.1, 1.14 }, { 0, y, 0 }, rgb(236, 170, 40), { name = "Crinkle" .. index })
    end
    b.add("Block", { 1.4, 1.8, 0.12 }, { 0, -0.1, 0.62 }, rgb(90, 24, 154), { name = "Cape" })
    b.add("Block", { 1.42, 0.2, 0.14 }, { 0, -0.95, 0.62 }, rgb(255, 255, 255), { name = "Ermine" })
    b.add("Cylinder", { 0.5, 1.2, 1.2 }, { 0, 1.35, 0 }, rgb(255, 183, 3), { upright = true, name = "Crown", body = false })
    for index = 0, 4 do
        local angle = index * math.pi * 2 / 5
        b.add("Ball", { 0.22, 0.22, 0.22 }, { math.cos(angle) * 0.5, 1.7, math.sin(angle) * 0.5 }, if index % 2 == 0 then rgb(230, 57, 70) else rgb(76, 201, 240), { name = "Jewel" .. index })
    end
    b.add("Block", { 0.12, 1.4, 0.12 }, { 0.8, 0.0, -0.2 }, rgb(255, 183, 3), { name = "Scepter" })
    b.add("Ball", { 0.3, 0.3, 0.3 }, { 0.8, 0.75, -0.2 }, rgb(123, 44, 191), { name = "ScepterGem", neon = true })
    b.face(-0.56, 0.45, 0.22, 0.32)
    b.feet(-1.02, 0.28, rgb(214, 140, 40))
end
PetModels.Recipes = Recipes
-- Returns a Model plus its pieces and local offsets, for callers to place each frame.
function PetModels.build(petType, golden, parent)
    local model = Instance.new("Model")
    model.Name = petType .. (if golden then "Golden" else "")
    local b, pieces = builder(model, golden)
    local recipe = Recipes[petType] or Recipes.CrinkleFry
    recipe(b)
    b.sparkles()
    model.Parent = parent
    return model, pieces
end
-- Places every piece relative to a base CFrame (the pet's position and facing).
function PetModels.place(pieces, base)
    for _, piece in ipairs(pieces) do piece.part.CFrame = base * piece.offset end
end
return PetModels
