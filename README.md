# Put the Fries in the Bag

A Roblox restaurant tycoon for up to six players. Claim a restaurant, pack fries into a bag, sell full bags for **Cash**, rebirth for **gems**, buy permanent upgrades, and spin a gacha machine for **pets** that boost your stats and follow you around.

Everything in the world and UI is built in code. No paid assets, plugins, external models, or runtime packages are required.

## Status (20 October 2026)

| Stage | What it added | Status |
| --- | --- | --- |
| Core loop | Claim a restaurant, pack, sell, basic fryer | Accepted |
| UI/UX polish | Plaza, chevron guides, owner cards, HUD, cartoon world, dimmed lighting | Accepted 8 Oct |
| 1. Upgrade shop | Three upgrade tracks, money per fry pricing | Accepted 8 Oct |
| 2. Gems and rebirth | Rebirth at a rising Cash threshold for gems; upgrades cost gems | Accepted 16 Oct |
| 3. Gacha machine | $100 Starter Fryer, 10 pets, pity, inventory, equipping, delete | Accepted 16 Oct |
| 4. Following pets | Equipped pets follow their owner; Settings with two toggles | Accepted 16 Oct |
| 5. Inventory management | Golden merges, delete all by rarity, auto-delete | Accepted 16 Oct |
| Visual overhaul 1 | Diner Sticker style foundation, icon system, new HUD layout, all panels restyled | Accepted 18 Oct |
| Visual overhaul 2 | Cartoon pet models, live pet portraits, PETS as a tile grid, new SPIN machine panel | Accepted 20 Oct |
| Rebalance | Flat three-stat pets, percentage upgrades, 40-fry bag, short numbers, no Cash cap, faster first world | **Built, awaiting Studio test and review** |
| Restaurant tiers | Six restaurants (Fry Stand to Fry Palace) bought with Cash, six physical gacha stands, 48 pets, EXPAND kiosk, themed restaurants | **Built, awaiting Studio test and review** |

Overhaul increments 1 and 2 are accepted. **The rebalance and restaurant tiers are built and awaiting review** (both below). The owner gave full control over the tiers' themes, pets, and numbers. Robux stays on hold.

## What the game has now

**Restaurants and the core loop**
- Six restaurants around a shared plaza. Gold chevrons guide unclaimed players to free entrances; press E (or tap the prompt) to claim. Owner avatar cards sit above claimed roofs.
- Click, hold, or hold F to pack fries; the basic fryer adds 0.5 fries per second while you are online. Sell a full bag with the button or R.
- A full bag sells for bag capacity x money per fry, rounded down ($40 at the start: 40 fries x $1).

**Progression**
- **Rebirth:** at $250K Cash (x2 each rebirth), reset Cash and the current bag for gems (10, then +5 each rebirth). Gems, upgrades, pets, and the rebirth count are kept.
- **Upgrades (gems):** +10% fries per click, money per fry, or bag capacity per level (levels add up). Permanent; costs rise 1.25x per level.
- **Restaurant tiers (Cash):** six restaurants from the Fry Stand to the Fry Palace, bought at the EXPAND kiosk. Each keeps every earlier machine, adds a new one, and dresses the restaurant in its theme. Permanent; survive rebirth.
- **Gacha (Cash):** six machines as physical stands in front of your restaurant, from the Starter Fryer ($150) to the Royal Fryer ($4B). Walk onto a stand's pad to spin. Each shows every pet's chance and guarantees an Epic or better by the 50th spin without one.
- **Pets:** 48 Fry Buddies, 8 per machine, from Common to Legendary. Every pet adds flat fries per click, money per fry, and bag size, leaning towards one. Equip up to 3; stat = (base + equipped pets) x (1 + upgrade percent).
- **Inventory management:** 50 pets; merge 5 copies into a Golden pet (2x stats); delete one pet, or all unequipped Commons, Uncommons, or Rares; auto-delete chosen rarities as you spin.
- **Following pets and Settings:** equipped pets follow their owner for everyone to see. Settings: *Pets follow me* and *Show other players' pets*.

