# Validation record

Validation date: 7 October 2026.

Tools: official Luau release 0.741 (luau and luau-compile), bundled Python standard library.

## Automated checks

Final result: **46 tests passed, 0 failed**. All **42 Luau source/test files** compiled. The place contains **39 game source files**.

The final test output is in TEST_RESULTS.txt. The test runner:

1. Compiles every source and test file using luau-compile.
2. Executes unchanged source module bodies in the Luau VM with a ModuleScript resolver.
3. Runs domain tests for economic invariants and exact gacha boundaries.
4. Runs a deterministic 10,000-action mixed progression simulation.
5. Runs storage tests with transient errors, exhausted retries, conflicting sessions, expired locks, invalid profiles and a lost response after a committed final save.
6. Runs server/client composition and action-routing smoke tests using lightweight engine doubles.
7. Checks calculated UI bounds at 390x844, 844x390 and 1280x720.

The place builder separately verifies XML parsing, embedded source equality, and the presence of exactly one server entry script and one client entry script.

## Limits of these results

No Roblox Studio session was available for execution or visual inspection. No actual Roblox DataStore calls were made. Engine doubles are not the Roblox engine. The tests do not establish real rendering quality, physics correctness, production network behaviour, device usability, absence of exploits, or durability during every possible outage.

The Luau compiler check is a syntax/bytecode compilation check, not a complete Roblox-aware static type analysis.

Complete docs/STUDIO_TESTS.md before treating this as a release candidate.

## Implementation references

- Roblox client/server validation: https://create.roblox.com/docs/scripting/security/client-server-boundary
- Roblox player-data and session-locking guidance: https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing
- Roblox DataStores: https://create.roblox.com/docs/cloud-services/data-stores
- Official Luau CLI releases: https://github.com/luau-lang/luau/releases

The implementation is project-specific; it does not vendor Roblox's reference persistence code.
