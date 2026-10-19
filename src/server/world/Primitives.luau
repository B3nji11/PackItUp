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
function Primitives.fitSurfaceLabel(parent, gui)
    local size, face = parent.Size, gui.Face
    local width, height = size.X, size.Y
    if face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
        height = size.Z
    elseif face == Enum.NormalId.Left or face == Enum.NormalId.Right then
        width = size.Z
    end
    -- Normalize the canvas to the face aspect, independent of its world size.
    gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
    gui.CanvasSize = Vector2.new(96 * width / height, 96)
end
function Primitives.surfaceLabel(parent, text, face, color)
    local gui = Instance.new("SurfaceGui")
    gui.Name, gui.Face = "WallArt", face
    Primitives.fitSurfaceLabel(parent, gui)
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
    -- A 96px-high canvas fills any physical sign without requesting fonts over 100px.
    -- Even a large mural stays below the native font ceiling, rather than shrinking.
    local textSize = Instance.new("UITextSizeConstraint")
    textSize.Name, textSize.MinTextSize, textSize.MaxTextSize = "WorldTextSize", 1, 96
    textSize.Parent = label
    label.Parent = gui
    return label
end
return Primitives
