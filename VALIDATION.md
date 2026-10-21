# Validation record

## Restaurant tiers: six restaurants, six machines, 48 pets

Validation date: 20 October 2026.

Scope: restaurant tiers 1-6 (Fry Stand, Fry Diner, Drive-In, Fish & Chips Pier, Cosmic Diner, Fry Palace) bought with Cash at an EXPAND kiosk and kept through rebirth; one gacha machine per tier as a physical stand along the front of every plot (locked stands visible); spins only at the right stand for an owned tier; the SPIN menu button moves the player to their best machine; 38 new pets (8 per machine, 4x the previous machine slot for slot) with code-built models; themed restaurant decoration per tier; the EXPAND panel; prices for tiers 3-6 from the new `tools/simulate.py --calibrate`. The owner gave full control over themes, pets, and numbers.

**101 tests passed, 0 failed.** All **60 Luau source/test files** compiled. Output is in TEST_RESULTS.txt.

New or changed coverage:

- Config: six tiers with rising prices, one machine each, 8 pets per machine, every pet in exactly one machine, 4x stats slot for slot, theme colours present.
- Rules: expanding charges once, one tier at a time, refuses without Cash and at the top; locked machines refuse without charging; pity per machine; older machines keep working; rebirth keeps the tier; `restaurantTier` validated (1-6 whole numbers) and saved.
- Server: Spin refused away from the stand (and at the wrong stand); VisitMachine moves the player onto the best stand; Expand refused away from the kiosk and without Cash; a real $5M earned by packing and selling buys the Fry Diner once (a rapid second request is ignored); the world shows tier 2 (attribute, decoration, unlocked Deluxe stand, plaque name); another player's tier is unaffected.
- World: every plot has six stands and a kiosk; applying tiers 2-6 unlocks the right stands, recolours the plot, adds anchored non-touching decoration, and names the restaurant; applying tier 1 restores the original colours and removes decoration; pads sit inside the plot clear of the entrance path.
- Client: the SPIN button sends VisitMachine; standing at a stand opens its panel (and closes others); a locked machine shows its pets and LOCKED and sends nothing; walking away closes it; the button count includes the EXPAND panel.
- Pet models: all 48 recipes build anchored, non-colliding parts with two eyes, a body, and Golden sparkles.

