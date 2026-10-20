# Put the Fries in the Bag

A Roblox restaurant tycoon for up to six players. Claim a restaurant, pack fries into a bag, sell full bags for **Cash**, rebirth for **gems**, buy permanent upgrades, and spin a gacha machine for **pets** that boost your stats and follow you around.

Everything in the world and UI is built in code. No paid assets, plugins, external models, or runtime packages are required.

## Status (18 October 2026)

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
| Visual overhaul 2 | Cartoon pet models, live pet portraits, PETS as a tile grid, new SPIN machine panel | **Built, awaiting Studio test and review** |

Development has paused on new systems for the **visual overhaul** (see What's next). More machines and Robux are deliberately on hold.

## What the game has now

**Restaurants and the core loop**
- Six restaurants around a shared plaza. Gold chevrons guide unclaimed players to free entrances; press E (or tap the prompt) to claim. Owner avatar cards sit above claimed roofs.
- Click, hold, or hold F to pack fries; the basic fryer adds 0.5 fries per second while you are online. Sell a full bag with the button or R.
- A full bag sells for bag capacity x money per fry, rounded down ($10 at the start).

**Progression**
- **Rebirth:** at $1,000 Cash (x1.6 each rebirth), reset Cash and the current bag for gems (10, then +5 each rebirth). Gems, upgrades, pets, and the rebirth count are kept.
- **Upgrades (gems):** fries per click, money per fry, and bag capacity. Permanent; costs rise 1.25x per level.
- **Gacha (Cash):** the Starter Fryer costs $100 per spin, shows its odds, and guarantees an Epic or better by the 50th spin without one.
- **Pets:** 10 Fry Buddies from Common to Legendary, each boosting one or two stats. Equip up to 3; stat = (base + upgrades) x (1 + pet bonuses).
- **Inventory management:** 50 pets; merge 5 copies into a Golden pet (2x bonus); delete one pet, or all unequipped Commons, Uncommons, or Rares; auto-delete chosen rarities as you spin.
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

## What's next: visual overhaul

The game works, but it looks like a prototype. Agreed on 16 October 2026: a **Pet Simulator style**, a **hybrid** approach (layout and panels stay code-built; a small set of icons is uploaded as images), and **design before building** (mockups, then a style guide, then one screen at a time, accepted from Studio screenshots). Build order: style foundation (Theme and Elements), main HUD, panels, feedback and animation, then the world. Scope notes:

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
2. **Pets, gacha, and inventory** (built 18 October 2026, awaiting review): ten cartoon pet models (shared face, Golden gold and sparkles), live 3D portraits, PETS as a tile grid with a detail bar, and the SPIN panel as a result card, pity bar, and a "in this machine" grid with each pet's chance. Upgrades and rebirth layouts are unchanged for now.
3. **Motion and sound:** press squash, panel pops, count-ups, sale pops, spin reveal, rebirth celebration.
4. **World:** restaurant, fryer, and pet models, plaza decoration, and a physical gacha machine.

Icons drop in at any point: add the PNG to `art/icons/`, upload it, and paste its ID into `src/shared/config/Icons.luau`.

## Later (on hold)

- More machines with better pets, later tied to unlockable worlds (Pet Simulator style). Machines are already data in `src/shared/config/Machines.luau`.
- Robux purchases (odds must be shown; selling gems would sell upgrades directly, so choose carefully).
- Possible: rebirth-count unlocks, extra pet slots, more upgrade tracks.

## Known issues and things to improve

**Needs testing**
- Real DataStore saving has never been tested end to end in a published test experience.
- Following pets have not been checked for performance with six players and 18 pets, or for clipping through walls (they do not collide).

**Balance**
- All numbers (spin price, odds, pity, rebirth curve, gem costs, pet bonuses) are first guesses from one simulation. Retune from playtests. Later rebirth cycles get long without good pets.

**UX**
- Panels scale down to about two thirds on short landscape phones; PETS uses a compact layout there but shows one row of tiles at a time.
- Pets with two bonuses (Fry King) have very small bonus text on their tile.
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
