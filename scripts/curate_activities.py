#!/usr/bin/env python3
"""Curate assets/seed/activities.json from public Compendium sources.

Sources (fetched at build time, not committed):
  - 2011 Adult Compendium, cleaned JSON (andyreagan/compendium-of-physical-activity,
    863 rows: 2011 code + MET + description + category). Values spot-checked
    against the 2024 Adult Compendium (pacompendium.com) for top entries.
  - 2024 Older-Adult Compendium reference list (pacompendium.com,
    MET60+ values) joined per matched row.
  - A few Wii Sports rows from published means (Graves et al.) — the 2011
    Compendium covers Wii Fit but not Wii Sports specifically.

Design: hand-authored GROUPS below (simple metric display names) each
match one or more compendium rows; MET = mean of matched rows (1dp), OA =
mean of matched OA values. Fails loudly on any group with zero matches.

Output: compact seed rows {i, n, c, m, o?} = id, name, category, MET,
older-adult MET60 (optional). Rerun: python3 scripts/curate_activities.py
"""
import html as ihtml
import json
import os
import re

TMP = "/var/folders/8y/_h1gw8cx58b4ydzlkn61ngf80000gn/T/opencode"
OUT = "assets/seed/activities.json"

C_2011 = f"{TMP}/compendium.json"
OA_HTML = f"{TMP}/oa.html"

# A group: (display name, bucket, {cats, all, any, none}).
# cats: 2011 categories to consider ([] = any). all: every keyword must
# appear in the normalized description. any: list of keyword-lists, at
# least one inner list fully present. none: excluded keywords.
# Rows are claimed exclusively in group order.
G = []


def g(name, bucket, cats=None, all=None, any=None, none=None):
    G.append({"n": name, "c": bucket, "cats": cats or [],
              "all": all or [], "any": any or [], "none": none or []})


# ── Housework ─────────────────────────────────────────────────────────
g("Cooking", "Housework", ["home_activity"], ["cook"], none=["indian"])
g("Washing dishes", "Housework", ["home_activity"], ["wash dishes"])
g("Laundry", "Housework", ["home_activity"], ["laundry"])
g("Ironing", "Housework", ["home_activity"], ["ironing"])
g("Dusting", "Housework", ["home_activity"], ["dusting"])
g("Vacuuming", "Housework", ["home_activity"], ["vacuuming", "general"])
g("Mopping floors", "Housework", ["home_activity"], ["mopping", "moderate"])
g("Sweeping", "Housework", ["home_activity"], ["sweeping", "slow"])
g("Cleaning windows", "Housework", ["home_activity"], ["cleaning windows"])
g("Scrubbing bathroom", "Housework", ["home_activity"], ["scrubbing"])
g("Making beds", "Housework", ["home_activity"], ["making bed"])
g("Tidying & organizing", "Housework", ["home_activity"],
  any=[["putting away household"], ["organizing room"]])
g("Taking out rubbish", "Housework", ["home_activity"],
  ["carrying out trash"])
g("Grocery shopping", "Housework", ["home_activity"], ["groceries"],
  none=["upstairs"])
g("Playing with kids", "Housework", ["home_activity"],
  ["playing with child"], none=["sitting", "standing,"])
g("Playing with pets", "Housework", ["home_activity"],
  ["playing with animals", "walk"])
g("Moving furniture", "Housework", ["home_activity"],
  ["moving furniture"], none=["upstairs"])

# ── Garden & Lawn ─────────────────────────────────────────────────────
g("Gardening (easy / weeding, potting)", "Garden & Lawn", ["lawn_garden"],
  any=[["weeding, cultivating garden, light"], ["planting, potting"],
       ["using containers"]])
g("Gardening (moderate / planting, pruning)", "Garden & Lawn",
  ["lawn_garden"],
  any=[["planting seedlings, shrub"], ["planting crops or garden"],
       ["trimming shrubs or trees, manual"], ["gardening, general"]])
g("Gardening (hard / digging, hauling)", "Garden & Lawn", ["lawn_garden"],
  any=[["digging, spading, filling garden, composting, vigorous"],
       ["taylor code 590)"], ["hauling branches"], ["wheelbarrow"]])
g("Mowing (push mower)", "Garden & Lawn", ["lawn_garden"],
  ["mowing lawn, general"])
