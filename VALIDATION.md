# Validation record

## Visual milestone 5: brighter rooms and oversized lettering

Validation date: 20 October 2026. Continues M4 `0de5b3b` on `visual/restaurant-one-simulator`. Main remains at `45526d3`.

**66 tests passed, 0 failed; all 37 Luau source/test files compiled** with official Luau 0.743. The rebuilt place verifies XML, all **33 embedded game modules**, entry-point counts, and saved Soft LightingStyle.

Owner feedback established that M4 was still too dim and its lettering too small. Its proposed font-limit change did not establish native readability. M5 replaces that approach with fixed-canvas world text and physically larger sign layouts. The [official SurfaceGui documentation](https://create.roblox.com/docs/reference/engine/classes/SurfaceGui) describes FixedSize/CanvasSize independently of world dimensions. Each label now uses a **96-pixel-high canvas with the face's physical aspect ratio**, full-face TextScaled, and a font constraint of 1-96. No font above 100 pixels is requested. Left/right/top faces are mapped correctly, and resizing the live ownership plaque refreshes its canvas. LightInfluence 0 and AlwaysOnTop false retain printed-text contrast with normal world occlusion. The small logical minimum is used with a normalized canvas; it is not a target screen-pixel font size.

The main menu title/subtitle/steps and side-menu caption regions are **three times their M4 height**. Action captions are also three times as wide. The main board grows to 35.8 x 10.8 studs; side menus move onto 18-stud-wide wall panels. Prior small side posters are replaced by these larger framed menu panels. Plot-number discs grow from 3.2 to 9.6 studs. Facade lettering, ownership plaques, mats, bag/apron badges and the central medallion expand within available space; bag/apron copy is shortened to FRY. Not every physical item can grow three times without covering working objects, so these remain bounded to their original item/shell while the full-face canvas avoids undersized text.

Ambient rises from M4 RGB **104/96/88** to **150/148/140**. Each broad ceiling SurfaceLight rises from **0.46 to 1.2** (2.61x); pendants rise from **0.16 to 0.45** (2.81x). The pale cream ceiling, plaster, stone, sage and coral finishes are significantly lighter; light colors are closer to neutral warm white. Fixture positions, ranges, cones and downward faces remain unchanged. Outdoor fill, sun brightness, exposure and time of day are unchanged.

Regression tests now verify all world-text canvas aspect ratios, including rotated side/top faces and resized ownership plaques. A new test checks 3x caption geometry, separate menu rows, clearance above prep jars, plaque headroom below the canopy, unobstructed live fry tips, and pale ceiling finishes. Existing geometry bounds, budgets, light coverage, ownership, production, sales, upgrades, saves and HUD input tests pass. Gameplay, client, config, persistence and remote modules remain unchanged.

The executed-source export contains **3,224 visible district parts** (M4: 3,248). Updated previews use the exported canvas height and light parameters. Interior, booth, kitchen, exterior, district, promenade and south-row views were reviewed with a separate renderer. Fonts and illumination remain approximate; these are not Studio screenshots or an engine performance result.

**Pending:** actual Studio brightness and normal-distance text comparison with M4, short/long ownership names, desktop/mobile, low/high graphics and two-player checks. Use the M5 checklist in docs/STUDIO_TESTS.md. No live DataStore calls, main-branch writes, merges, or game publication occurred.

## Visual milestone 4: balanced light and readable lettering

Validation date: 20 October 2026. Continues M3 `124cb92` on `visual/restaurant-one-simulator`. Main remains at `45526d3`.

**65 tests passed, 0 failed; all 37 Luau source/test files compiled** with official Luau 0.743. The rebuilt place verifies XML, all **33 embedded game modules**, entry-point counts, and the saved Soft LightingStyle.

Indoor Ambient rises from M3 RGB **83/75/69** to **104/96/88**, below the original **136/146/162**. The four broad ceiling SurfaceLights rise from **0.32 to 0.46** each (original: 0.8); both pendant lights rise from **0.12 to 0.16**. Their warm colors, coverage, direction, and the room's detailed geometry remain in place. Outdoor fill, sun, exposure, and time of day retain their earlier values.

The shared world-label helper now adds a UITextSizeConstraint with **MinTextSize 9 / MaxTextSize 1000** to each full-face TextScaled label, retaining 40 pixels per stud. Roblox documents a default 100-pixel maximum for TextScaled without a size constraint; large physical signs could therefore display undersized lettering. See the official [TextLabel reference](https://create.roblox.com/docs/reference/engine/classes/TextLabel) and [UITextSizeConstraint reference](https://create.roblox.com/docs/reference/engine/classes/UITextSizeConstraint). SurfaceGui LightInfluence is now 0 for printed-text contrast; AlwaysOnTop remains false so walls still occlude it.

Smaller items also receive more physical lettering space: larger ownership plaques, bag badges, welcome mats, plot-number discs, and the central medallion text face. Menu captions grow, HOT & CRISPY is shortened, and GOLDEN BITES / HELLO, FRY FRIEND use two lines. All six restaurants use the same changes, including the rotated southern row. No gameplay, client, config, persistence, or remote module changes.

The new regression check traverses all world SurfaceGuis, verifies explicit font bounds, full-face scaling, text contrast/occlusion settings, and caption room on all six plots. Existing tests cover the intermediate light levels, safe decoration bounds, original functional references/collision, claims, production, packing/selling, upgrades, saves, and HUD input.

Interior, kitchen, exterior, and promenade geometry previews were reviewed. The separate preview renderer now reads actual source font constraints as well as light parameters. Earlier previews did not reproduce the default 100-pixel font limit and overstated some lettering. Current previews remain approximate: Arial substitutes for Gotham and the renderer cannot establish native Roblox text layout, illumination, performance, or device readability. The full district still exports **3,248 visible parts**.

**Pending:** Studio Play comparison with M2/M3; normal viewing-distance checks of every sign/item; short/long owner names; low/high graphics, desktop/mobile and two-player review. Use the M4 checklist in docs/STUDIO_TESTS.md. No live DataStore calls, merges, main-branch writes, or game publication occurred.

## Visual milestone 3: warm diner interiors

Validation date: 20 October 2026. Continues `5a31322` on `visual/restaurant-one-simulator`. Main remains at `45526d3`.

**64 tests passed, 0 failed; all 37 Luau source/test files compiled** with official Luau 0.743. The place builder verifies XML and all **33 embedded game modules**, entry-point counts, and the saved Soft LightingStyle.

InteriorStyle applies the same warm finish to all six original stations: matte stone floor tiles, an entry runner, teal wainscoting and trim, upholstered booth backs and buttons, ceiling coffers, pendant shades, layered framed wall graphics, fryer vents/dial marks, and a prep line with cabinetry, handles, backsplash, cold cabinet, shelf jars, cutting board, and napkins. Existing restaurant surfaces are recolored; obsolete interior confetti and the previous poster are hidden, including disabling its SurfaceGui. The exterior shell and district geometry are retained. Added art remains anchored, non-colliding, touch/query-disabled, non-shadow-casting, and made from SmoothPlastic.

Actual runtime light changes: indoor Ambient is RGB **83/75/69** instead of **136/146/162**. Each of the four existing broad ceiling SurfaceLights has brightness **0.32 instead of 0.8** (60% lower) and a warmer color, with its original position/range/cone coverage retained. Two unshadowed downward pendant SurfaceLights add brightness **0.12** each. OutdoorAmbient, sun brightness, ClockTime, exposure, and reflection settings retain their earlier values. No editor-only lighting property is written at runtime.

The new regression check covers all six interiors, bounded room geometry and headroom, a clear entrance/counter route, a 260-part per-room interior-art budget, two correctly downward-facing pendant lights, reduced broad-light intensity, disabled old poster GUI, and preserved original station collision/fill indicators. Existing coverage passes for claiming, production, packing/selling, upgrades, saves, player isolation, owner cards, and HUD input. No game config, domain, services, storage, remotes, or client modules changed.

Interior, booth, kitchen, exterior, and district previews were reviewed from the executed source geometry. The preview renderer also reads the actual light parameters but approximates their appearance; it cannot establish Roblox illumination, exposure, shadows, or graphics quality. This review refined the initial brown-heavy palette into warm stone, muted coral, and teal, and replaced large uniform wall text with smaller framed graphics. The exported district contains **3,248 visible parts**, not a measured engine frame-time result.

**Pending:** Studio Play comparison with M2, actual indoor brightness on low/high graphics settings, camera clearance around booth backs, mobile controls, two-player rendering, and owner review. No live DataStore calls, merges, main-branch writes, or game publication occurred. Use the M3 checklist in docs/STUDIO_TESTS.md.

## Visual milestone 2: all restaurants and the district

Validation date: 19 October 2026. Continues the approved visual direction from `ea8adbf` on `visual/restaurant-one-simulator`. Main remains at the original `45526d3` baseline.

**63 tests passed, 0 failed; all 36 Luau source/test files compiled** with the official Luau 0.743 tools. The rebuilt place contains **32 game source files**. XML, exact embedded-source round-tripping, entry-point counts, and saved Soft LightingStyle pass the existing builder checks.

All six plots use the same restaurant skin. The southern row rotates its signs, facade, canopy slope, furniture, and equipment with the original station transform. ArtPrimitives centralizes the unchanged palette and rounded-part construction. The original counter character gains decorative face, cap, and apron details. PlazaStyle adds cream/gold path edges, brown pavers, flat plot-number badges and a welcome medallion, flowering planters, pastel rounded benches, puffy hedge caps, corner finials, and a title-wall frame. Added art is anchored, non-colliding, touch/query-disabled, and non-shadow-casting. Original invisible furniture retains its collision. No config, domain, service, persistence, remotes, client UI, or global lighting module changed.

The previous art checks now cover all six plots, both facade directions, downward canopy slopes, live plaque references, unchanged functional positions, full rotation-aware art bounds, and open entrance/counter routes. A district check covers spawn position, solid boundary collision, clear central and restaurant approach lanes, preserved plaza furniture collision, and a shared-art budget of 400 parts. Restaurant art remains below 260 added parts per plot. The complete initial world export has 2,072 visible parts; real-engine performance still needs checking.

Full-district, promenade, southern-row, and updated restaurant previews were inspected from the executed source modules. They use a separate renderer with approximate lighting and fonts, and show geometry rather than an engine playtest. Both rows' signs face inward and the central circulation space remains open. Existing regression tests continue to pass for claims, ownership/release/respawn, production, packing, selling, upgrades, player isolation, saving, and HUD input.

**Pending:** Studio desktop/mobile and two-player playtesting, real owner-card/guide rendering, camera clearance, low/high graphics performance, and review of this expanded result. No live DataStore calls, main-branch writes, merges, or game publication occurred. See docs/STUDIO_TESTS.md for the manual checks.

## Visual milestone 1: Restaurant 1

Validation date: 19 October 2026. Base: `45526d39aeea5e2d27de527c8ab30d473cde18c2`. Branch: `visual/restaurant-one-simulator`.

**62 tests passed, 0 failed; all 34 Luau source/test files compiled** using the official Luau 0.743 Windows tools. The baseline passed all 60 tests before editing. The rebuilt place contains **30 game source files**, with XML parsing, exact embedded-source round-tripping, one server entry point, one client entry point, and saved Soft LightingStyle verified by tools/build.py.

Implementation: RestaurantStyle is applied only to Restaurant 1 after its baseline station is built. The skin adds coral/gold exterior treatment, striped/scalloped canopy, oversized fries mascot, physical facade and wall signs, mint fryer details, rounded furniture, sauce bottles, topiary, and a welcome mat. Original objects are retained; hidden furniture/equipment preserve their previous physical collision envelopes. Added art cannot collide, touch, or intercept queries, and has no shadow-casting overhead. No shared config, domain rules, services, persistence, network, or client modules changed.

New regression checks cover the single-plot restriction, original gameplay positions/references, live ownership SurfaceGui, full rotation-aware decoration bounds, a clear central entrance/counter route, a bounded art budget (at most 400 added parts), non-colliding/query-disabled decoration, and the brand staying below the roof's owner-card anchor. The test CFrame double now handles all three rotation axes and synchronizes Position when CFrame is assigned. Existing tests still exercise claims/reclaims, owner markers, packing/selling, automatic production, upgrades, independent player state, saving, and input validation.

Geometry review: exterior, front, interior, and roof/side-wall cutaway previews were inspected from an export of the executed runtime modules. This caught covered legacy equipment surfaces and space needed for the owner card. Previews use Three.js with approximate light, fonts, and materials. They do not reproduce Roblox rendering. No runtime write to editor-only lighting properties was added; the existing owner-approved lighting remains unchanged.

**Pending:** actual Studio Play testing, desktop/mobile camera and touch checks, two-player rendering/ownership checks, performance at low graphics settings, and owner acceptance. Studio was installed, but this session had no supported native-app control surface for a verified engine playtest. No live DataStore calls or game publication occurred. Use docs/STUDIO_TESTS.md for the manual acceptance path.

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

Not yet done: Studio playtesting (docs/STUDIO_TESTS.md, Upgrade shop section), real DataStore persistence, and owner review. The dimmed lighting was approved by the owner.

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
