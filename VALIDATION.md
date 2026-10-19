# Validation record

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