g("Mowing (ride-on)", "Garden & Lawn", ["lawn_garden"], ["riding mower"])
g("Raking leaves", "Garden & Lawn", ["lawn_garden"], ["raking lawn"])
g("Trimming hedges", "Garden & Lawn", ["lawn_garden"],
  ["trimming shrubs or trees, power"])
g("Watering plants", "Garden & Lawn", ["home_activity"],
  ["watering plants"])
g("Chopping wood", "Garden & Lawn", ["lawn_garden"], ["chopping wood"])
g("Shovelling snow", "Garden & Lawn", ["lawn_garden"],
  any=[["shoveling snow, by hand, moderate"], ["shovelling snow, by hand"],
       ["shoveling snow, by hand, vigorous"]])
g("Picking fruit", "Garden & Lawn", ["lawn_garden"], ["picking fruit"])

# ── Home Repair ───────────────────────────────────────────────────────
g("Painting walls", "Home Repair", ["home_repair"],
  any=[["painting inside house"], ["painting, (taylor code 630)"]])
g("Carpentry & repairs", "Home Repair", ["home_repair"],
  any=[["carpentry, general"], ["carpentry, home remodeling tasks, moderate"]])
g("Home repairs (general)", "Home Repair", ["home_repair"],
  ["home repair, general"])
g("Plumbing", "Home Repair", ["home_repair"], ["plumbing"])
g("Washing the car", "Home Repair", ["home_repair"],
  ["washing and waxing car"])

# ── Walking (metric) ──────────────────────────────────────────────────
g("Strolling (3 km/h)", "Walking", ["walking"], ["less than 20 mph"])
g("Walking (easy, 4 km/h)", "Walking", ["walking"], ["walking, 2.5 mph, level"])
g("Walking (brisk, 5 km/h)", "Walking", ["walking"], ["walking, 2.8 to 3.2 mph"])
g("Walking (fast, 5.5 km/h)", "Walking", ["walking"], ["walking, 3.5 mph, level"])
g("Walking (very fast, 6.5 km/h)", "Walking", ["walking"], ["walking, 4.0 mph"])
g("Hiking", "Walking", ["walking"],
  any=[["hiking, cross country"], ["fields and hillsides"]])
g("Hiking (steep, heavy pack)", "Walking", ["walking"],
  any=[["backpacking"]])
g("Walking uphill", "Walking", ["walking"],
  any=[["1 to 5% grade"], ["climbing hills, no load"]])
g("Walking the dog", "Walking", ["walking"], ["walking the dog"])
g("Climbing stairs", "Walking", ["walking"], ["stair climbing, slow"])
g("Walking with pram", "Walking", ["walking"], ["stroller"])

# ── Running (metric) ──────────────────────────────────────────────────
g("Jogging", "Running", ["running"], ["jogging, general"])
g("Running (8 km/h)", "Running", ["running"], ["running, 5 mph"])
g("Running (10 km/h)", "Running", ["running"], ["running, 6 mph"])
g("Running (12 km/h)", "Running", ["running"], ["running, 7.5 mph"])
g("Running (14 km/h)", "Running", ["running"], ["running, 8.6 mph"])
g("Running (16 km/h)", "Running", ["running"], ["running, 10 mph"])
g("Running stairs", "Running", ["running"], ["stairs, up"])
g("Trail running", "Running", ["running"], ["cross country"])

# ── Cycling (metric) ──────────────────────────────────────────────────
g("Cycling (leisurely)", "Cycling", ["bicycling"], ["<10 mph"])
g("Cycling (easy, 16 km/h)", "Cycling", ["bicycling"], ["10-119 mph"])
g("Cycling (moderate, 20 km/h)", "Cycling", ["bicycling"], ["12-139 mph"])
g("Cycling (fast, 25 km/h)", "Cycling", ["bicycling"], ["14-159 mph"])
g("Cycling (racing)", "Cycling", ["bicycling"], ["racing"])
g("Exercise bike (moderate)", "Cycling", ["conditioning_exercise"],
  any=[["51-89 watts"], ["30-50 watts"]])
g("Exercise bike (hard)", "Cycling", ["conditioning_exercise"],
  any=[["90-100 watts"], ["101-160 watts"], ["spin bike"]])
