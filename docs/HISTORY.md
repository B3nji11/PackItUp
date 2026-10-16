# Project history and design notes

This file keeps the detailed record that used to live in README.md: each iteration's status as it was written at the time, the agreed progression design with its reasoning and numbers, and every increment's acceptance criteria. README.md now holds the current summary.

Entries are kept as written at the time; the README and docs/GAME_RULES.md describe the game as it is now.

## Iteration log (as of 16 October 2026, before Increments 4 and 5)

Increment 3 was accepted by the project owner later on 16 October 2026, before Increments 4 and 5 were built.

**Current iteration: Increment 3 — first Cash gacha machine.** Agreed with the project owner on 16 October 2026. Players spend Cash on spins for pets, keep them in an inventory, and equip up to 3 for stat bonuses. The acceptance criteria are in **Planned expansion > Increment 3 acceptance criteria** below.

**Completed iteration: Increment 2 — gems and rebirth.** Accepted by the project owner on 16 October 2026. Players rebirth at a rising Cash threshold for gems and spend gems on upgrades.

**Completed iteration: Increment 1 — upgrade shop.** Accepted 8 October 2026. Players spend Cash on fries per click, money per fry, and bag capacity; see **Planned expansion > Increment 1 acceptance criteria**.

**Completed iteration: UI/UX polish.** Accepted by the project owner on 8 October 2026, after the world lighting was dimmed.

**Baseline rules from the completed iterations (still in force):**

- Players enter the central plaza without an assigned restaurant, walk to an available entrance, and press E (or tap the proximity prompt) to claim it.
- Spaced gold chevrons (`> > >`) extend from above the local player's head toward each free restaurant entrance, with clear gaps, no connecting line, and an AVAILABLE label at the destination. The chevrons flow toward the restaurants, fade at the endpoints as they loop, follow the player while choosing, and disappear on claiming. Claimed restaurants show the owner's Roblox avatar headshot and @username above the roof for everyone; leaving removes the card and restores availability for unclaimed players. These are restaurant markers, not equipment labels.
- Claiming requires a loaded profile, a living nearby character, an unoccupied plot, and no existing claim. One player owns one restaurant per session; leaving frees it.
- Six spacious restaurant plots face a central promenade. Ownership is shown on the building; the title is wall art. Never add floating fryer/equipment name tags, now or in future iterations.
- The world uses smooth, untextured surfaces, bright cartoon colors, rounded plaza bushes, and soft lighting. Check the result in Studio before accepting this visual pass.
- Brown central paths connect to brown restaurant walkways. Every restaurant has 18-stud walls, a high cream ceiling with colored roof trim, and four warm-white ceiling lights covering the work and dining areas. A continuous solid hedge boundary encloses the playing area.
- Packing highlights fries per click (+1 fry/click before upgrades) and changes to Click on hover/focus, with the yield retained below. The internal click-rate limit is not shown to players. Selling shows bag capacity/progress until full, then Sell Bag and its Cash value.
- Cash has a visible card at the middle left, with a coin symbol and grouped amount. On short landscape screens it lifts enough to clear the action buttons. Successful sales update the card and reset the bag without a bottom message.
- Clicking, holding the button, or holding F adds fries at the player's counter.
- After claiming, the basic fryer retains its existing online rate of 0.5 fries per second.
- A bag stops filling at its capacity (20 fries before upgrades).
- An empty or partial bag cannot be sold, including through keyboard or direct remote requests.
- Selling a full bag awards bag capacity x money per fry, rounded down (20 x $0.50 = $10 before upgrades), exactly once and resets the bag for the next cycle.
- Players' Cash and bags remain independent; teleport returns each player to their own counter.
- Automated checks pass, Studio desktop/mobile and two-player checks pass, and the project owner reviews the result.

Automated checks alone do not finish an iteration. The gacha increment needs Studio playtesting and owner review. **Do not start Increment 4 until it has been accepted.**

Folding, Upgrades, Delivery, Index, and Inventory have been removed from the running game and source modules. Their connected bonus systems—Tickets, random fry variants, discovery rewards, order rewards, and Lunch Rush—are also outside this iteration. They are possible future backlog items, not a commitment to implement them. The exception is the upgrade, gacha, and inventory design agreed in **Planned expansion** below, which replaces the old Upgrades and Inventory and is planned for later increments. There are no placeholder menus or active background rewards for these systems.


## Progression design and increment criteria

First agreed with the project owner on 8 October 2026 and revised on 16 October 2026 to a **Cash, gems, and rebirth** loop. Build it in the small increments listed below. Numbers here are starting points for tuning, not commitments.

