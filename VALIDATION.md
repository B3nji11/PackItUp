# Validation record

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
