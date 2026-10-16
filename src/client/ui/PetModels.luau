-- Code-built pet models: a few smooth cartoon blocks and balls per pet, no assets.
-- Each piece is { shape, size, offset, color, transparency? }. Bodies get eyes on the front (-Z).
local PetModels = {}
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local Specs = {
    CrinkleFry = { eyes = 0.45, { "Block", { 0.9, 1.8, 0.9 }, { 0, 0, 0 }, rgb(255, 214, 90) },
        { "Block", { 0.95, 0.12, 0.95 }, { 0, 0.4, 0 }, rgb(232, 176, 52) }, { "Block", { 0.95, 0.12, 0.95 }, { 0, -0.3, 0 }, rgb(232, 176, 52) } },
    SaltShaker = { eyes = 0.55, { "Block", { 1.1, 1.4, 1.1 }, { 0, 0, 0 }, rgb(244, 244, 240) },
        { "Block", { 1.12, 0.4, 1.12 }, { 0, 0.85, 0 }, rgb(170, 178, 190) } },
    PaperCup = { eyes = 0.6, { "Block", { 1.2, 1.4, 1.2 }, { 0, 0, 0 }, rgb(232, 72, 72) },
        { "Block", { 1.22, 0.38, 1.22 }, { 0, -0.2, 0 }, rgb(255, 248, 236) }, { "Block", { 0.8, 0.5, 0.8 }, { 0, 0.9, 0 }, rgb(255, 214, 90) } },
    PotatoPup = { eyes = 0.75, { "Ball", { 1.6, 1.6, 1.6 }, { 0, 0, 0 }, rgb(196, 150, 92) },
        { "Ball", { 0.55, 0.55, 0.55 }, { -0.55, 0.7, 0 }, rgb(150, 105, 60) }, { "Ball", { 0.55, 0.55, 0.55 }, { 0.55, 0.7, 0 }, rgb(150, 105, 60) } },
    KetchupPacket = { eyes = 0.18, { "Block", { 1.5, 1.1, 0.35 }, { 0, 0, 0 }, rgb(222, 44, 44) },
        { "Block", { 1.52, 0.25, 0.37 }, { 0, 0.32, 0 }, rgb(255, 248, 236) } },
    NapkinGhost = { eyes = 0.75, { "Ball", { 1.6, 1.6, 1.6 }, { 0, 0, 0 }, rgb(250, 250, 255), 0.15 },
        { "Block", { 1.2, 0.5, 1.2 }, { 0, -0.7, 0 }, rgb(250, 250, 255), 0.15 } },
    CurlyFryCat = { eyes = 0.7, { "Ball", { 1.5, 1.5, 1.5 }, { 0, 0, 0 }, rgb(240, 150, 60) },
        { "Block", { 0.35, 0.55, 0.35 }, { -0.45, 0.8, 0 }, rgb(214, 118, 40) }, { "Block", { 0.35, 0.55, 0.35 }, { 0.45, 0.8, 0 }, rgb(214, 118, 40) } },
    MayoJar = { eyes = 0.6, { "Block", { 1.2, 1.5, 1.2 }, { 0, 0, 0 }, rgb(252, 246, 222) },
        { "Block", { 1.25, 0.32, 1.25 }, { 0, 0.9, 0 }, rgb(92, 150, 232) } },
    FryerBot = { eyes = false, { "Block", { 1.4, 1.3, 1.2 }, { 0, 0, 0 }, rgb(170, 186, 202) },
        { "Block", { 0.9, 0.5, 0.06 }, { 0, 0.15, -0.62 }, rgb(126, 245, 215) }, { "Block", { 0.12, 0.5, 0.12 }, { 0, 0.9, 0 }, rgb(120, 130, 145) },
        { "Ball", { 0.3, 0.3, 0.3 }, { 0, 1.2, 0 }, rgb(244, 112, 111) } },
    FryKing = { eyes = 0.5, { "Block", { 1.0, 1.9, 1.0 }, { 0, 0, 0 }, rgb(255, 206, 64) },
        { "Block", { 1.12, 0.36, 1.12 }, { 0, 1.15, 0 }, rgb(255, 176, 0) }, { "Ball", { 0.3, 0.3, 0.3 }, { 0, 1.45, 0 }, rgb(244, 112, 111) } },
}
local Gold = rgb(255, 200, 50)
PetModels.Specs = Specs
-- Returns a Model plus the pieces with their local offsets, for the follower to place each frame.
function PetModels.build(petType, golden, parent)
    local spec = Specs[petType] or Specs.CrinkleFry
    local model = Instance.new("Model")
    model.Name = petType .. (if golden then "Golden" else "")
    local pieces = {}
    local function add(shape, size, offset, color, transparency)
        local part = Instance.new("Part")
        part.Shape = if shape == "Ball" then Enum.PartType.Ball else Enum.PartType.Block
        part.Size = Vector3.new(size[1], size[2], size[3])
        part.Color, part.Transparency = color, transparency or 0
        part.Material, part.Reflectance = Enum.Material.SmoothPlastic, if golden then 0.25 else 0
        part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery, part.CastShadow = true, false, false, false, false
        part.Parent = model
        table.insert(pieces, { part = part, offset = CFrame.new(Vector3.new(offset[1], offset[2], offset[3])) })
    end
    for index, piece in ipairs(spec) do
        -- Golden pets tint the body gold and keep their accent colors.
        add(piece[1], piece[2], piece[3], if golden and index == 1 then Gold else piece[4], piece[5])
    end
    if spec.eyes then
        for _, x in ipairs({ -0.22, 0.22 }) do
            add("Ball", { 0.24, 0.24, 0.24 }, { x, 0.25, -spec.eyes }, rgb(40, 32, 28))
        end
    end
    model.Parent = parent
    return model, pieces
end
return PetModels
