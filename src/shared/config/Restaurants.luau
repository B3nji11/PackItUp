-- Restaurant tiers (owner, 20 October 2026). Each tier is bought with Cash at the EXPAND kiosk,
-- keeps every earlier machine, adds one gacha machine, and dresses the restaurant in its theme.
-- Tiers are permanent and survive rebirth. Prices from tools/simulate.py (--calibrate).
local function rgb(r, g, b) return { r, g, b } end
local function tier(id, name, price, machine, tagline, theme)
    return table.freeze({ Id = id, Name = name, Price = price, Machine = machine, Tagline = tagline,
        Theme = table.freeze(theme) })
end
-- Theme colours (RGB lists, so this module needs no engine types): Main for the roof, fascia,
-- and stand body; Trim for edges and stripes; Glow for neon; Floor for the restaurant floor.
local Tiers = {
    tier("FryStand", "Fry Stand", 0, "StarterFryer", "Where every fry empire starts.",
        { Main = rgb(245, 112, 113), Trim = rgb(255, 247, 226), Glow = rgb(255, 214, 102), Floor = rgb(255, 247, 226) }),
    tier("FryDiner", "Fry Diner", 5e6, "DeluxeFryer", "Chrome, neon, and milkshakes.",
        { Main = rgb(230, 57, 70), Trim = rgb(214, 226, 233), Glow = rgb(255, 92, 168), Floor = rgb(250, 250, 250) }),
    tier("DriveIn", "Drive-In", 30e6, "DriveInGrill", "Burgers served right to your car.",
        { Main = rgb(42, 157, 143), Trim = rgb(247, 127, 0), Glow = rgb(255, 183, 3), Floor = rgb(255, 236, 200) }),
    tier("FishPier", "Fish & Chips Pier", 750e6, "PierFryer", "Salty sea air and golden chips.",
        { Main = rgb(29, 53, 87), Trim = rgb(255, 255, 255), Glow = rgb(72, 202, 228), Floor = rgb(196, 150, 104) }),
    tier("CosmicDiner", "Cosmic Diner", 10e9, "CosmicFryer", "Fries that are out of this world.",
        { Main = rgb(60, 26, 110), Trim = rgb(123, 44, 191), Glow = rgb(76, 201, 240), Floor = rgb(40, 34, 70) }),
    tier("FryPalace", "Fry Palace", 350e9, "RoyalFryer", "Fit for the Fry Emperor.",
        { Main = rgb(90, 24, 154), Trim = rgb(255, 183, 3), Glow = rgb(255, 230, 140), Floor = rgb(244, 238, 228) }),
}
return table.freeze({ Tiers = table.freeze(Tiers), Max = #Tiers })
