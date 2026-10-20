-- Live 3D pet portraits for the UI: a ViewportFrame showing the same code-built model the
-- pet uses in the world, framed from the front and slightly above.
local PetModels = require(script.Parent.PetModels)
local PetPortrait = {}
local Origin = CFrame.new(Vector3.new(0, 0, 0))
local function frame(viewport)
    local camera = viewport:FindFirstChild("PortraitCamera")
    if not camera then
        camera = Instance.new("Camera")
        camera.Name, camera.FieldOfView = "PortraitCamera", 30
        camera.Parent = viewport
        viewport.CurrentCamera = camera
    end
    -- Pets face -Z and are about 2 studs tall: look at them from the front, a little above.
    camera.CFrame = CFrame.lookAt(Vector3.new(0, 0.7, -6.4), Vector3.new(0, 0.15, 0))
end
-- Creates a portrait (or reuses `viewport`) showing `petType`; nil shows an empty frame.
function PetPortrait.set(viewport, petType, golden)
    local key = tostring(petType) .. (if golden then "*" else "")
    if viewport:GetAttribute("Showing") == key then return viewport end
    viewport:SetAttribute("Showing", key)
    local old = viewport:FindFirstChild("Pet")
    if old then old:Destroy() end
    if petType then
        local model, pieces = PetModels.build(petType, golden, viewport)
        model.Name = "Pet"
        PetModels.place(pieces, Origin)
    end
    return viewport
end
function PetPortrait.make(parent, name, size, position)
    local viewport = Instance.new("ViewportFrame")
    viewport.Name, viewport.BackgroundTransparency = name or "Portrait", 1
    viewport.Size, viewport.Position = size or UDim2.fromOffset(72, 72), position or UDim2.new()
    viewport.Ambient, viewport.LightColor = Color3.fromRGB(190, 180, 170), Color3.fromRGB(255, 250, 240)
    viewport.LightDirection = Vector3.new(-0.4, -1, 0.6)
    viewport.Parent = parent
    frame(viewport)
    return viewport
end
return PetPortrait
