"""Balance simulation for the rebalance increment (flat three-stat pets, percentage upgrades).

Models one player who taps at the click limit, sells every full bag, spins with part of their
Cash, merges five copies into Golden, equips the best three, spends gems on the cheapest
upgrade, rebirths at the threshold, and saves for the Fry Diner once ready. Reports the median
time to milestones over many runs. All numbers are first guesses to tune, not truths.

    python3 tools/simulate.py            # default numbers
    python3 tools/simulate.py --runs 400
"""
import argparse
import random
import statistics

# ---- Proposed numbers (mirror these into src/shared/config when agreed) -------------------
BASE = dict(click=2, money=1.00, bag=40)   # fries/click, $/fry, fries per bag
FRYER_PER_SECOND = 0.5
CLICKS_PER_SECOND = 4
SELL_SECONDS = 0.75                            # tapping Sell after a full bag

def stats(click, money, bag):
    return dict(click=click, money=money, bag=bag)

# Rarity scale x lean (click, money, bag). Common unit lean shapes:
PET_POWER = 2   # owner, 20 Oct 2026: pet stats higher
CLICK_LEAN = (2 * PET_POWER, 0.50 * PET_POWER, 5 * PET_POWER)
MONEY_LEAN = (1 * PET_POWER, 1.00 * PET_POWER, 5 * PET_POWER)
BAG_LEAN = (1 * PET_POWER, 0.50 * PET_POWER, 10 * PET_POWER)
BALANCED = (1.5 * PET_POWER, 0.75 * PET_POWER, 7.5 * PET_POWER)
def pet(name, rarity, lean, scale):
    c, m, b = lean
    # Clean numbers: whole fries, money to 5 cents, whole bag slots.
    return dict(name=name, rarity=rarity, click=max(1, round(c * scale)), money=max(0.05, round(m * scale * 20) / 20),
        bag=max(1, round(b * scale)))

SCALE = dict(Common=1, Uncommon=1.5, Rare=2, Epic=3, Legendary=4)   # stat multiplier per rarity
DELUXE = 4                                                          # Deluxe stats vs Starter
def roster(tier, prefix_names):
    n = prefix_names
    return [pet(n[0], "Common", CLICK_LEAN, SCALE["Common"] * tier), pet(n[1], "Common", MONEY_LEAN, SCALE["Common"] * tier),
        pet(n[2], "Common", BAG_LEAN, SCALE["Common"] * tier), pet(n[3], "Uncommon", CLICK_LEAN, SCALE["Uncommon"] * tier),
        pet(n[4], "Uncommon", MONEY_LEAN, SCALE["Uncommon"] * tier), pet(n[5], "Rare", MONEY_LEAN, SCALE["Rare"] * tier),
        pet(n[6], "Epic", BAG_LEAN, SCALE["Epic"] * tier), pet(n[7], "Legendary", BALANCED, SCALE["Legendary"] * tier)]
ODDS = dict(Common=0.60, Uncommon=0.25, Rare=0.10, Epic=0.04, Legendary=0.01)
def build_machines():
    return {
        "StarterFryer": dict(price=START_PRICE, pity=50, odds=ODDS, pets=roster(1, ["Crinkle Fry", "Salt Shaker", "Paper Cup", "Potato Pup", "Ketchup Packet", "Mayo Jar", "Fryer Bot", "Fry King"])),
        "DeluxeFryer": dict(price=DELUXE_PRICE, pity=50, odds=ODDS, pets=roster(DELUXE, ["Onion Ring", "Pickle Chip", "Napkin Ghost", "Hash Brown Hamster", "Milkshake", "Curly Fry Cat", "Cheese Sauce Slime", "Fry Phoenix"])),
    }
START_PRICE, DELUXE_PRICE = 150, 150000
MACHINES = None
RANK = dict(Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5)
DINER_PRICE = 5000000
UPGRADE = dict(percent_per_level=0.10, base_cost=dict(click=3, money=4, bag=5), growth=1.25)
REBIRTH = dict(base=250000, growth=2.0, base_gems=10, gems_per=5)
EQUIP_SLOTS, MAX_PETS, MERGE, GOLDEN = 3, 50, 5, 2
SPIN_SHARE = 0.5      # share of each sale the player spends on spins (until saving for the Diner)
SPINS_PER_SECOND = 1.5


def effective(pets, levels):
    out = {}
    for key in ("click", "money", "bag"):
        flat = BASE[key] + sum(p[key] for p in pets)
        out[key] = flat * (1 + UPGRADE["percent_per_level"] * levels[key])
    out["bag"] = max(1, int(out["bag"]))
    return out


def income_per_second(s):
    fill = max(s["bag"] / (CLICKS_PER_SECOND * s["click"] + FRYER_PER_SECOND), 1 / CLICKS_PER_SECOND)
    return s["bag"] * s["money"] / (fill + SELL_SECONDS)


def value(p):  # income from equipping this pet alone on a fresh player, used to rank pets
    return income_per_second(effective([p], dict(click=0, money=0, bag=0)))


