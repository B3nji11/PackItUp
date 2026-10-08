# Validation record

Validation date: 8 October 2026.

Scope: the owner-approved UI/UX iteration on the working core loop, including the smooth cartoon world pass. Base packing, fryer production after claiming, and $10 sales are unchanged.

## Automated results

**41 tests passed, 0 failed.** All **27 Luau source/test files** compiled. The rebuilt place contains **24 game source files**. Output is recorded in TEST_RESULTS.txt.

Coverage includes:

- Core filling, full-bag selling, repeated-sale rejection, exact Cash totals, and a deterministic 10,000-action simulation.
- Save/load compatibility, lease/session locking, retries, lost-response recovery, and invalid core data.
- No automatic plot assignment or production before claiming.
- Server-side claim distance and health checks, one plot per player, occupied-plot/race rejection, and six admission slots including unclaimed players.
- Session claims survive respawn and release on departure; a replacement player can claim the released plot.
- Separate private state, owner-only work/teleport, basic fixed rates, and rejection of retired actions.
- Six separated restaurant plots with inward-facing entrances, physical wall signage, and no fryer name labels.
- Ceiling coverage/headroom and wall joins across all six restaurants; solid perimeter alignment, corner overlap, and clearance outside every plot.
- Three permanent HUD actions, middle-left Cash placement/formatting, fries-per-click hover labels, embedded bag capacity, full-bag sell state, E reserved for claiming, and R for selling.
- Calculated HUD bounds for 320x568, 390x844, 568x320, 844x390, and 1280x720.

The builder verifies XML parsing, exact source round-tripping, and the saved Soft LightingStyle setting.

### Startup regression after the cartoon pass

The owner reported missing restaurant claiming and HUD elements. The cartoon pass wrote LightingStyle from WorldBuilder at runtime, before the server created remotes or connected claiming. Roblox documents this as an editor-only property. The prior engine double accepted arbitrary property writes and missed this failure.

The engine double now rejects runtime writes to editor-only lighting settings. Before the fix, the startup test failed at LightingStyle and FriesRemotes was absent, reproducing the broken startup path. After moving LightingStyle into the saved place builder and Rojo configuration, all 40 tests pass, including startup, claiming, client HUD creation, and fill/sell behavior. Studio verification of the rebuilt place remains pending.

## Visual layout review

Desktop, portrait-phone, and landscape-phone previews were generated from the actual UI modules using the test doubles and tools/preview_ui.py, then visually inspected. These checks led to improved compact spacing and shortcut contrast. The PNGs are under artifacts/ui-preview/.

These previews use approximate fonts and a neutral background. They are not Roblox screenshots and do not validate real engine layering, world appearance, Roblox mobile controls, or interaction.

The subsequent world art pass replaces textured materials with SmoothPlastic, refreshes the colors, rounds plaza bushes, and applies Soft lighting with brighter ambient light and reduced reflections. It does not change the HUD, so the HUD previews were not regenerated for this pass. Compilation and mocked world construction are checked automatically; real lighting, surface appearance, and graphics-quality differences still need the Studio checks. No real-engine visual result is claimed.

## Remaining Studio checks

The latest pass changes the plaza and walkways to brown, adds cream ceilings with colored roof caps, raises side walls to meet them, and encloses the map with solid hedge walls. Automated geometry checks cover containment and ceiling coverage, but ceiling camera behavior, interior brightness, and boundary collisions/jumping still require Studio playtesting.

The project owner confirmed the preceding core version works. This new claiming/layout/HUD iteration has not been playtested by the agent in Roblox Studio. No real DataStore calls were made. Run docs/STUDIO_TESTS.md before accepting this iteration, especially simultaneous claims, mobile prompts, camera/walkability, and multiplayer ownership.

## API references checked

- Native keyboard/touch claiming prompts: https://create.roblox.com/docs/ui/proximity-prompts
- Prompt properties/events: https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt
- Wall-bound text: https://create.roblox.com/docs/reference/engine/classes/SurfaceGui
- Surface materials: https://create.roblox.com/docs/parts/materials
- Soft lighting and environment settings: https://create.roblox.com/docs/reference/engine/classes/Lighting
- Editor-only LightingStyle setting: https://create.roblox.com/docs/effects/light-sources
