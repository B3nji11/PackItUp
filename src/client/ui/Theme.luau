-- Diner Sticker palette and type (agreed 17 October 2026). See docs/STYLE_GUIDE.md.
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
return {
    -- Surfaces
    Cream = rgb(255, 244, 220), -- panel and card bodies
    Card = rgb(255, 255, 255), -- rows and tiles on cream
    Tan = rgb(229, 201, 163), -- dashed dividers, quiet borders
    Chip = rgb(247, 227, 191), -- inactive chips and empty tracks
    White = rgb(255, 255, 255), -- sticker borders
    -- Ink: text, outlines, and offset shadows
    Ink = rgb(61, 31, 31),
    Text = rgb(61, 31, 31),
    Muted = rgb(138, 90, 60),
    Accent = rgb(181, 101, 29), -- readable orange-brown for values on white or cream
    OnColor = rgb(255, 255, 255), -- text on ketchup, grape, blueberry, or teal
    -- Brand colours
    Red = rgb(230, 57, 70), -- ketchup: headers, Return to Counter, danger
    Gold = rgb(255, 183, 3), -- mustard: pack, buy, merge, highlights
    GoldLight = rgb(255, 209, 102),
    Green = rgb(42, 157, 143), -- teal: sell, equipped, ON
    GreenLight = rgb(82, 199, 184),
    Orange = rgb(247, 127, 0), -- upgrades
    Gem = rgb(123, 44, 191), -- grape: gems and rebirth
    GemLight = rgb(196, 161, 255),
    Blue = rgb(29, 111, 216), -- blueberry: pets
    Disabled = rgb(214, 196, 170),
    -- Back-compat names used by older modules
    Background = rgb(255, 244, 220),
    Shadow = rgb(61, 31, 31),
    -- Type: both fonts ship with Roblox
    Display = Enum.Font.LuckiestGuy, -- titles, numbers, button labels
    Body = Enum.Font.FredokaOne, -- body text
    -- Shape
    Border = 4, -- white sticker border
    ShadowOffset = 5, -- ink shadow, down and right
    Radius = 18,
}
