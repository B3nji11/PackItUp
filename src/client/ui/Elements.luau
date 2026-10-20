-- Shared widgets in the Diner Sticker style: white sticker borders, solid ink shadows
-- offset down and right, Luckiest Guy labels on buttons, and one panel frame.
local Theme = require(script.Parent.Theme)
local Elements = {}
function Elements.count(value)
    local grouped = string.reverse(string.format("%.0f", value)):gsub("(%d%d%d)", "%1,")
    local result = string.reverse(grouped):gsub("^,", "")
    return result
end
function Elements.money(value) return "$" .. Elements.count(value) end
-- Whole numbers stay whole; pet bonuses can make stats fractional (1.05 fries per click).
function Elements.number(value)
    if math.abs(value - math.floor(value + 0.5)) < 1e-6 then return Elements.count(math.floor(value + 0.5)) end
    local text = string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
    return text
end
-- Shrinks text to fit on one line, between min and max sizes.
function Elements.fit(label, min, max)
    label.TextScaled, label.TextWrapped = true, false
    local constraint = Instance.new("UITextSizeConstraint")
    constraint.Name, constraint.MinTextSize, constraint.MaxTextSize, constraint.Parent = "Fit", min, max, label
    return constraint
end
function Elements.stroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color, stroke.Thickness, stroke.Transparency = color, thickness, transparency or 0
    stroke.ApplyStrokeMode, stroke.Parent = Enum.ApplyStrokeMode.Border, parent
    return stroke
end
-- An outline around the letters themselves (for white titles on colour).
function Elements.textStroke(label, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Name, stroke.Color, stroke.Thickness = "TextOutline", color or Theme.Ink, thickness or 2
    stroke.ApplyStrokeMode, stroke.Parent = Enum.ApplyStrokeMode.Contextual, label
    return stroke
end
function Elements.corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius, corner.Parent = UDim.new(0, radius or 10), parent
    return corner
end
function Elements.box(parent, name, position, size, color, radius)
    local frame = Instance.new("Frame")
    frame.Name, frame.Position, frame.Size = name, position, size
    frame.BackgroundColor3, frame.BorderSizePixel, frame.Parent = color, 0, parent
    Elements.corner(frame, radius)
    return frame
end
function Elements.label(parent, text, height, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, height or 42)
    label.BackgroundTransparency = 1
    label.Font = Theme.Body
    label.TextSize = 15
    label.TextColor3 = color or Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Text = text
    label.Parent = parent
    return label
end
-- A solid ink "shadow" sibling that follows its target's position, size, visibility, and
-- layer. Roblox draws children above their parent, so a drop shadow must be a sibling.
-- Never use on a direct child of a list layout (the shadow would become a list item).
local Followed = { "Position", "Size", "AnchorPoint", "Visible", "ZIndex", "Name", "Parent" }
function Elements.shadow(target, offset, color)
    offset = offset or Theme.ShadowOffset
    local shadow = Instance.new("Frame")
    shadow.BackgroundColor3, shadow.BorderSizePixel = color or Theme.Ink, 0
    local corner = Elements.corner(shadow, 0)
    if target.ZIndex == nil or target.ZIndex < 2 then target.ZIndex = 2 end
    local function sync()
        local p = target.Position or UDim2.new()
        shadow.Name = target.Name .. "Shadow"
        shadow.AnchorPoint, shadow.Size = target.AnchorPoint or Vector2.new(0, 0), target.Size
        shadow.Position = UDim2.new(p.X.Scale, p.X.Offset + offset, p.Y.Scale, p.Y.Offset + offset)
        shadow.Visible = target.Visible
        shadow.ZIndex = (target.ZIndex or 2) - 1
        local targetCorner = target:FindFirstChildOfClass("UICorner")
        corner.CornerRadius = if targetCorner then targetCorner.CornerRadius else UDim.new(0, 0)
        shadow.Parent = target.Parent
    end
    for _, property in ipairs(Followed) do target:GetPropertyChangedSignal(property):Connect(sync) end
    sync()
    return shadow
end
-- Sticker look: white border plus an offset ink shadow.
function Elements.sticker(target, border, offset)
    Elements.stroke(target, Theme.White, border or Theme.Border, 0)
    return Elements.shadow(target, offset or Theme.ShadowOffset)
end
-- A sticker button with a Luckiest Guy label. Pass shadowOffset = 0 for a flat button.
function Elements.button(parent, text, callback, color, shadowOffset)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 44)
    button.BackgroundColor3 = color or Theme.Gold
    button.TextColor3 = Theme.Ink
    button.Font = Theme.Display
    button.TextSize = 16
    button.TextWrapped = true
    button.Text = text
    button.BorderSizePixel = 0
    button.Parent = parent
    Elements.corner(button, 14)
    if shadowOffset ~= 0 then
        Elements.stroke(button, Theme.White, 3, 0)
        Elements.shadow(button, shadowOffset or 3)
    end
    if callback then button.Activated:Connect(callback) end
    return button