g("Mountain biking", "Cycling", ["bicycling"], ["mountain, general"])

# ── Swimming ──────────────────────────────────────────────────────────
g("Swimming (easy)", "Swimming", ["water_activities"],
  ["backstroke, recreational"])
g("Swimming (moderate laps)", "Swimming", ["water_activities"],
  ["freestyle, slow"])
g("Swimming (fast laps)", "Swimming", ["water_activities"],
  ["freestyle, fast"])
g("Water aerobics", "Swimming", ["water_activities"], ["water aerobics"])

# ── Water sports ──────────────────────────────────────────────────────
g("Surfing", "Water sports", ["water_activities"],
  ["surfing, body or board, general"])
g("Kayaking", "Water sports", ["water_activities"],
  ["kayaking, moderate effort"])
g("Snorkelling", "Water sports", ["water_activities"], ["snorkeling"])
g("Paddle boarding", "Water sports", ["water_activities"],
  ["paddle boarding"])

# ── Gym & Fitness ─────────────────────────────────────────────────────
g("Yoga", "Gym & Fitness", ["conditioning_exercise"], ["yoga, hatha"])
g("Stretching", "Gym & Fitness", ["conditioning_exercise"],
  any=[["stretching"]])
g("Tai chi", "Gym & Fitness", ["sports"], ["tai chi, qi gong, general"])
g("Weights (light)", "Gym & Fitness", ["conditioning_exercise"],
  ["8-15 repetitions"])
g("Weights (moderate)", "Gym & Fitness", ["conditioning_exercise"],
  ["squats"])
g("Weights (hard)", "Gym & Fitness", ["conditioning_exercise"],
  ["power lifting"])
g("Bodyweight (push-ups, core)", "Gym & Fitness",
  ["conditioning_exercise"], ["calisthenics"],
  none=["vigorous effort"])
g("Circuit training", "Gym & Fitness", ["conditioning_exercise"],
  ["circuit training, moderate"])
g("Kettlebells (hard)", "Gym & Fitness", ["conditioning_exercise"],
  ["kettlebells"])
g("Rowing machine (moderate)", "Gym & Fitness", ["conditioning_exercise"],
  ["rowing, stationary, general, moderate"])
g("Rowing machine (hard)", "Gym & Fitness", ["conditioning_exercise"],
  ["150 watts"])
g("Elliptical", "Gym & Fitness", ["conditioning_exercise"],
  ["elliptical trainer, moderate"])
g("Aerobics class", "Gym & Fitness", ["conditioning_exercise"],
  ["conditioning classes"])
g("Skipping", "Gym & Fitness", ["sports", "conditioning_exercise"],
  ["rope"], none=["climb"])
g("Boxing (bag)", "Gym & Fitness", ["sports"], ["punching bag"])
g("Martial arts", "Gym & Fitness", ["sports"],
  ["martial arts, different types, slower"])

# ── Sports ────────────────────────────────────────────────────────────
g("Soccer (casual)", "Sports", ["sports"], ["soccer, casual"])
g("Soccer (competitive)", "Sports", ["sports"], ["soccer, competitive"])
g("Basketball (shooting around)", "Sports", ["sports"],
  ["shooting baskets"])
g("Basketball (game)", "Sports", ["sports"], ["basketball, game"],
  none=["nongame"])
g("Tennis", "Sports", ["sports"], ["tennis, singles"])
g("Tennis (doubles)", "Sports", ["sports"], ["doubles (taylor"])
g("Badminton", "Sports", ["sports"], ["badminton, social"])
g("Squash", "Sports", ["sports"], ["squash, general"])
g("Table tennis", "Sports", ["sports"], ["ping pong"])
g("Volleyball (beach)", "Sports", ["sports"], ["beach"])
g("Volleyball (indoor)", "Sports", ["sports"], ["volleyball (taylor"])
g("Baseball / softball", "Sports", ["sports"],
  ["slow pitch, general"])
g("Golf (walking)", "Sports", ["sports"],
  any=[["walking, carrying clubs"], ["walking, pulling clubs"]])
