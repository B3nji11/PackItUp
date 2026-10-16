# Current iteration: gems and rebirth (Increment 2)

Each player arrives in a central plaza and chooses a free restaurant entrance using E or its touch prompt. Only a nearby living player with a loaded profile can claim; one restaurant is allowed per session. Leaving releases it. Every restaurant has one counter, a basic fryer, and a bag. Players earn Cash, rebirth at a rising Cash threshold to earn gems, and spend gems in the upgrade shop to raise three stats.

## Filling

- A bag holds 20 fries, plus 5 per Bag capacity level.
- Each accepted click adds 1 fry, plus 1 per Fries per click level. The server accepts at most 4 clicks per second.
- Holding Click or F sends paced Pack requests.
- After claiming, the basic fryer adds 0.5 fries per second while online, including away from the counter. This rate is fixed and cannot be upgraded. There is no production before claiming.
- Full bags halt production. Overflow is discarded; there is no queue or offline accrual.
- Click input requires the player to be alive and near their own counter.

## Selling

- A full bag sells for bag capacity x money per fry, rounded down to whole Cash. Money per fry is $0.50, plus $0.05 per Money per fry level. It is stored in cents so sums stay exact. Before upgrades: 20 fries x $0.50 = $10.
- Empty and partial bags cannot be sold.
- Selling requires the player to be alive and near their own counter.
- A successful sale credits Cash and lifetime counters, then clears the bag in one non-yielding operation.
- Repeated selling cannot reward the same bag twice.
- Cash and lifetime counters are capped at 1 trillion.

## Rebirth

- Rebirth threshold = 1,000 x 1.6^rebirths, rounded to whole Cash: $1,000, $1,600, $2,560, $4,096, ...
- Gems per rebirth = 10 + 5 x rebirths: 10, 15, 20, ...
- Rebirth needs Cash >= the threshold. It sets Cash to 0 (everything above the threshold is lost too) and empties the current bag, then adds the gems and counts the rebirth.
- Gems, upgrade levels, the rebirth count, sales, and lifetime Cash are kept.
- The client sends only the request. The server checks the restaurant claim and the threshold, and applies the whole rebirth in one non-yielding operation. A short cooldown stops a rapid repeat from rebirthing twice.

## Upgrades

| Track | Per level | Cost (whole gems, rounded) |
| --- | --- | --- |
| Fries per click | +1 fry per click | 3 x 1.25^level |
| Money per fry | +$0.05 per fry | 4 x 1.25^level |
| Bag capacity | +5 fries | 5 x 1.25^level |

- There are no level caps. Rising costs limit progress.
- The client sends only the track name. The server checks the restaurant claim, the track name, and the gems, then deducts the gem cost and raises one level in one non-yielding operation. Purchases have a short cooldown. Buying does not require standing at the counter.
- Buying Bag capacity while the bag is full makes it partial again. No fries are lost and filling resumes.
- Upgrades are permanent and survive rebirth. Cash never buys upgrades.
- Upgrade levels are saved in `upgradeLevels`, gems in `gems`, and the rebirth count in `rebirths`. A missing field or track means 0. The old prototype's `upgrades` field is never read.
- Saves from before gems existed load once with 0 gems, 0 rebirths, and level 0 upgrades (the owner chose to reset Cash-bought levels). A bag above base capacity is trimmed to 20 fries.

There are no random variants, folding bonuses, Tickets, gacha, pets, rebirth unlocks, or event rewards in this iteration. Legacy saved bonuses do not change these rules.

## Controls

The packing and selling cards remain at the bottom centre. Packing highlights the current fries per click and changes to Click on hover/selection, retaining the yield underneath. The internal rate limit is not displayed. The sell card shows capacity and progress until full, then Sell Bag and its Cash value. The Cash card shows Cash and, below a divider, Gems. It updates directly after a sale, purchase, or rebirth; there is no sold-message toast.

UPGRADES and REBIRTH sit side by side below the Cash card (stacked at the top right on short landscape screens) and are inactive before claiming. Only one panel is open at a time.

- UPGRADES opens one row per track: level, current value -> next value, and a Buy button showing the gem cost. Unaffordable Buy buttons are greyed out and send nothing.
- REBIRTH glows when the threshold is reached. Its panel shows the gems it gives, the threshold and current Cash with a progress bar, what resets and what is kept, and the rebirth count. The confirm button reads NEED $X until the threshold is reached, then REBIRTH NOW. A completed rebirth closes the panel.
- X closes either panel.

Return to Counter stays at the top and is disabled before claiming. Keyboard shortcuts are E for claiming, F for packing, and R for selling. The Sell button is disabled until a full bag is ready at the player's own counter; the server independently enforces that rule.

## Acceptance

Use the Increment 2 acceptance criteria in README.md and the checks in STUDIO_TESTS.md. Review the result with the project owner before starting Increment 3.