**Under the hood**
- The server decides every result: purchases, rolls, rebirths, and pet changes. Clients send only names or IDs, which are validated.
- Session-locked saving with retries, autosaves, and safe refusal of unreadable saves. Older test saves migrate safely.
- 89 automated tests (rules, saving, server wiring, UI layout at five screen sizes) and a reproducible place builder.

## How to play (Studio)

1. Open **FriesGame.rbxlx** in Roblox Studio using **File > Open from File**, then press **Play**. The world is built when the server starts; an empty edit view before Play is expected.
2. Walk to a free entrance and press **E** (or tap the prompt) to claim it.
3. Pack with the gold button, by holding it, or by holding **F**. Sell a full bag with the green button or **R** at your counter.
4. Use the menu grid below the Cash card (top right on short screens): **UPGRADES**, **REBIRTH**, **SPIN**, **PETS**. The gear beside **RETURN TO COUNTER** opens **Settings**.

Studio runs in labelled **memory-only test mode** by default, so progress resets when you stop. If nothing appears after Play, check the Output window.

## Rebalance (built 20 October 2026, awaiting review)

Pets become the source of base stats and upgrades become percentages: **(base + equipped pets) x (1 + upgrades)**. Reasons: percentage pet bonuses on a small base were nearly worthless (+5% of 1 fry), flat upgrades would stop mattering once pets are strong, and flat pet stats let each new machine's pets be several times stronger, Pet Simulator style. It also gives future enchantments a clean base to work on. The game is meant to scale into the billions and trillions.

Agreed criteria. Numbers come from `tools/simulate.py`; the owner asked for higher pet stats and a fast first world (about 20 minutes to the Fry Diner), and approved them on 20 October 2026.

1. **Every pet adds all three stats as flat amounts** (fries per click / money per fry / bag), with a **lean** so pets differ in more than size. Fries and money multiply each other, so rarity steps are small on paper (about x1.5 Uncommon, x2 Rare, x3 Epic, x4 Legendary) but large in play. Golden doubles every stat.

   | Starter Fryer pet | Rarity | Fries/click | Money/fry | Bag |
   | --- | --- | --- | --- | --- |
   | Crinkle Fry (click) | Common | +4 | +$1.00 | +10 |
   | Salt Shaker (money) | Common | +2 | +$2.00 | +10 |
   | Paper Cup (bag) | Common | +2 | +$1.00 | +20 |
   | Potato Pup | Uncommon | +6 | +$1.50 | +15 |
   | Ketchup Packet | Uncommon | +3 | +$3.00 | +15 |
   | Mayo Jar | Rare | +4 | +$4.00 | +20 |
   | Fryer Bot | Epic | +6 | +$3.00 | +60 |
   | Fry King | Legendary | +12 | +$6.00 | +60 |

   Deluxe Fryer pets (restaurant tier 2) are 4x the Starter pet in the same slot; Napkin Ghost (+8 / +$4 / +80) and Curly Fry Cat (+16 / +$16 / +80) already have their Deluxe stats.