Found and fixed while building: two files were briefly copied to the project before their last edit (the EXPAND panel's top-pet text and a test-only field in the world builder that would have errored in Roblox); a test comment had swallowed one assertion in the merge test; the SPIN teleport faced away from the stand on south-side plots.

Not yet done: Studio playtesting (docs/STUDIO_TESTS.md, restaurant tiers) and owner review. Model and decoration proportions especially need a real Studio look.

## Rebalance: flat three-stat pets, percentage upgrades, short numbers, no Cash cap

Validation date: 20 October 2026.

Scope: every pet adds flat fries per click, money per fry, and bag size (with a lean); upgrades give +10% per level (added); base player 2 fries per click, $1 per fry, 40-fry bag; Starter Fryer cut to 8 pets at $150 (Napkin Ghost and Curly Fry Cat kept as pet types for the Deluxe Fryer); rebirth $250K x2; short number text (K to Dc, then scientific); Cash cap raised from $1 trillion to a hidden 1e300 safety limit. Numbers come from the new `tools/simulate.py`, approved by the owner.

**95 tests passed, 0 failed.** All **55 Luau source/test files** compiled. Output is in TEST_RESULTS.txt.

New or changed coverage:

- Formula: (base + pets) x (1 + 10% per level), additive not compounding (level 10 = 2x); money pets in dollars on a cents base; capacity and sale rounding.
- Pets: every type has three positive stats and no percentage bonuses; each machine has 6-8 pets with one Common per lean; leans hold; sale value rises with rarity; Golden doubles all three stats; moved pets still load from saves.
- Short numbers from 0 to 5e120, rounding at suffix edges (999,949 shows as 1M), negatives, NaN and infinity, and money with cents.
- No cap: Cash beyond $1 trillion credits and validates; Cash stays finite at the safety limit; infinity is still rejected.
- All earlier tests updated to the new numbers. The server rebirth test still earns the $250K threshold by real packing and selling (6,247 bags).

The preview review led to pet tiles with one line per stat (taller tiles), wrapping detail-bar stats, a taller compact PETS panel on short landscape screens, and cents for money per fry in the upgrade shop.

Not yet done: Studio playtesting (docs/STUDIO_TESTS.md, rebalance) and owner review, especially whether the first world feels fast enough in real play.

## Visual overhaul 2: pet models, gacha, and inventory panels

Validation date: 18 October 2026.

Scope: ten rebuilt cartoon pet models with a shared face and a Golden variant, live 3D portraits, the PETS panel as a tile grid with a detail bar, the SPIN panel as a result card, pity bar, and per-pet chance grid, responsive panel sizes, and grids that fill their width. The machine snapshot now lists each rarity's pet types so the panel can show per-pet chances. No game rules changed.

**91 tests passed, 0 failed.** All **53 Luau source/test files** compiled. Output is in TEST_RESULTS.txt.

New or changed coverage:

- Pet models: every pet has a recipe; every part is anchored, non-colliding, non-touching, and non-queryable; each has two eyes and a body; Golden pets get a shiny body and two sparkles; `place` moves pieces with their base.
- Portraits: a ViewportFrame with a camera; the same pet is not rebuilt; a change (including Golden) rebuilds.
- SPIN: all ten pets in the pool with chances that add up to 100% (20%, 8.33%, 5%, 4%, 1%); the "?" before the first spin, then the portrait, rarity tag, name, and bonus.
- PETS: tiles with portrait, name, short bonus, and tick; tap to select; EQUIP, UNEQUIP, SLOTS FULL; two-tap DELETE from the detail bar; tiles reused across updates and removed when the pet goes; Golden tiles.
- Layout at all six screen sizes: SPIN is two columns when wide and stacked when narrow, with no overlapping parts; the PETS grid sits above the detail bar; panel shadows scale with their panels.

Bugs found and fixed during this increment: the DELETE button field overwrote the panel's delete method (tapping DELETE would have errored); panel shadows did not shrink with scaled panels on short landscape screens (a large dark box behind the panel); the narrow SPIN layout could overlap the pity bar on short panels; tile grids left an empty strip on the right. The preview tool now draws tile grids, portrait placeholders, and clipping.

Not yet done: Studio playtesting (docs/STUDIO_TESTS.md, visual overhaul 2) and owner review. Portrait framing, model proportions, and the cost of 50 live portraits need a real Studio look.

## Visual overhaul 1: Diner Sticker foundation and HUD

Validation date: 17 October 2026.

Scope: Diner Sticker tokens and fonts, sticker buttons with following shadows, the shared panel frame, the icon system (17 icons, all code-built fallbacks for now), the new HUD layout, all five panels restyled, readable rarity colours, and restyled restaurant markers. No game rules changed.

**90 tests passed, 0 failed.** All **52 Luau source/test files** compiled. Output is in TEST_RESULTS.txt.

New or changed coverage:

- Shadows: a sibling that matches its button's position (plus offset), size, visibility, and layer, and is removed with it; flat buttons get none.
- Icons: every configured icon has no asset ID yet and draws a code-built fallback.
- Fonts and colours: Luckiest Guy for numbers and buttons, Fredoka One for body text, coloured panel headers.
- Layout at 320x568, 390x844, 568x320, 844x390, and 1280x720: the wallet at the top left; pills on tall screens and an icon grid on small and short ones; every control on screen, at least 44 px, and not overlapping anything (shadows included).
- All earlier behaviour tests still pass with the new look.

The test engine double now supports property-change signals (used by shadows). The preview tool now renders the real fonts (with `--fonts`), rotation, padding, letter outlines, and scale-based corners, and centres button text as Roblox does. Preview review led to: `»` instead of `→` (neither font has an arrow), a darker gold for Golden pet names, a clipped receipt divider on short screens, a less crowded Pack button, and rebirth card spacing.

**Revised after the owner's first Studio screenshot (17 October 2026):** menu buttons always show their names (labelled tiles replace the icon-only grid on short screens); Pack and Sell grew to 232 x 104 so CLAIM FIRST fits; guidance moved under the top bar on wide screens so the labelled menu fits on laptops; the world now has grass to the horizon and a warm atmosphere instead of a floating island against a flat blue sky. The layout test now covers 375x667, 390x844, 640x360, 844x390, 947x600 (the owner's screen), and 1280x720, and checks every menu button's name is visible. 90 tests pass.

