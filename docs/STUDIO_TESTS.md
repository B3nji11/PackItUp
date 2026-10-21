# Roblox Studio acceptance checks

Awaiting review: **restaurant tiers** and **the rebalance**. Run their checks first. Visual overhaul 2 (pet models, gacha, and inventory panels) was accepted on 20 October 2026; the sections after it are regression checks for accepted stages, newest first. The overhaul changes how everything looks, so re-run them all once (the Increment 2 checks replace the Increment 1 upgrade shop checks, since upgrades now cost gems). The sections after it are regression checks from the accepted UI/UX iteration (accepted 8 October 2026). Sections older than the rebalance quote the old numbers ($100 spins, $1,000 rebirth, 20-fry bags, % pet bonuses); check the behaviour against the current numbers in docs/GAME_RULES.md.

## Restaurant tiers: six restaurants, six stands, the EXPAND kiosk

1. Claim a restaurant. Six stands stand in front of it, three each side of the entrance path: the Starter Fryer is open and five are grey and LOCKED with the restaurant they need. Signs are readable from the plaza and nothing clips the hedges, posts, or path.
2. Walk onto the Starter Fryer's glowing pad: its panel opens (green). Walk off: it closes. Step onto a locked stand: its panel shows its pets and LOCKED, and spinning does nothing.
3. Press SPIN in the menu from the counter: you are moved onto your best machine's pad, facing it. Check on a south-side restaurant too.
4. Walk onto the kiosk pad (inside, front left): the EXPAND panel shows the Fry Diner, the Deluxe Fryer, the Fry Phoenix portrait, and NEED $5M. With $5M (a long session, or edit the simulation numbers temporarily), EXPAND: the roof, fascia, awning, counter, and floor change colour, a FRY DINER roof sign and props appear, the Deluxe Fryer stand lights up, and your Cash drops by $5M.
5. Spin the Deluxe Fryer: new pets (Onion Ring and friends) with 4x stats. The Starter Fryer still works.
6. Rebirth: the restaurant stays a Fry Diner.
7. A second player sees your Fry Diner from the plaza. Leave the game: your plot returns to the Fry Stand look.
8. Look at each new pet model (spin, or use a test save) and note any that look wrong or float.
9. If possible, check the higher tiers' looks by temporarily lowering their prices in `config/Restaurants.luau` (do not save that change).

## Rebalance: flat pets, percentage upgrades, short numbers

Use a fresh test save (close Studio without saving, reopen the rebuilt place).

1. A new player: Pack shows +2 fries/click, the bag holds 40, and a full bag sells for $40. The first spin ($150) is affordable in about 20 seconds of tapping.
2. Spin a few times. Each pet tile shows three lines (+fries, +$/fry, +bag); the detail bar and the SPIN result show all three stats. On a phone, check the detail-bar stats wrap onto two readable lines.
3. Equip a Crinkle Fry: Pack shows +6 fries/click, and a full bag of 50 sells for $100. Equip three Commons and feel the jump in speed.
4. The SPIN panel lists 8 pets (no Napkin Ghost or Curly Fry Cat) at 20%, 12.5%, 10%, 4%, and 1%.
5. Cash, prices, and the rebirth panel use short numbers ($1.25K, $250K, $1.25M). Rebirth needs $250K and then $500K.
6. UPGRADES: each row shows LEVEL N  ·  +N0%, and buying a level raises the stat by 10% of its base-plus-pets value.
7. Pace check: time how long the first rebirth takes in real play (the simulation says about 3 minutes) and whether the first world feels fast. Note anything that drags or feels too quick.
8. If an old test save has Napkin Ghost or Curly Fry Cat, it still loads and they still work.

## Visual overhaul 2: pet models, gacha, and inventory (accepted 20 October 2026)