### The progression loop

1. Players earn **Cash** by packing and selling fries.
2. Cash is spent on **gacha spins** for pets, or saved to **rebirth**.
3. Rebirth converts Cash into **Gems**.
4. Gems buy **upgrades** (fries per click, money per fry, bag capacity).
5. Pets and upgrades both increase Cash income, so the next rebirth comes sooner.

### Agreed decisions

- **Two currencies: Cash and Gems.** Cash is the existing currency and keeps its name (the owner sometimes calls it coins). Gems replace the earlier "Fry Tokens" idea.
- **Gems come from rebirth only** and are spent on upgrades. The upgrade shop moves from Cash to gems.
- **Cash is the gacha currency.** Cash is easy to earn, so players can spin as often as they can afford.
- **Rebirth resets Cash and the current bag only.** Gems, upgrade levels, pets, and the rebirth count are kept.
- **Rebirth resets all Cash,** not just the threshold amount. Cash above the threshold are lost, so players are encouraged to spin before rebirthing.
- **The first rebirth threshold is $1,000** and rises with each rebirth. It can be retuned after playtesting.
- **Each gacha machine has a fixed Cash price per spin.** Better machines with better pets will come in future updates, later tied to worlds as in Pet Simulator.
- **Money per fry, not money per bag.** A bag sells for *bag capacity x money per fry* ($0.50 x 20 = $10 before upgrades). Already live.
- **The gacha gives pets**, which need an inventory system.
- **Free to play first.** Robux purchases come in a later, separately agreed increment.
- **The basic fryer's automatic rate stays fixed** at 0.5 fries per second.

### The three progression stats

| Stat | Current base | What it gives the player |
| --- | --- | --- |
| Fries per click | 1 | Faster active play. This is the main way active play scales, because the click rate is capped. |
| Money per fry | $0.50 | More income from everything: clicking, holding, and the fryer. |
| Bag capacity | 20 | Fewer trips to sell, and the fryer keeps filling longer while the player is away (a full bag stops production). |

Effective value = (base + upgrade levels) x (1 + total equipped pet bonus for that stat). Pet bonuses for the same stat add together; upgrades and pets multiply. Sale values are rounded down to whole Cash; money per fry is stored in cents to keep sums exact.

### Rebirth (gems)

- A **REBIRTH** button shows the current threshold and the gems it will give. It is enabled only when Cash >= threshold.
- Threshold = 1,000 x 1.6^(rebirths so far): $1,000, $1,600, $2,560, ...
- Gems per rebirth = 10 + 5 x (rebirths so far): 10, 15, 20, ...
- Rebirth sets Cash to 0 and empties the bag. Lifetime Cash and sales counters are kept.

### Upgrade system (gems)

The same three tracks as Increment 1, now bought with gems. Upgrades are permanent and survive rebirth.

| Upgrade | Per level | Gem cost |
| --- | --- | --- |
| Fries per click | +1 fry per click | 3 x 1.25^level |
| Money per fry | +$0.05 per fry | 4 x 1.25^level |
| Bag capacity | +5 fries | 5 x 1.25^level |

**Balance check (16 October 2026).** A simulation of an active player (4 clicks per second, about 1 second per sale, spending gems on the best-value upgrade, no pets) gave:
- about 9 minutes to the first rebirth;
- 7-11 minutes for each of rebirths 2-5;
- cycles of 15-25 minutes by rebirths 6-8.

Real players click more slowly, so real times will be longer. Pets will shorten the later cycles. Retune after playtesting.

### Gacha system (pets)

- **Currency: Cash.** Each machine has a fixed Cash price per spin. The first machine's price is to be agreed in its increment.
- **Reward: Fry Buddies (working name).** Collectible companions that follow the player around the plaza. Each one gives one percentage bonus to one stat (fries per click, money per fry, or bag capacity).
- **Machines are data.** Each machine is a config entry (price, pet pool, odds), and each pet records which machine it came from. New machines in future updates are added as data, not new systems.
- **Rarity table (starting point):**

| Rarity | Chance | Example bonus |
| --- | --- | --- |
| Common | 60% | +5% |
| Uncommon | 25% | +10% |
| Rare | 10% | +20% |
| Epic | 4% | +40% |
| Legendary | 1% | +75%, or two stats |

