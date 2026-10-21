"""Balance simulation: flat three-stat pets, percentage upgrades, and restaurant tiers.

Models one player who taps at the click limit, sells every full bag, spins the best machine
they have unlocked, merges five copies into Golden, equips the best three, spends gems on the
cheapest upgrade, rebirths at the threshold, and after a few rebirths saves up for the next
restaurant tier. Reports the median time to milestones over many runs. Numbers are first
guesses to tune from playtests; mirror agreed values into src/shared/config.

    python3 tools/simulate.py
    python3 tools/simulate.py --runs 60 --minutes 200
"""
import argparse
import random
import statistics

# ---- Numbers (mirror into src/shared/config) -----------------------------------------------
BASE = dict(click=2, money=1.00, bag=40)      # Economy: fries/click, $/fry, bag
FRYER_PER_SECOND = 0.5
CLICKS_PER_SECOND = 4
SELL_SECONDS = 0.75                            # tapping Sell after a full bag
SPINS_PER_SECOND = 1.5

# Starter pet stats (click, money, bag); every later machine is TIER_STEP x the one before.
STARTER = [
    ("Common", (4, 1.00, 10)), ("Common", (2, 2.00, 10)), ("Common", (2, 1.00, 20)),
    ("Uncommon", (6, 1.50, 15)), ("Uncommon", (3, 3.00, 15)),
    ("Rare", (4, 4.00, 20)), ("Epic", (6, 3.00, 60)), ("Legendary", (12, 6.00, 60)),
]
TIER_STEP = 4
ODDS = dict(Common=0.60, Uncommon=0.25, Rare=0.10, Epic=0.04, Legendary=0.01)
PITY = 50
# Restaurant tiers: Cash to unlock (tier 1 is free) and the spin price of its machine.
TIERS = [
    dict(name="Fry Stand", unlock=0, spin=150),
    dict(name="Fry Diner", unlock=5e6, spin=150e3),      # approved 20 Oct 2026
    dict(name="Drive-In", unlock=30e6, spin=1.5e6),      # tiers 3-6 from --calibrate, rounded
    dict(name="Fish & Chips Pier", unlock=750e6, spin=25e6),
    dict(name="Cosmic Diner", unlock=10e9, spin=200e6),
    dict(name="Fry Palace", unlock=350e9, spin=4e9),
]
UPGRADE = dict(percent_per_level=0.10, base_cost=dict(click=3, money=4, bag=5), growth=1.25)
REBIRTH = dict(base=250000, growth=2.0, base_gems=10, gems_per=5)
EQUIP_SLOTS, MAX_PETS, MERGE, GOLDEN = 3, 50, 5, 2
SPIN_SHARE = 0.5           # share of each sale spent on spins once three pets are owned
REBIRTHS_PER_TIER = 3      # rebirths after each new tier before saving for the next one
RANK = dict(Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5)


def pets_for(tier):
    scale = TIER_STEP ** (tier - 1)
    return [dict(tier=tier, rarity=r, click=c * scale, money=m * scale, bag=b * scale, index=i)
            for i, (r, (c, m, b)) in enumerate(STARTER)]


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


NO_LEVELS = dict(click=0, money=0, bag=0)
def value(p): return income_per_second(effective([p], NO_LEVELS))


