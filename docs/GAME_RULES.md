# Current iteration: upgrade shop (Increment 1)

Each player arrives in a central plaza and chooses a free restaurant entrance using E or its touch prompt. Only a nearby living player with a loaded profile can claim; one restaurant is allowed per session. Leaving releases it. Every restaurant has one counter, a basic fryer, and a bag. Players spend Cash in the upgrade shop to raise three stats.

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

## Upgrades

| Track | Per level | Cost (whole Cash, rounded) |
| --- | --- | --- |
| Fries per click | +1 fry per click | 25 x 1.18^level |
| Money per fry | +$0.05 per fry | 40 x 1.20^level |
| Bag capacity | +5 fries | 50 x 1.25^level |

- There are no level caps. Rising costs limit progress.
- The client sends only the track name. The server checks the restaurant claim, the track name, and the Cash, then deducts the cost and raises one level in one non-yielding operation. Purchases have a short cooldown. Buying does not require standing at the counter.
- Buying Bag capacity while the bag is full makes it partial again. No fries are lost and filling resumes.
- Upgrade levels are saved in `upgradeLevels`. A missing field or track means level 0. The old prototype's `upgrades` field is never read.

There are no random variants, folding bonuses, Tickets, gacha, pets, or event rewards in this iteration. Legacy saved bonuses do not change these rules.

## Controls

The packing and selling cards remain at the bottom centre. Packing highlights the current fries per click and changes to Click on hover/selection, retaining the yield underneath. The internal rate limit is not displayed. The sell card shows capacity and progress until full, then Sell Bag and its Cash value. The Cash card updates directly after a sale or purchase; there is no sold-message toast.

The UPGRADES button sits below the Cash card (top right on short landscape screens) and is inactive before claiming. It opens a panel with one row per track: level, current value -> next value, and a Buy button showing the cost. Unaffordable Buy buttons are greyed out and send nothing. X closes the panel.

Return to Counter stays at the top and is disabled before claiming. Keyboard shortcuts are E for claiming, F for packing, and R for selling. The Sell button is disabled until a full bag is ready at the player's own counter; the server independently enforces that rule.

## Acceptance

Use the Increment 1 acceptance criteria in README.md and the checks in STUDIO_TESTS.md. Review the result with the project owner before starting Increment 2.
