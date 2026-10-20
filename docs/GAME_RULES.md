# Game rules (current through the rebalance, 20 October 2026)

Each player arrives in a central plaza and chooses a free restaurant entrance using E or its touch prompt. Only a nearby living player with a loaded profile can claim; one restaurant is allowed per session. Leaving releases it. Every restaurant has one counter, a basic fryer, and a bag. Players earn Cash, rebirth at a rising Cash threshold to earn gems, spend gems in the upgrade shop, and spend Cash on gacha spins for pets that add to the same three stats.

Every stat = (base + equipped pets' flat amounts) x (1 + upgrade percent). Numbers are shown in short form: $1.25K, $3.4M, $1.25B, $2T, then Qa, Qi, Sx, Sp, Oc, No, Dc, then scientific notation (1.2e36).

## Filling

- A bag holds (40 + equipped pets' bag) x (1 + 10% per Bag capacity level) fries, rounded down to whole fries.
- Each accepted click adds (2 + equipped pets' fries) x (1 + 10% per Fries per click level) fries (so it can be fractional, such as 2.4). The server accepts at most 4 clicks per second.
- Holding Click or F sends paced Pack requests.
- After claiming, the basic fryer adds 0.5 fries per second while online, including away from the counter. This rate is fixed and cannot be upgraded. There is no production before claiming.
- Full bags halt production. Overflow is discarded; there is no queue or offline accrual.
- Click input requires the player to be alive and near their own counter.

## Selling

- A full bag sells for bag capacity x money per fry, rounded down to whole Cash. Money per fry is ($1 + equipped pets' money) x (1 + 10% per Money per fry level). It is worked out in cents. Before pets and upgrades: 40 fries x $1 = $40.
- Empty and partial bags cannot be sold.
- Selling requires the player to be alive and near their own counter.
- A successful sale credits Cash and lifetime counters, then clears the bag in one non-yielding operation.
- Repeated selling cannot reward the same bag twice.
- Cash has no practical cap (owner, 20 October 2026). A hidden safety limit of 1e300 only stops a number ever becoming infinity, which would corrupt a save. Above about 9 quadrillion, amounts keep about 15 significant digits.

## Rebirth

- Rebirth threshold = 250,000 x 2^rebirths, rounded to whole Cash: $250K, $500K, $1M, $2M, ...
- Gems per rebirth = 10 + 5 x rebirths: 10, 15, 20, ...
- Rebirth needs Cash >= the threshold. It sets Cash to 0 (everything above the threshold is lost too) and empties the current bag, then adds the gems and counts the rebirth.
- Gems, upgrade levels, the rebirth count, sales, and lifetime Cash are kept.
- The client sends only the request. The server checks the restaurant claim and the threshold, and applies the whole rebirth in one non-yielding operation. A short cooldown stops a rapid repeat from rebirthing twice.

## Gacha and pets

- **Starter Fryer:** $150 Cash per spin, 8 pets. Odds: Common 60%, Uncommon 25%, Rare 10%, Epic 4%, Legendary 1%. Pets in a rarity share its chance equally (Common 20% each, Uncommon 12.5% each, Rare 10%, Epic 4%, Legendary 1%).
- **Pets** (fries per click / money per fry / bag): Crinkle Fry +4 / +$1 / +10, Salt Shaker +2 / +$2 / +10, Paper Cup +2 / +$1 / +20 (Common); Potato Pup +6 / +$1.50 / +15, Ketchup Packet +3 / +$3 / +15 (Uncommon); Mayo Jar +4 / +$4 / +20 (Rare); Fryer Bot +6 / +$3 / +60 (Epic); Fry King +12 / +$6 / +60 (Legendary). Napkin Ghost and Curly Fry Cat are no longer in the Starter Fryer (they join the Deluxe Fryer); copies already owned keep working.
- **Pity:** the 50th spin in a row without an Epic or better is Epic or better (Epic 80%, Legendary 20%). Any Epic or Legendary resets the counter.
- The client sends only Spin with the machine name. The server checks the claim, Cash, and inventory space, then deducts the price, rolls with a server-side random number, adds the pet, and updates pity in one non-yielding step.
- **Inventory:** up to 50 pets, each with a unique ID that is never reused. Spinning is blocked when full.
- **Equipping:** up to 3 pets. Their flat amounts add together, then upgrade percentages apply.
- **Deleting:** only unequipped pets, after a second confirming tap.
- Unequipping or deleting trims an over-full bag to the new capacity. Pets, equipped pets, pity, and settings survive rebirth.

## Inventory management

- **Merging:** 5 unequipped, non-golden copies of one pet merge into one Golden pet (new ID, 2x every stat). Golden pets cannot merge again.
- **Delete all:** removes every unequipped, non-golden Common, Uncommon, or Rare pet of the chosen rarity (second tap within 3 seconds). Epic and Legendary cannot be bulk deleted.
- **Auto-delete:** per rarity (Common, Uncommon, Rare). A matching spin still costs Cash and counts for pity, but the pet is not kept.

## Following pets and settings

- Equipped pets float behind their owner (up to 3 slots behind the character), bob gently, and ease after them. Golden pets have a gold body.
- **Pets follow me** (default ON): when OFF, nobody sees your pets. Bonuses still apply.
- **Show other players' pets** (default ON): only changes what you see.
- Settings are saved, open from the gear beside Return to Counter, and can be changed before claiming.

## Upgrades

| Track | Per level | Cost (whole gems, rounded) |
| --- | --- | --- |
| Fries per click | +10% fries per click | 3 x 1.25^level |
| Money per fry | +10% money per fry | 4 x 1.25^level |
| Bag capacity | +10% bag size | 5 x 1.25^level |

- Levels add up rather than compound: level 5 is +50%, level 10 is +100%. There are no level caps; rising costs limit progress.
- The client sends only the track name. The server checks the restaurant claim, the track name, and the gems, then deducts the gem cost and raises one level in one non-yielding operation. Purchases have a short cooldown. Buying does not require standing at the counter.
- Buying Bag capacity while the bag is full makes it partial again. No fries are lost and filling resumes.
- Upgrades are permanent and survive rebirth. Cash never buys upgrades.
- Upgrade levels are saved in `upgradeLevels`, gems in `gems`, the rebirth count in `rebirths`, pets in `pets`, equipped pet IDs in `equippedPets`, the last pet number in `nextPetId`, and pity per machine in `pity`. The old prototype's `equipped` equipment field is never read. A missing field or track means 0. The old prototype's `upgrades` field is never read.
- Saves from before gems existed load once with 0 gems, 0 rebirths, and level 0 upgrades (the owner chose to reset Cash-bought levels). A bag above base capacity is trimmed to 40 fries.

There are no random fry variants, folding bonuses, Tickets, rebirth unlocks, extra machines, Robux purchases, or event rewards. Legacy saved bonuses do not change these rules.

## Controls

Layout and look follow docs/STYLE_GUIDE.md (Diner Sticker): the Cash and Gems wallet at the top left, the menu below it (or a round icon grid on small screens), Return to Counter and the settings gear at the top. The packing and selling buttons stay at the bottom centre. Packing highlights the current fries per click and changes to Click on hover/selection, retaining the yield underneath. The internal rate limit is not displayed. The sell card shows capacity and progress until full, then Sell Bag and its Cash value. The Cash card shows Cash and, below a divider, Gems. It updates directly after a sale, purchase, or rebirth; there is no sold-message toast.

Four menu buttons: UPGRADES, REBIRTH, SPIN, and PETS. On tall screens they are labelled pills below the wallet; on screens under 500 px high, and on small phones, they become labelled tiles (a row at the top right on short screens, or a 2x2 grid). All four are greyed out before claiming, REBIRTH shows a "!" badge when a rebirth is available, and only one panel is open at a time.

- UPGRADES opens one row per track: level, current value -> next value, and a Buy button showing the gem cost. Unaffordable Buy buttons are greyed out and send nothing.
- REBIRTH glows when the threshold is reached. Its panel shows the gems it gives, the threshold and current Cash with a progress bar, what resets and what is kept, and the rebirth count. The confirm button reads NEED $X until the threshold is reached, then REBIRTH NOW. A completed rebirth closes the panel.
- SPIN opens the Starter Fryer: price and pity in the caption, the last result (3D portrait, rarity tag, name, bonus), a pity bar, the pet count, a button reading SPIN $150, NEED $150, or INVENTORY FULL, and every pet in the machine with its own chance (its rarity's chance split evenly between that rarity's pets).
- PETS shows owned pets as tiles (equipped first, then by rarity, Golden first) with portrait, name, and bonus. Tapping a tile selects it; the detail bar below shows its rarity and full bonus, EQUIP/UNEQUIP (SLOTS FULL when three are equipped), and DELETE (unequipped only; tap twice within 3 seconds). Above the grid: AUTO-DELETE and DELETE ALL chips for Common, Uncommon, and Rare, and a merge banner with MERGE for the rarest mergeable pet.
- X closes any panel.

Return to Counter stays at the top and is disabled before claiming. Keyboard shortcuts are E for claiming, F for packing, and R for selling. The Sell button is disabled until a full bag is ready at the player's own counter; the server independently enforces that rule.

## Acceptance

Use the checks in STUDIO_TESTS.md and review with the project owner before starting the visual overhaul. Past acceptance criteria are in HISTORY.md.