g("Golf (cart)", "Sports", ["sports"], ["power cart"])
g("Cricket", "Sports", ["sports"], ["cricket"])
g("Rugby (touch)", "Sports", ["sports"], ["touch, non-competitive"])
g("Bowling", "Sports", ["sports"], ["bowling (taylor"])
g("Rock climbing", "Sports", ["sports"],
  any=[["low-to-moderate difficulty"], ["high difficulty"]])
g("Skateboarding", "Sports", ["sports"],
  ["skateboarding, general, moderate"])
g("Ultimate frisbee", "Sports", ["sports"], ["ultimate"])
g("Horse riding", "Sports", ["sports"], ["horseback riding, general"])
g("Hockey (ice)", "Sports", ["sports"], ["ice, general"])

# ── Dancing ───────────────────────────────────────────────────────────
g("Dancing (slow / ballroom)", "Dancing", ["dancing"], ["ballroom, slow"])
g("Dancing (salsa, cultural)", "Dancing", ["dancing"],
  ["ethnic or cultural"])
g("Dancing (party)", "Dancing", ["dancing"], ["general dancing"],
  none=["competitive"])
g("Ballet (class)", "Dancing", ["dancing"], ["rehearsal or class"])

# ── Water & Winter ────────────────────────────────────────────────────
g("Cross-country skiing", "Water & Winter", ["winter_activities"],
  ["40-49 mph"])
g("Downhill skiing & snowboarding", "Water & Winter",
  ["winter_activities"], ["alpine or snowboarding, moderate"])
g("Ice skating", "Water & Winter", ["winter_activities"],
  any=[["general (taylor 360)"], ["9 mph or less"]])
g("Snowshoeing", "Water & Winter", ["winter_activities"],
  ["snow shoeing, moderate"])
g("Sledding", "Water & Winter", ["winter_activities"], ["sledding"],
  none=["dog sledding"])

# ── Daily Movement ────────────────────────────────────────────────────
g("Nordic walking", "Walking", ["walking"], ["nordic", "moderate"])

# ── Exergaming (Wii-era) ──────────────────────────────────────────────
g("Wii Fit (easy / balance games)", "Exergaming",
  ["conditioning_exercise"], ["wii fit), light"])
g("Wii Fit (moderate / aerobic games)", "Exergaming",
  ["conditioning_exercise"], ["wii fit), moderate"])
g("Dance games (hard)", "Exergaming", ["conditioning_exercise"],
  ["exergaming, dance dance"])

# Manual rows (published means, Graves et al.) — 2011 lacks Wii Sports.
MANUAL = [
    ("Wii Sports (bowling, tennis)", "Exergaming", 2.5, None),
    ("Wii Sports (boxing)", "Exergaming", 4.0, None),
]

SKIP_SUBSTRINGS = [
    "sleeping", "sexual activity", "reclining with baby",
    "sitting, playing traditional video game",
]


def norm(s):
    return re.sub(r"[^a-z0-9 ]", "", s.lower()).strip()


def slug(name):
    s = re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")
    return "act_" + re.sub(r"_+", "_", s)[:60]


def load_oa():
    """Parse MET60 triplets from the saved OA reference page."""
    h = open(OA_HTML).read()
    t = ihtml.unescape(re.sub(r"<[^>]+>", "|", h))
    cells = [c.strip() for c in t.split("|") if c.strip()]
    oa = {}
    i = 0
    while i < len(cells) - 2:
        code, met, desc = cells[i], cells[i + 1], cells[i + 2]
        if (re.fullmatch(r"\d{7}", code or "")
                and re.fullmatch(r"\d+(\.\d+)?", met or "")
                and desc and len(desc) > 4
                and "Activity Description" not in desc):
            key = norm(desc)
            if key not in oa:
                oa[key] = float(met)
            i += 3
        else:
            i += 1
    return oa


def oa_lookup(oa, desc):
    key = norm(desc)
    if key in oa:
        return oa[key]
    segs = [s.strip() for s in key.split(",")]
    for end in range(len(segs) - 1, 1, -1):
        short = ", ".join(segs[:end])
        if short in oa:
            return oa[short]
    return None


