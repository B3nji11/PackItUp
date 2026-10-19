local Primitives = {}
function Primitives.part(parent, name, size, position, color, material)
    local part = Instance.new("Part")
    part.Name, part.Size, part.Position = name, size, position
    part.Anchored = true
    part.Color = color
    -- Smooth, untextured surfaces are the default art direction for new world pieces.
    part.Material = material or Enum.Material.SmoothPlastic
    part.Reflectance = 0
    part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end
function Primitives.surfaceLabel(parent, text, face, color)
    local gui = Instance.new("SurfaceGui")
    gui.Name, gui.Face = "WallArt", face
    gui.SizingMode, gui.PixelsPerStud = Enum.SurfaceGuiSizingMode.PixelsPerStud, 40
    -- Printed lettering stays readable under warm/dim light, with normal world occlusion.
    gui.AlwaysOnTop, gui.LightInfluence = false, 0
    gui.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextWrapped = true
    label.Text = text
    -- TextScaled otherwise stops at 100 px, making large SurfaceGui signs look tiny.
    -- Keep the 40 px/stud detail and explicitly permit type to fill the physical face.
    local textSize = Instance.new("UITextSizeConstraint")
    textSize.Name, textSize.MinTextSize, textSize.MaxTextSize = "WorldTextSize", 9, 1000
    textSize.Parent = label
    label.Parent = gui
    return label
end
return Primitives