1. Equip each of the ten pets in turn (spin, or use a test save). Each following pet is recognisable (fry, shaker, cup, pup, ketchup packet, ghost, cat, mayo jar, robot, king), has the shared face, and does not sink into the ground or float too high. Golden pets are gold with two small sparkles.
2. SPIN: before the first spin the result card shows "?". After a spin it shows the pet's 3D portrait, the rarity tag in its colour, "You got X!", and the bonus. With auto-delete on for that rarity it shows AUTO-DELETED in grey.
3. SPIN: the pity bar fills as spins pass and reads EPIC+ GUARANTEED IN N SPINS. "IN THIS MACHINE" shows all ten pets with portraits, rarity bands, and chances (20%, 8.33%, 5%, 4%, 1%); it scrolls if it does not fit.
4. PETS: pets show as tiles with portraits, equipped ones first with a teal tick. Tap a tile: the detail bar shows it larger with its rarity, bonus, and EQUIP or UNEQUIP. With three equipped, the button reads SLOTS FULL and does nothing. DELETE needs two taps within three seconds and is hidden for equipped pets.
5. PETS: spinning, deleting, and merging update the grid without the scroll jumping back to the top or portraits flickering.
6. Check the portraits render (not empty squares) and are framed well: the whole pet visible, face forward.
7. Phone portrait (375 x 667 and 390 x 844): SPIN stacks the result card above the pet grid; PETS stacks EQUIP and DELETE so the name is readable. Phone landscape (640 x 360): PETS puts both chip rows on one line and shows a full row of tiles; panel shadows shrink with the panels (no dark box behind them).
8. Performance: open PETS with 50 pets (50 live portraits) on a phone and scroll. Note any stutter.

## Visual overhaul 1: Diner Sticker foundation and HUD (accepted 18 October 2026)

Check against docs/STYLE_GUIDE.md and the "Fries HUD style directions" design canvas (artboard B).

1. Fonts: titles, numbers, and buttons use Luckiest Guy; body text uses Fredoka One. Confirm both render (not a fallback font) on desktop and a phone.
2. Wallet: a cream receipt card at the top left with the coin, Cash, a dashed divider, the gem, and Gems. Large Cash amounts shrink to fit.
3. Every sticker element (wallet, menu buttons, Return to Counter, gear, Pack, Sell, panels, Buy/Equip/chips) has a white border and an ink shadow down and right. Shadows follow buttons exactly, hide with them, and never sit on top of their button.
4. Menu: every button shows its name. Labelled pills (orange Upgrades, grape Rebirth, teal Spin, blueberry Pets) on desktop and tall phones; a row of labelled tiles at the top right on short landscape screens. Greyed out before claiming, with names still readable. Rebirth shows a "!" badge when affordable.
5. Return to Counter is a ketchup pill with a home icon; the gear is a cream circle. In portrait they sit under the wallet.
6. Pack is mustard with a fries icon disc, and CLAIM FIRST, BAG FULL, and +N FRIES/CLICK fit inside it with room to spare; Sell is cream with a bag icon and progress bar, turning teal with white outlined text when the bag is full.
7. Each panel opens with its coloured header, white outlined title, caption, round close button, and checker strip. Text inside is readable (ink or dark colours on cream and white).
8. Code-built icons (coin, gem, fries, bag, arrow, loop, egg, paw, gear, home) read clearly at their sizes. They are placeholders until art is uploaded.
9. Restaurant markers: AVAILABLE is a mustard sticker label; owner cards are cream with a white border.
10. Check desktop, a laptop (about 950 x 600), a portrait phone, a small portrait phone (375 x 667), a 640 x 360 landscape phone, and a wide short screen: nothing overlaps (shadows included), and every button is easy to tap.
11. Look out past the hedge from several camera angles: grass runs to the horizon under a warm haze, with no floating edge or harsh blue void. Check that the haze does not wash out the restaurants up close.

## Following pets and settings (stage 4)

1. Equip 1-3 pets. They appear behind your character, bob gently, and ease after you when you walk, run, jump, and turn. Golden pets have a gold body.
2. Unequip, delete, or merge: the following pets update at once. Reset the character: pets disappear while dead and return on respawn.
3. Open Settings (gear beside Return to Counter), including before claiming. Turn **Pets follow me** OFF: your pets vanish for you and for a second player; bonuses still apply. Turn it back ON.
4. With two players: each sees the other's pets. Turn **Show other players' pets** OFF on one client: only the other player's pets vanish there. Settings survive rejoining with persistence enabled.
5. Walk through doors, counters, and the plaza with pets out: they never block movement. Note any clipping through walls for the visual overhaul.
6. With six players and 3 pets each, check frame rate on desktop and a phone.

