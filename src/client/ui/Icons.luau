-- Icons: an uploaded image when shared/config/Icons has an asset ID, otherwise a simple
-- code-built fallback drawn in the same square. Drawings use scale units, so any size works.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("FriesShared")
local Ids = require(Shared.config.Icons)
local Theme = require(script.Parent.Theme)
local Icons = {}
local function piece(parent, name, x, y, w, h, color, round, rotation)
    local frame = Instance.new("Frame")
    frame.Name, frame.BorderSizePixel = name, 0
    frame.Position, frame.Size = UDim2.fromScale(x, y), UDim2.fromScale(w, h)
    frame.BackgroundColor3, frame.Rotation = color, rotation or 0
    if round then
        local corner = Instance.new("UICorner")
        corner.CornerRadius, corner.Parent = if round == true then UDim.new(0.5, 0) else UDim.new(round, 0), frame
    end
    frame.Parent = parent
    return frame
end
local function ring(parent, name, x, y, w, h, color, thickness)
    local frame = piece(parent, name, x, y, w, h, color, true)
    frame.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke")
    stroke.Color, stroke.Thickness, stroke.Parent = color, thickness, frame
    return frame
end
local function glyph(parent, text, color)
    local label = Instance.new("TextLabel")
    label.Name, label.Text, label.TextColor3, label.Font = "Glyph", text, color, Theme.Display
    label.BackgroundTransparency, label.Size, label.TextScaled = 1, UDim2.fromScale(1, 1), true
    label.TextSize = 100
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = parent
    return label
end
-- Fallback drawings. `tint` is the main line colour (white on colour, ink on cream).
local Draw = {}
function Draw.cash(holder)
    piece(holder, "Coin", 0.05, 0.05, 0.9, 0.9, Theme.Gold, true)
    local mark = piece(holder, "Mark", 0.2, 0.18, 0.6, 0.64, Theme.Gold, true)
    mark.BackgroundTransparency = 1
    glyph(mark, "$", Theme.Ink)
end
function Draw.gem(holder)
    piece(holder, "Stone", 0.2, 0.2, 0.6, 0.6, Theme.Gem, 0.12, 45)
    piece(holder, "Shine", 0.36, 0.3, 0.2, 0.2, Theme.GemLight, 0.2, 45)
end
function Draw.fries(holder)
    for index, x in ipairs({ 0.27, 0.44, 0.61 }) do
        piece(holder, "Fry" .. index, x, 0.08 + (index % 2) * 0.06, 0.12, 0.5, Theme.GoldLight, 0.3)
    end
    piece(holder, "Box", 0.18, 0.46, 0.64, 0.46, Theme.Red, 0.18)
end
function Draw.bag(holder, tint)
    ring(holder, "Handle", 0.33, 0.08, 0.34, 0.34, tint, 3)
    piece(holder, "Body", 0.18, 0.3, 0.64, 0.62, Theme.Tan, 0.16)
    piece(holder, "Band", 0.18, 0.5, 0.64, 0.1, Theme.Red, 0)
end
function Draw.upgrades(holder, tint)
    piece(holder, "Head", 0.24, 0.1, 0.52, 0.52, tint, 0.1, 45)
    piece(holder, "Shaft", 0.38, 0.38, 0.24, 0.52, tint, 0.2)
end
function Draw.rebirth(holder, tint)
    ring(holder, "Loop", 0.16, 0.16, 0.68, 0.68, tint, 4)
    piece(holder, "Tip", 0.6, 0.06, 0.26, 0.26, tint, 0.1, 45)
end
function Draw.spin(holder, tint)
    piece(holder, "Egg", 0.24, 0.08, 0.52, 0.84, tint, 0.48)
    piece(holder, "Band", 0.24, 0.48, 0.52, 0.12, Theme.Gold, 0)
end
function Draw.pets(holder, tint)
    piece(holder, "Pad", 0.26, 0.46, 0.48, 0.42, tint, true)
    for index, spot in ipairs({ { 0.14, 0.26 }, { 0.32, 0.08 }, { 0.54, 0.08 }, { 0.72, 0.26 } }) do
        piece(holder, "Toe" .. index, spot[1], spot[2], 0.16, 0.2, tint, true)
    end
end
function Draw.settings(holder, tint)
    for index = 0, 3 do
        piece(holder, "Tooth" .. index, 0.42, 0.06, 0.16, 0.88, tint, 0.2, index * 45)
    end
    piece(holder, "Ring", 0.2, 0.2, 0.6, 0.6, tint, true)
    piece(holder, "Hole", 0.38, 0.38, 0.24, 0.24, Theme.Cream, true)
end
function Draw.home(holder, tint)
    piece(holder, "Roof", 0.2, 0.1, 0.6, 0.6, tint, 0.08, 45)
    piece(holder, "Walls", 0.24, 0.44, 0.52, 0.46, tint, 0.08)
    piece(holder, "Door", 0.42, 0.62, 0.16, 0.28, Theme.Red, 0.2)
end
function Draw.close(holder, tint)
    piece(holder, "BarA", 0.42, 0.1, 0.16, 0.8, tint, 0.4, 45)
    piece(holder, "BarB", 0.42, 0.1, 0.16, 0.8, tint, 0.4, -45)
end
function Draw.check(holder, tint)
    piece(holder, "Short", 0.24, 0.42, 0.14, 0.34, tint, 0.4, -45)
    piece(holder, "Long", 0.52, 0.16, 0.14, 0.66, tint, 0.4, 40)
end
function Draw.sparkle(holder)
    piece(holder, "Tall", 0.4, 0.06, 0.2, 0.88, Theme.Gold, 0.5, 0)
    piece(holder, "Wide", 0.06, 0.4, 0.88, 0.2, Theme.Gold, 0.5, 0)
    piece(holder, "Core", 0.3, 0.3, 0.4, 0.4, Theme.GoldLight, 0.1, 45)
end
function Draw.star(holder)
    piece(holder, "A", 0.2, 0.2, 0.6, 0.6, Theme.Gold, 0.1, 0)
    piece(holder, "B", 0.2, 0.2, 0.6, 0.6, Theme.Gold, 0.1, 45)
end
Draw["upgrade-fries-per-click"] = Draw.fries
Draw["upgrade-money-per-fry"] = Draw.cash
Draw["upgrade-bag-capacity"] = Draw.bag
Icons.Draw = Draw
function Icons.hasImage(name) return type(Ids[name]) == "string" and Ids[name] ~= "" end
-- Returns a square holder named "Icon" containing either the uploaded image or a fallback.
function Icons.make(parent, name, size, tint, position)
    local holder = Instance.new("Frame")
    holder.Name, holder.BackgroundTransparency = "Icon", 1
    holder.Size, holder.Position = UDim2.fromOffset(size, size), position or UDim2.new()
    holder:SetAttribute("Icon", name)
    if Icons.hasImage(name) then
        local image = Instance.new("ImageLabel")
        image.Name, image.Image, image.BackgroundTransparency = "Image", Ids[name], 1
        image.Size, image.ScaleType = UDim2.fromScale(1, 1), Enum.ScaleType.Fit
        image.Parent = holder
    else
        assert(Draw[name], "Unknown icon " .. tostring(name))
        Draw[name](holder, tint or Theme.Ink)
    end
    holder.Parent = parent
    return holder
end
return Icons
