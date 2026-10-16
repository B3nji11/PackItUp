# Architecture

## Dependency direction

Client UI -> action request -> server ActionService -> domain rules -> in-memory profile.

Server SnapshotService -> private core-state snapshot -> permanent HUD.

DataService -> ProfileStore -> Roblox DataStore.

Server composition -> StationService -> procedural world builders.

The shared domain layer depends only on configuration, utilities, and other domain rules. Roblox services enter through server/client adapters.

## Responsibilities

| Module | Responsibility |
| --- | --- |
| shared/config/Economy | Base capacity, base click, fryer rate, base money per fry, and currency bound |
| shared/config/Upgrades | Upgrade tracks in shop order: names, gem cost curves, and per-level steps |
| shared/config/Rebirth | Rebirth threshold curve and gem rewards |
| shared/config/Pets | Pet types, rarities, bonuses, inventory size, and equip slots |
| shared/config/Machines | Gacha machines as data: price, odds, pet pool, and pity |
| shared/config/Settings | Setting names, hints, and defaults |
| shared/config/Runtime | Server, replication, and persistence settings |
| shared/config/Actions | Closed action vocabulary and each action's allowed argument |
| shared/domain/Profile | Core defaults and validation, including upgradeLevels, gems, and rebirths; one-time migration of pre-gem saves; v1 save compatibility |
| shared/domain/Pricing | Effective stats from base values, upgrade levels, and equipped pet bonuses; sale value; bounded currency credits |
| shared/domain/Upgrades | Gem upgrade costs, purchases, and server-computed shop rows |
| shared/domain/Rebirth | Threshold, reward, and the rebirth reset |
| shared/domain/Gacha | Odds with pity, rolls from an injected random source, and spins |
| shared/domain/Pets | Owned pets, unique IDs, equipping, deleting, Golden merges, bulk delete, auto-delete, and equipped bonuses |
| shared/domain/Settings | Saved settings with defaults |
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
| client/ui/AppView | Cash and Gems card, claiming guidance, errors, teleport, and responsive placement of the HUD and panel buttons |
| client/ui/HudView | Click, Sell, bag progress, and feedback |
| client/ui/ShopView | UPGRADES button and shop panel; displays server rows and requests purchases |
| client/ui/RebirthView | REBIRTH button and confirmation panel; displays server values and requests a rebirth |
| client/ui/GachaView | SPIN button and machine panel; displays odds, pity, and results, and requests spins |
| client/ui/PetsView | PETS button and inventory panel; requests equip, unequip, and delete |
| client/ui/PetText | Shared pet bonus text and rarity colors |
| client/ui/SettingsView | Gear button and settings panel; requests setting toggles |
| client/ui/PetModels | Code-built cartoon pet models |
| client/ui/PetFollower | Draws every player's equipped pets locally from the FollowPets attribute and moves them each frame |
| client/ui/Theme and Elements | Shared UI styling and widgets |

## Remote contract

Clients send Action:FireServer(actionName), or one validated argument for Upgrade (a track name), Spin (a machine name), Equip, Unequip, and DeletePet (a pet ID such as "P12"), MergePets (a pet type), DeleteRarity and ToggleAutoDelete (Common, Uncommon, or Rare), and ToggleSetting (a setting name). Every other action rejects any argument.

| Action | Server rule |
| --- | --- |
| Pack | Alive and at own station; rate-limited; add the player's fries per click |
| Sell | Alive and at own station with a full bag; credit once and clear the bag |
| Upgrade | Claimed restaurant and a known track name; short cooldown; deduct the gem cost and raise one level only if gems are sufficient |
| Rebirth | Claimed restaurant and Cash >= threshold; two-second cooldown; reset Cash and the bag, add gems, and count the rebirth together |
| Spin | Claimed restaurant, a known machine, enough Cash, and inventory space; short cooldown; deduct, roll on the server, add the pet, and update pity together. The spin's snapshot carries the result |
| Equip / Unequip / DeletePet | Claimed restaurant and an owned pet; at most 3 equipped; only unequipped pets can be deleted; trims an over-full bag |
| MergePets | Claimed restaurant and a pet type with 5 unequipped non-golden copies; replaces them with one Golden pet |
| DeleteRarity | Claimed restaurant and Common, Uncommon, or Rare; deletes all unequipped non-golden pets of it |
| ToggleAutoDelete | Claimed restaurant and Common, Uncommon, or Rare |
| ToggleSetting | A known setting name; allowed before claiming |
| Return | Teleport to the player's assigned station |
| Sync | Send the player's private snapshot |

