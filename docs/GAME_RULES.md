# Current iteration: core loop

Each player arrives in a central plaza and chooses a free restaurant entrance using E or its touch prompt. Only a nearby living player with a loaded profile can claim; one restaurant is allowed per session. Leaving releases it. Every restaurant has one counter, a basic fryer, and a basic bag. There is no equipment selection or progression shop.

## Filling

- A bag holds 20 fries.
- Each accepted click adds 1 fry; the server accepts at most 4 clicks per second.
- Holding Click or F sends paced Pack requests.
- After claiming, the basic fryer adds 0.5 fries per second while online, including away from the counter. There is no production before claiming.
- Full bags halt production. Overflow is discarded; there is no queue or offline accrual.
- Click input requires the player to be alive and near their own counter.

## Selling

- A full bag sells for bag capacity x money per fry: 20 fries x $0.50 = $10. Money per fry is stored in cents and the sale is rounded down to whole Cash.
- Empty and partial bags cannot be sold.
- Selling requires the player to be alive and near their own counter.
- A successful sale credits Cash and lifetime counters, then clears the bag in one non-yielding operation.
- Repeated selling cannot reward the same bag twice.
- Cash and lifetime counters are capped at 1 trillion.

There are no random variants, folding bonuses, upgrades, Tickets, or event rewards. Legacy saved bonuses do not change these rules.

## Controls

The packing and selling cards remain at the bottom centre. Packing highlights +1 fry/click and changes to Click on hover/selection, retaining the yield underneath. The internal rate limit is not displayed. The sell card shows capacity and progress until full, then Sell Bag and +$10 Cash. The Cash card updates directly after a sale; there is no sold-message toast.

Return to Counter stays at the top and is disabled before claiming. Keyboard shortcuts are E for claiming, F for packing, and R for selling. The Sell button is disabled until a full bag is ready at the player's own counter; the server independently enforces that rule.

## Acceptance

Use the current iteration's definition of done in README.md and the checks in STUDIO_TESTS.md. Validate the core loop and review it with the project owner before agreeing on the next feature.