## Inventory management (stage 5)

1. Collect 5 unequipped copies of one pet. The PETS merge banner offers it; MERGE replaces the 5 with one Golden pet (2x bonus, gold outline). Equipped copies are never used.
2. Golden pets are never offered for merging and are never removed by DELETE ALL.
3. DELETE ALL Common: the first tap shows SURE?, the second removes every unequipped non-golden Common; waiting 3 seconds cancels. Epic and Legendary have no DELETE ALL.
4. Turn AUTO-DELETE on for Common, then spin until a Common rolls: Cash is spent, the machine says "Auto-deleted ...", the pet count does not rise, and the pity countdown still drops. Turn it off again.
5. Check the PETS panel tools on desktop, a portrait phone, and a short landscape phone: chips must be tappable and readable.

## Gacha machine and pets (Increment 3)

These checks need a real Studio session. Automated tests cover odds, pity, spins, equipping, deleting, bonuses, saving, and calculated layout, but not rendering, touch scrolling, or real latency.

1. Before claiming, SPIN and PETS (second row of the menu grid) are greyed out and open nothing.
2. Claim and open SPIN. Check the title, $100 per spin, "Epic or better within 50 spins", the five odds rows with pet names, PETS 0 / 50, and NEED $100 while below $100.
3. Earn $100 and spin. Cash drops by exactly $100, the result names the pet in its rarity color with its bonus, the pity countdown drops by one (unless Epic or better), and the pet count rises.
4. Tap SPIN repeatedly and quickly, including with high simulated latency. Each accepted spin charges once and adds exactly one pet.
5. Open PETS. Opening it closes the machine panel. Pets are listed equipped first, then by rarity, with name, rarity, and bonus. Scroll the list with many pets on desktop and touch.
6. Equip a fries-per-click pet: the packing button shows the new value (for example +1.05 fries/click). Equip a money-per-fry pet: a full bag's SELL value rises. Equip Fryer Bot or a capacity pet: the bag capacity rises.
7. Try a 4th pet with 3 equipped: its EQUIP is greyed out. Unequip one, then equip another.
8. Fill the bag with a capacity pet equipped, then unequip it: the bag is trimmed to the new capacity and can be sold.
9. DELETE an unequipped pet: the first tap shows SURE?, the second deletes it; waiting 3 seconds cancels. Equipped pets show no DELETE.
10. Rebirth: pets, equipped pets, and the pity countdown are kept.
11. Fill the inventory to 50 (a temporary higher starting Cash in Studio is fine; restore afterwards): the machine button reads INVENTORY FULL until a pet is deleted.
12. Check the 2x2 menu grid and both panels on desktop, a portrait phone, a short landscape phone (grid at the top right), and a wide short screen. Text must fit, buttons must be tappable, and nothing may overlap the action buttons, Cash card, Return to Counter, guidance, or Roblox's own controls.
13. With two players, confirm pets, equipped pets, pity, and Cash stay separate.
14. With persistence enabled in a test experience: spin, equip, leave, and rejoin. Pets, equipped pets, pity, and stat bonuses are restored.
15. Confirm no extra machines or Robux options have appeared.

## Gems, rebirth, and upgrades (Increment 2)

These checks need a real Studio session. Automated tests cover the rules, saving, migration, and calculated layout, but not rendering, touch input, or real latency.

