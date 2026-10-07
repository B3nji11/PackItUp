# Roblox Studio acceptance checks

These checks have not been executed in this environment. Automated engine doubles cannot verify rendering, actual replication timing, player controls, Roblox service permissions or real shutdown behaviour.

## Solo

1. Open the included place and press Play. Confirm the restaurant, counter assignment, customer, bag and all five UI tabs appear without Output errors.
2. Pack using clicks, holding the button and F. Confirm each method fills the bag and production stops at 20.
3. Attempt to sell early. Confirm no Cash is awarded. Sell a full bag, then immediately press Serve repeatedly. Confirm only one reward.
4. Walk away, attempt to pack and sell, then Return to Counter. Confirm distance restrictions and a safe teleport.
5. Buy each upgrade. Check its balance deduction, level and next price. Confirm a bag already full keeps its original value.
6. Complete five sales. Confirm one normal order Ticket plus three tutorial Tickets.
7. Roll each delivery type, equip rewards, and check the visible model and stat change. Rolls should not auto-equip.
8. Attempt folding early, in the green zone and late, on separate bags. Confirm only the successful timing increases value.
9. Reset the character. Confirm the UI and profile survive and the character returns to its own counter.
10. Discover variations over play or temporarily increase Golden's weight in a test copy. Confirm index collection and its one-time reward. Restore weights before release.

## Multiplayer

Start a local server with at least two clients using Studio's multiplayer testing controls.

- Confirm different stations and independent wallets, inventories and bags.
- Confirm each client's UI shows only their own private progression.
- Observe another player's fry filling and equipment changes.
- Run a Lunch Rush, meet the shared goal, and vary personal contributions around three bags. Check exactly one qualifying reward.
- Join mid-rush and disconnect one starter. Check documented eligibility and the fixed target.
- Leave and rejoin; check freed stations can be reassigned.
- Test a six-player session for overlaps and crowding.

## Real persistence

Use a separately published test experience. Set StudioUseDataStore to true and enable Studio Access to API Services for that test experience.

1. Earn Cash/Tickets, purchase training, own and equip gear, and leave with a partly filled or completed bag.
2. Rejoin after the final save completes. Check every field, including discovery and guarantee counters.
3. Verify both autosave and exit save using Output and separate sessions.
4. Test rapid reconnects; the second session should wait through bounded retries or decline while the previous lease is active.
5. Stop a session abruptly and verify stale-lock recovery after expiry.
6. Exercise the published test server separately from Studio. Studio's TEST store and the live store are intentionally distinct.

Do not conduct failure-injection tests against real player data.

## Device and latency

- Use Studio's device emulator for portrait phones, landscape phones and desktop.
- Confirm tabs, scrolling, folding, hold input and hide/show controls remain reachable.
- Test multiple network-latency settings. Tune the folding lead-in/window after observing actual response timing.
- Confirm the default Roblox movement controls do not obscure necessary game buttons.
- Measure time to first sale, upgrade, delivery and rush reward. Prices are starting values, not a validated retention model.

## Before release

Set maximum players to six, review Roblox's current publication requirements, replace or polish prototype art as desired, and complete all relevant tests above.