2. **6 to 8 pets per machine.** Proposed Starter Fryer (8): Crinkle Fry, Salt Shaker, Paper Cup (Common); Potato Pup, Ketchup Packet (Uncommon); Mayo Jar (Rare); Fryer Bot (Epic); Fry King (Legendary). Napkin Ghost and Curly Fry Cat move to the Deluxe Fryer, so their models are reused and old test saves stay valid.
3. **Upgrades are percentages:** +10% per level on each track, added (not compounded). Gem costs unchanged (3, 4, and 5 gems, x1.25 per level).
4. **Base player:** 2 fries per click, $1 per fry, 40-fry bag ($40 per bag). The basic fryer stays at 0.5 fries per second.
5. **Short numbers:** Cash, prices, and stats show as $1.25K, $3.4M, $1.25B, $2T and so on (see 6 for the full list).
6. **No practical Cash cap** (owner decision, 20 October 2026). The $1 trillion cap goes. A hidden safety limit at 1e300 stays only so a number can never become infinity, which would corrupt a save; no player can reach it. Short names run K, M, B, T, Qa, Qi, Sx, Sp, Oc, No, Dc, then scientific notation (1.2e36). Above about 9 quadrillion, amounts are kept to about 15 significant digits, far finer than anything the game shows.
7. **Prices:** Starter spin $150 (about 20 seconds of a new player's income); rebirth $250K, then x2 each time; gems per rebirth unchanged (10, +5 each). Restaurant tiers: Fry Diner $5M and Deluxe spin $150K (see Restaurant tiers for the rest). Odds and pity unchanged.
   Simulated pace (median, `tools/simulate.py`): first spin 20 s, first rebirth 3 min, rebirths 2 and 3 at 6 and 9 min, Fry Diner 18 min. The first Legendary comes at about 1 minute: the Starter Fryer is the quick first machine; the longer chases are Golden pets, the Diner, and the Deluxe Fryer.
8. **Tests and docs** updated: pricing formula, pet text, shop text, number formatting, caps.

## Restaurant tiers (built 20 October 2026, awaiting review)

Better gacha machines are how players progress, and each new machine also upgrades the restaurant: a better machine means a more elaborate restaurant that everyone on the plaza can see. Agreed with the owner on 20 October 2026: machines are physical stands; new machines join the old ones; tiers cost Cash, are permanent, and survive rebirth; tiers change machines and looks only (the fryer rate stays fixed). The owner then asked for four more tiers beyond the Fry Diner and gave full control over their themes, pets, and numbers.

| Tier | Restaurant | Price | Machine (spin) | Theme | Pets (Common, Common, Common, Uncommon, Uncommon, Rare, Epic, Legendary) |
| --- | --- | --- | --- | --- | --- |
| 1 | Fry Stand | free | Starter Fryer ($150) | the original coral and cream | Crinkle Fry, Salt Shaker, Paper Cup, Potato Pup, Ketchup Packet, Mayo Jar, Fryer Bot, Fry King |
| 2 | Fry Diner | $5M | Deluxe Fryer ($150K) | 50s diner: red, chrome, pink neon, chrome stools, a jukebox, a checkered entrance | Onion Ring, Pickle Chip, Napkin Ghost, Hash Brown Hamster, Milkshake, Curly Fry Cat, Cheese Sauce Slime, Fry Phoenix |
| 3 | Drive-In | $30M | Drive-In Grill ($1.5M) | teal and sunset orange, a giant burger and a classic car on the roof, string lights | Sesame Bun, Mustard Bottle, Paper Tray, Burger Bear, Soda Seal, Hot Dog Pup, Carhop Bot, Burger Dragon |
| 4 | Fish & Chips Pier | $750M | Pier Fryer ($25M) | navy and white with a wooden floor, a lighthouse, a giant fish, life rings | Fish Stick, Tartar Tub, Newspaper Cone, Chip Crab, Vinegar Owl, Seagull Thief, Battered Octopus, Fry Kraken |
| 5 | Cosmic Diner | $10B | Cosmic Fryer ($200M) | deep purple and cyan neon, a ringed planet, a satellite dish, floating stars | Moon Fry, Star Salt, Astro Cup, Alien Tot, Comet Cola, Saucer Burger, Robo Chef, Galaxy Fry Lord |
| 6 | Fry Palace | $350B | Royal Fryer ($4B) | royal purple and gold, gold columns, a crown on the roof, banners, a red carpet | Truffle Fry, Pepper Knight, Velvet Box, Butler Spud, Crown Ketchup, Diamond Dip, Fry Unicorn, Fry Emperor |

How it works:

- **Stands:** all six machine stands stand along the front of every plot, three each side of the entrance path. Stands your restaurant has not reached are grey and LOCKED (with the restaurant they need), so everyone sees what comes next. Walk onto a stand's glowing pad to open its SPIN panel; walk off to close it. The server only spins at the right stand, for a tier you own.
- **SPIN menu button:** moves you onto your best machine's pad (like Return to Counter does for the counter). Walk along the row to reach the others.
- **EXPAND kiosk:** inside the restaurant, front left. Walk onto its pad to open the EXPAND panel: the next restaurant, its tagline, the machine it adds with its top pet as a live portrait, and the price. A hint appears when you can afford it.
- **Pets:** every machine's pets are 4x the previous machine's, slot for slot (Fry Emperor: +12,288 fries/click, +$6,144/fry, +61,440 bag). Same odds and pity everywhere; pity is counted per machine.
- **Looks:** each tier recolours the roof, fascia, posts, awning, counter, benches, and floor, adds a roof sign with the restaurant's name, neon trim, and themed props. Releasing a plot returns it to the Fry Stand look.
- **Saving:** `restaurantTier` (1-6) in the profile; missing means 1. Kept through rebirth.
- **Pace** (`tools/simulate.py`, one ideal player): Fry Diner at about 18 min, Drive-In 46, Pier 66, Cosmic 90, Palace about 110. Prices for tiers 3-6 were derived with `python3 tools/simulate.py --calibrate` (5 minutes of saving for tier 3, 1.5x longer for each tier after), then rounded.

## Visual overhaul (increments 1 and 2 accepted)

The game worked, but it looked like a prototype. Agreed on 16 October 2026: a **Pet Simulator style**, a **hybrid** approach (layout and panels stay code-built; a small set of icons is uploaded as images), and **design before building** (mockups, then a style guide, then one screen at a time, accepted from Studio screenshots). Build order: style foundation (Theme and Elements), main HUD, panels, feedback and animation, then the world. Scope notes:

- **HUD and panels:** a consistent, more playful style (colour, shape, icons, motion) to replace the dark functional cards; better icons than the current fry and bag symbols and the code-built gear.
- **Feedback and juice:** spin reveal animation, sale and purchase pops, rebirth celebration, sounds, and particles.
- **Pets:** more detailed and recognisable models, Golden sparkle, idle animations.
- **World:** detailed restaurant and fryer models, plaza decoration, the gacha machine as a physical object in the plaza.

### Chosen visual direction: Diner Sticker (agreed 17 October 2026)

Picked from three mockups (the "Fries HUD style directions" design canvas, artboard B). Pet Simulator energy with a fries-shop theme. The full rules are now in **docs/STYLE_GUIDE.md**. In short:

- **Colours:** ketchup red `#e63946` (headers, primary), mustard `#ffb703` (pack, merge, highlights), teal `#2a9d8f` (sell, equipped), cream `#fff4dc` (panel and card bodies), ink brown `#3d1f1f` (text, shadows, outlines), white `#ffffff` (sticker borders). Menu accents: orange `#f77f00` upgrades, grape `#7b2cbf` rebirth, teal `#2a9d8f` spin, blueberry `#1d6fd8` pets.
- **Rarity colours** (darkened for readable text): Common `#806c58`, Uncommon teal `#1f8a7e`, Rare blueberry `#1d6fd8`, Epic grape `#7b2cbf`, Legendary and Golden gold `#b07600`.
- **Type:** Luckiest Guy for titles, numbers, and button labels; Fredoka for body text. Both ship with Roblox (`Enum.Font.LuckiestGuy`, `Enum.Font.FredokaOne`).
- **Shapes:** a white 4-6 px "sticker" border plus a solid ink-brown shadow offset 5-9 px down and right. Pills are fully rounded; cards use 16-30 px corners. Panel headers are ketchup red with a red-and-cream checker strip below; dividers are dashed tan.
- **Layout:** Cash and Gems on a receipt-style card at the top left; the menu is a column of wide pill buttons (icon disc plus label) below it; Return to Counter and the settings gear at the top centre; Pack and Sell as big sticker buttons at the bottom centre; pets as a grid of tiles with a rarity-coloured top band and shadow.
- **Rules:** buttons and tiles at least 44 px; text keeps strong contrast (ink on cream, white on red or with an ink shadow); icons come from the uploaded set in `art/` with code-built fallbacks.

### Overhaul increments

1. **Foundation and HUD** (accepted 18 October 2026): Theme and Elements in Diner Sticker, the icon system with code-built fallbacks, the new HUD layout, and every panel on the shared frame.
2. **Pets, gacha, and inventory** (accepted 20 October 2026): ten cartoon pet models (shared face, Golden gold and sparkles), live 3D portraits, PETS as a tile grid with a detail bar, and the SPIN panel as a result card, pity bar, and a "in this machine" grid with each pet's chance. Upgrades and rebirth layouts are unchanged for now.
3. **Motion and sound:** press squash, panel pops, count-ups, sale pops, spin reveal, rebirth celebration.
4. **World:** restaurant, fryer, and pet models, plaza decoration, and a physical gacha machine.

Icons drop in at any point: add the PNG to `art/icons/`, upload it, and paste its ID into `src/shared/config/Icons.luau`.

## Later (on hold)

- More restaurant tiers past the Fry Palace, later perhaps unlockable worlds. Add a tier in `config/Restaurants.luau`, a machine in `config/Machines.luau`, its 8 pets in `config/Pets.luau` (4x the previous machine), pet recipes in `client/ui/PetModels.luau`, a stand slot and decoration in `server/world/TierBuilder.luau`, then rerun `tools/simulate.py --calibrate`.
- Robux purchases (odds must be shown; selling gems would sell upgrades directly, so choose carefully).
- Possible: rebirth-count unlocks, extra pet slots, more upgrade tracks.

## Known issues and things to improve

**Restaurant tiers (new)**
- The six stands, kiosk, and themed props are built from simple parts and have not been seen in Studio yet: check sizes, overlaps with walls and hedges, and that the signs read well.
- Every claimed plot shows its owner's tier to everyone on the server; unclaimed plots show the Fry Stand look with the Starter Fryer open and the other five LOCKED.
- 38 new pet models are code-built recipes; some will need tuning once seen in 3D.
- Late tiers come quickly once rebirths stop gating (the rebirth threshold doubles while income grows about 16-30x per tier). Retune `tools/simulate.py` after playtests.

**Needs testing**
- Real DataStore saving has never been tested end to end in a published test experience.
- Following pets have not been checked for performance with six players and 18 pets, or for clipping through walls (they do not collide).

**Balance**
- All numbers come from `tools/simulate.py`, which models one ideal player. Retune from playtests and rerun it after any change. Rebirths slow down after the Diner until tier 3 exists.

**UX**
- Panels scale down to about two thirds on short landscape phones; PETS uses a compact layout there but shows one row of tiles at a time.
- Pet tiles show three stat lines; on the phone detail bar the stats wrap onto two lines (check in Studio).
- The SPIN panel layout was not mocked up first; treat it as a first draft for feedback.
- The merge banner only merges the rarest mergeable pet at a time; there is no sorting, filtering, or "equip best".
- Menu labels are small in the short-landscape grid.

**Technical**
- Profiles are still version 1 with many optional fields. Before launch, decide whether to move to a clean version 2 and drop inactive fields from the old prototype.
- Rate limits and cooldowns were chosen by judgement, not measured.
- Tests use engine doubles and layout previews use approximate fonts; neither replaces a Studio playtest.

**Before public release**
- Set the experience's maximum players to 6, keep live and test DataStores separate, and re-check every number above.

## Development workflow (AGILE)

1. Agree one small outcome and its acceptance criteria before building.
2. Build only that; put other ideas in the backlog.
3. Run the automated checks and playtest in Roblox Studio.
4. Review with the project owner and choose the next stage together.
5. Keep the game playable after every stage; fix core-loop failures before adding scope.

**Standing rules:** never add floating fryer or equipment name tags. Keep balance numbers in `src/shared/config`. Add a regression test when changing a rule or fixing a bug. Review persistence and remote-input changes together. Never reuse a saved field name from the old prototype (`upgrades`, `equipped`, `owned`, `tickets`, `discoveries`).

## Documentation

| File | Contents |
| --- | --- |
| docs/GAME_RULES.md | Every current game rule and number |
| docs/ARCHITECTURE.md | Modules, the remote contract, transactions, and the save format |
| docs/STUDIO_TESTS.md | Manual Studio checks, newest stage first |
| docs/STYLE_GUIDE.md | Diner Sticker colours, type, shapes, layout, and touch rules |
| docs/HISTORY.md | Iteration log, the progression design with its reasoning, and every stage's acceptance criteria |
| art/README.md | Every image the game needs, its size, and its upload status and asset ID |
| VALIDATION.md | Recorded automated results per stage |

## Saving and publishing

Runtime configuration is in **src/shared/config/Runtime.luau**.

- **StudioUseDataStore = false:** Studio uses memory only.
- **StudioUseDataStore = true:** Studio uses **FriesProfiles_TEST_v1**. Use a separately published test experience with **Studio Access to API Services** enabled.
- Published servers always use **FriesProfiles_v1**.

Profiles save about every 45-55 seconds and on exit. A crash can lose work since the last save. A session lock stops two servers editing one profile; after an unclean shutdown it may take up to three minutes to expire. If a save cannot be read safely, the player is asked to rejoin rather than being given fresh progress.

Saves from before gems existed load once with 0 gems and level 0 upgrades. Bags larger than the current capacity are trimmed on load, so balance changes cannot make saves unloadable. Fields from the old prototype stay in storage but are never used.

The server reserves one of six places per player on entry, so set the experience's maximum player count to **6**. Changing StationCount beyond six also needs a layout change.

## Source layout

    src/
      shared/
        config/       Economy, upgrades, rebirth, pets, machines, settings, runtime, actions
        domain/       Pure game rules: packing, pricing, upgrades, rebirth, gacha, pets, settings, profile
        util/         Deep copy and rate limiter
      server/
        Main.server.luau       Composition and player lifecycle
        Network.luau           Remote transport
        services/              Data, claiming and stations, actions, snapshots
        storage/               Session-locked persistence
        world/                 Plaza, restaurants, and stations
      client/
        Main.client.luau       UI, input, markers, and following pets
        controllers/           Input handling
        ui/                    HUD, panels, restaurant guides and markers, pet models and follower
    tests/                     Rules, persistence, inventory, and wiring tests
    tools/                     Place builder, test runner, and UI layout previews
    docs/                      Rules, architecture, Studio checks, and history
    art/                       Source images for upload (icons, marketing), with a manifest

Domain modules own the rules and never create Instances, send messages, or touch DataStores. UI modules display server state and send requests.

## Editing workflow

Choose one per work session:

- **Studio:** edit scripts in Explorer and save the place. Scripts live under ReplicatedStorage/FriesShared, ServerScriptService/FriesServer, and StarterPlayer/StarterPlayerScripts/FriesClient.
- **Source files:** edit `src/`, run the builder, and reopen the generated place. Studio-only edits are not exported back to `src/`, and rebuilding replaces FriesGame.rbxlx.

**Watch out:** if FriesGame.rbxlx is open in Studio while it is rebuilt, close that place **without saving** and reopen the file. Saving the old open copy overwrites the new build, and the game silently runs old scripts (this happened on 16 October 2026: pets did not follow because the saved copy predated them).

The optional **default.project.json** supports Rojo; Rojo is not required.

## Build and automated checks

Python 3.9 or newer, standard library only:

    python tools/build.py

The builder embeds every source file into FriesGame.rbxlx and verifies the XML and exact source round-trip. Rojo equivalent: `rojo build default.project.json -o FriesGame.rbxlx`.

Tests use the official Luau tools from https://github.com/luau-lang/luau/releases:

    python tools/test.py --luau PATH_TO_LUAU_EXE --compiler PATH_TO_LUAU_COMPILE_EXE

Optional UI layout previews (requires Pillow) render the real UI modules into **artifacts/ui-preview/**. They are layout aids with approximate fonts, not Roblox screenshots:

    python tools/preview_ui.py --luau PATH_TO_LUAU_EXE --fonts PATH_TO_FONTS

`--fonts` is optional: a folder holding `LuckiestGuy-Regular.ttf` and `Fredoka.ttf` from Google Fonts (github.com/google/fonts, `apache/luckiestguy` and `ofl/fredoka`), so previews use the game's real fonts.

## Team ownership

| Person | Owns | Coordinates with |
| --- | --- | --- |
| 1 | Packing, selling, input, and station interactions | Person 2 on saved progress |
| 2 | Basic economy and persistence | Person 1 on sale rules; Person 3 on displayed values |
| 3 | World geometry and permanent UI | Persons 1 and 2 on action contracts |
