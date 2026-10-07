local Primitives = {}
function Primitives.part(parent, name, size, position, color, material)
    local part = Instance.new("Part")
    part.Name, part.Size, part.Position = name, size, position
    part.Anchored = true
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end
function Primitives.label(parent, text, offset, width, height)
    local gui = Instance.new("BillboardGui")
    gui.Name = "Sign"
    gui.Size = UDim2.fromOffset(width or 230, height or 70)
    gui.StudsOffset = offset or Vector3.new(0, 3, 0)
    gui.MaxDistance = 100
    gui.AlwaysOnTop = false
    gui.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(29, 34, 48)
    label.BackgroundTransparency = 0.15
    label.TextColor3 = Color3.fromRGB(255, 238, 194)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 17
    label.TextWrapped = true
    label.Text = text
    label.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label
    return label
end
return Primitives