- **Pity:** a guaranteed Epic or better within 50 spins. The pity counter is saved per player.
- **Odds are shown in game** from the start. Roblox requires this once spins can be bought with Robux, and it builds trust before then.
- All rolls are resolved on the server. Clients send a spin request only; they never choose or report results.
- Cheap, frequent spins fill inventories fast and hand out the best pets quickly. Inventory limits, bulk delete, auto-delete by rarity, and merging duplicates (for example 5 of the same pet into a Golden version) give extra pets a use and players a long-term goal.

### Inventory system (pets)

- Each owned pet is saved with a unique ID, pet type, rarity, and source machine (and later a Golden flag).
- Players equip a limited number of pets (start with 3 slots). Only equipped pets give bonuses and follow the player.
- Inventory has a capacity limit (for example 50 pets), with ways to delete unwanted pets.
- An inventory screen shows owned pets, their bonuses, and which are equipped.

### Delivery increments

Each increment follows the AGILE workflow above: agreed acceptance criteria, tests, a Studio playtest, and owner review before the next one.

1. **Upgrade shop.** Done: accepted 8 October 2026, using Cash.
2. **Gems and rebirth.** Gem balance, the rebirth button and threshold, and the upgrade shop switched to gems.
3. **First Cash gacha machine.** 10 pets, server-side rolls with pity, odds display, an inventory list, basic equipping with bonuses, and single delete.
4. **Pets following the player.** Visible pets for equipped slots.
5. **Inventory management.** Merging duplicates to Golden, bulk delete, and auto-delete by rarity.
6. **More machines** with better pets, in future updates, later tied to worlds.
7. **Robux** (later, separately agreed). Odds disclosed. Selling gems would sell upgrades directly, so decide what is sold with care.

### Increment 1 acceptance criteria: upgrade shop (agreed and accepted 8 October 2026)

These criteria were met with Cash as the upgrade currency. Increment 2 changes the currency and costs to gems; the tracks and effects stay the same.

- An **UPGRADES** button on the HUD opens a shop panel on desktop and mobile. Each of the three tracks shows its level, current value -> next value, and cost.
  - Fries per click = 1 + level. Money per fry = $0.50 + $0.05 per level. Bag capacity = 20 + 5 per level.
  - Costs are whole Cash, rounded: 25 x 1.18^level, 40 x 1.20^level, 50 x 1.25^level. No level caps in this increment.
- A full bag sells for capacity x money per fry, rounded down. The packing and sell buttons show the upgraded values. The basic fryer stays at 0.5 fries per second.
- Unaffordable upgrades are greyed out. A purchase updates the Cash card and the shop immediately.
- The client sends only the upgrade name. The server checks the claim, the upgrade name, and the Cash, then deducts the cost and raises the level exactly once. Purchases are rate-limited.
- Buying capacity with a full bag makes it partial again; no fries are lost and filling resumes.
- Upgrade levels save and load. **Save format:** the profile stays at version 1 and gains a new `upgradeLevels` field; a missing field means level 0. There are no live players yet, so no migration is needed. The old prototype's `upgrades` field is never read, so leftover test saves cannot grant levels.
- Done when automated tests (costs, effects, purchases, rejected requests, saving, HUD layout), Studio desktop/mobile and two-player checks pass, and the owner reviews the result.
- Not included: tokens, gacha, pets, inventory, Robux, buying several levels at once.


### Increment 2 acceptance criteria: gems and rebirth (agreed and accepted 16 October 2026)

- A **Gems** row is added to the Cash card and shows the gem balance. New profiles start with 0 gems.
- A **REBIRTH** button opens a confirmation showing the threshold, the gems it gives, and what resets (Cash and the current bag) and what is kept (gems, upgrades, rebirth count). It is greyed out below the threshold.
- Threshold = 1,000 x 1.6^rebirths; gems per rebirth = 10 + 5 x rebirths; both rounded to whole numbers.
- The client sends only the rebirth request. The server checks the claim and that Cash >= threshold, then in one non-yielding step sets Cash to 0, empties the bag, adds the gems, and increases the rebirth count by one. A rapid repeat cannot rebirth twice.
- The upgrade shop costs gems: 3, 4, and 5 x 1.25^level. Unaffordable upgrades are greyed out. Upgrade levels survive rebirth.
- Gems and rebirth count save and load. A missing field means 0.
- Done when automated tests (formulas, rebirth reset and rewards, gem purchases, rejected requests, saving, HUD layout), Studio desktop/mobile and two-player checks pass, and the owner reviews the result.
- Not included: gacha, pets, inventory, rebirth unlocks, Robux.