1. Before claiming, UPGRADES and REBIRTH below the Cash card are greyed out and open nothing. The Cash card shows Cash on top and Gems (0) below a divider.
2. Claim a restaurant. Open UPGRADES: three rows cost 3, 4, and 5 GEMS and are all greyed out with 0 gems, however much Cash you have.
3. Open REBIRTH: it shows +10 GEMS, Needs $1,000 Cash with a progress bar, what resets and what is kept, and REBIRTHS: 0. The confirm button reads NEED $1,000 and does nothing. Opening UPGRADES closes the rebirth panel, and the reverse.
4. Earn $1,000 (a temporary lower threshold in config/Rebirth is fine for a quick test; restore it afterwards). The REBIRTH button glows and the confirm button reads REBIRTH NOW.
5. Part-fill the bag and earn some Cash above the threshold, then rebirth. Cash goes to exactly $0, the bag empties (visible fries too), Gems shows 10, the panel closes, and the next rebirth reads +15 GEMS at $1,600.
6. Buy Fries per click for 3 gems: Gems drops to 7, the row shows LEVEL 1 and 4 GEMS, and packing reads +2 fries/click. Cash is unchanged. Buy until a row is unaffordable and check it greys out.
7. Rebirth again: upgrade levels and gems are kept; only Cash and the bag reset.
8. Tap REBIRTH NOW and the Buy buttons repeatedly and quickly, including with high simulated latency. Each accepted request applies once; gems never go negative and a rebirth never pays twice.
9. Fill the bag completely, then buy Bag capacity: the bag shows 20 / 25 and keeps filling; no fries disappear.
10. Check the Cash and Gems card, both buttons, and both panels on desktop, a portrait phone, and a short landscape phone (buttons stack at the top right). Text must fit, buttons must be easy to tap, and nothing may overlap the action buttons, Return to Counter, or Roblox's own controls. The Studio test label sits in the bottom-left corner.
11. With two players, confirm Cash, gems, rebirth counts, and levels stay separate.
12. With persistence enabled in a test experience: rebirth, buy upgrades, leave, and rejoin. Gems, rebirth count, levels, Cash, and the bag are restored. A save from Increment 1 (upgrade levels bought with Cash, no gems) loads with 0 gems and level 0 on all tracks, keeping its Cash.
13. Confirm no Robux options have appeared.

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
- Verify no doors, progression rewards beyond the upgrade shop, rebirth, and the gacha machine, or other unrequested systems have been introduced.

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
4. At full capacity (20 fries before upgrades) it should become green and read Sell Bag with its Cash value (+$10 before upgrades). Sell using the button and R. E must only handle claiming and never sell a bag.
5. Confirm Cash increases by exactly the shown value, the bag clears, and no Sold message appears underneath the buttons. Repeat rapidly; there must be no duplicate payment.
6. Check the middle-left Cash card, coin symbol, and comma-grouped amount, including clearance from the bottom actions on short screens. Verify large amounts fit the card.
7. Walk away from the counter with a full bag: selling must be disabled and the return instruction should be clear. Return to Counter must target the player's own restaurant.
8. Confirm useful errors appear briefly near the top, then clear, rather than obscuring the bottom actions.
9. Confirm Fold, Delivery, Index, and Inventory remain absent, and Q does nothing. The upgrade, rebirth, machine, pets, and settings panels are the only menus.

## Devices, multiplayer, and latency

- Emulate portrait phones, landscape phones, and desktop. Check label wrapping, shortcut contrast, touch sizes, and overlap with Roblox's movement/jump controls and top bar.
- Test tap, hold, release, loss of focus, and F/R shortcuts. Test native claiming prompts on touch and keyboard.
- Use at least two Studio clients to check separate ownership, Cash, bags, teleports, and visible fry filling.
- Test six admitted players, including those still choosing plots, and a seventh player being declined without displacing anyone.
- Test increased network latency; delayed UI updates must not permit duplicate claims, premature sales, or duplicate Cash.

## Persistence regression

Use a separately published test experience with StudioUseDataStore enabled. Keep live and test stores separate.

1. Earn Cash and leave with a partial bag. Rejoin, choose a restaurant, and verify progress.
2. Repeat with a full bag. It must sell once for its full value (capacity x money per fry) after claiming.
3. Verify autosave, exit save, and shutdown through Output. Old saved prototype bonuses must still have no effect; only upgradeLevels changes stats.

## Iteration review

Record the Studio results and review the new player journey with the project owner. Fix UX and core-loop failures before starting the visual overhaul.
