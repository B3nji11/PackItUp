# UI/UX iteration: Roblox Studio acceptance checks

The project owner confirmed the prior core version works. These checks cover the new claiming, world layout, and HUD changes. They still need a real Studio session; engine doubles and layout previews cannot verify rendering, physics, real prompts, or mobile controls.

## Arrival and claiming

1. Reopen the rebuilt FriesGame.rbxlx and press Play. The restaurant district must appear without Output errors.
   Confirm there is no LightingStyle permission error or infinite wait for FriesRemotes; the packing/selling buttons and middle-left Cash card must appear immediately. LightingStyle is stored in the place, not assigned by a running script.
2. Arrive in the central plaza with no restaurant assigned. All six restaurant entrances should be available, with no floating fryer labels anywhere.
3. Confirm packing, selling, and Return to Counter are inactive before claiming. No fries should accumulate before a claim.
4. Walk to any available entrance. Press E, tap the native prompt on a phone, or use the displayed gamepad input. Confirm ownership appears on the building and you arrive at its counter.
5. Try to claim another restaurant. Your original claim must remain; one player cannot occupy multiple plots.
6. In a two-player session, try to claim the same plot at nearly the same time. Only one player may own it. The other can choose a different restaurant.
7. Confirm a distant or dead character cannot claim and that claiming is unavailable while a profile is loading.
8. Leave the server. Confirm the plot becomes available for someone else. Rejoining starts in the plaza; plot choice is session-local, while Cash and fries persist when persistence is enabled.
9. Reset a character after claiming. It should return to its own restaurant without losing the claim or progress.

## Restaurant arrows and owner cards

- Join without a plot: spaced gold chevrons (> > >) should extend from above your head toward each free entrance, with no connecting shaft and AVAILABLE labels at the destinations. Walk, turn, and jump toward both rows; the starting point must follow your head smoothly. Stand still and confirm the chevrons keep flowing toward the restaurants, fading at both endpoints as they loop. Check desktop and mobile readability and animation speed at low/high frame rates.
- Claim a plot: all availability arrows disappear for you, while another unclaimed player still sees arrows for the remaining free plots.
- Everyone should see the owner's avatar headshot and account @username above each claimed restaurant roof. Test an account whose display name differs from its username and one with a long username.
- Leave and let another player claim that restaurant. The old owner card must clear, the arrow should return for unclaimed viewers, and the next card must show only the new owner.
- Check late joiners and respawns: markers should reflect current ownership without duplicates. Confirm there are no fryer name tags.
- Reset before claiming: arrows should hide during death and reattach above the new character's head. Stand directly at an endpoint and check for oversized/flickering chevrons. Another client should only see its own guides, not yours.
- If an avatar thumbnail is unavailable (including simulated Studio users), its initial and username remain visible; claiming, the action buttons, and Cash must continue working.
- Check portrait/landscape views for marker overlap and excessive obstruction; these world-space billboards need actual Studio visual review.

## District layout and signage

- Inspect all six restaurants, facing the central promenade in two rows of three.
- Walk from the plaza into every entrance, around the counter, and back out. Check floor transitions, hedges, furniture, and camera clearance.
- Check all six ceilings from inside and outside: walls should meet the ceiling, entrances must stay open, and the camera should remain usable when packing, walking, zooming, and returning to the counter. Check interior brightness on desktop and mobile.
- Confirm the taller walls, roofs, signs, and awnings line up in both rows. Check that owner cards remain visible above the raised roofs.
- Inspect the four ceiling lights per restaurant. Counters, fryer screens, bags, dining tables, and floor corners should be readable without harsh bright spots or washed-out colors. Compare low/high graphics settings and watch performance with all six restaurants visible; automated range checks cannot confirm rendered brightness.
- Walk the entire outer boundary, including its four corners. Confirm it blocks walking off the map, has no gaps, and leaves space outside the restaurant plots. Check normal jumping against the boundary.
- Confirm buildings feel separated and the central area remains open. Ask testers whether they can identify an available plot and understand where to go without instructions.
- Confirm the title is on the physical mural wall, following the wall's perspective rather than facing the camera.
- Confirm ownership plaques are readable nearby and no floating fryer/equipment name tags or old customer text bubbles return.
- Verify no doors, shops, progression rewards, or other unrequested systems have been introduced.

## Smooth cartoon world

- Inspect the ground, paths, walls, hedges, tables, fryer, and bag up close. Surfaces should have flat colors without grass, masonry, wood, or metal grain.
- Confirm the plaza and all connecting/entrance paths are brown, the plaza bushes are rounded, and the coral/mint restaurants remain easy to distinguish from the paths and green plots.
- Check that the fryer, bag, fries, wall title, and ownership text remain readable in both sun and shadow, without harsh glare or washed-out colors.
- Compare low and high graphics settings on desktop and a phone. Check moving-camera edge shimmer separately from surface texture; automated tests cannot validate engine antialiasing or shadow rendering.
- Walk through the district and repeat a fill/sell cycle. Review the actual Play-mode appearance with the owner before adding more art detail.

## Action buttons and Cash

1. The gold packing button highlights +1 fry/click. Hover/select it to see Click with the yield underneath. The maximum click rate should not appear. Touch users must retain a visible tap/hold packing hint.
2. Click, hold the button, and hold F. Each should fill the bag at the same existing rates. The basic fryer still adds 0.5 fries/sec after claiming, including while away.
3. The sell button shows fries/capacity and a progress bar before full. Check empty, partially filled, and nearly full states.
4. At 20 fries it should become green and read Sell Bag with +$10 Cash. Sell using the button and R. E must only handle claiming and never sell a bag.
5. Confirm Cash increases by exactly $10, the bag clears, and no Sold message appears underneath the buttons. Repeat rapidly; there must be no duplicate payment.
6. Check the middle-left Cash card, coin symbol, and comma-grouped amount, including clearance from the bottom actions on short screens. Verify large amounts fit the card.
7. Walk away from the counter with a full bag: selling must be disabled and the return instruction should be clear. Return to Counter must target the player's own restaurant.
8. Confirm useful errors appear briefly near the top, then clear, rather than obscuring the bottom actions.
9. Confirm Fold, Upgrades, Delivery, Index, and Inventory remain absent, and Q does nothing.

## Devices, multiplayer, and latency

- Emulate portrait phones, landscape phones, and desktop. Check label wrapping, shortcut contrast, touch sizes, and overlap with Roblox's movement/jump controls and top bar.
- Test tap, hold, release, loss of focus, and F/R shortcuts. Test native claiming prompts on touch and keyboard.
- Use at least two Studio clients to check separate ownership, Cash, bags, teleports, and visible fry filling.
- Test six admitted players, including those still choosing plots, and a seventh player being declined without displacing anyone.
- Test increased network latency; delayed UI updates must not permit duplicate claims, premature sales, or duplicate Cash.

## Persistence regression

Use a separately published test experience with StudioUseDataStore enabled. Keep live and test stores separate.

1. Earn Cash and leave with a partial bag. Rejoin, choose a restaurant, and verify progress.
2. Repeat with a full bag. It must sell once for $10 after claiming.
3. Verify autosave, exit save, and shutdown through Output. Old saved bonuses must still have no effect on the base rates or sale price.

## Iteration review

Record the Studio results and review the new player journey with the project owner. Fix UX and core-loop failures before starting another gameplay feature.