end
function Elements.column(parent, name)
    local frame = Instance.new("ScrollingFrame")
    frame.Name = name
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 6
    frame.ScrollBarImageColor3 = Theme.Muted
    frame.CanvasSize = UDim2.new()
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Parent = parent
    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 4)
    padding.Parent = frame
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame
    return frame
end
function Elements.bar(parent, color, height)
    local outer = Instance.new("Frame")
    outer.Size = UDim2.new(1, 0, 0, height or 18)
    outer.BackgroundColor3 = Theme.Chip
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
-- A dashed tan divider, like a receipt.
function Elements.dashes(parent, name, position, width)
    local holder = Instance.new("Frame")
    holder.Name, holder.Position, holder.Size = name, position, UDim2.fromOffset(width, 3)
    holder.BackgroundTransparency, holder.ClipsDescendants, holder.Parent = 1, true, parent
    for x = 0, width - 6, 12 do
        Elements.box(holder, "Dash", UDim2.fromOffset(x, 0), UDim2.fromOffset(6, 3), Theme.Tan, 1)
    end
    return holder
end
-- The shared modal frame: cream body with a white sticker border and shadow, a ketchup
-- header with a white Luckiest Guy title, a red-and-cream checker strip, and a close button.
-- Content starts at Elements.PanelTop. Title, Caption, and Close are direct panel children.
Elements.PanelTop = 70
function Elements.panel(gui, name, width, height, accent)
    local panel = Elements.box(gui, name, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(width, height), Theme.Cream, 26)
    panel.AnchorPoint, panel.Visible = Vector2.new(0.5, 0.5), false
    Elements.stroke(panel, Theme.White, 5, 0)
    panel.ZIndex = 6
    local panelShadow = Elements.shadow(panel, 8)
    local headerColor = accent or Theme.Red
    local header = Elements.box(panel, "Header", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 58), headerColor, 22)
    header.ZIndex = 0
    local square = Elements.box(header, "Square", UDim2.new(0, 0, 1, -22), UDim2.new(1, 0, 0, 22), headerColor, 0)
    square.ZIndex = 0
    local checker = Instance.new("Frame")
    checker.Name, checker.Position, checker.Size = "Checker", UDim2.fromOffset(0, 58), UDim2.new(1, 0, 0, 10)
    checker.BackgroundColor3, checker.BorderSizePixel, checker.ClipsDescendants = Theme.Cream, 0, true
    checker.ZIndex, checker.Parent = 0, panel
    -- Enough cells for the widest a resizable panel gets; the strip clips the rest.
    for index = 0, math.ceil(math.max(width, 760) / 10) - 1 do
        if index % 2 == 0 then
            local cell = Instance.new("Frame")
            cell.Name, cell.Position, cell.Size = "Cell", UDim2.fromOffset(index * 10, 0), UDim2.fromOffset(10, 10)
            cell.BackgroundColor3, cell.BorderSizePixel, cell.ZIndex, cell.Parent = headerColor, 0, 0, checker
        end
    end
    local title = Elements.label(panel, string.upper(name), 34, Theme.OnColor)
    title.Name, title.Position, title.Size = "Title", UDim2.fromOffset(20, 7), UDim2.new(1, -96, 0, 34)
    title.Font, title.TextSize = Theme.Display, 28
    Elements.textStroke(title, Theme.Ink, 2)
    Elements.fit(title, 14, 28)
    local caption = Elements.label(panel, "", 16, Color3.fromRGB(255, 232, 214))
    caption.Name, caption.Position, caption.Size, caption.TextSize = "Caption", UDim2.fromOffset(20, 38), UDim2.new(1, -96, 0, 16), 12
    Elements.fit(caption, 8, 12)
    local close = Elements.button(panel, "X", nil, Theme.Ink, 0)
    close.Name, close.Position, close.Size = "Close", UDim2.new(1, -50, 0, 10), UDim2.fromOffset(38, 38)
    close.TextColor3, close.TextSize = Theme.White, 18
    close:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 19)
    Elements.stroke(close, Theme.White, 3, 0)
    local scale = Instance.new("UIScale")
    scale.Parent = panel
    -- The shadow is a sibling, so it needs its own UIScale that mirrors the panel's.
    local shadowScale = Instance.new("UIScale")
    shadowScale.Parent = panelShadow
    scale:GetPropertyChangedSignal("Scale"):Connect(function() shadowScale.Scale = scale.Scale end)
    return { panel = panel, title = title, caption = caption, close = close, scale = scale }