def run(seed, minutes):
    rng = random.Random(seed)
    t, cash, gems, rebirths, tier, rebirths_at_tier = 0.0, 0.0, 0, 0, 1, 0
    levels = dict(click=0, money=0, bag=0)
    owned, pity, marks = [], {}, {}
    best, budget = [], 0.0
    pools = {n: pets_for(n) for n in range(1, len(TIERS) + 1)}

    def refresh():
        nonlocal best
        best = sorted(owned, key=lambda p: p["v"], reverse=True)[:EQUIP_SLOTS]

    def spin(n):
        nonlocal cash
        cash -= TIERS[n - 1]["spin"]
        pity[n] = pity.get(n, 0) + 1
        roll, acc, rarity = rng.random(), 0, "Common"
        for r, chance in ODDS.items():
            acc += chance
            if roll < acc: rarity = r; break
        if pity[n] >= PITY and RANK[rarity] < 4: rarity = "Epic"
        if RANK[rarity] >= 4: pity[n] = 0
        pet = dict(rng.choice([p for p in pools[n] if p["rarity"] == rarity]), golden=False)
        pet["v"] = value(pet)
        owned.append(pet)
        same = [p for p in owned if p["tier"] == pet["tier"] and p["index"] == pet["index"] and not p["golden"]]
        if len(same) >= MERGE:
            for p in same[:MERGE]: owned.remove(p)
            g = dict(pet, golden=True)
            for k in ("click", "money", "bag"): g[k] = pet[k] * GOLDEN
            g["v"] = value(g); owned.append(g)
        if len(owned) > MAX_PETS: owned.remove(min(owned, key=lambda p: p["v"]))
        refresh()
        if rarity == "Legendary": marks.setdefault(f"T{n} Legendary", t)

    while t < minutes * 60:
        earned = income_per_second(effective(best, levels))
        cash += earned
        t += 1
        if tier < len(TIERS) and rebirths_at_tier >= REBIRTHS_PER_TIER:
            marks.setdefault(f"save income {tier + 1}", earned)
            if cash >= TIERS[tier]["unlock"]:
                cash -= TIERS[tier]["unlock"]; tier += 1; rebirths_at_tier = 0
                marks.setdefault(f"tier {tier}", t); budget = 0
                marks.setdefault(f"arrive income {tier}", earned)
            continue
        new_tier_pets = sum(1 for p in owned if p["tier"] == tier)
        budget += earned * (1 if new_tier_pets < EQUIP_SLOTS else SPIN_SHARE)
        price, spins = TIERS[tier - 1]["spin"], 0
        while budget >= price and cash >= price and spins < SPINS_PER_SECOND:
            spin(tier); budget -= price; spins += 1
            marks.setdefault("first spin", t)
        threshold = round(REBIRTH["base"] * REBIRTH["growth"] ** rebirths)
        if cash >= threshold:
            cash, budget = 0.0, 0.0
            gems += REBIRTH["base_gems"] + REBIRTH["gems_per"] * rebirths
            rebirths += 1; rebirths_at_tier += 1
            marks.setdefault(f"rebirth {rebirths}", t)
            while True:
                costs = {k: round(UPGRADE["base_cost"][k] * UPGRADE["growth"] ** levels[k]) for k in levels}
                k = min(costs, key=costs.get)
                if costs[k] > gems: break
                gems -= costs[k]; levels[k] += 1
        if tier == len(TIERS): marks.setdefault("max tier income", income_per_second(effective(best, levels)))
    marks["_end"] = dict(rebirths=rebirths, tier=tier, levels=levels, income=income_per_second(effective(best, levels)))
    return marks


def calibrate(save_seconds=300, save_growth=1.5, spin_seconds=20, runs=12, fixed=(2,)):
    """Sets each tier's unlock price to save_seconds of the income a player has when they start
    saving for it, and its spin price to spin_seconds of their income on arrival."""
    global TIERS
    full = [dict(t) for t in TIERS]
    for n in range(2, len(full) + 1):
        if n in fixed: continue  # owner-approved prices stay
        TIERS = full[:n - 1]
        TIERS.append(dict(full[n - 1], unlock=1e300, spin=1e300))  # unreachable while measuring
        rs = [run(seed, 400) for seed in range(runs)]
        saving = statistics.median([r[f"save income {n}"] for r in rs if f"save income {n}" in r])
        full[n - 1]["unlock"] = float(f"{saving * save_seconds * save_growth ** (n - 2):.2g}")
        TIERS = full[:n]
        rs = [run(seed, 400) for seed in range(runs)]
        arrive = statistics.median([r[f"arrive income {n}"] for r in rs if f"arrive income {n}" in r])
        full[n - 1]["spin"] = float(f"{arrive * spin_seconds:.2g}")
        print(f"  tier {n}: saving income ${saving:,.0f}/s -> unlock ${full[n-1]['unlock']:,.0f};"
              f" arrival income ${arrive:,.0f}/s -> spin ${full[n-1]['spin']:,.0f}", flush=True)
    TIERS = full


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs", type=int, default=40)
    parser.add_argument("--minutes", type=int, default=200)
    parser.add_argument("--calibrate", action="store_true", help="derive tier prices from simulated income")
    args = parser.parse_args()
    if args.calibrate: calibrate()
    results = [run(seed, args.minutes) for seed in range(args.runs)]
    print(f"Median over {args.runs} runs ({args.minutes} min each):")
    keys = ["first spin", "rebirth 1", "rebirth 3"] + [f"tier {n}" for n in range(2, len(TIERS) + 1)] + \
        [f"T{n} Legendary" for n in range(1, len(TIERS) + 1)] + [f"rebirth {n}" for n in (10, 15, 20, 25)]
    for key in keys:
        times = [r[key] for r in results if key in r]
        if times:
            print(f"  {key:16s} {statistics.median(times) / 60:7.1f} min   (reached in {len(times)}/{args.runs})")
    ends = [r["_end"] for r in results]
    print("  end: median rebirths", statistics.median(e["rebirths"] for e in ends),
          " median tier", statistics.median(e["tier"] for e in ends))
    print("\nOne pet on a fresh player (income per second):")
    for n in range(1, len(TIERS) + 1):
        pool = pets_for(n)
        print(f"  tier {n} {TIERS[n-1]['name']:18s} Common ${value(pool[0]):,.0f}/s  Legendary ${value(pool[7]):,.0f}/s  "
              f"spin ${TIERS[n-1]['spin']:,.0f}  unlock ${TIERS[n-1]['unlock']:,.0f}")


if __name__ == "__main__":
    main()
