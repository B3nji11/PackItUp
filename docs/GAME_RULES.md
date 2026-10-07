# Implemented prototype rules

## Filling and selling

A bag holds 20 fries. Starter clicking produces 1 fry per accepted click, with a maximum accepted rate of 4 clicks per second. Holding the UI button sends paced requests. The starter fryer adds 0.5 fries per second while online, including while away from the station. A full bag halts production.

Fries beyond capacity are discarded. There is no queue and no offline accrual. A full bag's price and variation are locked at completion. Equipment changes and upgrades affect the next completed bag.

Base sale = round(10 x equipped bag multiplier x (1 + 0.2 x sales level) x fry variation multiplier).

A perfect fold multiplies the resulting integer value by 1.25 and rounds to the nearest integer. A player can sell without folding.

## Fold

StartFold consumes the bag's one attempt immediately and schedules a 1.5-second marker sweep after a 0.65-second lead-in. FinishFold succeeds when its server receipt time is between 40% and 60% of that sweep. Early, late or expired attempts leave the ordinary sale intact. Client latency can affect timing and must be tested in Studio.

Folding progress is session-local; the attempted/perfect flags persist. Rejoining cannot grant another attempt on an already-attempted full bag.

## Permanent upgrades

Both tracks start at level 0 and cap at 20.

- Scooping: +1 fry per click per level.
- Sales: +20% of base value per level, additive within the track.
- Next cost: ceil(30 x 1.5 ^ current level).

Cash, Tickets, lifetime Cash and lifetime sales are capped at 1 trillion to bound saved values.

## Deliveries

Three Tickets buy a Machine or Bag roll. Tickets have no Robux acquisition path.

Normal probabilities: Common 60%, Rare 30%, Epic 9%, Legendary 1%. Each pool contains one item at each rarity.

After nine consecutive non-Epic/non-Legendary rolls in one pool, that pool's next roll has 90% Epic / 10% Legendary odds. Any Epic or Legendary resets that pool's counter, including duplicate rewards. This guarantees rarity, not a new item.

Duplicates return one Ticket. Items are retained permanently; rolls never auto-equip.

| Rarity | Machine fries/sec | Bag multiplier |
| --- | ---: | ---: |
| Starter | 0.5 | 1.0 |
| Common | 1 | 1.1 |
| Rare | 2 | 1.3 |
| Epic | 3 | 1.6 |
| Legendary | 5 | 2.0 |

## Fry variations and orders

Each completed bag gets one variation: Regular 80% at x1 value, Loaded 18% at x1.5, Golden 2% at x3.

Discovering all three grants three Tickets once. Discoveries remain after selling.

Every 100 fries served awards one Ticket, with excess progress carried forward. The first five sales grant three extra Tickets once. At the default capacity, five ordinary sales therefore produce four Tickets total. Fixed order targets are deliberate for this single-tier prototype; larger restaurant tiers need a new order-balancing pass.

## Lunch Rush

- First start: after 90 seconds, when at least one player is ready.
- Duration: 90 seconds.
- Next start: 240 seconds after the previous rush resolves.
- Roster: ready players present at start; late joiners wait for the next reward-eligible rush.
- Team goal: 8 bags per starting participant. The target does not shrink when someone leaves.
- Minimum personal contribution: 3 bags.
- Reward: 3 Tickets, granted once at event end if the team succeeded and the player met the minimum and is still present with a loaded profile.
- Sales after the deadline do not count. Each player's ordinary sale income is always kept.

This prototype scales the goal by starting player count, not equipment strength. Exact pacing and rewards need human playtesting.