Claiming uses the server-side ProximityPrompt.Triggered connection, not an extra action remote. Main checks loaded data, applies a rate limit, and calls StationService:claim. The service rechecks character health, entrance distance, plot availability, and existing ownership. The availability check and assignment do not yield. Prompt visibility is not trusted as authorization.

Players reserve one of six admission slots before data loading, but receive no restaurant until claiming. Admission slots are released on failure or departure. Production waits for a claim; respawning retains the session claim.

Retired feature requests and unknown names are rejected before dispatch. Clients cannot supply prices, levels, quantities, Cash deltas, equipment, or other player IDs. General rate limits apply before dispatch; packing has a separate four-per-second limit.

## Following pets

SnapshotService sets a public `FollowPets` attribute on each Player whenever it sends a snapshot: the equipped pet types in slot order, comma-separated, with `*` after Golden pets (for example `FryKing*,MayoJar`), or empty when Pets follow me is off. Each client's PetFollower reads the attribute for every player, builds code-made models once per change, and positions them each render frame behind the character. Nothing is sent per frame, the models are local, non-colliding, and non-queryable, and Show other players' pets only filters what that client draws.

## Transactions and persistence

Filling, selling, upgrade purchases, rebirth, spins, and pet changes do not yield. A sale reads a full bag, credits Cash and lifetime counters, and replaces it with an empty bag before another request runs.

DataStore writes remain serialized per profile with ownership tokens and bounded retries. Repeating a request after a lost response recognizes an already-committed write. Autosaves renew the lease. If safe ownership cannot be maintained, the session is disconnected. Load failures do not create writable default progress.

Version 1 core fields are version, cash, sales, lifetimeCash, and bag.fries, plus optional upgradeLevels (track name -> whole level), gems, rebirths, pets (list of {id, type, machine}), equippedPets (list of owned IDs), nextPetId, pity (machine -> count), settings (name -> boolean), and autoDelete (rarity -> true); a pet may carry golden = true. Missing means none or defaults. The pet fields use new names because the old prototype already stored an `equipped` equipment table. Unknown pet types or machines, duplicate or malformed IDs, more than 50 pets, more than 3 or unowned equipped pets, and out-of-range pity make a profile invalid. Bag size is only sanity-checked; Profile.normalize trims it to the current capacity on load so balance changes cannot make saves unloadable. Unknown track names or invalid levels make a profile invalid, so it is not loaded or saved. Keeping version 1 was agreed because there are no live players yet. DataService runs Profile.migrate once after each load: a save without `gems` predates gems, so its Cash-bought upgrade levels reset to 0 (owner decision, 16 October 2026) and its bag is trimmed to base capacity. Existing profiles may also contain inactive fields from the earlier prototype; storage preserves them, but runtime rules and snapshots ignore them. No equipment selection or bonus state is created for new players. New fields or incompatible formats in future iterations require an explicit compatibility decision.

## Iteration boundary

Follow the AGILE workflow in README.md. Stages 4 (following pets) and 5 (inventory management) are built and awaiting review; the visual overhaul comes next. Preserve base rates and prices; the fryer rate stays fixed. Keep fryer name tags absent in future changes too. Do not add more machines, rebirth unlocks, Robux purchases, placeholder feature modules, or speculative frameworks ahead of their agreed increment.