def run(seed, minutes=240):
    rng = random.Random(seed)
    t, cash, gems, rebirths, tier = 0.0, 0.0, 0, 0, 1
    levels = dict(click=0, money=0, bag=0)
    owned, pity = [], dict(StarterFryer=0, DeluxeFryer=0)
    marks = {}
    spin_budget = 0.0
    step = 1.0
    cache = {"best": []}
    def best():
        return cache["best"]
    def refresh():
        cache["best"] = sorted(owned, key=lambda p: p["v"], reverse=True)[:EQUIP_SLOTS]
    def spin(machine_id):
        nonlocal cash
        m = MACHINES[machine_id]
        cash -= m["price"]
        pity[machine_id] += 1
        roll, acc, rarity = rng.random(), 0, "Common"
        for r, chance in m["odds"].items():
            acc += chance
            if roll < acc: rarity = r; break
        if pity[machine_id] >= m["pity"] and RANK[rarity] < 4: rarity = "Epic"
        if RANK[rarity] >= 4: pity[machine_id] = 0
        choice = dict(rng.choice([p for p in m["pets"] if p["rarity"] == rarity]), golden=False)
        choice["v"] = value(choice)
        owned.append(choice)
        # merge five plain copies into a Golden one
        same = [p for p in owned if p["name"] == choice["name"] and not p["golden"]]
        if len(same) >= MERGE:
            for p in same[:MERGE]: owned.remove(p)
            g = dict(choice, golden=True, name=choice["name"])
            for k in ("click", "money", "bag"): g[k] = choice[k] * GOLDEN
            g["v"] = value(g)
            owned.append(g)
        if len(owned) > MAX_PETS:
            owned.remove(min(owned, key=lambda p: p["v"]))
        refresh()
    while t < minutes * 60:
        s = effective(best(), levels)
        earned = income_per_second(s) * step
        cash += earned
        t += step
        threshold = round(REBIRTH["base"] * REBIRTH["growth"] ** rebirths)
        saving = tier == 1 and rebirths >= SAVE_AFTER_REBIRTHS
        if saving:
            if cash >= DINER_PRICE:
                cash -= DINER_PRICE; tier = 2; marks.setdefault("diner", t)
            continue
        # New players spend everything until three pets are equipped, then a share of each sale.
        spin_budget += earned * (1 if len(owned) < EQUIP_SLOTS else SPIN_SHARE)
        machine = "DeluxeFryer" if tier >= 2 else "StarterFryer"
        price = MACHINES[machine]["price"]
        spins = 0
        while spin_budget >= price and cash >= price and spins < SPINS_PER_SECOND * step:
            spin(machine); spin_budget -= price; spins += 1
            marks.setdefault("first spin", t)
            if any(p["rarity"] == "Epic" for p in owned): marks.setdefault("first Epic", t)
            if any(p["rarity"] == "Legendary" for p in owned): marks.setdefault("first Legendary", t)
        if cash >= threshold:
            cash, spin_budget = 0.0, 0.0
            gems += REBIRTH["base_gems"] + REBIRTH["gems_per"] * rebirths
            rebirths += 1
            marks.setdefault(f"rebirth {rebirths}", t)
            while True:
                costs = {k: round(UPGRADE["base_cost"][k] * UPGRADE["growth"] ** levels[k]) for k in levels}
                k = min(costs, key=costs.get)
                if costs[k] > gems: break
                gems -= costs[k]; levels[k] += 1
    s = effective(best(), levels)
    marks["_end"] = dict(rebirths=rebirths, tier=tier, levels=levels, income=income_per_second(s), stats=s,
                         equipped=[p["name"] + (" (G)" if p["golden"] else "") for p in best()])
    return marks


SAVE_AFTER_REBIRTHS = 3

def main():
    global MACHINES
    MACHINES = build_machines()
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs", type=int, default=200)
    parser.add_argument("--minutes", type=int, default=240)
    args = parser.parse_args()
    results = [run(seed, args.minutes) for seed in range(args.runs)]
    keys = ["first spin", "first Epic", "first Legendary"] + [f"rebirth {i}" for i in range(1, 16)] + ["diner"]
    print(f"Median over {args.runs} runs ({args.minutes} min each):")
    for key in keys:
        times = [r[key] for r in results if key in r]
        if times:
            print(f"  {key:16s} {statistics.median(times) / 60:7.1f} min   (reached in {len(times)}/{args.runs})")
    print("\nIncome per second with one pet equipped (fresh player):")
    for mid, m in MACHINES.items():
        for p in m["pets"]:
            print(f"  {mid:12s} {p['rarity']:9s} {p['name']:20s} +{p['click']:g} fries/click  +${p['money']:g}/fry  +{p['bag']:g} bag   ->  ${value(p):,.1f}/s")
    print(f"  {'base':12s} no pets: ${income_per_second(effective([], dict(click=0, money=0, bag=0))):,.2f}/s")
    end = results[0]["_end"]
    print("\nExample end state:", end)


if __name__ == "__main__":
    main()
