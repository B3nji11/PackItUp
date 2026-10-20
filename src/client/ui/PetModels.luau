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