Not yet done: Studio playtesting (docs/STUDIO_TESTS.md, visual overhaul 1) and owner review. Font rendering, shadows, and icon legibility in particular need a real Studio look.

## Stages 4 and 5: following pets, settings, and inventory management

Validation date: 16 October 2026.

Scope: code-built pets that follow their owner, the Settings panel (Pets follow me, Show other players' pets), Golden merges, delete all by rarity, and auto-delete by rarity.

**89 tests passed, 0 failed.** All **50 Luau source/test files** compiled. The rebuilt place contains **44 game source files**. Output is in TEST_RESULTS.txt.

New coverage:

- Merging: 5 unequipped copies become one Golden pet with a new ID and 2x bonus; equipped copies are excluded; Golden pets never merge again; the rarest mergeable pet is offered first.
- Delete all removes only unequipped, non-golden pets of Common, Uncommon, or Rare; Epic, Legendary, and unknown rarities are refused.
- Auto-delete: matching spins cost Cash and count for pity but are not kept; Epic and Legendary cannot be auto-deleted.
- Settings default ON, toggle, reject unknown names, can change before claiming, save, and load.
- The public FollowPets text lists equipped pets with Golden marks and is empty when Pets follow me is off.
- Validation of golden flags, settings, and auto-delete (8 corrupt cases rejected), plus save and load.
- Server flow: 69 sales, 4 spins, merge, equip, settings toggles updating the attribute, auto-deleted spin, delete all, refusals, and forged arguments dropped.
- Follower: own and other players' pets drawn near their characters, non-colliding and anchored, easing rather than snapping, hidden by Show other players' pets, removed for dead or departed players, and rebuilt when the attribute changes.
- Client: Settings panel toggles and requests, Golden rows, auto-delete and delete-all chips with two-tap confirmation, the merge banner, auto-deleted spin results, and bounds for the gear button and Settings panel at all five viewports.

Layout previews (including the Settings panel and the PETS tools) were regenerated and inspected. That led to an outline on OFF toggles. Pet models cannot be previewed outside Studio.

**Accepted by the project owner on 16 October 2026.** Six-player performance and real DataStore persistence remain untested.

## Increment 3: first Cash gacha machine

Validation date: 16 October 2026.

Scope: the Starter Fryer ($100 per spin), 10 pets with rarity odds and pity, a 50-pet inventory, 3 equip slots with stat bonuses, single delete, the SPIN and PETS panels, and the 2x2 menu grid.

**78 tests passed, 0 failed.** All **44 Luau source/test files** compiled. The rebuilt place contains **39 game source files**. Output is in TEST_RESULTS.txt.

New coverage:

- Machine odds sum to 1; every pool pet has a listed rarity; random numbers map to the right rarity and pet; 40,000 seeded spins land within tolerance of the advertised odds.
- Pity: 49 non-Epic spins, then a forced Epic or better (Epic 80%, Legendary 20%); natural and forced Epics reset the counter.
- Spins charge exactly $100, add uniquely numbered pets (IDs never reused), and refuse when broke, full, or for an unknown machine.
- Equipping: 3 slots, duplicate and unowned refusals, bonuses stacking within a stat and multiplying with upgrades (for example Fry King: $0.75 per fry, $15 per bag), capacity rounded down, and an over-full bag trimmed on unequip.
- Delete refuses equipped pets; rebirth keeps pets, equipped pets, and pity; upgrade shop values include pet bonuses.
- The old prototype's `equipped` equipment table never counts as equipped pets. That clash was caught by the existing legacy-save tests, so the new field is named `equippedPets`.
- Pet, equipped, next-ID, and pity validation (16 corrupt cases rejected), plus save and load.
- Server flow: Cash and cooldown checks, server-side rolls, result only in the spin's own snapshot, equip/unequip/delete with refusals, forged arguments dropped, separate state per player, and Spin rejected before claiming.
- Client: machine title, pity countdown, odds rows, NEED / SPIN / INVENTORY FULL states, the result in rarity color, fractional stats (+3.15 fries/click), pets list rows, EQUIP / UNEQUIP, two-tap DELETE, full slots, the empty state, one panel open at a time, and everything inactive before claiming.
- Calculated bounds for the four menu buttons and four panels at all five viewports.

Bag size is now only sanity-checked in saves and trimmed to the current capacity on load, so changing pet or upgrade balance cannot make existing saves unloadable.

Layout previews (including desktop/phone machine and pets panels and a wide short screen) were regenerated and inspected. The preview tool now stacks list rows like Roblox's list layout. That review led to fit-to-width odds labels, short bonus wording in pet rows, and UNEQUIP aligned right. The previews use approximate fonts and are not Roblox screenshots.

**Accepted by the project owner on 16 October 2026.**

## Increment 2: gems and rebirth

Validation date: 16 October 2026.

Scope: the gem balance, rebirth (threshold, reward, reset), the upgrade shop switched from Cash to gems, the one-time reset of Cash-bought upgrade levels in older saves, the REBIRTH button and panel, and the Gems row on the Cash card.

**63 tests passed, 0 failed.** All **36 Luau source/test files** compiled. The rebuilt place contains **32 game source files**. Output is in TEST_RESULTS.txt.

New coverage:

- Rebirth thresholds ($1,000, $1,600, $2,560, $4,096, $6,554) and gem rewards (10, 15, 20, ...).
- Rebirth refuses below the threshold, then resets Cash (including any excess) and the bag only, keeping gems, levels, sales, and lifetime Cash.
- Gem upgrade costs (3, 4, 5 x 1.25^level), purchases spend gems never Cash, and insufficient gems are rejected.
- Pre-gem saves migrate once: 0 gems, 0 rebirths, level 0 upgrades, Cash kept, and an oversized bag trimmed to 20 fries. Newer saves are never migrated again.
- Gems and rebirths validate as whole non-negative numbers, then save and load; corrupt values refuse to load.
- Server flow over 98 sales to the first rebirth: threshold and gem notices, a rapid second rebirth or purchase ignored, forged arguments dropped, separate state per player, and Rebirth rejected before claiming.
- Client: Gems on the wallet card, gem prices in the shop, Buy buttons depending on gems rather than Cash, the rebirth panel's values and confirm state, only "Rebirth" sent with no argument, the panel closing after a rebirth, one panel open at a time, and both inactive before claiming.
- Calculated bounds at all five viewports for both buttons, both panels, and the Studio test label, which moved to the bottom-left corner.

Layout previews (including desktop/phone/landscape rebirth panels) were regenerated and inspected. That review found the REBIRTH button drawing over the open upgrade panel on phones; both panels now sit on a higher layer, and the preview tool respects that layering. It also found the Studio test label overlapping the Cash card on short screens. The previews use approximate fonts and are not Roblox screenshots.

**Accepted by the project owner on 16 October 2026.**

## Increment 1: upgrade shop

Validation date: 8 October 2026.

Scope: money per fry pricing, the three Cash upgrade tracks, saved upgrade levels, the Upgrade action, the UPGRADES button and shop panel, and dimmed world lighting from the owner's polish review.

**60 tests passed, 0 failed.** All **33 Luau source/test files** compiled. The rebuilt place contains **29 game source files**. Output is in TEST_RESULTS.txt.

New coverage:

- Cost curves and rounding for all three tracks; costs never decrease as levels rise.
- Effects of each level on fries per click, money per fry, capacity, and sale value, including rounding down ($13.75 -> $13).
- Purchases deduct once, raise one level, reject insufficient Cash and unknown tracks, and leave lifetime Cash unchanged.
- The old prototype `upgrades` field never grants levels.
- Buying capacity with a full bag makes it partial without losing fries.
- Upgrade levels save and load; saves without levels load at level 0; corrupt levels refuse to load.
- Server remote flow: unclaimed rejection, insufficient Cash notice, the purchase cooldown blocking a rapid second buy, forged arguments dropped before dispatch, upgraded packing and sale values, and separate state per player.
- Shop UI: rows show server values, unaffordable Buy buttons are inactive and send nothing, affordable ones send only the track name, and the panel stays closed before claiming.
- Calculated bounds for the UPGRADES button and panel at 320x568, 390x844, 568x320, 844x390, and 1280x720, clear of the actions, Cash card, Return to Counter, and guidance.

Layout previews (including desktop-shop, phone-shop, and landscape-shop) were regenerated with tools/preview_ui.py and inspected. That review caught the pack button title wrapping at "+2 fries/click"; the titles now shrink to fit on one line. The previews use approximate fonts and are not Roblox screenshots.

**Accepted by the project owner on 8 October 2026** after review. The dimmed lighting was also approved.

## UI/UX polish iteration (accepted 8 October 2026)

Validation date: 8 October 2026.

Scope: the owner-approved UI/UX iteration on the working core loop, including the smooth cartoon world pass. Base packing, fryer production after claiming, and $10 sales are unchanged.

## Automated results

**48 tests passed, 0 failed.** All **29 Luau source/test files** compiled. The rebuilt place contains **26 game source files**. Output is recorded in TEST_RESULTS.txt.

Coverage includes:

- Core filling, full-bag selling, repeated-sale rejection, exact Cash totals, and a deterministic 10,000-action simulation.
- Save/load compatibility, lease/session locking, retries, lost-response recovery, and invalid core data.
- No automatic plot assignment or production before claiming.
- Server-side claim distance and health checks, one plot per player, occupied-plot/race rejection, and six admission slots including unclaimed players.
- Session claims survive respawn and release on departure; a replacement player can claim the released plot.
- Separate private state, owner-only work/teleport, basic fixed rates, and rejection of retired actions.
- Six separated restaurant plots with inward-facing entrances, physical wall signage, and no fryer name labels.
- Ceiling coverage/headroom and wall joins across all six restaurants; solid perimeter alignment, corner overlap, and clearance outside every plot.
- Taller restaurant headroom, interior fixture mounting/clearance, downward light faces, and conservative range/cone coverage of floor corners and working surfaces in both restaurant orientations.
- Three permanent HUD actions, middle-left Cash placement/formatting, fries-per-click hover labels, embedded bag capacity, full-bag sell state, E reserved for claiming, and R for selling.
- Calculated HUD bounds for 320x568, 390x844, 568x320, 844x390, and 1280x720.
- Per-player availability arrows, account usernames, owner card release/reclaim, stale thumbnail responses, and bounded thumbnail retries with an initial fallback.
- Player-head guide attachment, moving chevrons, forward direction and gaps, bounded geometry reuse, frame-rate-independent directional animation and faded loops, non-colliding geometry, claim cleanup, death/respawn rebinding, missing characters, and zero-length guide suppression.

The builder verifies XML parsing, exact source round-tripping, and the saved Soft LightingStyle setting.

### Startup regression after the cartoon pass

The owner reported missing restaurant claiming and HUD elements. The cartoon pass wrote LightingStyle from WorldBuilder at runtime, before the server created remotes or connected claiming. Roblox documents this as an editor-only property. The prior engine double accepted arbitrary property writes and missed this failure.

The engine double now rejects runtime writes to editor-only lighting settings. Before the fix, the startup test failed at LightingStyle and FriesRemotes was absent, reproducing the broken startup path. After moving LightingStyle into the saved place builder and Rojo configuration, all 40 tests pass, including startup, claiming, client HUD creation, and fill/sell behavior. Studio verification of the rebuilt place remains pending.

## Visual layout review

Desktop, portrait-phone, and landscape-phone previews were generated from the actual UI modules using the test doubles and tools/preview_ui.py, then visually inspected. These checks led to improved compact spacing and shortcut contrast. The PNGs are under artifacts/ui-preview/.

These previews use approximate fonts and a neutral background. They are not Roblox screenshots and do not validate real engine layering, world appearance, Roblox mobile controls, or interaction.

The subsequent world art pass replaces textured materials with SmoothPlastic, refreshes the colors, rounds plaza bushes, and applies Soft lighting with brighter ambient light and reduced reflections. It does not change the HUD, so the HUD previews were not regenerated for this pass. Compilation and mocked world construction are checked automatically; real lighting, surface appearance, and graphics-quality differences still need the Studio checks. No real-engine visual result is claimed.

## Remaining Studio checks

The restaurant-marker pass adds local availability guides from above the player's head to free entrances, plus public owner cards using replicated session ownership. Guides use pairs of short beams to form separated open chevrons (> > >), with no connecting shaft. They follow the character and face the camera each render frame. Each route reuses at most 24 chevrons. The chevrons advance toward the restaurant using render-frame elapsed time, fading and shrinking at the endpoints to loop without extending outside the route. Animation direction, equal elapsed time at 30/60 FPS, and loop closure are checked automatically; actual motion still needs Studio review. Saved profiles are unchanged. Thumbnail calls and attachments are mocked in automated tests; real Roblox avatar loading, beam appearance, billboard placement/overlap, late joins, and respawn rendering require Studio review.

The latest pass raises restaurant walls from 12 to 18 studs, moves ceilings/roof caps/awnings/signs up with them, and adds four broad warm-white SurfaceLights per restaurant. The fixtures do not collide or cast additional local shadows. Automated geometry checks cover headroom and conservative lighting range/cones, but actual interior brightness, graphics-quality differences, camera behavior, and rendering performance still require Studio playtesting. The brown paths and perimeter remain in place.

The project owner confirmed the preceding core version works. This new claiming/layout/HUD iteration has not been playtested by the agent in Roblox Studio. No real DataStore calls were made. Run docs/STUDIO_TESTS.md before accepting this iteration, especially simultaneous claims, mobile prompts, camera/walkability, and multiplayer ownership.

## API references checked

- Native keyboard/touch claiming prompts: https://create.roblox.com/docs/ui/proximity-prompts
- Prompt properties/events: https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt
- Wall-bound text: https://create.roblox.com/docs/reference/engine/classes/SurfaceGui
- Surface materials: https://create.roblox.com/docs/parts/materials
- Soft lighting and environment settings: https://create.roblox.com/docs/reference/engine/classes/Lighting
- Editor-only LightingStyle setting: https://create.roblox.com/docs/effects/light-sources
- World-space restaurant markers: https://create.roblox.com/docs/reference/engine/classes/BillboardGui
- Avatar headshots: https://create.roblox.com/docs/reference/engine/classes/Players#GetUserThumbnailAsync
- Player-to-entrance guides: https://create.roblox.com/docs/reference/engine/classes/Beam