def _hit(key, kw):
    # Numeric phrases match as a whole with boundaries ('5 mph' must not
    # match '7.5 mph', normalized '75 mph'; the standalone '6' in
    # '6 min/mile' must not satisfy '6 mph').
    # Non-numeric phrases match when every word is present, not
    # necessarily adjacent ('freestyle, slow' ~ 'freestyle, front
    # crawl, slow'); bare stems match by substring ('cook' ~ 'cooking').
    nkw = norm(kw)
    if re.search(r"\d", nkw):
        return re.search(r"\b" + re.escape(nkw) + r"\b", key) is not None
    return all(w in key for w in nkw.split())


def row_matches(r, group):
    if group["cats"] and (r.get("('Category', '')") or "") not in group["cats"]:
        return False
    desc = (r.get("('Description', '')") or "")
    key = norm(desc)
    if any(_hit(key, s) for s in group["none"]):
        return False
    if not all(_hit(key, w) for w in group["all"]):
        return False
    if group["any"]:
        if not any(all(_hit(key, w) for w in alt)
                   for alt in group["any"]):
            return False
    return True


def main():
    rows = json.load(open(C_2011))
    oa = load_oa()
    print(f"2011 rows: {len(rows)}, OA values parsed: {len(oa)}")

    # Drop retired/valueless rows up front.
    usable = []
    for r in rows:
        try:
            met = float(r.get("('2011 Compendium', 'METs')") or 0)
        except ValueError:
            continue
        if met <= 0:
            continue
        low = ((r.get("('Description', '')") or "")).lower()
        if any(s in low for s in SKIP_SUBSTRINGS):
            continue
        usable.append(r)

    picked = []
    claimed = set()
    for grp in G:
        matched = [r for idx, r in enumerate(usable)
                   if idx not in claimed and row_matches(r, grp)]
        if not matched:
            raise SystemExit(
                f"GROUP UNMATCHED: {grp['n']} {grp['all']} {grp['any']}")
        for idx, r in enumerate(usable):
            if r in matched:
                claimed.add(idx)
        mets = [float(r["('2011 Compendium', 'METs')"]) for r in matched]
        met = round(sum(mets) / len(mets), 1)
        oas = [o for o in
               (oa_lookup(oa, r.get("('Description', '')") or "")
                for r in matched) if o is not None]
        row = {"i": "", "n": grp["n"], "c": grp["c"], "m": met,
               "src": len(matched)}
        if oas:
            row["o"] = round(sum(oas) / len(oas), 1)
        picked.append(row)
    print(f"groups: {len(picked)}, compendium rows claimed: {len(claimed)}")

    for name, cat, met, o in MANUAL:
        row = {"i": "", "n": name, "c": cat, "m": met}
        if o:
            row["o"] = o
        picked.append(row)

    # Stable ids + display-name guards.
    used_ids = set()
    for p in picked:
        base = slug(p["n"])
        cand, n = base, 2
        while cand in used_ids:
            suffix = f"_{n}"
            cand = base[: 60 - len(suffix)] + suffix
            n += 1
        p["i"] = cand
        used_ids.add(cand)
        assert len(p["n"]) <= 48, f"NAME TOO LONG: {p['n']}"
        assert not re.search(
            r"mph|mile|pounds?|\blbs?\b|inch|feet|\bfoot\b|yard|watts?",
            p["n"], re.I), f"IMPERIAL: {p['n']}"

    # Load-bearing anchors (sourced reference values).
    anchors = {
        "Running (10 km/h)": 9.8,
        "Mowing (push mower)": 5.5,
        "Gardening (moderate / planting, pruning)": 4.1,
        "Yoga": 2.5,
        "Swimming (moderate laps)": 5.8,
        "Wii Fit (easy / balance games)": 2.3,
    }
    by_name = {p["n"]: p for p in picked}
    for name, met in anchors.items():
        got = by_name.get(name, {}).get("m")
        if got is None or abs(got - met) > 0.05:
            raise SystemExit(f"ANCHOR FAILED: {name} expected {met}, got {got}")
    print("anchors passed")

    for p in picked:
        p.pop("src", None)
    out = {"v": 2,
           "source": "Compendium of Physical Activities (2011 codes/METs grouped & simplified; 2024 OA MET60+ where matched; Wii Sports rows: Graves et al. means)",
           "activities": picked}
    with open(OUT, "w") as f:
        json.dump(out, f, separators=(",", ":"))
    print(f"wrote {OUT}: {os.path.getsize(OUT)} bytes, {len(picked)} rows")


if __name__ == "__main__":
    main()
