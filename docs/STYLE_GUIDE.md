# Style guide: Diner Sticker

Agreed 17 October 2026. Pet Simulator energy with a fries-shop theme: bold flat colour, chunky type, white "sticker" borders, and solid ink shadows. Tokens live in `src/client/ui/Theme.luau`; shared widgets in `src/client/ui/Elements.luau`. Change a token there, never a colour inline.

## Colour

| Token | Hex | Use |
| --- | --- | --- |
| Cream | `#fff4dc` | Panel bodies, the wallet, inactive Sell, icon discs |
| Card | `#ffffff` | Rows, cards, and tiles on cream |
| Chip | `#f7e3bf` | Inactive chips, empty progress tracks, Unequip |
| Tan | `#e5c9a3` | Card borders and dashed dividers |
| Ink | `#3d1f1f` | Text, outlines, and every drop shadow |
| Muted | `#8a5a3c` | Secondary text |
| Accent | `#b5651d` | Values on white or cream (upgrade values, pet bonuses) |
| Red (ketchup) | `#e63946` | Panel headers, Return to Counter, danger (Delete, SURE?, errors) |
| Gold (mustard) | `#ffb703` | Pack, Buy, Equip, Merge, rebirth "!" badge |
| Green (teal) | `#2a9d8f` | Sell when ready, Spin, ON, the machine panel header |
| Orange | `#f77f00` | Upgrades menu |
| Gem (grape) | `#7b2cbf` | Gems, Rebirth menu and panel header |
| Blue (blueberry) | `#1d6fd8` | Pets menu and panel header |
| Disabled | `#d6c4aa` | Anything the player cannot use yet |

Rarity text and borders (dark enough for cream and white): Common `#806c58`, Uncommon `#1f8a7e`, Rare `#1d6fd8`, Epic `#7b2cbf`, Legendary and Golden `#b07600` (in `src/shared/config/Pets.luau`).

## Type

- **Luckiest Guy** (`Theme.Display`, `Enum.Font.LuckiestGuy`): titles, numbers, button labels, and pet names. It is all capitals by design.
- **Fredoka One** (`Theme.Body`, `Enum.Font.FredokaOne`): body text, hints, and captions.
- White titles on colour get a 2 px ink letter outline (`Elements.textStroke`).
- Long text shrinks to fit on one line (`Elements.fit`) rather than wrapping out of its box.
- Neither font has arrows, ticks, or stars: use `»` for "becomes", and icons for ticks and stars.

## Shape

