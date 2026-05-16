#!/usr/bin/env python3
"""
Lifecycle check for the PersoMemory vault.

Surfaces three categories:
  1. OVERDUE: notes with review-by dates in the past
  2. STALE: active/winding-down outcome notes not updated in STALE_DAYS
  3. AGED LOOPS: open-loop commitments with an explicit date older than LOOP_AGE_DAYS

Usage:
  python3 lifecycle-check.py
  python3 lifecycle-check.py --stale-days 21 --loop-age-days 21
"""

import argparse
import os
import re
import sys
from datetime import date, datetime
from pathlib import Path

VAULT = Path(os.environ.get("VAULT_PATH", "/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultMemory"))
OUTCOMES_DIR = VAULT / "outcomes"
OPEN_LOOPS = VAULT / "execution" / "open-loops.md"

STALE_DAYS_DEFAULT = 14
LOOP_AGE_DAYS_DEFAULT = 14

ACTIVE_STATUSES = {"active", "winding-down"}


def parse_frontmatter(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    block = text[3:end].strip()
    result = {}
    for line in block.splitlines():
        m = re.match(r"^(\S+?):\s*(.*)$", line)
        if m:
            result[m.group(1)] = m.group(2).strip().strip("'\"")
    return result


def parse_date(val: str) -> date | None:
    for fmt in ("%Y-%m-%d", "%Y-%m-%dT%H:%M:%S.%fZ", "%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%dT%H:%M:%S"):
        try:
            return datetime.strptime(val[:len(fmt.replace("%", "XX").replace("XX", "0000"))], fmt).date()
        except (ValueError, TypeError):
            continue
    # Handle ISO datetime strings like "2026-05-12T00:00:00.000Z"
    m = re.match(r"(\d{4}-\d{2}-\d{2})", str(val))
    if m:
        try:
            return date.fromisoformat(m.group(1))
        except ValueError:
            pass
    return None


def check_outcomes(today: date, stale_days: int) -> tuple[list, list]:
    overdue = []
    stale = []

    for p in sorted(OUTCOMES_DIR.glob("*.md")):
        fm = parse_frontmatter(p)
        status = fm.get("status", "").lower()
        name = p.stem

        review_by_raw = fm.get("review-by")
        if review_by_raw:
            d = parse_date(review_by_raw)
            if d and d <= today:
                overdue.append({
                    "note": f"outcomes/{name}",
                    "status": status,
                    "review-by": str(d),
                    "days_overdue": (today - d).days,
                })

        if status in ACTIVE_STATUSES:
            updated_raw = fm.get("updated")
            if updated_raw:
                d = parse_date(updated_raw)
                if d:
                    age = (today - d).days
                    if age >= stale_days:
                        stale.append({
                            "note": f"outcomes/{name}",
                            "status": status,
                            "last_updated": str(d),
                            "days_since_update": age,
                        })
            else:
                mtime = date.fromtimestamp(p.stat().st_mtime)
                age = (today - mtime).days
                if age >= stale_days:
                    stale.append({
                        "note": f"outcomes/{name}",
                        "status": status,
                        "last_updated": f"file mtime {mtime}",
                        "days_since_update": age,
                    })

    return overdue, stale


def check_open_loops(today: date, loop_age_days: int) -> list:
    if not OPEN_LOOPS.exists():
        return []

    text = OPEN_LOOPS.read_text(encoding="utf-8")
    aged = []

    date_pattern = re.compile(r"added\s+(\d{4}-\d{2}-\d{2})", re.IGNORECASE)
    lines = text.splitlines()
    for line in lines:
        if not line.strip().startswith(("-", "*", "1", "2", "3", "4", "5", "6", "7", "8", "9")):
            continue
        m = date_pattern.search(line)
        if m:
            d = parse_date(m.group(1))
            if d:
                age = (today - d).days
                if age >= loop_age_days:
                    label = line.strip().lstrip("-*0123456789. ").strip()[:80]
                    aged.append({
                        "commitment": label,
                        "added": str(d),
                        "days_open": age,
                    })

    return aged


def print_section(title: str, items: list, formatter):
    if not items:
        print(f"  (none)\n")
        return
    for item in items:
        formatter(item)
    print()


def main():
    parser = argparse.ArgumentParser(description="PersoMemory lifecycle check")
    parser.add_argument("--stale-days", type=int, default=STALE_DAYS_DEFAULT)
    parser.add_argument("--loop-age-days", type=int, default=LOOP_AGE_DAYS_DEFAULT)
    args = parser.parse_args()

    today = date.today()
    print(f"Lifecycle check: {today}\n")
    print("=" * 60)

    overdue, stale = check_outcomes(today, args.stale_days)

    print(f"\n[OVERDUE] Notes past their review-by date ({len(overdue)})")
    print_section("overdue", overdue, lambda i: print(
        f"  {i['note']:<40} status={i['status']:<14} review-by={i['review-by']}  ({i['days_overdue']}d overdue)"
    ))

    print(f"[STALE] Active/winding-down outcomes not updated in {args.stale_days}+ days ({len(stale)})")
    print_section("stale", stale, lambda i: print(
        f"  {i['note']:<40} status={i['status']:<14} last={i['last_updated']}  ({i['days_since_update']}d ago)"
    ))

    aged_loops = check_open_loops(today, args.loop_age_days)
    print(f"[AGED LOOPS] Open commitments with explicit date older than {args.loop_age_days}d ({len(aged_loops)})")
    print_section("loops", aged_loops, lambda i: print(
        f"  {i['added']} ({i['days_open']}d open)  {i['commitment']}"
    ))

    total = len(overdue) + len(stale) + len(aged_loops)
    print("=" * 60)
    if total == 0:
        print("All clear. No lifecycle issues found.")
    else:
        print(f"{total} item(s) need attention.")


if __name__ == "__main__":
    main()
