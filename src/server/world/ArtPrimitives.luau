-- Shared palette and anchored decorative geometry; collision belongs to the world builders.
local P = require(script.Parent.Primitives)
local Art = {}
Art.Palette = table.freeze({
    Cream = Color3.fromRGB(255, 246, 222), Coral = Color3.fromRGB(250, 104, 105),
    Red = Color3.fromRGB(216, 69, 78), Gold = Color3.fromRGB(255, 196, 63),
    Honey = Color3.fromRGB(238, 155, 48), Mint = Color3.fromRGB(77, 206, 182),
    Teal = Color3.fromRGB(36, 120, 128), Ink = Color3.fromRGB(64, 62, 91),
    Pink = Color3.fromRGB(255, 163, 184), Lime = Color3.fromRGB(145, 230, 133),
})

function Art.new(parent, partFactory)
    local function piece(name, size, offset, color, shape, rotation)
        local object
        if partFactory then
            object = partFactory(name, size, offset, color)
        else
            object = P.part(parent, name, size, offset, color)
            object.CFrame = CFrame.new(offset)
        end
        object.Parent = parent
        object.CanCollide, object.CanTouch, object.CanQuery, object.CastShadow = false, false, false, false
        if shape then object.Shape = shape end
        if rotation then object.CFrame = object.CFrame * rotation end
        return object
    end
    local function ball(name, size, offset, color)
        return piece(name, size, offset, color, Enum.PartType.Ball)
    end
    local upright = CFrame.Angles(0, 0, math.pi / 2)
    local function disc(name, diameter, height, offset, color)
        return piece(name, Vector3.new(height, diameter, diameter), offset, color, Enum.PartType.Cylinder, upright)
    end
    local function rounded(name, size, offset, color, radius)
        piece(name .. "Core", Vector3.new(size.X - 2 * radius, size.Y, size.Z), offset, color)
        -- Inset the caps slightly to prevent coplanar surface flicker.
        piece(name .. "Cross", Vector3.new(size.X, size.Y - 0.006, size.Z - 2 * radius), offset, color)
        for _, x in ipairs({-1, 1}) do
            for _, z in ipairs({-1, 1}) do
                disc(name .. "Corner", 2 * radius, size.Y - 0.012,
                    offset + Vector3.new(x * (size.X / 2 - radius), 0, z * (size.Z / 2 - radius)), color)
            end
        end
    end
    local function label(part, text, color, face)
        local result = P.surfaceLabel(part, text, face or Enum.NormalId.Back, color)
        result.TextWrapped = false
        return result
    end
    return {piece = piece, ball = ball, disc = disc, rounded = rounded, label = label}
end

return Art
