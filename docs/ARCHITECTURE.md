# Core-loop architecture

## Dependency direction

Client UI -> action request -> server ActionService -> domain rules -> in-memory profile.

Server SnapshotService -> private core-state snapshot -> permanent HUD.

DataService -> ProfileStore -> Roblox DataStore.

Server composition -> StationService -> procedural world builders.

The shared domain layer depends only on configuration, utilities, and other domain rules. Roblox services enter through server/client adapters.

## Responsibilities

| Module | Responsibility |
| --- | --- |
| shared/config/Economy | Capacity, base click, fryer rate, money per fry, and currency bound |
| shared/config/Runtime | Server, replication, and persistence settings |
| shared/config/Actions | Closed core action vocabulary |
| shared/domain/Profile | Core defaults and validation; v1 save compatibility |
| shared/domain/Pricing | Fixed base values and bounded currency credits |
| shared/domain/Packing | Fill a bag and execute a sale |
| shared/util/Copy | Deep-copy saved tables |
| shared/util/RateLimiter | Bound per-player request frequency |
| server/Main.server | Compose services and manage player/server lifecycle |
| server/Network | Remotes and notifications |
| server/services/ActionService | Validate and dispatch core requests |
| server/services/SnapshotService | Send private core state without inactive legacy fields |
| server/services/DataService | Own loaded profiles and serialize saves |
| server/services/StationService | Validate proximity claims, release ownership, and locate/display stations |
| server/storage/ProfileStore | Atomic, session-locked storage transactions |
| server/world/Primitives | World parts and labels |
| server/world/StationBuilder | Individual restaurant plot, entrance prompt, wall plaque, and basic workstation |
| server/world/WorldBuilder | Six restaurants facing a shared central plaza and a physical title mural |
| client/Main.client | UI/input composition and state subscriptions |
| client/controllers/InputController | Keyboard, mouse, and touch input |
| client/ui/AppView | Cash card, claiming guidance, errors, teleport, and responsive HUD placement |
| client/ui/HudView | Click, Sell, bag progress, and feedback |
| client/ui/Theme and Elements | Shared UI styling and widgets |

## Remote contract

Clients send Action:FireServer(actionName). No action accepts an argument.

| Action | Server rule |
| --- | --- |
| Pack | Alive and at own station; rate-limited; add the base click amount |
| Sell | Alive and at own station with a full bag; credit once and clear the bag |
| Return | Teleport to the player's assigned station |
| Sync | Send the player's private snapshot |

Claiming uses the server-side ProximityPrompt.Triggered connection, not an extra action remote. Main checks loaded data, applies a rate limit, and calls StationService:claim. The service rechecks character health, entrance distance, plot availability, and existing ownership. The availability check and assignment do not yield. Prompt visibility is not trusted as authorization.

Players reserve one of six admission slots before data loading, but receive no restaurant until claiming. Admission slots are released on failure or departure. Production waits for a claim; respawning retains the session claim.

Retired feature requests and unknown names are rejected before dispatch. Clients cannot supply prices, quantities, Cash deltas, equipment, or other player IDs. General rate limits apply before dispatch; packing has a separate four-per-second limit.

## Transactions and persistence

Filling and selling do not yield. A sale reads a full bag, credits Cash and lifetime counters, and replaces it with an empty bag before another request runs.

DataStore writes remain serialized per profile with ownership tokens and bounded retries. Repeating a request after a lost response recognizes an already-committed write. Autosaves renew the lease. If safe ownership cannot be maintained, the session is disconnected. Load failures do not create writable default progress.

Version 1 core fields are version, cash, sales, lifetimeCash, and bag.fries. Existing profiles may also contain inactive fields from the earlier prototype; storage preserves them, but runtime rules and snapshots ignore them. No equipment selection or bonus state is created for new players. New fields or incompatible formats in future iterations require an explicit compatibility decision.

## Iteration boundary

Follow the AGILE workflow in README.md. Current work is the owner-approved UI/UX pass on the working fill-and-sell loop. Preserve base rates and prices. Keep fryer name tags absent in future changes too. Do not add placeholder feature modules, shops, reward systems, or speculative frameworks ahead of an agreed increment.
