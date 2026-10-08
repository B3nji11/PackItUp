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
function Primitives.surfaceLabel(parent, text, face, color)
    local gui = Instance.new("SurfaceGui")
    gui.Name, gui.Face = "WallArt", face
    gui.SizingMode, gui.PixelsPerStud = Enum.SurfaceGuiSizingMode.PixelsPerStud, 40
    gui.AlwaysOnTop, gui.LightInfluence = false, 0.5
    gui.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextWrapped = true
    label.Text = text
    label.Parent = gui
    return label
end
return Primitives