Agreed details (16 October 2026):
- The currency keeps the name **Cash** in game.
- Upgrade levels bought with Cash in existing test saves **reset to 0** (there are no live players). Saves made before gems existed load with 0 gems, 0 rebirths, and level 0 upgrades; a bag above base capacity is trimmed to 20 fries.

### Increment 3 acceptance criteria: first Cash gacha machine (agreed 16 October 2026)

- **Machine:** Starter Fryer, $100 Cash per spin, reached from a **SPIN** button on the HUD. Its panel shows the price, the odds for every rarity and pet, the pity count, the last result, and the inventory count.
- **Pets (Fry Buddies, placeholder names):**

| Rarity | Chance | Pets and bonuses |
| --- | --- | --- |
| Common | 60% | Crinkle Fry +5% fries per click; Salt Shaker +5% money per fry; Paper Cup +5% bag capacity |
| Uncommon | 25% | Potato Pup +10% fries per click; Ketchup Packet +10% money per fry; Napkin Ghost +10% bag capacity |
| Rare | 10% | Curly Fry Cat +20% fries per click; Mayo Jar +20% money per fry |
| Epic | 4% | Fryer Bot +40% bag capacity |
| Legendary | 1% | Fry King +50% fries per click and +50% money per fry |

  Pets in the same rarity share its chance equally.
- **Pity:** the 50th spin in a row without an Epic or better is guaranteed Epic or better. The counter is saved per machine and resets on any Epic or Legendary.
- **Server-side rolls:** the client sends only a spin request for a machine name. The server checks the claim, the Cash, and inventory space, then deducts the price, rolls, saves the pet, and updates pity in one non-yielding step. Spins have a short cooldown.
- **Inventory:** a **PETS** button opens a list of owned pets (name, rarity, bonus, equipped state) with a count out of 50. Spinning is blocked when the inventory is full.
- **Basic equipping (added on 16 October 2026):** up to 3 pets equipped. Equipped pets apply their bonuses: effective value = (base + upgrade levels) x (1 + total equipped bonus for that stat). Bag capacity rounds down to whole fries; the sale still rounds down to whole Cash.
- **Delete (added to avoid a dead end once the inventory is full):** an unequipped pet can be deleted after a second confirming tap. Equipped pets cannot be deleted.
- Unequipping a capacity pet trims an over-full bag to the new capacity. Pets, equipped pets, and pity survive rebirth.
- Pets, equipped pets, the next pet ID, and pity save and load. Missing fields mean none. Unknown pet types, machines, duplicate IDs, or equipped pets that are not owned make a save invalid.
- Done when automated tests (odds, pity, spins, equip/delete, bonuses, rejected requests, saving, HUD layout), Studio desktop/mobile and two-player checks pass, and the owner reviews the result.
- Not included: pets following the player, merging, auto-delete, bulk delete, more machines, Robux.

Each saved field added here (upgrade levels, gems, rebirths, pets, pity) needs an explicit profile-compatibility decision, as described in docs/ARCHITECTURE.md. Inactive fields from the earlier prototype must not be reused by accident.

### Increments 4 and 5: following pets and inventory management (built 16 October 2026)

Requested by the project owner on 16 October 2026 with "pets follow the player, with a settings toggle" and "inventory management as stated in the README".

- **Following pets:** each player's equipped pets float and bob behind their character, easing after it as it moves. Pets are code-built cartoon models (no assets); Golden pets have a gold body and a slight shine. The server publishes each player's equipped pets as a public `FollowPets` player attribute; every client draws them locally, so following costs no network traffic per frame. Pets disappear while the character is dead or gone.
- **Settings (gear beside Return to Counter, available before claiming):** *Pets follow me* (when off, nobody sees your pets; bonuses still apply) and *Show other players' pets* (only changes what you see). Both default ON and are saved.
- **Merging:** 5 unequipped, non-golden copies of one pet merge into one Golden pet with a new ID and 2x bonus. Golden pets cannot be merged again. The PETS panel offers the rarest mergeable pet first.
- **Bulk delete:** DELETE ALL Common, Uncommon, or Rare removes every unequipped, non-golden pet of that rarity after a second tap. Epic and Legendary are protected.
- **Auto-delete:** per rarity (Common, Uncommon, Rare). Matching spins still cost Cash and count for pity but are not kept; the machine panel names the auto-deleted pet.
- Saved fields: `golden` on a pet, `settings`, and `autoDelete`. Invalid values make a save invalid.
- Studio playtesting and owner review are still pending.

### Open questions

- Final names for the pets.
- Whether rebirth count unlocks anything (for example, extra pet slots or machines) before worlds exist.
- Whether upgrade tracks have level caps.

