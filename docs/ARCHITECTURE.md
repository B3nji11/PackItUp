# Architecture and responsibilities

## Dependency direction

Client UI -> action request -> server ActionService -> domain rules -> in-memory profile.

Server SnapshotService -> private state snapshot -> client views.

DataService -> ProfileStore -> Roblox DataStore.

Server composition -> StationService -> world builders and equipment cosmetics.

The shared domain layer depends only on configuration, utilities, and other domain rules. Its unchanged source can execute in the standalone Luau VM. Roblox services enter through server/client adapters.

## Module ownership

| File | Single responsibility |
| --- | --- |
| shared/config/Economy | Currency, packing, upgrade and fold balance |
| shared/config/Equipment | Equipment catalogue and gacha pools |
| shared/config/Variants | Fry variation distribution |
| shared/config/Rush | Event timing and rewards |
| shared/config/Runtime | Server, persistence and replication settings |
| shared/config/Actions | Allowed remote action vocabulary |
| shared/util/Copy | Deep-copy serializable tables |
| shared/util/Weighted | Select an entry from positive weights |
| shared/util/RateLimiter | Limit request frequency per player |
| shared/domain/Profile | Profile schema, defaults and validation |
| shared/domain/Pricing | Derived stats, prices and bounded currency credit |
| shared/domain/Packing | Fill a bag, lock its value, and execute a sale |
| shared/domain/Folding | One timing attempt per full bag |
| shared/domain/Discovery | Record variants and grant index completion once |
| shared/domain/Orders | Award sold-fries milestones and tutorial reward |
| shared/domain/Upgrades | Purchase training and select owned equipment |
| shared/domain/Gacha | Execute a roll with refund and guarantee state |
| shared/domain/LunchRush | Event roster, target, contribution and resolution |
| server/Main.server | Compose services and run player/server lifecycle |
| server/Network | Create remotes and deliver notifications |
| server/services/ActionService | Validate and dispatch player requests |
| server/services/SnapshotService | Send each player's private UI state |
| server/services/DataService | Own loaded profiles and serialize their saves |
| server/services/StationService | Assign, free, locate and update owned stations |
| server/storage/ProfileStore | Atomic, session-locked storage transactions |
| server/world/Primitives | Reusable world parts and labels |
| server/world/StationBuilder | Build a station and its customer |
| server/world/WorldBuilder | Build the shared restaurant layout |
| server/world/EquipmentVisuals | Change gear-specific cosmetic geometry |
| client/Main.client | Compose UI/input and subscribe to server state |
| client/controllers/InputController | Translate keyboard/touch/mouse input into requests |
| client/ui/Theme | UI colours |
| client/ui/Elements | Reusable widgets |
| client/ui/AppView | Panel layout, navigation and notifications |
| client/ui/HudView | Packing, serving, folding and rush display |
| client/ui/UpgradeView | Training shop display |
| client/ui/DeliveryView | Gacha shop, odds and guarantees display |
| client/ui/InventoryView | Owned and equipped gear display |
| client/ui/IndexView | Discovery collection display |

## Remote contract

Clients send Action:FireServer(actionName, optionalStringArgument).

| Action | Argument | Server rule |
| --- | --- | --- |
| Pack | None | Alive, at own station, rate-limited; adds server-calculated fries |
| Sell | None | Alive, at own station, full bag; awards one sale and clears bag |
| StartFold | None | Alive, at own station, full bag, not attempted |
| FinishFold | None | Alive, at own station, active fold; uses server receipt time |
| Upgrade | Click or Sales | Recognized track, level below cap, sufficient Cash |
| Roll | Machine or Bag | Recognized pool, sufficient Tickets; server RNG |
| Equip | Catalogue item ID | Item exists and is owned |
| Return | None | Teleport only to the player's assigned station |
| Sync | None | Send the player's current private snapshot |

Only finite, bounded server-owned numbers are saved. Clients never submit prices, quantities, timestamps, cash deltas, random samples, or another player's ID. Unknown actions, oversized strings, and tables are rejected. General request limits run before dispatch; packing has an additional four-per-second limiter.

Work actions require proximity. Shops and inventory can be used anywhere. These checks prevent forged rewards; they are not a claim to eliminate bots, automated timing, or Roblox character-physics exploits.

## Transactions and concurrency

Packing, selling, purchases, rolls and rewards do not yield. A sale reads the existing full bag once, credits it, and replaces it with an empty bag before another action runs.

DataStore writes are serialized per profile. Each operation snapshots the profile, uses an ownership token, and retries the same write ID. A retry after a lost response recognizes an already-committed write, including a final save that released its lock. Different servers cannot write over a newer session's lock.

Saving retries are bounded. Autosaves renew the lease. If renewal cannot be confirmed before the safety margin, gameplay access is withdrawn and the player is disconnected. A load failure never starts a writable default profile.

All fields participating in a transaction are saved together: currencies, ownership, equipped gear, guarantee counters, order progress, discoveries and the current bag.

## Extending the project

- Change balance in config files; rerun tests after changing caps, probabilities or milestones.
- Add catalogue rewards by extending both Items and the appropriate pool. The current pool has exactly one item per rarity; multiple items per rarity require another weighted selection and updated odds display.
- Add profile fields with an explicit schema migration. The current validator rejects versions other than 1.
- Add promotions in a new domain module; do not hide promotion rules in UI code.
- Add world art by replacing world builders while retaining StationService's returned station fields.
- Keep client visuals derived from snapshots; never move economy decisions into the UI.