- **Sticker:** a white border (4 px on buttons and cards, 5 px on panels) plus a solid ink shadow offset down and right (3 px on small buttons, 5 px on menu buttons, 6-8 px on the wallet, actions, and panels). Use `Elements.sticker`, `Elements.button`, or `Elements.shadow`.
- Shadows are siblings that follow their target. Never give a shadow to a direct child of a list layout; list rows use `Elements.card` (white with a tan border) instead.
- Pills are fully rounded; cards and tiles use 14-20 px corners; panels use 26 px.
- **Panel frame** (`Elements.panel`): a coloured header (ketchup by default, or the menu's colour) with a white Luckiest Guy title, a short caption, a round ink close button, and a checker strip; content starts at `Elements.PanelTop` (70 px).
- Receipt details: dashed tan dividers (`Elements.dashes`).

## Layout

- **Wallet** (receipt card): top left. Cash on top, a dashed divider, Gems below.
- **Menu:** Upgrades, Rebirth, Spin, Pets. **Every menu button always shows its name** (owner feedback, 17 October 2026: icon-only buttons were unclear).
  - Tall screens: wide labelled pills below the wallet.
  - Short screens (under 500 px high): a row of labelled tiles (icon on top, name underneath, Pet Simulator style) at the top right.
  - If pills would not fit on a tall screen, the same labelled tiles in a 2x2 grid below the wallet.
- **Return to Counter and Settings:** top centre on wide screens, under the wallet in portrait, under the tile row on short screens.
- **Pack and Sell:** big sticker buttons (232 x 104) at the bottom centre, wide enough for Luckiest Guy titles such as CLAIM FIRST. Pack is mustard; Sell is cream until the bag is full, then teal. They scale down on narrow or short screens.
- **Guidance and errors:** a cream strip under the top bar on wide screens, above Pack and Sell in portrait, and between the wallet and the tiles on short screens.
- **Smallest supported screens:** 375 x 667 portrait and 640 x 360 landscape (common phone sizes). The layout test also covers 390 x 844, 844 x 390, 947 x 600, and 1280 x 720.
- Nothing may overlap, shadows included. The layout test checks five screen sizes.

## Numbers

- Cash, prices, and stats use the short format from `shared/util/Format`: 950, 1.25K, 12.5K, 125K, 1.25M, then B, T, Qa, Qi, Sx, Sp, Oc, No, Dc, then 1.2e36. Three significant digits.
- Money per fry in the upgrade shop keeps cents below $1,000 ($1.00 » $1.10).
- Upgrade rows show the total percent next to the level (LEVEL 2  ·  +20%).

## Touch and contrast

- Every tappable control is at least 44 x 44 px. Pack and Sell may scale down on narrow phones but stay at least 36 px tall.
- Text meets 4.5:1 contrast where it is small: ink on cream or white, white with an ink outline on colour. Disabled controls use Disabled with Muted text.

## World

The district sits on rolling grass that runs to the horizon (no floating island), under a warm haze (`Atmosphere`) that softens the default blue sky into the palette. Detailed world art is overhaul increment 4.

## Icons

Uploaded images when `src/shared/config/Icons.luau` has an asset ID, otherwise code-built fallbacks from `src/client/ui/Icons.luau`. The full list, sizes, and the art brief are in `art/README.md`.

## Pets (overhaul increment 2)

- **Models** (`client/ui/PetModels`): about 2 studs tall, built from smooth parts, facing -Z. Every pet shares one face: white eyes with ink pupils and a shine, pink blush, and a small smile. Golden pets turn the body gold (`#ffcc40`, slight shine) and add two neon sparkles. The same model is used for following pets and portraits.
- **Portraits** (`client/ui/PetPortrait`): a ViewportFrame with a fixed camera looking slightly down at the pet's face. A portrait only rebuilds when the pet shown changes.
- **Tiles:** white cards with a 3 px border and a top band in the rarity colour (Legendary gold for Golden), the portrait, the name in Luckiest Guy, and three stat lines (fries, money per fry, bag). Equipped tiles get a teal tick badge at the top right; Golden tiles a sparkle at the top left. Grids stretch their cells to fill the row (`Elements.fitGrid`) and scroll vertically.

## Panels

- **PETS:** auto-delete and delete-all chips, then the merge banner, the tile grid (equipped first, then by rarity, Golden first), and a detail bar for the selected pet (large portrait, name, rarity tags, full bonus, EQUIP/UNEQUIP/SLOTS FULL and a two-tap DELETE). On narrow panels the two buttons stack; on short landscape screens both chip rows share one line.
- **SPIN:** a result card (portrait or a "?" before the first spin, a rarity tag, "You got X!", the bonus), the pity bar, the pet count, the big green SPIN button, and an "IN THIS MACHINE" grid of every pet with its own chance. Two columns on wide panels; stacked on narrow ones, where the panel may grow taller.
- A panel's shadow scales with the panel on small screens.

## Restaurant tiers (world)

- **Stands:** a plinth, a body in the tier's Main colour, a glass dome of three capsules, a Luckiest Guy sign ("DELUXE FRYER / $150K A SPIN"), and a glowing neon pad in the Glow colour. Locked stands are grey with a faded dome, no capsules, and "LOCKED / NEEDS FRY DINER".
- **Kiosk:** a podium with a mustard board ("EXPAND / FRY DINER  $5M") and a neon pad, inside the restaurant at the front left.
- **Themes:** each tier has Main, Trim, Glow, and Floor colours (in `config/Restaurants.luau`). Tiers 2 and up recolour the roof cap, fascia, posts, awning (Main and Trim stripes), plaque, counter, benches, and floor, and add a roof sign, a neon strip, and props: Fry Diner stools, jukebox, and checkered entrance; Drive-In giant burger, car, and string lights; Pier lighthouse, giant fish, and life rings; Cosmic Diner ringed planet, dish, and stars; Fry Palace gold columns, crown, banners, and red carpet. Props are anchored and non-colliding (except a few solid bases).
- **Panels:** the SPIN panel header, checker strip, and stand share the machine's colour (green, red, orange, blue, grape, gold for tiers 1-6). The EXPAND panel is mustard.

## Motion (next increment)

Planned, not built yet: buttons squash on press, panels pop open, numbers count up, "+$" pops on sale, a spin reveal, and a rebirth celebration. Keep motion short (0.1-0.3 s) and never block input.
