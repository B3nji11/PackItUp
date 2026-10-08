local Theme = require(script.Parent.Theme)
local Elements = {}
function Elements.money(value)
    local grouped = string.reverse(string.format("%.0f", value)):gsub("(%d%d%d)", "%1,")
    local result = string.reverse(grouped):gsub("^,", "")
    return "$" .. result
end
function Elements.stroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color, stroke.Thickness, stroke.Transparency = color, thickness, transparency or 0
    stroke.ApplyStrokeMode, stroke.Parent = Enum.ApplyStrokeMode.Border, parent
    return stroke
end
function Elements.box(parent, name, position, size, color, radius)
    local frame = Instance.new("Frame")
    frame.Name, frame.Position, frame.Size = name, position, size
    frame.BackgroundColor3, frame.BorderSizePixel, frame.Parent = color, 0, parent
    Elements.corner(frame, radius)
    return frame
end
function Elements.corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius, corner.Parent = UDim.new(0, radius or 10), parent
end
function Elements.label(parent, text, height, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, height or 42)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 15
    label.TextColor3 = color or Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Text = text
    label.Parent = parent
    return label
end
function Elements.button(parent, text, callback, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 43)
    button.BackgroundColor3 = color or Theme.Gold
    button.TextColor3 = Theme.Background
    button.Font = Enum.Font.GothamBold
    button.TextSize = 15
    button.TextWrapped = true
    button.Text = text
    button.BorderSizePixel = 0
    button.Parent = parent
    Elements.corner(button)
    if callback then button.Activated:Connect(callback) end
    return button
end
function Elements.column(parent, name)
    local frame = Instance.new("ScrollingFrame")
    frame.Name = name
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = Theme.Muted
    frame.CanvasSize = UDim2.new()
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Parent = parent
    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0, 9)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = frame
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame
    return frame
end
function Elements.bar(parent, color, height)
    local outer = Instance.new("Frame")
    outer.Size = UDim2.new(1, 0, 0, height or 18)
    outer.BackgroundColor3 = Theme.Card
    outer.BorderSizePixel = 0
    outer.Parent = parent
    Elements.corner(outer, 5)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = color or Theme.Gold
    fill.BorderSizePixel = 0
    fill.Parent = outer
    Elements.corner(fill, 5)
    return outer, fill
end
return Elements