end
-- Menu buttons: a coloured sticker pill with a cream icon disc and a white outlined label.
-- setMenuMode switches between the wide pill and a round icon-only button.
function Elements.menuButton(parent, name, text, icon, accent, callback)
    local Icons = require(script.Parent.Icons)
    local button = Elements.button(parent, "", callback, accent, 0)
    button.Name, button.AutoButtonColor = name, true
    Elements.stroke(button, Theme.White, 4, 0)
    Elements.shadow(button, 5)
    local disc = Elements.box(button, "Disc", UDim2.new(0, 7, 0.5, 0), UDim2.fromOffset(36, 36), Theme.Cream, 18)
    disc.AnchorPoint = Vector2.new(0, 0.5)
    local glyph = Icons.make(disc, icon, 26, accent)
    glyph.AnchorPoint, glyph.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
    local label = Elements.label(button, text, 30, Theme.OnColor)
    label.Name, label.Position, label.Size = "Label", UDim2.new(0, 52, 0.5, -15), UDim2.new(1, -60, 0, 30)
    label.Font, label.TextSize = Theme.Display, 19
    Elements.textStroke(label, Theme.Ink, 2)
    Elements.fit(label, 7, 19)
    local badge = Elements.box(button, "Badge", UDim2.new(1, -14, 0, -8), UDim2.fromOffset(22, 22), Theme.Gold, 11)
    Elements.stroke(badge, Theme.White, 2, 0)
    local mark = Elements.label(badge, "!", 22, Theme.Ink)
    mark.Size, mark.Font, mark.TextSize, mark.TextXAlignment = UDim2.fromScale(1, 1), Theme.Display, 15, Enum.TextXAlignment.Center
    badge.Visible = false
    return button
end
-- Menu buttons always show their name. "pill": icon disc on the left, label beside it.
-- "tile": icon disc on top, label underneath (Pet Simulator style, for short screens).
function Elements.setMenuMode(button, mode, width, height)
    local pill = mode == "pill"
    button:SetAttribute("MenuMode", mode)
    button.Size = UDim2.fromOffset(width, height)
    button:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, if pill then math.floor(height / 2) else 16)
    local disc, label = button.Disc, button.Label
    local discSize = if pill then 36 else math.min(width - 18, height - 28)
    disc.Size = UDim2.fromOffset(discSize, discSize)
    disc:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, math.floor(discSize / 2))
    disc.AnchorPoint = if pill then Vector2.new(0, 0.5) else Vector2.new(0.5, 0)
    disc.Position = if pill then UDim2.new(0, 7, 0.5, 0) else UDim2.new(0.5, 0, 0, 6)
    label.Visible = true
    if pill then
        label.Position, label.Size = UDim2.new(0, 52, 0.5, -15), UDim2.new(1, -60, 0, 30)
        label.TextXAlignment, label.Fit.MaxTextSize = Enum.TextXAlignment.Left, 19
    else
        label.Position, label.Size = UDim2.new(0, 3, 1, -21), UDim2.new(1, -6, 0, 16)
        label.TextXAlignment, label.Fit.MaxTextSize = Enum.TextXAlignment.Center, 12
    end
end
function Elements.setMenuEnabled(button, enabled, accent)
    button.BackgroundColor3 = if enabled then accent else Theme.Disabled
    button.Active, button.Selectable, button.AutoButtonColor = enabled, enabled, enabled
end
-- A scrolling grid of fixed-size cells (tiles). Never give its children sibling shadows.
function Elements.grid(parent, name, cellWidth, cellHeight, gap)
    local frame = Instance.new("ScrollingFrame")
    frame.Name, frame.BackgroundTransparency, frame.BorderSizePixel = name, 1, 0
    frame.Size, frame.ScrollBarThickness, frame.ScrollBarImageColor3 = UDim2.fromScale(1, 1), 6, Theme.Muted
    frame.CanvasSize, frame.AutomaticCanvasSize = UDim2.new(), Enum.AutomaticSize.Y
    frame.Parent = parent
    local padding = Instance.new("UIPadding")
    padding.PaddingTop, padding.PaddingLeft = UDim.new(0, 6), UDim.new(0, 4)
    padding.PaddingRight, padding.PaddingBottom = UDim.new(0, 10), UDim.new(0, 10)
    padding.Parent = frame
    local layout = Instance.new("UIGridLayout")
    layout.CellSize, layout.CellPadding = UDim2.fromOffset(cellWidth, cellHeight), UDim2.fromOffset(gap or 10, gap or 10)
    layout.SortOrder, layout.Parent = Enum.SortOrder.LayoutOrder, frame
    return frame, layout
end
-- Stretches grid cells so the columns fill `areaWidth` (no empty strip on the right). Cells
-- stay between minWidth and 1.3x minWidth wide; the height stays as built.
function Elements.fitGrid(layout, areaWidth, minWidth)
    local gap = layout.CellPadding.X.Offset
    local usable = areaWidth - 14 -- the grid's left and right padding
    local columns = math.max(1, math.floor((usable + gap) / (minWidth + gap)))
    local cell = math.min(math.floor(minWidth * 1.3), math.floor((usable - gap * (columns - 1)) / columns))
    layout.CellSize = UDim2.fromOffset(cell, layout.CellSize.Y.Offset)
    return columns
end
-- A card for content inside panels: white with a quiet tan border (no sibling shadow, so it
-- is safe inside list layouts).
function Elements.card(parent, name, position, size, radius)
    local card = Elements.box(parent, name, position, size, Theme.Card, radius or 16)
    Elements.stroke(card, Theme.Tan, 2, 0)
    return card
end
return Elements
